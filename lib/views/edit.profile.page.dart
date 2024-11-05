import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myapp/controller/edit.profile.controller.dart';

import '../user.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final controller = EditProfileController();
  final TextEditingController name = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController currentPassword = TextEditingController();
  final TextEditingController newPassword = TextEditingController();
  final TextEditingController confirmNewPassword = TextEditingController();
  String? profileImageUrl;
  File? selectedImage;
  var busy = false;

  @override
  void initState() {
    super.initState();
    // Atribuir os valores iniciais dos controladores com os dados do usuário
    name.text = user.value.name;
    phone.text = user.value.telephone;
    email.text = user.value.email;
  }

  hanfleEditProfile() {
    setState(() {
      busy = true;
    });
      controller.updateUserProfile(context, currentPassword.text.trim(), name.text.trim(), phone.text.trim(), email.text.trim(), currentPassword.text.trim(), newPassword.text.trim(), confirmNewPassword.text.trim()).then((data) {
      onSuccess();
    }).catchError((err) {
      onError();
    }).whenComplete(() {
      onComplete();
    });
  }

  onSuccess() {

  }

  onError() {

  }

  onComplete() {

  }

  Future<GestureTapCallback?> selectImage() async {
    final selectedImage = await controller.pickImage(); // Espera o resultado
    if (selectedImage != null) {
      setState(() {
        this.selectedImage = selectedImage; // Atualiza o estado aqui
      });
    }
    return null;
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
                        backgroundImage: selectedImage != null
                            ? FileImage(selectedImage!)
                            : (profileImageUrl != null && profileImageUrl!.isNotEmpty
                            ? NetworkImage(profileImageUrl!)
                            : const NetworkImage('')),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: selectImage, // Selecionar nova imagem
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
                    user.value.name,
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
              controller: name,
            ),
            const SizedBox(height: 5),

            // Campo de Telefone Editável
            _buildEditableField(
              label: 'Telefone:',
              controller: phone,
            ),
            const SizedBox(height: 5),

            // Campo de E-mail Editável
            _buildEditableField(
              label: 'E-mail:',
              controller: email,
            ),
            const SizedBox(height: 5),

            // Campo de Senha Atual
            _buildEditableField(
              label: 'Senha Atual:',
              controller: currentPassword,
              obscureText: true,
            ),
            const SizedBox(height: 5),

            // Campo de Nova Senha
            _buildEditableField(
              label: 'Nova Senha:',
              controller: newPassword,
              obscureText: true,
            ),
            const SizedBox(height: 5),

            // Campo de Confirmar Nova Senha
            _buildEditableField(
              label: 'Confirmar Nova Senha:',
              controller: confirmNewPassword,
              obscureText: true,
            ),
            const SizedBox(height: 20),

            // Botão Salvar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  hanfleEditProfile();
                  controller.uploadImage(selectedImage, context); // Faz o upload da nova imagem de perfil
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
