import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Wow/pages/edit_reels_page/controller/edit_reels_controller.dart';
import 'package:Wow/pages/edit_reels_page/widget/edit_reels_widget.dart';
import 'package:Wow/ui/app_button_ui.dart';
import 'package:Wow/ui/simple_app_bar_ui.dart';
import 'package:Wow/utils/asset.dart';
import 'package:Wow/utils/color.dart';
import 'package:Wow/utils/enums.dart';
import 'package:Wow/utils/font_style.dart';

class EditReelsView extends StatelessWidget {
  const EditReelsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EditReelsController>();

    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColor.white,
        shadowColor: AppColor.black.withOpacity(0.4),
        surfaceTintColor: AppColor.transparent,
        flexibleSpace: SimpleAppBarUi(title: EnumLocal.txtEditReels.name.tr),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 15),
            Container(
              height: 210,
              width: 160,
              clipBehavior: Clip.antiAlias,
              margin: EdgeInsets.only(left: 15),
              decoration: BoxDecoration(
                color: AppColor.colorBorder.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: SizedBox(
                height: 210,
                width: 160,
                child: GetBuilder<EditReelsController>(
                  id: "onChangeThumbnail",
                  builder: (controller) {
                    if (controller.selectedImage != null) {
                      return Image.file(
                        File(controller.selectedImage ?? ""),
                        fit: BoxFit.cover,
                      );
                    } else {
                      return Image.network(
                        controller.videoThumbnail,
                        fit: BoxFit.cover,
                      );
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 15),
            InkWell(
              onTap: () => controller.onChangeThumbnail(context),
              child: Container(
                height: 55,
                width: Get.width,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                margin: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: AppColor.colorBorder.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColor.colorBorder.withOpacity(0.6)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(AppAsset.icChangeThumbnail, width: 20, color: AppColor.primary),
                    SizedBox(width: 15),
                    Text(
                      EnumLocal.txtChangeThumbnail.name.tr,
                      style: AppFontStyle.styleW700(AppColor.black, 15),
                    ),
                    Spacer(),
                    Image.asset(AppAsset.icArrowRight, width: 20),
                  ],
                ),
              ),
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: RichText(
                text: TextSpan(
                  text: EnumLocal.txtCaption.name.tr,
                  style: AppFontStyle.styleW700(AppColor.black, 15),
                  children: [
                    TextSpan(
                      text: " ${EnumLocal.txtOptionalInBrackets.name.tr}",
                      style: AppFontStyle.styleW400(AppColor.coloGreyText, 10),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 5),
            GestureDetector(
              onTap: () {
                Get.to(
                  EditPreviewReelsCaptionUi(),
                  transition: Transition.downToUp,
                  duration: Duration(milliseconds: 300),
                );
              },
              child: GetBuilder<EditReelsController>(
                id: "onChangeHashtag",
                builder: (controller) => Container(
                  height: 130,
                  width: Get.width,
                  padding: const EdgeInsets.only(left: 15, top: 5),
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: AppColor.colorBorder.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColor.colorBorder.withOpacity(0.8)),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      controller.captionController.text.isEmpty ? EnumLocal.txtEnterYourTextWithHashtag.name.tr : controller.captionController.text,
                      style: controller.captionController.text.isEmpty ? AppFontStyle.styleW400(AppColor.coloGreyText, 15) : AppFontStyle.styleW600(AppColor.black, 15),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppButtonUi(
        title: EnumLocal.txtSubmit.name.tr,
        gradient: AppColor.primaryLinearGradient,
        callback: () {
          FocusManager.instance.primaryFocus?.unfocus();
          controller.onEditUploadReels();
        },
      ).paddingSymmetric(horizontal: Get.width / 6.5, vertical: 25),
    );
  }
}
