import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BookCard extends StatelessWidget {
  final String id;
  final String userId;
  final String title;
  final String author;
  final String postedBy;
  final String imageUserUrl;
  final String? profileImageUrl;
  final bool isFavorite;
  final double? customerRating;
  final VoidCallback onFavoritePressed;
  final String addres;

  const BookCard({
    super.key,
    required this.id,
    required this.userId,
    required this.title,
    required this.author,
    required this.postedBy,
    required this.imageUserUrl,
    this.profileImageUrl,
    required this.isFavorite,
    this.customerRating,
    required this.onFavoritePressed,
    required this.addres,
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
      child: SizedBox(
        height: 170, // Altura fixa do card
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center, // Centraliza verticalmente no Row
            children: [
              // Imagem do livro com CachedNetworkImage
              Container(
                height: 130,
                width: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.grey[200],
                ),
                child: CachedNetworkImage(
                  imageUrl: imageUserUrl,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),

              // Informações do livro
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título com no máximo 2 linhas e truncado com "..."
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Autor com no máximo 1 linhas e truncado com "..."
                    Text(
                      author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Postado por:',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Imagem de perfil
                        CircleAvatar(
                          radius: 15,
                          backgroundImage: profileImageUrl != null &&
                              profileImageUrl!.isNotEmpty
                              ? CachedNetworkImageProvider(profileImageUrl!)
                              : null,
                          child: profileImageUrl == null ||
                              profileImageUrl!.isEmpty
                              ? const Icon(Icons.person, color: Colors.grey)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Nome do usuário
                              Text(
                                postedBy,
                                style: const TextStyle(fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              // Estrelas de avaliação alinhadas verticalmente
                              RatingBarIndicator(
                                rating: customerRating ?? 0.0,
                                itemBuilder: (context, index) => const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                itemCount: 5,
                                itemSize: 16.0,
                                direction: Axis.horizontal,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      addres,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                ),

              ),

              // Botão de coração centralizado verticalmente
              Align(
                alignment: Alignment.center,
                child: IconButton(
                  onPressed: onFavoritePressed,
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
