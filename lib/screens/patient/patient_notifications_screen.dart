import 'package:flutter/material.dart';
import '../../constants/patient_theme.dart';
import 'patient_components.dart';

/// Screen 21 — Notifications Screen (matching media_1787385006975.jpg)
class PatientNotificationsScreen extends StatefulWidget {
  const PatientNotificationsScreen({super.key});

  @override
  State<PatientNotificationsScreen> createState() => _PatientNotificationsScreenState();
}

class _PatientNotificationsScreenState extends State<PatientNotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Appointment Reminder',
      'subtitle': 'Your appointment is today at 05:00 PM with Dr. Vashu User.',
      'time': '10:00 AM',
      'category': 'Today',
      'icon': Icons.calendar_today_rounded,
      'color': PatientTheme.infoBlue,
      'bg': PatientTheme.infoBlueBg,
      'isRead': false,
    },
    {
      'title': 'Exercise Reminder',
      'subtitle': 'You have 2 exercises pending for today. Complete them before 9 PM.',
      'time': '09:00 AM',
      'category': 'Today',
      'icon': Icons.fitness_center_rounded,
      'color': PatientTheme.warningOrange,
      'bg': PatientTheme.warningOrangeBg,
      'isRead': false,
    },
    {
      'title': 'New Message',
      'subtitle': 'You have a new message from Dr. Vashu User: "How are you feeling today?"',
      'time': 'Yesterday',
      'category': 'Yesterday',
      'icon': Icons.chat_bubble_rounded,
      'color': PatientTheme.primaryTeal,
      'bg': PatientTheme.primaryTealLight,
      'isRead': true,
    },
    {
      'title': 'Payment Reminder',
      'subtitle': 'Payment of ₹1,250 is pending for your recent therapy consultation.',
      'time': '16 Aug 2026',
      'category': 'Earlier',
      'icon': Icons.receipt_long_rounded,
      'color': const Color(0xFFD97706),
      'bg': const Color(0xFFFEF3C7),
      'isRead': true,
    },
    {
      'title': 'Program Update',
      'subtitle': 'Your treatment program has been updated to Phase 2: Mobility.',
      'time': '17 Aug 2026',
      'category': 'Earlier',
      'icon': Icons.folder_shared_rounded,
      'color': PatientTheme.successGreen,
      'bg': PatientTheme.successGreenBg,
      'isRead': true,
    },
  ];

  void _markAllAsRead() {
    setState(() {
      for (final n in _notifications) {
        n['isRead'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read.')),
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
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text(
              'Mark all as read',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: PatientTheme.primaryTeal),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildGroup('Today'),
          _buildGroup('Yesterday'),
          _buildGroup('Earlier'),
        ],
      ),
    );
  }

  Widget _buildGroup(String groupName) {
    final items = _notifications.where((n) => n['category'] == groupName).toList();
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 8),
          child: Text(
            groupName,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: PatientTheme.textSecondary),
          ),
        ),
        ...items.map((item) {
          final isRead = item['isRead'] as bool;
          return PatientCard(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            borderColor: isRead ? PatientTheme.border : PatientTheme.primaryTeal.withValues(alpha: 0.3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: item['bg'] as Color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: item['color'] as Color,
                    size: 20,
                  ),
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
                            item['title'] as String,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: isRead ? FontWeight.bold : FontWeight.w800,
                              color: PatientTheme.textDark,
                            ),
                          ),
                          Text(
                            item['time'] as String,
                            style: const TextStyle(fontSize: 11, color: PatientTheme.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item['subtitle'] as String,
                        style: const TextStyle(fontSize: 12, color: PatientTheme.textSecondary, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
      ],
    );
  }
}
