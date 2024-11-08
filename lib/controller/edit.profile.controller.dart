
import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/controller/login.controller.dart';
import 'package:myapp/views/home.page.dart';

import '../user.dart';

class EditProfileController {
  final Firebasestorage = FirebaseStorage.instance;
  final loginControler = LoginController();

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

  Future<void> updateUserEmail(BuildContext context, String newEmail, String currentPassword) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      Fluttertoast.showToast(msg: 'Usuário não está logado ou não foi encontrado');
      return;
    }

    final credential = EmailAuthProvider.credential(email: currentUser.email!, password: currentPassword);

    try {
      await currentUser.reauthenticateWithCredential(credential);
      await currentUser.verifyBeforeUpdateEmail(newEmail);
      await currentUser.sendEmailVerification();
      Fluttertoast.showToast(msg: 'E-mail de verificação enviado. Verifique sua caixa de entrada.');

      // Iniciar o processo de verificação e atualização da coleção
      checkEmailVerificationAndUpdateCollection(context, currentUser);
    } catch (e) {
      print('Erro ao trocar e-mail: $e');
      Fluttertoast.showToast(msg: 'Erro ao tentar atualizar o e-mail: $e');
    }
  }

  Future<void> checkEmailVerificationAndUpdateCollection(BuildContext context, User currentUser) async {
    const maxDuration = Duration(minutes: 5);
    DateTime startTime = DateTime.now();

    Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (DateTime.now().difference(startTime) > maxDuration) {
        timer.cancel(); // Para o temporizador após o tempo limite
        Fluttertoast.showToast(msg: 'Tempo para verificação expirado. Tente novamente.');
        return;
      }

      await currentUser.reload();

      if (currentUser.emailVerified) {
        timer.cancel();

        try {
          await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
            'email': currentUser.email,
            'emailVerified': true,
          });
          Fluttertoast.showToast(msg: 'E-mail confirmado e dados atualizados com sucesso!');
        } catch (e) {
          Fluttertoast.showToast(msg: 'Erro ao atualizar dados no Firestore: $e');
        }
      }
    });
  }

  Future<void> updateUserPassword(BuildContext context, String currentPassword, String newPassword, String confirmNewPassword) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não encontrado ou não está logado')),
      );
      return;
    }

    if (newPassword.isNotEmpty && confirmNewPassword == newPassword) {
      try {
        AuthCredential credential = EmailAuthProvider.credential(
          email: currentUser.email!,
          password: currentPassword,
        );

        await currentUser.reauthenticateWithCredential(credential);
        await currentUser.updatePassword(newPassword);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senha atualizada com sucesso!')),
        );
        Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
      } catch (err) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senha atual incorreta ou erro ao atualizar senha')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não coincidem!')),
      );
    }
  }
}