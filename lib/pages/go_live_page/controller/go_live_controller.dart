import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:Wow/ui/loading_ui.dart';
import 'package:Wow/pages/go_live_page/api/create_live_user_api.dart';
import 'package:Wow/pages/go_live_page/model/create_live_user_model.dart';
import 'package:Wow/routes/app_routes.dart';
import 'package:Wow/utils/database.dart';
import 'package:Wow/utils/enums.dart';
import 'package:Wow/utils/utils.dart';

class GoLiveController extends GetxController {
  CameraController? cameraController;
  CameraLensDirection cameraLensDirection = CameraLensDirection.front;
  bool isFlashOn = false;

  @override
  void onInit() {
    super.onInit();
    onRequestPermissions();
  }

  @override
  void onClose() {
    onDisposeCamera();
    super.onClose();
  }

  Future<void> onRequestPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    if (cameraStatus.isGranted && micStatus.isGranted) {
      await onInitializeCamera();
    } else {
      Utils.showToast(EnumLocal.txtPleaseAllowPermission.name.tr);
      Get.back();
    }
  }

  Future<void> onInitializeCamera() async {
    try {
      final cameras = await availableCameras();
      final selectedCamera = cameras.firstWhere(
            (cam) => cam.lensDirection == cameraLensDirection,
        orElse: () => cameras.first,
      );

      cameraController = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: true,
      );

      await cameraController!.initialize();
      isFlashOn = false;
      await cameraController!.setFlashMode(FlashMode.off);

      update(["onInitializeCamera", "onSwitchFlash"]);
    } catch (e) {
      Utils.showLog("Error initializing camera: $e");
    }
  }

  Future<void> onDisposeCamera() async {
    try {
      await cameraController?.dispose();
      cameraController = null;
      Utils.showLog("Camera controller disposed.");
    } catch (e) {
      Utils.showLog("Error disposing camera: $e");
    }
  }

  Future<void> onSwitchFlash() async {
    if (cameraController == null || !(cameraController!.value.isInitialized)) return;

    if (cameraLensDirection == CameraLensDirection.back) {
      isFlashOn = !isFlashOn;
      await cameraController!.setFlashMode(
        isFlashOn ? FlashMode.torch : FlashMode.off,
      );
      update(["onSwitchFlash"]);
    } else {
      Utils.showToast("Flash is not available on front camera.");
    }
  }

  Future<void> onSwitchCamera() async {
    if (cameraController == null) return;

    Get.dialog(
      barrierDismissible: false,
      PopScope(canPop: false, child: const LoadingUi()),
    );

    if (isFlashOn) {
      await onSwitchFlash();
    }

    cameraLensDirection = cameraLensDirection == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;

    await onDisposeCamera();
    await onInitializeCamera();

    Get.back();
  }

  Future<void> onClickGoLive() async {
    Get.dialog(
      barrierDismissible: false,
      PopScope(canPop: false, child: const LoadingUi()),
    );

    try {
      final createLiveUserModel = await CreateLiveUserApi.callApi(
        loginUserId: Database.loginUserId,
      );

      Get.back();

      if (createLiveUserModel?.data?.liveHistoryId != null) {
        Get.offAndToNamed(AppRoutes.livePage, arguments: {
          "roomId": createLiveUserModel?.data?.liveHistoryId,
          "isHost": true,
          "userId": Database.loginUserId,
          "image": Database.fetchLoginUserProfileModel?.user?.image ?? "",
          "name": Database.fetchLoginUserProfileModel?.user?.name ?? "",
          "userName": Database.fetchLoginUserProfileModel?.user?.userName ?? "",
          "isFollow": false,
        });
      } else {
        Utils.showToast("Unable to go live. Please try again.");
      }
    } catch (e) {
      Get.back();
      Utils.showToast("Go live failed: ${e.toString()}");
    }
  }
}
