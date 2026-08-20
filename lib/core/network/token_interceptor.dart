import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../storage/local_storage_service.dart';

class TokenInterceptor {
  TokenInterceptor({String? baseUrl}) : baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final String baseUrl;

  Future<Map<String, String>> getHeaders({bool isMultipart = false}) async {
    final token = await LocalStorageService.getAccessToken();
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<bool> attemptRefreshToken() async {
    final refreshToken = await LocalStorageService.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/refresh'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'refresh_token': refreshToken}),
          )
          .timeout(ApiConfig.timeoutDuration);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body is Map && body.containsKey('data') ? body['data'] : body;
        if (data != null && data is Map) {
          final newAccessToken = data['access_token'] ?? data['token'] ?? '';
          final newRefreshToken = data['refresh_token'] ?? refreshToken;
          if (newAccessToken.toString().isNotEmpty) {
            await LocalStorageService.saveTokens(
              accessToken: newAccessToken.toString(),
              refreshToken: newRefreshToken.toString(),
              userId: data['user_id']?.toString() ?? '',
              role: data['role']?.toString() ?? '',
            );
            return true;
          }
        }
      }
    } catch (_) {}
    await LocalStorageService.clearAll();
    return false;
  }
}
