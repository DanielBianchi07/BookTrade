import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class FavoriteBooksPage extends StatefulWidget {
  @override
  FavoriteBooksPageState createState() => FavoriteBooksPageState();
}

class FavoriteBooksPageState extends State<FavoriteBooksPage> {
    // Chave global para acessar o Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Lista para gerenciar o estado dos corações (favoritados ou não)
  List<bool> favoriteStatus = [true, true, true, true, true, true, true]; // Exemplo com 7 itens

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFFD8D5B3), // Cor amarelada da barra superior
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop(); // Voltar para a página anterior
          },
        ),
        title: Text(
          'Lista de desejos',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: favoriteStatus.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {Navigator.pushNamed(context, '/tradeOffer');},
                  child: BookCard(
                    title: '1984',
                    author: 'De George Orwell',
                    postedBy: 'José Almeida',
                    imageUrl: 'https://via.placeholder.com/150',
                    profileImageUrl: 'https://via.placeholder.com/50',
                    isFavorite: favoriteStatus[index],
                    rating: 4.5,
                    onFavoritePressed: () {
                      setState(() {
                        favoriteStatus[index] = !favoriteStatus[index];
                      });
                    },
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

class BookCard extends StatelessWidget {
  final String title;
  final String author;
  final String postedBy;
  final String imageUrl;
  final String profileImageUrl;
  final bool isFavorite;
  final double rating;
  final VoidCallback onFavoritePressed;

  BookCard({
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
                SizedBox(width: 16),

                // Informações do livro
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        author,
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Postado por:',
                        style: TextStyle(fontSize: 12),
                      ),
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(profileImageUrl),
                            radius: 15,
                          ),
                          SizedBox(width: 8),
                          Text(
                            postedBy,
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      // Estrelas de avaliação
                      RatingBarIndicator(
                        rating: rating,
                        itemBuilder: (context, index) => Icon(
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