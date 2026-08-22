import 'package:flutter/material.dart';
import '../../constants/patient_theme.dart';
import 'patient_components.dart';
import 'patient_edit_profile_screen.dart';

/// Settings Screen for Patient Application
class PatientSettingsScreen extends StatefulWidget {
  const PatientSettingsScreen({super.key});

  @override
  State<PatientSettingsScreen> createState() => _PatientSettingsScreenState();
}

class _PatientSettingsScreenState extends State<PatientSettingsScreen> {
  bool _appointmentReminders = true;
  bool _exerciseReminders = true;
  bool _messageAlerts = true;
  bool _programUpdates = true;

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
          'Settings',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Account Settings
          _buildSectionHeader('Account'),
          PatientCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildActionTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Edit Profile',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PatientEditProfileScreen()),
                    );
                  },
                ),
                const Divider(height: 1, color: PatientTheme.border),
                _buildActionTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Change Password',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password reset link sent to your registered email.')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Notifications Settings
          _buildSectionHeader('Notifications'),
          PatientCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildSwitchTile(
                  'Appointment Reminders',
                  'Get alerted 1 hour before scheduled sessions',
                  _appointmentReminders,
                  (v) => setState(() => _appointmentReminders = v),
                ),
                const Divider(height: 1, color: PatientTheme.border),
                _buildSwitchTile(
                  'Exercise Reminders',
                  'Daily reminders to complete today\'s routine',
                  _exerciseReminders,
                  (v) => setState(() => _exerciseReminders = v),
                ),
                const Divider(height: 1, color: PatientTheme.border),
                _buildSwitchTile(
                  'Doctor Messages',
                  'Instant push alerts for direct chat messages',
                  _messageAlerts,
                  (v) => setState(() => _messageAlerts = v),
                ),
                const Divider(height: 1, color: PatientTheme.border),
                _buildSwitchTile(
                  'Program Updates',
                  'Notifications when new phases are unlocked',
                  _programUpdates,
                  (v) => setState(() => _programUpdates = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Preferences & Privacy
          _buildSectionHeader('Preferences & Privacy'),
          PatientCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildActionTile(
                  icon: Icons.language_rounded,
                  title: 'Language',
                  trailingText: 'English (US)',
                  onTap: () {},
                ),
                const Divider(height: 1, color: PatientTheme.border),
                _buildActionTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () {},
                ),
                const Divider(height: 1, color: PatientTheme.border),
                _buildActionTile(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: PatientTheme.textSecondary),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: PatientTheme.primaryTeal, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: PatientTheme.textDark)),
            ),
            if (trailingText != null)
              Text(trailingText, style: const TextStyle(fontSize: 12, color: PatientTheme.textSecondary)),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: PatientTheme.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: PatientTheme.textDark)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: PatientTheme.textSecondary)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: PatientTheme.primaryTeal,
            activeTrackColor: PatientTheme.primaryTealLight,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
