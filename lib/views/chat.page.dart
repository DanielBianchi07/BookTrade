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
  bool _isSending = false;
  final ScrollController _scrollController = ScrollController();


  String _receiverName = 'Usuário';
  String _receiverProfileImageUrl = 'https://via.placeholder.com/150';

  @override
  void initState() {
    super.initState();
    _loadReceiverData();
    _markMessagesAsRead(_generateConversationId(user.value.uid, widget.otherUserId));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose(); // Libera o ScrollController
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
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

  void _markMessagesAsRead(String conversationId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('messages')
        .where('receiverId', isEqualTo: _auth.currentUser?.uid)
        .where('isRead', isEqualTo: false) // Filtrar mensagens não lidas
        .get();

    for (var doc in querySnapshot.docs) {
      await FirebaseFirestore.instance
          .collection('messages')
          .doc(doc.id)
          .update({'isRead': true}); // Marca a mensagem como lida
    }
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
                    child: Text(""),
                  );
                }

                final messages = snapshot.data!.docs;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom(); // Rola para o final ao carregar novas mensagens
                });

                // Agrupar mensagens por data
                Map<String, List<QueryDocumentSnapshot>> groupedMessages = {};
                for (var message in messages) {
                  final timestamp = message['timestamp'] as Timestamp?;
                  if (timestamp != null) {
                    final date = timestamp.toDate();
                    String dateLabel;

                    final now = DateTime.now();
                    if (DateUtils.isSameDay(date, now)) {
                      dateLabel = "Hoje";
                    } else if (DateUtils.isSameDay(date, now.subtract(const Duration(days: 1)))) {
                      dateLabel = "Ontem";
                    } else {
                      dateLabel = DateFormat('dd/MM/yyyy').format(date);
                    }

                    groupedMessages.putIfAbsent(dateLabel, () => []).add(message);
                  }
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: groupedMessages.keys.length,
                  itemBuilder: (context, index) {
                    final dateLabel = groupedMessages.keys.elementAt(index);
                    final dayMessages = groupedMessages[dateLabel]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Exibir o cabeçalho da data centralizado
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Center( // Adiciona alinhamento central
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                dateLabel,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Exibir mensagens do grupo
                        ...dayMessages.map((messageData) {
                          final messageContent = messageData['content'] ?? '';
                          final isUser = messageData['senderId'] == _auth.currentUser?.uid;

                          // Obtenha o timestamp e formate a hora
                          Timestamp? timestamp = messageData['timestamp'] as Timestamp?;
                          String formattedTime = '';
                          if (timestamp != null) {
                            DateTime date = timestamp.toDate().toLocal();
                            formattedTime = DateFormat('HH:mm').format(date);
                          }

                          final isRead = messageData['isRead'] ?? false;

                          return MessageBubble(
                            message: messageContent,
                            isUser: isUser,
                            time: formattedTime,
                            isRead: isRead,
                          );
                        }).toList(),
                      ],
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    maxLines: 3, // Limita o campo de texto a no máximo 3 linhas
                    minLines: 1, // Começa com 1 linha
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: _isSending ? Colors.grey : Colors.blue),
                  onPressed: _isSending
                      ? null
                      : () async {
                    _sendMessage();
                    _scrollToBottom();
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) { // Verifica se a mensagem não é apenas espaços
      final user = _auth.currentUser;
      if (user != null) {
        try {
          // Desativa o botão de envio (se necessário)
          setState(() {
            _isSending = true;
          });

          // Envia a mensagem
          await _messageService.sendMessage(
            senderId: user.uid,
            receiverName: _receiverName,
            receiverProfileUrl: _receiverProfileImageUrl,
            content: _messageController.text.trim(),
            receiverId: widget.otherUserId,
            timestamp: FieldValue.serverTimestamp(),
            isRead: false,
          );

          // Limpa o campo de entrada
          _messageController.clear();
        } catch (e) {
          // Notifica o usuário em caso de erro
          _showErrorSnackBar("Erro ao enviar mensagem. Tente novamente.");
        } finally {
          // Reativa o botão de envio
          setState(() {
            _isSending = false;
          });
        }
      } else {
        _showErrorSnackBar("Usuário não autenticado. Faça login novamente.");
      }
    }
  }
  String _generateConversationId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode ? '${user1}_$user2' : '${user2}_$user1';
  }
}
