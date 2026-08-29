import 'package:flutter/material.dart';
import '../../constants/patient_theme.dart';
import '../../models/appointment_model.dart';
import '../../models/chat_model.dart';
import '../../models/document_model.dart';
import '../../models/exercise_model.dart';
import '../../models/progress_model.dart';
import '../../services/appointment_service.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../../services/document_service.dart';
import '../../services/exercise_service.dart';
import '../../services/progress_service.dart';
import 'appointment_detail_screen.dart';
import 'exercise_detail_screen.dart';
import 'patient_book_appointment_screen.dart';
import 'patient_chat_screen.dart';
import 'patient_components.dart';
import 'patient_documents_screen.dart';
import 'patient_notifications_screen.dart';
import 'patient_side_drawer.dart';
import 'program_detail_screen.dart';

/// Screen 7 — Patient Multi-Screen Sliding Dashboard (matching RehabZ design system)
class PatientDashboard extends StatefulWidget {
  const PatientDashboard({
    super.key,
    this.onNavigateTab,
    this.initialSectionIndex = 0,
  });

  final void Function(int index)? onNavigateTab;
  final int initialSectionIndex;

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late PageController _pageController;
  final ScrollController _tabScrollController = ScrollController();
  late int _currentSectionIndex;

  String _userName = 'Patient';
  String _userInitials = 'P';
  int _unreadMessagesCount = 0;

  final List<_SectionMeta> _sections = const [
    _SectionMeta(title: 'Overview', icon: Icons.home_rounded),
    _SectionMeta(title: 'Appointments', icon: Icons.calendar_today_rounded),
    _SectionMeta(title: 'Exercises', icon: Icons.fitness_center_rounded),
    _SectionMeta(title: 'My Progress', icon: Icons.trending_up_rounded),
    _SectionMeta(title: 'Documents', icon: Icons.description_outlined),
    _SectionMeta(title: 'Messages', icon: Icons.chat_bubble_outline_rounded),
    _SectionMeta(title: 'My Program', icon: Icons.assignment_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _currentSectionIndex = widget.initialSectionIndex.clamp(0, _sections.length - 1);
    _pageController = PageController(initialPage: _currentSectionIndex);
    _loadUserProfile();
    _loadUnreadCount();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = await AuthService().getProfile();
      if (!mounted) return;
      setState(() {
        if (user.firstName.isNotEmpty) {
          _userName = user.firstName;
        } else if (user.fullName.isNotEmpty) {
          _userName = user.fullName.split(' ').first;
        }
        _userInitials = _getInitials(user.fullName.isNotEmpty ? user.fullName : _userName);
      });
    } catch (_) {}
  }

  Future<void> _loadUnreadCount() async {
    try {
      final convs = await ChatService().getConversations();
      if (!mounted) return;
      int unread = 0;
      for (final c in convs) {
        unread += c.unreadCount;
      }
      setState(() => _unreadMessagesCount = unread);
    } catch (_) {}
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'P';
  }

