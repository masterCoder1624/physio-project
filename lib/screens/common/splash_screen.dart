import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _loadingController;
  late final AnimationController _pulseController;

  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  Timer? _statusTimer;

  int _statusIndex = 0;

  final List<String> _loadingMessages = [
    'Preparing your practice',
    'Loading your workspace',
    'Setting up appointments',
    'Almost ready',
  ];

  static const Color _background = Color(0xFFF2FAFA);
  static const Color _teal = Color(0xFF08A5A0);
  static const Color _darkText = Color(0xFF12324A);
  static const Color _mutedText = Color(0xFF78909C);
  static const Color _trackColor = Color(0xFFD5EEEE);

  @override
  void initState() {
    super.initState();

    // ------------------------------------------------------------
    // SPLASH ENTRANCE ANIMATION
    // ------------------------------------------------------------

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.96,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutCubic,
      ),
    );

    _entranceController.forward();

    // ------------------------------------------------------------
    // LOADING ANIMATION
    // ------------------------------------------------------------

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _loadingController.forward();

    // ------------------------------------------------------------
    // SUBTLE PULSE ANIMATION
    // ------------------------------------------------------------

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
      lowerBound: 0.97,
      upperBound: 1.03,
    )..repeat(reverse: true);

    // ------------------------------------------------------------
    // CHANGE LOADING MESSAGE
    // ------------------------------------------------------------

    _statusTimer = Timer.periodic(
      const Duration(milliseconds: 800),
      (timer) {
        if (!mounted) return;

        setState(() {
          if (_statusIndex < _loadingMessages.length - 1) {
            _statusIndex++;
          }
        });
      },
    );

    // ------------------------------------------------------------
    // GO TO LOGIN
    // ------------------------------------------------------------

    Future.delayed(
      const Duration(milliseconds: 3500),
      _openLogin,
    );
  }

  void _openLogin() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return const LoginScreen();
        },
        transitionDuration: const Duration(milliseconds: 700),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _statusTimer?.cancel();

    _entranceController.dispose();
    _loadingController.dispose();
    _pulseController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _background,
        body: SafeArea(
          child: Stack(
            children: [
              // ============================================================
              // BACKGROUND DECORATIONS
              // ============================================================

              Positioned(
                top: -90,
                left: -90,
                child: _backgroundCircle(
                  size: 250,
                  opacity: 0.07,
                ),
              ),

              Positioned(
                top: 100,
                right: -110,
                child: _backgroundCircle(
                  size: 230,
                  opacity: 0.045,
                ),
              ),

              Positioned(
                bottom: -120,
                right: -100,
                child: _backgroundCircle(
                  size: 270,
                  opacity: 0.065,
                ),
              ),

              // ============================================================
              // MAIN CONTENT
              // ============================================================

              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // ----------------------------------------------------
                      // HERO IMAGE
                      // ----------------------------------------------------

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                          ),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(34),
                              boxShadow: [
                                BoxShadow(
                                  color: _teal.withValues(alpha: 0.06),
                                  blurRadius: 30,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(34),
                              child: Image.asset(
                                'assets/images/rehabz_splash_logo.png',
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.contain,
                                errorBuilder: (
                                  context,
                                  error,
                                  stackTrace,
                                ) {
                                  return _imageError();
                                },
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ----------------------------------------------------
                      // LOADING SECTION
                      // ----------------------------------------------------

                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          32,
                          0,
                          32,
                          26,
                        ),
                        child: Column(
                          children: [
                            // Animated loading message
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (
                                Widget child,
                                Animation<double> animation,
                              ) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                              child: Text(
                                _loadingMessages[_statusIndex],
                                key: ValueKey(_statusIndex),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: _darkText,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Progress bar
                            AnimatedBuilder(
                              animation: _loadingController,
                              builder: (context, child) {
                                final progress =
                                    _loadingController.value;

                                return Column(
                                  children: [
                                    Container(
                                      width: 260,
                                      height: 7,
                                      decoration: BoxDecoration(
                                        color: _trackColor,
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: FractionallySizedBox(
                                          widthFactor: progress,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: _teal,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: _teal.withValues(
                                                    alpha: 0.20,
                                                  ),
                                                  blurRadius: 8,
                                                  offset:
                                                      const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 9),

                                    // Percentage
                                    Text(
                                      '${(progress * 100).round()}%',
                                      style: const TextStyle(
                                        color: _mutedText,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),

                            const SizedBox(height: 12),

                            // Animated dots
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _dot(0),
                                const SizedBox(width: 6),
                                _dot(1),
                                const SizedBox(width: 6),
                                _dot(2),
                              ],
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
        ),
      ),
    );
  }

  // ============================================================
  // BACKGROUND CIRCLE
  // ============================================================

  Widget _backgroundCircle({
    required double size,
    required double opacity,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _teal.withValues(alpha: opacity),
      ),
    );
  }

  // ============================================================
  // ANIMATED DOT
  // ============================================================

  Widget _dot(int index) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final delay = index * 0.12;

        final value =
            ((_pulseController.value - 0.97) / 0.06 - delay)
                .clamp(0.0, 1.0);

        return Container(
          width: 7 + (value * 2),
          height: 7 + (value * 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == 0
                ? _teal
                : _teal.withValues(alpha: 0.25),
          ),
        );
      },
    );
  }

  // ============================================================
  // IMAGE ERROR
  // ============================================================

  Widget _imageError() {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 44,
            color: _mutedText,
          ),
          SizedBox(height: 12),
          Text(
            'Unable to load splash image',
            style: TextStyle(
              color: _mutedText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}