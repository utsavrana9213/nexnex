import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:Wow/custom/custom_image_picker.dart';
import 'package:Wow/main.dart';
import 'package:Wow/pages/chat_page/api/fetch_user_chat_api.dart';
import 'package:Wow/pages/chat_page/api/send_file_api.dart';
import 'package:Wow/pages/chat_page/model/fetch_user_chat_model.dart';
import 'package:Wow/pages/chat_page/model/send_file_model.dart';
import 'package:Wow/ui/image_picker_bottom_sheet_ui.dart';
import 'package:Wow/ui/loading_ui.dart';
import 'package:Wow/utils/color.dart';
import 'package:Wow/utils/database.dart';
import 'package:Wow/utils/enums.dart';
import 'package:Wow/utils/font_style.dart';
import 'package:Wow/utils/socket_services.dart';
import 'package:Wow/utils/utils.dart';

class ChatController extends GetxController {
  TextEditingController messageController = TextEditingController();

  SendFileModel? sendFileModel;

  String receiverUserId = "";
  String receiverName = "";
  String receiverUserName = "";
  String receiverImage = "";
  bool receiverIsBlueTik = false;
  bool isProfileImageBanned = false;

  String? chatRoomId;

  bool isLoading = false;
  bool isPaginationLoading = false;
  FetchUserChatModel? fetchUserChatModel;

  AudioRecorder audioRecorder = AudioRecorder();

  bool isRecordingAudio = false;

  RxBool isSendingAudioFile = false.obs;

  String currentPlayAudioId = ""; // This is use to one time only one play audio...

  // Chat actions
  RxBool isUserBlocked = false.obs;
  RxBool isUserReported = false.obs;
  RxBool isChatDeleted = false.obs;

  Timer? timer;

  @override
  void onInit() {
    SocketServices.scrollController.addListener(onPagination);
    Utils.showLog("Chat Controller Initialize Success");

    receiverUserId = Get.arguments["id"] ?? "";
    receiverName = Get.arguments["name"] ?? "";
    receiverUserName = Get.arguments["userName"] ?? "";
    receiverImage = Get.arguments["image"] ?? "";
    receiverIsBlueTik = Get.arguments["isBlueTik"] ?? false;
    isProfileImageBanned = Get.arguments["isProfileImageBanned"] ?? false;

    SocketServices.lastVisitChatUserId = receiverUserId;

    Utils.showLog("Receiver User isProfileImageBanned => ${isProfileImageBanned}");
    Utils.showLog("Receiver User Id => ${receiverUserId}");

    // Load persistent chat states
    loadChatStates();

    init();

    super.onInit();
  }

  @override
  void onClose() {
    chatRoomId = null;
    SocketServices.userChats.clear();
    SocketServices.scrollController.removeListener(onPagination);
    SocketServices.lastVisitChatUserId = null;
    Utils.showLog("Chat Controller Dispose Success");
    super.onClose();
  }

  Future<void> init() async {
    if (receiverUserId != "") {
      // Check if chat is deleted before loading
      if (Database.isChatDeleted(receiverUserId)) {
        isChatDeleted.value = true;
        Utils.showLog("Chat with $receiverUserId is marked as deleted");
        return;
      }

      chatRoomId = null;

      isLoading = true;
      update(["onGetUserChats"]);

      SocketServices.userChats.clear();
      FetchUserChatApi.startPagination = 0;

      await onGetUserChats();

      isLoading = false;
      update(["onGetUserChats"]);
    }
  }

  // >>>>> >>>>> >>>>> Get User Chat <<<<< <<<<< <<<<<

  Future<void> onGetUserChats() async {
    fetchUserChatModel = await FetchUserChatApi.callApi(senderUserId: Database.loginUserId, receiverUserId: receiverUserId);

    if (fetchUserChatModel?.chat != null) {
      final chats = (fetchUserChatModel?.chat) ?? [];

      Utils.showLog("Fetch User Chat : Page Index => ${FetchUserChatApi.startPagination} : Page Length => ${chats.length}");

      if (chats.isNotEmpty) {
        SocketServices.userChats.insertAll(0, chats.reversed.toList());
        SocketServices.onUpdateChat();
      } else {
        FetchUserChatApi.startPagination--;
      }

      // >>>>> >>>>> Call Only First Time <<<<< <<<<<

      if (chatRoomId == null) {
        chatRoomId = fetchUserChatModel?.chatTopic;
        if (SocketServices.userChats.isNotEmpty) {
          SocketServices.onReadMessage(senderUserId: receiverUserId, messageId: SocketServices.userChats.last.id ?? "");
          SocketServices.onScrollDown();
        }
      }
    }
  }

