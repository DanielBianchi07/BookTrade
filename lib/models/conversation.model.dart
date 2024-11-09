import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationModel {
  final String id;
  final String? lastMessageId;
  final String participants;
  final Timestamp timestamp;
  final String otherUserName; // Nome do outro usuário na conversa
  final String otherUserImage; // URL da imagem do outro usuário

  ConversationModel({
    required this.id,
    this.lastMessageId,
    required this.participants,
    required this.timestamp,
    required this.otherUserName,
    required this.otherUserImage,
  });

  // Converte um documento do Firestore em um `ConversationModel`
  factory ConversationModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ConversationModel(
      id: doc.id,
      lastMessageId: data['lastMessageId'],
      participants: data['participants'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      otherUserName: data['otherUserName'] ?? 'Usuário',
      otherUserImage: data['otherUserImage'] ?? '',
    );
  }

  // Converte `ConversationModel` para um mapa para o Firestore
  Map<String, dynamic> toMap() {
    return {
      'lastMessageId': lastMessageId,
      'participants': participants,
      'timestamp': timestamp,
      'otherUserName': otherUserName,
      'otherUserImage': otherUserImage,
    };
  }
}
