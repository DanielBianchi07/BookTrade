import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Para o tipo Timestamp

class ChatTile extends StatelessWidget {
  final String contactName;
  final String lastMessage;
  final dynamic time;
  final String avatarUrl;
  final String senderId;
  final String currentUserId;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final int unreadCount;

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
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentUserSender = senderId == currentUserId;

    // Função para formatar a data
    String formatTime(dynamic time) {
      try {
        if (time is Timestamp) {
          final dateTime = time.toDate(); // Converte Timestamp para DateTime
          final now = DateTime.now();

          if (DateUtils.isSameDay(dateTime, now)) {
            return DateFormat('HH:mm').format(dateTime); // Retorna horário se for hoje
          } else if (DateUtils.isSameDay(dateTime, now.subtract(const Duration(days: 1)))) {
            return 'Ontem'; // Retorna "Ontem" se for o dia anterior
          } else {
            return DateFormat('dd/MM/yyyy').format(dateTime); // Retorna data completa para outros dias
          }
        } else if (time is DateTime) {
          // Caso já seja DateTime, formata diretamente
          final now = DateTime.now();

          if (DateUtils.isSameDay(time, now)) {
            return DateFormat('HH:mm').format(time); // Retorna horário se for hoje
          } else if (DateUtils.isSameDay(time, now.subtract(const Duration(days: 1)))) {
            return 'Ontem'; // Retorna "Ontem" se for o dia anterior
          } else {
            return DateFormat('dd/MM/yyyy').format(time); // Retorna data completa para outros dias
          }
        } else {
          return ''; // Retorna vazio caso não seja um tipo válido
        }
      } catch (e) {
        return ''; // Em caso de erro, retorna vazio
      }
    }

    final formattedTime = formatTime(time);

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
          maxLines: 1, // Limita o texto a uma linha
          overflow: TextOverflow.ellipsis, // Adiciona "..." no final se o texto for longo
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (unreadCount > 0)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF77C593), // Cor do círculo
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadCount.toString(),
                  style: const TextStyle(color: Colors.black, fontSize: 12), // Número preto
                ),
              ),
            const SizedBox(width: 8), // Espaçamento entre o ícone e a data
            Text(
              formattedTime,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Excluir Conversa'),
                      content: const Text(
                        'Tem certeza de que deseja excluir esta conversa? Esta ação não poderá ser desfeita, '
                            'a menos que você faça uma nova solicitação de troca para esta pessoa.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Fecha o popup
                          },
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Fecha o popup
                            onDelete(); // Executa a ação de exclusão
                          },
                          child: const Text(
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
