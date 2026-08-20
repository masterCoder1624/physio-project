import '../core/network/api_client.dart';
import '../core/storage/local_storage_service.dart';
import '../models/user_model.dart';

class AuthService {
  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/login',
      body: {
        'email': email.trim(),
        'password': password,
      },
    );

    if (response.success && response.data != null) {
      final data = response.data!;
      await LocalStorageService.saveTokens(
        accessToken: data['access_token'] as String? ?? '',
        refreshToken: data['refresh_token'] as String? ?? '',
        userId: data['user_id'] as String? ?? '',
        role: data['role'] as String? ?? 'patient',
      );

      return await getProfile();
    } else {
      throw Exception(response.message);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
    String? phone,
  }) async {
    final response = await _apiClient.post(
      '/auth/register',
      body: {
        'email': email.trim(),
        'password': password,
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'phone': phone?.trim(),
        'role': role.toLowerCase().contains('physio') ? 'physiotherapist' : 'patient',
      },
    );

    if (!response.success) {
      throw Exception(response.message);
    }
  }

  Future<UserModel> getProfile() async {
    final response = await _apiClient.get<UserModel>(
      '/auth/me',
      fromJson: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<void> logout() async {
    await LocalStorageService.clearAll();
  }

  Future<bool> isLoggedIn() async {
    final token = await LocalStorageService.getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
