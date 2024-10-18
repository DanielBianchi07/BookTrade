


import 'package:firebase_auth/firebase_auth.dart';

class RegisterController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future registerWithEmail(String email, String password) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }
}