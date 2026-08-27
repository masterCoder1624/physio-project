import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../../services/patient_service.dart';
import 'calendar_screen.dart';
import 'patient_detail_screen.dart';
import 'patient_list_screen.dart';
import 'physio_messages_screen.dart';
import 'profile_screen.dart';
import 'physio_navigation.dart';
import 'physio_main_shell.dart';
import '../auth/login_screen.dart';

// PhysioSoft frontend theme — unchanged.
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
  final int _pendingBookingsCount = 0;
  final int _completedThisWeek = 0;
  int _unreadMessagesCount = 0;
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
      final userFuture = AuthService().getProfile();
      final patientsFuture = PatientService().getPatients();
      final unreadFuture = ChatService().getUnreadCount();
      final user = await userFuture;
      final patientModels = await patientsFuture;
      final unread = await unreadFuture;

      final patients = patientModels.map((p) => DashboardPatient(
        id: p.id ?? '',
        name: p.name,
        condition: p.condition,
        phone: p.phone ?? 'No number',
        time: '10:00 AM',
        status: 'CONFIRMED',
      )).toList();

      if (!mounted) return;
      setState(() {
        _physioName = user.fullName.isNotEmpty ? user.fullName : 'Dr. Alex';
        _specialty = 'Sports & Orthopedic Physiotherapy';
        _todayPatientsCount = patients.length;
        _todayPatients = patients;
        _unreadMessagesCount = unread;
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
    if (!widget.embedded) return const PhysioMainShell();

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
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
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
              _headerIconButton(Icons.menu_rounded, () {}),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('PhysioSoft', style: TextStyle(
                  color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800,
                )),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _headerIconButton(
                    Icons.chat_bubble_outline_rounded,
                    () => _navigateTo(const PhysioMessagesScreen()),
                  ),
                  if (_unreadMessagesCount > 0)
                    Positioned(
                      right: 0,
                      top: -1,
                      child: Container(
                        width: 19,
                        height: 19,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: kCoral,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$_unreadMessagesCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _headerIconButton(Icons.notifications_none_rounded, () {}),
                  Positioned(
                    right: 0, top: -1,
                    child: Container(
                      width: 19, height: 19,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(color: kError, shape: BoxShape.circle),
                      child: const Text('3', style: TextStyle(
                        color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800,
                      )),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildProfileAvatar(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Good morning,', style: TextStyle(
                      color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500,
                    )),
                    const SizedBox(height: 3),
                    Text(_displayPhysioName, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800,
                      )),
                    const SizedBox(height: 4),
                    Text(_specialty, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70, fontSize: 12)),
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
              Text(_formatDate(DateTime.now()), style: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600,
              )),
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

  Widget _headerIconButton(IconData icon, VoidCallback onTap) {
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
    return InkWell(
      onTap: _signOut,
      customBorder: const CircleBorder(),
      child: Container(
        width: 68, height: 68,
        decoration: BoxDecoration(
          color: Colors.white, shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: .8), width: 3),
          boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: .12), blurRadius: 12, offset: const Offset(0, 5),
          )],
        ),
        child: CircleAvatar(
          backgroundColor: kLightCyan,
          child: Text(_getInitials(_physioName), style: const TextStyle(
            color: kDarkCyan, fontSize: 21, fontWeight: FontWeight.w800,
          )),
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTodayOverview(),
        const SizedBox(height: 16),
        _buildNextPatientCard(),
        const SizedBox(height: 22),
        _sectionHeader('Today\'s Schedule', 'View all', () => _navigateTo(const CalendarScreen())),
        const SizedBox(height: 10),
        _buildScheduleCard(),
        const SizedBox(height: 22),
        _sectionHeader('Patient Watchlist', 'View all', () => _navigateTo(const PatientListScreen())),
        const SizedBox(height: 10),
        _buildWatchlistCard(),
        const SizedBox(height: 22),
        _buildPerformanceCard(),
        const SizedBox(height: 22),
        _sectionHeader('Recent Patients', 'View all', () => _navigateTo(const PatientListScreen())),
        const SizedBox(height: 10),
        _buildRecentPatients(),
        const SizedBox(height: 22),
        _buildInsightCard(),
      ],
    );
  }

  Widget _buildTodayOverview() {
    final total = _todayPatientsCount;
    final completed = total == 0 ? 0 : (_completedThisWeek > total ? total : _completedThisWeek);
    final remaining = total > completed ? total - completed : 0;
    final progress = total == 0 ? 0.0 : completed / total;

    return _card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TODAY\'S OVERVIEW', style: TextStyle(
            color: kDarkCyan, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: .5,
          )),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _numberMetric('$total', 'Appointments')),
            _divider(),
            Expanded(child: _numberMetric('$completed', 'Completed')),
            _divider(),
            Expanded(child: _numberMetric('$remaining', 'Remaining')),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                minHeight: 8, value: progress,
                backgroundColor: kLightCyan,
                valueColor: const AlwaysStoppedAnimation(kPrimaryCyan),
              ),
            )),
            const SizedBox(width: 10),
            Text('${(progress * 100).round()}%', style: const TextStyle(
              color: kTextPrimary, fontSize: 12, fontWeight: FontWeight.w800,
            )),
          ]),
          const SizedBox(height: 7),
          Text(
            total == 0 ? 'No appointments are available yet.' : '$completed of $total scheduled sessions completed',
            style: const TextStyle(color: kTextSecondary, fontSize: 10.5),
          ),
        ],
      ),
    );
  }

  Widget _buildNextPatientCard() {
    final patient = _todayPatients.isEmpty ? null : _todayPatients.first;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kDarkCyan, kPrimaryCyan],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
          color: kDarkCyan.withValues(alpha: .20), blurRadius: 18, offset: const Offset(0, 8),
        )],
      ),
      child: patient == null
          ? const Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('NEXT PATIENT', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: .6)),
                SizedBox(height: 8),
                Text('Your next appointment will appear here.', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
              ])),
              Icon(Icons.event_available_rounded, color: Colors.white70, size: 42),
            ])
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('NEXT PATIENT', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: .6)),
              const SizedBox(height: 7),
              const Text('10:00 AM', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w800)),
              const SizedBox(height: 13),
              Row(children: [
                Container(
                  width: 54, height: 54, alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, color: Colors.white.withValues(alpha: .10),
                    border: Border.all(color: Colors.white.withValues(alpha: .85)),
                  ),
                  child: Text(patient.initials, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(patient.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text(patient.condition, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: .14), borderRadius: BorderRadius.circular(10)),
                    child: const Text('Confirmed', style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w700)),
                  ),
                ])),
                const SizedBox(width: 8),
                Material(
                  color: Colors.white, borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: patient.id.isEmpty ? null : () => _navigateTo(PatientDetailScreen(patientId: patient.id, initialTabIndex: 0)),
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 11, vertical: 11),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text('Profile', style: TextStyle(color: kDarkCyan, fontSize: 10.5, fontWeight: FontWeight.w800)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, color: kDarkCyan, size: 16),
                      ]),
                    ),
                  ),
                ),
              ]),
            ]),
    );
  }

  Widget _buildScheduleCard() {
    final patients = _todayPatients.take(4).toList();
    if (patients.isEmpty) {
      return _card(padding: const EdgeInsets.all(22), child: const Column(children: [
        Icon(Icons.calendar_month_outlined, color: kPrimaryCyan, size: 34),
        SizedBox(height: 10),
        Text('No appointments yet', style: TextStyle(color: kTextPrimary, fontSize: 14, fontWeight: FontWeight.w800)),
        SizedBox(height: 4),
        Text('Your daily schedule will appear here.', textAlign: TextAlign.center, style: TextStyle(color: kTextSecondary, fontSize: 11)),
      ]));
    }

    const times = ['09:00 AM', '10:00 AM', '12:00 PM', '04:30 PM'];
    return _card(
      padding: EdgeInsets.zero,
      child: Column(children: [
        for (var i = 0; i < patients.length; i++)
          _ScheduleRow(
            patient: patients[i],
            time: times[i],
            status: i == 0 ? 'Completed' : i == 1 ? 'Starting Soon' : 'Upcoming',
            isFirst: i == 0,
            isLast: i == patients.length - 1,
            onTap: patients[i].id.isEmpty ? null : () => _navigateTo(PatientDetailScreen(patientId: patients[i].id, initialTabIndex: 0)),
          ),
      ]),
    );
  }

  Widget _buildWatchlistCard() {
    final patients = _todayPatients.take(3).toList();
    if (patients.isEmpty) {
      return _card(padding: const EdgeInsets.all(18), child: const Row(children: [
        CircleAvatar(radius: 20, backgroundColor: kLightCyan, child: Icon(Icons.check_rounded, color: kDarkCyan)),
        SizedBox(width: 12),
        Expanded(child: Text('No patients need attention right now.', style: TextStyle(color: kTextSecondary, fontSize: 11.5, fontWeight: FontWeight.w600))),
      ]));
    }

    const messages = ['Review patient progress', 'Check exercise adherence', 'Follow-up recommended'];
    const colors = [kError, kWarning, kPrimaryCyan];
    return _card(
      padding: EdgeInsets.zero,
      child: Column(children: [
        for (var i = 0; i < patients.length; i++)
          _WatchlistRow(
            patient: patients[i], color: colors[i], message: messages[i],
            onTap: patients[i].id.isEmpty ? null : () => _navigateTo(PatientDetailScreen(patientId: patients[i].id, initialTabIndex: i == 1 ? 1 : 0)),
          ),
      ]),
    );
  }

  Widget _buildPerformanceCard() {
    final total = _todayPatientsCount;
    final completed = total == 0 ? 0 : (_completedThisWeek > total ? total : _completedThisWeek);
    final rate = total == 0 ? 0 : ((completed / total) * 100).round();

    return _card(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('Treatment Performance', style: TextStyle(color: kDarkCyan, fontSize: 13, fontWeight: FontWeight.w800))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(color: kLightCyan, borderRadius: BorderRadius.circular(10)),
            child: const Text('Today', style: TextStyle(color: kDarkCyan, fontSize: 9.5, fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          SizedBox(
            width: 108, height: 108,
            child: Stack(alignment: Alignment.center, children: [
              SizedBox(width: 96, height: 96, child: CircularProgressIndicator(
                value: total == 0 ? 0 : completed / total,
                strokeWidth: 10,
                backgroundColor: kLightCyan,
                valueColor: const AlwaysStoppedAnimation(kPrimaryCyan),
              )),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text('$rate%', style: const TextStyle(color: kTextPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
                const Text('completion', style: TextStyle(color: kTextSecondary, fontSize: 9, fontWeight: FontWeight.w600)),
              ]),
            ]),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(children: [
            _legend(kPrimaryCyan, 'Scheduled', '$total'),
            const SizedBox(height: 10),
            _legend(kSuccess, 'Completed', '$completed'),
            const SizedBox(height: 10),
            _legend(kWarning, 'Pending', '$_pendingBookingsCount'),
          ])),
        ]),
        const SizedBox(height: 14),
        Container(
          width: double.infinity, padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(color: kLightCyan, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            const Icon(Icons.trending_up_rounded, color: kDarkCyan, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(
              total == 0 ? 'Add appointments to start tracking performance.' : 'Keep your schedule moving and complete today\'s sessions.',
              style: const TextStyle(color: kDarkCyan, fontSize: 10.5, fontWeight: FontWeight.w700),
            )),
          ]),
        ),
      ]),
    );
  }

  Widget _buildRecentPatients() {
    final patients = _todayPatients.take(4).toList();
    if (patients.isEmpty) {
      return _card(padding: const EdgeInsets.all(18), child: const Text(
        'Recently viewed patients will appear here.', style: TextStyle(color: kTextSecondary, fontSize: 11),
      ));
    }

    return SizedBox(
      height: 145,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: patients.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final patient = patients[i];
          final improving = i.isEven;
          return SizedBox(
            width: 150,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(17),
              child: InkWell(
                onTap: patient.id.isEmpty ? null : () => _navigateTo(PatientDetailScreen(patientId: patient.id, initialTabIndex: 0)),
                borderRadius: BorderRadius.circular(17),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(color: kBorder),
                    boxShadow: [BoxShadow(color: kTextPrimary.withValues(alpha: .035), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: improving ? kLightCyan : const Color(0xFFF0EDFF),
                        child: Text(patient.initials, style: TextStyle(
                          color: improving ? kDarkCyan : const Color(0xFF6D5BD0), fontSize: 11, fontWeight: FontWeight.w800,
                        )),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: kTextSecondary),
                    ]),
                    const SizedBox(height: 9),
                    Text(patient.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(
                      color: kTextPrimary, fontSize: 12, fontWeight: FontWeight.w800,
                    )),
                    const SizedBox(height: 3),
                    Text(patient.condition, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(
                      color: kTextSecondary, fontSize: 9.5,
                    )),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: improving ? const Color(0xFFEAF9F0) : const Color(0xFFEAF4FF),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(improving ? 'Improving' : 'In Progress', style: TextStyle(
                        color: improving ? const Color(0xFF159447) : const Color(0xFF2775CA),
                        fontSize: 8.5, fontWeight: FontWeight.w800,
                      )),
                    ),
                  ]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInsightCard() {
    final total = _todayPatientsCount;
    final completed = _completedThisWeek;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [kLightCyan, Colors.white], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPrimaryCyan.withValues(alpha: .10)),
      ),
      child: Row(children: [
        Container(
          width: 46, height: 46,
          decoration: const BoxDecoration(color: kDarkCyan, shape: BoxShape.circle),
          child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('TODAY\'S INSIGHT', style: TextStyle(color: kDarkCyan, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .6)),
          const SizedBox(height: 5),
          Text(total == 0 ? 'Your dashboard is ready for today.' : '$completed of $total scheduled sessions are completed.', style: const TextStyle(
            color: kTextPrimary, fontSize: 11, fontWeight: FontWeight.w700,
          )),
          const SizedBox(height: 5),
          const Text('Keep your practice moving forward. ✨', style: TextStyle(
            color: kDarkCyan, fontSize: 10.5, fontWeight: FontWeight.w700,
          )),
        ])),
      ]),
    );
  }

  Widget _buildLoadingState() {
    return Column(children: [
      const _SkeletonCard(height: 150),
      const SizedBox(height: 12),
      const _SkeletonCard(height: 180),
      const SizedBox(height: 12),
      const _SkeletonCard(height: 230),
      const SizedBox(height: 12),
      const _SkeletonCard(height: 150),
    ]);
  }

  Widget _buildErrorState() {
    return _card(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFFFFF0F0), borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.cloud_off_rounded, color: kError, size: 32),
        ),
        const SizedBox(height: 12),
        const Text('Could not load dashboard', style: TextStyle(color: kTextPrimary, fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(_errorMessage ?? 'Something went wrong. Please try again.', textAlign: TextAlign.center, style: const TextStyle(color: kTextSecondary, fontSize: 13)),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: _loadDashboardData,
          style: FilledButton.styleFrom(backgroundColor: kPrimaryCyan),
          icon: const Icon(Icons.refresh_rounded), label: const Text('Try again'),
        ),
      ]),
    );
  }

  Widget _sectionHeader(String title, String action, VoidCallback onTap) {
    return Row(children: [
      Expanded(child: Text(title, style: const TextStyle(color: kTextPrimary, fontSize: 17, fontWeight: FontWeight.w800))),
      TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(foregroundColor: kPrimaryCyan, padding: const EdgeInsets.symmetric(horizontal: 6), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(action, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
          const SizedBox(width: 3), const Icon(Icons.arrow_forward_rounded, size: 15),
        ]),
      ),
    ]);
  }

  Widget _card({required Widget child, EdgeInsetsGeometry padding = const EdgeInsets.all(16)}) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: kCardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorder),
        boxShadow: [BoxShadow(color: const Color(0xFF123047).withValues(alpha: .045), blurRadius: 16, offset: const Offset(0, 5))],
      ),
      child: child,
    );
  }

  Widget _numberMetric(String value, String label) => Column(children: [
    Text(value, style: const TextStyle(color: kTextPrimary, fontSize: 22, fontWeight: FontWeight.w800)),
    const SizedBox(height: 3),
    Text(label, textAlign: TextAlign.center, style: const TextStyle(color: kTextSecondary, fontSize: 10.5, fontWeight: FontWeight.w600)),
  ]);

  Widget _divider() => Container(width: 1, height: 34, color: kBorder);

  Widget _legend(Color color, String title, String value) => Row(children: [
    Container(width: 9, height: 9, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 8),
    Expanded(child: Text(title, style: const TextStyle(color: kTextSecondary, fontSize: 10.5, fontWeight: FontWeight.w600))),
    Text(value, style: const TextStyle(color: kTextPrimary, fontSize: 11, fontWeight: FontWeight.w800)),
  ]);

  NavigationBar _buildBottomNavigationBar() {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onNavigationTapped,
      backgroundColor: Colors.white,
      elevation: 10,
      shadowColor: Colors.black.withValues(alpha: .08),
      indicatorColor: kLightCyan,
      labelTextStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined, color: kTextSecondary), selectedIcon: Icon(Icons.home_rounded, color: kPrimaryCyan), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.people_outline_rounded, color: kTextSecondary), selectedIcon: Icon(Icons.people_rounded, color: kPrimaryCyan), label: 'Patients'),
        NavigationDestination(icon: Icon(Icons.calendar_today_outlined, color: kTextSecondary), selectedIcon: Icon(Icons.calendar_today_rounded, color: kPrimaryCyan), label: 'Calendar'),
        NavigationDestination(icon: Icon(Icons.insights_outlined, color: kTextSecondary), selectedIcon: Icon(Icons.insights_rounded, color: kPrimaryCyan), label: 'Analytics'),
        NavigationDestination(icon: Icon(Icons.person_outline_rounded, color: kTextSecondary), selectedIcon: Icon(Icons.person_rounded, color: kPrimaryCyan), label: 'Profile'),
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

  String _getInitials(String name) {
    final clean = name.trim();
    if (clean.isEmpty) return 'DR';
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, parts.first.length > 1 ? 2 : 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String _formatDate(DateTime date) {
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({
    required this.patient,
    required this.time,
    required this.status,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  final DashboardPatient patient;
  final String time;
  final String status;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final completed = status == 'Completed';
    final starting = status == 'Starting Soon';
    final color = completed ? kSuccess : starting ? kPrimaryCyan : kTextSecondary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
        child: Row(children: [
          SizedBox(width: 48, child: Text(time, textAlign: TextAlign.center, style: const TextStyle(color: kTextSecondary, fontSize: 10, fontWeight: FontWeight.w700))),
          const SizedBox(width: 8),
          SizedBox(
            width: 20, height: 54,
            child: Stack(alignment: Alignment.center, children: [
              if (!isFirst) Positioned(top: 0, bottom: 27, child: Container(width: 1.2, color: kBorder)),
              if (!isLast) Positioned(top: 27, bottom: 0, child: Container(width: 1.2, color: kBorder)),
              Container(
                width: 18, height: 18,
                decoration: BoxDecoration(color: completed ? kSuccess : Colors.white, shape: BoxShape.circle, border: Border.all(color: color, width: 2)),
                child: completed ? const Icon(Icons.check, color: Colors.white, size: 11) : null,
              ),
            ]),
          ),
          const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(patient.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: kTextPrimary, fontSize: 12.5, fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text(patient.condition, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: kTextSecondary, fontSize: 10.5)),
          ])),
          const SizedBox(width: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
            decoration: BoxDecoration(color: color.withValues(alpha: .09), borderRadius: BorderRadius.circular(9)),
            child: Text(status, style: TextStyle(color: color, fontSize: 8.3, fontWeight: FontWeight.w800)),
          ),
          const Icon(Icons.chevron_right_rounded, color: kTextSecondary, size: 18),
        ]),
      ),
    );
  }
}

