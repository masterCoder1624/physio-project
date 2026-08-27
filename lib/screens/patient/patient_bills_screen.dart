import 'package:flutter/material.dart';
import '../../core/storage/local_storage_service.dart';
import '../../models/patient_model.dart';
import '../../services/patient_service.dart';
import '../../services/pdf_invoice_service.dart';
import 'payment_screen.dart';

const Color _kPrimary = Color(0xFF10B981);
const Color _kPageBg = Color(0xFF0F1F17);
const Color _kCardBg = Color(0xFF183326);
const Color _kBorderColor = Color(0xFF254B37);
const Color _kTextDark = Color(0xFFF8FAFC);
const Color _kTextSecondary = Color(0xFFA7F3D0);
const Color _kTextMuted = Color(0xFF6EE7B7);

class PatientBillsScreen extends StatefulWidget {
  const PatientBillsScreen({super.key, this.patientId = '1'});

  final String patientId;

  @override
  State<PatientBillsScreen> createState() => _PatientBillsScreenState();
}

class _PatientBillsScreenState extends State<PatientBillsScreen> {
  PatientModel? _patient;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  Future<void> _loadBills() async {
    try {
      String targetId = widget.patientId;
      if (targetId == '1' || targetId.isEmpty) {
        final currentUid = await LocalStorageService.getUserId();
        if (currentUid != null && currentUid.isNotEmpty) {
          targetId = currentUid;
        }
      }
      final p = await PatientService().getPatientById(targetId);
      if (!mounted) return;
      setState(() {
        _patient = p;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: _kPageBg,
        body: Center(child: CircularProgressIndicator(color: _kPrimary)),
      );
    }

    final bills = _patient?.bills ?? [];
    final double totalBilled = bills.fold(0.0, (sum, b) => sum + b.amount);
    final double totalPaid = bills.fold(0.0, (sum, b) => sum + b.paidAmount);
    final double totalDue = bills.fold(0.0, (sum, b) => sum + b.remainingAmount);

    return Scaffold(
      backgroundColor: _kPageBg,
      appBar: AppBar(
        title: const Text('My Invoices & Receipts'),
        backgroundColor: _kCardBg,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Summary Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _kCardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _kBorderColor),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Total Billed', style: TextStyle(color: _kTextMuted, fontSize: 11)),
                          const SizedBox(height: 4),
                          Text('Rs. ${totalBilled.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Total Paid', style: TextStyle(color: _kTextMuted, fontSize: 11)),
                          const SizedBox(height: 4),
                          Text('Rs. ${totalPaid.toStringAsFixed(0)}', style: const TextStyle(color: _kPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Remaining Due', style: TextStyle(color: _kTextMuted, fontSize: 11)),
                          const SizedBox(height: 4),
                          Text(
                            'Rs. ${totalDue.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: totalDue > 0 ? const Color(0xFFFDE68A) : _kPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (totalDue > 0) ...[
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final paid = await Navigator.of(context).push<bool>(
                            MaterialPageRoute(
                              builder: (_) => PaymentScreen(consultationFee: totalDue),
                            ),
                          );
                          if (paid == true) {
                            await _loadBills();
                          }
                        },
                        icon: const Icon(Icons.payment, size: 18),
                        label: Text('Pay Outstanding Due (Rs. ${totalDue.toStringAsFixed(0)})'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kPrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('Receipts & Invoices History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _kTextDark)),
            const SizedBox(height: 12),

            if (bills.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _kCardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _kBorderColor),
                ),
                child: const Center(
                  child: Text('No payment receipts recorded yet.', style: TextStyle(color: _kTextSecondary)),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: bills.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final b = bills[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _kCardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _kBorderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(b.receiptNo, style: const TextStyle(fontWeight: FontWeight.bold, color: _kTextDark, fontSize: 15)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: b.isFullyPaid ? const Color(0xFF064E3B) : const Color(0xFF78350F),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                b.isFullyPaid ? 'PAID' : 'DUE Rs. ${b.remainingAmount.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: b.isFullyPaid ? _kPrimary : const Color(0xFFFDE68A),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Date: ${b.dateStr} • Mode: ${b.paymentMode}', style: const TextStyle(color: _kTextMuted, fontSize: 12)),
                        const SizedBox(height: 8),
                        Text(b.description, style: const TextStyle(color: _kTextSecondary, fontSize: 13)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Amount: Rs. ${b.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                            OutlinedButton.icon(
                              onPressed: () async {
                                final pdf = await PdfInvoiceService.generatePdfInvoice(
                                  fileNo: b.fileNo,
                                  patientName: _patient?.name ?? 'Patient',
                                  gender: _patient?.gender == 'female' ? 'F' : 'M',
                                  age: _patient?.age ?? '28',
                                  contactNo: _patient?.phone ?? '',
                                  dateStr: b.dateStr,
                                  city: _patient?.city ?? 'Jaipur',
                                  receiptNo: b.receiptNo,
                                  description: b.description,
                                  amount: b.amount,
                                  paidAmount: b.paidAmount,
                                  remainingAmount: b.remainingAmount,
                                );
                                await PdfInvoiceService.downloadOrPrintInvoice(pdf, 'Receipt_${b.receiptNo}.pdf');
                              },
                              icon: const Icon(Icons.download, size: 16, color: Color(0xFF38BDF8)),
                              label: const Text('Download PDF', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 12)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF38BDF8)),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
