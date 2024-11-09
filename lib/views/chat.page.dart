// lib/pages/chat_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:myapp/user.dart';
import '../services/message.service.dart';
import '../widgets/message.bubble.widget.dart';

class ChatPage extends StatefulWidget {
  final String otherUserId;

  const ChatPage({
    super.key,
    required this.otherUserId,
  });

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
      _showErrorSnackBar("Erro ao carregar dados do destinatário.");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conversationId = _generateConversationId(user.value.uid, widget.otherUserId);
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
              stream: _messageService.getMessagesStream(conversationId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  _showErrorSnackBar("Erro ao carregar mensagens.");
                  return const Center(
                    child: Text("Erro ao carregar mensagens"),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("Nenhuma mensagem encontrada"),
                  );
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
          receiverName: _receiverName, // Nome do destinatário
          receiverProfileUrl: _receiverProfileImageUrl, // URL da imagem do destinatário
          content: _messageController.text.trim(),
          receiverId: widget.otherUserId,
          timestamp: FieldValue.serverTimestamp(), // Adiciona o timestamp
        );
        _messageController.clear();
      }
    }
  }
  String _generateConversationId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode ? '${user1}_$user2' : '${user2}_$user1';
  }
}
