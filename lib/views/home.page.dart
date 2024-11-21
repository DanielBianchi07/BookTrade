import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myapp/controller/login.controller.dart';
import 'package:myapp/views/chat.page.dart';
import 'package:myapp/views/edit.profile.page.dart';
import 'package:myapp/views/exchange.tracking.page.dart';
import 'package:myapp/views/favorite.books.page.dart';
import 'package:myapp/views/favorite.genres.page.dart';
import 'package:myapp/views/new.book.page.dart';
import 'package:myapp/views/notifications.page.dart';
import 'package:myapp/views/publicated.books.page.dart';
import 'package:myapp/views/trade.history.page.dart';
import 'package:myapp/views/trade.offer.page.dart';
import 'package:myapp/views/trade.status.page.dart';
import '../controller/books.controller.dart';
import '../models/book.model.dart';
import '../models/user.info.model.dart';
import '../user.dart';
import '../widgets/bookcard.widget.dart';
import 'chats.page.dart';
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
  List<BookModel> favoriteGenreBooks = [];
  List<BookModel> allBooks = []; // Lista que armazena todos os livros
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

  @override
  void dispose() {
    _searchController.dispose(); // Libere o controlador de texto
    super.dispose();
  }

  handleSignOut() {
    busy = true;
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
      if (mounted) {
        setState(() {
          busy = false;
        });
      }
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

  Future<void> _loadBooks() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      List<String> favoriteBooks = [];
      if (userId != null) {
        favoriteBooks = await booksController.getFavoriteBookIds(userId);
      }

      final recommendedBooks = await getRecommendedBooks(user.value.uid);
      // Consulta para carregar apenas livros com isAvailable = true
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('books')
          .where('isAvailable', isEqualTo: true)
          .get();

      setState(() {
        if (mounted) {
          favoriteGenreBooks = recommendedBooks.map((data) {
            return BookModel.fromMap(data);
          }).toList();
        }
      });
      setState(() {
        if (mounted) {
          allBooks = snapshot.docs
              .where((doc) =>
          (doc.data() as Map<String, dynamic>)['userId'] != userId)
              .map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            var bookImageUserUrls = data['bookImageUserUrls'];
            if (bookImageUserUrls is String) {
              bookImageUserUrls = [bookImageUserUrls];
            } else if (bookImageUserUrls is List) {
              bookImageUserUrls =
                  bookImageUserUrls.map((item) => item.toString()).toList();
            } else {
              bookImageUserUrls = ['https://via.placeholder.com/100'];
            }

            return BookModel(
              userId: data['userId'] ?? '',
              id: doc.id,
              title: data['title'] ?? 'Título não disponível',
              author: data['author'] ?? 'Autor desconhecido',
              bookImageUserUrls: bookImageUserUrls,
              imageApiUrl: data['imageApiUrl'],
              publishedDate: (data['publishedDate'] as Timestamp?)?.toDate() ??
                  DateTime.now(),
              condition: data['condition'] ?? 'Condição não disponível',
              edition: data['edition'] ?? 'Edição não disponível',
              genres: data['genres'] != null
                  ? List<String>.from(data['genres'])
                  : [],
              isbn: data['isbn'],
              description: data['description'],
              publicationYear: data['publicationYear'] ??
                  'Ano de publicação não disponível',
              publisher: data['publisher'] ?? 'Editora não disponível',
              isAvailable: data['isAvailable'] ?? true,
              userInfo: UInfo.fromMap(data['userInfo'] ?? {}),
            );
          }).toList();

          // Inicialmente, `books` contém todos os livros
          books = List.from(allBooks);

          favoriteStatus = List.generate(
              books.length, (index) => favoriteBooks.contains(books[index].id));
        }
      });
    } catch (e) {
      print('Erro ao carregar livros: $e');
    }
  }

  void _filterBooks(String query) {
    if (mounted) {
      setState(() {
        books = allBooks
            .where((book) =>
        book.title.toLowerCase().contains(query.toLowerCase()) ||
            book.author.toLowerCase().contains(query.toLowerCase()))
            .toList();
        favoriteGenreBooks = favoriteGenreBooks
            .where((book) =>
        book.title.toLowerCase().contains(query.toLowerCase()) ||
            book.author.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  Future<List<Map<String, dynamic>>> getRecommendedBooks(String userId) async {
    // Obtenha os gêneros favoritos do usuário
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    List<String> favoriteGenres = List<String>.from(userDoc['favoriteGenres'] ?? []);

    // Consulta os livros que têm pelo menos um dos gêneros favoritos
    final booksQuery = await FirebaseFirestore.instance
        .collection('books')
        .where('genres', arrayContainsAny: favoriteGenres)
        .get();

    // Filtra para excluir livros do próprio usuário e converte para Map<String, dynamic>
    List<Map<String, dynamic>> books = booksQuery.docs
        .where((doc) => doc['userInfo']['userId'] != userId)
        .map((doc) => doc.data())
        .toList();

    // Ordena os livros primeiro pelos gêneros favoritos e depois pela avaliação, do maior para o menor
    books.sort((a, b) {
      // Ordena pelo gênero se precisar, mas é opcional e depende da estrutura desejada
      // Verifica se os gêneros existem e têm elementos
      String genreA = (a['genres'] != null && a['genres'].isNotEmpty) ? a['genres'].first : '';
      String genreB = (b['genres'] != null && b['genres'].isNotEmpty) ? b['genres'].first : '';

      // Obtem os índices dos gêneros favoritos, tratando valores que podem ser -1
      int indexA = favoriteGenres.indexOf(genreA);
      int indexB = favoriteGenres.indexOf(genreB);

      // Ajusta índices ausentes para o final da lista
      indexA = indexA == -1 ? favoriteGenres.length : indexA;
      indexB = indexB == -1 ? favoriteGenres.length : indexB;

      int genreComparison = indexA.compareTo(indexB);

      // Verifica se o customerRating não é null
      double ratingA = a['customerRating'] ?? 0.0;
      double ratingB = b['customerRating'] ?? 0.0;

      // Em caso de empate de gênero, ordena pela avaliação (rating) do maior para o menor
      if (genreComparison == 0) {
        return ratingB.compareTo(ratingA);
      } else {
        return genreComparison;
      }
    });

    return books;
  }

  void safeSetState(VoidCallback callback) {
    if (mounted) {
      setState(callback);
    }
  }

  void toggleFavoriteStatus(String bookId, int index) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return; // Certifique-se de que o usuário está logado

    // Alterna o estado local
    safeSetState(() {
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

  Future<bool> checkAddress () async {
    // Obtenha os gêneros favoritos do usuário
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).get();
    if (userDoc.exists && userDoc.data()?['address'] != null && userDoc.data()?['address'].isNotEmpty) {
      return true;
    } else {
      return false;
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
                      onChanged: (query) {
                        _filterBooks(query);
                      },
                    ),
                  ),
                ],
              ),
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
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 300, // Altura máxima da área de rolagem
              ),
              child: Scrollbar(
                thumbVisibility: true, // Mostra a barra de rolagem
                child: books.isEmpty
                    ? const SizedBox(
                  height: 50,
                  child: Center(
                    child: Text(
                      'Nenhum livro selecionado ainda',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                )
                    : ListView.builder(
                  shrinkWrap: true,
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return InkWell(
                      onTap: () {
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
                        address: book.userInfo.address!,
                        onFavoritePressed: () async {
                          toggleFavoriteStatus(book.id, index);
                          await _loadBooks();
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Baseado nos seus gêneros favoritos:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 300, // Altura máxima da área de rolagem
              ),
              child: Scrollbar(
                thumbVisibility: true, // Mostra a barra de rolagem
                child: favoriteGenreBooks.isEmpty
                    ? const SizedBox(
                  height: 50,
                  child: Center(
                    child: Text(
                      'Não foi encontrado livros.',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                )
                    : ListView.builder(
                  shrinkWrap: true,
                  itemCount: favoriteGenreBooks.length,
                  itemBuilder: (context, index) {
                    final book = favoriteGenreBooks[index];
                    return InkWell(
                      onTap: () {
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
                        address: book.userInfo.address!,
                        onFavoritePressed: () async {
                          toggleFavoriteStatus(book.id, index);
                          await _loadBooks();
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool hasAddress = await checkAddress();

          if (hasAddress) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => NewBookPage()));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Você precisa cadastrar um endereço para publicar um novo livro.'),
              ),
            );
          }
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
                        backgroundImage: NetworkImage(
                          "${user.value.picture}?t=${DateTime.now().millisecondsSinceEpoch}",
                        ),
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
                        Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilePage()));
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
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PublicatedBooksPage()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.swap_horiz, color: Colors.black),
                  title: const Text('Trocas em Andamento'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ExchangeTrackingPage()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.history, color: Colors.black),
                  title: const Text('Histórico de Trocas'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => TradeHistoryPage()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.notifications, color: Colors.black),
                  title: const Text('Notificações'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationsPage()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.question_mark_rounded, color: Colors.black),
                  title: const Text('Trocas pendentes'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => TradeStatusPage()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.favorite, color: Colors.black),
                  title: const Text('Lista de desejos'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FavoriteBooksPage()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.chat, color: Colors.black),
                  title: const Text('Chat'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ChatsPage()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.star, color: Colors.black),
                  title: const Text('Gêneros Favoritos'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FavoriteGenresPage()));
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
