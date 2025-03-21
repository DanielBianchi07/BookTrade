import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/services/message.service.dart';
import '../user.dart';
import '../widgets/chat.tile.widget.dart';
import '../services/chats.service.dart';
import 'chat.page.dart';
import '../controller/login.controller.dart';
import '../models/message.model.dart';
import 'home.page.dart';

class ChatsPage extends StatelessWidget {
  final ChatsService _chatsService = ChatsService();
  final MessageService _messageService = MessageService();

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
            leading: IconButton(
              icon: const Icon(Icons.home),
              onPressed: () async {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(),
                  ),
                      (Route<dynamic> route) => false, // Remove todas as rotas anteriores
                );
              },
            ),
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

              // Filtrar conversas baseando-se no status correto (ativo/inativo)
              final conversationDocs = snapshot.data!.docs.where((doc) {
                final participants = (doc['participants'] as String).split('_');
                final isUser1 = participants[0] == user.value.uid;
                final isActive = isUser1 ? doc['isActiveForUser1'] : doc['isActiveForUser2'];
                return participants.contains(user.value.uid) && isActive; // Verifica se a conversa está ativa para o usuário atual
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
                        return const ListTile(title: Text('Carregando...'));
                      }
                      if (messageSnapshot.hasError) {
                        return const ListTile(title: Text('Erro ao carregar mensagem'));
                      }

                      // Mensagem pode ser nula para conversas sem mensagens
                      final message = messageSnapshot.data;
                      final lastMessage = message?.content ?? 'Inicie uma conversa';
                      final formattedTime = message != null
                          ? message.timestamp
                          : '';

                      // Dividir `participants` e identificar o outro usuário
                      final participants = (conversationDoc['participants'] as String).split('_');
                      final otherUserId = participants.firstWhere((id) => id != user.value.uid);

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState == ConnectionState.waiting) {
                            return const ListTile(title: Text('Carregando...'));
                          }
                          if (userSnapshot.hasError || !userSnapshot.hasData) {
                            return const ListTile(title: Text('Erro ao carregar usuário'));
                          }

                          final userDoc = userSnapshot.data!;
                          final otherUserName = userDoc['name'] ?? 'Usuário';
                          final otherUserImage = userDoc['profileImageUrl'] ?? '';

                          // Buscar quantidade de mensagens não lidas
                          return StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('messages')
                                .where('conversationId', isEqualTo: conversationDoc['participants'])
                                .where('isRead', isEqualTo: false)
                                .where('receiverId', isEqualTo: user.value.uid)
                                .snapshots(),
                            builder: (context, unreadSnapshot) {
                              if (unreadSnapshot.connectionState == ConnectionState.waiting) {
                                return const ListTile(title: Text('Carregando...'));
                              }
                              final unreadCount = unreadSnapshot.data?.docs.length ?? 0;

                              return ChatTile(
                                contactName: otherUserName,
                                lastMessage: lastMessage,
                                time: formattedTime,
                                avatarUrl: otherUserImage,
                                senderId: message?.senderId ?? '',
                                currentUserId: user.value.uid,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatPage(otherUserId: otherUserId),
                                    ),
                                  );
                                },
                                onDelete: () async {
                                  await _chatsService.updateConversationStatus(
                                      conversationId, user.value.uid);
                                },
                                unreadCount: unreadCount, // Passa a quantidade de mensagens não lidas
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
