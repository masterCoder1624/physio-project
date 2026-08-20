import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';

class ApiService {
  /// Optional developer override for custom environments
  static String? customBaseUrl;

  /// Returns production Render base URL by default, or custom override if set
  static String get baseUrl {
    if (customBaseUrl != null && customBaseUrl!.isNotEmpty) {
      return customBaseUrl!;
    }
    return ApiConfig.baseUrl;
  }

  /// Register user API endpoint
  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    String? clinicName,
    String role = "physio",
  }) async {
    try {
      final nameParts = fullName.trim().split(RegExp(r'\s+'));
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final targetUrl = '$baseUrl/auth/register';
      debugPrint('DEBUG: API Base URL: $baseUrl');
      debugPrint('DEBUG: Registering at: $targetUrl');

      final response = await http.post(
        Uri.parse(targetUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'full_name': fullName.trim(),
          'first_name': firstName,
          'last_name': lastName,
          'email': email.trim(),
          'password': password,
          'phone': phone.trim(),
          'clinic_name': clinicName?.trim(),
          'role': role.toLowerCase().contains('physio') ? 'physiotherapist' : 'patient',
        }),
      ).timeout(ApiConfig.timeoutDuration);

      debugPrint('DEBUG: Response status: ${response.statusCode}');
      debugPrint('DEBUG: Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw _parseError(response);
      }
    } on SocketException catch (e) {
      debugPrint('ERROR: Network connection failed: $e');
      throw Exception('Cannot reach server. Please check your internet connection.');
    } on TimeoutException {
      debugPrint('ERROR: Request to $baseUrl timed out after ${ApiConfig.timeoutDuration.inSeconds}s.');
      throw Exception('Server took too long to respond. Render may be waking up, please retry.');
    } catch (e) {
      debugPrint('ERROR: $e');
      rethrow;
    }
  }

  /// Login user API endpoint
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final targetUrl = '$baseUrl/auth/login';
      debugPrint('DEBUG: Logging in at: $targetUrl');

      final response = await http.post(
        Uri.parse(targetUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      ).timeout(ApiConfig.timeoutDuration);

      debugPrint('DEBUG: Response status: ${response.statusCode}');
      debugPrint('DEBUG: Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw _parseError(response);
      }
    } on SocketException {
      throw Exception('Cannot reach server. Please check your internet connection.');
    } on TimeoutException {
      throw Exception('Server took too long to respond. Render may be waking up, please retry.');
    } catch (e) {
      debugPrint('ERROR: Login error: $e');
      rethrow;
    }
  }

  /// Add Patient API
  static Future<Map<String, dynamic>> addPatient({
    required String name,
    required String condition,
    required String phone,
    required String token,
    String? gender,
    String? medicalHistory,
  }) async {
    try {
      final targetUrl = '$baseUrl/patients';
      final response = await http.post(
        Uri.parse(targetUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name.trim(),
          'condition': condition.trim(),
          'primary_condition': condition.trim(),
          'phone': phone.trim(),
          'emergency_contact_phone': phone.trim(),
          'gender': gender,
          'medical_history': medicalHistory,
        }),
      ).timeout(ApiConfig.timeoutDuration);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw _parseError(response);
      }
    } catch (e) {
      debugPrint('ERROR: Add patient error: $e');
      rethrow;
    }
  }

  /// Get All Patients API
  static Future<List<dynamic>> getPatients({required String token}) async {
    try {
      final targetUrl = '$baseUrl/patients';
      final response = await http.get(
        Uri.parse(targetUrl),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.timeoutDuration);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['data'] is List) {
          return decoded['data'] as List<dynamic>;
        }
        return decoded is List ? decoded : [];
      } else {
        throw _parseError(response);
      }
    } catch (e) {
      debugPrint('ERROR: Get patients error: $e');
      rethrow;
    }
  }

  /// Delete Patient API
  static Future<Map<String, dynamic>> deletePatient({
    required String patientId,
    required String token,
  }) async {
    try {
      final targetUrl = '$baseUrl/patients/$patientId';
      final response = await http.delete(
        Uri.parse(targetUrl),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.timeoutDuration);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw _parseError(response);
      }
    } catch (e) {
      debugPrint('ERROR: Delete patient error: $e');
      rethrow;
    }
  }

  /// Helper error parser for HTTP status codes
  static Exception _parseError(http.Response response) {
    String detailMessage = 'Unexpected server response (${response.statusCode})';
    try {
      final body = jsonDecode(response.body);
      if (body is Map) {
        detailMessage = body['message'] ?? body['detail'] ?? body['error'] ?? detailMessage;
      }
    } catch (_) {}

    switch (response.statusCode) {
      case 400:
        return Exception('Bad request: $detailMessage');
      case 401:
        return Exception('Unauthorized: Invalid credentials or session expired.');
      case 403:
        return Exception('Forbidden: Access denied.');
      case 404:
        return Exception('Not found: Requested resource does not exist.');
      case 409:
        return Exception('Conflict: $detailMessage');
      case 422:
        return Exception('Validation error: $detailMessage');
      case 500:
        return Exception('Internal server error. Please try again later.');
      case 503:
        return Exception('Service temporarily unavailable. Server may be waking up, please retry.');
      default:
        return Exception('Error (${response.statusCode}): $detailMessage');
    }
  }
}
