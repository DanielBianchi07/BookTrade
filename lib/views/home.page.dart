import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myapp/controller/login.controller.dart';
import 'package:myapp/views/trade.offer.page.dart';

import '../models/book.dart';
import '../user.dart';
import 'login.page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Chave global para acessar o Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final loginController = new LoginController();
  var busy = false;

  handleSignOut() {
    setState(() {
      busy = true;
    });
    loginController.logout().then((data) {
      onSuccess();
    }).catchError((err) {
      // Verifica o tipo da exceção para tratá-la corretamente
      if (err is FirebaseAuthException) {
        onError("Erro de autenticação: ${err.message}");
      } else {
        onError("Erro inesperado: $err");
      }
    }).whenComplete(() {
      onComplete();
    });
  }

  onSuccess() {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage(),
        ),
    );
  }

  onError(err) {
    Fluttertoast.showToast(
      msg: err,
      toastLength: Toast.LENGTH_LONG,
    );
  }

  onComplete() {
    setState(() {
      busy = false;
    });
  }

  // Lista para gerenciar o estado dos corações (favoritados ou não)
  List<Book> books = []; // Lista de livros
  List<bool> favoriteStatus = []; // Status dos favoritos

  @override
  void initState() {
    super.initState();
    _loadBooks(); // Carrega os livros quando a página é inicializada
  }

  Future<void> _loadBooks() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('books').get();
      setState(() {
        books = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Book(
            uid:user.uid,
            id: doc.id,
            title: data['title'] ?? '',
            author: data['author'] ?? '',
            imageUrl: data['imageUrl'] ?? 'https://via.placeholder.com/100',
            publishedDate: DateTime.now(), // Atualize conforme necessário
            postedBy: null, // Você pode atualizar conforme necessário
            profileImageUrl: null, // Você pode atualizar conforme necessário
            rating: null, // Substitua por uma nota real se disponível
          );
        }).toList();
        favoriteStatus = List.generate(books.length, (_) => false); // Inicializa o status de favoritos
      });
    } catch (e) {
      print('Erro ao carregar livros: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFD8D5B3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green, width: 1.5),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.grey, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar...',
                        hintStyle: TextStyle(fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            const Row(
              children: [
                Icon(Icons.location_on, color: Colors.green, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Endereço 1 - Bairro',
                    style: TextStyle(color: Colors.black, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: const Color(0xFFD8D5B3),
              padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 16.0),
              child: Stack(
                children: [
                  Column(
                    children: [
                      const Center(
                        child: CircleAvatar(
                          backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
                          radius: 40,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Fulano da Silva',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Address',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return const Icon(Icons.star, color: Colors.amber, size: 18);
                        }),
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/editProfile');
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.book, color: Colors.black),
              title: const Text('Meus livros'),
              onTap: () {
                Navigator.pushNamed(context, '/publicatedBooks');
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.black),
              title: const Text('Histórico de trocas'),
              onTap: () {
                Navigator.pushNamed(context, '/tradeHistory');
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications, color: Colors.black),
              title: const Text('Notificações'),
              onTap: () {
                Navigator.pushNamed(context, '/notifications');
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz, color: Colors.black),
              title: const Text('Status de trocas'),
              onTap: () {
                Navigator.pushNamed(context, '/tradeStatus');
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite, color: Colors.black),
              title: const Text('Lista de desejos'),
              onTap: () {
                Navigator.pushNamed(context, '/favoriteBooks');
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.black),
              title: const Text('Chat'),
              onTap: () {
                Navigator.pushNamed(context, '/chats');
              },
            ),
            const Spacer(),
            ListTile(
              title: const Text(
                'Sair',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recomendados:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            books.isEmpty
                ? const Center(child: CircularProgressIndicator()) // Exibe um carregador enquanto os livros não são carregados
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return InkWell(
                  onTap: () {
                    // Navegando para a TradeOfferPage e passando o livro selecionado
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TradeOfferPage(book: book),
                      ),
                    );
                  },
                  child: BookCard(
                    title: book.title,
                    author: book.author,
                    postedBy: book.postedBy ?? 'Desconhecido',
                    imageUrl: book.imageUrl,
                    profileImageUrl: book.profileImageUrl ?? 'https://via.placeholder.com/50',
                    isFavorite: favoriteStatus[index],
                    rating: book.rating ?? 0.0,
                    onFavoritePressed: () {
                      setState(() {
                        favoriteStatus[index] = !favoriteStatus[index];
                      });
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'Perto de você:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Aqui você pode adicionar outra lista de livros, se necessário
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/newBook');
        },
        backgroundColor: const Color(0xFF77C593),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  final String title;
  final String author;
  final String postedBy;
  final String imageUrl;
  final String profileImageUrl;
  final bool isFavorite;
  final double rating;
  final VoidCallback onFavoritePressed;

  const BookCard({super.key,
    required this.title,
    required this.author,
    required this.postedBy,
    required this.imageUrl,
    required this.profileImageUrl,
    required this.isFavorite,
    required this.rating,
    required this.onFavoritePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(
          color: Colors.grey.shade400, // Adiciona a borda à caixa do livro
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Imagem do livro
                Image.network(
                  imageUrl,
                  height: 100,
                  width: 80,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 16),

                // Informações do livro
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        author,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Postado por:',
                        style: TextStyle(fontSize: 12),
                      ),
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(profileImageUrl),
                            radius: 15,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            postedBy,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Estrelas de avaliação
                      RatingBarIndicator(
                        rating: rating,
                        itemBuilder: (context, index) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 18.0,
                        direction: Axis.horizontal,
                      ),
                    ],
                  ),
                ),

                // Botão de coração
                IconButton(
                  onPressed: onFavoritePressed,
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.green, // Ícone de coração na cor verde
                    size: 24,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}