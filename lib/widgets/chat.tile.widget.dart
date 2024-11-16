// lib/widgets/chat_tile.dart
import 'package:flutter/material.dart';

class ChatTile extends StatelessWidget {
  final String contactName;
  final String lastMessage;
  final String time;
  final String avatarUrl;
  final String senderId;
  final String currentUserId;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ChatTile({
    super.key,
    required this.contactName,
    required this.lastMessage,
    required this.time,
    required this.avatarUrl,
    required this.senderId,
    required this.currentUserId,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Determina quem enviou a última mensagem
    final isCurrentUserSender = senderId == currentUserId;
    final senderName = isCurrentUserSender ? 'Você' : contactName;
    return InkWell(
      onTap: onTap,
      child: ListTile(
        tileColor: const Color(0xFFE8E8E8),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(avatarUrl),
        ),
        title: Text(contactName),
        subtitle: Text(
          isCurrentUserSender ? 'Você: $lastMessage' : lastMessage,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(time),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Excluir Conversa'),
                      content: Text(
                        'Tem certeza de que deseja excluir esta conversa? Esta ação não poderá ser desfeita, '
                            'a menos que você faça uma nova solicitação de troca para esta pessoa.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Fecha o popup
                          },
                          child: Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Fecha o popup
                            onDelete(); // Executa a ação de exclusão
                          },
                          child: Text(
                            'Excluir',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
