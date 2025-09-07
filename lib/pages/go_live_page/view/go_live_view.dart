import 'dart:developer';
import 'package:Wow/main.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:Wow/ui/circle_icon_button_ui.dart';
import 'package:Wow/ui/app_button_ui.dart';
import 'package:Wow/ui/loading_ui.dart';
import 'package:Wow/pages/go_live_page/controller/go_live_controller.dart';
import 'package:Wow/utils/asset.dart';
import 'package:Wow/utils/color.dart';
import 'package:Wow/utils/enums.dart';

class GoLiveView extends StatelessWidget {
  const GoLiveView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GoLiveController());

    Future.delayed(
      const Duration(milliseconds: 300),
          () {
        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
            statusBarColor: AppColor.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        );
      },
    );

    return Scaffold(
      body: Container(
        height: Get.height,
        width: Get.width,
        color: AppColor.black,
        child: Stack(
          children: [
            GetBuilder<GoLiveController>(
              id: "onInitializeCamera",
              builder: (controller) {
                final cameraReady = controller.cameraController != null &&
                    controller.cameraController!.value.isInitialized;

                if (cameraReady) {
                  final mediaSize = MediaQuery.of(context).size;
                  final cameraAspectRatio =
                      controller.cameraController!.value.aspectRatio;
                  final deviceAspectRatio = mediaSize.width / mediaSize.height;
                  final scale = cameraAspectRatio / deviceAspectRatio;

                  log("CameraPreview scale: $scale");

                  return ClipRect(
                    child: Transform.scale(
                      scale: scale,
                      alignment: Alignment.topCenter,
                      child: CameraPreview(controller.cameraController!),
                    ),
                  );
                } else {
                  return const LoadingUi();
                }
              },
            ),
            Positioned(
              bottom: 0,
              child: Container(
                height: 150,
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
              top: 50,
              child: SizedBox(
                width: Get.width,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CircleIconButtonUi(
                        circleSize: 40,
                        iconSize: 20,
                        color: AppColor.white.withOpacity(0.1),
                        icon: AppAsset.icClose,
                        iconColor: AppColor.white,
                        callback: () => Get.back(),
                      ),
                      20.height,
                      GetBuilder<GoLiveController>(
                        id: "onSwitchFlash",
                        builder: (controller) => CircleIconButtonUi(
                          circleSize: 40,
                          iconSize: 20,
                          gradient: AppColor.primaryLinearGradient,
                          icon: controller.isFlashOn
                              ? AppAsset.icFlashOn
                              : AppAsset.icFlashOff,
                          iconColor: AppColor.white,
                          callback: controller.onSwitchFlash,
                        ),
                      ),
                      20.height,
                      GetBuilder<GoLiveController>(
                        builder: (controller) => CircleIconButtonUi(
                          circleSize: 40,
                          iconSize: 20,
                          gradient: AppColor.primaryLinearGradient,
                          icon: AppAsset.icRotateCamera,
                          iconColor: AppColor.white,
                          callback: controller.onSwitchCamera,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 50,
              child: SizedBox(
                width: Get.width,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: Get.width / 5),
                  child: GetBuilder<GoLiveController>(
                    builder: (controller) => AppButtonUi(
                      fontSize: 18,
                      gradient: AppColor.primaryLinearGradient,
                      title: EnumLocal.txtGoLive.name.tr,
                      callback: controller.onClickGoLive,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
