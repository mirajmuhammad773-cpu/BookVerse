// lib/Screens/BookVerseSplashScreen.dart

import 'dart:math';

import 'package:BookVerse/Auths/SigninScreen.dart';
import 'package:BookVerse/Views/BooknaScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BookVerseSplashScreen extends StatefulWidget {
  const BookVerseSplashScreen({super.key});

  @override
  State<BookVerseSplashScreen> createState() =>
      _BookVerseSplashScreenState();
}

class _Star {
  final double x = Random().nextDouble();
  final double y = Random().nextDouble() * 0.5;
  final double size = 1.2 + Random().nextDouble() * 2.2;
  final double phase = Random().nextDouble();

  final Color color = [
    const Color(0xFF6EA8FF),
    const Color(0xFFB37CFF),
    const Color(0xFFFF7CD6),
  ][Random().nextInt(3)];
}

class _BookVerseSplashScreenState extends State<BookVerseSplashScreen>
    with SingleTickerProviderStateMixin {
  static const bgA = Color(0xFF04062A);
  static const bgB = Color(0xFF120B33);
  static const bgC = Color(0xFF08090F);

  static const gold = Color(0xFFFFC94A);
  static const blue = Color(0xFF4F7CFF);
  static const purple = Color(0xFF9B5CF6);
  static const pink = Color(0xFFEC4899);

  static const String bookImage = 'asset/li.png';

  late final AnimationController _controller;

  final List<_Star> stars = List.generate(22, (_) => _Star());

  final int progressSegments = 3;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat();

    _checkUserAndNavigate();
  }

  // ============================================================
  // CHECK FIREBASE LOGIN
  // ============================================================

  Future<void> _checkUserAndNavigate() async {
    // Splash ko minimum 5 seconds show karna hai
    await Future.delayed(const Duration(seconds: 5));

    if (!mounted) return;

    // Firebase se current logged-in user check
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // ========================================================
      // USER ALREADY LOGGED IN
      // ========================================================

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 700),
          pageBuilder: (_, animation, secondaryAnimation) =>
              const BookNavScreen(),
          transitionsBuilder:
              (_, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: child,
            );
          },
        ),
      );
    } else {
      // ========================================================
      // USER NOT LOGGED IN
      // ========================================================

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 700),
          pageBuilder: (_, animation, secondaryAnimation) =>
              const BookVerseSignInScreen(),
          transitionsBuilder:
              (_, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          final progressT = (_controller.value * 3) % 3;

          final pulse =
              0.9 + 0.1 * ((sin(t * 2 * pi) + 1) / 2);

          return Stack(
            children: [
              // ==================================================
              // BACKGROUND
              // ==================================================

              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(
                        -1 + 2 * sin(t * 2 * pi),
                        -1,
                      ),
                      end: Alignment(
                        1,
                        1 - 2 * sin(t * 2 * pi),
                      ),
                      colors: const [
                        bgA,
                        bgB,
                        bgC,
                      ],
                    ),
                  ),
                ),
              ),

              // ==================================================
              // STARS
              // ==================================================

              Positioned.fill(
                child: CustomPaint(
                  painter: _StarPainter(stars, t),
                ),
              ),

              // ==================================================
              // BOOK ANIMATION
              // ==================================================

              Align(
                alignment: const Alignment(0, -0.35),
                child: Transform.translate(
                  offset: Offset(
                    0,
                    6 * sin(t * 2 * pi),
                  ),
                  child: SizedBox(
                    width: 230,
                    height: 230,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.rotate(
                          angle: t * 2 * pi,
                          child: Container(
                            width: 190,
                            height: 190,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: SweepGradient(
                                colors: [
                                  blue,
                                  purple,
                                  pink,
                                  blue,
                                ],
                              ),
                            ),
                            child: Center(
                              child: Container(
                                width: 176,
                                height: 176,
                                decoration: const BoxDecoration(
                                  color: bgA,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),

                        Transform.scale(
                          scale: pulse,
                          child: Image.asset(
                            bookImage,
                            width: 150,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ==================================================
              // BOTTOM CONTENT
              // ==================================================

              Positioned(
                left: 0,
                right: 0,
                bottom: size.height * 0.10,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            gold,
                            blue,
                            purple,
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.auto_stories_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      'BookVerse',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Dive into a world of stories',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 22),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        progressSegments,
                        (i) {
                          final fill =
                              (progressT - i).clamp(0.0, 1.0);

                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 4,
                            ),
                            width: 22,
                            height: 4,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(4),
                              color: Color.lerp(
                                Colors.white24,
                                gold,
                                fill,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// STAR PAINTER
// ============================================================

class _StarPainter extends CustomPainter {
  final List<_Star> stars;
  final double t;

  _StarPainter(this.stars, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (final s in stars) {
      final twinkle =
          (sin((t * 2 * pi) + s.phase * 2 * pi) + 1) / 2;

      paint.color = s.color.withValues(
        alpha: 0.15 + twinkle * 0.55,
      );

      canvas.drawCircle(
        Offset(
          s.x * size.width,
          s.y * size.height,
        ),
        s.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) {
    return true;
  }
}