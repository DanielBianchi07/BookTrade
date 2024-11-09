import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/views/publicated.books.page.dart';
import '../controller/login.controller.dart';
import '../services/image.service.dart';

class NewBookPage extends StatefulWidget {
  const NewBookPage({super.key});

  @override
  _NewBookPageState createState() => _NewBookPageState();
}

class _NewBookPageState extends State<NewBookPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _editionController = TextEditingController();
  final TextEditingController _isbnController = TextEditingController();
  final TextEditingController _publicationYearController = TextEditingController();
  final TextEditingController _publisherController = TextEditingController();

  final TextEditingController _genreController = TextEditingController();
  String _condition = 'Novo';
  bool _noIsbn = false;
  List<String> _genres = [];
  final ImageUploadService _imageUploadService = ImageUploadService();
  final List<File> _selectedImages = [];
  File? _apiImage;
  String _description = '';

  final loginController = LoginController();
  // Método para buscar informações do livro pelo ISBN

  @override
  void initState() {
    super.initState();
    loginController.AssignUserData(context);
  }

  Future<void> _fetchBookData(String isbn) async {
    final url = 'https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['totalItems'] > 0) {
          final volumeInfo = data['items'][0]['volumeInfo'];

          setState(() {
            _titleController.text = volumeInfo['title'] ?? '';
            _authorController.text = volumeInfo['authors']?.join(', ') ?? '';
            _publicationYearController.text = volumeInfo['publishedDate']?.split('-')[0] ?? '';
            _publisherController.text = volumeInfo['publisher'] ?? '';
            _genres = List<String>.from(volumeInfo['categories'] ?? []);
            _description = volumeInfo['descripion'] ?? '';

            // Carregar imagem do livro da API
            if (volumeInfo['imageLinks']?['thumbnail'] != null) {
              _apiImage = File.fromUri(Uri.parse(volumeInfo['imageLinks']['thumbnail']));
            }
          });
        } else {
          _showError('Nenhum livro encontrado para o ISBN fornecido.');
        }
      } else {
        _showError('Erro ao buscar os dados do livro.');
      }
    } catch (e) {
      _showError('Erro ao buscar dados: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _addImage() async {
    final selectedImage = await _imageUploadService.pickImage();
    if (selectedImage != null) {
      setState(() {
        _selectedImages.add(selectedImage);
      });
    }
  }

  bool _validateFields() {
    if (_titleController.text.isEmpty) {
      _showError('O campo "Nome do Livro" é obrigatório.');
      return false;
    }
    if (_authorController.text.isEmpty) {
      _showError('O campo "Nome do Autor" é obrigatório.');
      return false;
    }
    if (_editionController.text.isEmpty) {
      _showError('O campo "Edição" é obrigatório.');
      return false;
    }
    if (!_noIsbn && _isbnController.text.isEmpty) {
      _showError('O campo "ISBN" é obrigatório quando "Não possui ISBN" não está marcado.');
      return false;
    }
    if (_publicationYearController.text.isEmpty) {
      _showError('O campo "Ano de publicação" é obrigatório.');
      return false;
    }
    if (_publisherController.text.isEmpty) {
      _showError('O campo "Editora" é obrigatório.');
      return false;
    }
    if (_noIsbn && _genreController.text.isEmpty) {
      _showError('O campo "Gênero" é obrigatório quando "Não possui ISBN" está marcado.');
      return false;
    }
    return true;
  }

  Future<void> _onConfirm() async {
    if (!_validateFields()) {
      return; // Parar se a validação falhar
    }

    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String userId = currentUser.uid;

      // Limite de 5 imagens para cada livro
      if (_selectedImages.length > 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Você pode adicionar no máximo 5 fotos.')),
        );
        return; // Interrompe a execução se o limite for excedido
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        // Cria o documento do livro no Firestore (sem imagens inicialmente)
        DocumentReference bookDoc = await FirebaseFirestore.instance.collection('books').add({
          'title': _titleController.text.trim(),
          'author': _authorController.text.trim(),
          'edition': _editionController.text.trim(),
          'isbn': _noIsbn ? '' : _isbnController.text.trim(),
          'publicationYear': _publicationYearController.text.trim(),
          'publisher': _publisherController.text.trim(),
          'condition': _condition,
          'description': _description,
          'genres': _noIsbn ? [_genreController.text] : _genres,
          'bookImageUserUrls': [''], // Inicialmente uma lista vazia
          'imageApiUrl': '', // Será atualizado se houver uma imagem da API
          'userId': userId,
          'userInfo': {
            'profileImageUrl': userData['profileImageUrl'] ?? '',
            'address': userData['address'] ?? '',
            'customerRating': userData['customerRating'] ?? 0.0,
            'name': userData['name'] ?? '',
            'userId': userId,
          },
        });

        String bookId = bookDoc.id;
        List<String> bookImageUserUrls = [];

        // Faz o upload de cada imagem selecionada e armazena a URL
        for (var image in _selectedImages) {
          String? imageUrl = await _imageUploadService.uploadBookImage(image, userId, bookId);
          if (imageUrl != null) {
            bookImageUserUrls.add(imageUrl);
          }
        }

        await FirebaseFirestore.instance.collection('books').doc(bookId).update({
          'bookImageUserUrls': bookImageUserUrls,
          // 'imageApiUrl': apiImageUrl ?? '',
        });

        // // Se houver uma imagem da API, você pode definir `apiImageUrl`
        // if (_apiImage != null) {
        //   apiImageUrl = await _imageUploadService.uploadBookImage(_apiImage!, userId, bookId);
        // }
        //
        // // Atualiza o documento do livro com as URLs das imagens
        // await FirebaseFirestore.instance.collection('books').doc(bookId).update({
        //   'bookImageUserUrls': bookImageUserUrls,
        //   'imageApiUrl': apiImageUrl ?? '',
        // });

        // Navega para a página de livros publicados
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PublicatedBooksPage(),
          ),
        );
      } else {
        _showError('Erro: Dados do usuário não encontrados.');
      }
    } else {
      _showError('Erro: Nenhum usuário autenticado.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD8D5B3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Cadastro do Livro', style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Adicione fotos do livro:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            /// Carrossel de imagens
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length + 1,
                itemBuilder: (context, index) {
                  if (index == _selectedImages.length) {
                    return GestureDetector(
                      onTap: () {
                        if (_selectedImages.length < 5) {
                          _addImage();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Você pode adicionar no máximo 5 fotos.')),
                          );
                        }
                      },
                      child: Container(
                        height: 200,
                        width: 150,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey[200],
                        ),
                        child: const Center(child: Icon(Icons.add_a_photo, size: 50, color: Colors.black)),
                      ),
                    );
                  } else {
                    return Container(
                      height: 200,
                      width: 150,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[200],
                      ),
                      child: Image.file(
                        _selectedImages[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(Icons.broken_image, color: Colors.red, size: 50),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField('ISBN', _isbnController,
                enabled: !_noIsbn, // Desabilitar ISBN se "Não possui ISBN" for marcado
                onChanged: (value) {
                  if (_validateISBN(value)) {
                    _fetchBookData(value.trim());
                  }
                }),
            Row(
              children: [
                Checkbox(
                  value: _noIsbn,
                  onChanged: (bool? value) {
                    setState(() {
                      _noIsbn = value ?? false;
                      if (_noIsbn) {
                        _isbnController.clear();
                      }
                    });
                  },
                ),
                const Text('Não possui ISBN'),
              ],
            ),
            if (_noIsbn) _buildTextField('Gênero', _genreController),
            const SizedBox(height: 20),
            _buildTextField('Nome do Livro', _titleController),
            _buildTextField('Nome do Autor', _authorController),
            _buildTextField('Edição', _editionController),
            _buildTextField('Ano de publicação', _publicationYearController),
            _buildTextField('Editora', _publisherController),
            const SizedBox(height: 20),

            // Dropdown para Estado de Conservação
            Text(
              'Estado de conservação',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: DropdownButton<String>(
                isExpanded: true,
                value: _condition,
                items: [
                  'Novo',
                  'Poucas marcas de uso',
                  'Manchas e páginas rasgadas',
                  'Páginas faltando ou ilegíveis',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _condition = newValue ?? _condition;
                  });
                },
                underline: const SizedBox(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF77C593),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Text('Confirmar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {void Function(String)? onChanged, bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      ),
    );
  }

  bool _validateISBN(String isbn) => (isbn.length == 10 || isbn.length == 13) && isbn.contains(RegExp(r'^\d+$'));
}
