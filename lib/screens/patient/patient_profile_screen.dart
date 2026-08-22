import 'package:flutter/material.dart';
import '../../constants/patient_theme.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'patient_components.dart';
import 'patient_edit_profile_screen.dart';
import 'patient_settings_screen.dart';

/// Screen 20 — Patient Profile Screen (matching media_1787385006975.jpg)
class PatientProfileScreen extends StatelessWidget {
  const PatientProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out of PhysioVerse?'),
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
          'My Profile',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile Header Card (matching screenshot)
          PatientCard(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: PatientTheme.primaryTeal,
                  child: const Text(
                    'AR',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Anshu Reddy',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: PatientTheme.textDark,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        '+91 98765 43210',
                        style: TextStyle(fontSize: 12, color: PatientTheme.textSecondary),
                      ),
                      SizedBox(height: 1),
                      Text(
                        'anshu@gmail.com',
                        style: TextStyle(fontSize: 12, color: PatientTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: PatientTheme.primaryTeal, size: 20),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PatientEditProfileScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Menu Options (matching screenshot)
          PatientCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildMenuRow(
                  icon: Icons.person_outline_rounded,
                  title: 'Personal Information',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PatientEditProfileScreen()),
                    );
                  },
                ),
                const Divider(height: 1, color: PatientTheme.border),
                _buildMenuRow(
                  icon: Icons.contact_emergency_outlined,
                  title: 'Emergency Contact',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Emergency contact: Rajesh Reddy (+91 98765 11223)')),
                    );
                  },
                ),
                const Divider(height: 1, color: PatientTheme.border),
                _buildMenuRow(
                  icon: Icons.medical_information_outlined,
                  title: 'Health Information',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Blood Group: O+ • Height: 168 cm • Weight: 64 kg')),
                    );
                  },
                ),
                const Divider(height: 1, color: PatientTheme.border),
                _buildMenuRow(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PatientSettingsScreen()),
                    );
                  },
                ),
                const Divider(height: 1, color: PatientTheme.border),
                _buildMenuRow(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () {},
                ),
                const Divider(height: 1, color: PatientTheme.border),
                _buildMenuRow(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Support',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Logout Action (matching screenshot red logout)
          Center(
            child: InkWell(
              onTap: () => _handleLogout(context),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.logout_rounded, color: PatientTheme.errorRed, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: PatientTheme.errorRed,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuRow({
    required IconData icon,
    required String title,
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
              child: Text(
                title,
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: PatientTheme.textDark),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: PatientTheme.textMuted),
          ],
        ),
      ),
    );
  }
}
