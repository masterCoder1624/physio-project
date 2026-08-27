import 'package:flutter/material.dart';
import '../../constants/patient_theme.dart';
import '../../models/progress_model.dart';
import '../../services/progress_service.dart';
import 'patient_components.dart';

/// Screen 12 — Progress Tracking Screen (matching media_1787385006975.jpg)
class PatientProgressScreen extends StatefulWidget {
  const PatientProgressScreen({super.key, this.patientId});

  final String? patientId;

  @override
  State<PatientProgressScreen> createState() => _PatientProgressScreenState();
}

class _PatientProgressScreenState extends State<PatientProgressScreen> {
  final ProgressService _progressService = ProgressService();
  String _selectedPeriod = 'This Month';
  PatientProgressModel _progressData = PatientProgressModel.empty();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _progressData = _progressService.cachedProgress ?? PatientProgressModel.empty();
    _fetchProgress();
  }

  Future<void> _fetchProgress() async {
    setState(() => _isLoading = true);
    try {
      final data = widget.patientId != null && widget.patientId!.isNotEmpty
          ? await _progressService.getPatientProgress(widget.patientId!, period: _selectedPeriod)
          : await _progressService.getMyProgress(period: _selectedPeriod);
      if (!mounted) return;
      setState(() {
        _progressData = data;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _progressData;
    final overallPct = progress.overallPercentage / 100.0;
    final weeklyActivity = progress.exerciseCompliance.weeklyActivity;
    final weeklyValues = weeklyActivity.map((w) => w.completionRate).toList();
    final weeklyDays = weeklyActivity.map((w) => w.day).toList();
    final timePoints = progress.progressOverTime.map((p) => p.value).toList();
    final dateLabels = progress.dateLabels;

    return Scaffold(
      backgroundColor: PatientTheme.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: PatientTheme.textDark),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'My Progress',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: PatientTheme.inputBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: PatientTheme.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPeriod,
                isDense: true,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PatientTheme.textDark),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: PatientTheme.primaryTeal),
                items: ['This Week', 'This Month', '3 Months', 'All Time']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedPeriod = val);
                    _fetchProgress();
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchProgress,
        color: PatientTheme.primaryTeal,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_isLoading && !_progressData.hasData)
              const LinearProgressIndicator(
                minHeight: 2,
                color: PatientTheme.primaryTeal,
                backgroundColor: Colors.transparent,
              ),
              // Empty Data Notice Banner if patient has no records yet
              if (!progress.hasData)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: PatientTheme.infoBlueBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: PatientTheme.infoBlue.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 18, color: PatientTheme.infoBlue),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'No exercise or assessment records logged yet. Your recovery progress will update as you complete sessions.',
                          style: TextStyle(fontSize: 12, color: PatientTheme.textDark, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),

              // Overall Progress Card with Gauge (matching screenshot)
              PatientCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Overall Progress',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Circular Progress Gauge
                    CircularProgressGauge(
                      progress: overallPct.clamp(0.0, 1.0),
                      subtitle: progress.progressSubtitle,
                    ),
                    const SizedBox(height: 20),

                    // 3 Count Stats Row (Completed, In Progress, Pending)
                    Row(
                      children: [
                        Expanded(
                          child: _buildCountStat(
                            'Completed',
                            '${progress.completedCount}',
                            PatientTheme.successGreen,
                            PatientTheme.successGreenBg,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildCountStat(
                            'In Progress',
                            '${progress.inProgressCount}',
                            PatientTheme.infoBlue,
                            PatientTheme.infoBlueBg,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildCountStat(
                            'Pending',
                            '${progress.pendingCount}',
                            PatientTheme.warningOrange,
                            PatientTheme.warningOrangeBg,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Progress Over Time Card (with Line Chart)
              PatientCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Progress Over Time',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
                        ),
                        Text(
                          '${progress.overallPercentage}%',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: PatientTheme.primaryTeal),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Line Chart
                    ProgressLineChart(values: timePoints),
                    const SizedBox(height: 10),

                    // Date Markers Row
                    if (dateLabels.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: dateLabels
                            .map((l) => Text(l, style: const TextStyle(fontSize: 10.5, color: PatientTheme.textMuted)))
                            .toList(),
                      )
                    else
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Week 1', style: TextStyle(fontSize: 10.5, color: PatientTheme.textMuted)),
                          Text('Week 2', style: TextStyle(fontSize: 10.5, color: PatientTheme.textMuted)),
                          Text('Week 3', style: TextStyle(fontSize: 10.5, color: PatientTheme.textMuted)),
                          Text('Week 4', style: TextStyle(fontSize: 10.5, color: PatientTheme.textMuted)),
                          Text('Today', style: TextStyle(fontSize: 10.5, color: PatientTheme.textMuted)),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Weekly Consistency Card
              PatientCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Weekly Consistency',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
                        ),
                        Text(
                          '${progress.adherencePercentage}% Adherence',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: PatientTheme.primaryTeal),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    WeeklyActivityBarChart(
                      values: weeklyValues.isNotEmpty ? weeklyValues : null,
                      days: weeklyDays.isNotEmpty ? weeklyDays : const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
                    ),
                  ],
                ),
              ),
            ],
        ),
      ),
    );
  }

  Widget _buildCountStat(String title, String count, Color accentColor, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: PatientTheme.textDark),
          ),
        ],
      ),
    );
  }
}
