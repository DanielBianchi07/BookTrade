import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future registerWithEmail({required String email, required String password, required String passwordConfirm, required String name, required String phone}) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      await _firestore.collection('users').doc(user!.uid).set({
        'name': name,
        'phone': phone,
        'email': email,
        'profileImageUrl': '',
      });
      return user;
    }
    catch (e) {
      return;
    }
  }
}