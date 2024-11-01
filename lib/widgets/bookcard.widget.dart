import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class BookCard extends StatelessWidget {
  final String bookId; // Identificador único do livro
  final String title;
  final String author;
  final String? postedBy;
  final String? profileImageUrl;
  final String imageUrl;
  final bool isFavorite;
  final double? rating;
  final VoidCallback onFavoritePressed;

  const BookCard({
    super.key,
    required this.bookId, // Identificador único do livro
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
            // Exibe a imagem do livro
            Image.network(
              imageUrl,
              height: 100,
              width: 80,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Exibe o título do livro
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Exibe o autor do livro
                  Text(
                    author,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Postado por:',
                    style: TextStyle(fontSize: 12),
                  ),
                  // Exibe o nome e a foto do perfil da pessoa que postou, se disponível
                  if (postedBy != null && profileImageUrl != null)
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
                    // Caso o perfil esteja vazio, mostra um texto padrão
                    Text(
                      'Autor desconhecido',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  const SizedBox(height: 4),
                  // Exibe a avaliação do livro em estrelas
                  RatingBarIndicator(
                    rating: rating ?? 0.0,
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
            // Botão de favorito (ícone de coração)
            IconButton(
              onPressed: onFavoritePressed, // Função chamada ao pressionar o botão
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border, // Ícone muda com base no status
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
