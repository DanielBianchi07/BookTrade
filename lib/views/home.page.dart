import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myapp/controller/login.controller.dart';
import 'package:myapp/views/trade.offer.page.dart';
import '../models/book.dart';
import '../models/user_info.dart';
import '../user.dart';
import '../widgets/bookcard.widget.dart';
import 'login.page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Chave global para acessar o Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final loginController = LoginController();
  var busy = false;
  List<BookModel> books = [];
  List<bool> favoriteStatus = [];

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

  @override
  void initState() {
    super.initState();
    _loadBooks(); // Carrega os livros quando a página é inicializada
  }

  Future<void> _loadBooks() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('books').get();
      final userId = FirebaseAuth.instance.currentUser?.uid;

      // Inicialize uma lista de favoritos
      List<String> favoriteBooks = [];

      // Se o usuário estiver logado, busque os livros favoritados
      if (userId != null) {
        QuerySnapshot favoritesSnapshot = await FirebaseFirestore.instance
            .collection('favorites')
            .doc(userId)
            .collection('userFavorites')
            .get();

        favoriteBooks = favoritesSnapshot.docs.map((doc) => doc.id).toList();
      }

      setState(() {
        books = snapshot.docs
            .where((doc) => (doc.data() as Map<String, dynamic>)['userId'] != userId)
            .map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return BookModel(
            userId: data['userId'] ?? '', // Adiciona valor padrão se for null
            id: doc.id,
            title: data['title'] ?? 'Título não disponível', // Valor padrão
            author: data['author'] ?? 'Autor desconhecido', // Valor padrão
            imageUserUrl: data['imageUserUrl'] ?? '', // Valor padrão
            imageApiUrl: data['imageApiUrl'],
            publishedDate: (data['publishedDate'] as Timestamp?)?.toDate() ?? DateTime.now(), // Valor padrão para publishedDate
            condition: data['condition'] ?? 'Condição não disponível', // Valor padrão
            edition: data['edition'] ?? 'Edição não disponível', // Valor padrão
            genres: data['genres'] != null ? List<String>.from(data['genres']) : [], // Lista vazia se null
            isbn: data['isbn'],
            publicationYear: data['publicationYear'] ?? 'Ano de publicação não disponível', // Valor padrão
            publisher: data['publisher'] ?? 'Editora não disponível', // Valor padrão
            userInfo: UInfo.fromMap(data['userInfo'] ?? {}), // Constrói userInfo com um map vazio se null
          );
        }).toList();

        favoriteStatus = List.generate(books.length, (index) => favoriteBooks.contains(books[index].id));
      });
    } catch (e) {
      print('Erro ao carregar livros: $e');
    }
  }

  void toggleFavoriteStatus(String bookId, int index) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return; // Certifique-se de que o usuário está logado

    // Alterna o estado local
    setState(() {
      favoriteStatus[index] = !favoriteStatus[index];
    });

    try {
      if (favoriteStatus[index]) {
        // Adiciona aos favoritos
        await FirebaseFirestore.instance
            .collection('favorites')
            .doc(userId)
            .collection('userFavorites')
            .doc(bookId)
            .set({
          'isFavorite': true,
        });
      } else {
        // Remove dos favoritos
        await FirebaseFirestore.instance
            .collection('favorites')
            .doc(userId)
            .collection('userFavorites')
            .doc(bookId)
            .delete();
      }

    } catch (e) {
      print('Erro ao atualizar favoritos: $e');
      // Reverte a mudança em caso de erro
      setState(() {
        favoriteStatus[index] = !favoriteStatus[index]; // Reverte o estado local
      });
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
                    id: book.id,
                    userId: book.userId,
                    title: book.title,
                    author: book.author,
                    imageUserUrl: book.imageUserUrl,
                    postedBy: book.userInfo.name,
                    profileImageUrl: book.userInfo.profileImageUrl,
                    customerRating: book.userInfo.customerRating,
                    isFavorite: favoriteStatus[index],
                    onFavoritePressed: () => toggleFavoriteStatus(book.id, index),
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