import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import '../models/user.info.dart';

class BooksController {
  Future<List<BookModel>> loadBooks() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('books').get();

      List<BookModel> books = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        // Criação do objeto UserInfo baseado no documento do Firestore
        UserInfo userInfo = UserInfo(
          profileImageUrl: data['userInfo']['profileImageUrl'] ?? '',
          address: data['userInfo']['address'] ?? '',
          customerRating: (data['userInfo']['customerRating'] ?? 0.0).toDouble(),
          name: data['userInfo']['name'] ?? '',
          email: data['userInfo']['email'] ?? '',
          phone: data['userInfo']['phone'] ?? '',
        );

        // Retorna o modelo BookModel com todos os dados, incluindo o userInfo
        return BookModel(
          userId: data['userId'],
          id: doc.id,
          author: data['author'] ?? 'Autor desconhecido',
          condition: data['condition'] ?? 'Não especificado',
          edition: data['edition'] ?? 'Edição não especificada',
          genres: List<String>.from(data['genres']),
          imageUserUrl: data['imageUserUrl'] ?? '',
          imageApiUrl: data['imageApiUrl'],
          publicationYear: data['publicationYear'] ?? 'Ano não especificado',
          publishedDate: (data['publishedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
          publisher: data['publisher'] ?? 'Editora não especificada',
          selectedExchangeGenres: List<String>.from(data['selectedExchangeGenres']),
          title: data['title'] ?? 'Título desconhecido',
          userInfo: userInfo,
        );
      }).toList();

      return books;
    } catch (e) {
      print('Erro ao carregar livros: $e');
      return [];
    }
  }
}