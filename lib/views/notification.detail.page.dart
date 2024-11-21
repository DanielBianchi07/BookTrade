import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationDetailPage extends StatelessWidget {
  final String notificationId; // ID da notificação no Firestore
  final String title;
  final String message;
  final String time;

  const NotificationDetailPage({
    super.key,
    required this.notificationId,
    required this.title,
    required this.message,
    required this.time,
  });

  /// Função para marcar a notificação como lida
  Future<void> _markAsRead() async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update({'isUnread': false});
      print('Notificação marcada como lida.');
    } catch (e) {
      print('Erro ao marcar a notificação como lida: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Marca a notificação como lida ao carregar a página
    WidgetsBinding.instance.addPostFrameCallback((_) => _markAsRead());

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFFD8D5B3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              time,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}