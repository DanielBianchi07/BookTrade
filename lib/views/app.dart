import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat.page.dart';
import 'chats.page.dart';
import 'edit.profile.page.dart';
import 'favorite.books.page.dart';
import 'favorite.genres.page.dart';
import 'home.page.dart';
import 'new.book.page.dart';
import 'notifications.page.dart';
import 'publicated.books.page.dart';
import 'selected.book.page.dart';
import 'login.page.dart';
import 'register.page.dart';
import 'trade.history.page.dart';
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
        // Remova a rota nomeada para `TradeOfferPage`, pois ela requer um argumento:
        // "/tradeOffer": (context) => TradeOfferPage(),
        "/register": (context) => RegistrationPage(),
        "/tradeHistory": (context) => TradeHistoryPage(),
        "/newBook": (context) => NewBookPage(),
        "/notifications": (context) => NotificationsPage(),
        "/tradeStatus": (context) => TradeStatusPage(),
        "/chats": (context) => ChatsPage(),
        "/favoriteGenres": (context) => FavoriteGenresPage(),
      },
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.active) {
            return snapshot.data == null ? LoginPage() : HomePage();
          } else {
            return SplashScreen();
          }
        },
      ),
      onGenerateRoute: (settings) {
        if (settings.name == '/notificationDetail') {
          final args = settings.arguments as Map<String, String>;

          return MaterialPageRoute(
            builder: (context) {
              return NotificationDetailPage(
                title: args['title'] ?? 'Notificação',
                message: args['message'] ?? 'Sem mensagem',
                time: args['time'] ?? 'Sem data',
              );
            },
          );
        }
        if (settings.name == '/chat') {
          final args = settings.arguments as Map<String, dynamic>?;
          final receiverUserId = args?['receiverUserId'] as String?;

          // Verificação de null antes de navegar
          if (receiverUserId != null) {
            return MaterialPageRoute(
              builder: (context) => ChatPage(
                otherUserId: receiverUserId,
              ),
            );
          } else {
            // Caso o recipientUserId seja null
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                body: Center(
                  child: Text("Usuário de destino não encontrado."),
                ),
              ),
            );
          }
        }
        return null; // Adicione outras rotas dinâmicas aqui, se necessário
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Adicionar um delay para mostrar a tela de carregamento
    Future.delayed(const Duration(seconds: 3), () {
      // Aqui o StreamBuilder no home do MaterialApp já redireciona
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8D5B3),
      body: Center(
        child: Image.asset(
          'assets/logo_transparent.png',
          height: 200,
        ),
      ),
    );
  }
}
