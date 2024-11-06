// lib/services/book_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.model.dart';


class BookService {
  final CollectionReference booksCollection = FirebaseFirestore.instance.collection('books');

  // Método para buscar um livro pelo ID
  Future<BookModel> getBookById(String bookId) async {
    final doc = await booksCollection.doc(bookId).get();
    if (doc.exists) {
      return BookModel.fromDocument(doc);
    } else {
      throw Exception("Livro não encontrado");
    }
  }
}