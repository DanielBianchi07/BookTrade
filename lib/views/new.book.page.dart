import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookRegistrationPage extends StatefulWidget {
  const BookRegistrationPage({super.key});

  @override
  _BookRegistrationPageState createState() => _BookRegistrationPageState();
}

class _BookRegistrationPageState extends State<BookRegistrationPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _editionController = TextEditingController();
  final TextEditingController _isbnController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _publisherController = TextEditingController();
  String _condition = 'Novo';

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

  Future<void> _addBook() async {
    await FirebaseFirestore.instance.collection('books').add({
      'title': _titleController.text,
      'author': _authorController.text,
      'edition': _editionController.text,
      'isbn': _isbnController.text,
      'year': _yearController.text,
      'publisher': _publisherController.text,
      'condition': _condition,
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
              onTap: () {
                // Ação ao clicar para adicionar uma foto
              },
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
                child: const Center(
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
