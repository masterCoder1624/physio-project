import 'package:flutter/material.dart';
import '../../constants/patient_theme.dart';
import 'patient_components.dart';

/// Screen 12 — Progress Tracking Screen (matching media_1787385006975.jpg)
class PatientProgressScreen extends StatefulWidget {
  const PatientProgressScreen({super.key});

  @override
  State<PatientProgressScreen> createState() => _PatientProgressScreenState();
}

class _PatientProgressScreenState extends State<PatientProgressScreen> {
  String _selectedPeriod = 'This Month';

  @override
  Widget build(BuildContext context) {
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
                  if (val != null) setState(() => _selectedPeriod = val);
                },
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
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
                const CircularProgressGauge(
                  progress: 0.78,
                  subtitle: 'Good Progress',
                ),
                const SizedBox(height: 20),

                // 3 Count Stats Row (Completed 18, In Progress 5, Pending 3)
                Row(
                  children: [
                    Expanded(child: _buildCountStat('Completed', '18', PatientTheme.successGreen, PatientTheme.successGreenBg)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildCountStat('In Progress', '5', PatientTheme.infoBlue, PatientTheme.infoBlueBg)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildCountStat('Pending', '3', PatientTheme.warningOrange, PatientTheme.warningOrangeBg)),
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
                  children: const [
                    Text(
                      'Progress Over Time',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
                    ),
                    Text(
                      '100%',
                      style: TextStyle(fontSize: 11, color: PatientTheme.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Line Chart
                const ProgressLineChart(),
                const SizedBox(height: 10),

                // Date Markers Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('1 Aug', style: TextStyle(fontSize: 10.5, color: PatientTheme.textMuted)),
                    Text('8 Aug', style: TextStyle(fontSize: 10.5, color: PatientTheme.textMuted)),
                    Text('15 Aug', style: TextStyle(fontSize: 10.5, color: PatientTheme.textMuted)),
                    Text('22 Aug', style: TextStyle(fontSize: 10.5, color: PatientTheme.textMuted)),
                    Text('29 Aug', style: TextStyle(fontSize: 10.5, color: PatientTheme.textMuted)),
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
                  children: const [
                    Text(
                      'Weekly Consistency',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
                    ),
                    Text(
                      '85% Adherence',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: PatientTheme.primaryTeal),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const WeeklyActivityBarChart(),
              ],
            ),
          ),
        ],
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
