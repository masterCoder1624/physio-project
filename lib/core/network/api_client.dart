import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'api_exception.dart';
import 'api_response.dart';
import 'token_interceptor.dart';

class ApiClient {
  /// Optional static override for local testing/custom environments
  static String? overrideBaseUrl;

  ApiClient({String? baseUrl})
      : baseUrl = baseUrl ?? overrideBaseUrl ?? ApiConfig.baseUrl,
        _interceptor = TokenInterceptor(baseUrl: baseUrl ?? overrideBaseUrl ?? ApiConfig.baseUrl);

  final String baseUrl;
  final TokenInterceptor _interceptor;
  final Duration timeoutDuration = ApiConfig.timeoutDuration;

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, String>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    return _sendRequest<T>(
      'GET',
      path,
      queryParameters: queryParameters,
      fromJson: fromJson,
    );
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic body,
    T Function(dynamic json)? fromJson,
  }) async {
    return _sendRequest<T>(
      'POST',
      path,
      body: body,
      fromJson: fromJson,
    );
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic body,
    T Function(dynamic json)? fromJson,
  }) async {
    return _sendRequest<T>(
      'PUT',
      path,
      body: body,
      fromJson: fromJson,
    );
  }

  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic body,
    T Function(dynamic json)? fromJson,
  }) async {
    return _sendRequest<T>(
      'PATCH',
      path,
      body: body,
      fromJson: fromJson,
    );
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    T Function(dynamic json)? fromJson,
  }) async {
    return _sendRequest<T>(
      'DELETE',
      path,
      fromJson: fromJson,
    );
  }

  Future<ApiResponse<T>> _sendRequest<T>(
    String method,
    String path, {
    dynamic body,
    Map<String, String>? queryParameters,
    T Function(dynamic json)? fromJson,
    bool isRetry = false,
  }) async {
    Uri uri = Uri.parse('$baseUrl$path');
    if (queryParameters != null && queryParameters.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParameters);
    }

    final headers = await _interceptor.getHeaders();
    http.Response response;

    try {
      debugPrint('HTTP $method Request to: $uri');
      final encodedBody = body != null ? jsonEncode(body) : null;

      switch (method) {
        case 'GET':
          response = await http.get(uri, headers: headers).timeout(timeoutDuration);
          break;
        case 'POST':
          response = await http
              .post(uri, headers: headers, body: encodedBody)
              .timeout(timeoutDuration);
          break;
        case 'PUT':
          response = await http
              .put(uri, headers: headers, body: encodedBody)
              .timeout(timeoutDuration);
          break;
        case 'PATCH':
          response = await http
              .patch(uri, headers: headers, body: encodedBody)
              .timeout(timeoutDuration);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers).timeout(timeoutDuration);
          break;
        default:
          throw ApiException(message: 'Unsupported HTTP method $method');
      }

      debugPrint('HTTP $method Response (${response.statusCode}): ${response.body}');

      if (response.statusCode == 401 && !isRetry) {
        final refreshed = await _interceptor.attemptRefreshToken();
        if (refreshed) {
          return _sendRequest<T>(
            method,
            path,
            body: body,
            queryParameters: queryParameters,
            fromJson: fromJson,
            isRetry: true,
          );
        }
      }

      return _parseResponse<T>(response, fromJson);
    } on SocketException {
      throw ApiException(
        message: 'Cannot reach server. Please check your network connection.',
      );
    } on TimeoutException {
      throw ApiException(
        message: 'Request timed out. The server may be waking up from cold start, please retry.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Network error occurred: ${e.toString()}',
      );
    }
  }

  ApiResponse<T> _parseResponse<T>(
    http.Response response,
    T Function(dynamic json)? fromJson,
  ) {
    Map<String, dynamic> jsonBody;
    try {
      jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Server returned invalid response format (${response.statusCode}).',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse<T>.fromJson(jsonBody, fromJson);
    } else {
      final errorMessage = jsonBody['message'] ??
          jsonBody['detail'] ??
          jsonBody['error'] ??
          _getDefaultStatusMessage(response.statusCode);

      throw ApiException(
        statusCode: response.statusCode,
        message: errorMessage.toString(),
        errors: jsonBody['errors'],
      );
    }
  }

  String _getDefaultStatusMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check input parameters.';
      case 401:
        return 'Unauthorized. Session expired or credentials invalid.';
      case 403:
        return 'Access forbidden.';
      case 404:
        return 'Requested endpoint or resource not found.';
      case 409:
        return 'Data conflict error.';
      case 422:
        return 'Validation error. Please verify form inputs.';
      case 500:
        return 'Internal server error occurred.';
      case 503:
        return 'Service temporarily unavailable. Server may be spinning up.';
      default:
        return 'An unexpected error occurred ($statusCode)';
    }
  }
}
