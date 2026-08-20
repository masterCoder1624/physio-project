/// Single Centralized API Configuration for PhysioVerse Flutter App
class ApiConfig {
  /// Production Backend deployed on Render
  static const String baseUrl = "https://physio-backend-cc4d.onrender.com/api/v1";

  /// HTTP Timeout Duration in seconds (handles Render cold starts gracefully)
  static const Duration timeoutDuration = Duration(seconds: 45);
}
