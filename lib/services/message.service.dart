// lib/services/message_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase.service.dart';

class MessageService {
  final CollectionReference messagesCollection =
  FirebaseService.firestore.collection('messages');

  // Enviar uma nova mensagem para o Firestore
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String senderName,
    required String senderProfileUrl,
    required String content,
    required List<String> participants,
    required FieldValue timestamp,
  }) async {
    await messagesCollection.add({
      'senderId': senderId,
      'senderName': senderName,
      'senderProfileUrl': senderProfileUrl,
      'content': content,
      'receiverId': receiverId,
      'participants': participants,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Obter a stream de mensagens
  Stream<QuerySnapshot> getMessagesStream() {
    return messagesCollection.orderBy('timestamp').snapshots();
  }

}
