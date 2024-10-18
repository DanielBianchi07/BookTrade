import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Importante para usar File

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
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _publisherController = TextEditingController();
  String _condition = 'Novo';
  String? _imageUrl; // URL da imagem

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _editionController.dispose();
    _isbnController.dispose();
    _yearController.dispose();
    _publisherController.dispose();
    super.dispose();
  }

  // Método para escolher a imagem da galeria ou da câmera
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      // Carregar a imagem para o Firebase Storage
      await _uploadImage(image.path);
    }
  }

  // Método para fazer upload da imagem no Firebase Storage
  Future<void> _uploadImage(String filePath) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('books/${DateTime.now().millisecondsSinceEpoch}.png');
      await storageRef.putFile(File(filePath));
      String downloadUrl = await storageRef.getDownloadURL();
      setState(() {
        _imageUrl = downloadUrl; // Armazena a URL da imagem
      });
    } catch (e) {
      print('Erro ao fazer upload da imagem: $e');
    }
  }

  Future<void> _addBook() async {
    await FirebaseFirestore.instance.collection('books').add({
      'title': _titleController.text,
      'author': _authorController.text,
      'edition': _editionController.text,
      'isbn': _isbnController.text,
      'year': _yearController.text,
      'publisher': _publisherController.text,
      'condition': _condition,
      'imageUrl': _imageUrl, // Inclua a URL da imagem
    });
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
        title: const Text(
          'Cadastro do Livro',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Adicione uma foto:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Envie uma foto do seu livro.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage, // Chama o método para escolher uma imagem
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
                child: _imageUrl == null
                    ? const Center(
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.black,
                          size: 50,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          _imageUrl!,
                          fit: BoxFit.cover, // Ajusta a imagem para cobrir todo o container
                        ),
                      ), // Exibe a imagem se disponível
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
            _buildTextField('Ano de publicação', _yearController),
            const SizedBox(height: 15),
            _buildTextField('Editora', _publisherController),
            const SizedBox(height: 15),
            Text(
              'Estado de conservação',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
              ),
              child: DropdownButton<String>(
                isExpanded: true,
                value: _condition,
                items: [
                  'Novo',
                  'Poucas marcas de uso',
                  'Manchas e páginas rasgadas',
                  'Páginas faltando ou ilegíveis'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _condition = newValue!;
                  });
                },
                underline: const SizedBox(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await _addBook();
                  Navigator.pushNamed(context, '/publicatedBooks');
                },
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
                    style: TextStyle(
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
