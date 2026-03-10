import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, otpSent, error }

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthState _state = AuthState.initial;
  UserModel? _user;
  String? _errorMessage;
  String? _phone;
  bool _isNewUser = false;
  UserRole? _selectedRole;

  AuthState get state => _state;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  String? get phone => _phone;
  bool get isNewUser => _isNewUser;
  bool get isAuthenticated => _state == AuthState.authenticated;
  UserRole? get selectedRole => _selectedRole;

  void selectRole(UserRole role) {
    _selectedRole = role;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    _state = AuthState.loading;
    notifyListeners();

    try {
      _user = await _authService.getCurrentUser();
      _state = _user != null ? AuthState.authenticated : AuthState.unauthenticated;
    } catch (_) {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> sendOtp(String phone) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _phone = phone;
      final response = await _authService.sendOtp(phone);
      _isNewUser = response['isNewUser'] as bool? ?? false;
      _state = AuthState.otpSent;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = 'Failed to send OTP. Please try again.';
    }
    notifyListeners();
  }

  Future<bool> verifyOtp(String otp) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.verifyOtp(
        phone: _phone!,
        otp: otp,
      );

      if (response['user'] != null) {
        _user = UserModel.fromJson(response['user'] as Map<String, dynamic>);
        _state = AuthState.authenticated;
        notifyListeners();
        return true;
      }

      // New user — needs role selection
      _isNewUser = true;
      _state = AuthState.otpSent;
      notifyListeners();
      return true;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = 'Invalid OTP. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerWithRole({
    required String name,
    required UserRole role,
    String? email,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authService.register(
        name: name,
        phone: _phone!,
        role: role,
        email: email,
      );
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = 'Registration failed. Please try again.';
      notifyListeners();
      return false;
    }
  }

  void updateUser(UserModel updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _phone = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }

  // For demo/development — set a mock user
  void setMockUser(UserRole role) {
    _user = UserModel(
      id: 'mock_${role.name}_1',
      name: role == UserRole.student
          ? 'Arjun Kumar'
          : role == UserRole.parent
              ? 'Rajesh Kumar'
              : 'Dr. Priya Sharma',
      phone: '+91 98765 43210',
      email: '${role.name}@guidanceguru.ai',
      role: role,
      createdAt: DateTime.now(),
      studentCode: role == UserRole.student ? 'STU2024001' : null,
    );
    _state = AuthState.authenticated;
    notifyListeners();
  }
}
