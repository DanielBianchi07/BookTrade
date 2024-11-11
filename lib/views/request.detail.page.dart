import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/book.model.dart';  // Certifique-se de que a classe BookModel está importada corretamente.

class RequestDetailPage extends StatefulWidget {
  final String requestId;
  final bool isRequester;

  const RequestDetailPage({
    super.key,
    required this.requestId,
    required this.isRequester,
  });

  @override
  _RequestDetailPageState createState() => _RequestDetailPageState();
}

class _RequestDetailPageState extends State<RequestDetailPage> {
  Map<String, dynamic> requestData = {};
  List<BookModel> offeredBooks = [];
  String selectedBookId = '';

  @override
  void initState() {
    super.initState();
    _fetchRequestData();
  }

  // Função para carregar os dados da solicitação
  Future<void> _fetchRequestData() async {
    if (requestData.isNotEmpty) {
      // Se os dados já foram carregados, não carregue novamente
      return;
    }

    try {
      // Recupera o documento da solicitação
      DocumentSnapshot requestDoc = await FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.requestId)
          .get();

      if (requestDoc.exists) {
        setState(() {
          requestData = requestDoc.data() as Map<String, dynamic>;

          // Mapeia os livros oferecidos usando o método fromMap
          offeredBooks = (requestData['offeredBooks'] as List)
              .map((bookData) => BookModel.fromMap(bookData as Map<String, dynamic>))
              .toList();
        });
      }
    } catch (e) {
      print('Erro ao carregar os dados da solicitação: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalhes da Solicitação')),
      body: requestData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exibe o livro solicitado
              Text(
                'Livro solicitado: ${requestData['requestedBook']['title']}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Exibe os livros oferecidos
              Text(
                'Livros Oferecidos:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true, // Para que a ListView seja exibida corretamente dentro da Column
                physics: const NeverScrollableScrollPhysics(), // Evitar conflitos de scroll com o SingleChildScrollView
                itemCount: offeredBooks.length,
                itemBuilder: (context, index) {
                  final book = offeredBooks[index];
                  return RadioListTile<String>(
                    title: Text(book.title),
                    value: book.id,
                    groupValue: selectedBookId,
                    onChanged: (value) {
                      setState(() {
                        selectedBookId = value!;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              // Botões de Aceitar ou Rejeitar
              if (!widget.isRequester)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        // Lógica de aceitar a solicitação
                        await FirebaseFirestore.instance
                            .collection('requests')
                            .doc(widget.requestId)
                            .update({'status': 'accepted'});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Solicitação aceita!')),
                        );
                        Navigator.pop(context);
                      },
                      child: const Text('Aceitar'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        // Lógica de rejeitar a solicitação
                        await FirebaseFirestore.instance
                            .collection('requests')
                            .doc(widget.requestId)
                            .update({'status': 'rejected'});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Solicitação rejeitada!')),
                        );
                        Navigator.pop(context);
                      },
                      child: const Text('Rejeitar'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}