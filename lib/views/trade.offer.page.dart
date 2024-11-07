// lib/pages/trade_offer_page.dart
import 'package:flutter/material.dart';
import '../models/book.model.dart';


class TradeOfferPage extends StatelessWidget {
  final BookModel book;

  const TradeOfferPage({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD8D5B3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carrossel de Imagens
            SizedBox(
              height: 200,
              child: PageView(
                children: [
                  _buildBookImage(book.imageUserUrl),
                  if (book.imageApiUrl != null && book.imageApiUrl!.isNotEmpty)
                    _buildBookImage(book.imageApiUrl!),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Informações do Livro
            Text(
              book.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Autor: ${book.author}\nPublicado em: ${book.publicationYear}',
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 5),
            Text('Condição: ${book.condition}', style: const TextStyle(fontSize: 14)),
            Text('Edição: ${book.edition}', style: const TextStyle(fontSize: 14)),
            Text('Gêneros: ${book.genres?.join(', ') ?? 'N/A'}', style: const TextStyle(fontSize: 14)),
            Text('ISBN: ${book.isbn ?? 'N/A'}', style: const TextStyle(fontSize: 14)),
            Text('Editora: ${book.publisher}', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 20),

            // Sinopse do Livro
            const Text(
              'Sinopse',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(book.description ?? 'Sinopse não disponível', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),

            // Informação do Usuário e Avaliação com Estrelas
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(book.userInfo.profileImageUrl),
                  radius: 25,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.userInfo.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...List.generate(book.userInfo.customerRating.floor(), (index) {
                          return const Icon(Icons.star, color: Colors.amber, size: 18);
                        }),
                        if (book.userInfo.customerRating - book.userInfo.customerRating.floor() >= 0.5)
                          const Icon(Icons.star_half, color: Colors.amber, size: 18),
                        ...List.generate((5 - book.userInfo.customerRating.ceil()) as int, (index) {
                          return const Icon(Icons.star_border, color: Colors.amber, size: 18);
                        }),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Botões de Solicitar e Chat
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/selectedBook');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF77C593),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Solicitar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/chat',
                      arguments: {'recipientUserId': book.userInfo.id},
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Chat'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookImage(String imageUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
      ),
    );
  }
}
