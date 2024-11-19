import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/firebase_options.dart';
import 'package:myapp/views/app.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'services/notification.service.dart';

void setupFirebaseMessaging(String userId) async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Solicitar permissão para notificações
  NotificationSettings settings = await messaging.requestPermission();

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    // Obter o token FCM atual
    String? token = await messaging.getToken();

    if (token != null) {
      print("Token FCM: $token");

      // Salvar o token no Firestore ou backend
      await updateTokenInBackend(userId, token);
    }

    // Listener para capturar mudanças no token
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print("Token renovado: $newToken");

      // Atualizar o token no Firestore ou backend
      await updateTokenInBackend(userId, newToken);
    });
  }

  // Configurar o recebimento de mensagens
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      print("Notificação recebida: ${message.notification!.title}");
      // Exemplo: Exibir uma notificação local
      NotificationService().showNotification(
        message.notification!.title ?? "Nova Notificação",
        message.notification!.body ?? "",
      );
    }
  });
}

Future<void> updateTokenInBackend(String userId, String? token) async {
  if (token != null) {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .set({'deviceToken': token}, SetOptions(merge: true));
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user != null) {
      // Configura notificações para o usuário logado
      setupFirebaseMessaging(user.uid);
    } else {
      print("Usuário não autenticado");
    }
  });
  //await FirebaseAppCheck.instance.activate();

  runApp(BookTradeApp());
}
