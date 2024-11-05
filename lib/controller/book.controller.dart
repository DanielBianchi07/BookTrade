import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book.dart';
import '../models/user_info.dart';
import '../services/book_service.dart';


class BooksController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final BookService _bookService = BookService();
  //
  // Future<void> saveBook(BookModel book) {
  //   return _bookService.saveBook(book);
  // }
  //
  // Future<List<String>> getGenres(String query) {
  //   return _bookService.fetchGenresFromGoogleBooksAPI(query);
  // }
  //
  // Future<BookModel> getBookDetailsByISBN(String isbn) {
  //   return _bookService.fetchBookDataFromISBN(isbn);
  // }

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
      QuerySnapshot snapshot = await _firestore.collection('books').get();

      List<BookModel> books = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        // Criação do objeto UserInfo baseado no documento do Firestore
        UInfo userInfo = UInfo(
          id: data['userInfo']['userId'] ?? '',
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
      print('Erro ao carregar livros favoritos: $e');
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

  // Validação e Criação do Livro
  // Future<BookModel> prepareBook({
  //   required String title,
  //   required String author,
  //   required String edition,
  //   required String publicationYear,
  //   required String publisher,
  //   required String condition,
  //   required bool noIsbn,
  //   String? isbn,
  //   String? genre,
  //   List<String>? genres,
  //   String? imageUrl,
  // }) async {
  //   // Validação dos campos
  //   validateFields(
  //     title: title,
  //     author: author,
  //     edition: edition,
  //     publicationYear: publicationYear,
  //     publisher: publisher,
  //     noIsbn: noIsbn,
  //     isbn: isbn,
  //     genre: genre,
  //   );
  //
  //   // Obter o ID do usuário autenticado
  //   User? currentUser = FirebaseAuth.instance.currentUser;
  //   if (currentUser == null) {
  //     throw Exception('Erro: Usuário não autenticado.');
  //   }
  //
  //   // Buscar informações do usuário a partir do Firestore
  //   DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
  //   if (!userDoc.exists) {
  //     throw Exception('Erro: Dados do usuário não encontrados.');
  //   }
  //
  //   // Criar objeto UserInfo a partir dos dados do Firestore
  //   UserInfo userInfo = UserInfo.fromMap(userDoc.data() as Map<String, dynamic>);
  //
  //   // Criar e retornar o modelo do livro
  //   return createBook(
  //     userId: currentUser.uid,
  //     title: title,
  //     author: author,
  //     edition: edition,
  //     publicationYear: publicationYear,
  //     publisher: publisher,
  //     condition: condition,
  //     isbn: noIsbn ? null : isbn?.trim(),
  //     genres: noIsbn ? [genre!] : genres,
  //     imageUrl: imageUrl,
  //     userInfo: userInfo,
  //   );
  // }
  //
  // // Cria uma instância de BookModel com os dados coletados
  // BookModel createBook({
  //   required String userId,
  //   required String title,
  //   required String author,
  //   required String edition,
  //   required String publicationYear,
  //   required String publisher,
  //   required String condition,
  //   String? isbn,
  //   String? genre,
  //   List<String>? genres,
  //   String? imageUrl,
  //   String? imageApi,
  //   required UserInfo userInfo,
  // }) {
  //   return BookModel(
  //     uid: userId,
  //     id: '', // O ID será gerado automaticamente pelo Firestore
  //     title: title,
  //     author: author,
  //     imageUrl: imageUrl ?? '',
  //     imageApi: imageApi,
  //     publishedDate: DateTime.now(),
  //     condition: condition,
  //     edition: edition,
  //     genres: genres,
  //     selectedGenres: genres ?? [],
  //     isbn: isbn,
  //     publicationYear: publicationYear,
  //     publisher: publisher,
  //     userInfo: userInfo,
  //   );
  // }
}
