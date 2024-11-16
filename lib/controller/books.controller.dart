import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

        // Verificação e conversão de bookImageUserUrls para garantir que seja uma lista de strings
        var bookImageUserUrls = data['bookImageUserUrls'];
        if (bookImageUserUrls is String) {
          bookImageUserUrls = [bookImageUserUrls]; // Converte para lista se for uma string única
        } else if (bookImageUserUrls is List) {
          bookImageUserUrls = bookImageUserUrls.map((item) => item.toString()).toList();
        } else {
          bookImageUserUrls = ['https://via.placeholder.com/100']; // Placeholder se o campo estiver vazio ou nulo
        }

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
          bookImageUserUrls: bookImageUserUrls,
          imageApiUrl: data['imageApiUrl'],
          publishedDate: (data['publishedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
          condition: data['condition'] ?? 'Não especificado',
          edition: data['edition'] ?? 'Edição não especificada',
          genres: List<String>.from(data['genres'] ?? []),
          isbn: data['isbn'],
          publicationYear: data['publicationYear'] ?? 'Ano não especificado',
          publisher: data['publisher'] ?? 'Editora não especificada',
          isAvailable: data['isAvailable'] ?? true,
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

  Future<void> confirmDelete(BuildContext context, String bookId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // O usuário deve tocar em um botão
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Você tem certeza que deseja excluir este livro?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Excluir'),
              onPressed: () async{
                await updateBookAvailability(bookId, false, context);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> updateBookAvailability(String bookId, bool isAvailable, BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('books')
          .doc(bookId)
          .update({'isAvailable': isAvailable});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Livro removido com sucesso!')),
      );
    } catch (e) {
      throw Exception("Erro ao atualizar disponibilidade: $e");
    }
  }

  Future<String> getBookRequestStatus(String bookId) async {
    try {
      // Consulta na coleção de requests para verificar o status do livro
      final requestSnapshot =
      await FirebaseFirestore.instance.collection('requests').get();

      for (var doc in requestSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Verificar se o livro está no campo offeredBooks
        if (data['offeredBooks'] != null) {
          for (var offeredBook in data['offeredBooks']) {
            if (offeredBook['id'] == bookId) {
              // O usuário é o requester neste caso
              if (data['requesterConfirmationStatus'] == 'concluído') {
                return 'concluído';
              }
              return data['status']; // Retorna o status do request
            }
          }
        }
        // Verificar se o livro está no campo requestedBook
        if (data['requestedBook'] != null &&
            data['requestedBook']['id'] == bookId) {
          // O usuário é o owner neste caso
          if (data['ownerConfirmationStatus'] == 'concluído') {
            return 'concluído';
          }
          return data['status']; // Retorna o status do request
        }
      }
      return 'not_found'; // Retorna 'not_found' se o livro não estiver em nenhum request
    } catch (e) {
      throw Exception('Erro ao buscar status do request: $e');
    }
  }
}
