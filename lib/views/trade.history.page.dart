import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';


class TradeHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFD8D5B3), // Cor amarelada
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Ação para voltar
          },
        ),
        title: Text(
          'Histórico de trocas',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: 3, // Número de itens na lista
          itemBuilder: (context, index) {
            return TradeHistoryCard(
              title: '1984',
              author: 'De George Orwell',
              postedBy: 'José Almeida',
              deliveryDate: index == 0 ? null : '30/09/2024', // Exemplo: "Em andamento" para o primeiro item
              rating: 4.0,
              profileImageUrl: 'https://via.placeholder.com/50',
              bookImageUrl: 'https://via.placeholder.com/150',
              inProgress: index == 0, // Se `index` for 0, a troca está em andamento
            );
          },
        ),
      ),
    );
  }
}

class TradeHistoryCard extends StatelessWidget {
  final String title;
  final String author;
  final String postedBy;
  final String? deliveryDate;
  final double rating;
  final String profileImageUrl;
  final String bookImageUrl;
  final bool inProgress;

  TradeHistoryCard({
    required this.title,
    required this.author,
    required this.postedBy,
    this.deliveryDate,
    required this.rating,
    required this.profileImageUrl,
    required this.bookImageUrl,
    this.inProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(
          color: Colors.grey.shade400, // Borda da caixa do livro
          width: 1.5,
        ),
      ),
      margin: EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Imagem do livro
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    bookImageUrl,
                    height: 100,
                    width: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 16),

                // Informações do livro
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$title : $author',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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
                      SizedBox(height: 8),
                      // Estrelas de avaliação
                      RatingBarIndicator(
                        rating: rating,
                        itemBuilder: (context, index) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 16.0,
                        direction: Axis.horizontal,
                      ),
                      SizedBox(height: 8),
                      // Status da Troca (Em andamento ou Data de Entrega)
                      Text(
                        inProgress ? 'Em andamento' : 'Data de Entrega: $deliveryDate',
                        style: TextStyle(
                          fontSize: 14,
                          color: inProgress ? Colors.orange : Colors.black,
                          fontWeight: inProgress ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
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
