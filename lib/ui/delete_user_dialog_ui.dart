import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Wow/main.dart';
import 'package:Wow/pages/setting_page/controller/setting_controller.dart';
import 'package:Wow/utils/asset.dart';
import 'package:Wow/utils/color.dart';
import 'package:Wow/utils/enums.dart';
import 'package:Wow/utils/font_style.dart';

class DeleteUserDialogUi {
  static Future<void> onShow() async {
    final settingController = Get.find<SettingController>();
    Get.dialog(
      barrierColor: AppColor.black.withOpacity(0.9),
      Dialog(
        backgroundColor: AppColor.transparent,
        elevation: 0,
        child: Container(
          height: 400,
          width: 310,
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(45),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  10.height,
                  Image.asset(AppAsset.icDelete, width: 90),
                  10.height,
                  Text(
                    EnumLocal.txtDeleteAccount.name.tr,
                    style: AppFontStyle.styleW700(AppColor.black, 24),
                  ),
                  10.height,
                  Text(
                    textAlign: TextAlign.center,
                    EnumLocal.txtDeleteAccountText.name.tr,
                    style: AppFontStyle.styleW400(AppColor.colorTextGrey, 11.5),
                  ),
                  20.height,
                  GestureDetector(
                    onTap: settingController.onDeleteAccount,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: AppColor.colorLightRedBg,
                      ),
                      height: 52,
                      width: Get.width,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(EnumLocal.txtDelete.name.tr, style: AppFontStyle.styleW700(AppColor.colorTextRed, 16)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  10.height,
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: AppColor.colorGreyBg,
                      ),
                      height: 52,
                      width: Get.width,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(EnumLocal.txtCancel.name.tr, style: AppFontStyle.styleW700(AppColor.coloGreyText, 16)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
