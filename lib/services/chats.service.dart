import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myapp/services/firebase.service.dart';
import '../models/message.model.dart';

class ChatsService {
  final CollectionReference messagesCollection = FirebaseFirestore.instance.collection('messages');
  final CollectionReference conversationsCollection = FirebaseService.firestore.collection('conversations');


  Future<void> newChat({
    required String senderId,
    required String receiverId,
    String? lastMessageId,
    required timestamp,
  }) async {
    try {
      // Gera um ID de conversa consistente
      final participantsIds = mergeConversationId(senderId, receiverId);

      // Verificar se já existe uma conversa com os mesmos participantes
      final querySnapshot = await conversationsCollection
          .where('participants', isEqualTo: participantsIds)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        print('Conversa já existe, não é necessário criar uma nova.');
        return;
      }

      // Cria um novo documento na coleção `conversations`
      await conversationsCollection.add({
        'participants': participantsIds,  // Usando o ID combinado
        'lastMessageId': lastMessageId ?? '',
        'timestamp': timestamp,
      });
    } catch (e) {
      print('Erro ao criar novo chat: $e');
    }
  }

  String mergeConversationId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode ? '${user1}_$user2' : '${user2}_$user1';
  }

  // Obter a última mensagem de uma conversa específica
  Future<MessageModel?> getLastMessage(String conversationId) async {
    try {
      final conversationDoc = await conversationsCollection.doc(conversationId).get();
      if (conversationDoc.exists) {
        final lastMessageId = conversationDoc.get('lastMessageId');
        if (lastMessageId != null && lastMessageId.isNotEmpty) {
          final lastMessageDoc = await messagesCollection.doc(lastMessageId).get();
          return lastMessageDoc.exists ? MessageModel.fromDocument(lastMessageDoc) : null;
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Erro ao obter a última mensagem.');
      return null;
    }
  }
}
