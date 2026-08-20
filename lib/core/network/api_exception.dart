class ApiException implements Exception {
  ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  final String message;
  final int? statusCode;
  final dynamic errors;

  @override
  String toString() {
    return 'ApiException(statusCode: $statusCode, message: $message, errors: $errors)';
  }
}
