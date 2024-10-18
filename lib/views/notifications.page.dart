import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'notification.detail.page.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD8D5B3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Notificações',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('notifications').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              var notification = notifications[index];
              return Column(
                children: [
                  NotificationCard(
                    profileImageUrl: notification['profileImageUrl'],
                    icon: notification['icon'] != null ? Icons.local_shipping : null,
                    title: notification['title'],
                    message: notification['message'],
                    time: notification['time'],
                    isUserNotification: notification['isUserNotification'],
                  ),
                  const SizedBox(height: 10),
                ],
              );
            },
          );
        },
      ),
    );
  }
}


class NotificationCard extends StatelessWidget {
  final String? profileImageUrl;
  final IconData? icon;
  final String title;
  final String message;
  final Timestamp time; // Atualize aqui para receber Timestamp
  final bool isUserNotification;

  const NotificationCard({
    super.key,
    this.profileImageUrl,
    this.icon,
    required this.title,
    required this.message,
    required this.time,
    required this.isUserNotification,
  });

  @override
  Widget build(BuildContext context) {
    // Formatar o timestamp para uma data legível
    String formattedTime = DateFormat('dd/MM/yyyy HH:mm').format(time.toDate());

    return InkWell(
      onTap: () {
        // Navegar para a tela de detalhes da notificação ao clicar
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationDetailPage(
              title: title,
              message: message,
              time: formattedTime,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10.0),
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
            const SizedBox(width: 10),
            // Conteúdo da notificação
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  // Limitar o número de linhas do texto da notificação
                  Text(
                    message,
                    maxLines: 2, // Define o limite de linhas
                    overflow: TextOverflow.ellipsis, // Adiciona "..." ao final se exceder o limite
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Hora da notificação formatada
            Text(
              formattedTime,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}
