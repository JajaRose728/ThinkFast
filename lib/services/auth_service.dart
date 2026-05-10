import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign Up
Future<User?> signUp(String email, String password) async {
  try {
    UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email, 
      password: password
    );
    return result.user;
  } on FirebaseAuthException catch (e) {
    // This will print the specific error to your console
    print("Firebase Error Code: ${e.code}"); 
    print("Firebase Error Message: ${e.message}");
    return null;
  } catch (e) {
    print(e.toString());
    return null;
  }
}

  // Login
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      return result.user;
    } catch (e) {
      return null;
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}