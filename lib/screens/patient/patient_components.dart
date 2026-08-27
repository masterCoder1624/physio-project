import 'package:flutter/material.dart';
import '../../constants/patient_theme.dart';

/// Reusable Card Container for Patient UI
class PatientCard extends StatelessWidget {
  const PatientCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 18,
    this.onTap,
    this.color = PatientTheme.cardBg,
    this.borderColor = PatientTheme.border,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: PatientTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Status Badge Pill (Completed, In Progress, Pending, Scheduled, etc.)
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.isCompleted = false,
    this.isInProgress = false,
    this.isPending = false,
    this.isScheduled = false,
  });

  final String label;
  final bool isCompleted;
  final bool isInProgress;
  final bool isPending;
  final bool isScheduled;

  @override
  Widget build(BuildContext context) {
    Color bg = PatientTheme.primaryTealLight;
    Color fg = PatientTheme.primaryTeal;

    if (isCompleted || label.toLowerCase() == 'completed' || label.toLowerCase() == 'paid') {
      bg = PatientTheme.successGreenBg;
      fg = PatientTheme.successGreen;
    } else if (isInProgress || label.toLowerCase().contains('progress') || label.toLowerCase() == 'active') {
      bg = PatientTheme.infoBlueBg;
      fg = PatientTheme.infoBlue;
    } else if (isPending || label.toLowerCase().contains('pending')) {
      bg = PatientTheme.warningOrangeBg;
      fg = PatientTheme.warningOrange;
    } else if (isScheduled || label.toLowerCase().contains('scheduled')) {
      bg = PatientTheme.primaryTealLight;
      fg = PatientTheme.primaryTeal;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

/// Primary Full-Width Rounded Teal Button
class PrimaryTealButton extends StatelessWidget {
  const PrimaryTealButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.height = 50,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: onPressed != null ? PatientTheme.tealButtonShadow : null,
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: PatientTheme.primaryTeal,
            foregroundColor: Colors.white,
            elevation: 0,
            disabledBackgroundColor: PatientTheme.primaryTeal.withValues(alpha: 0.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Secondary Outlined Button
class SecondaryOutlineButton extends StatelessWidget {
  const SecondaryOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 46,
    this.color = PatientTheme.primaryTeal,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.6), width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Circular Gauge Progress Visualizer
class CircularProgressGauge extends StatelessWidget {
  const CircularProgressGauge({
    super.key,
    required this.progress,
    this.title = 'Overall Progress',
    this.subtitle = 'Good Progress',
    this.size = 130,
  });

  final double progress; // 0.0 to 1.0
  final String title;
  final String subtitle;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: _GaugePainter(progress: progress),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: PatientTheme.textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: PatientTheme.primaryTeal,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 16) / 2;

    // Background track arc
    final trackPaint = Paint()
      ..color = PatientTheme.borderLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.14159 * 0.75,
      3.14159 * 1.5,
      false,
      trackPaint,
    );

    // Foreground progress arc
    final progressPaint = Paint()
      ..color = PatientTheme.primaryTeal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.14159 * 0.75,
      3.14159 * 1.5 * progress.clamp(0.0, 1.0),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Weekly Activity Bar Chart (Monday to Sunday)
class WeeklyActivityBarChart extends StatelessWidget {
  const WeeklyActivityBarChart({
    super.key,
    this.values,
    this.days = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
    this.todayIndex,
  });

  final List<double>? values;
  final List<String> days;
  final int? todayIndex;

  @override
  Widget build(BuildContext context) {
    final effectiveValues = values != null && values!.isNotEmpty
        ? values!
        : const [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
    final activeToday = todayIndex ?? (DateTime.now().weekday - 1).clamp(0, 6);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        final isToday = index == activeToday;
        final rawPct = index < effectiveValues.length ? effectiveValues[index] : 0.0;
        final heightPct = rawPct.clamp(0.0, 1.0);

        return Column(
          children: [
            Container(
              width: 28,
              height: 70,
              decoration: BoxDecoration(
                color: PatientTheme.borderLight,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 28,
                height: 70 * (heightPct > 0 ? heightPct : 0.05),
                decoration: BoxDecoration(
                  color: isToday
                      ? PatientTheme.primaryTeal
                      : (heightPct > 0 ? const Color(0xFF99DFD3) : PatientTheme.borderLight),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              index < days.length ? days[index] : '',
              style: TextStyle(
                fontSize: 11,
                fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                color: isToday ? PatientTheme.primaryTeal : PatientTheme.textSecondary,
              ),
            ),
          ],
        );
      }),
    );
  }
}

/// Line Chart Graph Painter for Progress Over Time
class ProgressLineChart extends StatelessWidget {
  const ProgressLineChart({
    super.key,
    this.values,
  });

  final List<double>? values;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      width: double.infinity,
      child: CustomPaint(
        painter: _LineChartPainter(values: values),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({this.values});
  final List<double>? values;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = PatientTheme.primaryTeal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = PatientTheme.primaryTeal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final effectiveValues = values != null && values!.isNotEmpty
        ? values!
        : const [15.0, 30.0, 45.0, 65.0, 80.0];

    final n = effectiveValues.length;
    final points = <Offset>[];

    for (int i = 0; i < n; i++) {
      final x = n == 1 ? size.width / 2 : 10 + (size.width - 20) * (i / (n - 1));
      final val = effectiveValues[i].clamp(0.0, 100.0);
      final y = size.height * (0.9 - (val / 100.0) * 0.75);
      points.add(Offset(x, y));
    }

    if (points.isNotEmpty) {
      final path = Path();
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, linePaint);

      for (final p in points) {
        canvas.drawCircle(p, 5, dotPaint);
        canvas.drawCircle(p, 5, dotBorderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.values != values;
}
