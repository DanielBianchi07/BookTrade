import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:myapp/controller/login.controller.dart';
import '../models/book.model.dart';
import '../user.dart';
import 'home.page.dart';
import 'trade.confirmation.page.dart';

class ExchangeTrackingPage extends StatelessWidget {
  const ExchangeTrackingPage({super.key});

  Future<void> _checkUser(BuildContext context, LoginController loginController) async {
    loginController.AssignUserData(context);
  }

  Future<List<Map<String, dynamic>>> _fetchTradeHistory(LoginController loginController) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('requests')
        .where('status', whereIn: ['Aguardando recebimento', 'Aguardando confirmação do endereço'])
        .orderBy('createdAt', descending: true) // Ordena pelo campo createdAt em ordem decrescente
        .get();

    List<Map<String, dynamic>> tradeHistory = [];
    final userId = user.value.uid;

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final requesterId = data['requesterId'];
      final ownerId = data['ownerId'];
      final requestedBookData = data['requestedBook'];
      final offeredBooksData = List<Map<String, dynamic>>.from(data['offeredBooks']);

      // Verifica se o usuário logado é o requester (ofereceu o livro) ou o owner (postou o livro)
      bool isRequester = requesterId == userId;
      final userConfirmationStatus = isRequester ? data['requesterConfirmationStatus'] : data['ownerConfirmationStatus'];

      // Filtra registros onde o status de confirmação do usuário atual é diferente de "Aguardando confirmação"
      if (userConfirmationStatus == 'concluído' || userConfirmationStatus == 'cancelado') {
        continue; // Ignora este request
      }

      final bookToShow = isRequester ? requestedBookData : offeredBooksData[0];

      // Obter informações do usuário da outra pessoa envolvida na troca
      final otherUserId = isRequester ? ownerId : requesterId;
      final otherUserDoc = await FirebaseFirestore.instance.collection('users').doc(otherUserId).get();
      final otherUserData = otherUserDoc.data();

      // Define o status de entrega como o status do request
      final deliveryStatus = data['status'];

      tradeHistory.add({
        'requestId': doc.id,
        'otherUserId': otherUserId,
        'title': bookToShow['title'] ?? 'Título não disponível',
        'author': bookToShow['author'] ?? 'Autor desconhecido',
        'postedBy': otherUserData?['name'] ?? 'Usuário desconhecido',
        'deliveryStatus': deliveryStatus,
        'rating': otherUserData?['customerRating']?.toDouble() ?? 0.0,
        'profileImageUrl': otherUserData?['profileImageUrl'] ?? 'https://via.placeholder.com/50',
        'bookImageUrl': bookToShow['imageUrl'] ?? 'https://via.placeholder.com/150',
        'requestedBook': requestedBookData,
        'offeredBook': offeredBooksData[0],
        'publicationYear': bookToShow['publicationYear'] ?? 'Ano não disponível',
        'isRequester': isRequester, // Passa a informação de isRequester
        'createdAt': (data['createdAt'] as Timestamp).toDate(), // Conversão de Timestamp para DateTime
      });
    }

    return tradeHistory;
  }

  @override
  Widget build(BuildContext context) {
    final LoginController loginController = LoginController();
    return FutureBuilder(
      future: _checkUser(context, loginController),
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFFD8D5B3),
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
              'Trocas em Andamento',
              style: TextStyle(color: Colors.black),
            ),
          ),
          body: FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchTradeHistory(loginController),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text('Erro ao carregar histórico de trocas'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Nenhuma troca em andamento'));
              }

              final tradeHistory = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: tradeHistory.length,
                  itemBuilder: (context, index) {
                    final trade = tradeHistory[index];
                    final otherUserId = trade['otherUserId'];
                    final isRequester = trade['isRequester'];
                    final requestedBookData = trade['requestedBook'];
                    final offeredBooksData = trade['offeredBook'];
                    final otherUserData = {
                      'name': trade['postedBy'],
                      'profileImageUrl': trade['profileImageUrl'],
                    };

                    return TradeHistoryCard(
                      title: trade['title'],
                      author: 'De ${trade['author']}',
                      postedBy: trade['postedBy'],
                      deliveryStatus: trade['deliveryStatus'],
                      rating: trade['rating'],
                      profileImageUrl: trade['profileImageUrl'],
                      bookImageUrl: trade['bookImageUrl'],
                      createdAt: trade['createdAt'],
                      onTap: () {
                        // Definindo as variáveis necessárias para passar para a página de confirmação
                        final requestedBook = isRequester ? offeredBooksData : requestedBookData;
                        final selectedOfferedBook = isRequester ? requestedBookData : offeredBooksData;
                        final requesterName = isRequester ? trade['postedBy'] : otherUserData['name'];
                        final requesterProfileUrl = isRequester ? trade['profileImageUrl'] : otherUserData['profileImageUrl'];

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TradeConfirmationPage(
                              otherUserId: otherUserId,
                              isRequester: isRequester,
                              requestId: trade['requestId'],
                              requestedBook: BookModel.fromMap(requestedBook),
                              selectedOfferedBook: BookModel.fromMap(selectedOfferedBook),
                              requesterName: requesterName,
                              requesterProfileUrl: requesterProfileUrl,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class TradeHistoryCard extends StatelessWidget {
  final String title;
  final String author;
  final String postedBy;
  final String deliveryStatus;
  final double rating;
  final String profileImageUrl;
  final String bookImageUrl;
  final VoidCallback onTap;
  final DateTime createdAt; // Adicionado campo createdAt

  const TradeHistoryCard({
    super.key,
    required this.title,
    required this.author,
    required this.postedBy,
    required this.deliveryStatus,
    required this.rating,
    required this.profileImageUrl,
    required this.bookImageUrl,
    required this.onTap,
    required this.createdAt, // Inicialização do campo createdAt
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 190,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(
              color: Colors.grey.shade400,
              width: 1.5,
            ),
          ),
          margin: const EdgeInsets.only(bottom: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    bookImageUrl,
                    height: 100,
                    width: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1, // Limita a uma linha
                        overflow: TextOverflow.ellipsis, // Adiciona "..." caso o texto ultrapasse o espaço
                      ),
                      const SizedBox(height: 4),
                      Text(
                        author,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey,
                        ),
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                postedBy,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              RatingBarIndicator(
                                rating: rating,
                                itemBuilder: (context, index) => const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                itemCount: 5,
                                itemSize: 16.0,
                                direction: Axis.horizontal,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Exibição do campo createdAt formatado
                      Text(
                        'Data: ${createdAt.day}/${createdAt.month}/${createdAt.year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            deliveryStatus,
                            style: TextStyle(
                              fontSize: 12, // Fonte menor para o status
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}