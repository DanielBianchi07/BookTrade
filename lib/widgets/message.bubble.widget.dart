// lib/widgets/message_bubble.dart
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final String time;
  final String? imageUrl;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isUser,
    required this.time,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.green : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Exibe a imagem se imageUrl não for nulo
            if (imageUrl != null)
              Image.network(
                imageUrl!,
                width: 200, // Ajuste a largura conforme necessário
                height: 200, // Ajuste a altura conforme necessário
                fit: BoxFit.cover,
              ),
            if (message.isNotEmpty) // Só exibe o texto se houver mensagem de texto
              Text(
                  message,
                  style: TextStyle(color: isUser ? Colors.white : Colors.black),
                ),
            Text(
              time,
              style: TextStyle(
                fontSize: 12,
                color: isUser ? Colors.white70 : Colors.black54,
              ),
            ),

          ],
        ),
      ),
    );
  }
}