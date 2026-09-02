import 'package:flutter/material.dart';
import '../../models/patient_model.dart';
import '../../services/patient_service.dart';
import 'add_patient_screen.dart';
import 'calendar_screen.dart';
import 'patient_detail_screen.dart';
import 'physio_dashboard.dart';
import 'profile_screen.dart';
import 'physio_navigation.dart';
import 'dart:async';

// Physio Patients UI theme — preserved exactly.
const Color _kPrimaryCyan = Color(0xFF00AFC1);
const Color _kDarkCyan = Color(0xFF008C9E);
const Color _kLightCyan = Color(0xFFE8F9FB);
const Color _kPageBg = Color(0xFFF7FAFC);
const Color _kCardBg = Colors.white;
const Color _kTextDark = Color(0xFF123047);
const Color _kTextSecondary = Color(0xFF64748B);
const Color _kTextMuted = Color(0xFF94A3B8);
const Color _kBorderColor = Color(0xFFE5EEF2);

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key, this.showBottomNavigation = true});

  final bool showBottomNavigation;

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final PatientService _patientService = PatientService();
  final TextEditingController _searchController = TextEditingController();

  List<_PatientItem> _allPatients = [];
  List<_PatientItem> _filteredPatients = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  String _sortBy = 'Default';
  final int _navIndex = 1;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchPatients();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchPatients() async {
    if (mounted) setState(() => _isLoading = true);

    try {
      final models = await _patientService.getPatients();
      if (!mounted) return;

      final patients = models.map((m) {
        String formattedDate = '—';
        if (m.createdAt != null && m.createdAt!.isNotEmpty) {
          final dt = DateTime.tryParse(m.createdAt!);
          if (dt != null) {
            const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            formattedDate = '${dt.day} ${months[dt.month - 1]} ${dt.year}';
          } else {
            formattedDate = m.createdAt!.length >= 10 ? m.createdAt!.substring(0, 10) : m.createdAt!;
          }
        }

        String genderDisplay = '—';
        if (m.gender != null && m.gender!.isNotEmpty) {
          final g = m.gender!.trim().toLowerCase();
          genderDisplay = g.length > 1 ? '${g[0].toUpperCase()}${g.substring(1)}' : g.toUpperCase();
        }

        String ageDisplay = m.age.isNotEmpty ? (m.age.endsWith('yrs') ? m.age : '${m.age} yrs') : '—';

        return _PatientItem(
          id: m.id ?? '',
          name: m.name.isNotEmpty ? m.name : 'Patient',
          condition: m.condition.isNotEmpty ? m.condition : 'Physical Rehabilitation',
          status: m.status.toUpperCase(),
          age: ageDisplay,
          rawAge: m.age,
          gender: genderDisplay,
          lastVisit: formattedDate,
          phone: m.phone != null && m.phone!.isNotEmpty ? m.phone! : '—',
          createdAt: m.createdAt,
          initials: _getInitials(m.name),
          avatarBgColor: _kPrimaryCyan,
        );
      }).toList();

      setState(() {
        _allPatients = patients;
        _filteredPatients = _filterPatients(patients);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _allPatients = [];
        _filteredPatients = [];
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 160), () {
      if (!mounted) return;
      setState(() {
        _filteredPatients = _filterPatients(_allPatients);
      });
    });
  }

  List<_PatientItem> _filterPatients(List<_PatientItem> patients) {
    final query = _searchController.text.trim().toLowerCase();

    final filtered = patients.where((patient) {
      final matchesQuery = query.isEmpty ||
          patient.name.toLowerCase().contains(query) ||
          patient.condition.toLowerCase().contains(query) ||
          patient.phone.toLowerCase().contains(query) ||
          patient.id.toLowerCase().contains(query);

      final matchesStatus = _selectedFilter == 'All' ||
          (_selectedFilter == 'Active' && patient.status == 'ACTIVE') ||
          (_selectedFilter == 'Pending' && patient.status == 'PENDING') ||
          (_selectedFilter == 'Completed' && patient.status == 'COMPLETED');

      return matchesQuery && matchesStatus;
    }).toList();

    int compareNames(_PatientItem a, _PatientItem b) =>
        a.name.toLowerCase().compareTo(b.name.toLowerCase());

    int compareAge(_PatientItem a, _PatientItem b) =>
        (int.tryParse(a.rawAge) ?? 0).compareTo(int.tryParse(b.rawAge) ?? 0);

    DateTime? createdDate(_PatientItem patient) => patient.createdAt == null
        ? null
        : DateTime.tryParse(patient.createdAt!);

    switch (_sortBy) {
      case 'Name: A → Z':
        filtered.sort(compareNames);
        break;
      case 'Name: Z → A':
        filtered.sort((a, b) => compareNames(b, a));
        break;
      case 'Age: Low → High':
        filtered.sort(compareAge);
        break;
      case 'Age: High → Low':
        filtered.sort((a, b) => compareAge(b, a));
        break;
      case 'Recently Added':
        filtered.sort((a, b) {
          final ad = createdDate(a);
          final bd = createdDate(b);
          if (ad == null && bd == null) return 0;
          if (ad == null) return 1;
          if (bd == null) return -1;
          return bd.compareTo(ad);
        });
        break;
    }

    return filtered;
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'PT';
    if (parts.length == 1) {
      final value = parts.first;
      return value.substring(0, value.length > 1 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return PhysioSystemUi(
      statusBarColor: Colors.white,
      statusBarBrightness: Brightness.light,
      child: Scaffold(
        backgroundColor: _kPageBg,
        body: SafeArea(
          child: RefreshIndicator(
            color: _kPrimaryCyan,
            onRefresh: _fetchPatients,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildHeader(),
                      const SizedBox(height: 18),
                      _buildSearchBar(),
                      const SizedBox(height: 14),
                      _buildFilterBar(),
                      const SizedBox(height: 18),
                      _buildListHeader(),
                      const SizedBox(height: 10),
                    ]),
                  ),
                ),
                if (_isLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _LoadingState(),
                  )
                else if (_allPatients.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _ZeroPatientsEmptyState(onAddPatient: _openAddPatient),
                  )
                else if (_filteredPatients.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _NoSearchResultsEmptyState(
                      onResetSearch: () {
                        _searchController.clear();
                        setState(() {
                          _selectedFilter = 'All';
                          _filteredPatients = _allPatients;
                        });
                      },
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    sliver: SliverList.builder(
                      itemCount: _filteredPatients.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == _filteredPatients.length - 1 ? 0 : 12,
                          ),
                          child: _buildPatientCard(_filteredPatients[index]),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: widget.showBottomNavigation ? _buildBottomNavigationBar() : null,
        floatingActionButton: FloatingActionButton(
          onPressed: _openAddPatient,
          backgroundColor: _kPrimaryCyan,
          foregroundColor: Colors.white,
          elevation: 4,
          child: const Icon(Icons.add_rounded, size: 28),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Patients',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: _kTextDark,
                  letterSpacing: -0.6,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Manage your patients',
                style: TextStyle(
                  fontSize: 14,
                  color: _kTextSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        _addPatientButton(),
      ],
    );
  }

  Widget _addPatientButton() {
    return ElevatedButton.icon(
      onPressed: _openAddPatient,
      icon: const Icon(Icons.add_rounded, size: 19),
      label: const Text('Add Patient'),
      style: ElevatedButton.styleFrom(
        backgroundColor: _kPrimaryCyan,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorderColor),
        boxShadow: [
          BoxShadow(
            color: _kDarkCyan.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        style: const TextStyle(
          fontSize: 14,
          color: _kTextDark,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Search by name, ID, phone or condition...',
          hintStyle: const TextStyle(color: _kTextMuted, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: _kPrimaryCyan),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  onPressed: _searchController.clear,
                  icon: const Icon(Icons.close_rounded, size: 19),
                  color: _kTextMuted,
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    const filters = ['All', 'Active', 'Pending', 'Completed'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final selected = _selectedFilter == filter;
          int count = 0;
          if (filter == 'All') {
            count = _allPatients.length;
          } else if (filter == 'Active') {
            count = _allPatients.where((p) => p.status == 'ACTIVE').length;
          } else if (filter == 'Pending') {
            count = _allPatients.where((p) => p.status == 'PENDING').length;
          } else if (filter == 'Completed') {
            count = _allPatients.where((p) => p.status == 'COMPLETED').length;
          }

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                  _filteredPatients = _filterPatients(_allPatients);
                });
              },
              borderRadius: BorderRadius.circular(22),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selected ? _kPrimaryCyan : _kCardBg,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: selected ? _kPrimaryCyan : _kBorderColor,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      filter,
                      style: TextStyle(
                        color: selected ? Colors.white : _kTextSecondary,
                        fontSize: 13,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: selected ? Colors.white.withValues(alpha: 0.25) : _kLightCyan,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            color: selected ? Colors.white : _kDarkCyan,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildListHeader() {
    return Row(
      children: [
        Text(
          '${_filteredPatients.length} ${_filteredPatients.length == 1 ? 'Patient' : 'Patients'}',
          style: const TextStyle(
            color: _kTextDark,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        if (_selectedFilter != 'All') ...[
          Text(
            _selectedFilter,
            style: const TextStyle(
              color: _kPrimaryCyan,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
        ],
        _buildSortButton(),
      ],
    );
  }

  Widget _buildSortButton() {
    return PopupMenuButton<String>(
      tooltip: 'Sort patients',
      onSelected: (value) {
        setState(() {
          _sortBy = value;
          _filteredPatients = _filterPatients(_allPatients);
        });
      },
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      offset: const Offset(0, 42),
      itemBuilder: (context) => [
        _sortMenuItem('Default', 'Default order'),
        _sortMenuItem('Name: A → Z', 'Name: A → Z'),
        _sortMenuItem('Name: Z → A', 'Name: Z → A'),
        _sortMenuItem('Age: Low → High', 'Age: Low → High'),
        _sortMenuItem('Age: High → Low', 'Age: High → Low'),
        _sortMenuItem('Recently Added', 'Recently Added'),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: _sortBy == 'Default' ? _kCardBg : _kLightCyan,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _sortBy == 'Default' ? _kBorderColor : _kPrimaryCyan,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.swap_vert_rounded, size: 17, color: _kPrimaryCyan),
            const SizedBox(width: 5),
            Text(
              'Sort by',
              style: TextStyle(
                color: _sortBy == 'Default' ? _kTextSecondary : _kDarkCyan,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 17, color: _kTextMuted),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _sortMenuItem(String value, String label) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            _sortBy == value
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_off_rounded,
            size: 18,
            color: _sortBy == value ? _kPrimaryCyan : _kTextMuted,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: _kTextDark,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(_PatientItem patient) {
    return Container(
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _patientAvatar(patient),
                const SizedBox(width: 12),
                Expanded(child: _patientMainInfo(patient)),
                _buildStatusBadge(patient.status),
                const SizedBox(width: 4),
                _buildPatientMenu(patient),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: _kLightCyan.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kBorderColor),
              ),
              child: Row(
                children: [
                  Expanded(child: _cardInfo(Icons.person_outline_rounded, patient.age, 'Age')),
                  _verticalDivider(),
                  Expanded(child: _cardInfo(Icons.wc_rounded, patient.gender, 'Gender')),
                  _verticalDivider(),
                  Expanded(child: _cardInfo(Icons.calendar_today_outlined, patient.lastVisit, 'Added on')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF4FBFC),
              border: Border(top: BorderSide(color: _kBorderColor)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _cardAction(
                    icon: Icons.visibility_outlined,
                    label: 'View Profile',
                    onTap: () => _openPatient(patient.id, 0),
                  ),
                ),
                Container(width: 1, height: 24, color: _kBorderColor),
                Expanded(
                  child: _cardAction(
                    icon: Icons.note_add_outlined,
                    label: 'Add Note',
                    onTap: () => _openPatient(patient.id, 1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // THREE-DOT ACTION MENU (View, Edit, Change Status, Delete)
  // ============================================================
  Widget _buildPatientMenu(_PatientItem patient) {
    return PopupMenuButton<String>(
      tooltip: 'Patient actions',
      padding: EdgeInsets.zero,
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      offset: const Offset(-8, 40),
      onSelected: (value) => _handlePatientAction(value, patient),
      itemBuilder: (context) => [
        _patientMenuItem(
          value: 'view',
          icon: Icons.person_outline_rounded,
          label: 'View Profile',
        ),
        _patientMenuItem(
          value: 'edit',
          icon: Icons.edit_outlined,
          label: 'Edit Patient',
        ),
        _patientMenuItem(
          value: 'status',
          icon: Icons.swap_horiz_rounded,
          label: 'Change Status',
        ),
        const PopupMenuDivider(height: 8),
        _patientMenuItem(
          value: 'delete',
          icon: Icons.delete_outline_rounded,
          label: 'Delete Patient',
          isDestructive: true,
        ),
      ],
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: _kLightCyan,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _kBorderColor),
        ),
        child: const Icon(
          Icons.more_horiz_rounded,
          color: _kDarkCyan,
          size: 20,
        ),
      ),
    );
  }

  PopupMenuItem<String> _patientMenuItem({
    required String value,
    required IconData icon,
    required String label,
    bool isDestructive = false,
  }) {
    return PopupMenuItem<String>(
      value: value,
      height: 44,
      child: Row(
        children: [
          Icon(
            icon,
            size: 19,
            color: isDestructive ? const Color(0xFFEF4444) : _kPrimaryCyan,
          ),
          const SizedBox(width: 11),
          Text(
            label,
            style: TextStyle(
              color: isDestructive ? const Color(0xFFDC2626) : _kTextDark,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _handlePatientAction(String action, _PatientItem patient) {
    switch (action) {
      case 'view':
        _openPatient(patient.id, 0);
        break;
      case 'edit':
        _showEditPatientBottomSheet(patient);
        break;
      case 'status':
        _showChangeStatusBottomSheet(patient);
        break;
      case 'delete':
        _showDeleteConfirmation(patient);
        break;
    }
  }

  // ============================================================
  // STATUS CHANGE BOTTOM SHEET
  // ============================================================
  void _showChangeStatusBottomSheet(_PatientItem patient) {
    String currentStatus = patient.status.toUpperCase();
    String selectedStatus = currentStatus;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Change Patient Status',
                          style: TextStyle(
                            color: _kTextDark,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: _kTextMuted),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    Text(
                      'Select current treatment status for ${patient.name}',
                      style: const TextStyle(color: _kTextSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 18),
                    _statusOptionTile(
                      label: 'Active',
                      value: 'ACTIVE',
                      subtitle: 'Currently undergoing active therapy',
                      bg: const Color(0xFFEAF9F0),
                      fg: const Color(0xFF159447),
                      selected: selectedStatus == 'ACTIVE',
                      onTap: () => setSheetState(() => selectedStatus = 'ACTIVE'),
                    ),
                    const SizedBox(height: 10),
                    _statusOptionTile(
                      label: 'Pending',
                      value: 'PENDING',
                      subtitle: 'Awaiting assessment or scheduled to start',
                      bg: const Color(0xFFFFF7ED),
                      fg: const Color(0xFFC2410C),
                      selected: selectedStatus == 'PENDING',
                      onTap: () => setSheetState(() => selectedStatus = 'PENDING'),
                    ),
                    const SizedBox(height: 10),
                    _statusOptionTile(
                      label: 'Completed',
                      value: 'COMPLETED',
                      subtitle: 'Treatment protocol finished successfully',
                      bg: const Color(0xFFE8F9FB),
                      fg: const Color(0xFF008C9E),
                      selected: selectedStatus == 'COMPLETED',
                      onTap: () => setSheetState(() => selectedStatus = 'COMPLETED'),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          Navigator.pop(ctx);
                          await _patientService.updatePatientStatus(patient.id, selectedStatus);
                          if (!mounted) return;
                          _fetchPatients();
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Patient status updated successfully.'),
                              backgroundColor: Color(0xFF159447),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kPrimaryCyan,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _statusOptionTile({
    required String label,
    required String value,
    required String subtitle,
    required Color bg,
    required Color fg,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? bg : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? fg : _kBorderColor,
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? fg : _kTextMuted,
                  width: selected ? 6 : 1.5,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: selected ? fg : _kTextDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: _kTextSecondary, fontSize: 11.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EDIT PATIENT BOTTOM SHEET
  // ============================================================
  void _showEditPatientBottomSheet(_PatientItem patient) {
    final nameCtrl = TextEditingController(text: patient.name);
    final conditionCtrl = TextEditingController(text: patient.condition);
    final phoneCtrl = TextEditingController(text: patient.phone == '—' ? '' : patient.phone);
    final ageCtrl = TextEditingController(text: patient.rawAge);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Patient',
                    style: TextStyle(
                      color: _kTextDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: _kTextMuted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  filled: true,
                  fillColor: _kPageBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _kBorderColor),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: conditionCtrl,
                decoration: InputDecoration(
                  labelText: 'Primary Condition / Injury',
                  filled: true,
                  fillColor: _kPageBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _kBorderColor),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: ageCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Age',
                        filled: true,
                        fillColor: _kPageBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: _kBorderColor),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone',
                        filled: true,
                        fillColor: _kPageBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: _kBorderColor),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(ctx);
                    final updatedModel = PatientModel(
                      id: patient.id,
                      name: nameCtrl.text.trim(),
                      condition: conditionCtrl.text.trim(),
                      age: ageCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                      status: patient.status,
                    );
                    await _patientService.updatePatient(updatedModel);
                    if (!mounted) return;
                    _fetchPatients();
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Patient updated successfully.')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimaryCyan,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // DELETION CONFIRMATION DIALOG
  // ============================================================
  Future<void> _showDeleteConfirmation(_PatientItem patient) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Delete Patient?',
          style: TextStyle(
            color: _kTextDark,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${patient.name}?\nThis action cannot be undone.',
          style: const TextStyle(color: _kTextSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: _kTextSecondary, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              final success = await _patientService.deletePatient(patient.id);
              if (!mounted) return;
              if (success) {
                setState(() {
                  _allPatients.removeWhere((p) => p.id == patient.id);
                  _filteredPatients = _filterPatients(_allPatients);
                });
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Patient deleted successfully.'),
                    backgroundColor: Color(0xFFDC2626),
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Color(0xFFDC2626),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardInfo(IconData icon, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: _kPrimaryCyan, size: 20),
        const SizedBox(height: 5),
        Text(
          value.isEmpty ? '—' : value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _kTextDark,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: _kTextSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(width: 1, height: 38, color: _kBorderColor);
  }

  Widget _cardAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: _kPrimaryCyan, size: 18),
            const SizedBox(width: 7),
            Text(
              label,
              style: const TextStyle(
                color: _kDarkCyan,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _patientAvatar(_PatientItem patient) {
    return CircleAvatar(
      radius: 25,
      backgroundColor: _kLightCyan,
      child: CircleAvatar(
        radius: 22,
        backgroundColor: patient.avatarBgColor,
        child: Text(
          patient.initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _patientMainInfo(_PatientItem patient) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          patient.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _kTextDark,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          patient.id.isEmpty ? 'Patient' : 'ID: ${patient.id}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _kTextMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: _kLightCyan,
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Icon(
                Icons.accessibility_new_rounded,
                size: 15,
                color: _kPrimaryCyan,
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                patient.condition,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _kTextSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    final style = _statusStyle(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        style.label,
        style: TextStyle(
          color: style.foreground,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  _StatusStyle _statusStyle(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return const _StatusStyle(
          'Active',
          Color(0xFFEAF9F0),
          Color(0xFF159447),
        );
      case 'PENDING':
        return const _StatusStyle(
          'Pending',
          Color(0xFFFFF7ED),
          Color(0xFFC2410C),
        );
      case 'COMPLETED':
        return const _StatusStyle(
          'Completed',
          Color(0xFFE8F9FB),
          Color(0xFF008C9E),
        );
      case 'NEED FOLLOWUP':
        return const _StatusStyle(
          'Follow-up',
          Color(0xFFFFE9E7),
          Color(0xFFDC4035),
        );
      default:
        return const _StatusStyle(
          'Active',
          Color(0xFFEAF9F0),
          Color(0xFF159447),
        );
    }
  }

  Widget _buildBottomNavigationBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.only(top: 7, bottom: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: _kBorderColor)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_outlined, 'Home', 0, _returnToDashboard),
            _buildNavItem(Icons.people_outline, 'Patients', 1, () {}),
            _buildNavItem(Icons.calendar_today_outlined, 'Calendar', 2, () {
              PhysioNavigation.replace(context, const CalendarScreen());
            }),
            _buildNavItem(Icons.trending_up, 'Analytics', 3, () {}),
            _buildNavItem(Icons.person_outline, 'Profile', 4, () {
              PhysioNavigation.replace(context, const ProfileScreen());
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index,
    VoidCallback onTap,
  ) {
    final selected = _navIndex == index;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 23,
              color: selected ? _kPrimaryCyan : _kTextMuted,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: selected ? _kDarkCyan : _kTextSecondary,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              height: 2,
              width: selected ? 20 : 0,
              decoration: BoxDecoration(
                color: _kPrimaryCyan,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openPatient(String patientId, int tabIndex) {
    PhysioNavigation.push(context, PatientDetailScreen(patientId: patientId, initialTabIndex: tabIndex));
  }

  void _returnToDashboard() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      PhysioNavigation.replace(context, const PhysioDashboard());
    }
  }

  Future<void> _openAddPatient() async {
    final patientWasAdded = await PhysioNavigation.push<bool>(context, const AddPatientScreen());
    if (patientWasAdded == true) _fetchPatients();
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: _kPrimaryCyan, strokeWidth: 2.5),
          const SizedBox(height: 12),
          Text(
            'Loading patients...',
            style: TextStyle(
              color: _kTextSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ZeroPatientsEmptyState extends StatelessWidget {
  final VoidCallback onAddPatient;

  const _ZeroPatientsEmptyState({required this.onAddPatient});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: _kLightCyan,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_outline_rounded,
                size: 42,
                color: _kPrimaryCyan,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No patients yet',
              style: TextStyle(
                color: _kTextDark,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Start building your patient list by adding your first patient.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _kTextSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onAddPatient,
              icon: const Icon(Icons.add_rounded, size: 19),
              label: const Text('+ Add Patient'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimaryCyan,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoSearchResultsEmptyState extends StatelessWidget {
  final VoidCallback onResetSearch;

  const _NoSearchResultsEmptyState({required this.onResetSearch});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: _kLightCyan,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 42,
                color: _kPrimaryCyan,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No patients found',
              style: TextStyle(
                color: _kTextDark,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try searching using a different name, ID, phone number or condition.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _kTextSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onResetSearch,
              child: const Text('Clear Search & Filters', style: TextStyle(color: _kPrimaryCyan, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

class _PatientItem {
  final String id;
  final String name;
  final String condition;
  final String status;
  final String age;
  final String rawAge;
  final String gender;
  final String lastVisit;
  final String phone;
  final String? createdAt;
  final String initials;
  final Color avatarBgColor;

  const _PatientItem({
    required this.id,
    required this.name,
    required this.condition,
    required this.status,
    required this.age,
    required this.rawAge,
    required this.gender,
    required this.lastVisit,
    required this.phone,
    this.createdAt,
    required this.initials,
    required this.avatarBgColor,
  });
}

class _StatusStyle {
  final String label;
  final Color background;
  final Color foreground;

  const _StatusStyle(this.label, this.background, this.foreground);
}
