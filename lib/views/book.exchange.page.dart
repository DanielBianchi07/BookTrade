import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookExchangePage extends StatefulWidget {
  final Map<String, dynamic> bookDetails;

  const BookExchangePage({super.key, required this.bookDetails});

  @override
  _BookExchangePageState createState() => _BookExchangePageState();
}

class _BookExchangePageState extends State<BookExchangePage> {
  List<String> _selectedGenres = [];
  List<String> _searchResults = [];
  TextEditingController _searchController = TextEditingController();
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    currentUser = FirebaseAuth.instance.currentUser; // Obter o usuário autenticado
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Função chamada sempre que o texto de busca muda
  void _onSearchChanged() {
    if (_searchController.text.isNotEmpty) {
      _fetchGenresFromGoogleBooksAPI(_searchController.text);
    } else {
      setState(() {
        _searchResults.clear();
      });
    }
  }

  // Função para buscar gêneros com base na entrada do usuário
  Future<void> _fetchGenresFromGoogleBooksAPI(String query) async {
    final url = 'https://www.googleapis.com/books/v1/volumes?q=subject:$query';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['items'] != null && data['items'].isNotEmpty) {
          Set<String> genres = {};
          for (var item in data['items']) {
            if (item['volumeInfo']['categories'] != null) {
              genres.addAll(List<String>.from(item['volumeInfo']['categories']));
            }
          }

          setState(() {
            _searchResults = genres.toList();
          });
        } else {
          setState(() {
            _searchResults.clear();
          });
          _showError('Nenhum gênero encontrado para "$query".');
        }
      } else {
        _showError('Erro ao buscar gêneros.');
      }
    } catch (e) {
      _showError('Erro ao buscar dados: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Função para salvar as informações na coleção 'books' e redirecionar para a HomePage
  Future<void> _saveSelectedGenres() async {
    if (currentUser != null) {
      try {
        // Salvar as informações na coleção 'books'
        await FirebaseFirestore.instance.collection('books').add({
          'userId': currentUser!.uid, // Salvar o ID do usuário autenticado
          ...widget.bookDetails,       // Inclui todos os detalhes do livro
          'selectedGenres': _selectedGenres, // Inclui os gêneros selecionados
          'publicationDate': Timestamp.now(), // Data de publicação
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Livro publicado com sucesso!')),
        );

        // Redirecionar para a página inicial
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } catch (e) {
        _showError('Erro ao salvar os gêneros: $e');
      }
    } else {
      _showError('Usuário não autenticado.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bookDetails.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Erro'),
          backgroundColor: const Color(0xFFD8D5B3),
        ),
        body: Center(
          child: const Text('Erro: Detalhes do livro estão ausentes.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escolha gêneros de troca'),
        backgroundColor: const Color(0xFFD8D5B3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Digite o gênero que você gostaria de receber em troca:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar gêneros',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 10),

            // Exibição de gêneros recomendados em um espaço compacto
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _searchResults.map((genre) {
                final isSelected = _selectedGenres.contains(genre);
                return ChoiceChip(
                  label: Text(genre),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected && !isSelected) {
                        _selectedGenres.add(genre);
                      } else {
                        _selectedGenres.remove(genre);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            const Text(
              'Gêneros selecionados:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Exibição de gêneros selecionados com opção de remoção
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _selectedGenres.map((genre) {
                return Chip(
                  label: Text(genre),
                  deleteIcon: Icon(Icons.close),
                  onDeleted: () {
                    setState(() {
                      _selectedGenres.remove(genre);
                    });
                  },
                );
              }).toList(),
            ),

            // Botão de Confirmar
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSelectedGenres, // Função para salvar os gêneros
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF77C593),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Text(
                    'Confirmar',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}