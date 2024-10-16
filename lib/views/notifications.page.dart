import 'package:flutter/material.dart';


class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFD8D5B3), // Cor amarelada semelhante à parte superior
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // Ícone de voltar
          onPressed: () {
            Navigator.pop(context); // Ação para voltar
          },
        ),
        title: Text(
          'Notificações',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Notificação do usuário
          NotificationCard(
            profileImageUrl: 'https://via.placeholder.com/50',
            title: 'Bernardo Almeida',
            message: 'Você vem mesmo né mano?',
            time: '12:10',
            isUserNotification: true,
          ),
          SizedBox(height: 10),
          // Notificação do status do livro
          NotificationCard(
            profileImageUrl: '', // Notificação de sistema, sem imagem de perfil
            icon: Icons.local_shipping,
            title: 'Seu livro está a caminho!',
            message: 'O usuário X acabou de enviar o livro.',
            time: '12:10',
            isUserNotification: false,
          ),
        ],
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String? profileImageUrl;
  final IconData? icon;
  final String title;
  final String message;
  final String time;
  final bool isUserNotification;

  NotificationCard({
    this.profileImageUrl,
    this.icon,
    required this.title,
    required this.message,
    required this.time,
    required this.isUserNotification,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Ícone ou imagem do perfil
          if (isUserNotification && profileImageUrl != null) ...[
            CircleAvatar(
              backgroundImage: NetworkImage(profileImageUrl!),
              radius: 20,
            ),
          ] else if (!isUserNotification && icon != null) ...[
            Icon(
              icon,
              size: 40,
              color: Colors.black,
            ),
          ],
          SizedBox(width: 10),
          // Conteúdo da notificação
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  message,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          // Hora da notificação
          Text(
            time,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
