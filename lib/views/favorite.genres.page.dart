import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/views/home.page.dart';
import '../utils/books.genres.dart';

class FavoriteGenresPage extends StatefulWidget {
  const FavoriteGenresPage({Key? key}) : super(key: key);

  @override
  _FavoriteGenresPageState createState() => _FavoriteGenresPageState();
}

class _FavoriteGenresPageState extends State<FavoriteGenresPage> {
  List<String> _selectedGenres = [];
  List<String> _searchResults = [];
  TextEditingController _searchController = TextEditingController();
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    currentUser = FirebaseAuth.instance.currentUser;
    _loadUserGenres(); // Carregar os gêneros favoritos do usuário ao iniciar a página
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Função para carregar os gêneros favoritos do usuário
  Future<void> _loadUserGenres() async {
    if (currentUser != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .get();

        setState(() {
          _selectedGenres = List<String>.from(userDoc['favoriteGenres'] ?? []);
        });
      } catch (e) {
        _showError('Erro ao carregar gêneros favoritos: $e');
      }
    } else {
      _showError('Usuário não autenticado.');
    }
  }

  // Função chamada sempre que o texto de busca muda
  void _onSearchChanged() {
    if (_searchController.text.isNotEmpty) {
      _fetchGenresFromList(_searchController.text);
    } else {
      setState(() {
        _searchResults.clear();
      });
    }
  }

  // Função para buscar gêneros com base na entrada do usuário
  Future<void> _fetchGenresFromList(String query) async {
    // Filtra os gêneros que contêm a string de consulta
    final filteredGenres = BookGenres.genres
        .where((genre) => genre.toLowerCase().contains(query.toLowerCase()))
        .toList();

    // Atualiza o estado com os gêneros encontrados ou exibe uma mensagem de erro
    setState(() {
      if (filteredGenres.isNotEmpty) {
        _searchResults = filteredGenres;
      } else {
        _searchResults.clear();
        _showError('Nenhum gênero encontrado para "$query".');
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Função para salvar os gêneros favoritos do usuário
  Future<void> _saveFavoriteGenres() async {
    if (currentUser != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).update({
          'favoriteGenres': _selectedGenres,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gêneros favoritos salvos com sucesso!')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage(),
          ),
        );
      } catch (e) {
        _showError('Erro ao salvar os gêneros favoritos: $e');
      }
    } else {
      _showError('Usuário não autenticado.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gêneros Favoritos'),
        backgroundColor: const Color(0xFFD8D5B3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Digite para buscar novos gêneros:',
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

            // Conteúdo expansível que ajusta a posição de "Gêneros Selecionados"
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      'Gêneros Selecionados:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    // Exibição de gêneros favoritos com opção de remoção
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
                  ],
                ),
              ),
            ),

            // Botão de salvar fixo na parte inferior
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveFavoriteGenres, // Salva os gêneros favoritos
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF77C593),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Text(
                    'Salvar Gêneros',
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