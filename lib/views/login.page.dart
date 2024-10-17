import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8D5B3), // Cor de fundo semelhante ao visto
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
                    errorBuilder: (BuildContext context, Object error,
                        StackTrace? stackTrace) {
                      return const Text('Erro ao carregar imagem');
                    },
                  ),
                  const SizedBox(width: 5), // Espaço entre logo e nome
                  // Nome do aplicativo
                  const Text(
                    'BookTrade',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Campo de Email
              TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // Campo de Senha
              TextField(
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
              const SizedBox(height: 10),

              // Esqueceu a senha
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Ação para "Esqueceu sua senha?"
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
                  onPressed: () {
                    Navigator.pushNamed(
                        context, '/home'); // Ação ao clicar em "Entrar"
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF77C593), // Cor verde semelhante ao botão
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text('Entrar'),
                  ),
                ),
              ),

              // Criar nova conta
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                      context, "/register"); // Ação para "Criar nova conta"
                },
                child: const Text(
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