  void _navigateToSection(int index) {
    if (index == _currentSectionIndex) return;
    setState(() => _currentSectionIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
    _scrollToTab(index);
  }

  void _scrollToTab(int index) {
    if (!_tabScrollController.hasClients) return;
    const itemWidth = 115.0;
    final targetOffset = (index * itemWidth) - (itemWidth * 0.8);
    _tabScrollController.animateTo(
      targetOffset.clamp(0.0, _tabScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentSectionIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentSectionIndex != 0) {
          _navigateToSection(0);
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: PatientTheme.pageBg,
        drawer: PatientSideDrawer(
          onSelectSection: (index) => _navigateToSection(index),
        ),
        body: Column(
          children: [
            // Top Teal Header + Sliding Section Tabs
            _buildTopHeaderSection(),

            // Smooth Horizontal PageView for 7 Major Sections
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentSectionIndex = index);
                  _scrollToTab(index);
                },
                children: [
                  _OverviewTabView(onNavigateSection: _navigateToSection),
                  const _AppointmentsTabView(),
                  const _ExercisesTabView(),
                  const _ProgressTabView(),
                  const _DocumentsTabView(),
                  const _MessagesTabView(),
                  const _ProgramsTabView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeaderSection() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: PatientTheme.primaryTeal,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App Bar Row (Drawer, Greeting, Notification Bell)
              Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 24),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    tooltip: 'Menu',
                  ),
                  const SizedBox(width: 12),

                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    child: Text(
                      _userInitials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Good morning,',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                        Text(
                          _userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Notification Bell with dynamic badge
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

              // Horizontally Scrollable Section Tabs / Pills
              SizedBox(
                height: 36,
                child: ListView.builder(
                  controller: _tabScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _sections.length,
                  itemBuilder: (context, index) {
                    final isSelected = _currentSectionIndex == index;
                    final meta = _sections[index];
                    final hasBadge = index == 5 && _unreadMessagesCount > 0;

                    return GestureDetector(
                      onTap: () => _navigateToSection(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              meta.icon,
                              size: 15,
                              color: isSelected ? PatientTheme.primaryTeal : Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              meta.title,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected ? PatientTheme.primaryTeal : Colors.white,
                              ),
                            ),
                            if (hasBadge) ...[
                              const SizedBox(width: 5),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEF4444),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$_unreadMessagesCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Page Indicator Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_sections.length, (index) {
                  final isSelected = _currentSectionIndex == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    height: 4,
                    width: isSelected ? 18 : 5,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionMeta {
  const _SectionMeta({required this.title, required this.icon});
  final String title;
  final IconData icon;
}

// ============================================================================
// SECTION 0: OVERVIEW TAB (Executive Summary Hub)
// ============================================================================
class _OverviewTabView extends StatefulWidget {
  const _OverviewTabView({required this.onNavigateSection});

  final void Function(int sectionIndex) onNavigateSection;

  @override
  State<_OverviewTabView> createState() => _OverviewTabViewState();
}

class _OverviewTabViewState extends State<_OverviewTabView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final ExerciseService _exerciseService = ExerciseService();
  final ProgressService _progressService = ProgressService();
  final AppointmentService _appointmentService = AppointmentService();
  final ChatService _chatService = ChatService();

  String _progressFilter = 'This Month';
  AppointmentModel? _upcomingAppointment;
  TodayPlanModel? _todayPlan;
  PatientProgramModel? _activeProgram;
  PatientProgressModel? _progressData;
  int _unreadMessages = 0;

  @override
  void initState() {
    super.initState();
    _loadOverviewData();
  }

  Future<void> _loadOverviewData() async {
    try {
      final appts = await _appointmentService.getAppointments();
      final plan = await _exerciseService.getTodayPlan();
      final progs = await _exerciseService.getMyPrograms();
      final progress = await _progressService.getMyProgress(period: _progressFilter);
      final convs = await _chatService.getConversations();

      if (!mounted) return;

      final now = DateTime.now();
      final todayStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final upcoming = appts
          .where((a) => !a.isCancelled && !a.isCompleted && a.appointmentDate.compareTo(todayStr) >= 0)
          .toList();

      int unread = 0;
      for (final c in convs) {
        unread += c.unreadCount;
      }

      setState(() {
        _upcomingAppointment = upcoming.isNotEmpty ? upcoming.first : null;
        _todayPlan = plan;
        _progressData = progress;
        _activeProgram = progs.isNotEmpty ? progs.first : null;
        _unreadMessages = unread;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return RefreshIndicator(
      color: PatientTheme.primaryTeal,
      onRefresh: _loadOverviewData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Protocol banner if available
            if (_activeProgram != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: PatientTheme.primaryTealLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFC7EDE8)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.assignment_turned_in_rounded, color: PatientTheme.primaryTeal, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Active Protocol: ${_activeProgram!.title}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: PatientTheme.primaryTealDark,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => widget.onNavigateSection(6),
                      child: const Text(
                        'View >',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: PatientTheme.primaryTeal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Upcoming Appointment Card
            PatientCard(
              padding: const EdgeInsets.all(16),
              onTap: () {
                if (_upcomingAppointment != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AppointmentDetailScreen(appointment: _upcomingAppointment),
                    ),
                  );
                } else {
                  widget.onNavigateSection(1);
                }
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
                          style: TextStyle(fontSize: 11, color: PatientTheme.textSecondary, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _upcomingAppointment != null
                              ? '${_upcomingAppointment!.appointmentDate} • ${_upcomingAppointment!.startTime}'
                              : 'No appointment scheduled',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          _upcomingAppointment != null
                              ? '${_upcomingAppointment!.physioName ?? "Dr. Physiotherapist"} • ${_upcomingAppointment!.physioSpecialty ?? "Rehabilitation"}'
                              : 'Tap to book a consultation session',
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
            const SizedBox(height: 14),

            // 3 Quick Metric Cards (Taps jump to respective tabs!)
            Row(
              children: [
                Expanded(
                  child: _buildStatTile(
                    title: "Today's Exercises",
                    value: _todayPlan != null ? '${_todayPlan!.completedExercises}/${_todayPlan!.totalExercises}' : '0/0',
                    subtitle: 'Exercises',
                    color: PatientTheme.primaryTeal,
                    icon: Icons.fitness_center_rounded,
                    onTap: () => widget.onNavigateSection(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatTile(
                    title: 'Messages',
                    value: '$_unreadMessages',
                    subtitle: 'Unread',
                    color: PatientTheme.infoBlue,
                    icon: Icons.chat_bubble_outline_rounded,
                    onTap: () => widget.onNavigateSection(5),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatTile(
                    title: 'Overall Progress',
                    value: _progressData != null ? '${_progressData!.overallPercentage}%' : '0%',
                    subtitle: _progressData?.progressSubtitle ?? 'Improving',
                    color: PatientTheme.successGreen,
                    icon: Icons.trending_up_rounded,
                    onTap: () => widget.onNavigateSection(3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Overall Progress Summary Card
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

                  Center(
                    child: CircularProgressGauge(
                      progress: ((_progressData?.overallPercentage ?? _todayPlan?.progressPercentage ?? 0) / 100.0).clamp(0.0, 1.0),
                      subtitle: _progressData?.progressSubtitle ?? 'Good Progress',
                    ),
                  ),
                  const SizedBox(height: 14),

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
            const SizedBox(height: 18),

            // Weekly Activity Bar Chart
            PatientCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Weekly Activity',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: PatientTheme.textDark,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => widget.onNavigateSection(3),
                        child: const Text(
                          'Detailed Analytics >',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: PatientTheme.primaryTeal),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  WeeklyActivityBarChart(
                    values: _progressData?.exerciseCompliance.weeklyActivity.map((w) => w.completionRate).toList(),
                    days: _progressData?.exerciseCompliance.weeklyActivity.map((w) => w.day).toList() ?? const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Today's Plan Preview
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today's Plan",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: PatientTheme.textDark,
                  ),
                ),
                GestureDetector(
                  onTap: () => widget.onNavigateSection(2),
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

            if (_todayPlan == null || _todayPlan!.exercises.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: PatientTheme.border),
                ),
                child: const Center(
                  child: Text(
                    'No exercises assigned for today.',
                    style: TextStyle(color: PatientTheme.textSecondary, fontSize: 13),
                  ),
                ),
              )
            else
              ..._todayPlan!.exercises.take(3).map((ex) {
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
                    ).then((_) => _loadOverviewData());
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
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile({
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

// ============================================================================
// SECTION 1: APPOINTMENTS TAB
// ============================================================================
class _AppointmentsTabView extends StatefulWidget {
  const _AppointmentsTabView();

  @override
  State<_AppointmentsTabView> createState() => _AppointmentsTabViewState();
}

class _AppointmentsTabViewState extends State<_AppointmentsTabView>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  late TabController _subTabController;
  bool _isLoading = true;
  List<AppointmentModel> _allAppointments = [];

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 2, vsync: this);
    _fetchAppointments();
  }

  @override
  void dispose() {
    _subTabController.dispose();
    super.dispose();
  }

  Future<void> _fetchAppointments() async {
    try {
      final list = await AppointmentService().getAppointments();
      if (!mounted) return;
      setState(() {
        _allAppointments = list;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<AppointmentModel> get _upcomingAppointments {
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return _allAppointments.where((a) {
      if (a.isCancelled || a.isCompleted) return false;
      return a.appointmentDate.compareTo(todayStr) >= 0;
    }).toList();
  }

  List<AppointmentModel> get _pastAppointments {
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return _allAppointments.where((a) {
      if (a.isCancelled || a.isCompleted) return true;
      return a.appointmentDate.compareTo(todayStr) < 0;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: PatientTheme.pageBg,
      body: Column(
        children: [
          // Sub Tab Bar (Upcoming / Past)
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _subTabController,
              labelColor: PatientTheme.primaryTeal,
              unselectedLabelColor: PatientTheme.textSecondary,
              indicatorColor: PatientTheme.primaryTeal,
              indicatorWeight: 2.5,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              tabs: const [
                Tab(text: 'Upcoming'),
                Tab(text: 'Past'),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: PatientTheme.primaryTeal))
                : RefreshIndicator(
                    color: PatientTheme.primaryTeal,
                    onRefresh: _fetchAppointments,
                    child: TabBarView(
                      controller: _subTabController,
                      children: [
                        _buildAppointmentsList(_upcomingAppointments, isUpcoming: true),
                        _buildAppointmentsList(_pastAppointments, isUpcoming: false),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PatientBookAppointmentScreen()),
          ).then((_) => _fetchAppointments());
        },
        backgroundColor: PatientTheme.primaryTeal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text('Book Appointment', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildAppointmentsList(List<AppointmentModel> appointments, {required bool isUpcoming}) {
    if (appointments.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.event_busy_rounded,
                  size: 48,
                  color: PatientTheme.textMuted.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  isUpcoming ? 'No upcoming appointments.' : 'No past appointments found.',
                  style: const TextStyle(color: PatientTheme.textSecondary, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 80),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final a = appointments[index];
        return PatientCard(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => AppointmentDetailScreen(appointment: a)),
            ).then((_) => _fetchAppointments());
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: PatientTheme.primaryTealLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.medical_services_outlined,
                      color: PatientTheme.primaryTeal,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.physioName ?? 'Physiotherapist Consultation',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: PatientTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          a.physioSpecialty ?? 'Rehabilitation Therapy',
                          style: const TextStyle(fontSize: 11.5, color: PatientTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(
                    label: a.status.toUpperCase(),
                    isCompleted: a.isCompleted,
                    isPending: a.isPending,
                  ),
                ],
              ),
              const Divider(height: 20, color: PatientTheme.border),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 14, color: PatientTheme.textSecondary),
                      const SizedBox(width: 5),
                      Text(
                        a.appointmentDate,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PatientTheme.textDark),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 14, color: PatientTheme.textSecondary),
                      const SizedBox(width: 5),
                      Text(
                        '${a.startTime} (${a.duration})',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PatientTheme.textDark),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================================
// SECTION 2: EXERCISES TAB
// ============================================================================
class _ExercisesTabView extends StatefulWidget {
  const _ExercisesTabView();

  @override
  State<_ExercisesTabView> createState() => _ExercisesTabViewState();
}

class _ExercisesTabViewState extends State<_ExercisesTabView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final ExerciseService _exerciseService = ExerciseService();
  int _selectedFilter = 0; // 0: All, 1: Pending, 2: Completed
  bool _isLoading = true;
  List<PatientExerciseAssignmentModel> _exercises = [];

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  Future<void> _loadPlan() async {
    try {
      final plan = await _exerciseService.getTodayPlan();
      if (!mounted) return;
      setState(() {
        _exercises = plan.exercises;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<PatientExerciseAssignmentModel> get _filteredExercises {
    if (_selectedFilter == 1) {
      return _exercises.where((e) => !e.isCompletedToday).toList();
    } else if (_selectedFilter == 2) {
      return _exercises.where((e) => e.isCompletedToday).toList();
    }
    return _exercises;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: PatientTheme.primaryTeal));
    }

    final completedCount = _exercises.where((e) => e.isCompletedToday).length;
    final totalCount = _exercises.length;
    final progress = totalCount > 0 ? (completedCount / totalCount) : 0.0;

    return RefreshIndicator(
      color: PatientTheme.primaryTeal,
      onRefresh: _loadPlan,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
        children: [
          // Target Progress Card
          PatientCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Today's Exercise Target",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
                    ),
                    Text(
                      '$completedCount / $totalCount Completed',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: PatientTheme.primaryTeal),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(PatientTheme.primaryTeal),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Filter Chips
          Row(
            children: [
              _buildFilterChip('All (${_exercises.length})', 0),
              const SizedBox(width: 8),
              _buildFilterChip('Pending (${totalCount - completedCount})', 1),
              const SizedBox(width: 8),
              _buildFilterChip('Completed ($completedCount)', 2),
            ],
          ),
          const SizedBox(height: 14),

          // Exercise List
          if (_filteredExercises.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              child: const Center(
                child: Text(
                  'No exercises found for this filter.',
                  style: TextStyle(color: PatientTheme.textSecondary, fontSize: 13),
                ),
              ),
            )
          else
            ..._filteredExercises.map((ex) {
              final isDone = ex.isCompletedToday;
              return PatientCard(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
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
                  ).then((_) => _loadPlan());
                },
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDone ? PatientTheme.successGreenBg : PatientTheme.primaryTealLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.fitness_center_rounded,
                        color: isDone ? PatientTheme.successGreen : PatientTheme.primaryTeal,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ex.exerciseTitle,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${ex.bodyPart} • ${ex.sets} sets x ${ex.reps} reps',
                            style: const TextStyle(fontSize: 11.5, color: PatientTheme.textSecondary),
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
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? PatientTheme.primaryTeal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? PatientTheme.primaryTeal : PatientTheme.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : PatientTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SECTION 3: MY PROGRESS TAB (Detailed Phase 4 Analytics)
// ============================================================================
class _ProgressTabView extends StatefulWidget {
  const _ProgressTabView();

  @override
  State<_ProgressTabView> createState() => _ProgressTabViewState();
}

class _ProgressTabViewState extends State<_ProgressTabView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final ProgressService _progressService = ProgressService();
  String _selectedPeriod = 'this_month';
  bool _isLoading = true;
  PatientProgressModel? _progressData;

  final Map<String, String> _periods = {
    'this_week': 'This Week',
    'this_month': 'This Month',
    'three_months': '3 Months',
    'all_time': 'All Time',
  };

  @override
  void initState() {
    super.initState();
    _fetchProgress();
  }

  Future<void> _fetchProgress() async {
    try {
      final data = await _progressService.getMyProgress(period: _selectedPeriod);
      if (!mounted) return;
      setState(() {
        _progressData = data;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: PatientTheme.primaryTeal));
    }

    final data = _progressData ?? PatientProgressModel.empty('me');

    return RefreshIndicator(
      color: PatientTheme.primaryTeal,
      onRefresh: _fetchProgress,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _periods.entries.map((e) {
                  final isSelected = _selectedPeriod == e.key;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(e.value),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedPeriod = e.key;
                            _isLoading = true;
                          });
                          _fetchProgress();
                        }
                      },
                      selectedColor: PatientTheme.primaryTeal,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : PatientTheme.textDark,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 12,
                      ),
                      backgroundColor: Colors.white,
                      side: BorderSide(color: isSelected ? PatientTheme.primaryTeal : PatientTheme.border),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // Overall Progress Gauge Card
            PatientCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('Overall Recovery Progress', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: PatientTheme.textDark)),
                  const SizedBox(height: 16),
                  CircularProgressGauge(
                    progress: (data.overallPercentage / 100.0).clamp(0.0, 1.0),
                    subtitle: data.progressSubtitle,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _BreakdownPill(label: 'Completed', value: '${data.completedCount}', color: PatientTheme.successGreen),
                      _BreakdownPill(label: 'In Progress', value: '${data.inProgressCount}', color: PatientTheme.infoBlue),
                      _BreakdownPill(label: 'Pending', value: '${data.pendingCount}', color: PatientTheme.warningOrange),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Progress Over Time Chart
            PatientCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Progress Over Time', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: PatientTheme.textDark)),
                  const SizedBox(height: 16),
                  ProgressLineChart(
                    values: data.progressOverTime.map((p) => p.value).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Weekly Consistency Chart
            PatientCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Weekly Consistency', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: PatientTheme.textDark)),
                      Text('${data.adherencePercentage}% Adherence', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: PatientTheme.primaryTeal)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  WeeklyActivityBarChart(
                    values: data.exerciseCompliance.weeklyActivity.map((w) => w.completionRate).toList(),
                    days: data.exerciseCompliance.weeklyActivity.map((w) => w.day).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Pain Trend & ROM Trend Card
            if (data.painTrend.isNotEmpty || data.romTrend.isNotEmpty)
              PatientCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Clinical Pain & Mobility Trends', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: PatientTheme.textDark)),
                    const SizedBox(height: 12),
                    if (data.painTrend.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Pain Level Trend:', style: TextStyle(fontSize: 12.5, color: PatientTheme.textSecondary)),
                          Text(
                            '${data.painTrend.first.painLevel}/10 -> ${data.painTrend.last.painLevel}/10 (Reduced)',
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: PatientTheme.successGreen),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (data.romTrend.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Active ROM Flexion:', style: TextStyle(fontSize: 12.5, color: PatientTheme.textSecondary)),
                          Text(
                            data.romTrend.last.flexion,
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: PatientTheme.primaryTeal),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// SECTION 4: DOCUMENTS TAB (Vault & PDF Invoices)
// ============================================================================
class _DocumentsTabView extends StatefulWidget {
  const _DocumentsTabView();

  @override
  State<_DocumentsTabView> createState() => _DocumentsTabViewState();
}

class _DocumentsTabViewState extends State<_DocumentsTabView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final DocumentService _documentService = DocumentService();
  String _selectedCategory = 'All';
  bool _isLoading = true;
  List<DocumentModel> _documents = [];

  final List<String> _categories = [
    'All',
    'Report',
    'Prescription',
    'Scan',
    'Bill',
  ];

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    try {
      final list = await _documentService.getMyDocuments();
      if (!mounted) return;
      setState(() {
        _documents = list;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<DocumentModel> get _filteredDocuments {
    if (_selectedCategory == 'All') return _documents;
    return _documents
        .where((d) => d.category.toLowerCase().contains(_selectedCategory.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: PatientTheme.primaryTeal));
    }

    return Scaffold(
      backgroundColor: PatientTheme.pageBg,
      body: Column(
        children: [
          // Filter Chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat == 'All' ? 'All Files' : cat),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedCategory = cat);
                      },
                      selectedColor: PatientTheme.primaryTeal,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : PatientTheme.textDark,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 12,
                      ),
                      backgroundColor: PatientTheme.inputBg,
                      side: BorderSide(color: isSelected ? PatientTheme.primaryTeal : PatientTheme.border),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              color: PatientTheme.primaryTeal,
              onRefresh: _loadDocuments,
              child: _filteredDocuments.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 80),
                        Center(
                          child: Text(
                            'No documents found.',
                            style: TextStyle(color: PatientTheme.textSecondary, fontSize: 14),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 80),
                      itemCount: _filteredDocuments.length,
                      itemBuilder: (context, index) {
                        final doc = _filteredDocuments[index];
                        return PatientCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: PatientTheme.primaryTealLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.picture_as_pdf_rounded, color: PatientTheme.primaryTeal, size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doc.fileName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${doc.category} • ${doc.dateFormatted} • ${doc.fileSizeFormatted}',
                                      style: const TextStyle(fontSize: 11.5, color: PatientTheme.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.download_rounded, color: PatientTheme.primaryTeal, size: 22),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Downloading ${doc.fileName}...')),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PatientDocumentsScreen()),
          ).then((_) => _loadDocuments());
        },
        backgroundColor: PatientTheme.primaryTeal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.upload_file_rounded, size: 20),
        label: const Text('Upload Document', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// ============================================================================
// SECTION 5: MESSAGES TAB (Real-Time Conversations)
// ============================================================================
class _MessagesTabView extends StatefulWidget {
  const _MessagesTabView();

  @override
  State<_MessagesTabView> createState() => _MessagesTabViewState();
}

class _MessagesTabViewState extends State<_MessagesTabView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final ChatService _chatService = ChatService();
  bool _isLoading = true;
  List<ConversationModel> _conversations = [];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    try {
      final list = await _chatService.getConversations();
      if (!mounted) return;
      setState(() {
        _conversations = list;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: PatientTheme.primaryTeal));
    }

    return RefreshIndicator(
      color: PatientTheme.primaryTeal,
      onRefresh: _loadConversations,
      child: _conversations.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 80),
                Center(
                  child: Text(
                    'No active conversations yet.',
                    style: TextStyle(color: PatientTheme.textSecondary, fontSize: 14),
                  ),
                ),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
              itemCount: _conversations.length,
              itemBuilder: (context, index) {
                final c = _conversations[index];
                return PatientCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PatientChatScreen()),
                    ).then((_) => _loadConversations());
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: PatientTheme.primaryTealLight,
                        child: const Icon(Icons.person_rounded, color: PatientTheme.primaryTeal, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  c.physiotherapistName.isNotEmpty ? c.physiotherapistName : 'Dr. Physiotherapist',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
                                ),
                                Text(
                                  c.timeFormatted,
                                  style: const TextStyle(fontSize: 11, color: PatientTheme.textSecondary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              c.lastMessageContent.isNotEmpty ? c.lastMessageContent : 'Tap to start conversation',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: c.unreadCount > 0 ? PatientTheme.textDark : PatientTheme.textSecondary,
                                fontWeight: c.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (c.unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: PatientTheme.primaryTeal,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${c.unreadCount}',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}

// ============================================================================
// SECTION 6: MY PROGRAM TAB (Treatment Protocols & Progression)
// ============================================================================
class _ProgramsTabView extends StatefulWidget {
  const _ProgramsTabView();

  @override
  State<_ProgramsTabView> createState() => _ProgramsTabViewState();
}

class _ProgramsTabViewState extends State<_ProgramsTabView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final ExerciseService _exerciseService = ExerciseService();
  bool _isLoading = true;
  List<PatientProgramModel> _programs = [];

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  Future<void> _loadPrograms() async {
    try {
      final list = await _exerciseService.getMyPrograms();
      if (!mounted) return;
      setState(() {
        _programs = list;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: PatientTheme.primaryTeal));
    }

    return RefreshIndicator(
      color: PatientTheme.primaryTeal,
      onRefresh: _loadPrograms,
      child: _programs.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 80),
                Center(
                  child: Text(
                    'No active treatment programs prescribed yet.',
                    style: TextStyle(color: PatientTheme.textSecondary, fontSize: 14),
                  ),
                ),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
              itemCount: _programs.length,
              itemBuilder: (context, index) {
                final prog = _programs[index];
                final pct = prog.progressPercentage / 100.0;

                return PatientCard(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ProgramDetailScreen(program: prog)),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              prog.title,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
                            ),
                          ),
                          StatusBadge(
                            label: prog.status.toUpperCase(),
                            isCompleted: prog.progressPercentage >= 100,
                            isInProgress: prog.isActive,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Condition: ${prog.condition}',
                        style: const TextStyle(fontSize: 12, color: PatientTheme.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Phase: ${prog.phases.isNotEmpty ? prog.phases.first.name : "Phase 1: Recovery"}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PatientTheme.primaryTeal)),
                          Text('${prog.progressPercentage}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: PatientTheme.textDark)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: pct.clamp(0.0, 1.0),
                          backgroundColor: const Color(0xFFE2E8F0),
                          valueColor: const AlwaysStoppedAnimation<Color>(PatientTheme.primaryTeal),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                );
              },
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

