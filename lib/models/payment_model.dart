class PaymentModel {
  const PaymentModel({
    required this.id,
    required this.patientId,
    this.appointmentId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.paymentMethod,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.createdAt,
  });

  final String id;
  final String patientId;
  final String? appointmentId;
  final double amount;
  final String currency;
  final String status;
  final String paymentMethod;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final String? createdAt;

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String? ?? '',
      patientId: json['patient_id'] as String? ?? '',
      appointmentId: json['appointment_id'] as String?,
      amount: (json['amount'] as num? ?? 0).toDouble(),
      currency: json['currency'] as String? ?? 'INR',
      status: json['status'] as String? ?? 'pending',
      paymentMethod: json['payment_method'] as String? ?? 'razorpay',
      razorpayOrderId: json['razorpay_order_id'] as String?,
      razorpayPaymentId: json['razorpay_payment_id'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'appointment_id': appointmentId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'payment_method': paymentMethod,
      'razorpay_order_id': razorpayOrderId,
      'razorpay_payment_id': razorpayPaymentId,
      'created_at': createdAt,
    };
  }

  PaymentModel copyWith({
    String? id,
    String? patientId,
    String? appointmentId,
    double? amount,
    String? currency,
    String? status,
    String? paymentMethod,
    String? razorpayOrderId,
    String? razorpayPaymentId,
    String? createdAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      appointmentId: appointmentId ?? this.appointmentId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      razorpayOrderId: razorpayOrderId ?? this.razorpayOrderId,
      razorpayPaymentId: razorpayPaymentId ?? this.razorpayPaymentId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
