import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
      bucket: "gs://booktrade-c6ed3.firebasestorage.app");

  Future<File?> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    return pickedFile != null ? File(pickedFile.path) : null;
  }


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

  Future<String?> uploadApiImage(String imageUrl, String userId, String bookId) async {
    try {
      // Verifica se `userId` e `bookId` são válidos
      if (userId.isEmpty || bookId.isEmpty || imageUrl.isEmpty) {
        return null;
      }

      // Faz o download da imagem da URL da API
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        // Cria um arquivo temporário para upload
        final tempDir = await getTemporaryDirectory();
        final tempFilePath = '${tempDir.path}/temp_book_image.jpg';
        final tempFile = File(tempFilePath);
        await tempFile.writeAsBytes(response.bodyBytes);

        // Faz o upload do arquivo para o Firebase Storage
        final ref = _storage
            .ref()
            .child('bookImages')
            .child(userId)
            .child(bookId)
            .child('api_image_${DateTime.now().millisecondsSinceEpoch}');

        final uploadTask = ref.putFile(tempFile);
        final snapshot = await uploadTask.whenComplete(() => null);
        final downloadUrl = await snapshot.ref.getDownloadURL();

        // Atualiza o campo `bookImageUserUrls` para garantir que seja o primeiro índice
        final bookRef = FirebaseFirestore.instance.collection('books').doc(bookId);
        final bookDoc = await bookRef.get();

        if (bookDoc.exists) {
          final bookData = bookDoc.data() as Map<String, dynamic>;
          final List<String> currentUrls = List<String>.from(bookData['bookImageUserUrls'] ?? []);

          // Coloca a nova URL como o primeiro índice
          final updatedUrls = [downloadUrl, ...currentUrls];
          await bookRef.update({'bookImageUserUrls': updatedUrls});
        } else {
          // Caso o documento não exista, cria com a nova URL
          await bookRef.set({'bookImageUserUrls': [downloadUrl]});
        }

        return downloadUrl;
      } else {
        throw Exception('Erro ao baixar imagem da API.');
      }
    } catch (e) {
      print('Erro ao salvar imagem da API: $e');
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
