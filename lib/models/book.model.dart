import 'package:cloud_firestore/cloud_firestore.dart';
import 'user.info.model.dart';

class BookModel {
  final String userId; // Id de quem postou o livro
  final String id; // Id do livro
  final String title; // Titulo do livro
  final String author; // Autor do livro
  final String imageUserUrl; // URL da imagem do livro colocado pelo Usuário
  final String? imageApiUrl; // URL da Imagem do Livro da API
  final DateTime publishedDate; // Data de publicação do livro no app
  final String condition; // Condição do livro
  final String edition; // Edição do livro
  final List<String>? genres; // Gêneros do livro
  final String? isbn; // ISBN do livro
  final String publicationYear; // Ano de publicação
  final String publisher; // Editora do livro
  final UInfo userInfo; // Informações do Usuário que postou o livro

  BookModel({
    required this.userId,
    required this.id,
    required this.title,
    required this.author,
    required this.imageUserUrl,
    this.imageApiUrl,
    required this.publishedDate,
    required this.condition,
    required this.edition,
    this.genres,
    this.isbn,
    required this.publicationYear,
    required this.publisher,
    required this.userInfo,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'id': id,
      'title': title,
      'author': author,
      'imageUrl': imageUserUrl,
      'imageApi': imageApiUrl,
      'publishedDate': publishedDate.toIso8601String(),
      'condition': condition,
      'edition': edition,
      'genres': genres,
      'isbn': isbn,
      'publicationYear': publicationYear,
      'publisher': publisher,
      'userInfo': userInfo.toMap(),
    };
  }

  factory BookModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookModel(
      userId: data['userId'],
      id: doc.id,
      title: data['title'],
      author: data['author'],
      imageUserUrl: data['imageUrl'],
      imageApiUrl: data['imageApi'] ?? '',
      publishedDate: (data['publishedDate'] as Timestamp).toDate(),
      condition: data['condition'],
      edition: data['edition'],
      genres: List<String>.from(data['genres'] ?? []),
      isbn: data['isbn'] ?? '',
      publicationYear: data['publicationYear'],
      publisher: data['publisher'],
      userInfo: UInfo.fromMap(data['userInfo']),
    );
  }
}