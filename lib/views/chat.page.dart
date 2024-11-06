// lib/pages/chat_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../services/message.service.dart';
import '../widgets/message.bubble.widget.dart';

class ChatPage extends StatefulWidget {
  final String otherUserId;

  const ChatPage({
    Key? key,
    required this.otherUserId,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final MessageService _messageService = MessageService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _receiverName = 'Usuário';
  String _receiverProfileImageUrl = 'https://via.placeholder.com/150';

  @override
  void initState() {
    super.initState();
    _loadReceiverData();
  }

  // Função para carregar os dados do usuário destinatário
  Future<void> _loadReceiverData() async {
    try {
      final receiverDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.otherUserId)
          .get();
      if (receiverDoc.exists) {
        setState(() {
          _receiverName = receiverDoc['name'] ?? 'Usuário';
          _receiverProfileImageUrl =
              receiverDoc['profileImageUrl'] ?? 'https://via.placeholder.com/150';
        });
      }
    } catch (e) {
      // Caso ocorra algum erro, exibir mensagem de erro
      print("Erro ao carregar dados do destinatário: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD8D5B3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(_receiverProfileImageUrl),
            ),
            const SizedBox(width: 10),
            Text(_receiverName, style: const TextStyle(color: Colors.black)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Exibição de mensagens em tempo real
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messageService.getMessagesStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData = messages[index];
                    final messageContent = messageData['content'] ?? '';
                    final isUser = messageData['senderId'] == _auth.currentUser?.uid;

                    // Obtenha o timestamp e formate a data
                    Timestamp? timestamp = messageData['timestamp'] as Timestamp?;
                    String formattedTime = '';
                    if (timestamp != null) {
                      DateTime date = timestamp.toDate();
                      formattedTime = DateFormat('HH:mm').format(date);
                    }

                    return MessageBubble(
                      message: messageContent,
                      isUser: isUser,
                      time: formattedTime,
                    );
                  },
                );
              },
            ),
          ),

          // Campo de texto para envio de mensagens
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
                    controller: _messageController,
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
                  onPressed: () {
                    _sendMessage();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Função para enviar uma mensagem
  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      final user = _auth.currentUser;
      if (user != null) {
        _messageService.sendMessage(
          senderId: user.uid,
          senderName: user.displayName ?? 'Usuário',
          senderProfileUrl: user.photoURL ?? 'https://via.placeholder.com/150',
          content: _messageController.text.trim(),
          receiverId: widget.otherUserId,
          participants: [user.uid, widget.otherUserId],
          timestamp: FieldValue.serverTimestamp(), // Adiciona o timestamp
        );
        _messageController.clear();
      }
    }
  }
}
