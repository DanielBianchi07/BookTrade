import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegisterController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> registerWithEmail({required String email, required String password, required String passwordConfirm,
  required String name, required String phone, String? address}) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(name);
        await userCredential.user!.reload();
        User? user = userCredential.user;

        // Armazenamento das informações do usuário no Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({'email': email, 'name': name, 'phone': phone,
          'address': address, 'customerRating': 0.0, 'favoriteGenres': [], 'profileImageUrl': ''});

        // Criação da subcoleção "favorites" no Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).collection('favorites').doc('dummyDoc').set({});

        return user;
      } else {
        Fluttertoast.showToast(msg: "Erro ao criar usuário", toastLength: Toast.LENGTH_LONG);
      }
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: "Erro de autenticação: ${e.message}", toastLength: Toast.LENGTH_LONG);
      return null;
    } catch (e) {
      Fluttertoast.showToast(msg: "Erro inesperado: $e", toastLength: Toast.LENGTH_LONG);
      return null;
    }
    return null;
  }
}