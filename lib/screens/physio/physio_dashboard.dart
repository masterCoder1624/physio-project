import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/patient_service.dart';
import 'add_patient_screen.dart';
import 'calendar_screen.dart';
import 'patient_detail_screen.dart';
import 'patient_list_screen.dart';
import 'profile_screen.dart';
import 'physio_navigation.dart';
import 'physio_main_shell.dart';
import '../auth/login_screen.dart';

// Physio frontend theme — keep backend/API files untouched.
const Color kPrimaryCyan = Color(0xFF00AFC1);
const Color kDarkCyan = Color(0xFF008C9E);
const Color kLightCyan = Color(0xFFE8F9FB);
const Color kPageBackground = Color(0xFFF7FAFC);
const Color kCardBackground = Colors.white;
const Color kTextPrimary = Color(0xFF123047);
const Color kTextSecondary = Color(0xFF64748B);
const Color kBorder = Color(0xFFE5EEF2);
const Color kSuccess = Color(0xFF22C55E);
const Color kWarning = Color(0xFFF59E0B);
const Color kError = Color(0xFFEF4444);

// Kept for compatibility with any existing references in the project.
const Color kPrimaryBlue = kPrimaryCyan;
const Color kPrimaryTeal = kDarkCyan;
const Color kCoral = Color(0xFFFF6B4A);

