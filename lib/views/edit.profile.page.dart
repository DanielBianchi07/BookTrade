import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myapp/controller/edit.profile.controller.dart';
import '../controller/login.controller.dart';
import '../user.dart';
import 'change.email.page.dart';
import 'change.password.page.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final loginController = LoginController();
  final controller = EditProfileController();
  final TextEditingController name = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController currentPassword = TextEditingController();
  final TextEditingController newPassword = TextEditingController();
  final TextEditingController confirmNewPassword = TextEditingController();
  String? profileImageUrl;
  File? selectedImage;
  var busy = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _inicializarDados();
  }

  _inicializarDados() async {
    // Aguarda a execução de uma função assíncrona antes de prosseguir
    await loginController.AssignUserData(context);
    setState(() {
      _isLoading = false;
    });
    // Outra ação a ser realizada após a função assíncrona
    print('Função assíncrona executada');

    if (_isLoading == false) {
      name.text = user.value.name;
      phone.text = user.value.telephone;
      if (user.value.address != null) {
        address.text = user.value.address!;
      } else {
        address.text = '';
      }
      email.text = user.value.email;
      print('dados carregados aos labels');
    }
  }

  handleEditProfile() {
    setState(() {
      busy = true;
    });
      controller.updateUserProfile(context, name.text.trim(), phone.text.trim(), address.text.trim()).then((data) {
    }).catchError((err) {
      onError(err);
    }).whenComplete(() {
      onComplete();
    });
  }

  onError(err) {
    if (err is FirebaseAuthException) {
      loginController.handleFirebaseAuthError(err);
    } else {
      Fluttertoast.showToast(
        msg: "Erro inesperado: $err",
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  onComplete() {
    setState(() {
      busy = false;
    });
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
        title: const Text(
            'Editar Perfil',
            style: TextStyle(color: Colors.black)),
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

            _buildEditableField(
              label: 'Endereço:',
              controller: address,
            ),
            const SizedBox(height: 5),
            // Campo de E-mail NÃO Editável
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text(
                'E-mail',
                style: const TextStyle(
                fontWeight: FontWeight.bold,
                  ),
                ),
      const SizedBox(height: 5),
      TextFormField(
        controller: email,
        obscureText: false,
        readOnly: true,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
      ),],
    ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Centraliza os botões horizontalmente
              children: [
                // Botão Alterar E-mail
                SizedBox(
                  width: 150, // Largura fixa do botão
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ChangeEmailPage()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD8D5B3),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(10.0), // Ajusta o padding do botão
                      child: Text(
                        'Alterar e-mail',
                        style: TextStyle(fontSize: 12), // Ajuste do tamanho do texto
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20), // Espaçamento entre os botões (ajuste conforme necessário)
                // Botão Alterar Senha
                SizedBox(
                  width: 150, // Largura fixa do botão
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePasswordPage()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD8D5B3),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(10.0), // Ajusta o padding do botão
                      child: Text(
                        'Alterar senha',
                        style: TextStyle(fontSize: 12), // Ajuste do tamanho do texto
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            // Botão Salvar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  handleEditProfile();
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
