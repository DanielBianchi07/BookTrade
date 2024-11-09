import 'package:flutter/material.dart';
import 'package:myapp/controller/books.controller.dart';
import '../models/book.model.dart';

class DeleteBookPage extends StatefulWidget {
  final BookModel book; // Receber o livro como argumento

  const DeleteBookPage({super.key, required this.book});

  @override
  _DeleteBookPageState createState() => _DeleteBookPageState();
}

class _DeleteBookPageState extends State<DeleteBookPage> {
  final BooksController booksController = BooksController();
  int _currentPage = 0; // Página atual no carrossel
  final PageController _pageController = PageController();

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
            // Carrossel de Imagens com Setas
            Stack(
              children: [
                SizedBox(
                  height: 300,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.book.bookImageUserUrls.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return _buildBookImage(widget.book.bookImageUserUrls[index]);
                    },
                  ),
                ),
                // Seta para a esquerda
                if (_currentPage > 0)
                  Positioned(
                    left: 10,
                    top: 125,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                // Seta para a direita
                if (_currentPage < widget.book.bookImageUserUrls.length - 1)
                  Positioned(
                    right: 10,
                    top: 125,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Informações do Livro
            Text(
              widget.book.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Autor: ${widget.book.author}\nPublicado em: ${widget.book.publishedDate.year}',
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 0),
            Text(
              'Condição: ${widget.book.condition}\nEdição: ${widget.book.edition}\nGêneros: ${widget.book.genres?.join(', ') ?? 'N/A'}\nISBN: ${widget.book.isbn ?? 'N/A'}\nAno de publicação: ${widget.book.publicationYear}\nEditora: ${widget.book.publisher}',
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

            // Botões de Solicitar e Chat
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    booksController.confirmDelete(context, widget.book.id); // Chama a função de confirmação
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFDD585B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Excluir'),
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
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.contain, // Ajuste para caber a imagem inteira
        ),
      ),
    );
  }
}
