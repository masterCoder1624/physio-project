import 'package:flutter/material.dart';
import '../../constants/patient_theme.dart';
import 'patient_components.dart';

/// Screen 16 — Book Appointment Screen (matching media_1787385006975.jpg)
class PatientBookAppointmentScreen extends StatefulWidget {
  const PatientBookAppointmentScreen({super.key});

  @override
  State<PatientBookAppointmentScreen> createState() => _PatientBookAppointmentScreenState();
}

class _PatientBookAppointmentScreenState extends State<PatientBookAppointmentScreen> {
  int _selectedDateIndex = 0;
  int _selectedSlotIndex = 1; // 05:00 PM selected
  int _selectedTypeIndex = 0;

  final List<Map<String, String>> _dates = [
    {'day': '19', 'week': 'Wed'},
    {'day': '20', 'week': 'Thu'},
    {'day': '21', 'week': 'Fri'},
    {'day': '22', 'week': 'Sat'},
    {'day': '23', 'week': 'Sun'},
  ];

  final List<String> _slots = [
    '04:00 PM',
    '05:00 PM',
    '06:00 PM',
    '07:00 PM',
    '08:00 PM',
    '08:30 PM',
  ];

  final List<String> _types = [
    'In-Person Consultation (₹800)',
    'Online Video Assessment (₹500)',
    'Therapy Session (₹1,000)',
  ];

  void _confirmBooking() {
    showDialog(
      context: context,
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
              'Your session is scheduled for ${_dates[_selectedDateIndex]['day']} Aug at ${_slots[_selectedSlotIndex]} with Dr. Vashu User.',
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
                      children: const [
                        Text(
                          'Dr. Vashu User',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
                        ),
                        SizedBox(height: 2),
                        Text(
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

            // Step 1: Select Date (matching screenshot)
            const Text(
              'Select Date',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_dates.length, (index) {
                final isSelected = _selectedDateIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDateIndex = index),
                  child: Container(
                    width: 58,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? PatientTheme.primaryTeal : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? PatientTheme.primaryTeal : PatientTheme.border,
                      ),
                      boxShadow: isSelected ? PatientTheme.tealButtonShadow : PatientTheme.cardShadow,
                    ),
                    child: Column(
                      children: [
                        Text(
                          _dates[index]['day']!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : PatientTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _dates[index]['week']!,
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
              }),
            ),
            const SizedBox(height: 24),

            // Step 2: Available Slots (matching screenshot)
            const Text(
              'Available Slots',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
            ),
            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _slots.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedSlotIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedSlotIndex = index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? PatientTheme.primaryTeal : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? PatientTheme.primaryTeal : PatientTheme.border,
                      ),
                      boxShadow: isSelected ? PatientTheme.tealButtonShadow : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _slots[index],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : PatientTheme.textDark,
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
              onPressed: _confirmBooking,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
