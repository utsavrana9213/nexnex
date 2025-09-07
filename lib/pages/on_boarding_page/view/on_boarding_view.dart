import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Wow/main.dart';
import 'package:Wow/pages/on_boarding_page/controller/on_boarding_controller.dart';
import 'package:Wow/pages/on_boarding_page/widget/on_boarding_widget.dart';
import 'package:Wow/ui/gradient_text_ui.dart';
import 'package:Wow/utils/asset.dart';
import 'package:Wow/utils/color.dart';
import 'package:Wow/utils/constant.dart';
import 'package:Wow/utils/enums.dart';
import 'package:Wow/utils/font_style.dart';

class OnBoardingView extends GetView<OnBoardingController> {
  const OnBoardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) => controller.onPopScope(),
      child: Scaffold(
        body: Stack(
          children: [
            // Enhanced background with shimmer effect
            AnimatedContainer(
              duration: const Duration(seconds: 3),
              height: Get.height,
              width: Get.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.purple.withOpacity(0.1),
                    Colors.pink.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Image.asset(AppAsset.imgGradiantBg, fit: BoxFit.cover),
            ),

            // Glitter overlay for the entire screen
            GlitterAnimation(
              particleCount: 20,
              child: SizedBox(
                height: Get.height,
                width: Get.width,
              ),
            ),

            SizedBox(
              height: Get.height,
              width: Get.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: GetBuilder<OnBoardingController>(
                      id: "onChangePage",
                      builder: (controller) => PageView.builder(
                        itemCount: controller.pages.length,
                        onPageChanged: (value) => controller.onChangePage(value),
                        itemBuilder: (context, index) => AnimatedSwitcher(
                          duration: const Duration(milliseconds: 800),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.3, 0),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.elasticOut,
                              )),
                              child: child,
                            ),
                          ),
                          child: controller.pages[controller.currentPage],
                        ),
                      ),
                    ),
                  ),

                  // Enhanced bottom container with glittery effects
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInOut,
                    width: Get.width,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColor.primary.withOpacity(0.95),
                          AppColor.primary,
                          AppColor.primary,
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(45),
                        topRight: Radius.circular(45),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.primary.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                          offset: const Offset(0, -10),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Subtle glitter overlay on the bottom container
                        Positioned.fill(
                          child: GlitterAnimation(
                            particleCount: 15,
                            child: Container(),
                          ),
                        ),

                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            32.height,
                            GetBuilder<OnBoardingController>(
                              id: "onChangePage",
                              builder: (controller) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 25),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 600),
                                  transitionBuilder: (child, animation) =>
                                      ScaleTransition(
                                    scale: Tween<double>(begin: 0.8, end: 1.0)
                                        .animate(
                                      CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.elasticOut,
                                      ),
                                    ),
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  ),
                                  child: Container(
                                    key: ValueKey(controller.currentPage),
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.2),
                                          blurRadius: 15,
                                          spreadRadius: 3,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      controller
                                          .pageTitle[controller.currentPage],
                                      style: TextStyle(
                                        color: AppColor.white,
                                        fontFamily: AppConstant.appFontBold,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.2,
                                        fontSize: 32,
                                        shadows: [
                                          Shadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            blurRadius: 5,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            17.height,
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: GetBuilder<OnBoardingController>(
                                id: "onChangePage",
                                builder: (controller) => AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 500),
                                  child: Container(
                                    key: ValueKey(
                                        'subtitle_${controller.currentPage}'),
                                    child: Text(
                                      controller
                                          .pageSubTitle[controller.currentPage],
                                      textAlign: TextAlign.center,
                                      style: AppFontStyle.styleW400(
                                        AppColor.white.withOpacity(0.9),
                                        15,
                                      ).copyWith(
                                        shadows: [
                                          Shadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 3,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            22.height,
                            GetBuilder<OnBoardingController>(
                              id: "onChangePage",
                              builder: (controller) =>
                                  DotIndicatorUi(index: controller.currentPage),
                            ),
                            27.height,

                            // Enhanced next button with glittery effects
                            GestureDetector(
                              onTap: () => controller.onClickNext(),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 100, vertical: 15),
                                margin: const EdgeInsets.only(bottom: 32),
                                decoration: BoxDecoration(
                                  color: AppColor.white,
                                  borderRadius: BorderRadius.circular(50),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColor.black.withOpacity(0.4),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 4),
                                    ),
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.6),
                                      blurRadius: 15,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    // Subtle glitter on the button
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: GlitterAnimation(
                                          particleCount: 8,
                                          child: Container(),
                                        ),
                                      ),
                                    ),

                                    Center(
                                      child: GradientTextUi(
                                        EnumLocal.txtNext.name.tr,
                                        gradient:
                                            AppColor.primaryLinearGradient,
                                        style: AppFontStyle.styleW700(
                                                AppColor.white, 22)
                                            .copyWith(
                                          shadows: [
                                            Shadow(
                                              color:
                                                  Colors.black.withOpacity(0.2),
                                              blurRadius: 2,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