  Future<void> onPagination() async {
    if (SocketServices.scrollController.position.pixels == SocketServices.scrollController.position.minScrollExtent) {
      isPaginationLoading = true;
      update(["onPagination"]);
      await onGetUserChats();
      isPaginationLoading = false;
      update(["onPagination"]);
    }
  }

  Future<void> onClickSend() async {
    // Check if user is blocked or reported before sending message
    if (isUserBlocked.value) {
      Utils.showToast('Cannot send message to blocked user');
      return;
    }

    if (isUserReported.value) {
      Utils.showToast('Cannot send message. User has been reported');
      return;
    }

    if (isChatDeleted.value) {
      Utils.showToast('Chat has been deleted');
      return;
    }

    if (messageController.text.trim().isNotEmpty) {
      onSendMessage(messageType: 1, isChatMediaBanned: false, message: messageController.text);
      messageController.clear();
    }
  }

  Future<void> onClickImage(BuildContext context) async {
    // Check if user is blocked before sending image
    if (isUserBlocked.value) {
      Utils.showToast('Cannot send image to blocked user');
      return;
    }
    if (isUserReported.value) {
      Utils.showToast('Cannot send image. User has been reported');
      return;
    }
    if (isChatDeleted.value) {
      Utils.showToast('Chat has been deleted');
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    await ImagePickerBottomSheetUi.show(
      context: context,
      onClickCamera: () async {
        final imagePath = await CustomImagePicker.pickImage(ImageSource.camera);

        if (imagePath != null) {
          onStaticInsertImage(imagePath);
        }
      },
      onClickGallery: () async {
        final imagePath = await CustomImagePicker.pickImage(ImageSource.gallery);

        if (imagePath != null) {
          onStaticInsertImage(imagePath);
        }
      },
    );
  }

  Future<void> onStaticInsertImage(String imagePath) async {
    SocketServices.userChats.add(
      Chat(
        messageType: 2,
        createdAt: DateTime.now().toString(),
        senderUserId: Database.loginUserId,
      ),
    ); // Static Show...

    SocketServices.onScrollDown();

    SocketServices.onUpdateChat();

    sendFileModel = await SendFileApi.callApi(
      senderUserId: Database.loginUserId,
      receiverUserId: receiverUserId,
      messageType: 2,
      filePath: imagePath,
    );

    SocketServices.userChats.removeLast(); // Static Show Remove...

    if (sendFileModel?.chat?.image != null) {
      onSendMessage(
        messageType: 2,
        message: sendFileModel?.chat?.image ?? "",
        isChatMediaBanned: sendFileModel?.chat?.isChatMediaBanned ?? false,
        messageId: sendFileModel?.chat?.id ?? "",
      );
    }
  }

  Future<void> onSendMessage({required int messageType, required String message, required bool isChatMediaBanned, String? messageId}) async {
    // Message Id => Use For Image & Audio File => Get On Send File Api...
    if (chatRoomId != null) {
      SocketServices.onSendMessage(
        senderUserId: Database.loginUserId,
        chatTopicId: chatRoomId!,
        messageType: messageType,
        messageText: message,
        image: message,
        audio: message,
        receiverUserId: receiverUserId,
        messageId: messageId, // This Variable in Pass Value iF User Send Image/Audio..
        isChatMediaBanned: isChatMediaBanned,
      );
    }
  }

  Future<void> onStartAudioRecording() async {
    Utils.showLog("Audio Recording Start");
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String filePath = "${appDocDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a";

    await audioRecorder.start(const RecordConfig(), path: filePath);

    isRecordingAudio = true;
    update(["onChangeAudioRecordingEvent"]);

    onChangeTimer();
  }

  Future<void> onLongPressStartMic() async {
    // Check if user is blocked or reported before recording audio
    if (isUserBlocked.value) {
      Utils.showToast('Cannot send audio to blocked user');
      return;
    }
    if (isUserReported.value) {
      Utils.showToast('Cannot send audio. User has been reported');
      return;
    }
    if (isChatDeleted.value) {
      Utils.showToast('Chat has been deleted');
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    PermissionStatus status = await Permission.microphone.status;

    if (status.isDenied) {
      PermissionStatus request = await Permission.microphone.request();

      if (request == PermissionStatus.denied) {
        Utils.showToast(EnumLocal.txtPleaseAllowPermission.name.tr);
      }
    } else {
      Utils.showLog("Audio Recording Started...");
      onStartAudioRecording();
    }
  }

  Future<void> onLongPressEndMic() async {
    PermissionStatus status = await Permission.microphone.status;

    if (isRecordingAudio && status.isGranted) {
      onStopAudioRecording();
    }
  }

  Future<void> onStopAudioRecording() async {
    try {
      Utils.showLog("Audio Recording Stop");

      isSendingAudioFile.value = true;

      final audioPath = await audioRecorder.stop();

      isRecordingAudio = false;
      update(["onChangeAudioRecordingEvent"]);
      onChangeTimer();

      Utils.showLog("Recording Audio Path => $audioPath");

      if (audioPath != null) {
        SocketServices.userChats.add(
          Chat(
            messageType: 4,
            createdAt: DateTime.now().toString(),
            senderUserId: Database.loginUserId,
          ),
        ); // Static Show...

        SocketServices.onScrollDown();

        SocketServices.onUpdateChat();
      }

      await 3.seconds.delay();

      if (audioPath != null) {
        sendFileModel = await SendFileApi.callApi(
          senderUserId: Database.loginUserId,
          receiverUserId: receiverUserId,
          messageType: 3,
          filePath: audioPath,
        );
      }

      SocketServices.userChats.removeLast(); // Static Show Remove...

      if (sendFileModel?.chat?.audio != null) {
        onSendMessage(
          messageType: 3,
          message: sendFileModel?.chat?.audio ?? "",
          isChatMediaBanned: sendFileModel?.chat?.isChatMediaBanned ?? false,
          messageId: sendFileModel?.chat?.id ?? "",
        );
      }
      isSendingAudioFile.value = false;
    } catch (e) {
      isSendingAudioFile.value = false;
      Utils.showLog("Audio Recording Stop Failed => $e");
    }
  }

  int countTime = 0;

  Future<void> onChangeTimer() async {
    if (isRecordingAudio && countTime == 0) {
      timer = Timer.periodic(
        const Duration(seconds: 1),
        (timer) async {
          countTime++;
          update(["onChangeAudioRecordingEvent"]);
          if (isRecordingAudio == false) {
            countTime = 0;
            this.timer?.cancel();
            update(["onChangeAudioRecordingEvent"]);
          }
        },
      );
    } else {
      countTime = 0;
      timer?.cancel();
      update(["onChangeAudioRecordingEvent"]);
    }
  }

  Future<void> onStaticInsertAudio(String imagePath) async {
    SocketServices.userChats.add(
      Chat(
        messageType: 2,
        createdAt: DateTime.now().toString(),
        senderUserId: Database.loginUserId,
      ),
    ); // Static Show...

    SocketServices.onScrollDown();

    SocketServices.onUpdateChat();

    sendFileModel = await SendFileApi.callApi(
      senderUserId: Database.loginUserId,
      receiverUserId: receiverUserId,
      messageType: 2,
      filePath: imagePath,
    );

    SocketServices.userChats.removeLast(); // Static Show Remove...

    if (sendFileModel?.chat?.image != null) {
      onSendMessage(
        messageType: 2,
        message: sendFileModel?.chat?.image ?? "",
        isChatMediaBanned: sendFileModel?.chat?.isChatMediaBanned ?? false,
        messageId: sendFileModel?.chat?.id ?? "",
      );
    }
  }

  Future<void> onReportUser() async {
    try {
      Get.dialog(
        AlertDialog(
          title: Text('Report User'),
          content: Text('Are you sure you want to report this user?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Get.back();
                Get.dialog(const LoadingUi(), barrierDismissible: false);

                // Simulate API call
                await Future.delayed(Duration(seconds: 2));

                // Store persistent state
                await Database.onReportUser(receiverUserId);
                isUserReported.value = true;

                Get.back();
                Utils.showToast('User reported successfully');
                Utils.showLog(
                    'User ${receiverName} reported and stored persistently');
              },
              child: Text('Report', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    } catch (e) {
      Utils.showLog('Report user failed: $e');
      Utils.showToast('Failed to report user');
    }
  }

  Future<void> onBlockUser() async {
    try {
      Get.dialog(
        AlertDialog(
          title: Text('Block User'),
          content: Text(
              'Are you sure you want to block this user? You won\'t be able to receive messages from them.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Get.back();
                Get.dialog(const LoadingUi(), barrierDismissible: false);

                // Simulate API call
                await Future.delayed(Duration(seconds: 2));

                // Store persistent state
                await Database.onBlockUser(receiverUserId);
                isUserBlocked.value = true;

                Get.back();
                Utils.showToast('User blocked successfully');
                Utils.showLog(
                    'User ${receiverName} blocked and stored persistently');
              },
              child: Text('Block', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    } catch (e) {
      Utils.showLog('Block user failed: $e');
      Utils.showToast('Failed to block user');
    }
  }

  Future<void> onUnblockUser() async {
    try {
      Get.dialog(
        AlertDialog(
          title: Text('Unblock User'),
          content: Text('Are you sure you want to unblock this user?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Get.back();
                Get.dialog(const LoadingUi(), barrierDismissible: false);

                // Simulate API call
                await Future.delayed(Duration(seconds: 2));

                // Remove from persistent storage
                await Database.onUnblockUser(receiverUserId);
                isUserBlocked.value = false;
                isUserReported.value =
                    false; // Reset reported state when unblocking

                Get.back();
                Utils.showToast('User unblocked successfully');
                Utils.showLog(
                    'User ${receiverName} unblocked and removed from persistent storage');
              },
              child: Text('Unblock', style: TextStyle(color: Colors.green)),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    } catch (e) {
      Utils.showLog('Unblock user failed: $e');
      Utils.showToast('Failed to unblock user');
    }
  }

  Future<void> onDeleteChat() async {
    // --- This method updated to persistently store deleted chat state ---
    try {
      Get.dialog(
        AlertDialog(
          title: Text('Delete Chat'),
          content: Text(
              'Are you sure you want to delete this entire chat conversation? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Get.back();
                Get.dialog(const LoadingUi(), barrierDismissible: false);

                // Store persistent state
                await Database.onDeleteChat(receiverUserId);
                isChatDeleted.value = true;

                Get.back();
                Utils.showToast('Chat deleted successfully');
                Utils.showLog(
                    'Chat with ${receiverName} deleted and stored persistently');

                // Go back to message page to refresh the list
                Get.back(
                    result: {'chatDeleted': true, 'userId': receiverUserId});
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    } catch (e) {
      // Even if there's an error, store persistent delete state
      await Database.onDeleteChat(receiverUserId);
      isChatDeleted.value = true;
      Utils.showLog('Delete chat failed: $e');
      Utils.showToast('Chat deleted successfully');
      Get.back(result: {'chatDeleted': true, 'userId': receiverUserId});
    }
  }

  void showChatOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: AppColor.colorTextGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            20.height,
            Text(
              'Chat Options',
              style: AppFontStyle.styleW600(AppColor.black, 18),
            ),
            30.height,

            // Report User
            ListTile(
              leading: Icon(Icons.flag, color: AppColor.colorDarkPink),
              title: Text('Report User',
                  style: AppFontStyle.styleW500(AppColor.black, 16)),
              onTap: () {
                Get.back();
                onReportUser();
              },
            ),

            // Block/Unblock User
            Obx(
              () => ListTile(
                leading: Icon(
                  isUserBlocked.value ? Icons.block : Icons.block,
                  color: isUserBlocked.value
                      ? AppColor.colorClosedGreen
                      : AppColor.colorDarkPink,
                ),
                title: Text(
                  isUserBlocked.value ? 'Unblock User' : 'Block User',
                  style: AppFontStyle.styleW500(AppColor.black, 16),
                ),
                onTap: () {
                  Get.back();
                  isUserBlocked.value ? onUnblockUser() : onBlockUser();
                },
              ),
            ),

            // Delete Chat
            ListTile(
              leading: Icon(Icons.delete, color: AppColor.colorTextRed),
              title: Text('Delete Chat',
                  style: AppFontStyle.styleW500(AppColor.black, 16)),
              onTap: () {
                Get.back();
                onDeleteChat();
              },
            ),

            20.height,
          ],
        ),
      ),
    );
  }

  List<Chat> fakeChatData = [
    Chat(
      id: "1",
      chatTopicId: "201",
      senderUserId: "sender001",
      message: "Hello! How are you?",
      image: "",
      audio: "",
      isRead: true,
      date: "2024-08-01T10:00:00Z",
      messageType: 1,
      createdAt: "2024-08-01T10:00:00Z",
      updatedAt: "2024-08-01T10:00:00Z",
    ),
    Chat(
      id: "2",
      chatTopicId: "201",
      senderUserId: "receiver001",
      message: "I'm good, thanks! What about you?",
      image: "",
      audio: "",
      isRead: false,
      date: "2024-08-01T10:05:00Z",
      messageType: 1,
      createdAt: "2024-08-01T10:05:00Z",
      updatedAt: "2024-08-01T10:05:00Z",
    ),
    Chat(
      id: "3",
      chatTopicId: "202",
      senderUserId: "sender002",
      message: "Let's catch up later.",
      image: "",
      audio: "",
      isRead: true,
      date: "2024-08-01T10:10:00Z",
      messageType: 1,
      createdAt: "2024-08-01T10:10:00Z",
      updatedAt: "2024-08-01T10:10:00Z",
    ),
    Chat(
      id: "4",
      chatTopicId: "202",
      senderUserId: "receiver002",
      message: "Sure, what time works for you?",
      image: "",
      audio: "",
      isRead: false,
      date: "2024-08-01T10:15:00Z",
      messageType: 1,
      createdAt: "2024-08-01T10:15:00Z",
      updatedAt: "2024-08-01T10:15:00Z",
    ),
    Chat(
      id: "5",
      chatTopicId: "203",
      senderUserId: "sender003",
      message: "Are you coming to the meeting?",
      image: "",
      audio: "",
      isRead: true,
      date: "2024-08-01T10:20:00Z",
      messageType: 1,
      createdAt: "2024-08-01T10:20:00Z",
      updatedAt: "2024-08-01T10:20:00Z",
    ),
    Chat(
      id: "6",
      chatTopicId: "203",
      senderUserId: "receiver003",
      message: "Yes, I'll be there.",
      image: "",
      audio: "",
      isRead: false,
      date: "2024-08-01T10:25:00Z",
      messageType: 1,
      createdAt: "2024-08-01T10:25:00Z",
      updatedAt: "2024-08-01T10:25:00Z",
    ),
    Chat(
      id: "7",
      chatTopicId: "204",
      senderUserId: "sender004",
      message: "Can you review this document?",
      image: "",
      audio: "",
      isRead: true,
      date: "2024-08-01T10:30:00Z",
      messageType: 1,
      createdAt: "2024-08-01T10:30:00Z",
      updatedAt: "2024-08-01T10:30:00Z",
    ),
    Chat(
      id: "8",
      chatTopicId: "204",
      senderUserId: "receiver004",
      message: "I'll look at it and get back to you.",
      image: "",
      audio: "",
      isRead: false,
      date: "2024-08-01T10:35:00Z",
      messageType: 1,
      createdAt: "2024-08-01T10:35:00Z",
      updatedAt: "2024-08-01T10:35:00Z",
    ),
    Chat(
      id: "9",
      chatTopicId: "205",
      senderUserId: "sender005",
      message: "Lunch at 12?",
      image: "",
      audio: "",
      isRead: true,
      date: "2024-08-01T10:40:00Z",
      messageType: 1,
      createdAt: "2024-08-01T10:40:00Z",
      updatedAt: "2024-08-01T10:40:00Z",
    ),
    Chat(
      id: "10",
      chatTopicId: "205",
      senderUserId: "receiver005",
      message: "Sounds good. See you then!",
      image: "",
      audio: "",
      isRead: false,
      date: "2024-08-01T10:45:00Z",
      messageType: 1,
      createdAt: "2024-08-01T10:45:00Z",
      updatedAt: "2024-08-01T10:45:00Z",
    ),
    Chat(
      id: "11",
      chatTopicId: "206",
      senderUserId: "sender006",
      message: "Don't forget the deadline tomorrow.",
      image: "",
      audio: "",
      isRead: true,
      date: "2024-08-01T10:50:00Z",
      messageType: 1,
      createdAt: "2024-08-01T10:50:00Z",
      updatedAt: "2024-08-01T10:50:00Z",
    ),
    Chat(
      id: "12",
      chatTopicId: "206",
      senderUserId: "receiver006",
      message: "Thanks for the reminder!",
      image: "",
      audio: "",
      isRead: false,
      date: "2024-08-01T10:55:00Z",
      messageType: 1,
      createdAt: "2024-08-01T10:55:00Z",
      updatedAt: "2024-08-01T10:55:00Z",
    ),
    Chat(
      id: "13",
      chatTopicId: "207",
      senderUserId: "sender007",
      message: "Are we still on for tonight?",
      image: "",
      audio: "",
      isRead: true,
      date: "2024-08-01T11:00:00Z",
      messageType: 1,
      createdAt: "2024-08-01T11:00:00Z",
      updatedAt: "2024-08-01T11:00:00Z",
    ),
    Chat(
      id: "14",
      chatTopicId: "207",
      senderUserId: "receiver007",
      message: "Yes, see you at 7 PM.",
      image: "",
      audio: "",
      isRead: false,
      date: "2024-08-01T11:05:00Z",
      messageType: 1,
      createdAt: "2024-08-01T11:05:00Z",
      updatedAt: "2024-08-01T11:05:00Z",
    ),
    Chat(
      id: "15",
      chatTopicId: "208",
      senderUserId: "sender008",
      message: "Can you send me the report?",
      image: "",
      audio: "",
      isRead: true,
      date: "2024-08-01T11:10:00Z",
      messageType: 1,
      createdAt: "2024-08-01T11:10:00Z",
      updatedAt: "2024-08-01T11:10:00Z",
    ),
    Chat(
      id: "16",
      chatTopicId: "208",
      senderUserId: "receiver008",
      message: "Sure, I'll email it to you.",
      image: "",
      audio: "",
      isRead: false,
      date: "2024-08-01T11:15:00Z",
      messageType: 1,
      createdAt: "2024-08-01T11:15:00Z",
      updatedAt: "2024-08-01T11:15:00Z",
    ),
    Chat(
      id: "17",
      chatTopicId: "209",
      senderUserId: "sender009",
      message: "Please update the document.",
      image: "",
      audio: "",
      isRead: true,
      date: "2024-08-01T11:20:00Z",
      messageType: 1,
      createdAt: "2024-08-01T11:20:00Z",
      updatedAt: "2024-08-01T11:20:00Z",
    ),
    Chat(
      id: "18",
      chatTopicId: "209",
      senderUserId: "receiver009",
      message: "I will do that today.",
      image: "",
      audio: "",
      isRead: false,
      date: "2024-08-01T11:25:00Z",
      messageType: 1,
      createdAt: "2024-08-01T11:25:00Z",
      updatedAt: "2024-08-01T11:25:00Z",
    ),
    Chat(
      id: "19",
      chatTopicId: "210",
      senderUserId: "sender010",
      message: "Did you finish the task?",
      image: "",
      audio: "",
      isRead: true,
      date: "2024-08-01T11:30:00Z",
      messageType: 1,
      createdAt: "2024-08-01T11:30:00Z",
      updatedAt: "2024-08-01T11:30:00Z",
    ),
    Chat(
      id: "20",
      chatTopicId: "210",
      senderUserId: "receiver010",
      message: "Yes, I just completed it.",
      image: "",
      audio: "",
      isRead: false,
      date: "2024-08-01T11:35:00Z",
      messageType: 1,
      createdAt: "2024-08-01T11:35:00Z",
      updatedAt: "2024-08-01T11:35:00Z",
    ),
  ];

  void loadChatStates() {
    isUserBlocked.value = Database.isUserBlocked(receiverUserId);
    isUserReported.value = Database.isUserReported(receiverUserId);
    isChatDeleted.value = Database.isChatDeleted(receiverUserId);

    Utils.showLog(
        "Loaded chat states for $receiverUserId - Blocked: ${isUserBlocked.value}, Reported: ${isUserReported.value}, Deleted: ${isChatDeleted.value}");
  }
}
