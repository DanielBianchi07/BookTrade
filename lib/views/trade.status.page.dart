import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trocas Pendentes'), 
        backgroundColor: const Color(0xFFD8D5B3),
        ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('status', isEqualTo: 'pending') // Status da troca
            .where('requesterId', isEqualTo: userId) // Caso o usuário seja o solicitante
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data!.docs;

          if (requests.isEmpty) {
            return const Center(child: Text('Nenhuma troca pendente.'));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final isRequester = request['requesterId'] == userId;

              return GestureDetector(
                onTap: () {
                  // Redireciona para a página de detalhes da solicitação
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RequestDetailPage(
                        requestId: request.id,  // Passa o ID da solicitação
                        isRequester: isRequester, // Passa se é o solicitante ou o dono do livro
                      ),
                    ),
                  );
                },
                child: Card(
                  child: ListTile(
                    title: Text('Livro: ${request['requestedBook']['title']}'),
                    subtitle: Text('Solicitado por: ${isRequester ? 'Você' : request['requesterId']}'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
