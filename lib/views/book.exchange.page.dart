import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookExchangePage extends StatefulWidget {
  final Map<String, dynamic> bookDetails;

  const BookExchangePage({super.key, required this.bookDetails});

  @override
  _BookExchangePageState createState() => _BookExchangePageState();
}

class _BookExchangePageState extends State<BookExchangePage> {
  final List<String> _selectedGenres = [];
  List<String> _allGenres = [];
  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser; // Obter usuário autenticado
    _fetchGenresFromGoogleBooksAPI();
  }

  // Função para buscar todos os gêneros possíveis da API do Google Books
  Future<void> _fetchGenresFromGoogleBooksAPI() async {
    final url = 'https://www.googleapis.com/books/v1/volumes?q=subject:fiction'; // Puxa livros de ficção, troque para outro termo se desejar

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Pega todos os gêneros listados em cada livro obtido
        Set<String> genres = {};
        for (var item in data['items']) {
          if (item['volumeInfo']['categories'] != null) {
            genres.addAll(List<String>.from(item['volumeInfo']['categories']));
          }
        }

        setState(() {
          _allGenres = genres.toList();
        });
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

  Future<void> _saveBookWithGenres() async {
    try {
      // Salvando os detalhes do livro com os gêneros escolhidos no Firestore
      if (currentUser != null) {
        await FirebaseFirestore.instance.collection('books').add({
          'userId': currentUser!.uid, // Salvar o ID do usuário autenticado
          ...widget.bookDetails,
          'exchangeGenres': _selectedGenres,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Livro registrado com sucesso!')),
        );

        // Navegar para a página inicial
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        _showError('Usuário não autenticado.');
      }
    } catch (e) {
      _showError('Erro ao salvar o livro: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Escolha gêneros de troca'),
        backgroundColor: const Color(0xFFD8D5B3),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Selecione os gêneros que você gostaria de receber em troca:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Campo de escolha de gêneros usando ChoiceChip para selecionar vários gêneros
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 10.0,
                runSpacing: 5.0,
                children: _allGenres.map((genre) {
                  return ChoiceChip(
                    label: Text(genre),
                    selected: _selectedGenres.contains(genre),
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
          ),

          // Botão de Confirmar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveBookWithGenres,
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
          ),
        ],
      ),
    );
  }
}