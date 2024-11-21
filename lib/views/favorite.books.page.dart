import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myapp/controller/books.controller.dart';
import 'package:myapp/user.dart';
import '../models/book.model.dart';
import '../widgets/bookcard.widget.dart';
import 'home.page.dart';
import 'trade.offer.page.dart';

class FavoriteBooksPage extends StatefulWidget {
  const FavoriteBooksPage({super.key});

  @override
  FavoriteBooksPageState createState() => FavoriteBooksPageState();
}

class FavoriteBooksPageState extends State<FavoriteBooksPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  List<BookModel> books = []; // Lista para armazenar livros favoritos
  final BooksController booksController = BooksController();

  @override
  void initState() {
    super.initState();
    loadFavoriteBooks(); // Carrega os livros favoritos ao inicializar
  }

  Future<void> loadFavoriteBooks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Utiliza o método do controller para carregar os livros favoritos
      List<BookModel> favoriteBooks = await booksController.loadFavoriteBooks(user.value.uid);

      setState(() {
        books = favoriteBooks;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar livros favoritos: $e');
      Fluttertoast.showToast(
        msg: "Erro ao carregar livros favoritos",
        toastLength: Toast.LENGTH_SHORT,
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void toggleFavoriteStatus(String bookId, int index) async {
    // Utiliza o método do controller para alternar o status do favorito
    try {
      await booksController.toggleFavoriteStatus(user.value.uid, bookId);

      setState(() {
        books.removeAt(index);
      });
    } catch (e) {
      print('Erro ao atualizar favoritos: $e');
      Fluttertoast.showToast(
        msg: "Erro ao atualizar favoritos",
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFD8D5B3), // Cor amarelada da barra superior
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () async{
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
                  (Route<dynamic> route) => false, // Remove todas as rotas anteriores
            );
          },
        ),
        title: const Text(
          'Lista de Desejos',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Exibe um indicador de carregamento enquanto os livros são carregados
          : books.isEmpty
          ? const Center(child: Text('Nenhum livro favorito selecionado.')) // Mensagem se não houver favoritos
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
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
              address: book.userInfo.address!,
              isFavorite: true, // Sempre é favorito na página de favoritos
              onFavoritePressed: () => toggleFavoriteStatus(book.id, index),
            ),
          );
        },
      ),
    );
  }
}
