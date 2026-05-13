import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';

import '../utils/secure_logger.dart';
import 'security_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SecurityService _securityService = SecurityService();

  // Sign Up
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 30));

      final user = result.user;
      if (user != null) {
        try {
          await _securityService.saveSecureData(
            SecurityService.lastUserUidKey,
            user.uid,
          );
        } catch (_) {
          SecureLogger.w('Secure storage save failed');
        }
      }

      return user;
    } on TimeoutException {
      SecureLogger.w('Sign up timeout');
      throw Exception(
        'Request timed out. Please check your internet connection and try again.',
      );
    } on SocketException {
      SecureLogger.w('Sign up network error');
      throw Exception(
        'Network error. Please check your internet connection and try again.',
      );
    } on FirebaseAuthException {
      return null;
    } catch (_) {
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  // Login
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 30));

      final user = result.user;
      if (user != null) {
        try {
          await _securityService.saveSecureData(
            SecurityService.lastUserUidKey,
            user.uid,
          );
        } catch (_) {
          SecureLogger.w('Secure storage save failed');
        }
      }

      return user;
    } on TimeoutException {
      SecureLogger.w('Login timeout');
      throw Exception(
        'Request timed out. Please check your internet connection and try again.',
      );
    } on SocketException {
      SecureLogger.w('Login network error');
      throw Exception(
        'Network error. Please check your internet connection and try again.',
      );
    } on FirebaseAuthException {
      return null;
    } catch (_) {
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
    await _securityService.deleteSecureData(SecurityService.lastUserUidKey);
  }
}

