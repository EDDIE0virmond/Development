// lib/core/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/auth_service.dart';
import '../models/login_request.dart';
import '../models/user_model.dart';
import '../constants/api_constants.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;

  // Getters para verificar permissões
  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isMaster => _currentUser?.role == 'master';
  bool get isComum => _currentUser?.role == 'comum';
  bool get canCreateUsers => isAdmin || isMaster;
  String get userRole => _currentUser?.role ?? 'comum';

  AuthProvider() {
    _loadStoredSession();
  }

  // Legacy serialized profiles are not proof of authentication. Never restore
  // roles or a signed-in state from editable, unencrypted preferences.
  Future<void> _loadStoredSession() async {
    _currentUser = null;
    _isAuthenticated = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(ApiConstants.userDataKey);
    } catch (_) {
      // A storage failure must leave the legacy client signed out.
    } finally {
      notifyListeners();
    }
  }

  Future<bool> login(String email, String senha, bool rememberMe) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final request = LoginRequest(email: email, senha: senha);
      final response = await _authService.login(request);

      if (response.success && response.user != null) {
        _currentUser = UserModel(
          id: response.user!.id, // Adicionar o id aqui
          nome: response.user!.nome,
          email: response.user!.email,
          role: response.role ?? 'comum',
        );
        _isAuthenticated = true;

        if (rememberMe) {
          await _saveSession();
        }

        _setLoading(false);
        return true;
      } else {
        _errorMessage = response.message ?? 'Erro ao fazer login';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erro inesperado: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  Future<void> _saveSession() async {
    // The current portal persists only a refresh token through secure storage.
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConstants.userDataKey);
  }

  Future<void> logout() async {
    _setLoading(true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConstants.userDataKey);

    _currentUser = null;
    _isAuthenticated = false;

    _setLoading(false);
  }

  Future<void> refreshUser() async {
    await _loadStoredSession();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
