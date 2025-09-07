import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:Wow/custom/custom_image_picker.dart';
import 'package:Wow/pages/chat_page/model/fetch_user_chat_model.dart';
import 'package:Wow/ui/image_picker_bottom_sheet_ui.dart';
import 'package:Wow/utils/database.dart';
import 'package:Wow/utils/enums.dart';
import 'package:Wow/utils/utils.dart';

class FakeChatController extends GetxController {
  // Get Argument Variables...

  String receiverUserId = "";
  String receiverName = "";
  String receiverUserName = "";
  String receiverImage = "";
  bool receiverIsBlueTik = false;

  // Get Argument Variables...

  ScrollController scrollController = ScrollController();
  TextEditingController messageController = TextEditingController();
  FetchUserChatModel? fetchUserChatModel;
  List<Chat> userChats = [];
  bool isLoading = false;

  AudioRecorder audioRecorder = AudioRecorder();

  bool isRecordingAudio = false;

  RxBool isSendingAudioFile = false.obs;

  String currentPlayAudioId = ""; // This is use to one time only one play audio...

  Timer? timer;

  @override
  void onInit() {
    Utils.showLog("Chat Controller Initialize Success");

    receiverUserId = Get.arguments["id"] ?? "";
    receiverName = Get.arguments["name"] ?? "";
    receiverUserName = Get.arguments["userName"] ?? "";
    receiverImage = Get.arguments["image"] ?? "";
    receiverIsBlueTik = Get.arguments["isBlueTik"] ?? false;

    Utils.showLog("Receiver User Id => ${receiverUserId}");

    init();

    super.onInit();
  }

  Future<void> init() async {
    userChats.clear();
    isLoading = true;
    update(["onGetUserChats"]);

    userChats.addAll(fakeChatData);

    await 1.seconds.delay();

    isLoading = false;
    update(["onGetUserChats"]);
    onScrollDown();
  }

  @override
  void onClose() {
    userChats.clear();
    Utils.showLog("Chat Controller Dispose Success");
    super.onClose();
  }

  // >>>>> >>>>> >>>>> Get User Chat <<<<< <<<<< <<<<<

  Future<void> onClickSend() async {
    if (messageController.text.trim().isNotEmpty) {
      userChats.add(
        Chat(
          id: (Random().nextInt(900000) + 100000).toString(),
          chatTopicId: "0001",
          createdAt: DateTime.now().toString(),
          senderUserId: Database.loginUserId,
          message: messageController.text.trim(),
          image: "",
          audio: "",
          isRead: true,
          date: "2024-08-01T10:10:00Z",
          messageType: 1,
          updatedAt: "2024-08-01T10:10:00Z",
        ),
      );
      update(["onGetUserChats"]);
      messageController.clear();
      onScrollDown();
    }
  }

  Future<void> onClickImage(BuildContext context) async {
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
    userChats.add(
      Chat(
        id: (Random().nextInt(900000) + 100000).toString(),
        chatTopicId: "0001",
        messageType: 2,
        createdAt: DateTime.now().toString(),
        senderUserId: Database.loginUserId,
        message: "",
        image: imagePath,
        audio: "",
        isRead: true,
        date: "2024-08-01T10:10:00Z",
        updatedAt: "2024-08-01T10:10:00Z",
      ),
    ); // Static Show...
    update(["onGetUserChats"]);
    onScrollDown();
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
        userChats.add(
          Chat(
            id: (Random().nextInt(900000) + 100000).toString(),
            chatTopicId: "0001",
            messageType: 3,
            createdAt: DateTime.now().toString(),
            senderUserId: Database.loginUserId,
            message: "",
            image: "",
            audio: audioPath,
            isRead: true,
            date: "2024-08-01T10:10:00Z",
            updatedAt: "2024-08-01T10:10:00Z",
          ),
        ); // Static Show...

        update(["onGetUserChats"]);
        onScrollDown();
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

  Future<void> onScrollDown() async {
    try {
      await 10.milliseconds.delay();
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
      await 10.milliseconds.delay();
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
    } catch (e) {
      Utils.showLog("Scroll Down Failed => $e");
    }
  }

  List<Chat> fakeChatData = [
    Chat(
      id: "1",
      chatTopicId: "201",
      senderUserId: "other_user_001", // This should be different from Database.loginUserId
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
      senderUserId: Database.loginUserId, // This should be the current user
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
      senderUserId: "other_user_002", // This should be different from Database.loginUserId
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
      senderUserId: Database.loginUserId, // This should be the current user
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
      senderUserId: "other_user_003", // This should be different from Database.loginUserId
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
      senderUserId: Database.loginUserId, // This should be the current user
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
      senderUserId: "other_user_004", // This should be different from Database.loginUserId
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
      senderUserId: Database.loginUserId, // This should be the current user
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
      senderUserId: "other_user_005", // This should be different from Database.loginUserId
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
      senderUserId: Database.loginUserId, // This should be the current user
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
      senderUserId: "other_user_006", // This should be different from Database.loginUserId
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
      senderUserId: Database.loginUserId, // This should be the current user
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
      senderUserId: "other_user_007", // This should be different from Database.loginUserId
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
      senderUserId: Database.loginUserId, // This should be the current user
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
      senderUserId: "other_user_008", // This should be different from Database.loginUserId
      message: "Great! Looking forward to it.",
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
      senderUserId: Database.loginUserId, // This should be the current user
      message: "Me too! It's been a while.",
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
      senderUserId: "other_user_009", // This should be different from Database.loginUserId
      message: "Did you finish the project?",
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
      senderUserId: Database.loginUserId, // This should be the current user
      message: "Almost done, just need to review it.",
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
      senderUserId: "other_user_010", // This should be different from Database.loginUserId
      message: "Perfect! Send it when ready.",
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
      senderUserId: Database.loginUserId, // This should be the current user
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
}
