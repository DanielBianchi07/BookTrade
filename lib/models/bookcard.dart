import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class BookCard extends StatelessWidget {
  final String title;
  final String author;
  final String? postedBy; // Agora pode ser nulo
  final String? profileImageUrl; // Agora pode ser nulo
  final String imageUrl;
  final bool isFavorite;
  final double? rating; // Agora pode ser nulo
  final VoidCallback onFavoritePressed;

  const BookCard({
    super.key,
    required this.title,
    required this.author,
    required this.postedBy,
    required this.imageUrl,
    required this.profileImageUrl,
    required this.isFavorite,
    required this.rating,
    required this.onFavoritePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(
          color: Colors.grey.shade400,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // Imagem do livro
            Image.network(
              imageUrl,
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
                  if (postedBy != null && profileImageUrl != null) // Checa se os valores não são nulos
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(profileImageUrl!),
                          radius: 15,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          postedBy!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    )
                  else
                    Text(
                      'Autor desconhecido',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  const SizedBox(height: 4),
                  // Estrelas de avaliação
                  RatingBarIndicator(
                    rating: rating ?? 0.0, // Se rating for nulo, use 0.0
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
                color: Colors.green,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