class _WatchlistRow extends StatelessWidget {
  const _WatchlistRow({required this.patient, required this.color, required this.message, required this.onTap});
  final DashboardPatient patient;
  final Color color;
  final String message;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(children: [
          Container(width: 4, height: 45, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8))),
          const SizedBox(width: 10),
          CircleAvatar(radius: 19, backgroundColor: color.withValues(alpha: .10), child: Text(patient.initials, style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w800))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(patient.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: kTextPrimary, fontSize: 12, fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text(message, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: kTextSecondary, fontSize: 10)),
          ])),
          const Icon(Icons.chevron_right_rounded, color: kTextSecondary, size: 19),
        ]),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: kBorder)),
      child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _SkeletonLine(width: 130, height: 13),
        SizedBox(height: 14),
        _SkeletonLine(width: double.infinity, height: 28),
        SizedBox(height: 9),
        _SkeletonLine(width: 210, height: 12),
      ]),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.width, required this.height});
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(width: width, height: height, decoration: BoxDecoration(color: kLightCyan, borderRadius: BorderRadius.circular(8)));
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
    if (parts.length == 1) return parts.first.substring(0, parts.first.length > 1 ? 2 : 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More Options'), backgroundColor: kPrimaryCyan, foregroundColor: Colors.white),
      body: const Center(child: Text('Clinic Settings & Reports')),
    );
  }
}
