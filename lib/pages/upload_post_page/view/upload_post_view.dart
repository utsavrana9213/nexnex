import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Wow/pages/upload_post_page/widget/upload_post_widget.dart';
import 'package:Wow/ui/app_button_ui.dart';
import 'package:Wow/main.dart';
import 'package:Wow/pages/upload_post_page/controller/upload_post_controller.dart';
import 'package:Wow/ui/simple_app_bar_ui.dart';
import 'package:Wow/utils/asset.dart';
import 'package:Wow/utils/color.dart';
import 'package:Wow/utils/enums.dart';
import 'package:Wow/utils/font_style.dart';

class UploadPostView extends GetView<UploadPostController> {
  const UploadPostView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColor.white,
        shadowColor: AppColor.black.withOpacity(0.4),
        surfaceTintColor: AppColor.transparent,
        flexibleSpace: SimpleAppBarUi(title: EnumLocal.txtUploadPost.name.tr),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 170,
            width: Get.width,
            color: AppColor.colorBorder.withOpacity(0.2),
            child: GetBuilder<UploadPostController>(
              id: "onChangeImages",
              builder: (logic) => ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount:
                    logic.selectedImages.length < 5 ? (logic.selectedImages.length + 1) : logic.selectedImages.length,
                padding: EdgeInsets.only(left: 15, top: 15, bottom: 15),
                itemBuilder: (context, index) => Padding(
                  padding: EdgeInsets.only(right: 15),
                  child: (index == (logic.selectedImages.length) && logic.selectedImages.length < 5)
                      ? GestureDetector(
                          onTap: () => controller.onSelectNewImage(context),
                          child: DottedBorder(
                            options: RectDottedBorderOptions(
                              dashPattern: const [3, 6],
                              //   borderType: BorderType.RRect,
                              color: AppColor.colorScaffold,
                              //radius: Radius.circular(radius),
                              padding: const EdgeInsets.all(1.3),
                              strokeWidth: 5,
                            ),
                            child: Container(
                              width: 135,
                              decoration: BoxDecoration(
                                color: AppColor.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(child: Image.asset(AppAsset.icAdd, width: 40)),
                            ),
                          ),
                        )
                      : SizedBox(
                          width: 135,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                height: 140,
                                clipBehavior: Clip.antiAlias,
                                decoration:
                                    BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Image.file(File(controller.selectedImages[index]), fit: BoxFit.cover),
                                ),
                              ),
                              Positioned(
                                top: -8,
                                right: -8,
                                child: GestureDetector(
                                  onTap: () => logic.onCancelImage(index),
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    color: AppColor.transparent,
                                    alignment: Alignment.topRight,
                                    child: Container(
                                      height: 25,
                                      width: 25,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColor.black,
                                        border: Border.all(color: AppColor.colorGreyBg, width: 2),
                                      ),
                                      child: Center(
                                        child: Image.asset(
                                          AppAsset.icClose,
                                          color: AppColor.white,
                                          width: 13,
                                        ),
                                      ),
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
          ),
          20.height,
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
          5.height,
          GestureDetector(
            onTap: () {
              Get.to(
                PreviewPostCaptionUi(),
                transition: Transition.downToUp,
                duration: Duration(milliseconds: 300),
              );
            },
            child: GetBuilder<UploadPostController>(
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
                    controller.captionController.text.isEmpty
                        ? EnumLocal.txtEnterYourTextWithHashtag.name.tr
                        : controller.captionController.text,
                    style: controller.captionController.text.isEmpty
                        ? AppFontStyle.styleW400(AppColor.coloGreyText, 15)
                        : AppFontStyle.styleW600(AppColor.black, 15),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppButtonUi(
        title: EnumLocal.txtUpload.name.tr,
        gradient: AppColor.primaryLinearGradient,
        callback: controller.onUploadPost,
      ).paddingSymmetric(horizontal: Get.width / 6.5, vertical: 25),
    );
  }
}

// >>>>>>>>>>>>>>>>>>>>>>>> Old Hashtag Function <<<<<<<<<<<<<<<<<<<<<<<<<<<<<

// CaptionTextFieldUi(
//   height: 130,
//   title: EnumLocal.txtCaption.name.tr,
//   maxLines: 4,
//   controller: controller.captionController,
//   enabled: false,
//   onClick: () {
//     Get.to(
//       PreviewPostCaptionUi(),
//       transition: Transition.downToUp,
//       duration: Duration(milliseconds: 300),
//     );
//   },
// ),

// UploadTextFiledUi(
//   height: 130,
//   title: EnumLocal.txtCaption.name.tr,
//   maxLines: 4,
//   controller: controller.captionController,
//   onClick: () {
//     Get.to(
//       PreviewCaptionUi(),
//       transition: Transition.downToUp,
//       duration: Duration(milliseconds: 300),
//     );
//   },
//   onChanged: () {
//     Utils.showLog("Enter Text => ${controller.captionController.text}");
//
//     // if (controller.captionController.text.endsWith("#") || controller.captionController.text.endsWith("@")) {
//     //   Utils.showLog("Hash Tag Adding...");
//     // }
//   },
// ),

//   20.height,
//                         UploadTextFiledUi(
//                           title: EnumLocal.txtHashTag.name.tr,
//                           maxLines: 1,
//                           controller: controller.hashTagController,
//                           onChanged: () => controller.onChangeHashTag(),
//                         ),

//--------------------
//  10.height,
//                     GetBuilder<UploadPostController>(
//                       id: "onSelectHastTag",
//                       builder: (logic) => Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 15),
//                         child: Wrap(
//                           spacing: 15,
//                           alignment: WrapAlignment.start,
//                           children: [
//                             for (int index = 0; index < logic.selectedHashTag.length; index++)
//                               Chip(
//                                 padding: const EdgeInsets.only(top: 7, bottom: 7, right: 7),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(50),
//                                 ),
//                                 deleteIconColor: AppColor.black,
//                                 onDeleted: () => logic.onCancelHashTag(index),
//                                 elevation: 0,
//                                 autofocus: false,
//                                 deleteIcon: Padding(
//                                   padding: const EdgeInsets.only(right: 4),
//                                   child: Image.asset(AppAsset.icClose),
//                                 ),
//                                 backgroundColor: AppColor.grey_100,
//                                 side: const BorderSide(width: 0.8, color: AppColor.transparent),
//                                 label: RichText(
//                                   text: TextSpan(
//                                     text: " # ",
//                                     style: AppFontStyle.styleW600(AppColor.primary, 16),
//                                     children: [
//                                       TextSpan(
//                                         text: logic.selectedHashTag[index].hashTag,
//                                         style: AppFontStyle.styleW700(AppColor.black, 13),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     // GetBuilder<UploadPostController>(
//                     //   id: "onToggleHashTag",
//                     //   builder: (controller) => Visibility(
//                     //     visible: controller.isShowHashTag,
//                     //     child: GetBuilder<UploadPostController>(
//                     //       id: "onGetHashTag",
//                     //       builder: (controller) => controller.isLoadingHashTag
//                     //           ? HashTagBottomSheetShimmerUi()
//                     //           : controller.hastTagCollection.isEmpty
//                     //               ? Offstage()
//                     //               : ListView.builder(
//                     //                   shrinkWrap: true,
//                     //                   physics: NeverScrollableScrollPhysics(),
//                     //                   itemCount: controller.hastTagCollection.length,
//                     //                   itemBuilder: (context, index) => GetBuilder<UploadPostController>(
//                     //                     id: "onSelectHastTag",
//                     //                     builder: (controller) => GestureDetector(
//                     //                       onTap: () => controller.onSelectHastTag(index),
//                     //                       child: Container(
//                     //                         height: 70,
//                     //                         width: Get.width,
//                     //                         padding: EdgeInsets.only(left: 20, right: 20),
//                     //                         decoration: BoxDecoration(
//                     //                           border: Border(top: BorderSide(color: AppColor.grey_100)),
//                     //                         ),
//                     //                         child: Row(
//                     //                           children: [
//                     //                             RichText(
//                     //                               text: TextSpan(
//                     //                                 text: "# ",
//                     //                                 style: AppFontStyle.styleW600(AppColor.primary, 20),
//                     //                                 children: [
//                     //                                   TextSpan(
//                     //                                     text: controller.hastTagCollection[index].hashTag,
//                     //                                     style: AppFontStyle.styleW700(AppColor.black, 15),
//                     //                                   ),
//                     //                                 ],
//                     //                               ),
//                     //                             ),
//                     //                             const Spacer(),
//                     //                             Row(
//                     //                               children: [
//                     //                                 Image.asset(
//                     //                                   AppAsset.icViewBorder,
//                     //                                   color: AppColor.colorTextGrey,
//                     //                                   width: 20,
//                     //                                 ),
//                     //                                 5.width,
//                     //                                 Text(
//                     //                                   CustomFormatNumber.convert(controller.hastTagCollection[index].totalHashTagUsedCount ?? 0),
//                     //                                   style: AppFontStyle.styleW700(AppColor.colorTextGrey, 13),
//                     //                                 ),
//                     //                               ],
//                     //                             ),
//                     //                           ],
//                     //                         ),
//                     //                       ),
//                     //                     ),
//                     //                   ),
//                     //                 ),
//                     //     ),
//                     //   ),
//                     // ),

//-------------------------------------------------------------------------------------------------

// Container(
//   height: 20,
//   width: 20,
//   decoration: BoxDecoration(
//     border: Border.all(
//       width: 1.5,
//       color: controller.selectedHashTag
//               .contains(controller.hastTagCollection[index])
//           ? AppColor.primary
//           : AppColor.grey_300,
//     ),
//     borderRadius: BorderRadius.circular(3),
//   ),
//   child: controller.selectedHashTag
//           .contains(controller.hastTagCollection[index])
//       ? const Center(
//           child: Icon(
//             size: 15,
//             Icons.done_rounded,
//             color: AppColor.primary,
//           ),
//         )
//       : const Offstage(),
// ),
// 15.width,
///---------------------
// Container(
//   height: Get.width,
//   width: Get.width,
//   color: Colors.pink,
// ),

// Padding(
//   padding: const EdgeInsets.symmetric(horizontal: 15),
//   child: Text(
//     "Caption",
//     style: AppFontStyle.styleW500(AppColor.coloGreyText, 15),
//   ),
// ),
// Container(
//   padding: const EdgeInsets.symmetric(horizontal: 15),
//   margin: const EdgeInsets.only(bottom: 10, top: 10),
//   color: AppColor.colorBorder.withOpacity(0.2),
//   child: TextFormField(
//     maxLines: 5,
//     style: AppFontStyle.styleW600(AppColor.black, 15),
//     controller: controller.descriptionController,
//     cursorColor: AppColor.primary,
//     keyboardType: TextInputType.multiline,
//     decoration: InputDecoration(
//       hintText: "",
//       hintStyle: AppFontStyle.styleW400(AppColor.coloGreyText, 15),
//       border: InputBorder.none,
//     ),
//   ),
// ),
// Container(
//   padding: const EdgeInsets.symmetric(horizontal: 15),
//   margin: const EdgeInsets.only(bottom: 10, top: 10),
//   color: AppColor.colorBorder.withOpacity(0.2),
//   child: TextFormField(
//     maxLines: 2,
//     style: AppFontStyle.styleW600(AppColor.black, 15),
//     controller: controller.descriptionController,
//     cursorColor: AppColor.primary,
//     keyboardType: TextInputType.multiline,
//     decoration: InputDecoration(
//       hintText: "Enter your hash tag...",
//       hintStyle: AppFontStyle.styleW400(AppColor.coloGreyText, 15),
//       border: InputBorder.none,
//     ),
//   ),
// ),
// ListView.builder(
//   shrinkWrap: true,
//   itemCount: 10,
//   itemBuilder: (context, index) => Container(),
// ),

// InkWell(
//   onTap: postHashTagBottomSheet,
//   child: Container(
//     height: 50,
//     width: Get.width,
//     padding: const EdgeInsets.symmetric(horizontal: 15),
//     decoration: BoxDecoration(
//       color: AppColor.transparent,
//       border: Border.symmetric(
//         horizontal: BorderSide(color: AppColor.colorBorderGrey.withOpacity(0.6)),
//       ),
//     ),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         RichText(
//           text: TextSpan(
//             text: "#  ",
//             style: AppFontStyle.styleW600(AppColor.primary, 18),
//             children: [
//               TextSpan(
//                 text: EnumLocal.txtAddTopic.name.tr,
//                 style: AppFontStyle.styleW700(AppColor.black, 15),
//               ),
//             ],
//           ),
//         ),
//         Image.asset(AppAsset.icArrowRight, width: 20),
//       ],
//     ),
//   ),
// ),

// if ( ==
//    ) {
//   controller.onSelectHastTag(0);
// } else {
//   Utils.showLog("******** ");
// }
// controller.onCreateHashTag();
