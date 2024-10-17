import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myapp/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controladores para os campos de email e senha
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Instância do AuthService
  final AuthService _authService = AuthService();

  // Função para autenticar o usuário
  Future<void> _signIn() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      // Exibir mensagem se algum campo estiver vazio
      Fluttertoast.showToast(
        msg: "Por favor, insira email e senha",
        toastLength: Toast.LENGTH_LONG,
      );
      return;
    }

    final user = await _authService.loginWithEmail(email, password);
    if (user != null) {
      // Se o login for bem-sucedido, navegue para a página inicial
      Navigator.pushReplacementNamed(context, '/home');
    }
    // Não é necessário tratar erros aqui, o AuthService já lida com isso
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
                controller: _emailController,
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
                controller: _passwordController,
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _signIn,
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
