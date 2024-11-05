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
      User? user = userCredential.user;
      if (user != null) {
        // Armazenamento das informações do usuário no Firestore
        await _firestore.collection('users').doc(user!.uid).set({
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
      }
      else {
        Fluttertoast.showToast(
          msg: "Erro ao criar usuário.",
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (e) {
      return null; // Pode ser interessante retornar o erro para tratamento adicional
    }
  }

  // Função para alternar o status de favorito
  Future<void> toggleFavoriteStatus(String bookId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return; // Verifique se o usuário está autenticado

      final userFavorites = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(bookId);

      final favoriteExists = await userFavorites.get();

      if (favoriteExists.exists) {
        // Se o livro já é favorito, remove
        await userFavorites.delete();
      } else {
        // Caso contrário, adiciona o livro aos favoritos
        await userFavorites.set({
          'addedAt': FieldValue.serverTimestamp(),
          // Adicione outros campos se necessário
        });
      }
    } catch (e) {
      print("Erro ao alternar favorito: $e");
    }
  }
}
