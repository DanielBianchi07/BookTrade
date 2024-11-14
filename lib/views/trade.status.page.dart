import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.page.dart';
import 'request.detail.page.dart';

class TradeStatusPage extends StatefulWidget {
  const TradeStatusPage({super.key});

  @override
  _TradeStatusPageState createState() => _TradeStatusPageState();
}

class _TradeStatusPageState extends State<TradeStatusPage> {
  late final String userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid; // Pegando o UID do usuário atual
  }

  Future<String> _getRequesterName(String requesterId) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(requesterId).get();
      if (userDoc.exists) {
        return userDoc.data()!['name'] ?? 'Nome não encontrado';
      } else {
        return 'Usuário não encontrado';
      }
    } catch (e) {
      return 'Erro ao buscar nome';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trocas Pendentes'),
        backgroundColor: const Color(0xFFD8D5B3),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                builder: (context) => HomePage()
              ),
            );
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('status', isEqualTo: 'pending') // Status da troca
            .where('requesterId', isEqualTo: userId) // Caso o usuário seja o solicitante
            .snapshots(),
        builder: (context, snapshotRequester) {
          if (snapshotRequester.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshotRequester.hasError) {
            return Center(child: Text('Erro: ${snapshotRequester.error}'));
          }

          final requesterRequests = snapshotRequester.data?.docs ?? [];

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('requests')
                .where('status', isEqualTo: 'pending') // Status da troca
                .where('ownerId', isEqualTo: userId) // Caso o usuário seja o dono do livro
                .snapshots(),
            builder: (context, snapshotOwner) {
              if (snapshotOwner.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshotOwner.hasError) {
                return Center(child: Text('Erro: ${snapshotOwner.error}'));
              }

              final ownerRequests = snapshotOwner.data?.docs ?? [];

              // Combina as listas de trocas em uma só
              final allRequests = [...requesterRequests, ...ownerRequests];

              if (allRequests.isEmpty) {
                return const Center(child: Text('Nenhuma troca pendente.'));
              }

              return ListView.builder(
                itemCount: allRequests.length,
                itemBuilder: (context, index) {
                  final request = allRequests[index];
                  final bool isRequester = request['requesterId'] == userId;
                  final requesterId = request['requesterId'];

                  return GestureDetector(
                    onTap: () {
                      // Redireciona para a página de detalhes da solicitação
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RequestDetailPage(
                            requestId: request.id, // Passa o ID da solicitação
                            isRequester: isRequester, // Passa se é o solicitante ou o dono do livro
                          ),
                        ),
                      );
                    },
                    child: Card(
                      child: ListTile(
                        title: Text('Livro: ${request['requestedBook']['title']}'),
                        subtitle: FutureBuilder<String>(
                          future: _getRequesterName(requesterId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Text('Carregando nome...');
                            } else if (snapshot.hasError) {
                              return const Text('Erro ao buscar nome');
                            } else {
                              final requesterName = snapshot.data ?? 'Nome não encontrado';
                              return Text('Solicitado por: ${isRequester ? 'Você' : requesterName}');
                            }
                          },
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
