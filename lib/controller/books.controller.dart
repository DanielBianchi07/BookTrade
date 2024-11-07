import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/book.model.dart';
import '../models/user.info.model.dart';

class BooksController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool validateFields({
    required String title,
    required String author,
    required String edition,
    required String publicationYear,
    required String publisher,
    bool noIsbn = false,
    String? isbn,
    String? genre,
  }) {
    if (title.isEmpty) {
      throw Exception('O campo "Nome do Livro" é obrigatório.');
    }
    if (author.isEmpty) {
      throw Exception('O campo "Nome do Autor" é obrigatório.');
    }
    if (edition.isEmpty) {
      throw Exception('O campo "Edição" é obrigatório.');
    }
    if (!noIsbn && (isbn == null || isbn.isEmpty)) {
      throw Exception('O campo "ISBN" é obrigatório quando "Não possui ISBN" não está marcado.');
    }
    if (publicationYear.isEmpty) {
      throw Exception('O campo "Ano de publicação" é obrigatório.');
    }
    if (publisher.isEmpty) {
      throw Exception('O campo "Editora" é obrigatório.');
    }
    if (noIsbn && (genre == null || genre.isEmpty)) {
      throw Exception('O campo "Gênero" é obrigatório quando "Não possui ISBN" está marcado.');
    }
    return true;
  }

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
      Fluttertoast.showToast(
        msg: "Erro ao carregar os livros: $e",
        toastLength: Toast.LENGTH_LONG,
      );
      return [];
    }
  }

  Future<List<BookModel>> loadFavoriteBooks(String userId) async {
    try {
      // Busca os livros favoritados do Firebase
      List<String> favoriteBookIds = await getFavoriteBookIds(userId);

      // Carregar todos os livros da coleção 'books' do Firestore
      List<BookModel> allBooks = await loadBooks();

      // Filtra os livros que estão nos favoritos
      List<BookModel> favoriteBooks = allBooks.where((book) => favoriteBookIds.contains(book.id)).toList();

      return favoriteBooks;
    } catch (e) {
      return [];
    }
  }


  Future<List<String>> getFavoriteBookIds(String userId) async {
    try {
      // Busca os livros favoritados do Firebase
      QuerySnapshot favoritesSnapshot = await _firestore
          .collection('favorites')
          .doc(userId)
          .collection('userFavorites')
          .get();
      List<String> favoriteBookIds = favoritesSnapshot.docs.map((doc) => doc.id).toList();

      return favoriteBookIds;
    } catch (e) {
      print('Erro ao carregar IDs dos livros favoritos: $e');
      return [];
    }
  }

  Future<void> addBookToFavorites(String userId, String bookId) async {
    try {
      await _firestore
          .collection('favorites')
          .doc(userId)
          .collection('userFavorites')
          .doc(bookId)
          .set({'isFavorite': true});
    } catch (e) {
      print('Erro ao adicionar livro aos favoritos: $e');
    }
  }

  Future<void> removeBookFromFavorites(String userId, String bookId) async {
    try {
      await _firestore
          .collection('favorites')
          .doc(userId)
          .collection('userFavorites')
          .doc(bookId)
          .delete();
    } catch (e) {
      print('Erro ao remover livro dos favoritos: $e');
    }
  }

  Future<void> toggleFavoriteStatus(String userId, String bookId) async {
    try {
      final favoriteDoc = _firestore
          .collection('favorites')
          .doc(userId)
          .collection('userFavorites')
          .doc(bookId);

      final favoriteExists = await favoriteDoc.get();

      if (favoriteExists.exists) {
        // Se o livro já é favorito, remove
        await favoriteDoc.delete();
      } else {
        // Caso contrário, adiciona o livro aos favoritos
        await favoriteDoc.set({
          'addedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print("Erro ao alternar favorito: $e");
    }
  }
}
