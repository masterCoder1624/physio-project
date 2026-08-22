import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../onboarding/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  final Future<FirebaseApp> firebaseReady;

  const SplashScreen({
    super.key,
    required this.firebaseReady,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.04,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();

    _startSplash();
  }

  Future<void> _startSplash() async {
    try {
      await Future.wait([
        widget.firebaseReady,
        Future.delayed(
          const Duration(seconds: 3),
        ),
      ]);
    } catch (e) {
      // Keep the splash visible briefly even if Firebase
      // initialization fails.
      await Future.delayed(
        const Duration(milliseconds: 500),
      );
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (
          context,
          animation,
          secondaryAnimation,
        ) {
          return const WelcomeScreen();
        },
        transitionDuration: const Duration(
          milliseconds: 600,
        ),
        reverseTransitionDuration: Duration.zero,
        transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
        ) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFF2FAFA),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF2FAFA),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenHeight = constraints.maxHeight;

                return Column(
                  children: [
                    const Spacer(),

                    // --------------------------------------------------
                    // SPLASH IMAGE
                    // --------------------------------------------------
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: SizedBox(
                            width: double.infinity,
                            height: screenHeight * 0.62,
                            child: Image.asset(
                              'assets/images/physiosoft_splash_screen.png',
                              fit: BoxFit.cover,

                              // If the path is wrong, this prevents
                              // the red Flutter error screen.
                              errorBuilder: (
                                context,
                                error,
                                stackTrace,
                              ) {
                                return Container(
                                  color: const Color(0xFFF2FAFA),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Splash image unavailable',
                                    style: TextStyle(
                                      color: Color(0xFF6B7C93),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // --------------------------------------------------
                    // LOADING TEXT
                    // --------------------------------------------------
                    const Text(
                      'Preparing your practice',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF17324D),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // --------------------------------------------------
                    // PROGRESS BAR
                    // --------------------------------------------------
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: 0,
                        end: 1,
                      ),
                      duration: const Duration(seconds: 3),
                      curve: Curves.easeInOut,
                      builder: (
                        context,
                        value,
                        child,
                      ) {
                        return SizedBox(
                          width: 150,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: value,
                              minHeight: 5,
                              backgroundColor:
                                  const Color(0xFFD8EEEE),
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(
                                Color(0xFF0AA6A3),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const Spacer(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}