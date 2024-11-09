import 'package:flutter/material.dart';
import 'package:myapp/controller/edit.profile.controller.dart';
import 'package:myapp/widgets/edit.field.dart';

import '../controller/login.controller.dart';

class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({super.key});

  @override
  _ChangeEmailPageState createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final loginController = LoginController();
  final editProfileController = EditProfileController();
  final TextEditingController email = TextEditingController();

  @override
  void initState() {
    super.initState();
    loginController.AssignUserData(context);
  }


  @override
  Widget build(BuildContext context) {
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
        'Alterar E-mail',
        style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: Column(children: [EditField(label: 'Novo E-mail', controller: email),
            const SizedBox(height: 50),
            // Botão Salvar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  editProfileController.updateUserEmail(context, email.text);
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