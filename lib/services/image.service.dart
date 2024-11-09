import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
      bucket: "gs://booktrade-c6ed3.firebasestorage.app");

  Future<File?> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  // Future<File> _resizeImage(File imageFile, int width, int height) async {
  //   final imageBytes = await imageFile.readAsBytes();
  //   final decodedImage = img.decodeImage(imageBytes);
  //
  //   if (decodedImage == null) {
  //     throw Exception("Erro ao decodificar a imagem");
  //   }
  //
  //   final resizedImage = img.copyResize(decodedImage, width: width, height: height);
  //   final resizedBytes = img.encodeJpg(resizedImage);
  //
  //   // Salva a imagem redimensionada em um novo arquivo temporário
  //   final resizedFile = File(imageFile.path)..writeAsBytesSync(resizedBytes);
  //   return resizedFile;
  // }

  // Método para upload de imagem de perfil do usuário
  Future<String?> uploadProfileImage(File imageFile, String userId) async {
    try {
      final ref = _storage.ref().child('profileImages').child(userId);
      final downloadUrl = await _uploadImage(ref, imageFile);

      // Atualiza a URL da imagem de perfil no Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'profileImageUrl': downloadUrl,
      });

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  // Método para upload de imagem de livro
  Future<String?> uploadBookImage(File imageFile, String userId, String bookId) async {
    try {
      // Verifica se `userId` e `bookId` são válidos
      if (userId.isEmpty || bookId.isEmpty) {
        return null;
      }

      final ref = _storage
          .ref()
          .child('bookImages')
          .child(userId)
          .child(bookId)
          .child(DateTime.now().millisecondsSinceEpoch.toString());

      // Faz o upload do arquivo e captura o snapshot
      final uploadTask = ref.putFile(imageFile);

      // Aguardar até o upload ser concluído e pegar o snapshot
      final TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);

      // Pega a URL de download do arquivo carregado
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Atualiza a URL da imagem do livro no Firestore
      await FirebaseFirestore.instance.collection('books').doc(bookId).update({
        'bookImageUserUrls': FieldValue.arrayUnion([downloadUrl]),
      });

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  // Função privada para upload genérico de imagem com logs detalhados
  Future<String> _uploadImage(Reference ref, File imageFile) async {
    try {
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }
}
