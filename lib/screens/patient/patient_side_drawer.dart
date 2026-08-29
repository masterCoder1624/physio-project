import 'package:flutter/material.dart';
import '../../constants/patient_theme.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'exercise_list_screen.dart';
import 'patient_appointments_screen.dart';
import 'patient_documents_screen.dart';
import 'patient_messages_screen.dart';
import 'patient_notifications_screen.dart';
import 'patient_payments_screen.dart';
import 'patient_profile_screen.dart';
import 'patient_programs_screen.dart';
import 'patient_progress_screen.dart';
import 'patient_records_screen.dart';
import 'patient_settings_screen.dart';

class PatientSideDrawer extends StatefulWidget {
  const PatientSideDrawer({super.key, this.patientName, this.onSelectSection});

  final String? patientName;
  final void Function(int sectionIndex)? onSelectSection;

  @override
  State<PatientSideDrawer> createState() => _PatientSideDrawerState();
}

class _PatientSideDrawerState extends State<PatientSideDrawer> {
  String _displayName = 'Patient';
  String _email = '';
  String _initials = 'P';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (widget.patientName != null && widget.patientName!.isNotEmpty) {
      _displayName = widget.patientName!;
      _initials = _getInitials(_displayName);
    }
    try {
      final user = await AuthService().getProfile();
      if (!mounted) return;
      setState(() {
        if (user.fullName.isNotEmpty) {
          _displayName = user.fullName;
          _initials = _getInitials(user.fullName);
        }
        _email = user.email;
      });
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

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out of RehabZ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: PatientTheme.errorRed),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await AuthService().logout();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _handleSection(int index, Widget fallbackScreen) {
    Navigator.of(context).pop();
    if (widget.onSelectSection != null) {
      widget.onSelectSection!(index);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => fallbackScreen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Header Profile Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            color: PatientTheme.primaryTealLight,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: PatientTheme.primaryTeal,
                  child: Text(
                    _initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: PatientTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _email.isNotEmpty ? _email : 'patient@rehabz.com',
                        style: const TextStyle(
                          fontSize: 12,
                          color: PatientTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Drawer Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.home_rounded,
                  title: 'Home Overview',
                  onTap: () {
                    Navigator.of(context).pop();
                    if (widget.onSelectSection != null) {
                      widget.onSelectSection!(0);
                    }
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.calendar_today_rounded,
                  title: 'My Appointments',
                  onTap: () => _handleSection(1, const PatientAppointmentsScreen()),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.fitness_center_rounded,
                  title: 'Today\'s Exercises',
                  onTap: () => _handleSection(2, const ExerciseListScreen()),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.trending_up_rounded,
                  title: 'Progress Tracking',
                  onTap: () => _handleSection(3, const PatientProgressScreen()),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.description_outlined,
                  title: 'Documents & Reports',
                  onTap: () => _handleSection(4, const PatientDocumentsScreen()),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'Messages',
                  onTap: () => _handleSection(5, const PatientMessagesScreen()),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.assignment_outlined,
                  title: 'My Programs',
                  onTap: () => _handleSection(6, const PatientProgramsScreen()),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.folder_shared_outlined,
                  title: 'Medical Records',
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PatientRecordsScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.receipt_long_rounded,
                  title: 'Invoices & Payments',
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PatientPaymentsScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PatientNotificationsScreen()),
                    );
                  },
                ),
                const Divider(height: 20, color: PatientTheme.border),
                _buildDrawerItem(
                  context,
                  icon: Icons.person_outline_rounded,
                  title: 'My Profile',
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PatientProfileScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PatientSettingsScreen()),
                    );
                  },
                ),
              ],
            ),
          ),

          // Logout Item at bottom
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: PatientTheme.border)),
            ),
            child: _buildDrawerItem(
              context,
              icon: Icons.logout_rounded,
              title: 'Log Out',
              color: PatientTheme.errorRed,
              onTap: () => _logout(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = PatientTheme.textDark,
  }) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: color, size: 20),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      onTap: onTap,
    );
  }
}
