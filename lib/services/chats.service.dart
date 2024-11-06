import 'package:cloud_firestore/cloud_firestore.dart';


class ChatsService {
  final CollectionReference messagesCollection = FirebaseFirestore.instance.collection('messages');

  // Obter as últimas mensagens únicas de cada conversa
  Stream<List<QueryDocumentSnapshot>> getLastMessagesStream(String userId) {
    return messagesCollection
        .where('participants', arrayContains: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      final uniqueConversations = <String, QueryDocumentSnapshot>{};

      for (var doc in snapshot.docs) {
        final otherUserId = doc['senderId'] == userId ? doc['receiverId'] : doc['senderId'];
        if (!uniqueConversations.containsKey(otherUserId)) {
          uniqueConversations[otherUserId] = doc;
        }
      }

      return uniqueConversations.values.toList();
    });
  }
}
