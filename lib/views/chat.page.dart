import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFD8D5B3), // Cor amarelada da barra superior
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop(); // Voltar para a página anterior
          },
        ),
        title: Row(
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
        color: Color(0xFFE8E8E8), // Cor de fundo da tela
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  // Bolha usuário (verde claro)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFFD8D5B3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('Daniel, eu ja disse para parar de jogar em aula'),
                    ),
                  ),

                  SizedBox(height: 8), // Espaço entre as mensagens

                  // Bolha do outro usuário (branca)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFF7ABC84),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('Sou burro uga uga'),
                    ),
                  ),

                  SizedBox(height: 8), // Espaço entre as mensagens

                  // Bolha do outro usuário (verde claro)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFFD8D5B3), 
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('...'),
                    ),
                  ),
                ],
              ),
            ),
            // Campo de texto
            Container(
              color: Color(0xFFFFFFFF),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Digite uma mensagem...',
                        filled: true,
                        fillColor: Color(0xFFE8E8E8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
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