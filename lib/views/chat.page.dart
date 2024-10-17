import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD8D5B3), // Cor amarelada da barra superior
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop(); // Voltar para a página anterior
          },
        ),
        title: const Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
            ),
            SizedBox(width: 10), // Espaço entre a foto e o título
            Text(
              'Victor',
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
      body: Container(
        color: const Color(0xFFE8E8E8), // Cor de fundo da tela
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  // Bolha usuário (verde claro)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8D5B3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Daniel, eu ja disse para parar de jogar em aula'),
                    ),
                  ),

                  const SizedBox(height: 8), // Espaço entre as mensagens

                  // Bolha do outro usuário (branca)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7ABC84),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Sou burro uga uga'),
                    ),
                  ),

                  const SizedBox(height: 8), // Espaço entre as mensagens

                  // Bolha do outro usuário (verde claro)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8D5B3), 
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('...'),
                    ),
                  ),
                ],
              ),
            ),
            // Campo de texto
            Container(
              color: const Color(0xFFFFFFFF),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Digite uma mensagem...',
                        filled: true,
                        fillColor: const Color(0xFFE8E8E8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}