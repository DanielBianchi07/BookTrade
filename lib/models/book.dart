class Book {
  final String id;
  final String title;
  final String author;
  final String imageUrl; // URL da imagem
  final DateTime? publishedDate; // Data de publicação

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.publishedDate,
  });
}
