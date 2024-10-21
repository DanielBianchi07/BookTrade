import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BookExchangePage extends StatefulWidget {
  final Map<String, dynamic> bookDetails;

  const BookExchangePage({Key? key, required this.bookDetails}) : super(key: key);

  @override
  _BookExchangePageState createState() => _BookExchangePageState();
}

class _BookExchangePageState extends State<BookExchangePage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _selectedGenres = [];
  List<String> _allGenres = [];
  List<String> _bookResults = [];
  List<String> _selectedBooks = []; // Para armazenar múltiplos livros selecionados

  @override
  void initState() {
    super.initState();
    _fetchGenres();
  }

  // Fetch all genres from Firestore
  Future<void> _fetchGenres() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('books').get();
    Set<String> genres = {};

    for (var doc in snapshot.docs) {
      List<dynamic> docGenres = doc['genres'] ?? [];
      genres.addAll(docGenres.map((e) => e.toString()));
    }

    setState(() {
      _allGenres = genres.toList();
    });
  }

  // Fetch books from API based on search query
  Future<void> _searchBooks(String query) async {
    final url = 'https://www.googleapis.com/books/v1/volumes?q=$query';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _bookResults = List<String>.from(
              data['items'].map((item) => item['volumeInfo']['title']));
        });
      }
    } catch (e) {
      print('Erro ao buscar livros: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escolha livros para troca')),
      body: Column(
        children: [
          // Campo de busca por nome do livro
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Digite o nome do livro',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _searchBooks(value);
                } else {
                  setState(() {
                    _bookResults = [];
                  });
                }
              },
            ),
          ),
          if (_bookResults.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _bookResults.length,
                itemBuilder: (context, index) {
                  final bookTitle = _bookResults[index];
                  final isSelected = _selectedBooks.contains(bookTitle);

                  return ListTile(
                    title: Text(bookTitle),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.check_circle_outline),
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedBooks.remove(bookTitle);
                        } else {
                          _selectedBooks.add(bookTitle);
                        }
                      });
                    },
                  );
                },
              ),
            ),

          const SizedBox(height: 10),

          // Campo de escolha de gêneros
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8.0,
              children: _allGenres.map((genre) {
                final isSelected = _selectedGenres.contains(genre);
                return FilterChip(
                  label: Text(genre),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedGenres.add(genre);
                      } else {
                        _selectedGenres.remove(genre);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          // Botão de Confirmar
          ElevatedButton(
            onPressed: () async {
              if (_selectedBooks.isEmpty && _selectedGenres.isEmpty) {
                // Exibir uma mensagem de erro se não houver livros ou gêneros selecionados
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Selecione ao menos um livro ou gênero.')),
                );
                return;
              }

              // Salvando o livro junto com os gêneros e livros escolhidos
              await FirebaseFirestore.instance.collection('books').add({
                ...widget.bookDetails,
                'exchangeGenres': _selectedGenres,
                'selectedBooks': _selectedBooks,
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Livro registrado com sucesso!')),
              );
              Navigator.pop(context);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}
