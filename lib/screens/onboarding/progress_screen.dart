import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../auth/login_screen.dart';

const _progressGreen = Color(0xFF00B894);
const _progressMuted = Color(0xFF7F8C8D);

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  void _openLogin(BuildContext context) {
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
              const Expanded(flex: 62, child: _ProgressHero()),
              Expanded(
                flex: 38,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
                  child: Column(
                    children: [
                      const Spacer(flex: 11),
                      const _PageIndicator(),
                      const Spacer(flex: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: OutlinedButton(
                          onPressed: () => _openLogin(context),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: _progressGreen,
                            foregroundColor: Colors.white,
                            side: const BorderSide(
                              color: _progressGreen,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => _openLogin(context),
                        style: TextButton.styleFrom(
                          foregroundColor: _progressMuted,
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

class _ProgressHero extends StatelessWidget {
  const _ProgressHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _progressGreen,
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
              child: const _ProgressMessage(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressMessage extends StatelessWidget {
  const _ProgressMessage();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PulseMark(),
        SizedBox(height: 25),
        Text(
          'Track Progress\nTogether',
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
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Patients follow their exercise programs\nwhile you monitor healing in real time.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 12, height: 1.45),
          ),
        ),
      ],
    );
  }
}

class _PulseMark extends StatelessWidget {
  const _PulseMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 69,
      height: 69,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.monitor_heart_outlined,
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
        color: const Color(0xFF00A98C),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33005647),
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
        color: Color(0x3329D0B3),
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
        _IndicatorDot(),
        SizedBox(width: 5),
        _IndicatorDot(active: true),
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
        color: active ? _progressGreen : const Color(0xFFDDE5EC),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
