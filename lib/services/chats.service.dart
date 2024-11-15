import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myapp/services/firebase.service.dart';
import '../models/message.model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  Future<void> sendImageMessage(
      {required String senderId,
      required String receiverId,
      required String receiverName,
      required String receiverProfileUrl,
      required XFile image, // Recebe o XFile da imagem
      required Timestamp timestamp}) async {
    try {
      final String imageName = DateTime.now().millisecondsSinceEpoch.toString();
      final Reference storageReference =
          FirebaseStorage.instance.ref().child('chat_images/$imageName');

      // Upload da imagem
      final UploadTask uploadTask = storageReference.putFile(File(image.path));
      await uploadTask;
      final String imageUrl = await storageReference.getDownloadURL();

      // Salva a mensagem com a URL da imagem
      await sendMessage(
        senderId: senderId,
        receiverId: receiverId,
        receiverName: receiverName,
        receiverProfileUrl: receiverProfileUrl,
        content: '', // Mensagem vazia, pois a imagem é o conteúdo principal
        imageUrl: imageUrl, // Adiciona a URL da imagem
        timestamp: timestamp
      );
    } catch (e) {
      print('Erro ao enviar mensagem de imagem: $e');
      // Lidar com o erro (exibir mensagem, etc.)
    }
  }

  Future<void> sendMessage({
      required String senderId,
      required String receiverId,
      required String receiverName,
      required String receiverProfileUrl,
      required String content,
      String? imageUrl,  // Parâmetro opcional para a URL da imagem
      required timestamp,
    }) async {
      try {
        final conversationId = _generateConversationId(senderId, receiverId);
        final newMessage = MessageModel(
          id: '',
          senderId: senderId,
          receiverId: receiverId,
          content: content,
          timestamp: timestamp,
          receiverName: receiverName,
          receiverProfileUrl: receiverProfileUrl,
          imageUrl: imageUrl, // Inclui a URL da imagem, se fornecida
        );

        final docRef = await messagesCollection.add(newMessage.toMap());
        final messageId = docRef.id;

        // Atualiza o lastMessageId na conversa
        await FirebaseFirestore.instance
            .collection('conversations')
            .doc(conversationId)
            .update({'lastMessageId': messageId});
      } catch (e) {
        print('Erro ao enviar mensagem: $e');
        // Lide com o erro adequadamente (exiba uma mensagem para o usuário, etc.)
    }
  }
  String _generateConversationId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode
        ? '${user1}_$user2'
        : '${user2}_$user1';
  }
}