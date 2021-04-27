import 'package:firebase_auth/firebase_auth.dart';

class Authentication {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> signIn(String email, String password) async {
    try {
      final User user = (await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      ))
          .user;

      if (user != null) {
        return "true";
      } else {
        return "false";
      }
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
  }

  Future<String> register(String email, String password) async {
    try {
      final User user = (await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      ))
          .user;
      if (user != null) {
        return "true";
      } else {
        return "false";
      }
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
  }
}
