import 'package:flutter/material.dart';
import 'calendar_screen.dart';
import 'patient_list_screen.dart';
import 'physio_dashboard.dart';
import 'profile_screen.dart';

const Color _shellCyan = Color(0xFF00AFC1);
const Color _shellLightCyan = Color(0xFFE8F9FB);
const Color _shellText = Color(0xFF123047);
const Color _shellMuted = Color(0xFF64748B);

/// Main Physio tab shell.
/// Dashboard, Patients, Calendar and Profile can be changed by tapping the
/// bottom navigation or swiping horizontally. Backend/API code is untouched.
class PhysioMainShell extends StatefulWidget {
  const PhysioMainShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<PhysioMainShell> createState() => _PhysioMainShellState();
}

class _PhysioMainShellState extends State<PhysioMainShell> {
  late final PageController _pageController;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, 3);
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectPage(int index) {
    if (index == _selectedIndex) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          if (mounted) setState(() => _selectedIndex = index);
        },
        children: const [
          PhysioDashboard(embedded: true),
          PatientListScreen(),
          CalendarScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectPage,
        backgroundColor: Colors.white,
        elevation: 10,
        shadowColor: Colors.black12,
        indicatorColor: _shellLightCyan,
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _shellText),
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: _shellMuted),
            selectedIcon: Icon(Icons.home_rounded, color: _shellCyan),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded, color: _shellMuted),
            selectedIcon: Icon(Icons.people_rounded, color: _shellCyan),
            label: 'Patients',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined, color: _shellMuted),
            selectedIcon: Icon(Icons.calendar_today_rounded, color: _shellCyan),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded, color: _shellMuted),
            selectedIcon: Icon(Icons.person_rounded, color: _shellCyan),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}