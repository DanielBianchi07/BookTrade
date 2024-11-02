import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/book.dart';
import '../widgets/bookcard.widget.dart';
import 'trade.offer.page.dart';

class FavoriteBooksPage extends StatefulWidget {
  const FavoriteBooksPage({super.key});

  @override
  FavoriteBooksPageState createState() => FavoriteBooksPageState();
}

class FavoriteBooksPageState extends State<FavoriteBooksPage> {
  // Chave global para acessar o Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Book> books = []; // Lista para armazenar livros favoritos
  List<bool> favoriteStatus = []; // Lista para gerenciar o estado dos favoritos

  @override
  void initState() {
    super.initState();
    _loadBooks(); // Carrega os livros favoritos ao inicializar
  }

  Future<void> _loadBooks() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) return; // Retorna se o usuário não estiver logado

    try {
      // Busca os livros favoritados do Firebase
      QuerySnapshot favoritesSnapshot = await FirebaseFirestore.instance
          .collection('favorites')
          .doc(userId)
          .collection('userFavorites')
          .get();

      List<String> favoriteBooks = favoritesSnapshot.docs.map((doc) => doc.id).toList();

      // Agora busca os dados dos livros usando os IDs
      for (String bookId in favoriteBooks) {
        DocumentSnapshot bookDoc = await FirebaseFirestore.instance.collection('books').doc(bookId).get();
        if (bookDoc.exists) {
          final data = bookDoc.data() as Map<String, dynamic>;
          books.add(Book(
            uid: data['userId'] ?? '',
            id: bookId,
            title: data['title'] ?? '',
            author: data['author'] ?? '',
            imageUrl: data['imageUrl'] ?? 'https://via.placeholder.com/100',
            postedBy: data['postedBy'],
            profileImageUrl: data['profileImageUrl'],
            rating: data['rating'],
            isFavorite: true, // Todos os livros aqui são favoritos
          ));
        }
      }

      setState(() {
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
                          bookId: book.id,
                          title: book.title,
                          author: book.author,
                          postedBy: book.postedBy ?? 'Desconhecido',
                          imageUrl: book.imageUrl,
                          profileImageUrl: book.profileImageUrl ?? 'https://via.placeholder.com/50',
                          isFavorite: favoriteStatus[index],
                          rating: book.rating ?? 0.0,
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