import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../models/clinical_models.dart';
import '../../services/patient_service.dart';
import '../../services/pdf_invoice_service.dart';
import '../physio/physio_dashboard.dart';

const Color _kPageBg = Color(0xFFF4F9FA);
const Color _kBorder = Color(0xFFD9E7EA);
const Color _kMint = Color(0xFF08A7B5);
const Color _kTextPrimary = Color(0xFF102A43);
const Color _kTextSecondary = Color(0xFF5F7185);
const Color _kTextMuted = Color(0xFF8A9AAA);
const Color _kSuccess = Color(0xFF16A36A);
const Color _kWarning = Color(0xFFF2A900);
const Color _kDanger = Color(0xFFE85D68);

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key, this.isFirstTimeLogin = false});

  final bool isFirstTimeLogin;

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  int _currentStep = 1; // 1: Details, 2: Payments, 3: Success

  // Form Controllers & State for Step 1 — Clean, empty initialization
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedGender;
  String? _selectedReason;
  bool _genderError = false;
  bool _reasonError = false;

  final List<String> _visitReasons = [
    'Knee Rehabilitation',
    'Lower Back Pain',
    'Post-Surgery Recovery',
    'Shoulder Impingement',
    'Cervical Spondylosis',
    'Ankle Sprain / Fracture',
    'Sports Injury Rehab',
    'General Physiotherapy',
  ];

  // State for Step 2 (Billing Inputs)
  String _paymentMode = 'Offline Payment';
  final _descriptionController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _paidAmountController = TextEditingController();

  double get _totalAmount => double.tryParse(_totalAmountController.text.trim()) ?? 0.0;
  double get _paidAmount => double.tryParse(_paidAmountController.text.trim()) ?? 0.0;
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
    final formValid = _formKey.currentState?.validate() ?? false;
    setState(() {
      _genderError = _selectedGender == null;
      _reasonError = _selectedReason == null;
    });

    if (formValid && !_genderError && !_reasonError) {
      if (_descriptionController.text.trim().isEmpty) {
        _descriptionController.text = 'Treatment Session';
      }
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
    final patientName = _nameController.text.trim();
    final description = _descriptionController.text.trim().isNotEmpty
        ? _descriptionController.text.trim()
        : 'Treatment Session';

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
      status: _remainingAmount == 0 ? 'COMPLETED' : 'PENDING',
    );

    try {
      await PatientService().createPatient(
        name: patientName,
        condition: _selectedReason ?? 'General Physiotherapy',
        gender: _selectedGender,
        phone: _phoneController.text.trim(),
        city: _addressController.text.trim(),
        initialNotes: _notesController.text.trim(),
        initialBill: initialBill,
      );
    } catch (_) {
      // Handled cleanly
    }

    // Pre-generate PDF receipt for downloading with actual data
    final pdfData = await PdfInvoiceService.generatePdfInvoice(
      fileNo: fileNo,
      patientName: patientName,
      gender: _selectedGender == 'Female' ? 'F' : (_selectedGender == 'Male' ? 'M' : 'O'),
      age: '',
      contactNo: _phoneController.text.trim(),
      dateStr: dateStr,
      city: _addressController.text.trim().toUpperCase(),
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
      final safeName = _nameController.text.trim().replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
      await PdfInvoiceService.downloadOrPrintInvoice(
        _pdfBytes!,
        'Patient_Bill_${safeName.isEmpty ? "Receipt" : safeName}.pdf',
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
      _descriptionController.text = '';
      _totalAmountController.text = '';
      _paidAmountController.text = '';
      _selectedGender = null;
      _selectedReason = null;
      _genderError = false;
      _reasonError = false;
      _pdfBytes = null;
    });
  }

  void _goToDashboard() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(true);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PhysioDashboard()),
        (route) => false,
      );
    }
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
          title: 'Add Patient',
          subtitle: 'Patient information',
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
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionIntro(
                    icon: Icons.person_outline_rounded,
                    title: 'Patient Information',
                    subtitle: 'Enter basic information for the new patient',
                  ),
                  const SizedBox(height: 20),

                  _buildLabel('Full Name', required: true, icon: Icons.person_outline_rounded),
                  const SizedBox(height: 7),
                  _buildTextField(
                    controller: _nameController,
                    hint: 'Enter patient full name',
                    prefixIcon: Icons.person_outline_rounded,
                    validator: (val) =>
                        (val == null || val.trim().isEmpty) ? 'Please enter full name' : null,
                  ),
                  const SizedBox(height: 18),

                  _buildLabel('Gender', required: true, icon: Icons.wc_rounded),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildGenderPill('Male'),
                      const SizedBox(width: 8),
                      _buildGenderPill('Female'),
                      const SizedBox(width: 8),
                      _buildGenderPill('Other'),
                    ],
                  ),
                  if (_genderError) ...[
                    const SizedBox(height: 6),
                    const Text(
                      'Please select a gender',
                      style: TextStyle(color: _kDanger, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                  const SizedBox(height: 18),

                  _buildLabel('Contact Number', icon: Icons.phone_outlined),
                  const SizedBox(height: 7),
                  _buildTextField(
                    controller: _phoneController,
                    hint: 'Enter 10-digit phone number',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 18),

                  _buildLabel('City / Home Address', icon: Icons.location_on_outlined),
                  const SizedBox(height: 7),
                  _buildTextField(
                    controller: _addressController,
                    hint: 'Enter city or home address',
                    prefixIcon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 24),

                  _buildSectionIntro(
                    icon: Icons.medical_services_outlined,
                    title: 'Treatment Information',
                    subtitle: 'Select reason for visit and clinical notes',
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('Reason for Visit', required: true, icon: Icons.healing_outlined),
                  const SizedBox(height: 7),
                  _buildReasonDropdown(),
                  if (_reasonError) ...[
                    const SizedBox(height: 6),
                    const Text(
                      'Please select reason for visit',
                      style: TextStyle(color: _kDanger, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLabel('Clinical Notes', icon: Icons.notes_rounded),
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _notesController,
                        builder: (_, value, _) => Text(
                          '${value.text.length}/250',
                          style: const TextStyle(color: _kTextMuted, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  _buildTextField(
                    controller: _notesController,
                    hint: 'Previous injury, surgery, symptoms, history...',
                    prefixIcon: Icons.notes_rounded,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Keep notes concise and clinically relevant.',
                    style: TextStyle(color: _kTextMuted, fontSize: 11),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
        _buildBottomAction(
          label: 'Continue to Billing',
          icon: Icons.arrow_forward_rounded,
          onPressed: _nextToBilling,
        ),
      ],
    );
  }

  // ==========================================
  // STEP 2: Billing Details
  // ==========================================
  Widget _buildStep2Billing() {
    return Column(
      key: const ValueKey('Step2'),
      children: [
        _buildHeader(
          title: 'Billing',
          subtitle: 'Payment information',
          stepDots: 2,
          onBack: () => setState(() => _currentStep = 1),
        ),
        Expanded(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionIntro(
                  icon: Icons.credit_card_outlined,
                  title: 'Payment Method',
                  subtitle: 'Choose how the payment is made',
                ),
                const SizedBox(height: 16),
                _buildPaymentModeCards(),
                const SizedBox(height: 24),

                _buildSectionIntro(
                  icon: Icons.medical_services_outlined,
                  title: 'Service / Treatment',
                  subtitle: 'Enter the treatment being billed',
                ),
                const SizedBox(height: 14),
                _buildLabel('Treatment / Service Description', required: true, icon: Icons.receipt_long_outlined),
                const SizedBox(height: 7),
                _buildTextField(
                  controller: _descriptionController,
                  hint: 'e.g. Treatment Session',
                  prefixIcon: Icons.receipt_long_outlined,
                ),
                const SizedBox(height: 24),

                _buildSectionIntro(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Billing Details',
                  subtitle: 'Enter the amount received today',
                ),
                const SizedBox(height: 14),
                _buildLabel('Total Amount (₹)', required: true, icon: Icons.currency_rupee_rounded),
                const SizedBox(height: 7),
                _buildTextField(
                  controller: _totalAmountController,
                  hint: '0',
                  prefixIcon: Icons.currency_rupee_rounded,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                _buildLabel('Paid Today (₹)', required: true, icon: Icons.payments_outlined),
                const SizedBox(height: 7),
                _buildTextField(
                  controller: _paidAmountController,
                  hint: '0',
                  prefixIcon: Icons.payments_outlined,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 20),
                _buildBillingSummaryCard(),
              ],
            ),
          ),
        ),
        _buildBottomAction(
          label: _isSubmitting ? 'Saving Patient...' : 'Confirm & Generate Bill',
          icon: Icons.arrow_forward_rounded,
          onPressed: _isSubmitting ? null : _confirmAndSubmit,
          loading: _isSubmitting,
        ),
      ],
    );
  }

  // ==========================================
  // STEP 3: Success
  // ==========================================
  Widget _buildStep3Success() {
    final patientName = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Patient';
    return Column(
      key: const ValueKey('Step3'),
      children: [
        _buildHeader(
          title: 'Patient Added',
          subtitle: 'Registration complete',
          stepDots: 3,
          onBack: () => _goToDashboard(),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7F8F0),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFBDEBD3), width: 1),
                  ),
                  child: const Icon(Icons.check_rounded, color: _kSuccess, size: 48),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Patient Added Successfully!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: _kTextPrimary, letterSpacing: -0.5),
                ),
                const SizedBox(height: 8),
                const Text(
                  'The patient has been added and billing information is recorded.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, height: 1.45, color: _kTextSecondary),
                ),
                const SizedBox(height: 24),
                _buildSuccessPatientCard(patientName),
                const SizedBox(height: 16),
                _buildSuccessAmountCard(),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isGeneratingPdf ? null : _downloadPdfBill,
                  icon: _isGeneratingPdf
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.picture_as_pdf_outlined, size: 21),
                  label: Text(_isGeneratingPdf ? 'Generating PDF...' : 'Download Receipt'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kMint,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _goToDashboard,
                  icon: const Icon(Icons.person_outline_rounded, size: 20),
                  label: const Text('Back to Patients'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _kMint,
                    side: const BorderSide(color: _kBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _resetForm,
                child: const Text('Add Another Patient', style: TextStyle(color: _kTextSecondary, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // UI Helpers
  // ==========================================

  Widget _buildHeader({
    required String title,
    required String subtitle,
    required int stepDots,
    required VoidCallback onBack,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 4),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded, color: _kTextPrimary),
                tooltip: 'Back',
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _kTextPrimary)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: _kTextSecondary, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Text('$stepDots/3', style: const TextStyle(fontSize: 13, color: _kTextSecondary, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(3, (index) {
              final active = index < stepDots;
              final current = index == stepDots - 1;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index == 2 ? 0 : 6),
                  height: current ? 4 : 3,
                  decoration: BoxDecoration(
                    color: active ? _kMint : const Color(0xFFE4ECEF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionIntro({required IconData icon, required String title, required String subtitle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: const Color(0xFFE6F8FA), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: _kMint, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _kTextPrimary)),
              const SizedBox(height: 3),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: _kTextSecondary, height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String label, {bool required = false, IconData? icon}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: _kTextSecondary),
          const SizedBox(width: 6),
        ],
        Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: _kTextPrimary)),
        if (required) const Text(' *', style: TextStyle(color: _kDanger, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    IconData? prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: _kTextPrimary, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _kTextMuted, fontSize: 13),
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 19, color: _kTextSecondary),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: _kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: _kMint, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: _kDanger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: _kDanger, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildReasonDropdown() {
    return Container(
      padding: const EdgeInsets.only(left: 14, right: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _reasonError ? _kDanger : _kBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedReason,
          hint: const Text('Select reason for visit / condition', style: TextStyle(color: _kTextMuted, fontSize: 13)),
          dropdownColor: Colors.white,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _kTextSecondary),
          isExpanded: true,
          style: const TextStyle(color: _kTextPrimary, fontSize: 14, fontWeight: FontWeight.w600),
          items: _visitReasons
              .map((r) => DropdownMenuItem(value: r, child: Text(r, overflow: TextOverflow.ellipsis)))
              .toList(),
          onChanged: (val) {
            setState(() {
              _selectedReason = val;
              _reasonError = false;
            });
          },
        ),
      ),
    );
  }

  Widget _buildGenderPill(String gender) {
    final isSelected = _selectedGender == gender;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: () => setState(() {
            _selectedGender = gender;
            _genderError = false;
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? _kMint : Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: isSelected
                    ? _kMint
                    : (_genderError ? _kDanger : _kBorder),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  size: 17,
                  color: isSelected ? Colors.white : _kTextSecondary,
                ),
                const SizedBox(width: 5),
                Text(
                  gender,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : _kTextPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentModeCards() {
    return Row(
      children: [
        Expanded(child: _buildModeSegment('Offline Payment', icon: Icons.payments_outlined, caption: 'Cash / Manual')),
        const SizedBox(width: 10),
        Expanded(child: _buildModeSegment('Online Payment', icon: Icons.credit_card_outlined, caption: 'UPI / Card')),
      ],
    );
  }

  Widget _buildModeSegment(String mode, {IconData icon = Icons.payment_outlined, String caption = ''}) {
    final isSelected = _paymentMode == mode;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _paymentMode = mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE8F8FA) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? _kMint : _kBorder, width: isSelected ? 1.4 : 1),
          ),
          child: Column(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: isSelected ? _kMint : const Color(0xFFF1F5F7), shape: BoxShape.circle),
                child: Icon(icon, size: 20, color: isSelected ? Colors.white : _kTextSecondary),
              ),
              const SizedBox(height: 8),
              Text(mode, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: isSelected ? _kMint : _kTextPrimary)),
              if (caption.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(caption, style: const TextStyle(fontSize: 10, color: _kTextMuted)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBillingSummaryCard() {
    final fullyPaid = _remainingAmount == 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(width: 38, height: 38, decoration: BoxDecoration(color: const Color(0xFFEAF8FA), borderRadius: BorderRadius.circular(11)), child: const Icon(Icons.receipt_long_outlined, color: _kMint, size: 20)),
              const SizedBox(width: 10),
              const Expanded(child: Text('Billing Summary', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _kTextPrimary))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(color: fullyPaid ? const Color(0xFFE7F8F0) : const Color(0xFFFFF4D9), borderRadius: BorderRadius.circular(20)),
                child: Text(fullyPaid ? 'FULLY PAID' : 'PARTIAL DUE', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: fullyPaid ? _kSuccess : _kWarning)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInvoiceRow(_descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : 'Treatment Session', '₹ ${_totalAmount.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          _buildInvoiceRow('Paid Today', '₹ ${_paidAmount.toStringAsFixed(0)}'),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: _kBorder, height: 1)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Remaining Due', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _kTextPrimary)),
              Text('₹ ${_remainingAmount.toStringAsFixed(0)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: fullyPaid ? _kSuccess : _kDanger)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessPatientCard(String patientName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _kBorder)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFE8F8FA),
            child: Text(patientName.isNotEmpty ? patientName.substring(0, 1).toUpperCase() : 'P', style: const TextStyle(color: _kMint, fontSize: 20, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patientName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _kTextPrimary)),
                const SizedBox(height: 4),
                Text(_selectedReason ?? 'General Physiotherapy', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: _kTextSecondary)),
                const SizedBox(height: 3),
                Text(_phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : 'No phone number', style: const TextStyle(fontSize: 11, color: _kTextMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessAmountCard() {
    final fullyPaid = _remainingAmount == 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _kBorder)),
      child: Column(
        children: [
          _buildInvoiceRow('Total Amount', '₹ ${_totalAmount.toStringAsFixed(0)}'),
          const SizedBox(height: 12),
          _buildInvoiceRow('Paid Today', '₹ ${_paidAmount.toStringAsFixed(0)}'),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Remaining Due', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _kTextPrimary)),
            Text('₹ ${_remainingAmount.toStringAsFixed(0)}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: fullyPaid ? _kSuccess : _kDanger)),
          ]),
        ],
      ),
    );
  }

  Widget _buildBottomAction({required String label, required IconData icon, required VoidCallback? onPressed, bool loading = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _kMint,
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFFA7DDE1),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: loading
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2))
              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)), const SizedBox(width: 7), Icon(icon, size: 20)]),
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(String label, String amount) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5, color: _kTextSecondary, fontWeight: FontWeight.w500))),
        const SizedBox(width: 12),
        Text(amount, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _kTextPrimary)),
      ],
    );
  }
}
