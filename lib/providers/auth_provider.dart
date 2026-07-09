import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({required AuthService authService}) : _authService = authService;

  final AuthService _authService;

  bool _isLoading = false;
  User? _currentUser;

  bool get isLoading => _isLoading;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<void> restoreSession() async {
    _currentUser = await _authService.restoreUserFromToken();
    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    _setLoading(true);
    try {
      _currentUser = await _authService.login(email: email, password: password);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? nim,
  }) async {
    _setLoading(true);
    try {
      _currentUser = await _authService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        nim: nim,
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
