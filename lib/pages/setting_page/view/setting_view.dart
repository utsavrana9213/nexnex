import 'package:Wow/pages/profile_page/controller/profile_controller.dart';
import 'package:Wow/utils/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Wow/ui/app_button_ui.dart';
import 'package:Wow/ui/delete_user_dialog_ui.dart';
import 'package:Wow/ui/logout_user_dialog_ui.dart';
import 'package:Wow/main.dart';
import 'package:Wow/pages/setting_page/controller/setting_controller.dart';
import 'package:Wow/routes/app_routes.dart';
import 'package:Wow/ui/simple_app_bar_ui.dart';
import 'package:Wow/utils/asset.dart';
import 'package:Wow/utils/color.dart';
import 'package:Wow/utils/database.dart';
import 'package:Wow/utils/enums.dart';
import 'package:Wow/utils/font_style.dart';
import 'package:Wow/pages/setting_page/widget/setting_widget.dart';
import 'package:share_plus/share_plus.dart';

class SettingView extends GetView<SettingController> {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColor.white,
        shadowColor: AppColor.black.withOpacity(0.4),
        surfaceTintColor: AppColor.transparent,
        flexibleSpace: SimpleAppBarUi(title: EnumLocal.txtSettings.name.tr),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          controller.profileImage(),
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            height: Get.height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    15.height,
                    Text(
                      EnumLocal.txtAccount.name.tr,
                      style: AppFontStyle.styleW500(AppColor.colorTextGrey, 16),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        height: 65,
                        width: Get.width,
                        color: AppColor.transparent,
                        child: Row(
                          children: [
                            Image.asset(
                              AppAsset.icNotification,
                              width: 30,
                              color: AppColor.colorLightBlue,
                            ),
                            15.width,
                            Expanded(
                              child: Text(
                                EnumLocal.txtNotifyMe.name.tr,
                                style: AppFontStyle.styleW700(AppColor.colorDarkBlue, 15),
                              ),
                            ),
                            GetBuilder<SettingController>(
                              id: "onSwitchNotification",
                              builder: (controller) => GestureDetector(
                                onTap: () => controller.onSwitchNotification(),
                                child: Container(
                                  height: 65,
                                  width: 70,
                                  color: AppColor.transparent,
                                  alignment: Alignment.centerRight,
                                  child: Transform.scale(
                                    scale: 0.8,
                                    child: CupertinoSwitch(
                                      value: controller.isShowNotification,
                                      activeColor: AppColor.primary,
                                      onChanged: (value) => controller.onSwitchNotification(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // ItemsView(
                    //   icon: AppAsset.icNotification,
                    //   title: EnumLocal.txtNotifyMe.name.tr,
                    //   callback: () {},
                    // ),
                    ItemsView(
                      icon: AppAsset.icLanguage,
                      title: EnumLocal.txtLanguages.name.tr,
                      callback: () {
                        Get.toNamed(AppRoutes.languagePage);
                      },
                    ),
                    ItemsView(
                      icon: AppAsset.icWallet,
                      title: EnumLocal.txtMyWallet.name.tr,
                      callback: () {
                        Get.toNamed(AppRoutes.myWalletPage);
                      },
                    ),
                    GetBuilder<SettingController>(
                      builder: (controller) => ItemsView(
                        icon: AppAsset.icShare,
                        title: EnumLocal.txtShareProfile.name.tr,
                        callback: () {
                          SharePlus.instance.share(
                              ShareParams(text:  "${Api.baseUrl}${profileController.fetchProfileModel?.userProfileData!.user!.userName??""}")
                          );
                          // onClickShare,
                   //       controller.onClickShareProfile();
                        },
                      ),
                    ),
                    ItemsView(
                      icon: AppAsset.icQrCode,
                      title: EnumLocal.txtMyQRCode.name.tr,
                      callback: () {
                        Get.toNamed(AppRoutes.myQrCodePage);
                      },
                    ),
                    Visibility(
                      visible: Database.fetchLoginUserProfileModel?.user?.isVerified == false,
                      child: ItemsView(
                        icon: AppAsset.icVerificationRequest,
                        title: EnumLocal.txtVerificationRequest.name.tr,
                        callback: () {
                          Get.toNamed(AppRoutes.verificationRequestPage);
                        },
                      ),
                    ),
                    10.height,
                    Text(
                      EnumLocal.txtGeneral.name.tr,
                      style: AppFontStyle.styleW500(AppColor.colorTextGrey, 16),
                    ),
                    ItemsView(
                      icon: AppAsset.icHelp,
                      title: EnumLocal.txtHelp.name.tr,
                      callback: () {
                        Get.toNamed(AppRoutes.helpPage);
                      },
                    ),
                    ItemsView(
                      icon: AppAsset.icTerms,
                      title: EnumLocal.txtTermsOfUse.name.tr,
                      callback: () {
                        Get.toNamed(AppRoutes.termsOfUsePage);
                      },
                    ),
                    ItemsView(
                      icon: AppAsset.icPrivacy,
                      title: EnumLocal.txtPrivacyPolicy.name.tr,
                      callback: () {
                        Get.toNamed(AppRoutes.privacyPolicyPage);
                      },
                    ),
                    ItemsView(
                      icon: AppAsset.icLogOut,
                      title: EnumLocal.txtLogOut.name.tr,
                      callback: () => LogoutUserDialogUi.onShow(),
                    ),
                    15.height,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        child: AppButtonUi(
          height: 56,
          color: AppColor.primary,
          icon: AppAsset.icDelete,
          iconColor: AppColor.white,
          title: EnumLocal.txtDeleteAccount.name.tr,
          gradient: AppColor.redGradient,
          fontWeight: FontWeight.w700,
          iconSize: 24,
          fontSize: 15,
          callback: () => DeleteUserDialogUi.onShow(),
        ),
      ),
    );
  }
}
