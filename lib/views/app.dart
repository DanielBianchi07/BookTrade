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
//import 'newaccount.page.dart';
//import 'chats.page.dart';
//import 'chat.page.dart';

class BookTradeApp extends StatelessWidget {
  const BookTradeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const SplashScreen(), // Definindo a tela inicial como SplashScreen
      routes: {
        "/login": (context) => const LoginPage(),
        "/home": (context) => const HomePage(),
        "/favoriteBooks": (context) => const FavoriteBooksPage(),
        "/publicatedBooks": (context) => const PublicatedBooksPage(),
        "/editProfile": (context) => EditProfilePage(),
        "/tradeOffer": (context) => const TradeOfferPage(),
        "/register": (context) => const RegistrationPage(),
        "/tradeHistory": (context) => const TradeHistoryPage(),
        "/newBook": (context) => const BookRegistrationPage(),
        "/notifications": (context) => const NotificationsPage(),
        "/tradeStatus": (context) => const TradeStatusPage(),
        //"/new-account": (context) => NewAccountPage(),
        "/chats":(context) => const ChatsPage(),
        "/chat":(context) => const ChatPage(),
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
    // Aguarde 3 segundos e depois navegue para a tela de login
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8D5B3), // Cor de fundo semelhante à imagem fornecida
      body: Center(
        child: Image.asset(
          'assets/logo_transparent.png', // Substitua pelo caminho correto do seu logo
          height: 200, // Ajuste a altura conforme necessário
        ),
      ),
    );
  }
}
