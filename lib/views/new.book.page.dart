import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BookRegistrationPage extends StatefulWidget {
  @override
  _BookRegistrationPageState createState() => _BookRegistrationPageState();
}

class _BookRegistrationPageState extends State<BookRegistrationPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _editionController = TextEditingController();
  final TextEditingController _isbnController = TextEditingController();
  final TextEditingController _publicationYearController = TextEditingController();
  final TextEditingController _publisherController = TextEditingController();
  String _condition = 'Novo'; // Default condition
  bool _isLoading = false;
  List<String> _genres = [];
  File? _selectedImage; // Para armazenar a imagem selecionada

  // Método para buscar os gêneros a partir do ISBN
  Future<void> _fetchGenresFromISBN(String isbn) async {
    final url = 'https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['totalItems'] > 0) {
          final volumeInfo = data['items'][0]['volumeInfo'];
          final categories = volumeInfo['categories'] ?? [];

          setState(() {
            _genres = List<String>.from(categories);
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

  // Exibir erros
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Validação do ISBN
  bool _validateISBN(String isbn) {
    return (isbn.length == 10 || isbn.length == 13) && isbn.contains(RegExp(r'^\d+$'));
  }

  // Validação dos campos
  bool _validateFields() {
    if (_titleController.text.isEmpty ||
        _authorController.text.isEmpty ||
        _editionController.text.isEmpty ||
        _isbnController.text.isEmpty ||
        _publicationYearController.text.isEmpty ||
        _publisherController.text.isEmpty){// Remoção da imagem como obrigatória apenas para teste||
        //_selectedImage == null) {
      _showError('Todos os campos, incluindo a imagem, são obrigatórios.');
      return false;
    }

    if (!_validateISBN(_isbnController.text.trim())) {
      _showError('ISBN inválido. Deve ter 10 ou 13 dígitos.');
      return false;
    }

    return true;
  }

  // Selecionar imagem
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Confirmar e redirecionar
  Future<void> _onConfirm() async {
    if (_validateFields()) {
      await _fetchGenresFromISBN(_isbnController.text.trim());

      Navigator.pushNamed(context, '/bookExchange', arguments: {
        'title': _titleController.text.trim(),
        'author': _authorController.text.trim(),
        'edition': _editionController.text.trim(),
        'isbn': _isbnController.text.trim(),
        'publicationYear': _publicationYearController.text.trim(),
        'publisher': _publisherController.text.trim(),
        'condition': _condition,
        'genres': _genres,
        'image': _selectedImage, // Incluindo a imagem para passar na próxima página
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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Cadastro do Livro', style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título e subtítulo para a foto
            const Text(
              'Adicione uma foto:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              'Envie uma foto do seu livro.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),

            // Container de Adicionar Foto
            GestureDetector(
              onTap: _pickImage, // Ação ao clicar para selecionar uma foto
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[200],
                ),
                child: _selectedImage != null
                    ? Image.file(_selectedImage!, fit: BoxFit.cover)
                    : const Center(
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.black,
                    size: 50,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            _buildTextField('Nome do Livro', _titleController),
            const SizedBox(height: 15),
            _buildTextField('Nome do Autor', _authorController),
            const SizedBox(height: 15),
            _buildTextField('Edição', _editionController),
            const SizedBox(height: 15),
            _buildTextField('ISBN', _isbnController),
            const SizedBox(height: 15),
            _buildTextField('Ano de publicação', _publicationYearController),
            const SizedBox(height: 15),
            _buildTextField('Editora', _publisherController),
            const SizedBox(height: 15),

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

            // Botão de Confirmar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onConfirm,
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

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }
}