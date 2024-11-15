import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:myapp/controller/login.controller.dart';
import 'package:myapp/views/exchanged.book.details.page.dart';
import '../models/book.model.dart';
import '../user.dart';

class TradeHistoryPage extends StatelessWidget {
  const TradeHistoryPage({super.key});

  Future<void> _checkUser(BuildContext context, LoginController loginController) async {
    loginController.AssignUserData(context);
  }

  Future<List<Map<String, dynamic>>> _fetchTradeHistory(LoginController loginController) async {
    final querySnapshot = await FirebaseFirestore.instance.collection('requests').get();

    List<Map<String, dynamic>> tradeHistory = [];
    final userId = user.value.uid;

    for (var doc in querySnapshot.docs) {
      final data = doc.data();

      // Ignorar requests com status "pending"
      if (data['status'] == 'pending') continue;

      // Verificar se os campos de confirmação existem
      if (!data.containsKey('requesterConfirmationStatus') || !data.containsKey('ownerConfirmationStatus')) {
        continue; // Ignora este request se algum campo de confirmação estiver ausente
      }

      final requesterId = data['requesterId'] ?? '';
      final ownerId = data['ownerId'] ?? '';
      final requestedBookData = data['requestedBook'] ?? {};
      final offeredBooksData = List<Map<String, dynamic>>.from(data['offeredBooks'] ?? []);

      // Verifica se o usuário logado é o requester ou o owner
      bool isRequester = requesterId == userId;
      final userConfirmationStatus = isRequester ? data['requesterConfirmationStatus'] : data['ownerConfirmationStatus'];

      // Ignorar se o status do usuário logado é "Aguardando confirmação"
      if (userConfirmationStatus == 'Aguardando confirmação') {
        continue;
      }

      final bookToShow = isRequester ? requestedBookData : (offeredBooksData.isNotEmpty ? offeredBooksData[0] : {});
      final userSpecificStatus = isRequester ? data['requesterConfirmationStatus'] : data['ownerConfirmationStatus'];
      final statusColor = userSpecificStatus == 'concluído' ? Colors.green : Colors.red;

      final otherUserId = isRequester ? ownerId : requesterId;
      final otherUserDoc = await FirebaseFirestore.instance.collection('users').doc(otherUserId).get();
      final otherUserData = otherUserDoc.data();

      tradeHistory.add({
        'requestId': doc.id,
        'title': bookToShow['title'] ?? 'Título não disponível',
        'author': bookToShow['author'] ?? 'Autor desconhecido',
        'postedBy': otherUserData?['name'] ?? 'Usuário desconhecido',
        'userSpecificStatus': userSpecificStatus,
        'statusColor': statusColor,
        'rating': (otherUserData?['customerRating'] ?? 0).toDouble(),
        'profileImageUrl': otherUserData?['profileImageUrl'] ?? 'https://via.placeholder.com/50',
        'bookImageUrl': bookToShow['imageUrl'] ?? 'https://via.placeholder.com/150',
        'requestedBook': requestedBookData,
        'offeredBook': offeredBooksData.isNotEmpty ? offeredBooksData[0] : {},
        'publicationYear': bookToShow['publicationYear'] ?? 'Ano não disponível',
        'isRequester': isRequester,
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
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: const Text(
              'Histórico de trocas',
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
                return const Center(child: Text('Nenhuma troca encontrada'));
              }

              final tradeHistory = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: tradeHistory.length,
                  itemBuilder: (context, index) {
                    final trade = tradeHistory[index];
                    return TradeHistoryCard(
                      title: trade['title']!,
                      author: 'De ${trade['author']}',
                      postedBy: trade['postedBy']!,
                      userSpecificStatus: trade['userSpecificStatus']!,
                      statusColor: trade['statusColor']!,
                      rating: trade['rating']!,
                      profileImageUrl: trade['profileImageUrl']!,
                      bookImageUrl: trade['bookImageUrl']!,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExchangedBookDetailsPage(
                              requestId: trade['requestId'],
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
  final String userSpecificStatus;
  final Color statusColor;
  final double rating;
  final String profileImageUrl;
  final String bookImageUrl;
  final VoidCallback onTap;

  const TradeHistoryCard({
    super.key,
    required this.title,
    required this.author,
    required this.postedBy,
    required this.userSpecificStatus,
    required this.statusColor,
    required this.rating,
    required this.profileImageUrl,
    required this.bookImageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 180, // Define uma altura fixa para manter o tamanho uniforme
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        author,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: statusColor,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              userSpecificStatus,
                              style: TextStyle(
                                fontSize: 12,
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
