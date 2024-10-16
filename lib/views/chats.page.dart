import 'package:flutter/material.dart';

class ChatsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFFD8D5B3), // Cor amarelada da barra superior
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop(); // Voltar para a página anterior
          },
        ),
        title: Text(
          'Conversas',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: ListView.builder(
        itemCount: 5, // Número de conversas
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              // Navegar para a tela de detalhes da conversa
              Navigator.pushNamed(context, '/chat');
            },
            child: ListTile(
              tileColor: Color(0xFFE8E8E8),
              leading: CircleAvatar(
                          backgroundImage: NetworkImage('https://i.pravatar.cc/300'), // Substituir pela URL da imagem do perfil
                        ),
              title: Text('Contato $index'),
              subtitle: Text('Última mensagem $index'),
              trailing: Text('12:10'),
            ),
          );
        },
      ),
    );
  }
}