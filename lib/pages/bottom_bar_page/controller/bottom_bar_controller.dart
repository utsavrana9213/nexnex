import 'package:Wow/ui/video_picker_bottom_sheet_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Wow/pages/feed_page/view/feed_view.dart';
import 'package:Wow/pages/message_page/view/message_view.dart';
import 'package:Wow/pages/profile_page/view/profile_view.dart';
import 'package:Wow/pages/reels_page/view/reels_view.dart';
import 'package:Wow/pages/stream_page/view/stream_view.dart';
import 'package:Wow/routes/app_routes.dart';
import 'package:Wow/ui/send_gift_on_video_bottom_sheet_ui.dart';
import 'package:Wow/utils/branch_io_services.dart';
import 'package:Wow/utils/socket_services.dart';
import 'package:Wow/pages/create_reels_page/view/create_reels_view.dart';
import 'package:Wow/pages/upload_reels_page/binding/upload_reels_binding.dart';
import 'package:get/get.dart';
import 'package:Wow/pages/create_reels_page/controller/create_reels_controller.dart';

class BottomBarController extends GetxController {
  int selectedTabIndex = 0;
  PageController pageController = PageController();

  @override
  void onInit() {
    Get.lazyPut<CreateReelsController>(() => CreateReelsController());
    init();
    super.onInit();
  }

  void init() async {
    selectedTabIndex = 0;

    await SocketServices.socketConnect();

    SendGiftOnVideoBottomSheetUi.onGetGift();

    if (BranchIoServices.eventType == "Post") {
      await 500.milliseconds.delay();
      onChangeBottomBar(2);
    } else if (BranchIoServices.eventType == "Profile") {
      await 500.milliseconds.delay();
      onChangeBottomBar(2);
      if (BranchIoServices.eventId != "") {
        Get.toNamed(AppRoutes.previewUserProfilePage, arguments: BranchIoServices.eventId);
      }
    }
  }

  List bottomBarPages = [
    const ReelsView(),
    const StreamView(),
    const MessageView(),
    const ProfileView(),
  //
    const CreateReelsView(),
  ];

   onChangeBottomBar(int index,{BuildContext? context}) {
    if (index != selectedTabIndex) {
      selectedTabIndex = index;

      update(["onChangeBottomBar"]);

    }
  }
}
