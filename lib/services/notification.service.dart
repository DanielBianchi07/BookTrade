import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  NotificationService() {
    _initialize();
  }

  void _initialize() {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'your_channel_id', 'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);
    await _flutterLocalNotificationsPlugin.show(
      0, // ID da notificação
      title,
      body,
      platformDetails,
    );
  }

  /// Função para excluir uma notificação pelo ID
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
      print('Notificação excluída com sucesso.');
    } catch (e) {
      print('Erro ao excluir a notificação: $e');
      throw Exception('Erro ao excluir a notificação');
    }
  }
}
