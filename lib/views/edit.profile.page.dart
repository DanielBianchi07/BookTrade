import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfilePage extends StatefulWidget {
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

  User? currentUser;
  String? profileImageUrl;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      setState(() {
        nameController.text = userDoc['name'] ?? '';
        phoneController.text = userDoc['phone'] ?? '';
        emailController.text = userDoc['email'] ?? '';
        profileImageUrl = userDoc['profileImageUrl'] ?? '';
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage != null && currentUser != null) {
      final storageRef = FirebaseStorage.instance.ref().child('profile_images').child(currentUser!.uid);
      final uploadTask = storageRef.putFile(_selectedImage!);
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Atualiza a URL da imagem no Firestore
      await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).update({
        'profileImageUrl': downloadUrl,
      });

      setState(() {
        profileImageUrl = downloadUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto de perfil atualizada com sucesso!')),
      );
    }
  }

  Future<void> _updateUserProfile() async {
    if (currentUser != null) {
      // Atualiza o Firestore com os novos dados do usuário
      await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).update({
        'name': nameController.text,
        'phone': phoneController.text,
      });

      // Atualiza o email se necessário
      if (emailController.text != currentUser!.email) {
        await currentUser!.updateEmail(emailController.text);
      }

      // Lógica para alterar a senha
      if (newPasswordController.text.isNotEmpty &&
          newPasswordController.text == confirmNewPasswordController.text) {
        try {
          // Reautentica o usuário antes de mudar a senha
          AuthCredential credential = EmailAuthProvider.credential(
            email: currentUser!.email!,
            password: currentPasswordController.text,
          );

          await currentUser!.reauthenticateWithCredential(credential);
          await currentUser!.updatePassword(newPasswordController.text);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Senha atualizada com sucesso!')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao atualizar a senha: $e')),
          );
        }
      } else if (newPasswordController.text != confirmNewPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('As senhas não coincidem!')),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso!')),
      );
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
                          onTap: _pickImage, // Selecionar nova imagem
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
