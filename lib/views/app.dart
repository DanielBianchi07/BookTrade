import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat.page.dart';
import 'chats.page.dart';
import 'edit.profile.page.dart';
import 'favorite.books.page.dart';
import 'home.page.dart';
import 'new.book.page.dart';
import 'notifications.page.dart';
import 'publicated.books.page.dart';
import 'login.page.dart';
import 'register.page.dart';
import 'trade.history.page.dart';
import 'trade.offer.page.dart';
import 'trade.status.page.dart';

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
        "/editProfile": (context) => EditProfilePage(),
        "/tradeOffer": (context) => TradeOfferPage(),
        "/register": (context) => RegistrationPage(),
        "/tradeHistory": (context) => TradeHistoryPage(),
        "/newBook": (context) => BookRegistrationPage(),
        "/notifications": (context) => NotificationsPage(),
        "/tradeStatus": (context) => TradeStatusPage(),
        "/chats":(context) => const ChatsPage(),
        "/chat":(context) => const ChatPage(),
      },
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            // Se o usuário não estiver autenticado, redirecionar para a tela de login
            return snapshot.data == null ? LoginPage() : HomePage();
          } else {
            // Mostrar uma tela de carregamento enquanto a conexão está sendo estabelecida
            return SplashScreen();
          }
        },
      ),
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
    Future.delayed(Duration(seconds: 3), () {
      // Aqui o StreamBuilder no home do MaterialApp já redireciona
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD8D5B3), // Cor de fundo semelhante à imagem fornecida
      body: Center(
        child: Image.asset(
          'assets/logo_transparent.png', // Substitua pelo caminho correto do seu logo
          height: 200, // Ajuste a altura conforme necessário
        ),
      ),
    );
  }
}
