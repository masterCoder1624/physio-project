import 'package:flutter/material.dart';
import '../../constants/patient_theme.dart';
import '../../models/app_update_info.dart';
import '../../services/update_service.dart';
import '../../widgets/update_dialog.dart';
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

  // Update check state
  bool _isCheckingUpdate = false;

  // ============================================================
  // MANUAL UPDATE CHECK — shows loading, update dialog, or error
  // ============================================================

  Future<void> _checkForUpdates() async {
    if (_isCheckingUpdate) return;

    setState(() => _isCheckingUpdate = true);

    try {
      final AppUpdateInfo? updateInfo =
          await UpdateService.instance.checkForUpdateManual();

      if (!mounted) return;

      if (updateInfo != null && updateInfo.isUpdateAvailable) {
        // Show the branded update dialog
        showDialog(
          context: context,
          barrierDismissible: !updateInfo.isMandatory,
          builder: (ctx) => UpdateDialog(
            updateInfo: updateInfo,
            onDismiss: () {},
          ),
        );
      } else {
        // No newer version found — show friendly message
        final version = await UpdateService.instance.getCurrentVersion();
        if (!mounted) return;
        _showSnackBar(
          'You are using the latest version of RehabZ (v$version).',
          icon: Icons.check_circle_outline_rounded,
          color: PatientTheme.successGreen,
        );
      }
    } on UpdateException catch (e) {
      if (!mounted) return;
      _showSnackBar(
        e.message,
        icon: Icons.error_outline_rounded,
        color: PatientTheme.errorRed,
      );
    } catch (_) {
      if (!mounted) return;
      _showSnackBar(
        'Unable to check for updates. Please check your internet connection and try again.',
        icon: Icons.error_outline_rounded,
        color: PatientTheme.errorRed,
      );
    } finally {
      if (mounted) setState(() => _isCheckingUpdate = false);
    }
  }

  void _showSnackBar(String message, {required IconData icon, required Color color}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
        elevation: 4,
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: PatientTheme.textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
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
          const SizedBox(height: 20),

          // About & Updates
          _buildSectionHeader('About & Updates'),
          PatientCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                // App Version — dynamically loaded
                FutureBuilder<String>(
                  future: UpdateService.instance.getCurrentVersion(),
                  builder: (context, snapshot) {
                    final version = snapshot.data ?? '—';
                    return _buildInfoTile(
                      icon: Icons.info_outline_rounded,
                      title: 'App Version',
                      trailingText: snapshot.connectionState == ConnectionState.done
                          ? 'v$version'
                          : '…',
                    );
                  },
                ),
                const Divider(height: 1, color: PatientTheme.border),
                // Check for Updates — with loading state
                _buildCheckUpdateTile(),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ============================================================
  // CHECK FOR UPDATES TILE — handles loading state inline
  // ============================================================

  Widget _buildCheckUpdateTile() {
    return InkWell(
      onTap: _isCheckingUpdate ? null : _checkForUpdates,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              Icons.system_update_rounded,
              color: _isCheckingUpdate ? PatientTheme.textMuted : PatientTheme.primaryTeal,
              size: 20,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                _isCheckingUpdate ? 'Checking for updates...' : 'Check for Updates',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: _isCheckingUpdate ? PatientTheme.textSecondary : PatientTheme.textDark,
                ),
              ),
            ),
            if (_isCheckingUpdate)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(PatientTheme.primaryTeal),
                ),
              )
            else ...[
              const Text(
                'GitHub Releases',
                style: TextStyle(fontSize: 12, color: PatientTheme.textSecondary),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: PatientTheme.textMuted),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HELPER WIDGETS
  // ============================================================

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: PatientTheme.textSecondary),
      ),
    );
  }

  /// Tappable action tile (with chevron)
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

  /// Non-tappable display tile (no chevron)
  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String trailingText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: PatientTheme.primaryTeal, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: PatientTheme.textDark)),
          ),
          Text(trailingText, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: PatientTheme.primaryTeal)),
        ],
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
