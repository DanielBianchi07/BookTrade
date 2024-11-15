import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../user.dart';
import '../widgets/chat.tile.widget.dart';
import '../services/chats.service.dart';
import 'chat.page.dart';
import '../controller/login.controller.dart';
import '../models/message.model.dart';

class ChatsPage extends StatelessWidget {
  final ChatsService _chatsService = ChatsService();

  ChatsPage({super.key});

  Future<void> _checkUser(BuildContext context, LoginController loginController) async {
    loginController.AssignUserData(context);
  }

  @override
  Widget build(BuildContext context) {
    final LoginController loginController = LoginController();

    return FutureBuilder(
      future: _checkUser(context, loginController),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Erro ao carregar usuário"));
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFFD8D5B3),
            elevation: 0,
            title: const Text('Conversas', style: TextStyle(color: Colors.black)),
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('conversations').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text("Erro ao carregar conversas"));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('Nenhuma conversa encontrada.'));
              }

              // Filtrar conversas onde o `senderId` está presente em `participants`
              final conversationDocs = snapshot.data!.docs.where((doc) {
                final participants = doc['participants'] as String;
                return participants.contains(user.value.uid);
              }).toList();

              if (conversationDocs.isEmpty) {
                return const Center(child: Text('Nenhuma conversa encontrada.'));
              }

              return ListView.builder(
                itemCount: conversationDocs.length,
                itemBuilder: (context, index) {
                  final conversationDoc = conversationDocs[index];
                  final conversationId = conversationDoc.id;

                  return FutureBuilder<MessageModel?>(
                    future: _chatsService.getLastMessage(conversationId),
                    builder: (context, messageSnapshot) {
                      if (messageSnapshot.connectionState == ConnectionState.waiting) {
                        return const ListTile(
                          title: Text('Carregando...'),
                        );
                      }
                      if (messageSnapshot.hasError) {
                        return const ListTile(
                          title: Text('Erro ao carregar mensagem'),
                        );
                      }

                      final message = messageSnapshot.data;
                      final lastMessage = message != null ? message.content : 'Inicie uma conversa';
                      final formattedTime = message != null
                          ? DateFormat('HH:mm').format(message.timestamp.toDate())
                          : '';

                      // Dividir `participants` e pegar o outro usuário (recebedor)
                      final participants = (conversationDoc['participants'] as String).split('_');
                      final otherUserId = participants.firstWhere((id) => id != user.value.uid);

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(otherUserId)
                            .get(),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState == ConnectionState.waiting) {
                            return const ListTile(
                              title: Text('Carregando...'),
                            );
                          }
                          if (userSnapshot.hasError || !userSnapshot.hasData) {
                            return const ListTile(
                              title: Text('Erro ao carregar usuário'),
                            );
                          }

                          final userDoc = userSnapshot.data!;
                          final otherUserName = userDoc['name'] ?? 'Usuário';
                          final otherUserImage = userDoc['profileImageUrl'] ?? '';

                          return ChatTile(
                            contactName: otherUserName,
                            lastMessage: lastMessage,
                            time: formattedTime,
                            avatarUrl: otherUserImage,
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
              );
            },
          ),
        );
      },
    );
  }
}