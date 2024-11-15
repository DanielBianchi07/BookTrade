import 'package:flutter/material.dart';

class ChatTile extends StatelessWidget {
  final String contactName;
  final String lastMessage;
  final String time;
  final String avatarUrl;
  final VoidCallback onTap;

  const ChatTile({
    super.key,
    required this.contactName,
    required this.lastMessage,
    required this.time,
    required this.avatarUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ListTile(
        tileColor: const Color(0xFFE8E8E8),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(avatarUrl),
        ),
        title: Text(contactName),
        subtitle: Text(lastMessage),
        trailing: Text(time),
      ),
    );
  }
}