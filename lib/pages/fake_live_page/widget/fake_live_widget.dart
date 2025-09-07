import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:lottie/lottie.dart';
import 'package:Wow/custom/custom_format_number.dart';
import 'package:Wow/custom/custom_share.dart';
import 'package:Wow/main.dart';
import 'package:Wow/pages/fake_live_page/widget/fake_comment_data.dart';
import 'package:Wow/ui/circle_icon_button_ui.dart';
import 'package:Wow/ui/loading_ui.dart';
import 'package:Wow/ui/preview_network_image_ui.dart';
import 'package:Wow/ui/send_gift_on_live_bottom_sheet_ui.dart';
import 'package:Wow/ui/stop_live_streaming_dialog_ui.dart';
import 'package:Wow/utils/asset.dart';
import 'package:Wow/utils/branch_io_services.dart';
import 'package:Wow/utils/color.dart';
import 'package:Wow/utils/enums.dart';
import 'package:Wow/utils/font_style.dart';
import 'package:Wow/utils/socket_services.dart';

import '../controller/fake_live_controller.dart';

class HostLiveUi extends StatelessWidget {
  const HostLiveUi({super.key, required this.liveScreen});

  final Widget liveScreen;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        StopLiveStreamingDialogUi.onShow();
        return false;
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          liveScreen,
          Align(
            alignment: Alignment.center,
            child: SendGiftOnLiveBottomSheetUi.onShowGift(),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              height: 400,
              width: Get.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColor.transparent, AppColor.black.withOpacity(0.7)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned(
            top: 45,
            child: SizedBox(
              width: Get.width,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 30,
                          width: 76,
                          decoration: BoxDecoration(
                            color: AppColor.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(AppAsset.icView, width: 20),
                              8.width,
                              Obx(
                                () => Text(
                                  CustomFormatNumber.convert(SocketServices.userWatchCount.value),
                                  maxLines: 1,
                                  style: AppFontStyle.styleW700(AppColor.white, 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GetBuilder<FakeLiveController>(
                          id: "onChangeTime",
                          builder: (controller) => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                AppAsset.icClock,
                                width: 22,
                                color: AppColor.white,
                              ),
                              8.width,
                              Padding(
                                padding: const EdgeInsets.only(top: 2, right: 35),
                                child: Text(
                                  controller.onConvertSecondToHMS(controller.countTime),
                                  style: AppFontStyle.styleW600(AppColor.white, 15),
                                ),
                              ),
                            ],
                          ),
                        ),
                        CircleIconButtonUi(
                          color: AppColor.black.withOpacity(0.5),
                          icon: AppAsset.icClose,
                          iconColor: AppColor.white,
                          callback: () => StopLiveStreamingDialogUi.onShow(),
                        ),
                      ],
                    ),
                    20.height,
                    GetBuilder<FakeLiveController>(
                      id: "onSwitchMic",
                      builder: (controller) => CircleIconButtonUi(
                        circleSize: 40,
                        iconSize: 20,
                        gradient: AppColor.primaryLinearGradient,
                        icon: controller.isMicOn ? AppAsset.icMicOn : AppAsset.icMicOff,
                        iconColor: AppColor.white,
                        callback: controller.onSwitchMic,
                      ),
                    ),
                    20.height,
                    GetBuilder<FakeLiveController>(
                      builder: (controller) => CircleIconButtonUi(
                        circleSize: 40,
                        iconSize: 20,
                        gradient: AppColor.primaryLinearGradient,
                        icon: AppAsset.icRotateCamera,
                        iconColor: AppColor.white,
                        callback: controller.onSwitchCamera,
                      ),
                    ),
                    GetBuilder<FakeLiveController>(builder: (fakeLiveController) {
                      return CircleIconButtonUi(
                        circleSize: 38,
                        color: AppColor.black.withOpacity(0.45),
                        icon: AppAsset.icShare,
                        callback: () async {
                          Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...

                          await BranchIoServices.onCreateFakeLiveBranchIoLink(
                            roomId: fakeLiveController.roomId ?? "",
                            pageRoutes: "FakeLive",
                            name: fakeLiveController.name ?? "",
                            image: fakeLiveController.image ?? "",
                            userId: fakeLiveController.userId ?? "",
                            userName: fakeLiveController.userName,
                            isFollow: true,
                            isHost: false,
                            views: fakeLiveController.views,
                            videoUrl: fakeLiveController.videoUrl,
                          );

                          final link = await BranchIoServices.onGenerateLink();

                          Get.back(); // Stop Loading...

                          if (link != null) {
                            CustomShare.onShareLink(link: link);
                          }
                          // await ReelsShareApi.callApi(loginUserId: Database.loginUserId, videoId: controller.mainReels[widget.index].id!);
                        },
                        iconSize: 22,
                        iconColor: AppColor.white,
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 15,
            child: SizedBox(
              width: Get.width,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: GetBuilder<FakeLiveController>(
                  builder: (controller) => CommentTextFieldUi(
                    controller: controller.commentController,
                    callback: () => controller.onSendComment(),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 70,
            child: Container(
              height: 250,
              width: Get.width / 1.8,
              color: AppColor.transparent,
              child: Obx(
                () => SingleChildScrollView(
                  controller: SocketServices.scrollController,
                  child: ListView.builder(
                    itemCount: SocketServices.mainLiveComments.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      final data = SocketServices.mainLiveComments[index];
                      return CommentItemUi(
                        title: data["userName"],
                        subTitle: data["commentText"],
                        leading: data["userImage"],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UserLiveUi extends StatelessWidget {
  UserLiveUi({super.key, required this.liveScreen, required this.liveRoomId, required this.liveUserId});

  final Widget liveScreen;
  final String liveRoomId;
  final String liveUserId;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GetBuilder<FakeLiveController>(
            id: "initializeVideoPlayer",
            builder: (controller) {
              return Container(
                color: AppColor.black,
                width: Get.width,
                height: Get.height,
                child: SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: controller.videoPlayerController?.value.size.width ?? 0,
                      height: controller.videoPlayerController?.value.size.height ?? 0,
                      child: controller.chewieController != null ? Chewie(controller: controller.chewieController!) : CircularProgressIndicator(),
                    ),
                  ),
                ),
              );
            }),
        Align(
          alignment: Alignment.center,
          child: SendGiftOnLiveBottomSheetUi.onShowGift(),
        ),
        Positioned(
          top: 40,
          child: SizedBox(
            width: Get.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GetBuilder<FakeLiveController>(
                      builder: (controller) => GestureDetector(
                            child: Container(
                              height: 50,
                              width: 178,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(56),
                                border: Border.all(color: AppColor.colorBorder.withOpacity(0.3)),
                                color: AppColor.black.withOpacity(0.45),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    height: 40,
                                    width: 40,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: const BoxDecoration(shape: BoxShape.circle),
                                    child: Stack(
                                      children: [
                                        AspectRatio(
                                          aspectRatio: 1,
                                          child: Image.asset(AppAsset.icProfilePlaceHolder),
                                        ),
                                        AspectRatio(
                                          aspectRatio: 1,
                                          child: PreviewNetworkImageUi(image: controller.image),
                                        ),
                                      ],
                                    ),
                                  ),
                                  2.width,
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 75,
                                        child: Text(
                                          controller.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppFontStyle.styleW600(AppColor.white, 14),
                                        ),
                                      ),
                                      Stack(
                                        // mainAxisAlignment: MainAxisAlignment.start,
                                        // crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Positioned(
                                            left: -10,
                                            child: Lottie.asset(AppAsset.lottieWaveAnimation, fit: BoxFit.cover, height: 20, width: 15),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 18, top: 2.5),
                                            child: SizedBox(
                                              width: 60,
                                              child: Text(
                                                controller.userName,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: AppFontStyle.styleW500(AppColor.white, 9),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  GetBuilder<FakeLiveController>(
                                    id: "onClickFollow",
                                    builder: (controller) => GestureDetector(
                                      onTap: controller.onClickFollow,
                                      child: Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: AppColor.primaryLinearGradient,
                                        ),
                                        child: Center(
                                          child: Image.asset(
                                            controller.isFollow ? AppAsset.icFollowing : AppAsset.icFollow,
                                            height: 22,
                                            width: 22,
                                            color: AppColor.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                  4.width,
                  GetBuilder<FakeLiveController>(
                    builder: (controller) {
                      return Container(
                        height: 42,
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(56),
                          border: Border.all(color: AppColor.colorBorder.withOpacity(0.3)),
                          color: AppColor.black.withOpacity(0.45),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              AppAsset.icView,
                              height: 22,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Text(
                                CustomFormatNumber.convert(controller.views),
                                style: AppFontStyle.styleW700(AppColor.white, 14.0),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  GetBuilder<FakeLiveController>(builder: (fakeLiveController) {
                    return CircleIconButtonUi(
                      circleSize: 38,
                      color: AppColor.black.withOpacity(0.45),
                      icon: AppAsset.icShare,
                      callback: () async {
                        Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...

                        await BranchIoServices.onCreateFakeLiveBranchIoLink(
                          roomId: liveRoomId ?? "",
                          pageRoutes: "FakeLive",
                          name: fakeLiveController.name ?? "",
                          image: fakeLiveController.image ?? "",
                          userId: liveUserId ?? "",
                          userName: fakeLiveController.userName,
                          isFollow: true,
                          isHost: false,
                          views: fakeLiveController.views,
                          videoUrl: fakeLiveController.videoUrl,
                        );

                        final link = await BranchIoServices.onGenerateLink();

                        Get.back(); // Stop Loading...

                        if (link != null) {
                          CustomShare.onShareLink(link: link);
                        }
                        // await ReelsShareApi.callApi(loginUserId: Database.loginUserId, videoId: controller.mainReels[widget.index].id!);
                      },
                      iconSize: 22,
                      iconColor: AppColor.white,
                    );
                  }),
                  CircleIconButtonUi(
                    circleSize: 38,
                    color: AppColor.black.withOpacity(0.45),
                    iconSize: 20,
                    icon: AppAsset.icClose,
                    iconColor: AppColor.white,
                    callback: () {
                      Get.back();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            height: 400,
            width: Get.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColor.transparent, AppColor.black.withOpacity(0.7)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 15,
          child: SizedBox(
            width: Get.width,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Expanded(
                    child: GetBuilder<FakeLiveController>(
                      builder: (controller) => CommentTextFieldUi(
                        controller: controller.commentController,
                        callback: () => controller.onSendComment(),
                      ),
                    ),
                  ),
                  15.width,
                  CircleIconButtonUi(
                    circleSize: 50,
                    iconSize: 48,
                    color: AppColor.black.withOpacity(0.3),
                    icon: AppAsset.icGift,
                    callback: () {
                      SendGiftOnLiveBottomSheetUi.show(context: context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          bottom: 70,
          child: GetBuilder<FakeLiveController>(
            builder: (controller) {
              return Container(
                height: 250,
                width: Get.width / 1.8,
                color: AppColor.transparent,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SingleChildScrollView(
                    controller: controller.scrollController,
                    child: ListView.builder(
                      itemCount: fakeHostCommentListBlank.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        return CommentItemUi(
                          title: fakeHostCommentListBlank[index].user,
                          subTitle: fakeHostCommentListBlank[index].message,
                          leading: fakeHostCommentListBlank[index].image,
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class CommentTextFieldUi extends StatelessWidget {
  const CommentTextFieldUi({
    super.key,
    this.callback,
    this.controller,
  });

  final Callback? callback;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.only(left: 15, right: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            height: 22,
            width: 22,
            AppAsset.icCommentGradiant,
          ),
          5.width,
          VerticalDivider(
            indent: 12,
            endIndent: 12,
            color: AppColor.coloGreyText.withOpacity(0.3),
          ),
          5.width,
          Expanded(
            child: TextFormField(
              controller: controller,
              cursorColor: AppColor.colorTextGrey,
              maxLines: 1,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(bottom: 3),
                hintText: EnumLocal.txtTypeComment.name.tr,
                hintStyle: AppFontStyle.styleW400(AppColor.coloGreyText, 15),
              ),
            ),
          ),
          GestureDetector(
            onTap: callback,
            child: Container(
              height: 40,
              width: 40,
              color: AppColor.transparent,
              child: Center(
                child: Image.asset(width: 26, AppAsset.icSend),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CommentItemUi extends StatelessWidget {
  const CommentItemUi({
    super.key,
    required this.title,
    required this.subTitle,
    required this.leading,
  });

  final String title;
  final String subTitle;
  final String leading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width / 2,
      padding: EdgeInsets.symmetric(horizontal: 15),
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(color: AppColor.transparent),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 38,
                width: 38,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColor.colorBorder.withOpacity(0.8)),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: Image.asset(AppAsset.icProfilePlaceHolder),
                    ),
                    AspectRatio(aspectRatio: 1, child: CachedNetworkImage(imageUrl: leading, fit: BoxFit.cover)),
                  ],
                ),
              ),
            ],
          ),
          10.width,
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  style: AppFontStyle.styleW600(AppColor.white, 11.5),
                ),
                2.height,
                Text(
                  subTitle,
                  style: AppFontStyle.styleW600(AppColor.white, 13.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
