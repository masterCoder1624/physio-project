import 'package:flutter/material.dart';
import '../../models/clinical_models.dart';
import '../../models/patient_model.dart';
import '../../services/patient_service.dart';
import '../../services/pdf_invoice_service.dart';

const Color _primary = Color(0xFF079E9B);
const Color _primaryDark = Color(0xFF087F7C);
const Color _background = Color(0xFFF2FBFB);
const Color _textDark = Color(0xFF123047);
const Color _textMuted = Color(0xFF71869A);
const Color _border = Color(0xFFDCE8ED);
const Color _softTeal = Color(0xFFE8F7F7);
const Color _softBlue = Color(0xFFEEF7FA);
const Color _success = Color(0xFF22A06B);

class PatientDetailScreen extends StatefulWidget {
  const PatientDetailScreen({
    super.key,
    this.patient,
    this.patientId,
    this.initialTabIndex = 0,
  });

  final PatientModel? patient;
  final String? patientId;
  final int initialTabIndex;

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  PatientModel? _patient;
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex >= 0 &&
              widget.initialTabIndex < 3
          ? widget.initialTabIndex
          : 0,
    );

    _loadPatient();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPatient() async {
    try {
      PatientModel loaded;

      if (widget.patient != null) {
        loaded = widget.patient!;

        if ((loaded.id ?? '').isNotEmpty) {
          loaded = await PatientService().getPatientById(loaded.id!);
        }
      } else {
        final id = widget.patientId ?? '1';
        loaded = await PatientService().getPatientById(id);
      }

      if (!mounted) return;

      setState(() {
        _patient = loaded;
        _isLoading = false;
        _loadError = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _loadError = error
            .toString()
            .replaceFirst('Exception: ', '')
            .trim();
      });
    }
  }

  Future<void> _refreshPatient() async {
    final current = _patient;
    if (current == null) return;

    try {
      final updated = await PatientService().getPatientById(
        current.id ?? '1',
      );

      if (!mounted) return;

      setState(() {
        _patient = updated;
      });
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Unable to refresh patient details.',
        isError: true,
      );
    }
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              isError ? const Color(0xFFE74C3C) : _primaryDark,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  void _showContactMessage(String type) {
    final phone = _patient?.phone;

    if (phone == null || phone.trim().isEmpty) {
      _showMessage(
        'No phone number is available for this patient.',
        isError: true,
      );
      return;
    }

    _showMessage('$type: $phone');
  }

  Future<void> _openAddNoteModal() async {
    final patient = _patient;
    if (patient == null) return;

    final nextNum = patient.sessionNotes.length + 1;
    int pain = patient.assessment?.painLevel ?? 3;

    final noteCtrl = TextEditingController(
      text:
          'Patient demonstrates full weight bearing. Flexion improved.',
    );

    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: _softTeal,
                                borderRadius:
                                    BorderRadius.circular(13),
                              ),
                              child: const Icon(
                                Icons.note_add_outlined,
                                color: _primaryDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Clinical Note',
                                    style: const TextStyle(
                                      color: _textDark,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    'Session #$nextNum',
                                    style: const TextStyle(
                                      color: _textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(),
                              icon: const Icon(
                                Icons.close_rounded,
                                color: _textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Pain Level',
                              style: TextStyle(
                                color: _textDark,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: _softTeal,
                                borderRadius:
                                    BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$pain / 10',
                                style: const TextStyle(
                                  color: _primaryDark,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: pain.toDouble(),
                          min: 0,
                          max: 10,
                          divisions: 10,
                          activeColor: _primary,
                          inactiveColor: _border,
                          onChanged: (value) {
                            setModalState(() {
                              pain = value.round();
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Assessment / Progress Note',
                          style: TextStyle(
                            color: _textDark,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: noteCtrl,
                          maxLines: 4,
                          style: const TextStyle(
                            color: _textDark,
                            fontSize: 13,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Write your clinical observation...',
                            hintStyle: const TextStyle(
                              color: _textMuted,
                              fontSize: 13,
                            ),
                            filled: true,
                            fillColor: _background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                color: _border,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                color: _border,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                color: _primary,
                                width: 1.4,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () async {
                              final navigator = Navigator.of(context);
                              final messenger =
                                  ScaffoldMessenger.of(context);

                              final note = SessionNoteModel(
                                id:
                                    'NOTE_${DateTime.now().millisecondsSinceEpoch}',
                                sessionNumber: nextNum,
                                date: DateTime.now()
                                    .toIso8601String()
                                    .substring(0, 10),
                                painLevel: pain,
                                subjectiveNotes:
                                    'Routine clinical evaluation.',
                                objectiveFindings:
                                    noteCtrl.text.trim(),
                                treatmentRendered:
                                    'Mobilization & prescribed rehabilitation.',
                                planForNextSession:
                                    'Continue progressive exercises.',
                              );

                              try {
                                await PatientService().addSessionNote(
                                  patient.id ?? '1',
                                  note,
                                );

                                await _refreshPatient();

                                if (!mounted) return;

                                navigator.pop();

                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Clinical note added successfully.',
                                    ),
                                    backgroundColor: _success,
                                    behavior:
                                        SnackBarBehavior.floating,
                                  ),
                                );
                              } catch (error) {
                                if (!mounted) return;

                                _showMessage(
                                  'Unable to save clinical note.',
                                  isError: true,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              'Save Clinical Note',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    } finally {
      noteCtrl.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: _background,
        body: Center(
          child: CircularProgressIndicator(
            color: _primary,
          ),
        ),
      );
    }

    if (_patient == null) {
      return Scaffold(
        backgroundColor: _background,
        appBar: AppBar(
          backgroundColor: _background,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: _textDark,
            ),
          ),
          title: const Text(
            'Patient Profile',
            style: TextStyle(
              color: _textDark,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: _buildErrorState(),
      );
    }

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: RefreshIndicator(
          color: _primary,
          onRefresh: _refreshPatient,
          child: NestedScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: _buildTopSection(),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _PatientTabHeaderDelegate(
                    TabBar(
                      controller: _tabController,
                      indicatorColor: _primary,
                      indicatorWeight: 3,
                      labelColor: _primaryDark,
                      unselectedLabelColor: _textMuted,
                      labelStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                      unselectedLabelStyle:
                          const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      dividerColor: _border,
                      tabs: const [
                        Tab(text: 'Overview'),
                        Tab(text: 'Clinical Notes'),
                        Tab(text: 'Prescriptions'),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildNotesTab(),
                _buildPrescriptionsTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    final patient = _patient!;
    final patientId =
        (patient.id ?? '').isEmpty ? 'PT-0001' : patient.id!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
      child: Column(
        children: [
          Row(
            children: [
              _CircleIconButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Patient Profile',
                  style: TextStyle(
                    color: _textDark,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              _CircleIconButton(
                icon: Icons.more_horiz_rounded,
                onTap: () {
                  _showMessage(
                    'Patient actions will be available here.',
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildProfileCard(patient, patientId),
          const SizedBox(height: 14),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildProfileCard(
    PatientModel patient,
    String patientId,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF079E9B),
            Color(0xFF087F7C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.20),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.45),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    patient.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Patient ID: $patientId',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 9),
                    _statusChip(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.medical_information_outlined,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    patient.condition,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            color: Color(0xFFB8F5D5),
            size: 8,
          ),
          SizedBox(width: 6),
          Text(
            'Active Treatment',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _QuickAction(
            icon: Icons.phone_outlined,
            label: 'Call',
            onTap: () => _showContactMessage('Call'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickAction(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Message',
            onTap: () => _showContactMessage('Message'),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab() {
    final patient = _patient!;
    final assessment = patient.assessment;

    final pain = assessment?.painLevel ?? 2;
    final flexion =
        assessment?.activeRomFlexion ?? '115°';
    final extension =
        assessment?.activeRomExtension ?? '0°';

    final totalSessions =
        patient.sessionNotes.isEmpty
            ? 0
            : patient.sessionNotes.length;

    final completedSessions =
        totalSessions > 12 ? 12 : totalSessions;

    final progress = totalSessions == 0
        ? 0.0
        : (completedSessions / 12).clamp(0.0, 1.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'Patient Overview',
            'Basic information',
          ),
          const SizedBox(height: 10),
          _buildInfoGrid(patient),

          const SizedBox(height: 22),

          _sectionTitle(
            'Current Condition',
            patient.condition,
          ),
          const SizedBox(height: 10),

          _buildMetricsCard(
            pain: '$pain/10',
            flexion: flexion,
            extension: extension,
          ),

          const SizedBox(height: 22),

          _sectionTitle(
            'Treatment Progress',
            'Based on recorded clinical sessions',
          ),
          const SizedBox(height: 10),

          _buildProgressCard(
            completedSessions: completedSessions,
            progress: progress,
          ),

          const SizedBox(height: 22),

          _sectionTitle(
            'Recent Activity',
            'Latest clinical information',
          ),
          const SizedBox(height: 10),

          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(PatientModel patient) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 10) / 2;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            SizedBox(
              width: width,
              child: _InfoCard(
                icon: Icons.cake_outlined,
                label: 'Age',
                value: '${patient.age} years',
              ),
            ),
            SizedBox(
              width: width,
              child: _InfoCard(
                icon: Icons.wc_outlined,
                label: 'Gender',
                value: (patient.gender ?? 'Not specified')
                    .toUpperCase(),
              ),
            ),
            SizedBox(
              width: width,
              child: _InfoCard(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: patient.phone?.isNotEmpty == true
                    ? patient.phone!
                    : 'Not available',
              ),
            ),
            SizedBox(
              width: width,
              child: _InfoCard(
                icon: Icons.location_on_outlined,
                label: 'City',
                value: patient.city.isNotEmpty
                    ? patient.city
                    : 'Not specified',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricsCard({
    required String pain,
    required String flexion,
    required String extension,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 18,
      ),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: _Metric(
              icon: Icons.favorite_border_rounded,
              value: pain,
              label: 'Pain Level',
              accent: const Color(0xFFE26D6D),
            ),
          ),
          _verticalDivider(),
          Expanded(
            child: _Metric(
              icon: Icons.accessibility_new_rounded,
              value: flexion,
              label: 'Flexion ROM',
              accent: _primary,
            ),
          ),
          _verticalDivider(),
          Expanded(
            child: _Metric(
              icon: Icons.swap_vert_rounded,
              value: extension,
              label: 'Extension',
              accent: const Color(0xFF6D8FE2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard({
    required int completedSessions,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _softTeal,
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: _primaryDark,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recovery Progress',
                      style: TextStyle(
                        color: _textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      '12-session treatment plan',
                      style: TextStyle(
                        color: _textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: _primaryDark,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: const Color(0xFFE6EFF1),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(
                _primary,
              ),
            ),
          ),
          const SizedBox(height: 11),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$completedSessions sessions completed',
                style: const TextStyle(
                  color: _textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Text(
                'Goal: 12',
                style: TextStyle(
                  color: _textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    final notes = _patient!.sessionNotes;

    if (notes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _softBlue,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.history_rounded,
                color: _primaryDark,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'No clinical activity has been recorded yet.',
                style: TextStyle(
                  color: _textMuted,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final recent = notes.length > 2
        ? notes.sublist(notes.length - 2).reversed
        : notes.reversed.toList();

    return Column(
      children: recent.map((note) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(15),
          decoration: _cardDecoration(),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _softTeal,
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.note_alt_outlined,
                  color: _primaryDark,
                  size: 19,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Session #${note.sessionNumber}',
                      style: const TextStyle(
                        color: _textDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      note.objectiveFindings.isNotEmpty
                          ? note.objectiveFindings
                          : note.treatmentRendered,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _textMuted,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                note.date,
                style: const TextStyle(
                  color: _textMuted,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotesTab() {
    final notes = _patient!.sessionNotes;

    return Column(
      children: [
        Expanded(
          child: notes.isEmpty
              ? _buildEmptyState(
                  icon: Icons.note_alt_outlined,
                  title: 'No clinical notes yet',
                  subtitle:
                      'Add a note after the patient session.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    16,
                    18,
                    12,
                  ),
                  itemCount: notes.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final note = notes[index];

                    return _ClinicalNoteCard(
                      note: note,
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            18,
            8,
            18,
            16,
          ),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _openAddNoteModal,
              icon: const Icon(
                Icons.add_rounded,
                size: 21,
              ),
              label: const Text(
                'Add Clinical Note',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrescriptionsTab() {
    final bills = _patient!.bills;

    if (bills.isEmpty) {
      return _buildEmptyPrescriptionState();
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        18,
        16,
        18,
        28,
      ),
      itemCount: bills.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final bill = bills[index];

        return _PrescriptionCard(
          bill: bill,
          onDownload: () => _downloadBill(bill),
        );
      },
    );
  }

  Future<void> _downloadBill(dynamic bill) async {
    try {
      final patient = _patient!;

      final pdf =
          await PdfInvoiceService.generatePdfInvoice(
        fileNo: bill.fileNo,
        patientName: patient.name,
        gender:
            patient.gender == 'female' ? 'F' : 'M',
        age: patient.age,
        contactNo: patient.phone ?? '',
        dateStr: bill.dateStr,
        city: patient.city,
        receiptNo: bill.receiptNo,
        description: bill.description,
        amount: bill.amount,
        paidAmount: bill.paidAmount,
        remainingAmount: bill.remainingAmount,
      );

      await PdfInvoiceService.downloadOrPrintInvoice(
        pdf,
        'Prescription_${bill.receiptNo}.pdf',
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Unable to generate prescription PDF.',
        isError: true,
      );
    }
  }

  Widget _buildEmptyPrescriptionState() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        _buildEmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'No prescriptions yet',
          subtitle:
              'Prescriptions and invoices for this patient will appear here.',
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEEEE),
                borderRadius:
                    BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.person_off_outlined,
                color: Color(0xFFD64545),
                size: 32,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Unable to load patient',
              style: TextStyle(
                color: _textDark,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              _loadError?.isNotEmpty == true
                  ? _loadError!
                  : 'Please try again.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _textMuted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _loadError = null;
                });
                _loadPatient();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: _softTeal,
                borderRadius:
                    BorderRadius.circular(22),
              ),
              child: Icon(
                icon,
                color: _primaryDark,
                size: 30,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _textDark,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _textMuted,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(
    String title,
    String subtitle,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _textMuted,
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      border: Border.all(
        color: _border,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.035),
          blurRadius: 18,
          offset: const Offset(0, 7),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 52,
      color: _border,
    );
  }
}

// ============================================================
// SMALL UI COMPONENTS
// ============================================================

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _border,
            ),
          ),
          child: Icon(
            icon,
            color: _textDark,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 47,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(
          icon,
          size: 18,
        ),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryDark,
          backgroundColor: Colors.white,
          side: const BorderSide(
            color: _border,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: _border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 37,
            height: 37,
            decoration: BoxDecoration(
              color: _softTeal,
              borderRadius:
                  BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: _primaryDark,
              size: 18,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _textMuted,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _textDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.10),
            borderRadius:
                BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: accent,
            size: 17,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: _textDark,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _textMuted,
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ClinicalNoteCard extends StatelessWidget {
  const _ClinicalNoteCard({
    required this.note,
  });

  final SessionNoteModel note;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: _border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _softTeal,
                  borderRadius:
                      BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.note_alt_outlined,
                  color: _primaryDark,
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Session #${note.sessionNumber}',
                      style: const TextStyle(
                        color: _textDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      note.date,
                      style: const TextStyle(
                        color: _textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _softTeal,
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Text(
                  'Pain ${note.painLevel}/10',
                  style: const TextStyle(
                    color: _primaryDark,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            note.objectiveFindings.isNotEmpty
                ? note.objectiveFindings
                : note.treatmentRendered,
            style: const TextStyle(
              color: _textDark,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          if (note.treatmentRendered.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: _background,
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.fitness_center_outlined,
                    color: _primaryDark,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      note.treatmentRendered,
                      style: const TextStyle(
                        color: _textMuted,
                        fontSize: 10.5,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PrescriptionCard extends StatelessWidget {
  const _PrescriptionCard({
    required this.bill,
    required this.onDownload,
  });

  final dynamic bill;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: _border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F0),
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.picture_as_pdf_outlined,
              color: Color(0xFFD64545),
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Prescription #${bill.receiptNo}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${bill.dateStr} • Rs. ${bill.amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: _textMuted,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDownload,
            style: IconButton.styleFrom(
              backgroundColor: _softTeal,
              foregroundColor: _primaryDark,
            ),
            icon: const Icon(
              Icons.download_rounded,
              size: 19,
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientTabHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  const _PatientTabHeaderDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: _background,
      child: Material(
        color: Colors.white,
        child: tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(
    covariant _PatientTabHeaderDelegate oldDelegate,
  ) {
    return oldDelegate.tabBar != tabBar;
  }
}
