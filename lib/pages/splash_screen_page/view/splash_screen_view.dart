import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:Wow/pages/splash_screen_page/controller/splash_screen_controller.dart';
import 'package:Wow/utils/asset.dart';
import 'package:Wow/utils/color.dart';

class SplashScreenView extends GetView<SplashScreenController> {
  const SplashScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: AppColor.transparent,
      ),
    );
    return Scaffold(
      backgroundColor: AppColor.primary,
      body: const SplashAnimationWidget(),
    );
  }
}

class SplashAnimationWidget extends StatefulWidget {
  const SplashAnimationWidget({super.key});

  @override
  State<SplashAnimationWidget> createState() => _SplashAnimationWidgetState();
}

class _SplashAnimationWidgetState extends State<SplashAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _logoDropController;
  late AnimationController _textRiseController;
  late AnimationController _loadingController;

  late Animation<double> _logoDropAnimation;
  late Animation<double> _textRiseAnimation;
  late Animation<double> _loadingOpacityAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _logoDropController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _textRiseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Setup animations
    _logoDropAnimation = Tween<double>(
      begin: -200.0, // Start above screen
      end: 0.0, // End at center
    ).animate(CurvedAnimation(
      parent: _logoDropController,
      curve: Curves.bounceOut,
    ));

    _textRiseAnimation = Tween<double>(
      begin: 200.0, // Start below screen
      end: 0.0, // End at center
    ).animate(CurvedAnimation(
      parent: _textRiseController,
      curve: Curves.easeOutBack,
    ));

    _loadingOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeIn,
    ));

    // Start animations sequence
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Start logo drop animation
    await Future.delayed(const Duration(milliseconds: 300));
    _logoDropController.forward();

    // Start text rise animation with slight delay
    await Future.delayed(const Duration(milliseconds: 600));
    _textRiseController.forward();

    // Start loading animation after logos are in place
    await Future.delayed(const Duration(milliseconds: 400));
    _loadingController.forward();
  }

  @override
  void dispose() {
    _logoDropController.dispose();
    _textRiseController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Main logo (drops from top)
        AnimatedBuilder(
          animation: _logoDropAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _logoDropAnimation.value),
              child: Image.asset(
                AppAsset.logo,
                height: Get.height * 0.25, // 25% of screen height
                width: Get.width * 0.6, // 60% of screen width
                fit: BoxFit.contain,
              ),
            );
          },
        ),

        AnimatedBuilder(
          animation: _textRiseAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _textRiseAnimation.value),
              child: Image.asset(
                AppAsset.icAppLogo,
                height: Get.height * 0.15, // 15% of screen height
                width: Get.width * 0.7, // 70% of screen width
                fit: BoxFit.contain,
              ),
            );
          },
        ),

        const SizedBox(height: 40),

        // Loading spinner (appears after logos)
        AnimatedBuilder(
          animation: _loadingOpacityAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _loadingOpacityAnimation.value,
              child: SpinKitCircle(
                color: Colors.yellow,
                size: 50,
              ),
            );
          },
        ),
      ],
    );
  }
}

