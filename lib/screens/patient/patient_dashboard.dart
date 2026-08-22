import 'package:flutter/material.dart';
import '../../constants/patient_theme.dart';
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
  String _progressFilter = 'This Month';

  final List<Map<String, dynamic>> _todayExercises = [
    {
      'name': 'Bridge Exercise',
      'sets': '3',
      'reps': '12',
      'duration': '10 min',
      'isCompleted': true,
      'icon': Icons.accessibility_new_rounded,
    },
    {
      'name': 'Wall Squat',
      'sets': '3',
      'reps': '15',
      'duration': '15 min',
      'isCompleted': true,
      'icon': Icons.fitness_center_rounded,
    },
    {
      'name': 'Leg Raise',
      'sets': '3',
      'reps': '12',
      'duration': '10 min',
      'isCompleted': false,
      'icon': Icons.airline_seat_legroom_extra_rounded,
    },
    {
      'name': 'Hamstring Stretch',
      'sets': '3',
      'reps': '30 sec',
      'duration': '5 min',
      'isCompleted': false,
      'icon': Icons.self_improvement_rounded,
    },
  ];

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

                  // Motivational Quote
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Stay consistent, get stronger every day.',
                      style: TextStyle(
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
                        MaterialPageRoute(builder: (_) => const AppointmentDetailScreen()),
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
                            children: const [
                              Text(
                                'Upcoming Appointment',
                                style: TextStyle(fontSize: 10.5, color: PatientTheme.textSecondary, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Today, 05:00 PM',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
                              ),
                              SizedBox(height: 1),
                              Text(
                                'Dr. Vashu User • Sports & Orthopedic',
                                style: TextStyle(fontSize: 11, color: PatientTheme.textSecondary),
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
                          value: '5/6',
                          subtitle: 'Completed',
                          color: PatientTheme.primaryTeal,
                          icon: Icons.fitness_center_rounded,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const ExerciseListScreen()),
                            );
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
                          value: '78%',
                          subtitle: 'Improving',
                          color: PatientTheme.successGreen,
                          icon: Icons.trending_up_rounded,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const PatientProgressScreen()),
                            );
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
                                onChanged: (v) {
                                  if (v != null) setState(() => _progressFilter = v);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Gauge
                        const Center(
                          child: CircularProgressGauge(
                            progress: 0.78,
                            subtitle: 'Good Progress',
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Breakdown
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: const [
                            _BreakdownPill(label: 'Completed', value: '78%', color: PatientTheme.successGreen),
                            _BreakdownPill(label: 'In Progress', value: '15%', color: PatientTheme.infoBlue),
                            _BreakdownPill(label: 'Pending', value: '7%', color: PatientTheme.warningOrange),
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
                      children: const [
                        Text(
                          'Weekly Activity',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: PatientTheme.textDark,
                          ),
                        ),
                        SizedBox(height: 16),
                        WeeklyActivityBarChart(),
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
                          );
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

                  // Exercise Rows
                  ...List.generate(_todayExercises.length, (index) {
                    final ex = _todayExercises[index];
                    final isDone = ex['isCompleted'] as bool;

                    return PatientCard(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ExerciseDetailScreen(
                              exerciseName: ex['name'] as String,
                              sets: ex['sets'] as String,
                              reps: ex['reps'] as String,
                              duration: ex['duration'] as String,
                              isInitiallyCompleted: isDone,
                            ),
                          ),
                        );
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
                              ex['icon'] as IconData,
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
                                  ex['name'] as String,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: PatientTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${ex['sets']} sets • ${ex['reps']} reps • ${ex['duration']}',
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
