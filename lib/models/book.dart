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

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.postedBy,
    required this.profileImageUrl,
    required this.rating,
    required this.publishedDate,
  });

  // Método para criar uma instância de Book a partir de um documento do Firestore
  factory Book.fromDocument(DocumentSnapshot doc) {
    return Book(
      id: doc.id,
      title: doc['title'],
      author: doc['author'],
      imageUrl: doc['imageUrl'],
      postedBy: doc['postedBy'],
      profileImageUrl: doc['profileImageUrl'],
      rating: (doc['rating'] ?? 0.0).toDouble(),
      publishedDate: (doc['publishedDate'] as Timestamp?)?.toDate(),
    );
  }
}
