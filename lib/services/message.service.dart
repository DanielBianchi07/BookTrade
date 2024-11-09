// lib/services/message_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.model.dart';
import 'firebase.service.dart';

class MessageService {
  final CollectionReference messagesCollection = FirebaseService.firestore.collection('messages');
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final CollectionReference conversationsCollection = FirebaseFirestore.instance.collection('conversations');

  MessageService() {
    _initializeNotifications();
  }

  // Inicializar configurações de notificações
  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Enviar uma nova mensagem e atualizar a coleção `conversations`
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String receiverName,
    required String receiverProfileUrl,
    required String content,
    required FieldValue timestamp,
  }) async {
    try {
      final conversationId = await getConversationId(senderId, receiverId);

      // Cria a nova mensagem na coleção `messages`
      final newMessage = await messagesCollection.add({
        'conversationId': conversationId,
        'senderId': senderId,
        'receiverId': receiverId,
        'receiverName': receiverName,
        'receiverProfileUrl': receiverProfileUrl,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Atualiza o documento na coleção `conversations`
      await conversationsCollection.doc(conversationId).set({
        'participants': conversationId,  // Usando o ID combinado
        'lastMessageId': newMessage.id,
        'timestamp': timestamp,
      }, SetOptions(merge: true));
    } catch (e) {
      Fluttertoast.showToast(msg: 'Erro ao enviar mensagem e atualizar conversa: $e');
    }
  }

  Future<String> getConversationId(String senderId, String receiverId) async {
    try {
      // Gera o ID de conversa único e ordenado
      String conversationId = mergeConversationId(senderId, receiverId);

      final querySnapshot = await conversationsCollection
          .where('conversationId', isEqualTo: conversationId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      } else {
        throw Exception('Conversa não encontrada');
      }
    } catch (e) {
      throw Exception('Erro ao obter conversa: $e');
    }
  }

  // Função para gerar um ID de conversa consistente entre dois usuários
  String mergeConversationId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode ? '${user1}_$user2' : '${user2}_$user1';
  }

  // Obter a stream de mensagens entre o usuário atual e o usuário de destino
  Stream<QuerySnapshot> getMessagesStream(String conversationId) {
    return messagesCollection
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Obter últimas mensagens de todas as conversas do usuário e marcar como lidas
  Stream<List<MessageModel>> getLastMessagesStream(String userId) async* {
    try {
      // Recupera mensagens do cache e emite primeiro
      final cachedMessages = await _getCachedMessages();
      if (cachedMessages.isNotEmpty) yield cachedMessages;

      // Atualiza o cache e emite as novas mensagens do Firestore em tempo real
      await for (var snapshot in messagesCollection
          .where('participants', arrayContains: userId)
          .orderBy('timestamp', descending: true)
          .snapshots()) {
        final uniqueMessages = <String, QueryDocumentSnapshot>{};

        for (var doc in snapshot.docs) {
          final otherUserId = doc['senderId'] == userId ? doc['receiverId'] : doc['senderId'];
          if (!uniqueMessages.containsKey(otherUserId)) {
            uniqueMessages[otherUserId] = doc;
          }

          // Marcar mensagens não lidas como lidas
          if (!doc['read']) {
            await messagesCollection.doc(doc.id).update({'read': true});
          }
        }

        final lastMessages = uniqueMessages.values.map((msg) => MessageModel.fromDocument(msg)).toList();

        // Atualizar o cache
        await _cacheMessages(lastMessages);

        yield lastMessages;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Erro ao carregar mensagens.');
      yield [];
    }
  }

  // Função para armazenar mensagens em cache
  Future<void> _cacheMessages(List<MessageModel> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final messagesToCache = messages.map((msg) => msg.id).toList();
    await prefs.setStringList('cachedMessages', messagesToCache);
  }

  // Função para recuperar mensagens do cache
  Future<List<MessageModel>> _getCachedMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedMessageIds = prefs.getStringList('cachedMessages') ?? [];
    if (cachedMessageIds.isEmpty) return [];

    final List<MessageModel> cachedMessages = [];
    for (var messageId in cachedMessageIds) {
      final doc = await messagesCollection.doc(messageId).get();
      if (doc.exists) cachedMessages.add(MessageModel.fromDocument(doc));
    }

    return cachedMessages;
  }

}
