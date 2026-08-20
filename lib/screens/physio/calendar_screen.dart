import 'package:flutter/material.dart';
import 'patient_list_screen.dart';
import 'profile_screen.dart';

const Color _kPrimaryBlue = Color(0xFF10B981);
const Color _kTealGreen = Color(0xFF2E5A44);
const Color _kTextDark = Color(0xFFF8FAFC);
const Color _kTextSecondary = Color(0xFFA7F3D0);
const Color _kTextMuted = Color(0xFF6EE7B7);
const Color _kPageBg = Color(0xFF0F1F17);
const Color _kCardBg = Color(0xFF183326);
const Color _kBorderColor = Color(0xFF254B37);
const Color _kSlotBg = Color(0xFF132A1F);
const Color _kSlotBorder = Color(0xFF1F402E);

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _currentMonth = DateTime(2026, 7, 1);
  DateTime _selectedDate = DateTime(2026, 7, 23);
  String _selectedCalendarType = 'Physio calendar';
  int _navIndex = 2; // Calendar tab selected

  // Dummy booking data mapped by date string "YYYY-MM-DD"
  final Map<String, List<_AppointmentSlot>> _appointments = {
    '2026-07-23': [
      _AppointmentSlot(
        time: '10:00 AM',
        isBooked: true,
        patientName: 'Ananya Sharma',
        initials: 'AS',
        condition: 'Knee Injury Rehabilitation',
        price: 500,
        isVideoCall: true,
        avatarBgColor: const Color(0xFF0066FF),
      ),
      _AppointmentSlot(
        time: '11:30 AM',
        isBooked: true,
        patientName: 'Rahul Mehta',
        initials: 'RM',
        condition: 'Lower Back Pain',
        price: 800,
        isVideoCall: false,
        avatarBgColor: const Color(0xFFFF6B4A),
      ),
      _AppointmentSlot(
        time: '02:30 PM',
        isBooked: true,
        patientName: 'Siddharth Rao',
        initials: 'SR',
        condition: 'Post-ACL Rehab',
        price: 600,
        isVideoCall: true,
        avatarBgColor: const Color(0xFF10B981),
      ),
    ],
    '2026-07-25': [
      _AppointmentSlot(
        time: '09:00 AM',
        isBooked: true,
        patientName: 'Priya Verma',
        initials: 'PV',
        condition: 'Cervical Spondylosis',
        price: 700,
        isVideoCall: false,
        avatarBgColor: const Color(0xFF8B5CF6),
      ),
      _AppointmentSlot(
        time: '11:00 AM',
        isBooked: true,
        patientName: 'Vikram Singh',
        initials: 'VS',
        condition: 'Shoulder Impingement',
        price: 550,
        isVideoCall: true,
        avatarBgColor: const Color(0xFF00B894),
      ),
    ],
  };

  final List<String> _allTimeSlots = [
    '9:00 AM',
    '9:30 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '12:00 PM',
    '2:00 PM',
  ];

  @override
  Widget build(BuildContext context) {
    final dateKey = _formatDateKey(_selectedDate);
    final dayAppointments = _appointments[dateKey] ?? [];

    return Scaffold(
      backgroundColor: _kPageBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar with Header and Dropdown Pill
              _buildTopHeader(),
              const SizedBox(height: 20),

              // Calendar Card Box
              _buildMonthCalendarCard(),
              const SizedBox(height: 24),

              // Selected Date Summary Title
              Text(
                '${_selectedDate.day} ${_getMonthName(_selectedDate.month)} — ${dayAppointments.length} bookings',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _kTextDark,
                ),
              ),
              const SizedBox(height: 16),

              // Timeline List of Time Slots
              _buildScheduleTimeline(dayAppointments),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// Top Header section with Title, Subtitle, and Pill Dropdown
  Widget _buildTopHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calendar',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: _kTextDark,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Manage your availability and bookings',
                  style: TextStyle(
                    fontSize: 14,
                    color: _kTextSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            // Teal Pill Dropdown
            PopupMenuButton<String>(
              onSelected: (val) {
                setState(() {
                  _selectedCalendarType = val;
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'Physio calendar',
                  child: Text('Physio calendar'),
                ),
                const PopupMenuItem(
                  value: 'Patient calendar',
                  child: Text('Patient calendar'),
                ),
                const PopupMenuItem(
                  value: 'Clinic Schedule',
                  child: Text('Clinic Schedule'),
                ),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _kTealGreen,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _kTealGreen.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selectedCalendarType,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Month Calendar Card Widget matching the screenshot
  Widget _buildMonthCalendarCard() {
    final year = _currentMonth.year;
    final month = _currentMonth.month;
    final firstDayOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final startWeekday = firstDayOfMonth.weekday % 7; // Sun = 0, Mon = 1...

    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Month Header with Prev/Next controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildChevronButton(
                icon: Icons.chevron_left,
                onTap: () {
                  setState(() {
                    _currentMonth = DateTime(year, month - 1, 1);
                  });
                },
              ),
              Text(
                '${_getMonthName(month)} $year',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: _kTextDark,
                ),
              ),
              _buildChevronButton(
                icon: Icons.chevron_right,
                onTap: () {
                  setState(() {
                    _currentMonth = DateTime(year, month + 1, 1);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Weekdays Row Header
          Row(
            children: weekdays
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _kTextSecondary,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),

          // Days Grid (7 columns)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: startWeekday + daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 4,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              if (index < startWeekday) {
                return const SizedBox();
              }
              final dayNumber = index - startWeekday + 1;
              final cellDate = DateTime(year, month, dayNumber);
              final isSelected = cellDate.year == _selectedDate.year &&
                  cellDate.month == _selectedDate.month &&
                  cellDate.day == _selectedDate.day;

              final cellKey = _formatDateKey(cellDate);
              final hasBookings = _appointments.containsKey(cellKey) &&
                  _appointments[cellKey]!.isNotEmpty;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = cellDate;
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? _kPrimaryBlue : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNumber',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isSelected ? Colors.white : _kTextDark,
                        ),
                      ),
                      if (!isSelected && hasBookings) ...[
                        const SizedBox(height: 3),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: _kPrimaryBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Chevron button with rounded square border
  Widget _buildChevronButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: _kCardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _kBorderColor),
        ),
        child: Icon(icon, color: _kTextSecondary, size: 20),
      ),
    );
  }

  /// Timeline Schedule for Selected Date
  Widget _buildScheduleTimeline(List<_AppointmentSlot> bookedSlots) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _allTimeSlots.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final timeSlot = _allTimeSlots[index];
        final booked = bookedSlots.firstWhere(
          (s) => s.time == timeSlot,
          orElse: () => _AppointmentSlot(time: timeSlot, isBooked: false),
        );

        if (booked.isBooked) {
          return _buildBookedSlotCard(booked);
        } else {
          return _buildAvailableSlotRow(timeSlot);
        }
      },
    );
  }

  /// Available Slot Row with dashed/solid horizontal line
  Widget _buildAvailableSlotRow(String time) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            time,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _kTextMuted,
            ),
          ),
        ),
        const Expanded(
          child: Divider(
            color: _kBorderColor,
            thickness: 1.2,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Available',
          style: TextStyle(
            fontSize: 13,
            color: _kTextMuted,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  /// Booked Slot Card Widget matching the screenshot
  Widget _buildBookedSlotCard(_AppointmentSlot slot) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _kSlotBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kSlotBorder),
      ),
      child: Row(
        children: [
          // Time label on left inside card
          Text(
            slot.time,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: _kPrimaryBlue,
            ),
          ),
          const SizedBox(width: 14),

          // Avatar Circle with Patient Initials
          CircleAvatar(
            radius: 18,
            backgroundColor: slot.avatarBgColor ?? _kPrimaryBlue,
            child: Text(
              slot.initials ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Patient Name and Condition
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.patientName ?? '',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _kTextDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  slot.condition ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Price Tag and Mode Icon
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${slot.price}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _kPrimaryBlue,
                ),
              ),
              const SizedBox(height: 4),
              Icon(
                slot.isVideoCall
                    ? Icons.videocam_outlined
                    : Icons.location_on_outlined,
                color: _kTextSecondary,
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Bottom Navigation Bar matching screenshot with active tab indicator
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: _kCardBg,
        border: Border(
          top: BorderSide(color: _kBorderColor, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home_outlined,
            label: 'Home',
            isSelected: _navIndex == 0,
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          _buildNavItem(
            icon: Icons.people_outline,
            label: 'Patients',
            isSelected: _navIndex == 1,
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const PatientListScreen()),
              );
            },
          ),
          _buildNavItem(
            icon: Icons.calendar_today_outlined,
            label: 'Calendar',
            isSelected: _navIndex == 2,
            onTap: () {
              setState(() => _navIndex = 2);
            },
          ),
          _buildNavItem(
            icon: Icons.trending_up,
            label: 'Analytics',
            isSelected: _navIndex == 3,
            onTap: () {
              setState(() => _navIndex = 3);
            },
          ),
          _buildNavItem(
            icon: Icons.person_outline,
            label: 'Profile',
            isSelected: _navIndex == 4,
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Navigation Bar Item with active blue line indicator under label
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? _kPrimaryBlue : _kTextMuted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? _kPrimaryBlue : _kTextMuted,
              ),
            ),
            const SizedBox(height: 2),
            // Active Tab Underline Indicator
            Container(
              height: 2,
              width: 24,
              color: isSelected ? _kPrimaryBlue : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateKey(DateTime date) {
    final y = date.year;
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}

class _AppointmentSlot {
  final String time;
  final bool isBooked;
  final String? patientName;
  final String? initials;
  final String? condition;
  final int? price;
  final bool isVideoCall;
  final Color? avatarBgColor;

  _AppointmentSlot({
    required this.time,
    this.isBooked = false,
    this.patientName,
    this.initials,
    this.condition,
    this.price,
    this.isVideoCall = false,
    this.avatarBgColor,
  });
}
