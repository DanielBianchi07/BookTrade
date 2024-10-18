import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myapp/controller/login.controller.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/views/home.page.dart';
import 'package:myapp/widgets/busy.widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final controller = new LoginController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final AuthService _authService = AuthService();
  late String email;
  late String password;
  var busy = false;

  Future _signIn() async {
    String email = _email.text.trim();
    String password = _password.text.trim();

    if (email.isEmpty || password.isEmpty) {
      // Exibir mensagem se algum campo estiver vazio
      Fluttertoast.showToast(
        msg: "Por favor, insira email e senha",
        toastLength: Toast.LENGTH_LONG,
      );
    }

    final user = await _authService.loginWithEmail(email, password);
    if (user != null) {
      // Se o login for bem-sucedido, navegue para a página inicial
      Navigator.pushReplacementNamed(context, '/home');
    }
    // Não é necessário tratar erros aqui, o AuthService já lida com isso
  }

  handleSignIn() {
    setState(() {
      busy = true;
      email = _email.text.trim();
      password = _password.text.trim();
    });
    controller.loginWithEmail(email, password).then((data) {
      onSuccess();
    }).whenComplete(() {
      onComplete();
    });
  }

  onSuccess() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage(),
      ),
    );
  }

  onComplete() {
    setState(() {
      busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD8D5B3),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo e Nome do Aplicativo lado a lado
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo do aplicativo
                  Image.asset(
                    'assets/logo_transparent.png',
                    height: 60,
                    errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                      return Text('Erro ao carregar imagem');
                    },
                  ),
                  SizedBox(width: 5),
                  // Nome do aplicativo
                  Text(
                    'BookTrade',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),

              // Campo de Email
              TextField(
                controller: _email,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 20),

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
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 10),

              // Esqueceu a senha
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Ação para "Esqueceu sua senha?"
                    // Você pode implementar a recuperação de senha aqui
                  },
                  child: Text(
                    'Esqueceu sua senha?',
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ),

              // Botão Entrar
              TDBusy(busy: busy,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: handleSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF77C593),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text('Entrar'),
                    ),
                  ),
                ),
              ),

              // Criar nova conta
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/register");
                },
                child: Text(
                  'Criar nova conta',
                  style: TextStyle(
                    color: Colors.black,
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
