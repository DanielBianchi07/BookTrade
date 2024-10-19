import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String imageUrl; // URL da imagem
  final String? postedBy; // Quem postou o livro
  final String? profileImageUrl; // URL da imagem de perfil
  final double? rating; // Avaliação do livro
  final DateTime? publishedDate; // Data de publicação
  final String? condition; // Condição do livro
  final String? edition; // Edição do livro
  final List<String>? exchangeGenres; // Gêneros de troca
  final List<String>? genres; // Gêneros do livro
  final String? isbn; // ISBN do livro
  final String? publicationYear; // Ano de publicação
  final String? publisher; // Editora do livro

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    this.postedBy,
    this.profileImageUrl,
    this.rating,
    this.publishedDate,
    this.condition,
    this.edition,
    this.exchangeGenres,
    this.genres,
    this.isbn,
    this.publicationYear,
    this.publisher,
  });

  // Método para criar uma instância de Book a partir de um documento do Firestore
  factory Book.fromDocument(DocumentSnapshot doc) {
    return Book(
      id: doc.id,
      title: doc['title'],
      author: doc['author'],
      imageUrl: doc['imageUrl'] ?? '', // Certifique-se de que não seja nulo
      postedBy: doc['postedBy'],
      profileImageUrl: doc['profileImageUrl'],
      rating: (doc['rating'] ?? 0.0).toDouble(),
      publishedDate: (doc['publishedDate'] as Timestamp?)?.toDate(),
      condition: doc['condition'],
      edition: doc['edition'],
      exchangeGenres: List<String>.from(doc['exchangeGenres'] ?? []),
      genres: List<String>.from(doc['genres'] ?? []),
      isbn: doc['isbn'],
      publicationYear: doc['publicationYear'],
      publisher: doc['publisher'],
    );
  }
}
