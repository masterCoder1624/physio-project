import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../auth/login_screen.dart';
import 'progress_screen.dart';

const _welcomeBlue = Color(0xFF10B981);
const _welcomeMuted = Color(0xFFA7F3D0);

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _continueToProgress(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ProgressScreen()));
  }

  void _skipToLogin(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const Expanded(flex: 62, child: _WelcomeHero()),
              Expanded(
                flex: 38,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(21, 0, 21, 18),
                  child: Column(
                    children: [
                      const Spacer(flex: 11),
                      const _PageIndicator(),
                      const Spacer(flex: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed: () => _continueToProgress(context),
                          style: FilledButton.styleFrom(
                            backgroundColor: _welcomeBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => _skipToLogin(context),
                        style: TextButton.styleFrom(
                          foregroundColor: _welcomeMuted,
                          minimumSize: const Size(0, 35),
                        ),
                        child: const Text(
                          'Skip introduction',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
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
}

class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _welcomeBlue,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(top: -83, right: -45, child: _BackgroundCircle(size: 222)),
          Positioned(
            bottom: -76,
            left: -38,
            child: _BackgroundCircle(size: 146),
          ),
          const Positioned(top: 13, right: 12, child: _OnboardingPill()),
          Center(
            child: Transform.translate(
              offset: const Offset(0, 26),
              child: const _WelcomeMessage(),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeMessage extends StatelessWidget {
  const _WelcomeMessage();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _HeartMark(),
        SizedBox(height: 25),
        Text(
          'Welcome to\nPhysioVerse',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 23,
            height: 1.08,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 14),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 38),
          child: Text(
            'Manage patients, track recovery, and\nconduct consultations — all in one\nplace.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 12, height: 1.45),
          ),
        ),
      ],
    );
  }
}

class _HeartMark extends StatelessWidget {
  const _HeartMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 69,
      height: 69,
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.favorite_border_rounded,
        color: Colors.white,
        size: 37,
      ),
    );
  }
}

class _OnboardingPill extends StatelessWidget {
  const _OnboardingPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF0874D8),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33004488),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 5, color: Colors.white),
          SizedBox(width: 6),
          Text(
            'Onboarding',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 13,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

class _BackgroundCircle extends StatelessWidget {
  const _BackgroundCircle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0x332B8AE0),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _IndicatorDot(active: true),
        SizedBox(width: 5),
        _IndicatorDot(),
        SizedBox(width: 5),
        _IndicatorDot(),
      ],
    );
  }
}

class _IndicatorDot extends StatelessWidget {
  const _IndicatorDot({this.active = false});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: active ? 18 : 7,
      height: 7,
      decoration: BoxDecoration(
        color: active ? _welcomeBlue : const Color(0xFFDDE5EC),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
