import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.model.dart';
import '../models/user.info.model.dart';

class BooksController {
  Future<List<BookModel>> loadBooks() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('books').get();

      List<BookModel> books = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        // Criação do objeto UserInfo baseado no documento do Firestore
        UInfo userInfo = UInfo(
          id: data['userInfo']['userId'] ?? '', // Certifique-se que 'userId' está sendo salvo no campo correto
          name: data['userInfo']['name'] ?? '',
          address: data['userInfo']['address'] ?? '',
          customerRating: (data['userInfo']['customerRating'] ?? 0.0).toDouble(),
          profileImageUrl: data['userInfo']['profileImageUrl'] ?? '',
          email: data['userInfo']['email'] ?? '',
          phone: data['userInfo']['phone'] ?? '',
        );

        // Retorna o modelo BookModel com todos os dados, incluindo o userInfo
        return BookModel(
          userId: data['userId'] ?? '', // Certifique-se que está sendo atribuído corretamente
          id: doc.id,
          title: data['title'] ?? 'Título não disponível',
          author: data['author'] ?? 'Autor desconhecido',
          imageUserUrl: data['imageUserUrl'] ?? 'https://via.placeholder.com/100', // Placeholder se não houver imagem
          imageApiUrl: data['imageApiUrl'],
          publishedDate: (data['publishedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
          condition: data['condition'] ?? 'Não especificado',
          edition: data['edition'] ?? 'Edição não especificada',
          genres: List<String>.from(data['genres'] ?? []),
          isbn: data['isbn'],
          publicationYear: data['publicationYear'] ?? 'Ano não especificado',
          publisher: data['publisher'] ?? 'Editora não especificada',
          userInfo: userInfo,
        );
      }).toList();

      return books;
    } catch (e) {
      print('Erro ao carregar livros: $e');
      return [];
    }
  }



  Future<List<BookModel>> loadFavoriteBooks(String userId) async {
    try {
      // Busca os livros favoritados do Firebase
      QuerySnapshot favoritesSnapshot = await FirebaseFirestore.instance
          .collection('favorites')
          .doc(userId)
          .collection('userFavorites')
          .get();
      List<String> favoriteBookIds = favoritesSnapshot.docs.map((doc) => doc.id).toList();

      // Carregar todos os livros da coleção 'books' do Firestore
      List<BookModel> allBooks = await loadBooks();

      // Filtra os livros que estão nos favoritos
      List<BookModel> favoriteBooks = allBooks.where((book) => favoriteBookIds.contains(book.id)).toList();

      return favoriteBooks;
    } catch (e) {
      print('Erro ao carregar livros favoritos: $e');
      return [];
    }
  }
}