import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationModel {
  final String id;
  final String? lastMessageId;
  final String participants;
  final Timestamp timestamp;
  final String otherUserName;
  final String otherUserImage;
  final bool isActiveForUser1;
  final bool isActiveForUser2;

  ConversationModel({
    required this.id,
    this.lastMessageId,
    required this.participants,
    required this.timestamp,
    required this.otherUserName,
    required this.otherUserImage,
    required this.isActiveForUser1,
    required this.isActiveForUser2,
  });

  factory ConversationModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ConversationModel(
      id: doc.id,
      lastMessageId: data['lastMessageId'],
      participants: data['participants'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      otherUserName: data['otherUserName'] ?? 'Usuário',
      otherUserImage: data['otherUserImage'] ?? '',
      isActiveForUser1: data['isActiveForUser1'] ?? true,
      isActiveForUser2: data['isActiveForUser2'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lastMessageId': lastMessageId,
      'participants': participants,
      'timestamp': timestamp,
      'otherUserName': otherUserName,
      'otherUserImage': otherUserImage,
      'isActiveForUser1': isActiveForUser1,
      'isActiveForUser2': isActiveForUser2,
    };
  }
}