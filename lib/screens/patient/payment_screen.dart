import 'package:flutter/material.dart';
import '../../services/payment_service.dart';

const Color _primaryBlue = Color(0xFF0066CC);
const Color _textPrimary = Color(0xFF2C3E50);
const Color _textSecondary = Color(0xFF7F8C8D);
const Color _pageBackground = Color(0xFFF8FAFB);
const Color _cardBackground = Color(0xFFFFFFFF);
const Color _border = Color(0xFFE1E8ED);

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    this.consultationFee = 500.0,
    this.appointmentId,
  });

  final double consultationFee;
  final String? appointmentId;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentService _paymentService = PaymentService();
  bool _isProcessing = false;
  String? _statusMessage;

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Creating Razorpay Order...';
    });

    try {
      final orderData = await _paymentService.createRazorpayOrder(
        amount: widget.consultationFee,
        appointmentId: widget.appointmentId,
      );

      final orderId = orderData['razorpay_order_id'] ?? '';

      setState(() {
        _statusMessage = 'Verifying Payment Order Signature...';
      });

      // Simulate payment capture verification with backend
      final verified = await _paymentService.verifyPayment(
        orderId: orderId,
        paymentId: 'pay_mock_${DateTime.now().millisecondsSinceEpoch}',
        signature: 'sig_mock_verified',
      );

      if (!mounted) return;
      if (verified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment verified and completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _isProcessing = false;
          _statusMessage = 'Payment signature verification failed.';
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _statusMessage = 'Payment error: ${error.toString().replaceAll('Exception: ', '')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        title: const Text('Checkout & Payment'),
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Consultation Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _textPrimary,
                    ),
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Physiotherapy Session', style: TextStyle(color: _textSecondary)),
                      Text('₹${widget.consultationFee.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Platform Fee', style: TextStyle(color: _textSecondary)),
                      Text('₹0.00', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Payable',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _textPrimary,
                        ),
                      ),
                      Text(
                        '₹${widget.consultationFee.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (_statusMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _statusMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _textSecondary),
                ),
              ),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text(
                        'Pay with Razorpay',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
