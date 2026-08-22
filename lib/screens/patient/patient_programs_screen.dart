import 'package:flutter/material.dart';
import '../../constants/patient_theme.dart';
import 'patient_components.dart';
import 'program_detail_screen.dart';

/// Screen 10 — My Treatment Programs Screen (matching media_1787385006975.jpg)
class PatientProgramsScreen extends StatelessWidget {
  const PatientProgramsScreen({super.key});

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
          'My Program',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Your active treatment programs',
            style: TextStyle(fontSize: 13, color: PatientTheme.textSecondary),
          ),
          const SizedBox(height: 16),

          // Primary Program Card (matching screenshot)
          PatientCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Knee Rehabilitation\nProgram',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: PatientTheme.textDark,
                              height: 1.25,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Started on 10 Aug 2026',
                            style: TextStyle(fontSize: 11.5, color: PatientTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const StatusBadge(label: 'Active', isInProgress: true),
                  ],
                ),
                const SizedBox(height: 16),

                // Progress Bar Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Progress', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PatientTheme.textDark)),
                    Text('78%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: PatientTheme.primaryTeal)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: const LinearProgressIndicator(
                    value: 0.78,
                    minHeight: 8,
                    backgroundColor: PatientTheme.borderLight,
                    valueColor: AlwaysStoppedAnimation<Color>(PatientTheme.primaryTeal),
                  ),
                ),
                const SizedBox(height: 18),

                // Phases Checklist
                const Text(
                  'Phases',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
                ),
                const SizedBox(height: 10),
                _buildPhaseRow('Phase 1: Pain Relief', 'Completed', true, false, false),
                _buildPhaseRow('Phase 2: Mobility', 'In Progress', false, true, false),
                _buildPhaseRow('Phase 3: Strengthening', 'Pending', false, false, true),
                const SizedBox(height: 18),

                // View Details Button
                SecondaryOutlineButton(
                  label: 'View Program Details',
                  icon: Icons.info_outline_rounded,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ProgramDetailScreen(
                          programName: 'Knee Rehabilitation Program',
                          currentPhase: 'Phase 2 of 3',
                          progressPct: 0.78,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Secondary Program Card
          PatientCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Lumbar Core Stability',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: PatientTheme.textDark,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Started on 01 Aug 2026',
                            style: TextStyle(fontSize: 11.5, color: PatientTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const StatusBadge(label: 'Active', isInProgress: true),
                  ],
                ),
                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Progress', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PatientTheme.textDark)),
                    Text('45%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: PatientTheme.primaryTeal)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: const LinearProgressIndicator(
                    value: 0.45,
                    minHeight: 8,
                    backgroundColor: PatientTheme.borderLight,
                    valueColor: AlwaysStoppedAnimation<Color>(PatientTheme.primaryTeal),
                  ),
                ),
                const SizedBox(height: 16),

                SecondaryOutlineButton(
                  label: 'View Program Details',
                  icon: Icons.info_outline_rounded,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ProgramDetailScreen(
                          programName: 'Lumbar Core Stability',
                          currentPhase: 'Phase 1 of 2',
                          progressPct: 0.45,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseRow(String name, String status, bool done, bool inProg, bool pending) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: done ? PatientTheme.successGreen : (inProg ? PatientTheme.primaryTeal : PatientTheme.warningOrange),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                name,
                style: const TextStyle(fontSize: 12.5, color: PatientTheme.textDark, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          StatusBadge(
            label: status,
            isCompleted: done,
            isInProgress: inProg,
            isPending: pending,
          ),
        ],
      ),
    );
  }
}
