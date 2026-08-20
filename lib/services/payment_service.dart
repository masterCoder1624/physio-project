import '../core/network/api_client.dart';

class PaymentService {
  PaymentService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> createRazorpayOrder({
    required double amount,
    String currency = 'INR',
    String? appointmentId,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/payments/razorpay/create-order',
      body: {
        'amount': amount,
        'currency': currency,
        'appointment_id': appointmentId,
      },
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<bool> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/payments/razorpay/verify',
      body: {
        'razorpay_order_id': orderId,
        'razorpay_payment_id': paymentId,
        'razorpay_signature': signature,
      },
    );

    if (response.success && response.data != null) {
      return response.data!['verified'] as bool? ?? false;
    }
    return false;
  }
}
