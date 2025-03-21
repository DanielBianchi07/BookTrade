import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controller/books.controller.dart';
import '../controller/login.controller.dart';
import '../models/book.model.dart';

class SelectedBookPage extends StatefulWidget {
  const SelectedBookPage({super.key});

  @override
  _SelectedBookPageState createState() => _SelectedBookPageState();
}

class _SelectedBookPageState extends State<SelectedBookPage> {
  final loginController = LoginController();
  final booksController = BooksController();
  late final String userId;
  List<BookModel> _books = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  // Função para buscar os livros do usuário logado
  Future<void> _fetchBooks() async {
    final userCredential = FirebaseAuth.instance.currentUser;
    if (userCredential != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Carregando livros
        List<BookModel> books = await booksController.loadBooks();

        // Filtra apenas os livros do usuário logado e com isAvailable igual a true
        List<BookModel> userBooks = books.where((book) => book.userId == userCredential.uid && book.isAvailable).toList();

        setState(() {
          _books = userBooks;
        });
      } catch (e) {
        print('Erro ao carregar livros: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      print('Não existe usuário');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFD8D5B3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Livros publicados',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(), // Indicador de carregamento
      )
          : _books.isEmpty
          ? const Center(child: Text('Nenhum livro publicado.'))
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _books.length,
        itemBuilder: (context, index) {
          final book = _books[index];
          return GestureDetector(
            onTap: () {
              // Função de adicionar o livro escolhido para a tela anterior
              // Retorna o livro selecionado
              Navigator.pop(context, book);
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    // Imagem do livro com CachedNetworkImage, similar ao BookCard
                    Container(
                      height: 100,
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.grey[200],
                      ),
                      child: CachedNetworkImage(
                        imageUrl: book.bookImageUserUrls[0] ?? '',
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
                          Text(
                            book.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'De ${book.author}',
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Postado em: ${DateFormat.yMMMd().format(book.publishedDate)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}