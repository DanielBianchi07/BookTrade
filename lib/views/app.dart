import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:myapp/views/trade.history.page.dart';
import '../user.dart';
import 'chats.page.dart';
import 'edit.profile.page.dart';
import 'exchanged.book.details.page.dart';
import 'favorite.books.page.dart';
import 'favorite.genres.page.dart';
import 'home.page.dart';
import 'new.book.page.dart';
import 'notifications.page.dart';
import 'publicated.books.page.dart';
import 'selected.book.page.dart';
import 'login.page.dart';
import 'register.page.dart';
import 'exchange.tracking.page.dart';
import 'trade.status.page.dart';
import 'notification.detail.page.dart'; // Importe a tela de detalhes de notificação

class BookTradeApp extends StatelessWidget {
  const BookTradeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      routes: {
        "/login": (context) => LoginPage(),
        "/home": (context) => HomePage(),
        "/favoriteBooks": (context) => FavoriteBooksPage(),
        "/publicatedBooks": (context) => PublicatedBooksPage(),
        "/selectedBook": (context) => SelectedBookPage(),
        "/editProfile": (context) => EditProfilePage(),
        "/register": (context) => RegistrationPage(),
        "/tradeHistory": (context) => TradeHistoryPage(),
        "/exchangeTracking": (context) => ExchangeTrackingPage(),
        "/newBook": (context) => NewBookPage(),
        "/notifications": (context) => NotificationsPage(),
        "/tradeStatus": (context) => TradeStatusPage(),
        "/chats": (context) => ChatsPage(),
        "/favoriteGenres": (context) => FavoriteGenresPage(),
      },
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.active) {
            if (FirebaseAuth.instance.currentUser != null) {
              user.value.uid = FirebaseAuth.instance.currentUser!.uid;
              return snapshot.data == null ? LoginPage() : HomePage();
            } else {
              return snapshot.data == null ? LoginPage() : HomePage();
            }
          } else {
            return const Center(child: Text("Erro ao carregar o estado do usuário."));
          }
        },
      ),
      onGenerateRoute: (settings) {
        if (settings.name == '/notificationDetail') {
          final args = settings.arguments as Map<String, String>;

          return MaterialPageRoute(
            builder: (context) {
              return NotificationDetailPage(
                notificationId: args['id'] ?? '',
                title: args['title'] ?? 'Notificação',
                message: args['message'] ?? 'Sem mensagem',
                time: args['time'] ?? 'Sem data',
              );
            },
          );
        } else if (settings.name == '/exchangedBookDetails') {
          final requestId = settings.arguments as String;

          return MaterialPageRoute(
            builder: (context) {
              return ExchangedBookDetailsPage(requestId: requestId);
            },
          );
        }
        return null; // Adicione outras rotas dinâmicas aqui, se necessário
      },
    );
  }
}