class PhysioDashboard extends StatefulWidget {
  const PhysioDashboard({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<PhysioDashboard> createState() => _PhysioDashboardState();
}

class _PhysioDashboardState extends State<PhysioDashboard> {
  bool _isLoading = true;
  String? _errorMessage;

  String _physioName = 'Dr. Alex';
  String _specialty = 'Sports & Orthopedic Physiotherapy';
  int _todayPatientsCount = 0;
  int _pendingBookingsCount = 0;
  int _completedThisWeek = 0;
  double _monthlyRevenue = 0;
  List<DashboardPatient> _todayPatients = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Start both reads together so the dashboard does not wait for them one-by-one.
      final userFuture = AuthService().getProfile();
      final patientsFuture = PatientService().getPatients();
      final user = await userFuture;
      final patientModels = await patientsFuture;

      final dashboardPatients = patientModels.map((p) {
        return DashboardPatient(
          id: p.id ?? '',
          name: p.name,
          condition: p.condition,
          phone: p.phone ?? 'No number',
          time: '10:00 AM',
          status: 'CONFIRMED',
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _physioName = user.fullName.isNotEmpty ? user.fullName : 'Dr. Alex';
        _specialty = 'Sports & Orthopedic Physiotherapy';
        _todayPatientsCount = dashboardPatients.length;
        _todayPatients = dashboardPatients;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load your dashboard. Please try again.';
      });
    }
  }

  Future<void> _refreshDashboard() => _loadDashboardData();

  Future<void> _signOut() async {
    await AuthService().logout();
    if (!mounted) return;
    await PhysioNavigation.pushAndClear(context, const LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.embedded) {
      return const PhysioMainShell();
    }

    return PhysioSystemUi(
      statusBarColor: kDarkCyan,
      statusBarBrightness: Brightness.dark,
      child: Scaffold(
      backgroundColor: kPageBackground,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: kPrimaryCyan,
          backgroundColor: Colors.white,
          onRefresh: _refreshDashboard,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                sliver: SliverToBoxAdapter(
                  child: _isLoading
                      ? _buildLoadingState()
                      : _errorMessage != null
                          ? _buildErrorState()
                          : _buildDashboardContent(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const ValueKey('fab'),
        onPressed: _openAddPatient,
        backgroundColor: kPrimaryCyan,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: widget.embedded ? null : _buildBottomNavigationBar(),
    ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryCyan, kDarkCyan],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _headerIconButton(
                icon: Icons.menu_rounded,
                onTap: () {},
              ),
              const Spacer(),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _headerIconButton(
                    icon: Icons.notifications_none_rounded,
                    onTap: () {},
                  ),
                  Positioned(
                    right: 2,
                    top: 0,
                    child: Container(
                      width: 19,
                      height: 19,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: kError,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '3',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildProfileAvatar(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Good morning,',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _displayPhysioName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _specialty,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                _formatDate(DateTime.now()),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String get _displayPhysioName {
    if (_physioName.trim().isEmpty) return 'Dr. Alex';
    return _physioName.startsWith('Dr.') ? _physioName : 'Dr. $_physioName';
  }

  Widget _headerIconButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white.withValues(alpha: 0.12),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, color: Colors.white, size: 21),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundColor: kLightCyan,
        child: Text(
          _getInitials(_physioName),
          style: const TextStyle(
            color: kDarkCyan,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatsSection(),
        const SizedBox(height: 22),
        _buildSectionHeader('Today\'s Schedule', 'See all', () {
          _navigateTo(const CalendarScreen());
        }),
        const SizedBox(height: 10),
        _buildScheduleCard(),
        const SizedBox(height: 22),
        _buildSectionHeader('Needs Attention', 'See all', () {}),
        const SizedBox(height: 10),
        _buildAttentionCard(),
        const SizedBox(height: 22),
        const Text(
          'Quick Actions',
          style: TextStyle(
            color: kTextPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        _buildQuickActions(),
        const SizedBox(height: 22),
        _buildSectionHeader('Overview', 'This Month', () {}),
        const SizedBox(height: 10),
        _buildOverviewCard(),
      ],
    );
  }

  Widget _buildStatsSection() {
    final stats = [
      _DashboardStat(
        icon: Icons.people_alt_outlined,
        title: 'Patients Today',
        value: '$_todayPatientsCount',
        change: '+ 3 new',
        iconBackground: const Color(0xFFE7F8FA),
        iconColor: kPrimaryCyan,
        changeColor: kSuccess,
      ),
      _DashboardStat(
        icon: Icons.event_available_outlined,
        title: 'Sessions Today',
        value: '$_completedThisWeek',
        change: '↑ 2 completed',
        iconBackground: const Color(0xFFEAF9F3),
        iconColor: kSuccess,
        changeColor: kSuccess,
      ),
      _DashboardStat(
        icon: Icons.bookmark_border_rounded,
        title: 'Pending Bookings',
        value: '$_pendingBookingsCount',
        change: 'Awaiting',
        iconBackground: const Color(0xFFFFF4E5),
        iconColor: kWarning,
        changeColor: kWarning,
      ),
      _DashboardStat(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Revenue (This Month)',
        value: _formatRevenue(_monthlyRevenue),
        change: '↑ 12%',
        iconBackground: const Color(0xFFE8F4FF),
        iconColor: const Color(0xFF3B82F6),
        changeColor: kSuccess,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 700 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: constraints.maxWidth >= 700 ? 1.55 : 1.28,
          ),
          itemBuilder: (_, index) => StatCard(stat: stats[index]),
        );
      },
    );
  }

  Widget _buildScheduleCard() {
    final patients = _todayPatients.take(3).toList();
    final fallback = [
      const DashboardPatient(
        id: '',
        name: 'No appointments yet',
        condition: 'Your schedule will appear here',
        phone: '',
        time: '--:--',
        status: 'UPCOMING',
      ),
    ];
    final rows = patients.isEmpty ? fallback : patients;
    final times = ['09:00 AM', '10:00 AM', '11:30 AM'];
    final durations = ['30 min', '45 min', '30 min'];

    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          for (var index = 0; index < rows.length; index++) ...[
            _ScheduleRow(
              patient: rows[index],
              time: patients.isEmpty ? rows[index].time : times[index],
              duration: patients.isEmpty ? '' : durations[index],
              status: patients.isEmpty ? 'UPCOMING' : index == 2 ? 'PENDING' : 'CONFIRMED',
              onTap: rows[index].id.isEmpty
                  ? null
                  : () => _navigateTo(
                        PatientDetailScreen(patientId: rows[index].id, initialTabIndex: 0),
                      ),
            ),
            if (index < rows.length - 1) const Divider(height: 1, indent: 72, endIndent: 12, color: kBorder),
          ],
        ],
      ),
    );
  }

  Widget _buildAttentionCard() {
    final patients = _todayPatients.take(2).toList();
    final items = <_AttentionItem>[];

    if (patients.isNotEmpty) {
      items.add(
        _AttentionItem(
          icon: Icons.trending_up_rounded,
          iconColor: kError,
          title: patients.first.name,
          subtitle: 'Review patient progress',
          action: 'Review',
          actionColor: kError,
          onTap: () => _navigateTo(
            PatientDetailScreen(patientId: patients.first.id, initialTabIndex: 0),
          ),
        ),
      );
    }

    if (patients.length > 1) {
      items.add(
        _AttentionItem(
          icon: Icons.priority_high_rounded,
          iconColor: kWarning,
          title: patients[1].name,
          subtitle: 'Check exercise adherence',
          action: 'View',
          actionColor: kWarning,
          onTap: () => _navigateTo(
            PatientDetailScreen(patientId: patients[1].id, initialTabIndex: 1),
          ),
        ),
      );
    }

    if (items.isEmpty) {
      items.add(
        const _AttentionItem(
          icon: Icons.check_circle_outline_rounded,
          iconColor: kSuccess,
          title: 'All caught up',
          subtitle: 'No urgent items need your attention.',
          action: '',
          actionColor: kSuccess,
        ),
      );
    }

    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            items[index],
            if (index < items.length - 1) const Divider(height: 1, indent: 58, endIndent: 12, color: kBorder),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      _QuickAction(
        icon: Icons.person_add_alt_1_rounded,
        label: 'Add Patient',
        color: kPrimaryCyan,
        onTap: _openAddPatient,
      ),
      _QuickAction(
        icon: Icons.calendar_month_outlined,
        label: 'New Appointment',
        color: const Color(0xFF3B82F6),
        onTap: () => _navigateTo(const CalendarScreen()),
      ),
      _QuickAction(
        icon: Icons.accessibility_new_rounded,
        label: 'Start Session',
        color: kSuccess,
        onTap: () {
          if (_todayPatients.isNotEmpty) {
            _navigateTo(
              PatientDetailScreen(patientId: _todayPatients.first.id, initialTabIndex: 1),
            );
          } else {
            _showComingSoon('Start Session');
          }
        },
      ),
      _QuickAction(
        icon: Icons.note_add_outlined,
        label: 'Add Note',
        color: const Color(0xFF8B5CF6),
        onTap: () {
          if (_todayPatients.isNotEmpty) {
            _navigateTo(
              PatientDetailScreen(patientId: _todayPatients.first.id, initialTabIndex: 1),
            );
          } else {
            _showComingSoon('Add Note');
          }
        },
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 700 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: constraints.maxWidth >= 700 ? 1.6 : 1.45,
          ),
          itemBuilder: (_, index) => actions[index],
        );
      },
    );
  }

  Widget _buildOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: _OverviewMetric(
              icon: Icons.people_alt_outlined,
              label: 'Total Patients',
              value: '${_todayPatientsCount * 7}',
              change: '↑ 18%',
              color: kPrimaryCyan,
            ),
          ),
          _verticalDivider(),
          Expanded(
            child: _OverviewMetric(
              icon: Icons.check_circle_outline_rounded,
              label: 'Completed Sessions',
              value: '$_completedThisWeek',
              change: '↑ 15%',
              color: kSuccess,
            ),
          ),
          _verticalDivider(),
          Expanded(
            child: _OverviewMetric(
              icon: Icons.currency_rupee_rounded,
              label: 'Revenue',
              value: _formatRevenue(_monthlyRevenue),
              change: '↑ 12%',
              color: kWarning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(width: 1, height: 58, color: kBorder, margin: const EdgeInsets.symmetric(horizontal: 8));
  }

  Widget _buildSectionHeader(String title, String action, VoidCallback onTap) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: kTextPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: kPrimaryCyan,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            action,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(
        4,
        (index) => Container(
          height: index == 0 ? 130 : 72,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.cloud_off_rounded, color: kError, size: 32),
          ),
          const SizedBox(height: 12),
          const Text(
            'Could not load dashboard',
            style: TextStyle(color: kTextPrimary, fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            _errorMessage ?? 'Something went wrong. Please try again.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: kTextSecondary, fontSize: 13),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _loadDashboardData,
            style: FilledButton.styleFrom(backgroundColor: kPrimaryCyan),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }

  NavigationBar _buildBottomNavigationBar() {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onNavigationTapped,
      backgroundColor: Colors.white,
      elevation: 10,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      indicatorColor: kLightCyan,
      labelTextStyle: const WidgetStatePropertyAll(
        TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined, color: kTextSecondary),
          selectedIcon: Icon(Icons.home_rounded, color: kPrimaryCyan),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_outline_rounded, color: kTextSecondary),
          selectedIcon: Icon(Icons.people_rounded, color: kPrimaryCyan),
          label: 'Patients',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_today_outlined, color: kTextSecondary),
          selectedIcon: Icon(Icons.calendar_today_rounded, color: kPrimaryCyan),
          label: 'Calendar',
        ),
        NavigationDestination(
          icon: Icon(Icons.insights_outlined, color: kTextSecondary),
          selectedIcon: Icon(Icons.insights_rounded, color: kPrimaryCyan),
          label: 'Analytics',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded, color: kTextSecondary),
          selectedIcon: Icon(Icons.person_rounded, color: kPrimaryCyan),
          label: 'Profile',
        ),
      ],
    );
  }

  void _onNavigationTapped(int index) {
    if (index == 0) {
      setState(() => _selectedIndex = 0);
      return;
    }

    final Widget? page = switch (index) {
      1 => const PatientListScreen(),
      2 => const CalendarScreen(),
      4 => const ProfileScreen(),
      _ => null,
    };

    if (page == null) {
      setState(() => _selectedIndex = index);
      return;
    }

    setState(() => _selectedIndex = index);
    PhysioNavigation.replace(context, page);
  }

  void _navigateTo(Widget screen) async {
    await PhysioNavigation.push(context, screen);
    if (mounted) setState(() => _selectedIndex = 0);
  }

  Future<void> _openAddPatient() async {
    final patientWasAdded = await PhysioNavigation.push<bool>(context, const AddPatientScreen());
    if (patientWasAdded == true) await _refreshDashboard();
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature is ready for the next frontend phase.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: kTextPrimary,
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: kCardBackground,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: kBorder),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF123047).withValues(alpha: 0.045),
          blurRadius: 16,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    final clean = name.trim();
    if (clean.isEmpty) return 'DR';
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length > 1 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String _formatRevenue(double value) {
    if (value >= 1000) return '₹${(value / 1000).toStringAsFixed(1)}k';
    return '₹${value.toStringAsFixed(0)}';
  }

  String _formatDate(DateTime date) {
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _DashboardStat {
  const _DashboardStat({
    required this.icon,
    required this.title,
    required this.value,
    required this.change,
    required this.iconBackground,
    required this.iconColor,
    required this.changeColor,
  });

  final IconData icon;
  final String title;
  final String value;
  final String change;
  final Color iconBackground;
  final Color iconColor;
  final Color changeColor;
}

class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.stat});

  final _DashboardStat stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF123047).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: stat.iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(stat.icon, color: stat.iconColor, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stat.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: kTextPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                stat.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: kTextSecondary,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                stat.change,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: stat.changeColor,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({
    required this.patient,
    required this.time,
    required this.duration,
    required this.status,
    required this.onTap,
  });

  final DashboardPatient patient;
  final String time;
  final String duration;
  final String status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final timeParts = time.split(' ');
    final statusColor = status == 'PENDING' ? kWarning : kSuccess;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 50,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: kPrimaryCyan,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Column(
                children: [
                  Text(
                    timeParts.isNotEmpty ? timeParts[0] : '--',
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                  if (timeParts.length > 1)
                    Text(
                      timeParts[1],
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 19,
              backgroundColor: kLightCyan,
              child: Text(
                patient.initials,
                style: const TextStyle(color: kDarkCyan, fontSize: 11, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: kTextPrimary, fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    patient.condition,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: kTextSecondary, fontSize: 11),
                  ),
                  if (duration.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.schedule_rounded, size: 11, color: kTextSecondary),
                        const SizedBox(width: 3),
                        Text(duration, style: const TextStyle(color: kTextSecondary, fontSize: 10)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 6),
            if (status.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  status.toLowerCase().capitalize(),
                  style: TextStyle(color: statusColor, fontSize: 9.5, fontWeight: FontWeight.w800),
                ),
              ),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, color: kTextSecondary, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}

class _AttentionItem extends StatelessWidget {
  const _AttentionItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.action,
    required this.actionColor,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String action;
  final Color actionColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 19),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: kTextPrimary, fontSize: 12.5, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: const TextStyle(color: kTextSecondary, fontSize: 10.5)),
                ],
              ),
            ),
            if (action.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: actionColor.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(action, style: TextStyle(color: actionColor, fontSize: 9.5, fontWeight: FontWeight.w800)),
              ),
            const SizedBox(width: 3),
            const Icon(Icons.chevron_right_rounded, color: kTextSecondary, size: 19),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kBorder),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF123047).withValues(alpha: 0.035),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 21),
              ),
              const SizedBox(height: 7),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: kTextPrimary, fontSize: 10.5, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewMetric extends StatelessWidget {
  const _OverviewMetric({required this.icon, required this.label, required this.value, required this.change, required this.color});

  final IconData icon;
  final String label;
  final String value;
  final String change;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.10), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 17),
        ),
        const SizedBox(height: 7),
        Text(label, maxLines: 2, style: const TextStyle(color: kTextSecondary, fontSize: 9.5, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: kTextPrimary, fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(change, style: const TextStyle(color: kSuccess, fontSize: 9, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class DashboardPatient {
  const DashboardPatient({
    required this.id,
    required this.name,
    required this.condition,
    required this.phone,
    required this.time,
    required this.status,
  });

  final String id;
  final String name;
  final String condition;
  final String phone;
  final String time;
  final String status;

  String get initials {
    final clean = name.trim();
    if (clean.isEmpty) return 'P';
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length > 1 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More Options'),
        backgroundColor: kPrimaryCyan,
        foregroundColor: Colors.white,
      ),
      body: const Center(child: Text('Clinic Settings & Reports')),
    );
  }
}

extension _StringCapitalization on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
