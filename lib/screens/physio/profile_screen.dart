import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'calendar_screen.dart';
import 'patient_list_screen.dart';
import 'physio_dashboard.dart';

const Color _kPrimaryBlue = Color(0xFF10B981);
const Color _kTealGreen = Color(0xFF2E5A44);
const Color _kTextDark = Color(0xFFF8FAFC);
const Color _kTextSecondary = Color(0xFFA7F3D0);
const Color _kTextMuted = Color(0xFF6EE7B7);
const Color _kPageBg = Color(0xFF0F1F17);
const Color _kCardBg = Color(0xFF183326);
const Color _kBorderColor = Color(0xFF254B37);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _navIndex = 4; // Profile tab selected

  String _doctorName = 'Dr. Arjun Kapoor';
  final String _specialty = 'Sports & Orthopedic Physiotherapy';
  final String _clinicName = 'PhysioVerse Clinic';
  final String _location = 'Bandra West, Mumbai';
  final String _experience = '8 years';
  final String _consultationFee = '₹500 (online) · ₹800 (in-person)';
  String _email = 'dr.arjun@physioverse.com';
  String _phone = '+91 99887 76655';
  String _initials = 'DA';
  String _selectedProfileView = 'Profile';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = await AuthService().getProfile();
      if (!mounted) return;
      setState(() {
        if (user.fullName.isNotEmpty) {
          _doctorName = user.fullName.startsWith('Dr.')
              ? user.fullName
              : 'Dr. ${user.fullName}';
          _initials = _getInitials(user.fullName);
        }
        if (user.email.isNotEmpty) {
          _email = user.email;
        }
        if (user.phone != null && user.phone!.isNotEmpty) {
          _phone = user.phone!;
        }
      });
    } catch (_) {}
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length > 1 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Future<void> _signOut() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kPageBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Hero Header Banner
            _buildHeroHeader(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  // Quick Stats Row (5+ Patients, 47 Sessions, 4.9 Rating)
                  _buildQuickStatsRow(),
                  const SizedBox(height: 20),

                  // Practice Info Card Section
                  _buildPracticeInfoCard(),
                  const SizedBox(height: 20),

                  // Contact Details Card Section
                  _buildContactDetailsCard(),
                  const SizedBox(height: 20),

                  // Settings Options Card (Account settings, Subscription, Help, Privacy, Logout)
                  _buildSettingsOptionsCard(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// Top Gradient Hero Header with Avatar, Edit Badge, Name, Specialty, Rating, and Teal Pill
  Widget _buildHeroHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3A2B), Color(0xFF12261C)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 28),
      child: Column(
        children: [
          // Top Right Teal Pill Dropdown
          Align(
            alignment: Alignment.topRight,
            child: PopupMenuButton<String>(
              onSelected: (val) {
                setState(() {
                  _selectedProfileView = val;
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'Profile 20 screens',
                  child: Text('Profile 20 screens'),
                ),
                const PopupMenuItem(
                  value: 'Public Doctor View',
                  child: Text('Public Doctor View'),
                ),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _kTealGreen,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _kTealGreen.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _selectedProfileView == 'Profile'
                          ? 'Profile 20 screens'
                          : _selectedProfileView,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Avatar Circle with Edit Badge Pencil Button
          Stack(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: _kTealGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edit profile avatar')),
                    );
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 16,
                      color: _kPrimaryBlue,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Doctor Name
          Text(
            _doctorName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),

          // Specialty
          Text(
            _specialty,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 10),

          // Rating & Experience Badge
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Color(0xFFFFC107), size: 16),
              const SizedBox(width: 4),
              const Text(
                '4.9',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '·  8 years experience',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Quick Stats Row (5+ Patients, 47 Sessions, 4.9 Rating)
  Widget _buildQuickStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('5+', 'Patients')),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('47', 'Sessions')),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('4.9', 'Rating')),
      ],
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _kTextDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: _kTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Practice Info Card Section
  Widget _buildPracticeInfoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Practice info',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _kTextDark,
                ),
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit Practice info')),
                  );
                },
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _kPrimaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Fields
          _buildInfoRow('Clinic name', _clinicName),
          const Divider(color: _kBorderColor, height: 24),
          _buildInfoRow('Location', _location),
          const Divider(color: _kBorderColor, height: 24),
          _buildInfoRow('Experience', _experience),
          const Divider(color: _kBorderColor, height: 24),
          _buildInfoRow('Consultation fee', _consultationFee),
        ],
      ),
    );
  }

  /// Contact Details Card Section
  Widget _buildContactDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Contact details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _kTextDark,
                ),
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit Contact details')),
                  );
                },
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _kPrimaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Fields
          _buildInfoRow('Email', _email),
          const Divider(color: _kBorderColor, height: 24),
          _buildInfoRow('Phone', _phone),
        ],
      ),
    );
  }

  /// Key-Value row for info cards
  Widget _buildInfoRow(String key, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            key,
            style: const TextStyle(
              fontSize: 14,
              color: _kTextSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _kTextDark,
            ),
          ),
        ),
      ],
    );
  }

  /// Settings Options Card (Account settings, Subscription, Help, Privacy, Logout)
  Widget _buildSettingsOptionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.settings_outlined,
            iconColor: const Color(0xFF8B5CF6),
            title: 'Account settings',
            onTap: () {},
          ),
          const Divider(color: _kBorderColor, height: 1),
          _buildSettingsTile(
            icon: Icons.workspace_premium_outlined,
            iconColor: const Color(0xFF0EA5E9),
            title: 'Subscription & plans',
            onTap: () {},
          ),
          const Divider(color: _kBorderColor, height: 1),
          _buildSettingsTile(
            icon: Icons.help_outline,
            iconColor: const Color(0xFFEF4444),
            title: 'Help & support',
            onTap: () {},
          ),
          const Divider(color: _kBorderColor, height: 1),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            iconColor: const Color(0xFFF97316),
            title: 'Privacy policy',
            onTap: () {},
          ),
          const Divider(color: _kBorderColor, height: 1),
          _buildSettingsTile(
            icon: Icons.logout,
            iconColor: Colors.redAccent,
            title: 'Logout',
            titleColor: Colors.redAccent,
            onTap: _signOut,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: titleColor ?? _kTextDark,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: _kTextMuted,
        size: 20,
      ),
    );
  }

  /// Bottom Navigation Bar matching screenshot with 5 tabs and active line indicator
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
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const PhysioDashboard()),
              );
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
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const CalendarScreen()),
              );
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
            icon: Icons.settings_outlined,
            label: 'Profile',
            isSelected: _navIndex == 4,
            onTap: () {
              setState(() => _navIndex = 4);
            },
          ),
        ],
      ),
    );
  }

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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? _kPrimaryBlue : _kTextMuted,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? _kPrimaryBlue : _kTextMuted,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              height: 2,
              width: 22,
              color: isSelected ? _kPrimaryBlue : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
