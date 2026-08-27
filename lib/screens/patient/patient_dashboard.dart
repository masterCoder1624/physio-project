import 'package:flutter/material.dart';
import '../../constants/patient_theme.dart';
import '../../models/appointment_model.dart';
import '../../models/exercise_model.dart';
import '../../models/progress_model.dart';
import '../../services/appointment_service.dart';
import '../../services/exercise_service.dart';
import '../../services/progress_service.dart';
import 'appointment_detail_screen.dart';
import 'exercise_detail_screen.dart';
import 'exercise_list_screen.dart';
import 'patient_components.dart';
import 'patient_messages_screen.dart';
import 'patient_notifications_screen.dart';
import 'patient_progress_screen.dart';
import 'patient_side_drawer.dart';

/// Screen 7 — Patient Home Dashboard (matching media_1787385006975.jpg)
class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key, this.onNavigateTab});

  final void Function(int index)? onNavigateTab;

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ExerciseService _exerciseService = ExerciseService();
  final ProgressService _progressService = ProgressService();
  String _progressFilter = 'This Month';
  AppointmentModel? _upcomingAppointment;
  TodayPlanModel? _todayPlan;
  PatientProgramModel? _activeProgram;
  PatientProgressModel? _progressData;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    _loadUpcomingAppointment();
    try {
      final plan = await _exerciseService.getTodayPlan();
      final progs = await _exerciseService.getMyPrograms();
      final progress = await _progressService.getMyProgress(period: _progressFilter);
      if (!mounted) return;
      setState(() {
        _todayPlan = plan;
        _progressData = progress;
        if (progs.isNotEmpty) {
          _activeProgram = progs.first;
        }
      });
    } catch (_) {}
  }

  Future<void> _loadUpcomingAppointment() async {
    try {
      final list = await AppointmentService().getAppointments();
      if (!mounted) return;
      final now = DateTime.now();
      final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final upcoming = list.where((a) => !a.isCancelled && !a.isCompleted && a.appointmentDate.compareTo(todayStr) >= 0).toList();
      if (upcoming.isNotEmpty) {
        setState(() => _upcomingAppointment = upcoming.first);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: PatientTheme.pageBg,
      drawer: const PatientSideDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Teal Header Section (matching screenshot)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
              decoration: const BoxDecoration(
                color: PatientTheme.primaryTeal,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  // App Bar Row (Avatar, Name, Bell)
                  Row(
                    children: [
                      // Hamburger drawer button
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 24),
                        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                      ),
                      const SizedBox(width: 14),

                      // Avatar
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                        child: const Text(
                          'AR',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Greeting
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Good morning,',
                              style: TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                            Text(
                              'Anshu Reddy',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Notification Bell with Badge
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const PatientNotificationsScreen()),
                          );
                        },
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
                            ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEF4444),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Motivational Quote / Active Program
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _activeProgram != null ? 'Active Protocol: ${_activeProgram!.title}' : 'Stay consistent, get stronger every day.',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Upcoming Appointment Card (matching screenshot)
                  PatientCard(
                    padding: const EdgeInsets.all(16),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AppointmentDetailScreen(
                            appointment: _upcomingAppointment,
                          ),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: PatientTheme.primaryTealLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.calendar_today_rounded,
                            color: PatientTheme.primaryTeal,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Upcoming Appointment',
                                style: TextStyle(fontSize: 10.5, color: PatientTheme.textSecondary, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _upcomingAppointment != null
                                    ? '${_upcomingAppointment!.appointmentDate} • ${_upcomingAppointment!.startTime}'
                                    : 'Today, 05:00 PM',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                _upcomingAppointment != null
                                    ? '${_upcomingAppointment!.physioName ?? "Dr. Vashu User"} • ${_upcomingAppointment!.physioSpecialty ?? "Sports & Orthopedic"}'
                                    : 'Dr. Vashu User • Sports & Orthopedic',
                                style: const TextStyle(fontSize: 11, color: PatientTheme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        const Text(
                          'View >',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: PatientTheme.primaryTeal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Main Content Area
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 3 Metric Stat Cards (Today's Exercises, Messages, Overall Progress)
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricStatCard(
                          title: 'Today\'s Exercises',
                          value: _todayPlan != null ? '${_todayPlan!.completedExercises}/${_todayPlan!.totalExercises}' : '0/0',
                          subtitle: 'Completed',
                          color: PatientTheme.primaryTeal,
                          icon: Icons.fitness_center_rounded,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const ExerciseListScreen()),
                            ).then((_) => _loadDashboardData());
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetricStatCard(
                          title: 'Messages',
                          value: '2',
                          subtitle: 'Unread',
                          color: PatientTheme.infoBlue,
                          icon: Icons.chat_bubble_outline_rounded,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const PatientMessagesScreen()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetricStatCard(
                          title: 'Overall Progress',
                          value: _progressData != null ? '${_progressData!.overallPercentage}%' : (_todayPlan != null ? '${_todayPlan!.progressPercentage}%' : '0%'),
                          subtitle: _progressData?.progressSubtitle ?? 'Improving',
                          color: PatientTheme.successGreen,
                          icon: Icons.trending_up_rounded,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const PatientProgressScreen()),
                            ).then((_) => _loadDashboardData());
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Overall Progress Card with Gauge (matching screenshot)
                  PatientCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Overall Progress',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: PatientTheme.textDark,
                              ),
                            ),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _progressFilter,
                                isDense: true,
                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: PatientTheme.primaryTeal),
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: PatientTheme.primaryTeal),
                                items: ['This Week', 'This Month', '3 Months']
                                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                                    .toList(),
                                onChanged: (v) async {
                                  if (v != null) {
                                    setState(() => _progressFilter = v);
                                    final progress = await _progressService.getMyProgress(period: v);
                                    if (!mounted) return;
                                    setState(() => _progressData = progress);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Gauge
                        Center(
                          child: CircularProgressGauge(
                            progress: ((_progressData?.overallPercentage ?? _todayPlan?.progressPercentage ?? 0) / 100.0).clamp(0.0, 1.0),
                            subtitle: _progressData?.progressSubtitle ?? 'Good Progress',
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Breakdown
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _BreakdownPill(
                              label: 'Completed',
                              value: '${_progressData?.completedCount ?? _todayPlan?.completedExercises ?? 0}',
                              color: PatientTheme.successGreen,
                            ),
                            _BreakdownPill(
                              label: 'In Progress',
                              value: '${_progressData?.inProgressCount ?? 0}',
                              color: PatientTheme.infoBlue,
                            ),
                            _BreakdownPill(
                              label: 'Pending',
                              value: '${_progressData?.pendingCount ?? 0}',
                              color: PatientTheme.warningOrange,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Weekly Activity Bar Chart
                  PatientCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Weekly Activity',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: PatientTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        WeeklyActivityBarChart(
                          values: _progressData?.exerciseCompliance.weeklyActivity.map((w) => w.completionRate).toList(),
                          days: _progressData?.exerciseCompliance.weeklyActivity.map((w) => w.day).toList() ?? const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Today's Plan Header & List (matching screenshot)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Today\'s Plan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: PatientTheme.textDark,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ExerciseListScreen()),
                          ).then((_) => _loadDashboardData());
                        },
                        child: const Text(
                          'See All Exercises >',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: PatientTheme.primaryTeal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Exercise Rows or Empty State
                  if (_todayPlan == null || _todayPlan!.exercises.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Text(
                          'No exercises assigned for today.',
                          style: TextStyle(color: PatientTheme.textSecondary, fontSize: 13),
                        ),
                      ),
                    )
                  else
                    ..._todayPlan!.exercises.take(4).map((ex) {
                      final isDone = ex.isCompletedToday;

                      return PatientCard(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ExerciseDetailScreen(
                                assignmentId: ex.id,
                                exerciseName: ex.exerciseTitle,
                                targetArea: ex.bodyPart,
                                sets: '${ex.sets}',
                                reps: '${ex.reps}',
                                duration: ex.duration,
                                isInitiallyCompleted: isDone,
                                instructions: ex.instructions,
                              ),
                            ),
                          ).then((_) => _loadDashboardData());
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: isDone ? PatientTheme.successGreenBg : PatientTheme.primaryTealLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.fitness_center_rounded,
                                color: isDone ? PatientTheme.successGreen : PatientTheme.primaryTeal,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ex.exerciseTitle,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                      color: PatientTheme.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${ex.sets} sets • ${ex.reps} reps • ${ex.duration}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: PatientTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            StatusBadge(
                              label: isDone ? 'Completed' : 'Pending',
                              isCompleted: isDone,
                              isPending: !isDone,
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: PatientTheme.textMuted),
                          ],
                        ),
                      );
                    }),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return PatientCard(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: PatientTheme.textDark,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 9.5, color: PatientTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _BreakdownPill extends StatelessWidget {
  const _BreakdownPill({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: PatientTheme.textDark)),
            Text(label, style: const TextStyle(fontSize: 10, color: PatientTheme.textSecondary)),
          ],
        ),
      ],
    );
  }
}
