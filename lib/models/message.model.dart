import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final Timestamp timestamp;
  final String receiverName;
  final String receiverProfileUrl;
  final String? imageUrl; // Novo campo para URL da imagem

   MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.receiverName,
    required this.receiverProfileUrl,
    this.imageUrl,
  });

  factory MessageModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      senderId: data['senderId'],
      receiverId: data['receiverId'],
      content: data['content'],
      timestamp: data['timestamp'],
      receiverName: data['receiverName'],
      receiverProfileUrl: data['receiverProfileUrl'],
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp,
      'receiverName': receiverName,
      'receiverProfileUrl': receiverProfileUrl,
      'imageUrl': imageUrl,
    };
  }
}
