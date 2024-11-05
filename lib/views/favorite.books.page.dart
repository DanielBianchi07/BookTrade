import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myapp/views/trade.offer.page.dart';
import '../controller/books.controller.dart';
import '../models/book.dart';
import '../user.dart';
import '../widgets/bookcard.widget.dart';

class FavoriteBooksPage extends StatefulWidget {
  const FavoriteBooksPage({super.key});

  @override
  FavoriteBooksPageState createState() => FavoriteBooksPageState();
}

class FavoriteBooksPageState extends State<FavoriteBooksPage> {
  // Chave global para acessar o Scaffold
  late bool _isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<BookModel> books = []; // Lista para armazenar livros favoritos
  List<bool> favoriteStatus = []; // Lista para gerenciar o estado dos favoritos
  final BooksController booksController = BooksController();

  @override
  void initState() {
    super.initState();
    booksController.loadFavoriteBooks(user.value.uid); // Carrega os livros favoritos ao inicializar
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> loadFavoriteBooks() async {
    setState(() {
      _isLoading = true;
    });
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      _showError('Erro: Nenhum usuário autenticado.');
      return;
    }

    try {
      List<BookModel> favoriteBooks = await booksController.loadFavoriteBooks(userId);

      setState(() {
        books = favoriteBooks;
        favoriteStatus = List.generate(books.length, (index) => true); // Todos são favoritos
      });
    } catch (e) {
      print('Erro ao carregar livros favoritos: $e');
      Fluttertoast.showToast(
        msg: "Erro ao carregar livros favoritos",
        toastLength: Toast.LENGTH_SHORT,
      );
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
        // Adiciona aos favoritos (não deve acontecer aqui, já está na lista)
        // Código omitido porque não é necessário
      } else {
        // Remove dos favoritos
        await FirebaseFirestore.instance
            .collection('favorites')
            .doc(userId)
            .collection('userFavorites')
            .doc(bookId)
            .delete();

        // Remove o livro da lista de favoritos localmente
        setState(() {
          books.removeAt(index);
          favoriteStatus.removeAt(index);
        });
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
        backgroundColor: const Color(0xFFD8D5B3), // Cor amarelada da barra superior
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop(); // Voltar para a página anterior
          },
        ),
        title: const Text(
          'Lista de Desejos',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            books.isEmpty
                ? const Center(child: Text('Nenhum livro favorito encontrado.')) // Mensagem se não houver favoritos
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
                    userId: book.userInfo.id,
                    title: book.title,
                    author: book.author,
                    postedBy: book.userInfo.name,
                    imageUserUrl: book.imageUserUrl,
                    profileImageUrl: book.userInfo.profileImageUrl,
                    isFavorite: favoriteStatus[index],
                    customerRating: book.userInfo.customerRating ?? 0.0,
                    onFavoritePressed: () => toggleFavoriteStatus(book.id, index),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}