import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/controller/edit.profile.controller.dart';

import '../controller/login.controller.dart';
import '../user.dart';
import '../widgets/edit.field.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final loginController = LoginController();
  final editProfileController = EditProfileController();
  var email = TextEditingController();
  final currentPassword = TextEditingController();
  final newPassword = TextEditingController();
  final confirmNewPassword = TextEditingController();

  @override
  void initState() {
    super.initState();
    loginController.AssignUserData(context);
  }


  @override
  Widget build(BuildContext context) {
    email.text = user.value.email;
    return Scaffold(key: _scaffoldKey,
      backgroundColor: Colors.white,
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
            'Alterar Senha',
            style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: Column(children: [EditField(label: 'Senha atual', controller: currentPassword, obscureText: true) ,EditField(label: 'Nova senha', controller: newPassword, obscureText: true), EditField(label: 'Confirme a Nova senha', controller: confirmNewPassword, obscureText: true),
            const SizedBox(height: 50),
            // Botão Salvar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  editProfileController.updateUserPassword(context, currentPassword.text, newPassword.text, confirmNewPassword.text);
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
            ),])
      ),
    );
  }

}