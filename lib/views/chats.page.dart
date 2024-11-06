// lib/pages/chats_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:myapp/services/chats.service.dart';
import 'chat.page.dart';

class ChatsPage extends StatelessWidget {
  final ChatsService _chatsService = ChatsService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ChatsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Conversas'),
          backgroundColor: const Color(0xFFD8D5B3),
        ),
        body: const Center(child: Text('Nenhum usuário autenticado.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD8D5B3),
        elevation: 0,
        title: const Text('Conversas', style: TextStyle(color: Colors.black)),
      ),
      body: StreamBuilder<List<QueryDocumentSnapshot>>(
        stream: _chatsService.getLastMessagesStream(currentUser.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final conversations = snapshot.data!;

          if (conversations.isEmpty) {
            return const Center(child: Text('Nenhuma conversa encontrada.'));
          }

          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final messageData = conversations[index];
              final otherUserId = messageData['senderId'] == currentUser.uid
                  ? messageData['receiverId']
                  : messageData['senderId'];
              final lastMessage = messageData['content'] ?? '';
              final timestamp = messageData['timestamp'] as Timestamp?;
              final formattedTime = timestamp != null
                  ? DateFormat('HH:mm').format(timestamp.toDate())
                  : '';

              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc(otherUserId).snapshots(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const ListTile(
                      title: Text('Carregando...'),
                    );
                  }

                  final userDoc = userSnapshot.data!;
                  final otherUserName = userDoc['name'] ?? 'Usuário';
                  final otherUserImage = userDoc['profileImageUrl'] ?? '';

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(otherUserImage),
                    ),
                    title: Text(otherUserName),
                    subtitle: Text(lastMessage),
                    trailing: Text(formattedTime),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            otherUserId: otherUserId,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
