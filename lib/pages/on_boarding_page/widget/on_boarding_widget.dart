import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:Wow/utils/asset.dart';
import 'package:Wow/utils/color.dart';
import 'dart:math' as math;

// Glitter particle class
class GlitterParticle {
  late double x;
  late double y;
  late double size;
  late double opacity;
  late double speed;
  late Color color;
  late double direction;
  late double life;
  late double maxLife;

  GlitterParticle({required double screenWidth, required double screenHeight}) {
    x = math.Random().nextDouble() * screenWidth;
    y = math.Random().nextDouble() * screenHeight;
    size = math.Random().nextDouble() * 4 + 1;
    opacity = math.Random().nextDouble() * 0.8 + 0.2;
    speed = math.Random().nextDouble() * 2 + 0.5;
    direction = math.Random().nextDouble() * 2 * math.pi;
    maxLife = math.Random().nextDouble() * 200 + 100;
    life = maxLife;

    List<Color> colors = [
      Colors.white,
      Colors.pink.shade100,
      Colors.purple.shade100,
      Colors.blue.shade100,
      Colors.yellow.shade100,
    ];
    color = colors[math.Random().nextInt(colors.length)];
  }

  void update() {
    x += math.cos(direction) * speed;
    y += math.sin(direction) * speed;
    life--;
    opacity = (life / maxLife) * 0.8;
  }

  bool get isDead => life <= 0;
}

// Glitter animation widget
class GlitterAnimation extends StatefulWidget {
  final Widget child;
  final int particleCount;
  final bool isActive;

  const GlitterAnimation({
    super.key,
    required this.child,
    this.particleCount = 50,
    this.isActive = true,
  });

  @override
  State<GlitterAnimation> createState() => _GlitterAnimationState();
}

class _GlitterAnimationState extends State<GlitterAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<GlitterParticle> particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 16),
      vsync: this,
    )..addListener(_updateParticles);

    if (widget.isActive) {
      _controller.repeat();
    }
  }

  void _initializeParticles() {
    if (particles.isEmpty && context.mounted) {
      final size = MediaQuery.of(context).size;
      particles = List.generate(
        widget.particleCount,
        (index) => GlitterParticle(
          screenWidth: size.width,
          screenHeight: size.height,
        ),
      );
    }
  }

  void _updateParticles() {
    if (!mounted) return;

    setState(() {
      _initializeParticles();

      // Update existing particles
      particles.forEach((particle) => particle.update());

      // Remove dead particles and add new ones
      particles.removeWhere((particle) => particle.isDead);

      while (particles.length < widget.particleCount) {
        final size = MediaQuery.of(context).size;
        particles.add(GlitterParticle(
          screenWidth: size.width,
          screenHeight: size.height,
        ));
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isActive)
          Positioned.fill(
            child: CustomPaint(
              painter: GlitterPainter(particles: particles),
            ),
          ),
      ],
    );
  }
}

// Custom painter for glitter particles
class GlitterPainter extends CustomPainter {
  final List<GlitterParticle> particles;

  GlitterPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      // Draw sparkle shape
      final path = Path();
      final centerX = particle.x;
      final centerY = particle.y;
      final radius = particle.size;

      // Create a star/sparkle shape
      for (int i = 0; i < 8; i++) {
        final angle = (i * math.pi) / 4;
        final x = centerX + math.cos(angle) * radius;
        final y = centerY + math.sin(angle) * radius;

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }

        // Add inner points for star shape
        if (i % 2 == 0) {
          final innerAngle = angle + math.pi / 4;
          final innerX = centerX + math.cos(innerAngle) * (radius * 0.3);
          final innerY = centerY + math.sin(innerAngle) * (radius * 0.3);
          path.lineTo(innerX, innerY);
        }
      }
      path.close();

      canvas.drawPath(path, paint);

      // Add glow effect
      final glowPaint = Paint()
        ..color = particle.color.withOpacity(particle.opacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size * 1.5,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class OnBoardingScreen_1 extends StatelessWidget {
  const OnBoardingScreen_1({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(
      Duration(milliseconds: 100),
      () {
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: AppColor.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
        );
      },
    );
    return GlitterAnimation(
      particleCount: 30,
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.transparent,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Align(
            alignment: Alignment.center,
            child: AnimatedContainer(
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              child: Hero(
                tag: 'onboarding_1',
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.primary.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    AppAsset.imgOnBoarding_1,
                    width: Get.width,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OnBoardingScreen_2 extends StatelessWidget {
  const OnBoardingScreen_2({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(
      Duration(milliseconds: 100),
      () {
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: AppColor.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
        );
      },
    );
    return GlitterAnimation(
      particleCount: 40,
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Colors.pink.withOpacity(0.1),
              Colors.purple.withOpacity(0.05),
              Colors.transparent,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 15, top: 30),
          child: Align(
            alignment: Alignment.center,
            child: Hero(
              tag: 'onboarding_2',
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withOpacity(0.3),
                      blurRadius: 25,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Image.asset(
                  AppAsset.imgOnBoarding_2,
                  width: Get.width,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OnBoardingScreen_3 extends StatelessWidget {
  const OnBoardingScreen_3({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(
      Duration(milliseconds: 100),
      () {
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: AppColor.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
        );
      },
    );
    return GlitterAnimation(
      particleCount: 35,
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.bottomCenter,
            radius: 1.8,
            colors: [
              Colors.blue.withOpacity(0.1),
              Colors.purple.withOpacity(0.05),
              Colors.transparent,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            bottom: 15,
            top: 30,
          ),
          child: Align(
            alignment: Alignment.center,
            child: Hero(
              tag: 'onboarding_3',
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Image.asset(
                  AppAsset.imgOnBoarding_3,
                  width: 400,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DotIndicatorUi extends StatelessWidget {
  const DotIndicatorUi({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColor.white.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: SizedBox(
        height: 20,
        width: Get.width / 2,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (int i = 0; i < 3; i++)
              AnimatedContainer(
                duration: Duration(milliseconds: 500),
                curve: Curves.elasticOut,
                height: i == index ? 12 : 8,
                width: i == index ? 35 : 10,
                margin: EdgeInsets.only(left: 5),
                child: Container(
                  decoration: BoxDecoration(
                    shape: i == index ? BoxShape.rectangle : BoxShape.circle,
                    color: i == index
                        ? AppColor.white
                        : AppColor.white.withOpacity(0.3),
                    borderRadius: i == index ? BorderRadius.circular(20) : null,
                    boxShadow: i == index
                        ? [
                            BoxShadow(
                              color: AppColor.white.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
