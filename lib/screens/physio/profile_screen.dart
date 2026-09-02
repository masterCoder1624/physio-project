import 'package:flutter/material.dart';
import '../../models/app_update_info.dart';
import '../../services/auth_service.dart';
import '../../services/update_service.dart';
import '../../widgets/update_dialog.dart';
import '../auth/login_screen.dart';
import 'calendar_screen.dart';
import 'patient_list_screen.dart';
import 'physio_dashboard.dart';
import 'physio_navigation.dart';

const _cyan = Color(0xFF00AFC1);
const _darkCyan = Color(0xFF008C9E);
const _lightCyan = Color(0xFFE8F9FB);
const _pageBg = Color(0xFFF7FAFC);
const _textDark = Color(0xFF123047);
const _textMuted = Color(0xFF64748B);
const _border = Color(0xFFE5EEF2);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.showBottomNavigation = true});

  final bool showBottomNavigation;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _navIndex = 4;

  String _doctorName = 'Dr. Arjun Kapoor';
  String _email = 'dr.arjun@rehabz.com';
  String _phone = '+91 99887 76655';
  String _initials = 'DA';

  final String _specialty = 'Sports & Orthopedic Physiotherapy';
  final String _clinicName = 'RehabZ Clinic';
  final String _location = 'Bandra West, Mumbai';
  final String _experience = '8 years';
  final String _consultationFee = '₹500 (online) · ₹800 (in-person)';

  // Update check state
  bool _isCheckingUpdate = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // ============================================================
  // MANUAL UPDATE CHECK — loading spinner, update dialog, or error
  // ============================================================

  Future<void> _checkForUpdates() async {
    if (_isCheckingUpdate) return;

    setState(() => _isCheckingUpdate = true);

    try {
      final AppUpdateInfo? updateInfo =
          await UpdateService.instance.checkForUpdateManual();

      if (!mounted) return;

      if (updateInfo != null && updateInfo.isUpdateAvailable) {
        showDialog(
          context: context,
          barrierDismissible: !updateInfo.isMandatory,
          builder: (ctx) => UpdateDialog(
            updateInfo: updateInfo,
            onDismiss: () {},
          ),
        );
      } else {
        final version = await UpdateService.instance.getCurrentVersion();
        if (!mounted) return;
        _showSnackBar(
          'You are using the latest version of RehabZ (v$version).',
          icon: Icons.check_circle_outline_rounded,
          color: const Color(0xFF10B981),
        );
      }
    } on UpdateException catch (e) {
      if (!mounted) return;
      _showSnackBar(
        e.message,
        icon: Icons.error_outline_rounded,
        color: const Color(0xFFEF4444),
      );
    } catch (_) {
      if (!mounted) return;
      _showSnackBar(
        'Unable to check for updates. Please check your internet connection and try again.',
        icon: Icons.error_outline_rounded,
        color: const Color(0xFFEF4444),
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
                style: const TextStyle(
                  color: Color(0xFF123047),
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
        if (user.email.isNotEmpty) _email = user.email;
        if (user.phone != null && user.phone!.isNotEmpty) _phone = user.phone!;
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
    PhysioNavigation.pushAndClear(context, const LoginScreen());
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return PhysioSystemUi(
      statusBarColor: _lightCyan,
      statusBarBrightness: Brightness.light,
      child: Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                child: Column(
                  children: [
                    _buildStats(),
                    const SizedBox(height: 18),
                    _buildPersonalInfo(),
                    const SizedBox(height: 18),
                    _buildProfessionalInfo(),
                    const SizedBox(height: 18),
                    _buildSettings(),
                    const SizedBox(height: 14),
                    _buildLogout(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: widget.showBottomNavigation ? _buildBottomNavigationBar() : null,
    ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFDFFBFD), Color(0xFF8BE4EA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile',
                      style: TextStyle(
                        color: _textDark,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Manage your account',
                      style: TextStyle(color: _textMuted, fontSize: 14),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => _message('Edit profile'),
                icon: const Icon(Icons.edit_outlined, size: 18, color: _darkCyan),
                label: const Text(
                  'Edit Profile',
                  style: TextStyle(color: _darkCyan, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: _darkCyan.withValues(alpha: .10),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Transform.translate(
                  offset: const Offset(0, -28),
                  child: Stack(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: _lightCyan,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 5),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x22000000),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _initials,
                          style: const TextStyle(
                            color: _darkCyan,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: InkWell(
                          onTap: () => _message('Edit profile photo'),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: _cyan,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, color: Colors.white, size: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -12),
                  child: Column(
                    children: [
                      Text(
                        _doctorName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: _textDark,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _specialty,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: _cyan,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 19),
                          const SizedBox(width: 5),
                          const Text('4.9 Rating', style: TextStyle(color: _textMuted, fontWeight: FontWeight.w600)),
                          _headerDivider(),
                          const Icon(Icons.calendar_month_outlined, color: _cyan, size: 18),
                          const SizedBox(width: 5),
                          Text('$_experience Experience', style: const TextStyle(color: _textMuted, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerDivider() => Container(
        width: 1,
        height: 18,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        color: _border,
      );

  Widget _buildStats() {
    return _card(
      child: Row(
        children: [
          Expanded(child: _stat('5+', 'Patients', Icons.people_outline)),
          _verticalDivider(),
          Expanded(child: _stat('47', 'Sessions', Icons.calendar_month_outlined)),
          _verticalDivider(),
          Expanded(child: _stat('4.9', 'Rating', Icons.star_outline_rounded)),
        ],
      ),
    );
  }

  Widget _stat(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(color: _lightCyan, shape: BoxShape.circle),
          child: Icon(icon, color: _cyan, size: 22),
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: _textDark, fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: _textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _verticalDivider() => Container(width: 1, height: 70, color: _border);

  Widget _buildPersonalInfo() {
    return _sectionCard(
      title: 'Personal Information',
      onEdit: () => _message('Edit personal information'),
      children: [
        _infoItem(Icons.person_outline, 'Full Name', _doctorName),
        _infoItem(Icons.email_outlined, 'Email', _email),
        _infoItem(Icons.phone_outlined, 'Phone', _phone),
      ],
    );
  }

  Widget _buildProfessionalInfo() {
    return _sectionCard(
      title: 'Professional Information',
      onEdit: () => _message('Edit professional information'),
      children: [
        _infoItem(Icons.business_outlined, 'Clinic', _clinicName),
        _infoItem(Icons.medical_services_outlined, 'Specialization', _specialty),
        _infoItem(Icons.location_on_outlined, 'Location', _location),
        _infoItem(Icons.access_time_outlined, 'Experience', _experience),
        _infoItem(Icons.currency_rupee, 'Consultation Fees', _consultationFee),
      ],
    );
  }

  Widget _sectionCard({required String title, required VoidCallback onEdit, required List<Widget> children}) {
    return _card(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: const TextStyle(color: _textDark, fontSize: 17, fontWeight: FontWeight.w800)),
              ),
              TextButton(
                onPressed: onEdit,
                child: const Text('Edit', style: TextStyle(color: _darkCyan, fontWeight: FontWeight.w700)),
              ),
              const Icon(Icons.chevron_right, color: _cyan, size: 20),
            ],
          ),
          const SizedBox(height: 2),
          ...children,
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: _lightCyan, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: _cyan, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: _textMuted, fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 3),
                Text(value, style: const TextStyle(color: _textDark, fontSize: 14, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return _card(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text('Settings', style: TextStyle(color: _textDark, fontSize: 17, fontWeight: FontWeight.w800)),
          ),
          _setting(Icons.settings_outlined, 'Account Settings', () => _message('Account settings')),
          _setting(Icons.notifications_none_outlined, 'Notifications', () => _message('Notifications')),

          // ── About & Updates ────────────────────────────────
          const Divider(height: 1, color: _border, indent: 16, endIndent: 16),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Text(
              'About & Updates',
              style: TextStyle(color: _textMuted, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.3),
            ),
          ),

          // App Version — dynamic via package_info_plus
          FutureBuilder<String>(
            future: UpdateService.instance.getCurrentVersion(),
            builder: (context, snapshot) {
              final version = snapshot.data ?? '—';
              return ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: const Icon(Icons.info_outline_rounded, color: _textMuted, size: 22),
                title: const Text('App Version', style: TextStyle(color: _textDark, fontSize: 14, fontWeight: FontWeight.w600)),
                trailing: snapshot.connectionState == ConnectionState.done
                    ? Text('v$version', style: const TextStyle(color: _cyan, fontWeight: FontWeight.w700, fontSize: 13))
                    : const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: _cyan)),
              );
            },
          ),

          // Check for Updates — loading-aware tile
          ListTile(
            onTap: _isCheckingUpdate ? null : _checkForUpdates,
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: Icon(
              Icons.system_update_rounded,
              color: _isCheckingUpdate ? _textMuted : _textMuted,
              size: 22,
            ),
            title: Text(
              _isCheckingUpdate ? 'Checking for updates...' : 'Check for Updates',
              style: TextStyle(
                color: _isCheckingUpdate ? _textMuted : _textDark,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: _isCheckingUpdate
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: _cyan),
                  )
                : const Icon(Icons.chevron_right, color: _textMuted, size: 20),
          ),

          const Divider(height: 1, color: _border, indent: 16, endIndent: 16),
          // ── End About & Updates ────────────────────────────

          _setting(Icons.help_outline, 'Help & Support', () => _message('Help & Support')),
          _setting(Icons.shield_outlined, 'Privacy & Security', () => _message('Privacy & Security')),
        ],
      ),
    );
  }

  Widget _setting(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(icon, color: _textMuted, size: 22),
      title: Text(title, style: const TextStyle(color: _textDark, fontSize: 14, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right, color: _textMuted, size: 20),
    );
  }

  Widget _buildLogout() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: _signOut,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFD7DC)),
            color: const Color(0xFFFFF7F8),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, color: Color(0xFFEF4444), size: 20),
              SizedBox(width: 9),
              Text('Logout', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child, EdgeInsetsGeometry padding = const EdgeInsets.all(14)}) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(color: Color(0x0A123047), blurRadius: 14, offset: Offset(0, 5)),
        ],
      ),
      child: child,
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _border)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_outlined, 'Home', 0, () => PhysioNavigation.replace(context, const PhysioDashboard())),
          _navItem(Icons.people_outline, 'Patients', 1, () => PhysioNavigation.replace(context, const PatientListScreen())),
          _navItem(Icons.calendar_today_outlined, 'Calendar', 2, () => PhysioNavigation.replace(context, const CalendarScreen())),
          _navItem(Icons.trending_up, 'Analytics', 3, () => setState(() => _navIndex = 3)),
          _navItem(Icons.person_outline, 'Profile', 4, () => setState(() => _navIndex = 4)),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index, VoidCallback onTap) {
    final selected = _navIndex == index;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? _lightCyan : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? _cyan : _textMuted, size: 22),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(color: selected ? _cyan : _textMuted, fontSize: 10.5, fontWeight: selected ? FontWeight.w800 : FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}