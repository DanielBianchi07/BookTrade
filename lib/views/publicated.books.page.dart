import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';

class PublicatedBooksPage extends StatefulWidget {
  const PublicatedBooksPage({super.key});

  @override
  _PublicatedBooksPageState createState() => _PublicatedBooksPageState();
}

class _PublicatedBooksPageState extends State<PublicatedBooksPage> {
  final List<Book> _books = [];

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('books').get();
    final List<Book> books = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Book(
        id: doc.id,
        title: data['title'] ?? '',
        author: data['author'] ?? '',
        imageUrl: data['imageUrl'] ?? 'https://via.placeholder.com/100',
        publishedDate: DateTime.now(), 
        postedBy: null, 
        profileImageUrl: null, 
        rating: null, // Substitua por uma data real se disponível
      );
    }).toList();

    setState(() {
      _books.clear();
      _books.addAll(books);
    });
  }

  Future<void> _deleteBook(String bookId) async {
    await FirebaseFirestore.instance.collection('books').doc(bookId).delete();
    _fetchBooks(); // Atualiza a lista após a remoção
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
      body: _books.isEmpty
          ? Center(child: Text('Nenhum livro publicado.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _books.length,
              itemBuilder: (context, index) {
                final book = _books[index];
                return Card(
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
                                'Postado em: ${book.publishedDate?.toLocal().toString().split(' ')[0]}',
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
                            _deleteBook(book.id); // Chama a função de exclusão
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}