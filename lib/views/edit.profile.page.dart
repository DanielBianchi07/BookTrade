import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myapp/controller/edit.profile.controller.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController = TextEditingController();

  String? profileImageUrl;
  File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD8D5B3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // Foto de perfil e nome do usuário
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : (profileImageUrl != null && profileImageUrl!.isNotEmpty
                            ? NetworkImage(profileImageUrl!)
                            : const NetworkImage('https://via.placeholder.com/150')) as ImageProvider<Object>,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: pickIm, // Selecionar nova imagem
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    nameController.text,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),

            // Campo de Nome Editável
            _buildEditableField(
              label: 'Nome:',
              controller: nameController,
            ),
            const SizedBox(height: 5),

            // Campo de Telefone Editável
            _buildEditableField(
              label: 'Telefone:',
              controller: phoneController,
            ),
            const SizedBox(height: 5),

            // Campo de E-mail Editável
            _buildEditableField(
              label: 'E-mail:',
              controller: emailController,
            ),
            const SizedBox(height: 5),

            // Campo de Senha Atual
            _buildEditableField(
              label: 'Senha Atual:',
              controller: currentPasswordController,
              obscureText: true,
            ),
            const SizedBox(height: 5),

            // Campo de Nova Senha
            _buildEditableField(
              label: 'Nova Senha:',
              controller: newPasswordController,
              obscureText: true,
            ),
            const SizedBox(height: 5),

            // Campo de Confirmar Nova Senha
            _buildEditableField(
              label: 'Confirmar Nova Senha:',
              controller: confirmNewPasswordController,
              obscureText: true,
            ),
            const SizedBox(height: 20),

            // Botão Salvar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _updateUserProfile();
                  _uploadImage(); // Faz o upload da nova imagem de perfil
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF77C593),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Text('Salvar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Função para construir cada campo de edição do perfil
  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade200,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
