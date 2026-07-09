import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  AuthService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<User?> restoreUserFromToken() async {
    final token = await _apiService.readToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      return await _apiService.getUserProfile();
    } catch (_) {
      await _apiService.clearToken();
      return null;
    }
  }

  Future<User> login({required String email, required String password}) async {
    return _apiService.login(email: email, password: password);
  }

  Future<User> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? nim,
  }) async {
    return _apiService.register(
      name: name,
      email: email,
      password: password,
      phone: phone,
      nim: nim,
    );
  }

  Future<void> logout() async {
    await _apiService.logout();
  }
}
