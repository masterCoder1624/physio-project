import 'package:flutter/material.dart';
import '../../constants/patient_theme.dart';
import 'patient_components.dart';

/// Screen 19 — Payments & Invoices Screen (matching media_1787385006975.jpg)
class PatientPaymentsScreen extends StatelessWidget {
  const PatientPaymentsScreen({super.key});

  final List<Map<String, dynamic>> _transactions = const [
    {
      'title': 'Consultation Fee',
      'date': '16 Aug 2026',
      'amount': '₹600',
      'status': 'Paid',
    },
    {
      'title': 'Therapy Session',
      'date': '03 Aug 2026',
      'amount': '₹1,000',
      'status': 'Paid',
    },
    {
      'title': 'Consultation Fee',
      'date': '27 Jul 2026',
      'amount': '₹600',
      'status': 'Paid',
    },
    {
      'title': 'Initial Assessment',
      'date': '10 Jul 2026',
      'amount': '₹800',
      'status': 'Paid',
    },
  ];

  void _handlePay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
            ),
            const SizedBox(height: 16),
            _buildPayMethodTile(Icons.account_balance_wallet_rounded, 'UPI / Google Pay / PhonePe'),
            _buildPayMethodTile(Icons.credit_card_rounded, 'Credit / Debit Card'),
            _buildPayMethodTile(Icons.account_balance_rounded, 'Net Banking'),
            const SizedBox(height: 18),
            PrimaryTealButton(
              label: 'Pay ₹1,250',
              onPressed: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payment of ₹1,250 completed successfully! 🎉'),
                    backgroundColor: PatientTheme.successGreen,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayMethodTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: PatientTheme.primaryTeal),
      title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: PatientTheme.textMuted),
      onTap: () {},
    );
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
          'Payments',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Overview',
            style: TextStyle(fontSize: 13, color: PatientTheme.textSecondary),
          ),
          const SizedBox(height: 12),

          // Due Amount Card (matching screenshot)
          PatientCard(
            padding: const EdgeInsets.all(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Due Amount',
                      style: TextStyle(fontSize: 12, color: PatientTheme.textSecondary, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '₹1,250',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: PatientTheme.textDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    StatusBadge(label: '1 Payment pending', isPending: true),
                  ],
                ),
                SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () => _handlePay(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PatientTheme.primaryTeal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: const Text(
                      'Pay Now',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Payment History Header
          const Text(
            'Payment History',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: PatientTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),

          // Transactions List
          ...List.generate(_transactions.length, (index) {
            final tx = _transactions[index];
            return PatientCard(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: PatientTheme.successGreenBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.check_rounded, color: PatientTheme.successGreen, size: 18),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx['title']!,
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tx['date']!,
                          style: const TextStyle(fontSize: 11.5, color: PatientTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        tx['amount']!,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
                      ),
                      const SizedBox(height: 2),
                      const StatusBadge(label: 'Paid', isCompleted: true),
                    ],
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),

          Center(
            child: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All invoices downloaded as PDF statement.')),
                );
              },
              child: const Text(
                'View All Transactions',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: PatientTheme.primaryTeal),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
