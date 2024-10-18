import 'package:flutter/material.dart';
import '../models/book.dart'; // Importe o modelo Book

class TradeOfferPage extends StatelessWidget {
  final Book book; // Receber o livro como argumento

  const TradeOfferPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD8D5B3), // Cor amarelada na parte superior
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop(); // Seta de navegação para voltar
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
                  _buildBookImage(book.imageUrl), // Imagem do livro
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
              'Autor: ${book.author}\nPublicado em: ${book.publishedDate?.year ?? 'N/A'}', // Exibe as informações do livro
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            // Sinopse do Livro
            const Text(
              'Sinopse',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Aqui você pode adicionar uma sinopse se estiver disponível...',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Informação do Usuário (você pode ajustar para pegar dinamicamente)
            Row(
              children: [
                const CircleAvatar(
                  backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Imagem do perfil do usuário
                  radius: 25,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'José Almeida', // Nome do usuário pode ser dinâmico se disponível
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: List.generate(5, (index) {
                        return const Icon(Icons.star, color: Colors.amber, size: 16);
                      }),
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
                    // Lógica para solicitar troca
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF77C593), // Cor verde do botão "Solicitar"
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Solicitar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/chat');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Cor azul do botão "Chat"
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

  // Função para construir a imagem do livro no carrossel
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
