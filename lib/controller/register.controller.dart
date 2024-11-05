import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegisterController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> registerWithEmail({
    required String email,
    required String password,
    required String passwordConfirm,
    required String name,
    required String phone,
  }) async {
    try {
      // Criação do usuário no Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.reload();
      User? user = userCredential.user;
      if (user != null) {
        // Armazenamento das informações do usuário no Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'name': name,
          'phone': phone,
          'address': '',
          'customerRating': 0.0,
          'profileImageUrl': '',
        });
        // Criação da subcoleção "favorites" no Firestore
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .doc('dummyDoc') // Documento vazio para inicializar a coleção
            .set({});

        return user;
      } else {
        Fluttertoast.showToast(
          msg: "Erro ao criar usuário.",
          toastLength: Toast.LENGTH_LONG,
        );
        return null;
      }
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(
        msg: "Erro de autenticação: ${e.message}",
        toastLength: Toast.LENGTH_LONG,
      );
      return null;
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Erro inesperado: $e",
        toastLength: Toast.LENGTH_LONG,
      );
      return null;
    }
  }
}