import 'package:flutter/material.dart';


class BookRegistrationPage extends StatelessWidget {
  const BookRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD8D5B3), // Cor amarelada semelhante à parte superior
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black), // Ícone de voltar
          onPressed: () {
            Navigator.pop(context); // Ação para voltar
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
            // Título e Subtítulo da Seção de Foto
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

            // Container de Adicionar Foto
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

            // Campos de Texto para Cadastro do Livro
            _buildTextField('Nome do Livro'),
            const SizedBox(height: 15),
            _buildTextField('Nome do Autor'),
            const SizedBox(height: 15),
            _buildTextField('Edição'),
            const SizedBox(height: 15),
            _buildTextField('ISBN'),
            const SizedBox(height: 15),
            _buildTextField('Ano de publicação'),
            const SizedBox(height: 15),
            _buildTextField('Editora'),
            const SizedBox(height: 15),

            // Dropdown para Estado de Conservação
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
                value: 'Novo',
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
                  // Ação ao mudar o valor
                },
                underline: const SizedBox(),
              ),
            ),
            const SizedBox(height: 30),

            // Botão de Confirmar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/publicatedBooks');// Ação ao clicar em "Confirmar"
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF77C593), // Cor verde do botão
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

  // Widget Helper para TextField
  Widget _buildTextField(String label) {
    return TextField(
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
