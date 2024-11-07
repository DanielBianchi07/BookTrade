
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/views/home.page.dart';

import '../user.dart';

class EditProfileController {
  final Firebasestorage = FirebaseStorage.instance;

  Future<File?> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path); // Retorna o arquivo selecionado
    }
    return null; // Retorna null se nenhum arquivo for selecionado
  }

  Future uploadImage(File? selectedImage, BuildContext context) async {
    try {
      if (selectedImage != null) {
        final storageref = Firebasestorage.ref().child('profileImageUrl').child(user.value.uid);
        final uploadTask = storageref.putFile(selectedImage);
        final snapshot = await uploadTask.whenComplete(() => null);
        final downloadUrl = await snapshot.ref.getDownloadURL();

        // Atualiza a URL da imagem no Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.value.uid).update({
          'profileImageUrl': downloadUrl,
        });

        var profileImageUrl = downloadUrl;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto de perfil atualizada com sucesso!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao fazer upload da imagem: $e')),
      );
    }
  }

  Future updateUserPassword(BuildContext context, String currentPassword, String newPassword, String confirmNewPassword) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      if (newPassword.isNotEmpty &&
          confirmNewPassword == newPassword) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: currentUser.email!,
          password: currentPassword,
        );
        await currentUser.reauthenticateWithCredential(credential).catchError((err) {
          throw ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Senha atual incorreta')),
          );
        });
        await currentUser.updatePassword(newPassword);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senha atualizada com sucesso!')),
        );
        Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
      } else if (newPassword != confirmNewPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('As senhas não coincidem!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não encontrado ou não está logado')),
      );
    }
  }

  Future updateUserProfile(BuildContext context, String name, String phone, String? address) async {
    try {
      if (name.isNotEmpty && phone.isNotEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(user.value.uid).update({
          'name': name,
          'phone': phone,
          'address': address,
        });
        Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
      } else {
          throw Exception('Os campos de Nome e Telefone não podem ser vazios');
      }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
      } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar perfil: $e')),
      );
    }
  }

  Future updateUserEmail(BuildContext context, String newEmail) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // Verifica se o novo e-mail é diferente do atual
      if (newEmail != currentUser.email) {
        try {
          // Configura os parâmetros de ação de código de verificação, como a URL de redirecionamento após o e-mail ser verificado
          ActionCodeSettings actionCodeSettings = ActionCodeSettings(
            // Redireciona o usuário após a verificação
            url: 'https://booktrade-c6ed3.firebaseapp.com/__/auth/action?mode=action&oobCode=code',
            handleCodeInApp: true,
          );

          // Envia o e-mail de verificação
          await currentUser.verifyBeforeUpdateEmail(newEmail, actionCodeSettings);

          Fluttertoast.showToast(msg: 'E-mail de verificação enviado. Verifique sua caixa de entrada.');

        } catch (e) {
          // Trate erros, como e-mail inválido ou problemas ao enviar o código
          Fluttertoast.showToast(msg: 'Erro ao tentar atualizar o e-mail: $e');
        }
      } else {
        Fluttertoast.showToast(msg: 'O novo e-mail deve ser diferente do e-mail já usado');
      }
    } else {
      Fluttertoast.showToast(msg: 'Usuário não está logado ou não foi encontrado');
    }
  }
}