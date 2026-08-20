import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../models/clinical_models.dart';
import '../../services/patient_service.dart';
import '../../services/pdf_invoice_service.dart';
import '../physio/physio_dashboard.dart';

const Color _kPageBg = Color(0xFF0D1F17);       // Deep Dark Forest
const Color _kCardBg = Color(0xFF132A1F);       // Dark Forest Card BG
const Color _kBorder = Color(0xFF254B37);       // Dark Forest Border
const Color _kMint = Color(0xFF56C596);         // Mint Accent / Selected Button
const Color _kTextPrimary = Color(0xFFF8FAFC);   // White Text
const Color _kTextSecondary = Color(0xFFA7F3D0); // Mint Secondary Text
const Color _kTextMuted = Color(0xFF6EE7B7);     // Muted Text

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key, this.isFirstTimeLogin = false});

  final bool isFirstTimeLogin;

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  int _currentStep = 1; // 1: Details, 2: Payments, 3: Success

  // Form Controllers & State for Step 1
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Vikram Singh Nagar');
  final _addressController = TextEditingController(text: 'JAIPUR');
  final _phoneController = TextEditingController(text: '8739874457');
  final _notesController = TextEditingController(
    text: 'Prior ACL surgery 2 years ago. Recent pain flare up after jogging.',
  );
  String _selectedGender = 'Male';
  String _selectedReason = 'Knee Rehabilitation';

  final List<String> _visitReasons = [
    'Knee Rehabilitation',
    'Lower Back Pain',
    'Post-Surgery Recovery',
    'Shoulder Impingement',
    'Cervical Spondylosis',
  ];

  // State for Step 2 (Custom Amount Billing Inputs)
  String _paymentMode = 'Offline Payment';
  final _descriptionController = TextEditingController(text: 'Treatment Session');
  final _totalAmountController = TextEditingController(text: '1000');
  final _paidAmountController = TextEditingController(text: '800');

  double get _totalAmount => double.tryParse(_totalAmountController.text) ?? 1000.0;
  double get _paidAmount => double.tryParse(_paidAmountController.text) ?? 800.0;
  double get _remainingAmount => (_totalAmount - _paidAmount) < 0 ? 0.0 : (_totalAmount - _paidAmount);

  bool _isSubmitting = false;
  bool _isGeneratingPdf = false;
  Uint8List? _pdfBytes;

  @override
  void initState() {
    super.initState();
    _totalAmountController.addListener(_updateBillingState);
    _paidAmountController.addListener(_updateBillingState);
  }

  void _updateBillingState() {
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    _descriptionController.dispose();
    _totalAmountController.dispose();
    _paidAmountController.dispose();
    super.dispose();
  }

  void _nextToBilling() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _currentStep = 2;
      });
    }
  }

  Future<void> _confirmAndSubmit() async {
    setState(() {
      _isSubmitting = true;
    });

    final fileNo = 'FILE000${DateTime.now().millisecondsSinceEpoch % 10000}';
    final receiptNo = 'REC-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch % 10000}';
    final dateStr = '${DateTime.now().day.toString().padLeft(2, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().year}';
    final patientName = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Vikram Singh Nagar';
    final description = _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : 'Treatment Session';

    final initialBill = BillRecordModel(
      id: 'BILL_${DateTime.now().millisecondsSinceEpoch}',
      fileNo: fileNo,
      receiptNo: receiptNo,
      dateStr: dateStr,
      description: description,
      amount: _totalAmount,
      paidAmount: _paidAmount,
      remainingAmount: _remainingAmount,
      paymentMode: _paymentMode,
      status: 'COMPLETED',
    );

    try {
      await PatientService().createPatient(
        name: patientName,
        condition: _selectedReason,
        gender: _selectedGender,
        phone: _phoneController.text.trim(),
        city: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : 'JAIPUR',
        initialNotes: _notesController.text.trim(),
        initialBill: initialBill,
      );
    } catch (_) {
      // Demo fallback if backend offline
    }

    // Pre-generate PDF receipt for downloading
    final pdfData = await PdfInvoiceService.generatePdfInvoice(
      fileNo: fileNo,
      patientName: patientName,
      gender: _selectedGender == 'Female' ? 'F' : 'M',
      age: '25',
      contactNo: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : '8739874457',
      dateStr: dateStr,
      city: _addressController.text.trim().isNotEmpty ? _addressController.text.trim().toUpperCase() : 'JAIPUR',
      receiptNo: receiptNo,
      description: description,
      amount: _totalAmount,
      paidAmount: _paidAmount,
      remainingAmount: _remainingAmount,
    );

    if (!mounted) return;
    setState(() {
      _pdfBytes = pdfData;
      _isSubmitting = false;
      _currentStep = 3;
    });
  }

  Future<void> _downloadPdfBill() async {
    if (_pdfBytes == null) return;
    setState(() => _isGeneratingPdf = true);
    try {
      await PdfInvoiceService.downloadOrPrintInvoice(
        _pdfBytes!,
        'Patient_Bill_${_nameController.text.trim().replaceAll(' ', '_')}.pdf',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloading PDF: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isGeneratingPdf = false);
      }
    }
  }

  void _resetForm() {
    setState(() {
      _currentStep = 1;
      _nameController.text = '';
      _addressController.text = '';
      _phoneController.text = '';
      _notesController.text = '';
      _descriptionController.text = 'Treatment Session';
      _totalAmountController.text = '1000';
      _paidAmountController.text = '800';
      _selectedGender = 'Male';
      _selectedReason = 'Knee Rehabilitation';
      _pdfBytes = null;
    });
  }

  void _goToDashboard() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PhysioDashboard()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kPageBg,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _buildCurrentStepWidget(),
        ),
      ),
    );
  }

  Widget _buildCurrentStepWidget() {
    switch (_currentStep) {
      case 1:
        return _buildStep1Details();
      case 2:
        return _buildStep2Billing();
      case 3:
        return _buildStep3Success();
      default:
        return _buildStep1Details();
    }
  }

  // ==========================================
  // STEP 1: Add New Patient Details
  // ==========================================
  Widget _buildStep1Details() {
    return Column(
      key: const ValueKey('Step1'),
      children: [
        _buildHeader(
          title: 'Add New Patient',
          subtitle: 'Step 1 of 3: Details',
          stepDots: 1,
          onBack: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              _goToDashboard();
            }
          },
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Let's get your patient's details",
                    style: TextStyle(
                      color: _kTextSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Upload Patient Photo Card
                  _buildPhotoUploadCard(),
                  const SizedBox(height: 20),

                  // Full Name Field
                  _buildLabel('Full Name'),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: _nameController,
                    hint: 'Enter patient full name',
                    validator: (val) =>
                        (val == null || val.trim().isEmpty) ? 'Please enter full name' : null,
                  ),
                  const SizedBox(height: 16),

                  // Gender Selection Pills
                  _buildLabel('Gender'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildGenderPill('Male'),
                      const SizedBox(width: 10),
                      _buildGenderPill('Female'),
                      const SizedBox(width: 10),
                      _buildGenderPill('Other'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Phone Number Field
                  _buildLabel('Contact Number'),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: _phoneController,
                    hint: 'Enter 10-digit phone number',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  // Home Address / City Field
                  _buildLabel('City / Home Address'),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: _addressController,
                    hint: 'Enter city or home address',
                  ),
                  const SizedBox(height: 16),

                  // Reason for Visit Dropdown
                  _buildLabel('Reason for Visit'),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: _kCardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _kBorder),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedReason,
                        dropdownColor: _kCardBg,
                        icon: const Icon(Icons.keyboard_arrow_down, color: _kMint),
                        isExpanded: true,
                        style: const TextStyle(
                          color: _kTextPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        items: _visitReasons
                            .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedReason = val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Clinical Notes Multiline Field
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLabel('Clinical Notes'),
                      Text(
                        '${_notesController.text.length}/250',
                        style: const TextStyle(color: _kTextMuted, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: _notesController,
                    hint: 'Enter clinical notes and patient history...',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),

        // Bottom Action Button: Continue to Billing
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _nextToBilling,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kMint,
                foregroundColor: const Color(0xFF0D1F17),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Continue to Billing',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0D1F17),
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward, size: 20, color: Color(0xFF0D1F17)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // STEP 2: Custom Billing Details (Amount Input)
  // ==========================================
  Widget _buildStep2Billing() {
    return Column(
      key: const ValueKey('Step2'),
      children: [
        _buildHeader(
          title: 'Billing Details',
          subtitle: 'Step 2 of 3: Payments',
          stepDots: 2,
          onBack: () {
            setState(() => _currentStep = 1);
          },
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Payment Mode Selection Segmented Bar
                _buildLabel('Payment Mode'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _kCardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _kBorder),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildModeSegment('Online Payment'),
                      ),
                      Expanded(
                        child: _buildModeSegment('Offline Payment'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Treatment Description Input
                _buildLabel('Treatment / Service Description'),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _descriptionController,
                  hint: 'e.g. Treatment Session',
                ),
                const SizedBox(height: 16),

                // Total Treatment Amount Input
                _buildLabel('Total Treatment Amount (Rs.)'),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _totalAmountController,
                  hint: 'Enter total amount e.g. 1000',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                // Amount Paid Now Input
                _buildLabel('Amount Paid Now (Rs.)'),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _paidAmountController,
                  hint: 'Enter paid amount e.g. 800',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),

                // Invoice Calculation Summary Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _kCardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _kBorder),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Billing Summary',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _kTextPrimary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _remainingAmount == 0
                                  ? const Color(0xFF064E3B)
                                  : const Color(0xFF78350F),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _remainingAmount == 0 ? 'FULLY PAID' : 'PARTIAL DUE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _remainingAmount == 0
                                    ? _kMint
                                    : const Color(0xFFFDE68A),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInvoiceRow(
                        _descriptionController.text.isNotEmpty
                            ? _descriptionController.text
                            : 'Treatment Session',
                        'Rs. ${_totalAmount.toStringAsFixed(0)}',
                      ),
                      const SizedBox(height: 8),
                      _buildInvoiceRow('Sub Total', 'Rs. ${_totalAmount.toStringAsFixed(0)}'),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(color: _kBorder, height: 1),
                      ),
                      _buildInvoiceRow('Total Amount', 'Rs. ${_totalAmount.toStringAsFixed(0)}'),
                      const SizedBox(height: 8),
                      _buildInvoiceRow('Total Paid Amount', 'Rs. ${_paidAmount.toStringAsFixed(0)}'),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Remaining Amount Due',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFDE68A),
                            ),
                          ),
                          Text(
                            'Rs. ${_remainingAmount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFFDE68A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom Action Button: Confirm & Continue
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _confirmAndSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kMint,
                foregroundColor: const Color(0xFF0D1F17),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Color(0xFF0D1F17),
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Confirm & Generate Bill',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0D1F17),
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward, size: 20, color: Color(0xFF0D1F17)),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // STEP 3: Success & Download PDF Bill
  // ==========================================
  Widget _buildStep3Success() {
    return Column(
      key: const ValueKey('Step3'),
      children: [
        const SizedBox(height: 20),
        // Success Badge
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: _kMint,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _kMint.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.check,
            color: Color(0xFF0D1F17),
            size: 44,
          ),
        ),
        const SizedBox(height: 18),

        // Title and Subtitle
        const Text(
          'Patient Added Successfully!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: _kTextPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Registration and billing receipt processing is complete.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: _kTextMuted,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Patient Registration Summary Card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _kCardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _kBorder),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: _kMint,
                      child: Text(
                        _nameController.text.isNotEmpty
                            ? _nameController.text.substring(0, 1).toUpperCase()
                            : 'V',
                        style: const TextStyle(
                          color: Color(0xFF0D1F17),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _nameController.text.isNotEmpty
                                ? _nameController.text
                                : 'Vikram Singh Nagar',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _kTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _selectedReason,
                            style: const TextStyle(
                              fontSize: 13,
                              color: _kTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(color: _kBorder, height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Paid',
                          style: TextStyle(
                            fontSize: 12,
                            color: _kTextMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Rs. ${_paidAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: _kTextPrimary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Remaining Due',
                          style: TextStyle(
                            fontSize: 12,
                            color: _kTextMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Rs. ${_remainingAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _remainingAmount == 0 ? _kMint : const Color(0xFFFDE68A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const Spacer(),

        // PDF Download Button & Action Buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            children: [
              // Download PDF Receipt Button matching exact PDF design format
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isGeneratingPdf ? null : _downloadPdfBill,
                  icon: _isGeneratingPdf
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.picture_as_pdf, color: Colors.white, size: 22),
                  label: Text(
                    _isGeneratingPdf ? 'Generating PDF...' : 'Download PDF Bill / Receipt',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7), // High visibility Blue for PDF
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Go to Dashboard Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _goToDashboard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kMint,
                    foregroundColor: const Color(0xFF0D1F17),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Go to Dashboard',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0D1F17),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // + Add Another Patient Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _resetForm,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _kMint,
                    side: const BorderSide(color: _kBorder, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    '+ Add Another Patient',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _kMint,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // HELPER WIDGETS
  // ==========================================

  Widget _buildHeader({
    required String title,
    required String subtitle,
    required int stepDots,
    required VoidCallback onBack,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: _kTextPrimary),
          ),
          Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _kTextPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: _kTextMuted,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          // 3 Progress Dots
          Row(
            children: List.generate(3, (index) {
              final isActive = index < stepDots;
              return Container(
                margin: const EdgeInsets.only(left: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive ? _kMint : _kBorder,
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoUploadCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _kMint, width: 1.5),
            ),
            child: const Icon(Icons.camera_alt_outlined, color: _kMint, size: 22),
          ),
          const SizedBox(height: 10),
          const Text(
            'Upload Patient Photo',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _kTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'PNG, JPG up to 5MB (Optional)',
            style: TextStyle(
              fontSize: 12,
              color: _kTextMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: _kTextPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: _kTextPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _kTextMuted, fontSize: 13),
        filled: true,
        fillColor: _kCardBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kMint, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }

  Widget _buildGenderPill(String gender) {
    final isSelected = _selectedGender == gender;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGender = gender),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? _kMint : _kCardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? _kMint : _kBorder),
          ),
          child: Text(
            gender,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              color: isSelected ? const Color(0xFF0D1F17) : _kTextSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeSegment(String mode) {
    final isSelected = _paymentMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _paymentMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? _kMint : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          mode,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? const Color(0xFF0D1F17) : _kTextSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: _kTextSecondary,
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _kTextPrimary,
          ),
        ),
      ],
    );
  }
}
