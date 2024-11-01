import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/book.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'delete.book.page.dart';

class PublicatedBooksPage extends StatefulWidget {
  const PublicatedBooksPage({super.key});

  @override
  _PublicatedBooksPageState createState() => _PublicatedBooksPageState();
}

class _PublicatedBooksPageState extends State<PublicatedBooksPage> {
  final List<Book> _books = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  // Função para buscar os livros do usuário logado
  Future<void> _fetchBooks() async {
    setState(() {
      _isLoading = true;
    });

    // Obtém o usuário logado
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showError('Usuário não está logado');
      return;
    }

    // Obtenha apenas os livros do usuário atual
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('books')
        .where('userId', isEqualTo: user.uid)
        .get();

    final List<Book> books = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;

      // Pegando a data de publicação do Firestore (se disponível)
      final Timestamp timestamp = data['timestamp'] ?? Timestamp.now();
      final DateTime publishedDate = timestamp.toDate();

      return Book(
        uid: user.uid,
        id: doc.id,
        title: data['title'] ?? '',
        author: data['author'] ?? '',
        imageUrl: data['imageUrl'] ?? 'https://via.placeholder.com/100',
        publishedDate: publishedDate,
        postedBy: null, // Se necessário, adicione mais campos relacionados ao usuário
        profileImageUrl: null,
        rating: null,
      );
    }).toList();

    setState(() {
      _books.clear();
      _books.addAll(books);
      _isLoading = false;
    });
  }

  // Função para mostrar um erro
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    setState(() {
      _isLoading = false;
    });
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
          'Livros publicados',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator()) // Indicador de carregamento
          : _books.isEmpty
              ? const Center(child: Text('Nenhum livro publicado.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _books.length,
                  itemBuilder: (context, index) {
                    final book = _books[index];
                    return GestureDetector(
                      onTap: () {
                        // Navega para a DeleteBookPage e passa o livro como argumento
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DeleteBookPage(book: book),
                          ),
                        );
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
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  book.imageUrl,
                                  height: 100,
                                  width: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 16),
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
                                      'Postado em: ${book.publishedDate != null ? DateFormat.yMMMd().format(book.publishedDate!) : 'Data não disponível'}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  _confirmDelete(context, book.id); // Confirmação antes de excluir
                                },
                                icon: const Icon(Icons.delete, color: Colors.red),
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
