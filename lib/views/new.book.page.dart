import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'book.exchange.page.dart';
import 'package:image/image.dart' as img;

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
  File? _selectedImage;
  File? _apiImage;

  // Método para buscar informações do livro pelo ISBN
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

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
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

  Future<File> _resizeImage(File imageFile, int width, int height) async {
    final imageBytes = await imageFile.readAsBytes();
    final decodedImage = img.decodeImage(imageBytes);

    if (decodedImage == null) {
      throw Exception("Erro ao decodificar a imagem");
    }

    final resizedImage = img.copyResize(decodedImage, width: width, height: height);
    final resizedBytes = img.encodeJpg(resizedImage);

    // Salva a imagem redimensionada em um novo arquivo temporário
    final resizedFile = File(imageFile.path)..writeAsBytesSync(resizedBytes);
    return resizedFile;
  }

  Future<String?> _uploadImage(File imageFile, String path) async {
    try {
      // Redimensiona a imagem para 300x400 pixels antes do upload
      final resizedImage = await _resizeImage(imageFile, 80, 100);

      final storageRef = FirebaseStorage.instance.ref().child(path);
      final uploadTask = await storageRef.putFile(resizedImage);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      _showError('Erro ao fazer upload da imagem: $e');
      return null;
    }
  }

  Future<void> _onConfirm() async {
    if (!_validateFields()) {
      return; // Parar se a validação falhar
    }

    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String userId = currentUser.uid;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        String? userImageUrl;
        String? apiImageUrl;

        // Upload da imagem do usuário, se selecionada
        if (_selectedImage != null) {
          userImageUrl = await _uploadImage(_selectedImage!, 'userImages/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');
        }

        // Upload da imagem da API, se disponível
        if (_apiImage != null) {
          apiImageUrl = await _uploadImage(_apiImage!, 'apiImages/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');
        }

        final bookData = {
          'title': _titleController.text.trim(),
          'author': _authorController.text.trim(),
          'edition': _editionController.text.trim(),
          'isbn': _noIsbn ? '' : _isbnController.text.trim(),
          'publicationYear': _publicationYearController.text.trim(),
          'publisher': _publisherController.text.trim(),
          'condition': _condition,
          'genres': _noIsbn ? [_genreController.text] : _genres,
          'imageUserUrl': userImageUrl ?? '',
          'imageApiUrl': apiImageUrl ?? '',
          'userId': userId,
          'userInfo': {
            'profileImageUrl': userData['profileImageUrl'] ?? '',
            'address': userData['address'] ?? '',
            'customerRating': userData['customerRating'] ?? 0.0,
            'name': userData['name'] ?? '',
            'userId': userId,
          },
        };

        await FirebaseFirestore.instance.collection('books').add(bookData);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookExchangePage(bookDetails: bookData),
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
            const Text('Adicione uma foto:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[200],
                ),
                child: _selectedImage != null
                    ? Image.file(_selectedImage!, fit: BoxFit.cover)
                    : const Center(child: Icon(Icons.camera_alt, color: Colors.black, size: 50)),
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
