import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
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
  String? _email;
  bool _isNewUser = false;
  UserRole? _selectedRole;
  bool _isEmailLogin = false;
  String? _signupName;
  String? _signupEmail;
  StreamSubscription? _authSub;

  AuthController() {
    // Listen to Firebase auth state changes
    _authSub = _authService.authStateChanges.listen((firebaseUser) {
      if (firebaseUser == null && _state == AuthState.authenticated) {
        _user = null;
        _state = AuthState.unauthenticated;
        notifyListeners();
      }
    });
  }

  AuthState get state => _state;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  String? get phone => _phone;
  String? get email => _email;
  bool get isNewUser => _isNewUser;
  bool get isAuthenticated => _state == AuthState.authenticated;
  UserRole? get selectedRole => _selectedRole;
  bool get isEmailLogin => _isEmailLogin;
  String? get signupName => _signupName;
  String? get signupEmail => _signupEmail;

  /// The identifier shown on the OTP screen (phone or email)
  String get loginIdentifier => _isEmailLogin ? (_email ?? '') : (_phone ?? '');

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
      _errorMessage = _formatAuthError(e);
    }
    notifyListeners();
  }

  Future<void> sendEmailOtp(String email) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _email = email;
      _isEmailLogin = true;
      // Mock: simulate sending OTP to email
      await Future.delayed(const Duration(milliseconds: 600));
      _isNewUser = false;
      _state = AuthState.otpSent;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = 'Failed to send OTP to email. Please try again.';
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

  Future<void> signUp({
    required String name,
    required String email,
    required String phone,
    required UserRole role,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedRole = role;
      _phone = phone;
      _signupName = name;
      _signupEmail = email;
      final response = await _authService.sendOtp(phone);
      _isNewUser = response['isNewUser'] as bool? ?? true;
      _state = AuthState.otpSent;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = _formatAuthError(e);
    }
    notifyListeners();
  }

  String _formatAuthError(Object e) {
    final msg = e.toString();
    if (e is FirebaseAuthException) {
      return e.message ?? 'Authentication failed. Please try again.';
    }
    if (msg.contains('FirebaseAuthException')) {
      return msg.replaceFirst(RegExp(r'.*\] '), '');
    }
    if (msg.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later.';
    }
    if (msg.contains('invalid-phone-number')) {
      return 'Invalid phone number. Please check and try again.';
    }
    if (msg.contains('network-request-failed')) {
      return 'Network error. Please check your connection.';
    }
    return 'Something went wrong. Please try again.';
  }

  void updateUser(UserModel updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _phone = null;
    _email = null;
    _isEmailLogin = false;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }

  // For demo/development — set a mock user
  void setMockUser(UserRole role, {bool isNewSignup = false}) {
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
      counselorName: role == UserRole.student && !isNewSignup ? 'Dr. Priya Sharma' : null,
      counselorPhone: role == UserRole.student && !isNewSignup ? '+91 98765 00001' : null,
      parentName: role == UserRole.student && !isNewSignup ? 'Rajesh Kumar' : null,
      parentPhone: role == UserRole.student && !isNewSignup ? '+91 98765 00002' : null,
    );
    _isNewUser = isNewSignup;
    _state = AuthState.authenticated;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
