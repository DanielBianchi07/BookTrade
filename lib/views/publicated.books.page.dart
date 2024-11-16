import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../controller/books.controller.dart';
import '../models/book.model.dart';
import 'delete.book.page.dart';
import 'home.page.dart';

class PublicatedBooksPage extends StatefulWidget {
  const PublicatedBooksPage({super.key});

  @override
  _PublicatedBooksPageState createState() => _PublicatedBooksPageState();
}

class _PublicatedBooksPageState extends State<PublicatedBooksPage> {
  final booksController = BooksController();
  bool _isLoading = true;
  List<BookModel> availableBooks = [];
  List<BookModel> transactionBooks = [];
  List<BookModel> exchangedBooks = [];
  bool showExchangedBooks = false;

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    final userCredential = FirebaseAuth.instance.currentUser;

    if (userCredential != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Carrega todos os livros
        List<BookModel> allBooks = await booksController.loadBooks();

        // Filtra livros do usuário logado
        List<BookModel> userBooks = allBooks
            .where((book) => book.userId == userCredential.uid)
            .toList();

        // Ordena os livros pelo campo 'publishedDate' em ordem decrescente (mais recente primeiro)
        userBooks.sort((a, b) => b.publishedDate.compareTo(a.publishedDate));

        List<BookModel> available = [];
        List<BookModel> inTransaction = [];
        List<BookModel> exchanged = [];

        // Processa os livros em paralelo para verificar o status
        await Future.wait(userBooks.map((book) async {
          try {
            String requestStatus =
            await booksController.getBookRequestStatus(book.id);

            if (book.isAvailable) {
              available.add(book);
            } else if (requestStatus != 'concluído' &&
                requestStatus != 'not_found') {
              inTransaction.add(book);
            } else if (requestStatus == 'concluído') {
              exchanged.add(book);
            }
          } catch (e) {
            print('Erro ao verificar status do livro ${book.id}: $e');
          }
        }));

        setState(() {
          availableBooks = available;
          transactionBooks = inTransaction;
          exchangedBooks = exchanged;
        });
      } catch (e) {
        print('Erro ao carregar livros: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar livros: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildSection(
      String title, List<BookModel> books, bool showDelete, bool isAvailable,
      {bool hasSwitch = false, Function(bool)? onSwitchChanged, bool switchValue = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A4A4A),
                ),
              ),
              if (hasSwitch) // Exibe o switch apenas se necessário
                Row(
                  children: [
                    const Text(
                      'Ver Trocados',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    Transform.scale(
                      scale: 0.7, // Ajuste de escala (0.8 = 80% do tamanho original)
                      child: Switch(
                        value: switchValue,
                        onChanged: onSwitchChanged,
                        activeColor: Colors.grey,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 16.0),
          decoration: BoxDecoration(
            color: Colors.brown.shade200,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(13.0),
            ),
            border: Border(
              top: BorderSide(
                color: Colors.brown.shade700,
                width: 8.0,
              ),
              left: BorderSide(
                color: Colors.brown.shade700,
                width: 5.0,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.brown.shade700.withOpacity(0.8),
                offset: const Offset(-8, 0),
                blurRadius: 6.0,
                spreadRadius: 2.0,
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                height: 7,
                color: Colors.brown.shade700,
              ),
              Container(
                constraints: const BoxConstraints(
                  minHeight: 150,
                  maxHeight: 300,
                ),
                child: Scrollbar(
                  thumbVisibility: true,
                  thickness: 6,
                  radius: const Radius.circular(10),
                  child: SingleChildScrollView(
                    child: Column(
                      children: books.isEmpty
                          ? [
                        Center(
                          child: Text(
                            title == 'Livros Publicados'
                                ? 'Você não possui nenhum livro publicado'
                                : title == 'Livros em Transação'
                                ? 'Você não possui nenhum pedido ativo'
                                : 'Você ainda não concluiu nenhuma troca.',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ]
                          : books.map((book) {
                        return Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DeleteBookPage(book: book),
                                    ),
                                  );
                                },
                                child: Card(
                                  color: isAvailable
                                      ? Colors.white
                                      : Colors.grey.shade300,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(10.0),
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 4.0, horizontal: 8.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 100,
                                          width: 80,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(8.0),
                                            color: Colors.grey[200],
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl:
                                            book.bookImageUserUrls[0],
                                            placeholder: (context, url) =>
                                            const Center(
                                              child:
                                              CircularProgressIndicator(),
                                            ),
                                            errorWidget: (context, url,
                                                error) =>
                                            const Icon(
                                                Icons
                                                    .image_not_supported,
                                                size: 50,
                                                color: Colors.grey),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                book.title,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                'De ${book.author}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Postado em: ${DateFormat.yMMMd().format(book.publishedDate)}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              if (!isAvailable)
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.only(
                                                      top: 4.0),
                                                  child: Row(
                                                    children: [
                                                      const Icon(Icons.info,
                                                          color: Colors.red,
                                                          size: 16),
                                                      const SizedBox(
                                                          width: 4),
                                                      const Text(
                                                        'Indisponível',
                                                        style: TextStyle(
                                                            color:
                                                            Colors.red,
                                                            fontSize: 12),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        if (showDelete)
                                          IconButton(
                                            onPressed: () async{
                                             await booksController
                                                  .confirmDelete(
                                                  context, book.id);
                                              _fetchBooks();
                                            },
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (books.last != book)
                              Divider(
                                color: Colors.brown.shade600,
                                thickness: 3.0,
                                height: 20.0,
                              ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              Container(
                height: 7,
                color: Colors.brown.shade700,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD8D5B3),
        title: const Text(
          'Minha Biblioteca',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () async{
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
                  (Route<dynamic> route) => false, // Remove todas as rotas anteriores
            );
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildSection(
                'Livros Publicados',
                availableBooks,
                true,
                true,
                hasSwitch: true,
                onSwitchChanged: (value) {
                  setState(() {
                    showExchangedBooks = value;
                  });
                },
                switchValue: showExchangedBooks,
              ),
              const SizedBox(height: 16),
              _buildSection(
                'Livros em Transação',
                transactionBooks,
                false,
                false,
              ),
              if (showExchangedBooks)
                const SizedBox(height: 16),
              if (showExchangedBooks)
                _buildSection(
                  'Livros Trocados',
                  exchangedBooks,
                  false,
                  false,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
