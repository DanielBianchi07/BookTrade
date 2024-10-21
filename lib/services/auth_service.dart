import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Registrar usuário e salvar seus dados (exceto a imagem de perfil)
  Future<User?> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      // Criar o usuário no Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      // Criar documento no Firestore para o usuário (sem imagem inicialmente)
      await _firestore.collection('users').doc(user!.uid).set({
        'name': name,
        'phone': phone,
        'email': email,
        'profileImageUrl': '', // Deixamos a imagem vazia por enquanto
      });

      return user;
    } catch (e) {
      print('Erro ao registrar: $e');
      return null;
    }
  }

  // Fazer login
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      _handleFirebaseAuthError(e);
      return null;
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Erro desconhecido ao fazer login: $e",
        toastLength: Toast.LENGTH_LONG,
      );
      return null;
    }
  }

  // Fazer logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
      Fluttertoast.showToast(
        msg: "Logout realizado com sucesso",
        toastLength: Toast.LENGTH_SHORT,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Erro ao fazer logout: $e",
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  // Método para tratar erros do FirebaseAuth
  void _handleFirebaseAuthError(FirebaseAuthException e) {
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
