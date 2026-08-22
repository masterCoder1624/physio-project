import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shared frontend-only navigation and system UI helpers for the Physio section.
/// No backend/API behavior is involved here.
class PhysioNavigation {
  static const Duration _duration = Duration(milliseconds: 240);

  static PageRouteBuilder<T> route<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: _duration,
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.025, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  static Future<T?> push<T>(BuildContext context, Widget page) {
    return Navigator.of(context).push<T>(route<T>(page));
  }

  static Future<T?> replace<T, TO>(BuildContext context, Widget page, {TO? result}) {
    return Navigator.of(context).pushReplacement<T, TO>(route<T>(page), result: result);
  }

  static Future<T?> pushAndClear<T>(BuildContext context, Widget page) {
    return Navigator.of(context).pushAndRemoveUntil<T>(route<T>(page), (route) => false);
  }
}

class PhysioSystemUi extends StatelessWidget {
  const PhysioSystemUi({
    super.key,
    required this.child,
    required this.statusBarColor,
    this.statusBarBrightness = Brightness.light,
    this.systemNavigationBarColor = Colors.white,
  });

  final Widget child;
  final Color statusBarColor;
  final Brightness statusBarBrightness;
  final Color systemNavigationBarColor;

  @override
  Widget build(BuildContext context) {
    final iconBrightness = statusBarBrightness == Brightness.dark
        ? Brightness.light
        : Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: statusBarColor,
        statusBarBrightness: statusBarBrightness,
        statusBarIconBrightness: iconBrightness,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarColor: systemNavigationBarColor,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: child,
    );
  }
}
