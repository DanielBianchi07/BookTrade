import 'package:flutter/material.dart';
import 'package:myapp/views/publicated.books.page.dart';
import '../controller/books.controller.dart';
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
  bool showFullDescription = false;
  final ScrollController _scrollController = ScrollController();

  Widget _buildScrollableBookDetails() {
    final details = [
      {
        'icon': Icons.apartment,
        'label': 'Editora',
        'value': widget.book.publisher,
      },
      {
        'icon': Icons.qr_code,
        'label': 'ISBN-10',
        'value': widget.book.isbn ?? 'N/A',
      },
      {
        'icon': Icons.book,
        'label': 'Condição',
        'value': widget.book.condition,
      },
      {
        'icon': Icons.format_list_numbered,
        'label': 'Edição',
        'value': widget.book.edition,
      },
      {
        'icon': Icons.category,
        'label': 'Gênero',
        'value': widget.book.genres?.join(', ') ?? 'N/A',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Informações do Livro',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Container(
          height: 100, // Altura fixa para os itens
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: details.length,
            itemBuilder: (context, index) {
              final detail = details[index];
              return Container(
                width: 110, // Largura fixa para cada item
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(detail['icon'] as IconData, size: 30, color: Colors.black),
                    const SizedBox(height: 8),
                    Text(
                      detail['label'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detail['value'] as String,
                      style: const TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildImageCarousel() {
    return Stack(
      children: [
        SizedBox(
          height: 250,
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
            left: -10,
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
            right: -10,
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
    );
  }

  Widget _buildBookImage(String imageUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.contain,
        ),
      ),
    );
  }


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
            _buildImageCarousel(),
            const SizedBox(height: 20),

            // Título e Autor
            Text(
              widget.book.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
            Text(
              'De: ${widget.book.author}, ${widget.book.publishedDate.year}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.normal,
                color: Colors.grey
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 10),
            Divider(color: Colors.grey.shade400, thickness: 1),
            const SizedBox(height: 10),
            // Informações do Livro com rolagem horizontal
            _buildScrollableBookDetails(),
            const SizedBox(height: 10),
            // Linha de separação
            Divider(color: Colors.grey.shade400, thickness: 1),
            const SizedBox(height: 10),

            // Sinopse
            const Text(
              'Sinopse',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _buildDescription(),
            ),

            const SizedBox(height: 20),

            // Botão de Excluir
            if (widget.book.isAvailable)
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await booksController.confirmDelete(
                      context,
                      widget.book.id,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.red, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Excluir',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription() {
    // Verifica se a descrição é nula ou vazia
    if (widget.book.description == null || widget.book.description!.trim().isEmpty) {
      return const Text(
        'Sinopse não disponível.',
        style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
      );
    }

    final text = showFullDescription
        ? widget.book.description!
        : (widget.book.description!.length > 200
        ? '${widget.book.description!.substring(0, 200)}...'
        : widget.book.description!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: const TextStyle(fontSize: 16),
        ),
        if (widget.book.description!.length > 200)
          GestureDetector(
            onTap: () {
              setState(() {
                showFullDescription = !showFullDescription;
              });
            },
            child: Text(
              showFullDescription ? 'Ver menos' : 'Ver mais...',
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}

