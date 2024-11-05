import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_info.dart';


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
      'imageUserUrl': imageUserUrl,
      'imageApiUrl': imageApiUrl,
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

  // Método para criar uma instância de Book a partir de um documento do Firestore
  factory BookModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookModel(
      userId: data['userId'] ?? '',
      id: doc.id,
      title: data['title'] ?? 'Título não disponível',
      author: data['author'] ?? 'Autor desconhecido',
      imageUserUrl: data['imageUserUrl'] ?? '',
      imageApiUrl: data['imageApiUrl'],
      publishedDate: (data['publishedDate'] as Timestamp).toDate(),
      condition: data['condition'] ?? 'Condição não disponível',
      edition: data['edition'] ?? 'Edição não disponível',
      genres: List<String>.from(data['genres'] ?? []),
      isbn: data['isbn'],
      publicationYear: data['publicationYear'] ?? 'Ano de publicação não disponível',
      publisher: data['publisher'] ?? 'Editora não disponível',
      userInfo: UInfo.fromMap(data['userInfo']),
    );
  }
}
