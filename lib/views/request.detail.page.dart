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
              .map((bookData) => BookModel.fromDocument(bookData))
              .toList();
    } catch (e) {
      print('Erro ao carregar os dados da solicitação: $e');
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalhes da Solicitação')),
      body: requestData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(


              ],
            ),
    );
  }
}
