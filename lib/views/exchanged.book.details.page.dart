import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/book.model.dart';
import '../user.dart';

class ExchangedBookDetailsPage extends StatefulWidget {
  final String requestId;

  const ExchangedBookDetailsPage({
    Key? key,
    required this.requestId,
  }) : super(key: key);

  @override
  _ExchangedBookDetailsPageState createState() => _ExchangedBookDetailsPageState();
}

class _ExchangedBookDetailsPageState extends State<ExchangedBookDetailsPage> {
  BookModel? requestedBook;
  BookModel? selectedOfferedBook;
  String otherUserName = "Usuário desconhecido";
  String otherUserProfileUrl = "";
  double otherUserRating = 0.0;
  bool isRequester = false;
  String? tradeStatus;
  List<String> _deliveryAddressList = [];

  @override
  void initState() {
    super.initState();
    _fetchBookData();
  }

  Future<void> _fetchBookData() async {
    try {
      final requestDoc = await FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.requestId)
          .get();

      if (requestDoc.exists) {
        final data = requestDoc.data();

        if (data != null) {
          final requestedBookId = data['requestedBook']['id'];
          if (requestedBookId != null) {
            final requestedBookDoc = await FirebaseFirestore.instance
                .collection('books')
                .doc(requestedBookId)
                .get();
            if (requestedBookDoc.exists) {
              final requestedBookData = requestedBookDoc.data();
              requestedBook = BookModel.fromMap(requestedBookData!);
            }
          }

          final offeredBooksData = data['offeredBooks'];
          if (offeredBooksData is List && offeredBooksData.isNotEmpty) {
            final offeredBookId = offeredBooksData.first['id'];
            if (offeredBookId != null) {
              final offeredBookDoc = await FirebaseFirestore.instance
                  .collection('books')
                  .doc(offeredBookId)
                  .get();
              if (offeredBookDoc.exists) {
                final offeredBookData = offeredBookDoc.data();
                selectedOfferedBook = BookModel.fromMap(offeredBookData!);
              }
            }
          }

          isRequester = data['requesterId'] == user.value.uid;
          tradeStatus = isRequester
              ? data['requesterConfirmationStatus']
              : data['ownerConfirmationStatus'];

          if (data['deliveryAddress'] != null) {
            _deliveryAddressList = List<String>.from(data['deliveryAddress']);
          }

          final otherUserId = isRequester ? data['ownerId'] : data['requesterId'];
          await _loadOtherUserInfo(otherUserId);

          setState(() {});
        }
      }
    } catch (e) {
      print("Erro ao carregar dados do request: $e");
    }
  }

  Future<void> _loadOtherUserInfo(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        otherUserName = userData['name'] ?? "Usuário desconhecido";
        otherUserProfileUrl = userData['profileImageUrl'] ?? '';
        otherUserRating = (userData['customerRating'] ?? 0.0).toDouble();
      }
    } catch (e) {
      print("Erro ao carregar dados do usuário: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Detalhes da Troca'),
        backgroundColor: const Color(0xFFD8D5B3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (requestedBook != null) _buildBookImage(requestedBook!),
                Icon(Icons.swap_horiz, size: 40, color: Colors.black),
                if (selectedOfferedBook != null) _buildBookImage(selectedOfferedBook!),
              ],
            ),
            const SizedBox(height: 20),
            _buildAddressSection(),
            const SizedBox(height: 20),
            Text(
              'Participante da Troca',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildOtherUserInfoSection(),
            const SizedBox(height: 20),
            _buildTradeDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildBookImage(BookModel book) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: CachedNetworkImageProvider(
            book.bookImageUserUrls.isNotEmpty ? book.bookImageUserUrls[0] : 'https://via.placeholder.com/100',
          ),
          backgroundColor: Colors.grey[200],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 120,
          child: Text(
            book.title,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
        SizedBox(
          width: 120,
          child: Text(
            'de ${book.author}',
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    if (_deliveryAddressList.isEmpty) {
      return Container();
    }

    return Container(
      width: double.infinity,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Endereço', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(
                _deliveryAddressList.last,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtherUserInfoSection() {
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundImage: CachedNetworkImageProvider(
            otherUserProfileUrl.isNotEmpty ? otherUserProfileUrl : 'https://via.placeholder.com/50',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                otherUserName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Row(
                children: List.generate(
                  5,
                      (index) => Icon(
                    Icons.star,
                    color: index < otherUserRating.round() ? Colors.amber : Colors.grey,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTradeDetails() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Informações da troca', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
              isRequester
                  ? 'Livro a ser Recebido:\n${requestedBook?.author ?? 'Autor desconhecido'}, ${requestedBook?.title ?? 'Título não disponível'}, Ano: ${requestedBook?.publicationYear ?? 'Ano não disponível'}'
                  : 'Livro a ser Recebido:\n${selectedOfferedBook?.author ?? 'Autor desconhecido'}, ${selectedOfferedBook?.title ?? 'Título não disponível'}, Ano: ${selectedOfferedBook?.publicationYear ?? 'Ano não disponível'}',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            Text(
              isRequester
                  ? 'Livro a ser Enviado:\n${selectedOfferedBook?.author ?? 'Autor desconhecido'}, ${selectedOfferedBook?.title ?? 'Título não disponível'}, Ano: ${selectedOfferedBook?.publicationYear ?? 'Ano não disponível'}'
                  : 'Livro a ser Enviado:\n${requestedBook?.author ?? 'Autor desconhecido'}, ${requestedBook?.title ?? 'Título não disponível'}, Ano: ${requestedBook?.publicationYear ?? 'Ano não disponível'}',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: tradeStatus == 'concluído' ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  'Status da Troca: ${tradeStatus == 'concluído' ? 'concluído' : 'cancelado'}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: tradeStatus == 'concluído' ? Colors.green : Colors.red,
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