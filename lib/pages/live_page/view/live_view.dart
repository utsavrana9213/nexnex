import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:Wow/pages/live_page/controller/live_controller.dart';
import 'package:Wow/pages/live_page/widget/live_widget.dart';
import 'package:Wow/ui/loading_ui.dart';
import 'package:Wow/utils/color.dart';
import 'package:Wow/utils/database.dart';
import 'package:Wow/utils/socket_services.dart';
import 'package:Wow/utils/utils.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

class LiveView extends StatefulWidget {
  const LiveView({super.key});

  @override
  State<LiveView> createState() => _LiveViewState();
}

class _LiveViewState extends State<LiveView> {
  final controller = Get.put(LiveController());

  bool isHost = false;
  String localUserID = Database.loginUserId;
  String localUserName = "Hello Developer";
  String roomID = "1234";

  Widget? localView;
  int? localViewID;
  Widget? remoteView;
  int? remoteViewID;

  @override
  void initState() {
    SocketServices.mainLiveComments.clear();
    print("Get.arguments['roomId''] :: ${Get.arguments}");

    isHost = Get.arguments["isHost"] ?? "";
    roomID = Get.arguments["roomId"] ?? "";

    controller.userId = Get.arguments["userId"] ?? "";
    controller.image = Get.arguments["image"] ?? "";
    controller.roomId = Get.arguments["roomId"] ?? "";
    controller.name = Get.arguments["name"] ?? "";
    controller.userName = Get.arguments["userName"] ?? "";
    controller.isFollow = Get.arguments["isFollow"] ?? false;
    controller.isProfileImageBanned = Get.arguments["isProfileImageBanned"] ?? false;

    Utils.showLog("ROOM Is Live User Following => ${Get.arguments["roomId"]}");

    startListenEvent();
    loginRoom();

    if (isHost) {
      controller.onChangeTime();
    } else {
      Timer(
        Duration(seconds: 5),
        () {
          if (remoteView == null) {
            Get.back();
          }
        },
      );
    }
    // WakelockPlus.enable();
    super.initState();
  }

  @override
  void dispose() {
    if (isHost == false) {
      stopListenEvent();
    }
    logoutRoom();
    SocketServices.onLiveRoomExit(isHost: isHost, liveHistoryId: roomID);
    controller.isLivePage = false;
    // WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: AppColor.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    return Scaffold(
      body: Container(
        height: Get.height,
        width: Get.width,
        color: AppColor.black,
        child: isHost
            ? HostLiveUi(liveScreen: localView ?? const SizedBox.shrink())
            : UserLiveUi(
                liveScreen: remoteView ?? LoadingUi(),
                liveRoomId: roomID,
                liveUserId: controller.userId,
              ),
      ),
    );
  }

  Future<ZegoRoomLoginResult> loginRoom() async {
    final user = ZegoUser(localUserID, localUserName);

    final roomID = this.roomID;

    ZegoRoomConfig roomConfig = ZegoRoomConfig.defaultConfig()..isUserStatusNotify = true;

    return ZegoExpressEngine.instance.loginRoom(roomID, user, config: roomConfig).then((ZegoRoomLoginResult loginRoomResult) {
      debugPrint('loginRoom: errorCode:${loginRoomResult.errorCode}, extendedData:${loginRoomResult.extendedData}');
      if (loginRoomResult.errorCode == 0) {
        if (isHost) {
          startPreview();
          startPublish();
          SocketServices.userWatchCount.value = 0;
          SocketServices.userChats.clear();
          SocketServices.onLiveRoomConnect(loginUserId: Database.loginUserId, liveHistoryId: roomID);
        } else {
          SocketServices.userChats.clear();
          SocketServices.onAddView(loginUserId: Database.loginUserId, liveHistoryId: roomID);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('loginRoom failed: ${loginRoomResult.errorCode}')));
      }
      return loginRoomResult;
    });
  }

  Future<ZegoRoomLogoutResult> logoutRoom() async {
    stopPreview();
    stopPublish();
    return ZegoExpressEngine.instance.logoutRoom(this.roomID);
  }

  void startListenEvent() {
    ZegoExpressEngine.onRoomUserUpdate = (roomID, updateType, List<ZegoUser> userList) {
      debugPrint('onRoomUserUpdate: roomID: $roomID, updateType: ${updateType.name}, userList: ${userList.map((e) => e.userID)}');
    };
    ZegoExpressEngine.onRoomStreamUpdate = (roomID, updateType, List<ZegoStream> streamList, extendedData) {
      debugPrint(
          'onRoomStreamUpdate: roomID: $roomID, updateType: $updateType, streamList: ${streamList.map((e) => e.streamID)}, extendedData: $extendedData');
      if (updateType == ZegoUpdateType.Add) {
        for (final stream in streamList) {
          startPlayStream(stream.streamID);
        }
      } else {
        for (final stream in streamList) {
          stopPlayStream(stream.streamID);
        }
      }
    };
    ZegoExpressEngine.onRoomStateUpdate = (roomID, state, errorCode, extendedData) {
      debugPrint('onRoomStateUpdate: roomID: $roomID, state: ${state.name}, errorCode: $errorCode, extendedData: $extendedData');
    };

    ZegoExpressEngine.onPublisherStateUpdate = (streamID, state, errorCode, extendedData) {
      debugPrint('onPublisherStateUpdate: streamID: $streamID, state: ${state.name}, errorCode: $errorCode, extendedData: $extendedData');
    };
  }

  void stopListenEvent() {
    SocketServices.onLessView(loginUserId: Database.loginUserId, liveHistoryId: roomID);

    ZegoExpressEngine.onRoomUserUpdate = null;
    ZegoExpressEngine.onRoomStreamUpdate = null;
    ZegoExpressEngine.onRoomStateUpdate = null;
    ZegoExpressEngine.onPublisherStateUpdate = null;
  }

  Future<void> startPreview() async {
    // Just start the preview with a known viewID (e.g., 0)
    int viewID = 0;

    ZegoCanvas previewCanvas = ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);
    await ZegoExpressEngine.instance.startPreview(canvas: previewCanvas);

    setState(() {
      localViewID = viewID;
    });
  }


  Future<void> stopPreview() async {
    await ZegoExpressEngine.instance.stopPreview();

    // Instead of manually destroying the canvas view,
    // just remove the widget reference so it disappears from the UI.
    setState(() {
      localViewID = null;
      localView = null;
    });
  }

  Future<void> startPublish() async {
    String streamID = '${roomID}_${localUserID}_call';
    return ZegoExpressEngine.instance.startPublishingStream(streamID);
  }

  Future<void> stopPublish() async {
    return ZegoExpressEngine.instance.stopPublishingStream();
  }

  Future<void> startPlayStream(String streamID) async {
    remoteViewID = UniqueKey().toString() as int?;

    ZegoCanvas canvas = ZegoCanvas(remoteViewID!, viewMode: ZegoViewMode.AspectFill);
    ZegoPlayerConfig config = ZegoPlayerConfig.defaultConfig();

    await ZegoExpressEngine.instance.startPlayingStream(
      streamID,
      canvas: canvas,
      config: config,
    );

    setState(() {
     // remoteView = ZegoCanvasView(viewID: remoteViewID!); // ✅ Widget
    });
  }
  Future<void> stopPlayStream(String streamID) async {
    ZegoExpressEngine.instance.stopPlayingStream(streamID);
    if (remoteViewID != null) {
      ZegoExpressEngine.instance.destroyCanvasView(remoteViewID!);
      setState(() {
        remoteViewID = null;
        remoteView = null;
      });
    }
  }
}
