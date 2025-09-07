import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Wow/custom/custom_format_number.dart';
import 'package:Wow/main.dart';
import 'package:Wow/pages/edit_reels_page/controller/edit_reels_controller.dart';
import 'package:Wow/shimmer/hash_tag_bottom_sheet_shimmer_ui.dart';
import 'package:Wow/ui/no_data_found_ui.dart';
import 'package:Wow/utils/asset.dart';
import 'package:Wow/utils/color.dart';
import 'package:Wow/utils/enums.dart';
import 'package:Wow/utils/font_style.dart';

class EditPreviewReelsCaptionUi extends StatefulWidget {
  const EditPreviewReelsCaptionUi({super.key});

  @override
  State<EditPreviewReelsCaptionUi> createState() => _EditPreviewReelsCaptionUiState();
}

class _EditPreviewReelsCaptionUiState extends State<EditPreviewReelsCaptionUi> {
  final controller = Get.find<EditReelsController>();
  FocusNode focusNode = FocusNode();

  String caption = "";

  @override
  void initState() {
    focusNode.requestFocus();
    controller.onToggleHashTag(false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColor.white,
        surfaceTintColor: AppColor.transparent,
        flexibleSpace: SafeArea(
          bottom: false,
          child: Container(
            color: AppColor.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  45.width,
                  Spacer(),
                  Text(
                    EnumLocal.txtCaption.name.tr,
                    style: AppFontStyle.styleW700(AppColor.black, 19),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      height: 40,
                      width: 50,
                      decoration: const BoxDecoration(
                        color: AppColor.transparent,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        EnumLocal.txtDone.name.tr,
                        style: AppFontStyle.styleW700(AppColor.primary, 16),
                      ),
                    ),
                  ),
                  5.width,
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          15.height,
          Container(
            height: 130,
            width: Get.width,
            padding: const EdgeInsets.only(left: 15),
            margin: EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: AppColor.colorBorder.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColor.colorBorder.withOpacity(0.8)),
            ),
            child: TextFormField(
              onChanged: (value) => controller.onChangeHashtag(),
              controller: controller.captionController,
              maxLines: 4,
              focusNode: focusNode,
              cursorColor: AppColor.colorTextGrey,
              style: AppFontStyle.styleW600(AppColor.black, 15),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: EnumLocal.txtEnterYourTextWithHashtag.name.tr,
                hintStyle: AppFontStyle.styleW400(AppColor.coloGreyText, 15),
              ),
            ),
          ),
          15.height,
          Expanded(
            child: Obx(
              () => Visibility(
                visible: controller.isShowHashTag.value,
                child: GetBuilder<EditReelsController>(
                  id: "onGetHashTag",
                  builder: (controller) => controller.isLoadingHashTag
                      ? HashTagBottomSheetShimmerUi()
                      : controller.filterHashtag.isEmpty
                          ? Center(child: SingleChildScrollView(child: NoDataFoundUi(iconSize: 160, fontSize: 19)))
                          : SingleChildScrollView(
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: controller.filterHashtag.length,
                                itemBuilder: (context, index) => GetBuilder<EditReelsController>(
                                  id: "onSelectHastTag",
                                  builder: (controller) => GestureDetector(
                                    onTap: () => controller.onSelectHashtag(index),
                                    child: Container(
                                      height: 70,
                                      width: Get.width,
                                      padding: EdgeInsets.only(left: 20, right: 20),
                                      decoration: BoxDecoration(
                                        border: Border(top: BorderSide(color: AppColor.grey_100)),
                                      ),
                                      child: Row(
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              text: "# ",
                                              style: AppFontStyle.styleW600(AppColor.primary, 20),
                                              children: [
                                                TextSpan(
                                                  text: controller.filterHashtag[index].hashTag,
                                                  style: AppFontStyle.styleW700(AppColor.black, 15),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Spacer(),
                                          Row(
                                            children: [
                                              Image.asset(
                                                AppAsset.icViewBorder,
                                                color: AppColor.colorTextGrey,
                                                width: 20,
                                              ),
                                              5.width,
                                              Text(
                                                CustomFormatNumber.convert(controller.filterHashtag[index].totalHashTagUsedCount ?? 0),
                                                style: AppFontStyle.styleW700(AppColor.colorTextGrey, 13),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
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
