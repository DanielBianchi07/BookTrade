import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/user.info.model.dart';

class BookModel {
  final String userId;
  final String id;
  final String title;
  final String author;
  final List<String> bookImageUserUrls;
  final String? imageApiUrl;
  final DateTime publishedDate;
  final String condition;
  final String edition;
  final List<String>? genres;
  final String? isbn;
  final String publicationYear;
  final String publisher;
  final String? description; // Novo campo para a sinopse
  final UInfo userInfo;

  BookModel({
    required this.userId,
    required this.id,
    required this.title,
    required this.author,
    required this.bookImageUserUrls,
    this.imageApiUrl,
    required this.publishedDate,
    required this.condition,
    required this.edition,
    this.genres,
    this.isbn,
    required this.publicationYear,
    required this.publisher,
    this.description, // Inicialização do novo campo
    required this.userInfo,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'id': id,
      'title': title,
      'author': author,
      'bookImageUserUrls': bookImageUserUrls,
      'imageApiUrl': imageApiUrl,
      'publishedDate': publishedDate.toIso8601String(),
      'condition': condition,
      'edition': edition,
      'genres': genres,
      'isbn': isbn,
      'publicationYear': publicationYear,
      'publisher': publisher,
      'description': description, // Mapeamento da sinopse
      'userInfo': userInfo.toMap(),
    };
  }

  // Método para criar uma instância de Book a partir de um documento do Firestore
  factory BookModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Garante que `bookImageUserUrls` seja sempre uma lista de strings
    var bookImageUserUrls = data['bookImageUserUrls'];
    if (bookImageUserUrls is String) {
      bookImageUserUrls = [bookImageUserUrls];
    } else if (bookImageUserUrls is List) {
      bookImageUserUrls = bookImageUserUrls.map((item) => item.toString()).toList();
    } else {
      bookImageUserUrls = ['https://via.placeholder.com/100']; // Placeholder se estiver ausente ou nulo
    }

    return BookModel(
      userId: data['userId'] ?? '',
      id: doc.id,
      title: data['title'] ?? 'Título não disponível',
      author: data['author'] ?? 'Autor desconhecido',
      bookImageUserUrls: bookImageUserUrls,
      imageApiUrl: data['imageApiUrl'],
      publishedDate: (data['publishedDate'] as Timestamp).toDate(),
      condition: data['condition'] ?? 'Condição não disponível',
      edition: data['edition'] ?? 'Edição não disponível',
      genres: List<String>.from(data['genres'] ?? []),
      isbn: data['isbn'],
      publicationYear: data['publicationYear'] ?? 'Ano de publicação não disponível',
      publisher: data['publisher'] ?? 'Editora não disponível',
      description: data['description'], // Carrega a sinopse
      userInfo: UInfo.fromMap(data['userInfo']),
    );
  }

  // Método para criar uma instância de BookModel a partir de um Map
  factory BookModel.fromMap(Map<String, dynamic> data) {
    // Garante que `bookImageUserUrls` seja sempre uma lista de strings
    var bookImageUserUrls = data['bookImageUserUrls'];
    if (bookImageUserUrls is String) {
      bookImageUserUrls = [bookImageUserUrls];
    } else if (bookImageUserUrls is List) {
      bookImageUserUrls = bookImageUserUrls.map((item) => item.toString()).toList();
    } else {
      bookImageUserUrls = ['https://via.placeholder.com/100']; // Placeholder se estiver ausente ou nulo
    }

    return BookModel(
      userId: data['userId'] ?? '',
      id: data['id'] ?? '',
      title: data['title'] ?? 'Título não disponível',
      author: data['author'] ?? 'Autor desconhecido',
      bookImageUserUrls: bookImageUserUrls,
      imageApiUrl: data['imageApiUrl'],
      publishedDate: (data['publishedDate'] as Timestamp).toDate(),
      condition: data['condition'] ?? 'Condição não disponível',
      edition: data['edition'] ?? 'Edição não disponível',
      genres: List<String>.from(data['genres'] ?? []),
      isbn: data['isbn'],
      publicationYear: data['publicationYear'] ?? 'Ano de publicação não disponível',
      publisher: data['publisher'] ?? 'Editora não disponível',
      description: data['description'], // Carrega a sinopse
      userInfo: UInfo.fromMap(data['userInfo']),
    );
  }
}