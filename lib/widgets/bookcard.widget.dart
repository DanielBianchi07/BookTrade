import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class BookCard extends StatelessWidget {
  final String id;
  final String userId; // Identificador único do livro
  final String title;
  final String author;
  final String postedBy;
  final String? imageUserUrl;
  final String? profileImageUrl;
  final bool isFavorite;
  final double? customerRating;
  final VoidCallback onFavoritePressed;

  const BookCard({super.key,
    required this.id,
    required this.userId,
    required this.title,
    required this.author,
    required this.postedBy,
    this.imageUserUrl,
    this.profileImageUrl,
    required this.isFavorite,
    this.customerRating,
    required this.onFavoritePressed,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(
          color: Colors.grey.shade400, // Adiciona a borda à caixa do livro
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Imagem do livro
                Image.network(
                  imageUserUrl ?? '',
                  height: 100,
                  width: 80,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 16),

                // Informações do livro
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        author,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Postado por:',
                        style: TextStyle(fontSize: 12),
                      ),
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(profileImageUrl ?? ''),
                            radius: 15,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            postedBy,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Estrelas de avaliação
                      RatingBarIndicator(
                        rating: customerRating ?? 0.0,
                        itemBuilder: (context, index) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 18.0,
                        direction: Axis.horizontal,
                      ),
                    ],
                  ),
                ),

                // Botão de coração
                IconButton(
                  onPressed: onFavoritePressed,
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.green, // Ícone de coração na cor verde
                    size: 24,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}