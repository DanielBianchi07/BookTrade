import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
//import 'package:google_sign_in/google_sign_in.dart';
import 'package:myapp/user.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
      user.uid = userCredential.user!.uid;
      user.name = userCredential.user!.displayName ?? "";
      user.email = userCredential.user!.email ?? "";
      user.picture = userCredential.user!.photoURL ?? "";
      user.telephone = userCredential.user!.phoneNumber ?? "";
  }

  Future logout() async {
      await FirebaseAuth.instance.signOut();
      await FirebaseAuth.instance.currentUser?.reload();
      user = new IUser();
      var currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        Fluttertoast.showToast(msg: "Logout realizado com sucesso", toastLength: Toast.LENGTH_SHORT);
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
}