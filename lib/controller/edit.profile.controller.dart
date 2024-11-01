
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../user.dart';

class EditProfileController {
  final Firebasestorage = FirebaseStorage.instance;

  Future pickImage(File? selectedImage) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
        selectedImage = File(pickedFile.path);
        return selectedImage;
    }
    return null;
  }

  Future uploadImage(File? selectedImage, BuildContext context) async {
    try {
      if (selectedImage != null) {
        final storageref = Firebasestorage.ref().child('profile_images').child(user.uid);
        final uploadTask = storageref.putFile(selectedImage!);
        final snapshot = await uploadTask.whenComplete(() => null);
        final downloadUrl = await snapshot.ref.getDownloadURL();

        // Atualiza a URL da imagem no Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
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

  Future updateUserPassword(BuildContext context, String currentPassword, String email, String newPassword, String confirmNewPassword) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    // Lógica para alterar a senha
    if (newPassword.isNotEmpty &&
        newPassword == confirmNewPassword) {
      AuthCredential credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: currentPassword,
      );

      await currentUser.reauthenticateWithCredential(credential);
      await currentUser.updatePassword(newPassword);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha atualizada com sucesso!')),
      );
    } else if (newPassword != confirmNewPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não coincidem!')),
      );
    }
  }

  Future updateUserProfile(BuildContext context, String currentPassword, String name, String phone, String email, String password, String newPassword, String confirmNewPassword) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    try {
        // Atualiza o Firestore com os novos dados do usuário
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'name': name,
          'phone': phone,
        });

        // Atualiza o email se necessário
        if (email != user.email) {
          await currentUser!.updateEmail(email);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
      } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar perfil: $e')),
      );
    }
  }
}