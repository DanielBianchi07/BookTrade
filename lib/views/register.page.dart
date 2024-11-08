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
  var _name = TextEditingController();
  var _phone = TextEditingController();
  var _email = TextEditingController();
  var _password = TextEditingController();
  var _passwordConfirm = TextEditingController();
  late String name;
  late String phone;
  late String email;
  late String password;
  late String passwordConfirm;
  var busy = false;

  handleRegister() {
    name = _name.text.trim();
    phone = _phone.text.trim();
    email = _email.text.trim();
    password = _password.text.trim();
    passwordConfirm = _passwordConfirm.text.trim();

    if (name.isEmpty || phone.isEmpty || email.isEmpty || password.isEmpty || passwordConfirm.isEmpty) {
      Fluttertoast.showToast(
        msg: "Por favor, preencha todos os campos",
        toastLength: Toast.LENGTH_LONG,
      );
    } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$').hasMatch(email)) {
      Fluttertoast.showToast(
        msg: "Email inválido",
        toastLength: Toast.LENGTH_LONG,
      );
    } else if (password.length < 6) {
      Fluttertoast.showToast(
        msg: "A senha deve ter pelo menos 6 caracteres",
        toastLength: Toast.LENGTH_LONG,
      );
    } else if (password != passwordConfirm) {
      Fluttertoast.showToast(
        msg: "As senhas devem coincidir",
        toastLength: Toast.LENGTH_LONG,
      );
    } else {
      setState(() {
        busy = true;
      });
      controller.registerWithEmail(
        email: email,
        password: password,
        passwordConfirm: passwordConfirm,
        name: name,
        phone: phone,
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
    loginController.loginWithEmail(email, password);
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
    _name.clear();
    _phone.clear();
    _email.clear();
    _password.clear();
    _passwordConfirm.clear();
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
                controller: _name,
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
                controller: _phone,
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
                controller: _email,
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
                controller: _password,
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
                controller: _passwordConfirm,
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