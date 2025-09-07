import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Wow/pages/login_page/controller/login_controller.dart';
import 'package:Wow/routes/app_routes.dart';
import 'package:Wow/utils/asset.dart';
import 'package:Wow/utils/color.dart';
import 'package:Wow/utils/constant.dart';
import 'package:Wow/utils/enums.dart';
import 'package:Wow/utils/font_style.dart';

class LoginView extends GetView<LoginController> {
  LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(
      const Duration(milliseconds: 300),
          () => SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 400,
            child: Image.asset(AppAsset.imgLoginBg,
                height: Get.height, width: Get.width, fit: BoxFit.fill),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              height: 600,
              width: Get.width,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black,
                    Colors.black,
                    Colors.black
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SizedBox(
            height: Get.height,
            width: Get.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(height: 25),
                  SizedBox(
                    width: Get.width / 1.2,
                    child: Text(
                      EnumLocal.txtLoginTitle.name.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 33,
                        color: AppColor.white,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w900,
                        fontFamily: AppConstant.appFontBold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    EnumLocal.txtLoginSubTitle.name.tr,
                    textAlign: TextAlign.center,
                    style: AppFontStyle.styleW400(AppColor.white, 14),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      if (!controller.isAgreedToTerms.value) {
                        Get.defaultDialog(
                          title: 'Terms Required',
                          middleText:
                          'Please agree to Terms of Service to continue',
                          confirmTextColor: AppColor.white,
                        );
                        return;
                      }
                      controller.onQuickLogin();
                    },
                    child: Obx(() => Container(
                      height: 56,
                      width: Get.width,
                      padding: const EdgeInsets.only(left: 6, right: 52),
                      decoration: BoxDecoration(
                        gradient: controller.isAgreedToTerms.value
                            ? AppColor.primaryLinearGradient
                            : LinearGradient(
                          colors: [
                            AppColor.primary.withOpacity(0.5),
                            AppColor.primary.withOpacity(0.3),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 46,
                            width: 46,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                                child: Image.asset(AppAsset.icQuickLogo,
                                    width: 24)),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                EnumLocal.txtQuickLogIn.name.tr,
                                style: AppFontStyle.styleW600(
                                    controller.isAgreedToTerms.value
                                        ? AppColor.white
                                        : AppColor.white.withOpacity(0.7),
                                    16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppColor.white.withOpacity(0.15))),
                      const SizedBox(width: 15),
                      Text(
                        EnumLocal.txtOr.name.tr,
                        style: AppFontStyle.styleW600(AppColor.white, 12),
                      ),
                      const SizedBox(width: 15),
                      Expanded(child: Divider(color: AppColor.white.withOpacity(0.15))),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Platform.isIOS
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (!controller.isAgreedToTerms.value) {
                            Get.defaultDialog(
                              title: 'Terms Required',
                              middleText:
                              'Please agree to Terms of Service to continue',
                              confirmTextColor: AppColor.white,
                            );
                            return;
                          }
                          controller.onGoogleLogin();
                        },
                        child: Obx(() => Container(
                          height: 52,
                          width: 52,
                          decoration: BoxDecoration(
                            color: controller.isAgreedToTerms.value
                                ? AppColor.white
                                : AppColor.white.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                              child: Image.asset(
                                  AppAsset.icGoogleLogo,
                                  width: 32)),
                        )),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (!controller.isAgreedToTerms.value) {
                            Get.defaultDialog(
                              title: 'Terms Required',
                              middleText:
                              'Please agree to Terms of Service to continue',
                              confirmTextColor: AppColor.white,
                            );
                            return;
                          }
                          controller.loginWithApple();
                        },
                        child: Obx(() => Container(
                          height: 52,
                          width: 52,
                          decoration: BoxDecoration(
                            color: controller.isAgreedToTerms.value
                                ? AppColor.white
                                : AppColor.white.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                              child: Image.asset(AppAsset.icAppleLogo,
                                  width: 28)),
                        )),
                      ),
                      /* GestureDetector(
                              onTap: () {
                                if (!controller.isAgreedToTerms.value) {
                                  Get.defaultDialog(
                                    title: 'Terms Required',
                                    middleText:
                                        'Please agree to Terms of Service to continue',
                                    confirmTextColor: AppColor.white,
                                  );
                                  return;
                                }
                                Get.toNamed(AppRoutes.mobileNumLoginPage);
                              },
                              child: Obx(() => Container(
                                    height: 52,
                                    width: 52,
                                    decoration: BoxDecoration(
                                      color: controller.isAgreedToTerms.value
                                          ? AppColor.white
                                          : AppColor.white.withOpacity(0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                        child: Image.asset(AppAsset.icMobile,
                                            width: 32)),
                                  )),
                            ),*/
                    ],
                  )
                      : Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (!controller.isAgreedToTerms.value) {
                              Get.defaultDialog(
                                title: 'Terms Required',
                                middleText:
                                'Please agree to Terms of Service to continue',
                                confirmTextColor: AppColor.white,
                              );
                              return;
                            }
                            controller.onGoogleLogin();
                          },
                          child: Obx(() => Container(
                            height: 56,
                            padding: const EdgeInsets.only(
                                left: 6, right: 52),
                            decoration: BoxDecoration(
                              color: controller.isAgreedToTerms.value
                                  ? AppColor.colorDarkPink
                                  : AppColor.colorDarkPink
                                  .withOpacity(0.5),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: 46,
                                  width: 46,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                      child: Image.asset(
                                          AppAsset.icGoogleLogo,
                                          width: 32)),
                                ),
                                const Spacer(),
                                Text(
                                  EnumLocal.txtGoogle.name.tr,
                                  style: AppFontStyle.styleW600(
                                      controller.isAgreedToTerms.value
                                          ? AppColor.white
                                          : AppColor.white
                                          .withOpacity(0.7),
                                      16),
                                ),
                                const Spacer(),
                              ],
                            ),
                          )),
                        ),
                      ),
                      /*  const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  if (!controller.isAgreedToTerms.value) {
                                    Get.defaultDialog(
                                      title: 'Terms Required',
                                      middleText:
                                          'Please agree to Terms of Service to continue',
                                      confirmTextColor: AppColor.white,
                                    );
                                    return;
                                  }
                                  Get.toNamed(AppRoutes.mobileNumLoginPage);
                                },
                                child: Obx(() => Container(
                                      height: 56,
                                      padding: const EdgeInsets.only(
                                          left: 6, right: 52),
                                      decoration: BoxDecoration(
                                        color: controller.isAgreedToTerms.value
                                            ? AppColor.colorBlue
                                            : AppColor.colorBlue
                                                .withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 46,
                                            width: 46,
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                                child: Image.asset(
                                                    AppAsset.icMobile,
                                                    width: 32)),
                                          ),
                                          const Spacer(),
                                          Text(
                                            EnumLocal.txtMobile.name.tr,
                                            style: AppFontStyle.styleW600(
                                                controller.isAgreedToTerms.value
                                                    ? AppColor.white
                                                    : AppColor.white
                                                        .withOpacity(0.7),
                                                16),
                                          ),
                                        ],
                                      ),
                                    )),
                              ),
                            ),*/
                    ],
                  ),
                  const SizedBox(height: 10),
                  Obx(
                        () => Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Transform.scale(
                          scale: 0.8,
                          child: Checkbox(
                            value: controller.isAgreedToTerms.value,
                            onChanged: (value) {
                              controller.isAgreedToTerms.value = value ?? false;
                            },
                            fillColor: MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                                if (states.contains(MaterialState.selected)) {
                                  return AppColor.colorDarkPink;
                                }
                                return Colors.transparent;
                              },
                            ),
                            checkColor: AppColor.white,
                            side: BorderSide(color: AppColor.white, width: 1.5),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 18.0),
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(fontSize: 12),
                                children: [
                                  TextSpan(
                                    text: 'By logging in, you agree to our ',
                                    style: TextStyle(color: AppColor.white),
                                  ),
                                  TextSpan(
                                    text: 'Terms of Service',
                                    style: TextStyle(
                                      color: AppColor.colorDarkPink,
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        const url = 'https://nexnex.site/privacy';
                                        if (await canLaunchUrl(
                                            Uri.parse(url))) {
                                          await launchUrl(Uri.parse(url));
                                        }
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
