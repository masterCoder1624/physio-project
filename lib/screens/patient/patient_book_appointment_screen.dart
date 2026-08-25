import 'package:flutter/material.dart';
import '../../constants/patient_theme.dart';
import '../../models/appointment_model.dart';
import '../../services/appointment_service.dart';
import 'patient_components.dart';

/// Screen 16 — Book Appointment Screen (connected with backend)
class PatientBookAppointmentScreen extends StatefulWidget {
  const PatientBookAppointmentScreen({super.key, this.physioId, this.physioName});

  final String? physioId;
  final String? physioName;

  @override
  State<PatientBookAppointmentScreen> createState() => _PatientBookAppointmentScreenState();
}

class _PatientBookAppointmentScreenState extends State<PatientBookAppointmentScreen> {
  int _selectedDateIndex = 0;
  int _selectedSlotIndex = 0;
  int _selectedTypeIndex = 0;
  bool _isLoadingSlots = false;
  bool _isBooking = false;

  late final List<DateTime> _calendarDays;
  List<SlotItemModel> _availableSlots = [];

  final List<String> _types = [
    'In-Person Consultation (₹800)',
    'Online Video Assessment (₹500)',
    'Therapy Session (₹1,000)',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _calendarDays = List.generate(14, (i) => now.add(Duration(days: i)));
    _fetchSlotsForSelectedDate();
  }

  DateTime get _selectedDate => _calendarDays[_selectedDateIndex];
  String get _selectedDateStr =>
      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

  Future<void> _fetchSlotsForSelectedDate() async {
    if (!mounted) return;
    setState(() => _isLoadingSlots = true);

    try {
      final slots = await AppointmentService().getAvailableSlots(
        _selectedDateStr,
        physioId: widget.physioId,
      );
      if (!mounted) return;
      setState(() {
        _availableSlots = slots;
        _isLoadingSlots = false;
        _selectedSlotIndex = 0;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingSlots = false);
    }
  }

  Future<void> _confirmBooking() async {
    if (_availableSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an available time slot.')),
      );
      return;
    }

    final selectedSlot = _availableSlots[_selectedSlotIndex];
    if (!selectedSlot.available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This slot is already booked. Please choose another slot.')),
      );
      return;
    }

    setState(() => _isBooking = true);

    try {
      final selectedType = _types[_selectedTypeIndex];
      final isOnline = selectedType.toLowerCase().contains('online');

      await AppointmentService().createAppointment(
        appointmentDate: _selectedDateStr,
        startTime: selectedSlot.time,
        physiotherapistId: widget.physioId,
        physioName: widget.physioName ?? 'Dr. Vashu User',
        physioSpecialty: 'Sports & Orthopedic Physiotherapy',
        appointmentType: isOnline ? 'Online' : 'In-person',
        notes: selectedType,
      );

      if (!mounted) return;
      setState(() => _isBooking = false);

      _showSuccessDialog(selectedSlot.time);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isBooking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  void _showSuccessDialog(String slotTime) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PatientTheme.successGreenBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: PatientTheme.successGreen, size: 48),
            ),
            const SizedBox(height: 18),
            const Text(
              'Appointment Confirmed! 🎉',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
            ),
            const SizedBox(height: 8),
            Text(
              'Your session is scheduled for ${_selectedDate.day} ${_monthAbbr(_selectedDate.month)} at $slotTime with ${widget.physioName ?? "Dr. Vashu User"}.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12.5, color: PatientTheme.textSecondary, height: 1.35),
            ),
            const SizedBox(height: 20),
            PrimaryTealButton(
              label: 'Done',
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop(true);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PatientTheme.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: PatientTheme.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Book Appointment',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Summary Card
            PatientCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: PatientTheme.primaryTealLight,
                    child: const Icon(Icons.person_rounded, color: PatientTheme.primaryTeal, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.physioName ?? 'Dr. Vashu User',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Sports & Orthopedic Physiotherapy',
                          style: TextStyle(fontSize: 11.5, color: PatientTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Step 1: Select Date
            const Text(
              'Select Date',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 70,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _calendarDays.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final date = _calendarDays[index];
                  final isSelected = _selectedDateIndex == index;
                  final weekday = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedDateIndex = index);
                      _fetchSlotsForSelectedDate();
                    },
                    child: Container(
                      width: 58,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? PatientTheme.primaryTeal : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? PatientTheme.primaryTeal : PatientTheme.border,
                        ),
                        boxShadow: isSelected ? PatientTheme.tealButtonShadow : PatientTheme.cardShadow,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : PatientTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            weekday,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white.withValues(alpha: 0.9) : PatientTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Step 2: Available Slots
            const Text(
              'Available Slots',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
            ),
            const SizedBox(height: 12),

            if (_isLoadingSlots)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: CircularProgressIndicator(color: PatientTheme.primaryTeal),
                ),
              )
            else if (_availableSlots.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('No slots available for this date.', style: TextStyle(color: PatientTheme.textSecondary)),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.8,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _availableSlots.length,
                itemBuilder: (context, index) {
                  final slot = _availableSlots[index];
                  final isSelected = _selectedSlotIndex == index;
                  final isAvailable = slot.available;

                  return GestureDetector(
                    onTap: isAvailable ? () => setState(() => _selectedSlotIndex = index) : null,
                    child: Container(
                      decoration: BoxDecoration(
                        color: !isAvailable
                            ? PatientTheme.borderLight
                            : isSelected
                                ? PatientTheme.primaryTeal
                                : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected && isAvailable ? PatientTheme.primaryTeal : PatientTheme.border,
                        ),
                        boxShadow: isSelected && isAvailable ? PatientTheme.tealButtonShadow : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        slot.time,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: !isAvailable
                              ? PatientTheme.textMuted
                              : isSelected
                                  ? Colors.white
                                  : PatientTheme.textDark,
                          decoration: !isAvailable ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 24),

            // Step 3: Appointment Type
            const Text(
              'Appointment Type',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
            ),
            const SizedBox(height: 12),

            Column(
              children: List.generate(_types.length, (index) {
                final isSelected = _selectedTypeIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTypeIndex = index),
                  child: PatientCard(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    borderColor: isSelected ? PatientTheme.primaryTeal : PatientTheme.border,
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                          color: isSelected ? PatientTheme.primaryTeal : PatientTheme.textMuted,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _types[index],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? PatientTheme.primaryTeal : PatientTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 28),

            // CTA Button
            PrimaryTealButton(
              label: 'Confirm Appointment',
              icon: Icons.calendar_month_rounded,
              isLoading: _isBooking,
              onPressed: _confirmBooking,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _monthAbbr(int month) =>
      const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][month - 1];
}
