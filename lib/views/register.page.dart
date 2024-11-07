import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myapp/controller/login.controller.dart';
import 'package:myapp/controller/register.controller.dart';
import 'package:myapp/views/login.page.dart';
import 'package:myapp/widgets/busy.widget.dart';

import 'home.page.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final controller = new RegisterController();
  final loginController = new LoginController();
  var name = TextEditingController();
  var phone = TextEditingController();
  var email = TextEditingController();
  var password = TextEditingController();
  var passwordConfirm = TextEditingController();
  var busy = false;

  handleRegister() {

    if (name.text.isEmpty || phone.text.isEmpty || email.text.isEmpty || password.text.isEmpty || passwordConfirm.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Por favor, preencha todos os campos",
        toastLength: Toast.LENGTH_LONG,
      );
    } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$').hasMatch(email.text)) {
      Fluttertoast.showToast(
        msg: "Email inválido",
        toastLength: Toast.LENGTH_LONG,
      );
    } else if (password.text.length < 6) {
      Fluttertoast.showToast(
        msg: "A senha deve ter pelo menos 6 caracteres",
        toastLength: Toast.LENGTH_LONG,
      );
    } else if (password.text != passwordConfirm.text) {
      Fluttertoast.showToast(
        msg: "As senhas devem coincidir",
        toastLength: Toast.LENGTH_LONG,
      );
    } else {
      setState(() {
        busy = true;
      });
      controller.registerWithEmail(
        email: email.text,
        password: password.text,
        passwordConfirm: passwordConfirm.text,
        name: name.text,
        phone: phone.text,
      ).then((data) {
        if (data != null) {
          onSuccess();
        } else {
          Fluttertoast.showToast(
            msg: "Erro ao registrar usuário",
            toastLength: Toast.LENGTH_LONG,
          );
        }
      }).catchError((e) {
        onError(e);
      }).whenComplete(() {
        onComplete();
      });
    }
  }

  onSuccess() {
    loginController.loginWithEmail(email.text, password.text);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }


  onError(e) {
    Fluttertoast.showToast(
      msg: "Erro ao registrar: $e",
      toastLength: Toast.LENGTH_LONG,
    );
  }

  onComplete() {
    name.clear();
    phone.clear();
    email.clear();
    password.clear();
    passwordConfirm.clear();
    setState(() {
      busy = false;
    });
  }

  //============================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8D5B3),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo do aplicativo
              Image.asset(
                'assets/logo_transparent.png',
                height: 80,
              ),
              const SizedBox(height: 20),

              // Nome do aplicativo
              const Text(
                'BookTrade',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Texto descritivo
              Text(
                'Cadastre-se para começar a\n'
                    'trocar seus livros',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 30),

              // Campo de Nome
              TextField(
                controller: name,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 15),

              // Campo de Telefone
              TextField(
                controller: phone,
                decoration: InputDecoration(
                  labelText: 'Telefone',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 15),

              // Campo de Email
              TextField(
                controller: email,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 15),

              // Campo de Senha
              TextField(
                controller: password,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 15),

              // Campo de Confirmar Senha
              TextField(
                controller: passwordConfirm,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirme sua senha',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 30),

              // Botão de Cadastro
              TDBusy(busy: busy,
                child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: handleRegister, // Chama a função de registro
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF77C593),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text(
                      'Cadastrar',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Link para entrar
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                },
                child: const Text(
                  'Já possui conta? Entre aqui',
                  style: TextStyle(
                    color: Colors.black,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}