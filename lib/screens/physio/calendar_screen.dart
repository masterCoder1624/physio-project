import 'package:flutter/material.dart';
import 'patient_list_screen.dart';
import 'profile_screen.dart';
import 'physio_navigation.dart';

// Physio calendar theme — frontend only.
const Color _cyan = Color(0xFF08A9BE);
const Color _cyanDark = Color(0xFF078EA1);
const Color _cyanLight = Color(0xFFE8F8FA);
const Color _pageBg = Color(0xFFF6FAFC);
const Color _text = Color(0xFF102A43);
const Color _muted = Color(0xFF64748B);
const Color _border = Color(0xFFE4EEF2);
const Color _green = Color(0xFF16A34A);
const Color _greenBg = Color(0xFFEAF8EF);
const Color _orange = Color(0xFFF59E0B);
const Color _orangeBg = Color(0xFFFFF4E2);
const Color _red = Color(0xFFEF4444);
const Color _redBg = Color(0xFFFFECEC);

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key, this.showBottomNavigation = true});

  final bool showBottomNavigation;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // Kept as frontend demo data. Backend/API files are not touched.
  DateTime _selectedDate = DateTime(2026, 8, 19);
  int _navIndex = 2;
  String _filter = 'All Appointments';

  final Map<String, List<_Appointment>> _appointments = {
    '2026-08-19': [
      _Appointment(
        time: '09:00',
        period: 'AM',
        patient: 'Rahul Sharma',
        initials: 'RS',
        condition: 'Knee Rehabilitation',
        duration: '45 min',
        mode: 'In-person',
        status: 'Confirmed',
        statusColor: _green,
        statusBg: _greenBg,
      ),
      _Appointment(
        time: '10:00',
        period: 'AM',
        patient: 'Ananya Sharma',
        initials: 'AS',
        condition: 'Shoulder Pain',
        duration: '45 min',
        mode: 'Online',
        status: 'Pending',
        statusColor: _orange,
        statusBg: _orangeBg,
      ),
      _Appointment(
        time: '11:30',
        period: 'AM',
        patient: 'Neha Gupta',
        initials: 'NG',
        condition: 'Back Pain',
        duration: '30 min',
        mode: 'In-person',
        status: 'Confirmed',
        statusColor: _green,
        statusBg: _greenBg,
      ),
      _Appointment(
        time: '01:00',
        period: 'PM',
        patient: 'Amit Patel',
        initials: 'AP',
        condition: 'Sports Injury',
        duration: '45 min',
        mode: 'Online',
        status: 'Pending',
        statusColor: _orange,
        statusBg: _orangeBg,
      ),
    ],
    '2026-08-20': [
      _Appointment(
        time: '09:30',
        period: 'AM',
        patient: 'Pooja Kulkarni',
        initials: 'PK',
        condition: 'Neck Pain',
        duration: '30 min',
        mode: 'In-person',
        status: 'Confirmed',
        statusColor: _green,
        statusBg: _greenBg,
      ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final appointments = _appointments[_dateKey(_selectedDate)] ?? [];
    final visible = _filteredAppointments(appointments);

    return PhysioSystemUi(
      statusBarColor: _cyanDark,
      statusBarBrightness: Brightness.dark,
      child: Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                color: _cyan,
                onRefresh: () async => setState(() {}),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  children: [
                    _buildWeekCard(),
                    const SizedBox(height: 18),
                    _buildDaySummary(appointments),
                    const SizedBox(height: 18),
                    _buildFilters(),
                    const SizedBox(height: 20),
                    const Text(
                      "TODAY'S SCHEDULE",
                      style: TextStyle(
                        color: _cyanDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (visible.isEmpty)
                      _buildEmptyState()
                    else
                      ...visible.map(
                        (appointment) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildAppointmentCard(appointment),
                        ),
                      ),
                    if (visible.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _buildViewMore(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.showBottomNavigation ? _buildBottomNavigation() : null,
    ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_cyanDark, _cyan],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calendar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -.7,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Manage your appointments',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekCard() {
    final week = _weekDates(_selectedDate);
    final monthName = _monthName(_selectedDate.month);

    return Container(
      margin: const EdgeInsets.only(top: 0),
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _circleButton(Icons.chevron_left, _previousWeek),
              Text(
                '$monthName ${_selectedDate.year}',
                style: const TextStyle(
                  color: _text,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              _circleButton(Icons.chevron_right, _nextWeek),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: week.map(_buildDateItem).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateItem(DateTime date) {
    final selected = _sameDay(date, _selectedDate);
    final hasAppointments = (_appointments[_dateKey(date)] ?? []).isNotEmpty;
    final weekday = const ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'][date.weekday - 1];

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDate = date),
        child: Column(
          children: [
            Text(
              weekday,
              style: TextStyle(
                color: selected ? _cyanDark : _muted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 9),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? _cyan : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${date.day}',
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : date.weekday == DateTime.sunday
                          ? _red
                          : _text,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              height: 6,
              child: hasAppointments
                  ? Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: _cyan,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySummary(List<_Appointment> appointments) {
    final completed = appointments.where((a) => a.status == 'Completed').length;
    final pending = appointments.where((a) => a.status == 'Pending').length;
    final cancelled = appointments.where((a) => a.status == 'Cancelled').length;
    final upcoming = appointments.length - completed - pending - cancelled;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(
              width: 205,
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: _cyanLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.calendar_month_outlined, color: _cyanDark, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${_weekdayName(_selectedDate.weekday)}, ${_selectedDate.day} ${_monthName(_selectedDate.month)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: _text, fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _sameDay(_selectedDate, DateTime.now()) ? 'Today' : 'Selected day',
                          style: const TextStyle(color: _cyanDark, fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${appointments.length} Appointments',
                          style: const TextStyle(color: _muted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _summaryTile(Icons.check_circle_outline, '$completed', 'Completed', _cyanLight, _cyanDark),
            const SizedBox(width: 8),
            _summaryTile(Icons.access_time, '$upcoming', 'Upcoming', _greenBg, _green),
            const SizedBox(width: 8),
            _summaryTile(Icons.schedule_outlined, '$pending', 'Pending', _orangeBg, _orange),
            const SizedBox(width: 8),
            _summaryTile(Icons.cancel_outlined, '$cancelled', 'Cancelled', _redBg, _red),
          ],
        ),
      ),
    );
  }

  Widget _summaryTile(
    IconData icon,
    String value,
    String label,
    Color bg,
    Color color,
  ) {
    return SizedBox(
      width: 98,
      child: Container(
        height: 92,
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: .12)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 5),
            Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            FittedBox(
              child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    const filters = ['All Appointments', 'Upcoming', 'Completed', 'Pending', 'Cancelled'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final selected = _filter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              selected: selected,
              label: Text(filter),
              onSelected: (_) => setState(() => _filter = filter),
              selectedColor: _cyan,
              backgroundColor: Colors.white,
              side: BorderSide(color: selected ? _cyan : _border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              labelStyle: TextStyle(
                color: selected ? Colors.white : _text,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAppointmentCard(_Appointment appointment) {
    final dotColor = appointment.status == 'Pending' ? _orange : _cyan;

    return Container(
      constraints: const BoxConstraints(minHeight: 126),
      decoration: _cardDecoration(radius: 16),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  appointment.time,
                  style: const TextStyle(color: _cyanDark, fontSize: 17, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  appointment.period,
                  style: const TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 78, color: _border),
          const SizedBox(width: 10),
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          CircleAvatar(
            radius: 26,
            backgroundColor: _cyanLight,
            child: Text(
              appointment.initials,
              style: const TextStyle(color: _cyanDark, fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.patient,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _text, fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appointment.condition,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _muted, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      _meta(Icons.access_time, appointment.duration),
                      _meta(
                        appointment.mode == 'Online' ? Icons.videocam_outlined : Icons.location_on_outlined,
                        appointment.mode,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 14, bottom: 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                      decoration: BoxDecoration(
                        color: appointment.statusBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        appointment.status,
                        style: TextStyle(
                          color: appointment.statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.more_vert, color: _muted, size: 22),
                      onSelected: (value) => _showAppointmentAction(value, appointment),
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'details', child: Text('View details')),
                        PopupMenuItem(value: 'patient', child: Text('View patient')),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => _showAppointmentAction('patient', appointment),
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('View Patient'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _cyanDark,
                    side: const BorderSide(color: _cyan),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _meta(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: _muted, size: 16),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildViewMore() {
    return Center(
      child: TextButton.icon(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All appointments view is not connected yet.')),
        ),
        icon: const Icon(Icons.keyboard_arrow_down, color: _cyanDark),
        label: const Text(
          'View More Appointments',
          style: TextStyle(color: _cyanDark, fontWeight: FontWeight.w800, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 24),
      decoration: _cardDecoration(),
      child: const Column(
        children: [
          Icon(Icons.event_available_outlined, color: _cyan, size: 52),
          SizedBox(height: 12),
          Text('No appointments', style: TextStyle(color: _text, fontSize: 18, fontWeight: FontWeight.w800)),
          SizedBox(height: 6),
          Text(
            'There are no appointments for this day.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final items = [
      (Icons.home_outlined, 'Home'),
      (Icons.people_outline, 'Patients'),
      (Icons.calendar_month_outlined, 'Calendar'),
      (Icons.trending_up, 'Analytics'),
      (Icons.person_outline, 'Profile'),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final selected = index == _navIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (index == 0) {
                  Navigator.of(context).pop();
                } else if (index == 1) {
                  PhysioNavigation.replace(context, const PatientListScreen());
                } else if (index == 4) {
                  PhysioNavigation.replace(context, const ProfileScreen());
                } else {
                  setState(() => _navIndex = index);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? _cyanLight : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(items[index].$1, color: selected ? _cyanDark : _muted, size: 22),
                    const SizedBox(height: 4),
                    Text(
                      items[index].$2,
                      style: TextStyle(
                        color: selected ? _cyanDark : _muted,
                        fontSize: 11,
                        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  BoxDecoration _cardDecoration({double radius = 20}) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF123047).withValues(alpha: .05),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      );

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: 40,
        height: 40,
        child: Icon(icon, color: _cyanDark, size: 28),
      ),
    );
  }

  void _previousWeek() => setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 7)));
  void _nextWeek() => setState(() => _selectedDate = _selectedDate.add(const Duration(days: 7)));

  List<DateTime> _weekDates(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(7, (i) => DateTime(monday.year, monday.month, monday.day + i));
  }

  List<_Appointment> _filteredAppointments(List<_Appointment> items) {
    switch (_filter) {
      case 'Upcoming':
        return items.where((a) => a.status == 'Confirmed').toList();
      case 'Completed':
        return items.where((a) => a.status == 'Completed').toList();
      case 'Pending':
        return items.where((a) => a.status == 'Pending').toList();
      case 'Cancelled':
        return items.where((a) => a.status == 'Cancelled').toList();
      default:
        return items;
    }
  }

  void _showAppointmentAction(String action, _Appointment appointment) {
    if (action == 'patient') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Patient profile: ${appointment.patient}')),
      );
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(appointment.patient, style: const TextStyle(color: _text, fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(appointment.condition, style: const TextStyle(color: _muted, fontSize: 13)),
              const SizedBox(height: 16),
              ListTile(leading: const Icon(Icons.person_outline, color: _cyanDark), title: const Text('View patient')),
              ListTile(leading: const Icon(Icons.info_outline, color: _cyanDark), title: const Text('Appointment details')),
            ],
          ),
        ),
      ),
    );
  }

  String _dateKey(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  String _monthName(int month) => const [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ][month - 1];

  String _weekdayName(int weekday) => const [
        'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
      ][weekday - 1];
}

class _Appointment {
  final String time;
  final String period;
  final String patient;
  final String initials;
  final String condition;
  final String duration;
  final String mode;
  final String status;
  final Color statusColor;
  final Color statusBg;

  const _Appointment({
    required this.time,
    required this.period,
    required this.patient,
    required this.initials,
    required this.condition,
    required this.duration,
    required this.mode,
    required this.status,
    required this.statusColor,
    required this.statusBg,
  });
}
