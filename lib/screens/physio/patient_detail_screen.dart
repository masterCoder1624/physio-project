import 'package:flutter/material.dart';
import '../../models/clinical_models.dart';
import '../../models/patient_model.dart';
import '../../services/patient_service.dart';
import '../../services/pdf_invoice_service.dart';

const Color _primaryBlue = Color(0xFF10B981);
const Color _textPrimary = Color(0xFFF8FAFC);
const Color _textSecondary = Color(0xFFA7F3D0);
const Color _pageBackground = Color(0xFF0F1F17);
const Color _cardBackground = Color(0xFF183326);
const Color _border = Color(0xFF254B37);

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
  late PatientModel _patient;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex < 3 ? widget.initialTabIndex : 0,
    );
    _loadPatient();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPatient() async {
    if (widget.patient != null) {
      _patient = widget.patient!;
      final updated = await PatientService().getPatientById(_patient.id ?? '1');
      if (mounted) {
        setState(() {
          _patient = updated;
          _isLoading = false;
        });
      }
    } else {
      final id = widget.patientId ?? '1';
      final p = await PatientService().getPatientById(id);
      if (mounted) {
        setState(() {
          _patient = p;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshPatient() async {
    final updated = await PatientService().getPatientById(_patient.id ?? '1');
    if (mounted) {
      setState(() {
        _patient = updated;
      });
    }
  }

  void _openAddNoteModal() {
    final nextNum = _patient.sessionNotes.length + 1;
    int pain = 3;
    final noteCtrl = TextEditingController(
      text: 'Patient demonstrates full weight bearing. Flexion improved.',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Add Clinical Note (Session #$nextNum)',
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: _textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pain Level (0-10):',
                        style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$pain / 10',
                        style: const TextStyle(color: _primaryBlue, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Slider(
                    value: pain.toDouble(),
                    min: 0,
                    max: 10,
                    divisions: 10,
                    activeColor: _primaryBlue,
                    onChanged: (val) => setModalState(() => pain = val.round()),
                  ),
                  const SizedBox(height: 8),
                  const Text('Assessment / Progress Note', style: TextStyle(color: _textSecondary, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: noteCtrl,
                    maxLines: 3,
                    style: const TextStyle(color: _textPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      fillColor: _pageBackground,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _border),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () async {
                        final nav = Navigator.of(context);
                        final messenger = ScaffoldMessenger.of(context);
                        final note = SessionNoteModel(
                          id: 'NOTE_${DateTime.now().millisecondsSinceEpoch}',
                          sessionNumber: nextNum,
                          date: DateTime.now().toIso8601String().substring(0, 10),
                          painLevel: pain,
                          subjectiveNotes: 'Routine clinical evaluation.',
                          objectiveFindings: noteCtrl.text.trim(),
                          treatmentRendered: 'Mobilization & prescribed rehabilitation.',
                          planForNextSession: 'Continue progressive exercises.',
                        );
                        await PatientService().addSessionNote(_patient.id ?? '1', note);
                        await _refreshPatient();
                        if (!mounted) return;
                        nav.pop();
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Clinical Note added successfully!'),
                            backgroundColor: _primaryBlue,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Save Clinical Note', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: _pageBackground,
        body: Center(child: CircularProgressIndicator(color: _primaryBlue)),
      );
    }

    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        title: const Text('Patient Details'),
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Clinical Notes'),
            Tab(text: 'Prescriptions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildNotesTab(),
          _buildPrescriptionsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final assessment = _patient.assessment;
    final painText = assessment != null ? '${assessment.painLevel}/10' : '2/10';
    final flexionText = assessment != null ? assessment.activeRomFlexion : '115°';
    final extensionText = assessment != null ? assessment.activeRomExtension : '0°';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: _primaryBlue,
                  child: Text(
                    _patient.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _patient.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Condition: ${_patient.condition}',
                        style: const TextStyle(color: _textSecondary),
                      ),
                      Text(
                        'Gender: ${_patient.gender?.toUpperCase() ?? "MALE"} | Age: ${_patient.age}',
                        style: const TextStyle(color: _textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Recent Progress Metrics',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MetricItem(label: 'Pain Level', value: painText),
                _MetricItem(label: 'Flexion ROM', value: flexionText),
                _MetricItem(label: 'Extension', value: extensionText),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesTab() {
    final notes = _patient.sessionNotes;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: notes.isEmpty
                ? ListView(
                    children: const [
                      Card(
                        color: _cardBackground,
                        child: ListTile(
                          title: Text(
                            'Post-Op Week 4 Assessment',
                            style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Patient demonstrates full weight bearing. Flexion improved by 10 degrees.',
                            style: TextStyle(color: _textSecondary),
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    itemCount: notes.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final n = notes[index];
                      return Card(
                        color: _cardBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: _border),
                        ),
                        child: ListTile(
                          title: Text(
                            'Session #${n.sessionNumber} Assessment (${n.date})',
                            style: const TextStyle(color: _textPrimary, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              n.objectiveFindings.isNotEmpty
                                  ? n.objectiveFindings
                                  : 'Treatment rendered: ${n.treatmentRendered}',
                              style: const TextStyle(color: _textSecondary),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _openAddNoteModal,
              icon: const Icon(Icons.add),
              label: const Text('Add Clinical Note'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionsTab() {
    final bills = _patient.bills;

    if (bills.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Card(
              color: _cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: _border),
              ),
              child: ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('Prescription #RX-9821', style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold)),
                subtitle: const Text('Generated on 24 Jul 2026', style: TextStyle(color: _textSecondary)),
                trailing: IconButton(
                  icon: const Icon(Icons.download, color: _primaryBlue),
                  onPressed: () async {
                    final pdf = await PdfInvoiceService.generatePdfInvoice(
                      fileNo: 'FILE0001',
                      patientName: _patient.name,
                      gender: _patient.gender == 'female' ? 'F' : 'M',
                      age: _patient.age,
                      contactNo: _patient.phone ?? '',
                      dateStr: '24-07-2026',
                      city: _patient.city,
                      receiptNo: 'RX-9821',
                      description: 'Rehabilitation Prescription & Clinical Invoice',
                      amount: 1000,
                      paidAmount: 1000,
                      remainingAmount: 0,
                    );
                    await PdfInvoiceService.downloadOrPrintInvoice(pdf, 'Prescription_RX-9821.pdf');
                  },
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.separated(
        itemCount: bills.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final b = bills[index];
          return Card(
            color: _cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: _border),
            ),
            child: ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: Text('Prescription #${b.receiptNo}', style: const TextStyle(color: _textPrimary, fontWeight: FontWeight.bold)),
              subtitle: Text('Generated on ${b.dateStr} • Rs. ${b.amount.toStringAsFixed(0)}', style: const TextStyle(color: _textSecondary)),
              trailing: IconButton(
                icon: const Icon(Icons.download, color: _primaryBlue),
                onPressed: () async {
                  final pdf = await PdfInvoiceService.generatePdfInvoice(
                    fileNo: b.fileNo,
                    patientName: _patient.name,
                    gender: _patient.gender == 'female' ? 'F' : 'M',
                    age: _patient.age,
                    contactNo: _patient.phone ?? '',
                    dateStr: b.dateStr,
                    city: _patient.city,
                    receiptNo: b.receiptNo,
                    description: b.description,
                    amount: b.amount,
                    paidAmount: b.paidAmount,
                    remainingAmount: b.remainingAmount,
                  );
                  await PdfInvoiceService.downloadOrPrintInvoice(pdf, 'Prescription_${b.receiptNo}.pdf');
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _primaryBlue)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: _textSecondary)),
      ],
    );
  }
}
