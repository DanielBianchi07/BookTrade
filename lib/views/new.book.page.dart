import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/utils/books.genres.dart';
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
  String? _selectedGenre;
  String _condition = 'Novo';
  bool _noIsbn = false;
  List<String> _genres = [];
  final ImageUploadService _imageUploadService = ImageUploadService();
  final List<File> _selectedImages = [];
  File? _apiImage;
  String _description = '';
  bool _isProcessing = false;

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
            _description = volumeInfo['description'] ?? '';

            // Carregar imagem do livro da API
            if (volumeInfo['imageLinks']?['thumbnail'] != null) {
              _apiImage = File.fromUri(
                  Uri.parse(volumeInfo['imageLinks']['thumbnail']));
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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _addImage() async {
    final source = await _showImageSourceDialog();
    if (source != null) {
      final selectedImage = await _imageUploadService.pickImage(source);
      if (selectedImage != null) {
        setState(() {
          _selectedImages.add(selectedImage);
        });
      }
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escolha por onde deseja carregar a foto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Câmera'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Galeria'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  bool _validateFields() {
    if (_selectedImages.isEmpty) {
      _showError('Adicione pelo menos uma foto do livro.');
      return false;
    }
    if (_titleController.text.isEmpty) {
      _showError('O campo "Nome do Livro" é obrigatório.');
      return false;
    }
    if (_authorController.text.isEmpty) {
      _showError('O campo "Nome do Autor" é obrigatório.');
      return false;
    }
    if (_selectedGenre == null) {
      _showError('O campo "Gênero" é obrigatório.');
      return false;
    }
    if (_editionController.text.isEmpty) {
      _showError('O campo "Edição" é obrigatório.');
      return false;
    }
    if (!_noIsbn && _isbnController.text.isEmpty) {
      _showError(
          'O campo "ISBN" é obrigatório quando "Não possui ISBN" não está marcado.');
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
    return true;
  }

  Future<void> _onConfirm() async {
    if (_isProcessing) return; // Impede execuções simultâneas
    setState(() {
      _isProcessing = true; // Inicia o bloqueio
    });

    try {
      if (!_validateFields()) {
        return; // Para se a validação falhar
      }

      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String userId = currentUser.uid;

        // Limite de 10 imagens para cada livro
        if (_selectedImages.length > 10) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Você pode adicionar no máximo 10 fotos.'),
            ),
          );
          return; // Interrompe a execução se o limite for excedido
        }

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

          // Cria o documento do livro no Firestore (sem imagens inicialmente)
          DocumentReference bookDoc =
          await FirebaseFirestore.instance.collection('books').add({
            'title': _titleController.text.trim(),
            'author': _authorController.text.trim(),
            'edition': _editionController.text.trim(),
            'isbn': _noIsbn ? '' : _isbnController.text.trim(),
            'publicationYear': _publicationYearController.text.trim(),
            'publisher': _publisherController.text.trim(),
            'condition': _condition,
            'description': _description,
            'genres': _selectedGenre != null ? [_selectedGenre!] : [],
            'bookImageUserUrls': [''], // Inicialmente uma lista vazia
            'publishedDate': FieldValue.serverTimestamp(),
            'imageApiUrl': '', // Será atualizado se houver uma imagem da API
            'isAvailable': true,
            'userId': userId,
            'userInfo': {
              'profileImageUrl': userData['profileImageUrl'] ?? '',
              'address': userData['address'] ?? '',
              'customerRating': userData['customerRating'] ?? 0.0,
              'name': userData['name'] ?? '',
              'userId': userId,
              'favoriteGenres': userData['favoriteGenres'] ?? [''],
            },
          });

          String bookId = bookDoc.id;
          List<String> bookImageUserUrls = [];

          // Faz o upload de cada imagem selecionada e armazena a URL
          for (var image in _selectedImages) {
            String? imageUrl =
            await _imageUploadService.uploadBookImage(image, userId, bookId);
            if (imageUrl != null) {
              bookImageUserUrls.add(imageUrl);
            }
          }

          await FirebaseFirestore.instance
              .collection('books')
              .doc(bookId)
              .update({
            'bookImageUserUrls': bookImageUserUrls,
          });

          // Navega para a página de livros publicados
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => PublicatedBooksPage(),
            ),
                (Route<dynamic> route) => false,
          );
        } else {
          _showError('Erro: Dados do usuário não encontrados.');
        }
      } else {
        _showError('Erro: Nenhum usuário autenticado.');
      }
    } catch (e) {
      _showError('Erro ao processar a solicitação.');
    } finally {
      setState(() {
        _isProcessing = false; // Libera o botão após finalizar
      });
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
        title: const Text('Cadastro do Livro',
            style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Adicione fotos do livro:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            /// Carrossel de imagens
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_selectedImages.length < 10) {
                        _addImage();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Você pode adicionar no máximo 10 fotos.')),
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
                      child: const Center(
                          child: Icon(Icons.add_a_photo,
                              size: 50, color: Colors.black)),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
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
                                errorBuilder: (context, error, stackTrace) =>
                                const Center(
                                  child: Icon(Icons.broken_image,
                                      color: Colors.red, size: 50),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 18,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedImages.removeAt(index);
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            /// ISBN Field
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
            const SizedBox(height: 20),

            /// Other fields
            _buildTextField('Nome do Livro', _titleController),
            _buildTextField('Nome do Autor', _authorController),
            _buildTextField('Edição', _editionController),
            _buildTextField('Ano de publicação', _publicationYearController),
            _buildTextField('Editora', _publisherController),
            const Text('Digite o Gênero:', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 10),
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                return BookGenres.genres.where((genre) {
                  return genre
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase());
                }).toList();
              },
              onSelected: (String selection) {
                setState(() {
                  _selectedGenre = selection; // Atualiza o gênero selecionado
                });
              },
              fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'Gênero',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.grey[200],
                    errorText: _selectedGenre == null && controller.text.isNotEmpty
                        ? 'Gênero inválido. Por favor, escolha da lista.'
                        : null,
                  ),
                  onEditingComplete: onEditingComplete,
                  onChanged: (value) {
                    // Verifica se o gênero digitado é válido
                    if (!BookGenres.genres.contains(value.trim())){
                      setState(() {
                        _selectedGenre = null; // Limpa a seleção se não for válido
                      });
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            // Aqui você pode exibir o gênero selecionado ou usá-lo em outro campo
            if (_selectedGenre != null)
              Text('Gênero selecionado: $_selectedGenre', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),

            /// Book Condition Dropdown
            const Text('Estado de conservação',
                style: TextStyle(fontSize: 14, color: Colors.grey)),
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

            /// Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _onConfirm, // Desativa o botão se em processamento
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF77C593),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    _isProcessing ? 'Processando...' : 'Confirmar', // Mostra estado do processo
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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

  bool _validateISBN(String isbn) =>
      (isbn.length == 10 || isbn.length == 13) &&
          isbn.contains(RegExp(r'^\d+$'));
}