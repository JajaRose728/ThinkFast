import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:io';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign Up
Future<User?> signUp(String email, String password) async {
  try {
    UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email, 
      password: password
    ).timeout(const Duration(seconds: 30));
    return result.user;
  } on TimeoutException catch (e) {
    print("Sign up timeout: $e");
    throw Exception("Request timed out. Please check your internet connection and try again.");
  } on SocketException catch (e) {
    print("Sign up network error: $e");
    throw Exception("Network error. Please check your internet connection and try again.");
  } on FirebaseAuthException catch (e) {
    // This will print the specific error to your console
    print("Firebase Error Code: ${e.code}"); 
    print("Firebase Error Message: ${e.message}");
    return null;
  } catch (e) {
    print("Unexpected error during sign up: $e");
    throw Exception("An unexpected error occurred. Please try again.");
  }
}

  // Login
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      ).timeout(const Duration(seconds: 30));
      return result.user;
    } on TimeoutException catch (e) {
      print("Login timeout: $e");
      throw Exception("Request timed out. Please check your internet connection and try again.");
    } on SocketException catch (e) {
      print("Login network error: $e");
      throw Exception("Network error. Please check your internet connection and try again.");
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Error: ${e.code} - ${e.message}");
      return null;
    } catch (e) {
      print("Unexpected error during login: $e");
      throw Exception("An unexpected error occurred. Please try again.");
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}