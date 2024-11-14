import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controller/books.controller.dart';
import '../controller/login.controller.dart';
import '../models/book.model.dart';
import '../services/chats.service.dart';
import '../user.dart';
import 'selected.book.page.dart';

class RequestPage extends StatefulWidget {
  final BookModel book;

  const RequestPage({super.key, required this.book});

  @override
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  final loginController = LoginController();
  final booksController = BooksController();
  final ChatsService chatsService = ChatsService();
  late final String userId;
  final List<BookModel> _books = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Enviar Pedido'),
        backgroundColor: const Color(0xFFD8D5B3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Livro Desejado', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildDesiredBookCard(widget.book),
            const SizedBox(height: 20),

            const Text('Seus Livros', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final selectedBook = await Navigator.push<BookModel>(
                  context,
                  MaterialPageRoute(builder: (context) => SelectedBookPage()),
                );

                if (selectedBook != null) {
                  bool bookExists = _books.any((existingBook) => existingBook.id == selectedBook.id);
                  if (bookExists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Este livro já foi adicionado!')),
                    );
                  } else {
                    setState(() {
                      _books.add(selectedBook);
                    });
                  }
                }
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_circle, color: Color.fromARGB(255, 82, 82, 82)),
                  SizedBox(width: 8),
                  Text(
                    'Adicionar Livro',
                    style: TextStyle(color: Color.fromARGB(255, 82, 82, 82)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            SizedBox(
              height: 240,
              child: ListView.builder(
                itemCount: _books.length,
                itemBuilder: (context, index) {
                  final book = _books[index];
                  return _buildUserBookCard(book);
                },
              ),
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDD585B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_books.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Adicione pelo menos um livro para troca.')),
                      );
                      return;
                    }
                    final userCredential = FirebaseAuth.instance.currentUser;
                    if (userCredential == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Usuário não autenticado.')),
                      );
                      return;
                    }

                    final requestData = {
                      'requestedBook': {
                        'id': widget.book.id,
                        'title': widget.book.title,
                        'author': widget.book.author,
                        'imageUrl': widget.book.bookImageUserUrls[0],
                      },
                      'offeredBooks': _books.map((book) => {
                        'id': book.id,
                        'title': book.title,
                        'author': book.author,
                        'imageUrl': book.bookImageUserUrls[0],
                      }).toList(),
                      'requesterId': userCredential.uid,
                      'ownerId': widget.book.userId,
                      'status': 'pending',
                      'createdAt': Timestamp.now(),
                    };

                    try {
                      // Salva a solicitação no Firestore
                      await FirebaseFirestore.instance.collection('requests').add(requestData);

                      // Atualiza o campo isAvailable para false para cada livro oferecido
                      for (var book in _books) {
                        await FirebaseFirestore.instance
                            .collection('books')
                            .doc(book.id)
                            .update({'isAvailable': false});
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Solicitação enviada com sucesso!')),
                      );

                      Navigator.of(context).pop();

                      chatsService.newChat(
                        senderId: user.value.uid,
                        receiverId: widget.book.userInfo.id,
                        timestamp: FieldValue.serverTimestamp(),
                      );
                    } catch (e) {
                      print('Erro ao enviar a solicitação: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro ao enviar a solicitação. Tente novamente.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF77C593),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text('Enviar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesiredBookCard(BookModel book) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              height: 100,
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.grey[200],
              ),
              child: CachedNetworkImage(
                imageUrl: book.bookImageUserUrls[0],
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('De ${book.author}', style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('Publicado em: ${book.publishedDate.year}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('Estado: ${book.condition}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserBookCard(BookModel book) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              height: 100,
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.grey[200],
              ),
              child: CachedNetworkImage(
                imageUrl: book.bookImageUserUrls[0],
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('De ${book.author}', style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(
                    'Postado em: ${DateFormat.yMMMd().format(book.publishedDate)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                _removeBook(book);
              },
              icon: const Icon(Icons.remove_circle, color: Color.fromARGB(255, 82, 82, 82)),
            ),
          ],
        ),
      ),
    );
  }

  void _removeBook(BookModel book) {
    setState(() {
      _books.remove(book);
    });
  }
}
