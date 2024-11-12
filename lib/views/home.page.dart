import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myapp/controller/login.controller.dart';
import 'package:myapp/views/trade.offer.page.dart';
import '../controller/books.controller.dart';
import '../models/book.model.dart';
import '../models/user.info.model.dart';
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
  final booksController = BooksController(); // Instância do BooksController
  final TextEditingController _searchController = TextEditingController();
  bool busy = false;
  List<BookModel> books = [];
  List<bool> favoriteStatus = [];

  @override
  void initState() {
    super.initState();
    loginController.AssignUserData(context);
    _loadBooks(); // Carrega os livros quando a página é inicializada
    print('-----====Valor estrelas-----==== ${user.value.customerRating}');
  }

  handleSignOut() {
    setState(() {
      busy = true;
    });
    loginController.logout(context).then((data) {
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
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
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

  Future<void> _loadBooks() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      // Inicializa uma lista de favoritos vazia
      List<String> favoriteBooks = [];

      // Se o usuário estiver logado, busca os livros favoritados
      if (userId != null) {
        favoriteBooks = await booksController.getFavoriteBookIds(userId);
      }

      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('books').get();

      setState(() {
        books = snapshot.docs
            .where((doc) => (doc.data() as Map<String, dynamic>)['userId'] != userId)
            .map((doc) {
          final data = doc.data() as Map<String, dynamic>;

          // Verificação e conversão de `bookImageUserUrls` para garantir que seja uma lista de strings
          var bookImageUserUrls = data['bookImageUserUrls'];
          if (bookImageUserUrls is String) {
            bookImageUserUrls = [bookImageUserUrls];
          } else if (bookImageUserUrls is List) {
            bookImageUserUrls = bookImageUserUrls.map((item) => item.toString()).toList();
          } else {
            bookImageUserUrls = ['https://via.placeholder.com/100']; // Placeholder se estiver ausente ou nulo
          }

          return BookModel(
            userId: data['userId'] ?? '', // Adiciona valor padrão se for null
            id: doc.id,
            title: data['title'] ?? 'Título não disponível', // Valor padrão
            author: data['author'] ?? 'Autor desconhecido', // Valor padrão
            bookImageUserUrls: bookImageUserUrls,
            imageApiUrl: data['imageApiUrl'],
            publishedDate: (data['publishedDate'] as Timestamp?)?.toDate() ?? DateTime.now(), // Valor padrão para publishedDate
            condition: data['condition'] ?? 'Condição não disponível', // Valor padrão
            edition: data['edition'] ?? 'Edição não disponível', // Valor padrão
            genres: data['genres'] != null ? List<String>.from(data['genres']) : [], // Lista vazia se null
            isbn: data['isbn'],
            publicationYear: data['publicationYear'] ?? 'Ano de publicação não disponível', // Valor padrão
            publisher: data['publisher'] ?? 'Editora não disponível', // Valor padrão
            isAvailable: data['isAvailable'] ?? true,
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
        await booksController.addBookToFavorites(userId, bookId);
      } else {
        // Remove dos favoritos
        await booksController.removeBookFromFavorites(userId, bookId);
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, color: Colors.grey, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
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
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.green, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    user.value.address ?? 'Endereço não cadastrado',
                    style: const TextStyle(color: Colors.black, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      drawer: _buildDrawer(),
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
                    imageUserUrl: book.bookImageUserUrls[0],
                    postedBy: book.userInfo.name,
                    profileImageUrl: book.userInfo.profileImageUrl,
                    customerRating: book.userInfo.customerRating,
                    isFavorite: favoriteStatus[index],
                    onFavoritePressed: () async {
                      toggleFavoriteStatus(book.id, index);
                      // Atualiza os livros após a alteração do favorito
                      await _loadBooks();
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

  Widget _buildDrawer() {
    return Drawer(
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
                     Center(
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(user.value.picture),
                        radius: 40,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user.value.name,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      user.value.address ?? 'Endereço não cadastrado',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...List.generate(user.value.customerRating.floor(), (index) {
                          return const Icon(Icons.star, color: Colors.amber, size: 18);
                        }),
                        if (user.value.customerRating - user.value.customerRating.floor() >= 0.5)
                          const Icon(Icons.star_half, color: Colors.amber, size: 18),
                      ],
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
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
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
                  title: const Text('Minhas trocas'),
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
                  title: const Text('Trocas pendentes'),
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
                ListTile(
                  leading: const Icon(Icons.star, color: Colors.black),
                  title: const Text('Gêneros Favoritos'),
                  onTap: () {
                    Navigator.pushNamed(context, '/favoriteGenres');
                  },
                ),
                const Divider(), // Adicione um divisor para separar os itens
                ListTile(
                  title: const Text(
                    'Sair',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    handleSignOut();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );

  }
}
