import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/appointment_model.dart';
import '../../services/appointment_service.dart';

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
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  String _filter = 'All Appointments';
  bool _isLoading = false;
  List<_Appointment> _dayAppointments = [];
  final Set<String> _datesWithAppointments = {};

  @override
  void initState() {
    super.initState();
    _fetchAppointmentsForDate(_selectedDate);
  }

  Future<void> _fetchAppointmentsForDate(DateTime date) async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final dateStr = _dateKey(date);
      final List<AppointmentModel> models = await AppointmentService().getAppointments(date: dateStr);

      if (!mounted) return;

      final converted = models.map((m) {
        // Parse time & period
        final rawTime = m.startTime.trim();
        String timePart = rawTime;
        String periodPart = 'AM';

        if (rawTime.toUpperCase().contains('AM')) {
          timePart = rawTime.replaceAll(RegExp(r'am', caseSensitive: false), '').trim();
          periodPart = 'AM';
        } else if (rawTime.toUpperCase().contains('PM')) {
          timePart = rawTime.replaceAll(RegExp(r'pm', caseSensitive: false), '').trim();
          periodPart = 'PM';
        } else if (rawTime.contains(':')) {
          final parts = rawTime.split(':');
          final hr = int.tryParse(parts[0]) ?? 9;
          final min = parts.length > 1 ? parts[1] : '00';
          if (hr >= 12) {
            periodPart = 'PM';
            timePart = hr == 12 ? '12:$min' : '${hr - 12}:$min';
          } else {
            periodPart = 'AM';
            timePart = hr == 0 ? '12:$min' : '$hr:$min';
          }
        }

        String statusLabel = 'Confirmed';
        Color statusColor = _green;
        Color statusBg = _greenBg;

        if (m.isPending) {
          statusLabel = 'Pending';
          statusColor = _orange;
          statusBg = _orangeBg;
        } else if (m.isCancelled) {
          statusLabel = 'Cancelled';
          statusColor = _red;
          statusBg = _redBg;
        } else if (m.isCompleted) {
          statusLabel = 'Completed';
          statusColor = _cyanDark;
          statusBg = _cyanLight;
        }

        return _Appointment(
          time: timePart,
          period: periodPart,
          patient: m.patientName ?? 'Patient',
          initials: m.initials,
          condition: m.patientCondition ?? 'Physical Rehabilitation',
          duration: m.duration,
          mode: m.appointmentType,
          status: statusLabel,
          statusColor: statusColor,
          statusBg: statusBg,
          id: m.id,
        );
      }).toList();

      setState(() {
        _dayAppointments = converted;
        _isLoading = false;
        if (converted.isNotEmpty) {
          _datesWithAppointments.add(dateStr);
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visible = _filteredAppointments(_dayAppointments);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: _cyanDark,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _pageBg,
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: RefreshIndicator(
                color: _cyan,
                onRefresh: () => _fetchAppointmentsForDate(_selectedDate),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    _buildWeekCard(),
                    const SizedBox(height: 16),
                    _buildDaySummary(_dayAppointments),
                    const SizedBox(height: 16),
                    _buildFilters(),
                    const SizedBox(height: 20),
                    const Text(
                      "TODAY'S SCHEDULE",
                      style: TextStyle(color: _cyanDark, fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: CircularProgressIndicator(color: _cyan),
                        ),
                      )
                    else if (visible.isEmpty)
                      _buildEmptyState()
                    else
                      ...visible.map((appointment) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildAppointmentCard(appointment),
                          )),
                    if (visible.isNotEmpty) _buildViewMore(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(22, top + 12, 22, 24),
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
          Text('Calendar', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -.7)),
          SizedBox(height: 4),
          Text('Manage your appointments', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildWeekCard() {
    final week = _weekDates(_selectedDate);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 14),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _circleButton(Icons.chevron_left, _previousWeek),
              Flexible(
                child: Text(
                  '${_monthName(_selectedDate.month)} ${_selectedDate.year}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _text, fontSize: 22, fontWeight: FontWeight.w800),
                ),
              ),
              _circleButton(Icons.chevron_right, _nextWeek),
            ],
          ),
          const SizedBox(height: 18),
          Row(children: week.map(_buildDateItem).toList()),
        ],
      ),
    );
  }

  Widget _buildDateItem(DateTime date) {
    final selected = _sameDay(date, _selectedDate);
    final hasAppointments = _datesWithAppointments.contains(_dateKey(date));
    final weekday = const ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'][date.weekday - 1];

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => _selectedDate = date);
          _fetchAppointmentsForDate(date);
        },
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Text(weekday, style: TextStyle(color: selected ? _cyanDark : _muted, fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: selected ? _cyan : Colors.transparent, shape: BoxShape.circle),
              child: Text(
                '${date.day}',
                style: TextStyle(
                  color: selected ? Colors.white : date.weekday == DateTime.sunday ? _red : _text,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              height: 6,
              child: hasAppointments
                  ? Container(width: 6, height: 6, decoration: const BoxDecoration(color: _cyan, shape: BoxShape.circle))
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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(color: _cyanLight, borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.calendar_month_outlined, color: _cyanDark, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_weekdayName(_selectedDate.weekday)}, ${_selectedDate.day} ${_monthName(_selectedDate.month)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _text, fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(_sameDay(_selectedDate, DateTime.now()) ? 'Today' : 'Selected day', style: const TextStyle(color: _cyanDark, fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text('${appointments.length} Appointments', style: const TextStyle(color: _muted, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _summaryTile(Icons.check_circle_outline, '$completed', 'Completed', _cyanLight, _cyanDark)),
              const SizedBox(width: 8),
              Expanded(child: _summaryTile(Icons.access_time, '$upcoming', 'Upcoming', _greenBg, _green)),
              const SizedBox(width: 8),
              Expanded(child: _summaryTile(Icons.schedule_outlined, '$pending', 'Pending', _orangeBg, _orange)),
              const SizedBox(width: 8),
              Expanded(child: _summaryTile(Icons.cancel_outlined, '$cancelled', 'Cancelled', _redBg, _red)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryTile(IconData icon, String value, String label, Color bg, Color color) {
    return Container(
      height: 82,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withValues(alpha: .12))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(height: 3),
          Text(value, style: TextStyle(color: color, fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 1),
          FittedBox(child: Text(label, style: TextStyle(color: color, fontSize: 9.5, fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    const filters = ['All Appointments', 'Upcoming', 'Completed', 'Pending', 'Cancelled'];
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final filter = filters[index];
          final selected = _filter == filter;
          return ChoiceChip(
            selected: selected,
            label: Text(filter),
            onSelected: (_) => setState(() => _filter = filter),
            selectedColor: _cyan,
            backgroundColor: Colors.white,
            side: BorderSide(color: selected ? _cyan : _border),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
            labelStyle: TextStyle(color: selected ? Colors.white : _text, fontSize: 12, fontWeight: FontWeight.w700),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
            showCheckmark: false,
          );
        },
      ),
    );
  }

  Widget _buildAppointmentCard(_Appointment appointment) {
    final dotColor = appointment.status == 'Pending' ? _orange : _cyan;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
      decoration: _cardDecoration(radius: 17),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 64,
                child: Column(
                  children: [
                    Text(appointment.time, style: const TextStyle(color: _cyanDark, fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 1),
                    Text(appointment.period, style: const TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Container(width: 1, height: 66, color: _border),
              const SizedBox(width: 10),
              Container(width: 9, height: 9, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 25,
                backgroundColor: _cyanLight,
                child: Text(appointment.initials, style: const TextStyle(color: _cyanDark, fontSize: 15, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appointment.patient, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _text, fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text(appointment.condition, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _muted, fontSize: 12.5, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 9,
                      runSpacing: 3,
                      children: [
                        _meta(Icons.access_time, appointment.duration),
                        _meta(appointment.mode == 'Online' ? Icons.videocam_outlined : Icons.location_on_outlined, appointment.mode),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 30,
                height: 40,
                child: PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                  icon: const Icon(Icons.more_vert, color: _muted, size: 21),
                  onSelected: (value) => _showAppointmentAction(value, appointment),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'details', child: Text('View details')),
                    PopupMenuItem(value: 'cancel', child: Text('Cancel appointment')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(color: appointment.statusBg, borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    appointment.status,
                    style: TextStyle(color: appointment.statusColor, fontSize: 11.5, fontWeight: FontWeight.w800),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showAppointmentAction('details', appointment),
                  icon: const Icon(Icons.arrow_forward, size: 15),
                  label: const Text('View Details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _cyanDark,
                    side: const BorderSide(color: _cyan),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                    minimumSize: const Size(0, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _meta(IconData icon, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _muted, size: 14),
          const SizedBox(width: 3),
          Text(text, style: const TextStyle(color: _muted, fontSize: 11.5, fontWeight: FontWeight.w600)),
        ],
      );

  Widget _buildViewMore() => Center(
        child: TextButton.icon(
          onPressed: () => _fetchAppointmentsForDate(_selectedDate),
          icon: const Icon(Icons.refresh_rounded, color: _cyanDark),
          label: const Text('Refresh Schedule', style: TextStyle(color: _cyanDark, fontWeight: FontWeight.w800, fontSize: 14)),
        ),
      );

  Widget _buildEmptyState() => Container(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        decoration: _cardDecoration(),
        child: const Column(
          children: [
            Icon(Icons.event_available_outlined, color: _cyan, size: 52),
            SizedBox(height: 12),
            Text('No appointments', style: TextStyle(color: _text, fontSize: 18, fontWeight: FontWeight.w800)),
            SizedBox(height: 6),
            Text('There are no appointments scheduled for this day.', textAlign: TextAlign.center, style: TextStyle(color: _muted, fontSize: 13)),
          ],
        ),
      );

  BoxDecoration _cardDecoration({double radius = 20}) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: _border),
        boxShadow: [BoxShadow(color: const Color(0xFF123047).withValues(alpha: .05), blurRadius: 18, offset: const Offset(0, 7))],
      );

  Widget _circleButton(IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(width: 40, height: 40, child: Icon(icon, color: _cyanDark, size: 28)),
      );

  void _previousWeek() {
    setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 7)));
    _fetchAppointmentsForDate(_selectedDate);
  }

  void _nextWeek() {
    setState(() => _selectedDate = _selectedDate.add(const Duration(days: 7)));
    _fetchAppointmentsForDate(_selectedDate);
  }

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

  Future<void> _showAppointmentAction(String action, _Appointment appointment) async {
    if (action == 'cancel') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Cancel Appointment'),
          content: Text('Are you sure you want to cancel the appointment with ${appointment.patient}?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: _red),
              child: const Text('Cancel Appointment'),
            ),
          ],
        ),
      );

      if (confirm == true && appointment.id != null) {
        try {
          await AppointmentService().cancelAppointment(appointment.id!);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Appointment cancelled successfully.')),
            );
            _fetchAppointmentsForDate(_selectedDate);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to cancel appointment: $e')),
            );
          }
        }
      }
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(appointment.patient, style: const TextStyle(color: _text, fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('${appointment.condition} • ${appointment.time} ${appointment.period}', style: const TextStyle(color: _muted, fontSize: 13)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.event, color: _cyanDark),
                title: Text('Mode: ${appointment.mode} (${appointment.duration})'),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline, color: _cyanDark),
                title: Text('Status: ${appointment.status}'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _dateKey(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
  String _monthName(int month) => const ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'][month - 1];
  String _weekdayName(int weekday) => const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][weekday - 1];
}

class _Appointment {
  final String time, period, patient, initials, condition, duration, mode, status;
  final Color statusColor, statusBg;
  final String? id;

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
    this.id,
  });
}
