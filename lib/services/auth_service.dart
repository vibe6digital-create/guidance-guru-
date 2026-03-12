import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirestoreService _fs = FirestoreService();

  bool get _useMock => dotenv.get('USE_MOCK', fallback: 'false') == 'true';

  // Held between sendOtp → verifyOtp
  String? _verificationId;
  int? _resendToken;

  /// Stream that emits whenever auth state changes.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Current Firebase UID (or null).
  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  // ── Send OTP ────────────────────────────────────────────────

  Future<Map<String, dynamic>> sendOtp(String phone) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {'isNewUser': false};
    }

    // Only disable app verification in debug mode for emulator/simulator testing
    if (kDebugMode) {
      await _firebaseAuth.setSettings(appVerificationDisabledForTesting: true);
    }

    final completer = Completer<void>();

    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phone,
      forceResendingToken: _resendToken,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-sign-in on Android (auto-retrieve SMS)
        await _firebaseAuth.signInWithCredential(credential);
        if (!completer.isCompleted) completer.complete();
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) {
          completer.completeError(e);
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        if (!completer.isCompleted) completer.complete();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
      timeout: const Duration(seconds: 60),
    );

    // Wait for codeSent or verificationFailed callback
    await completer.future;

    // Check if the user doc exists in Firestore
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid != null) {
      final doc = await _fs.getDocument(_fs.users, uid);
      return {'isNewUser': doc == null};
    }

    return {'isNewUser': true};
  }

  // ── Verify OTP ──────────────────────────────────────────────

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {'user': null}; // triggers new-user path in controller
    }

    if (_verificationId == null) {
      throw Exception('No verification ID. Please request OTP again.');
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: otp,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final uid = userCredential.user!.uid;

    // Look up Firestore user doc
    final doc = await _fs.getDocument(_fs.users, uid);
    if (doc != null) {
      return {'user': doc};
    }

    // New user — no doc yet
    return {'user': null, 'isNewUser': true};
  }

  // ── Register ────────────────────────────────────────────────

  Future<UserModel> register({
    required String name,
    required String phone,
    required UserRole role,
    String? email,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return UserModel(
        id: 'mock_${role.name}_1',
        name: name,
        phone: phone,
        email: email,
        role: role,
        createdAt: DateTime.now(),
        studentCode: role == UserRole.student ? 'STU${DateTime.now().millisecondsSinceEpoch}' : null,
      );
    }

    final uid = _firebaseAuth.currentUser!.uid;
    final now = DateTime.now();
    final studentCode = role == UserRole.student
        ? 'STU${now.millisecondsSinceEpoch}'
        : null;

    final userData = {
      'id': uid,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role.name,
      'createdAt': now.toIso8601String(),
      'studentCode': studentCode,
    };

    await _fs.setDocument(_fs.users, uid, userData, merge: false);

    // Create role-specific sub-doc
    if (role == UserRole.student) {
      await _fs.setDocument(_fs.studentProfile(uid), 'data', {
        'studentCode': studentCode,
      });
    } else if (role == UserRole.counselor) {
      await _fs.setDocument(_fs.counselorProfile(uid), 'data', {
        'specialization': '',
        'experienceYears': 0,
        'rating': 0.0,
        'studentsGuided': 0,
        'bio': '',
        'languages': [],
        'isAvailable': true,
      });
    }

    return UserModel.fromJson(userData);
  }

  // ── Get current user ────────────────────────────────────────

  Future<UserModel?> getCurrentUser() async {
    if (_useMock) return null;

    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _fs.getDocument(_fs.users, uid);
    if (doc == null) return null;
    return UserModel.fromJson(doc);
  }

  // ── Logout ──────────────────────────────────────────────────

  Future<void> logout() async {
    if (!_useMock) {
      await _firebaseAuth.signOut();
    }
  }
}
