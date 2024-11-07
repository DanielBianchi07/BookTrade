import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/message.model.dart';

class ChatsService {
  final CollectionReference messagesCollection = FirebaseFirestore.instance.collection('messages');
  final CollectionReference conversationsCollection = FirebaseFirestore.instance.collection('conversations');

  // Obter a última mensagem de uma conversa específica
  Future<MessageModel?> getLastMessage(String conversationId) async {
    try {
      final conversationDoc = await conversationsCollection.doc(conversationId).get();
      if (conversationDoc.exists) {
        final lastMessageId = conversationDoc.get('lastMessageId');
        final lastMessageDoc = await messagesCollection.doc(lastMessageId).get();
        return lastMessageDoc.exists ? MessageModel.fromDocument(lastMessageDoc) : null;
      } else {
        return null;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Erro ao obter a última mensagem.');
      return null;
    }
  }
}
