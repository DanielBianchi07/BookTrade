import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:google_sign_in/google_sign_in.dart';
import 'package:myapp/user.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../views/login.page.dart';

/*
class GoogleLoginController {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future login() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken,);

    final FirebaseUser firebaseUser = (await _auth.signInWithCredential(credential)).user;
  }
}
*/

class LoginController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future loginWithEmail(String email, String password) async {
      final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();
        if (userDoc.exists) {
          user.value = IUser()
          ..uid = userCredential.user!.uid
          ..name = userDoc.get('name') ?? ""
          ..email = userCredential.user!.email ?? ""
          ..picture = userDoc.get('profileImageUrl') ?? ""
          ..address = userDoc.get('address')
          ..customerRating = userDoc.get('customerRating') ?? 0.0
          ..telephone = userDoc.get('phone') ?? "";
          user.notifyListeners();
        } else {
          Fluttertoast.showToast(msg: "Usuário não encontrado.", toastLength: Toast.LENGTH_SHORT);
          return null;
        }
      } else {
        Fluttertoast.showToast(msg: "Usuário não encontrado.", toastLength: Toast.LENGTH_SHORT);
      }
  }

  Future logout(BuildContext context) async {
      await FirebaseAuth.instance.signOut();
      await FirebaseAuth.instance.currentUser?.reload();
      user.value = IUser();
      var currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        Fluttertoast.showToast(msg: "Logout realizado com sucesso", toastLength: Toast.LENGTH_SHORT);
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
      } else {
        Fluttertoast.showToast(msg: "Falha ao deslogar", toastLength: Toast.LENGTH_SHORT);
      }
  }

  void handleFirebaseAuthError(FirebaseAuthException e) {
    String errorMessage;
    switch (e.code) {
      case 'email-already-in-use':
        errorMessage = "Este email já está sendo usado.";
        break;
      case 'wrong-password':
        errorMessage = "Senha incorreta.";
        break;
      case 'user-not-found':
        errorMessage = "Usuário não encontrado.";
        break;
      case 'user-disabled':
        errorMessage = "Esta conta foi desativada.";
        break;
      case 'too-many-requests':
        errorMessage = "Muitas tentativas. Tente novamente mais tarde.";
        break;
      case 'operation-not-allowed':
        errorMessage = "Operação não permitida.";
        break;
      default:
        errorMessage = "Erro ao fazer login. Verifique suas credenciais.";
    }
    Fluttertoast.showToast(
      msg: errorMessage,
      toastLength: Toast.LENGTH_LONG,
    );
  }

  Future AssignUserData(BuildContext context) async {
    final userCredential = FirebaseAuth.instance.currentUser;
    if (userCredential != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.uid)
          .get();
      if (userDoc.exists) {
        user.value = IUser()
          ..uid = userCredential.uid
          ..name = userDoc.get('name') ?? ""
          ..email = userCredential.email ?? ""
          ..address = userDoc.get('address')
          ..customerRating = userDoc.get('customerRating') ?? 0.0
          ..picture = userDoc.get('profileImageUrl') ?? ""
          ..telephone = userDoc.get('phone') ?? "";
        user.notifyListeners();
      }
      else {
        logout(context);
      }
    }
  }
}