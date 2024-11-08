import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../controller/books.controller.dart';
import '../controller/login.controller.dart';
import '../models/book.model.dart';
import '../user.dart';

class SelectedBookPage extends StatefulWidget {
  const SelectedBookPage({super.key});

  @override
  _SelectedBookPageState createState() => _SelectedBookPageState();
}

class _SelectedBookPageState extends State<SelectedBookPage> {
  List<BookModel> _books = [];
  final BooksController booksController = BooksController();
  bool _isLoading = true;
  final loginController = LoginController();

  @override
  void initState() {
    loginController.AssignUserData(context);
    super.initState();
    // Remover a chamada de _fetchBooks() daqui
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Mover a chamada de _fetchBooks() para cá
    _fetchBooks();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    setState(() {
      _isLoading = false;
    });
  }

  // Função para buscar os livros do usuário logado
  Future<void> _fetchBooks() async {
    setState(() {
      _isLoading = true;
    });

    // Obtém o usuario logado
    final userId = user.value.uid;

    if (userId.isEmpty) {
      _showError('Usuário não está logado');
      return;
    }

    try {
      // Chama a função do controller para carregar os livros
      List<BookModel> books = await booksController.loadBooks();

      // Filtra os livros para obter apenas os do usuário atual
      List<BookModel> userBooks = books.where((book) => book.userId == userId).toList();

      setState(() {
        _books = userBooks;
        _isLoading = false;
      });
    } catch (e) {
      _showError('Erro ao carregar livros: $e');
    }
  }

  // Função para excluir um livro
  Future<void> _deleteBook(String bookId) async {
    await FirebaseFirestore.instance.collection('books').doc(bookId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Livro removido com sucesso!')),
    );
    _fetchBooks(); // Atualiza a lista após a remoção
  }

  // Função para confirmar a exclusão do livro
  Future<void> _confirmDelete(BuildContext context, String bookId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // O usuário deve tocar em um botão
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Você tem certeza que deseja excluir este livro?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Excluir'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteBook(bookId); // Chama a função de exclusão
              },
            ),
          ],
        );
      },
    );
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
          'Escolha o livro que deseja ser trocado.',
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
              //Função de solicitar livro
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