import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> sendOtp(String phone) async {
    final response = await _api.post('/auth/login', data: {'phone': phone});
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final response = await _api.post('/auth/verify-otp', data: {
      'phone': phone,
      'otp': otp,
    });
    final data = response.data as Map<String, dynamic>;

    if (data['token'] != null) {
      await _api.saveTokens(
        token: data['token'] as String,
        refreshToken: data['refreshToken'] as String?,
      );
    }

    return data;
  }

  Future<UserModel> register({
    required String name,
    required String phone,
    required UserRole role,
    String? email,
  }) async {
    final response = await _api.post('/auth/register', data: {
      'name': name,
      'phone': phone,
      'role': role.name,
      'email': email,
    });
    final data = response.data as Map<String, dynamic>;

    if (data['token'] != null) {
      await _api.saveTokens(
        token: data['token'] as String,
        refreshToken: data['refreshToken'] as String?,
      );
    }

    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<UserModel?> getCurrentUser() async {
    final token = await _api.getToken();
    if (token == null) return null;

    try {
      final response = await _api.get('/auth/me');
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    await _api.clearTokens();
  }
}
