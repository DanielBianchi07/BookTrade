import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../services/notification.service.dart';
import 'home.page.dart';
import 'notification.detail.page.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Obter o ID do usuário logado
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD8D5B3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
                  (Route<dynamic> route) => false, // Remove todas as rotas anteriores
            );
          },
        ),
        title: const Text(
          'Notificações',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: currentUserId) // Filtra as notificações pelo usuário logado
            .orderBy('timestamp', descending: true) // Ordena por data
            .snapshots(),
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
                    notificationId: notification.id,
                    icon: notification['icon'],
                    title: notification['title'],
                    body: notification['body'],
                    time: notification['timestamp'],
                    isUnread: notification['isUnread'],
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
  final String? icon; // Caminho do ícone no formato `assets/...`
  final String notificationId; // ID da notificação no Firestore
  final String title;
  final String body;
  final Timestamp time; // Recebe um Timestamp do Firestore
  final bool isUnread;

  const NotificationCard({
    super.key,
    this.icon,
    required this.notificationId,
    required this.title,
    required this.body,
    required this.time,
    required this.isUnread,
  });

  /// Exibe o diálogo de confirmação antes de excluir a notificação
  Future<void> _confirmDelete(BuildContext context) async {
    final NotificationService notificationService = NotificationService();

    bool confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar Exclusão"),
          content: const Text("Deseja realmente excluir esta notificação?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Excluir"),
            ),
          ],
        );
      },
    ) ??
        false;

    if (confirm) {
      try {
        await notificationService.deleteNotification(notificationId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notificação excluída com sucesso!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao excluir a notificação!')),
        );
      }
    }
  }

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
              notificationId: notificationId,
              title: title,
              message: body,
              time: formattedTime,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: isUnread ? Colors.grey[300] : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Exibir ícone ou placeholder
            if (icon != null)
              Image.asset(
                icon!,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              )
            else
              const Icon(
                Icons.notifications,
                size: 40,
              ),
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
                  Text(
                    body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Hora da notificação formatada e ícone de exclusão
            Column(
              children: [
                Text(
                  formattedTime,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(height: 5),
                // Ícone de exclusão com confirmação
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.black54),
                  onPressed: () => _confirmDelete(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}