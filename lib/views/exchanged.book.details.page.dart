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
  String requesterName = "Usuário desconhecido";
  String requesterProfileUrl = "";
  String ownerName = "Usuário desconhecido";
  String ownerProfileUrl = "";
  double requesterRating = 0.0;
  double ownerRating = 0.0;
  bool isRequester = false;
  List<String> _deliveryAddressList = [];

  @override
  void initState() {
    super.initState();
    _loadRequestData();
  }

  Future<void> _loadRequestData() async {
    try {
      final requestDoc = await FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.requestId)
          .get();

      if (requestDoc.exists) {
        final data = requestDoc.data();

        if (data != null) {
          // Carrega informações do livro solicitado e do livro ofertado
          requestedBook = BookModel.fromMap(data['requestedBook']);
          selectedOfferedBook = BookModel.fromMap((data['offeredBooks'] as List).first);

          // Verifica se o usuário atual é o solicitante
          isRequester = data['requesterId'] == user.value.uid;

          // Carrega o endereço de entrega, se disponível
          if (data['deliveryAddress'] != null) {
            _deliveryAddressList = List<String>.from(data['deliveryAddress']);
          }

          // Carrega informações do solicitante e do dono do livro
          final requesterId = data['requesterId'];
          final ownerId = data['ownerId'];

          // Carrega dados do usuário logado e do outro usuário envolvido
          await _loadUserInfo(requesterId, isRequester);
          await _loadUserInfo(ownerId, !isRequester);

          setState(() {});
        }
      }
    } catch (e) {
      print("Erro ao carregar dados do request: $e");
    }
  }

  Future<void> _loadUserInfo(String userId, bool isRequesterUser) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        if (isRequesterUser) {
          requesterName = userData['name'] ?? "Usuário desconhecido";
          requesterProfileUrl = userData['profileImageUrl'] ?? '';
          requesterRating = (userData['customerRating'] ?? 0.0).toDouble();
        } else {
          ownerName = userData['name'] ?? "Usuário desconhecido";
          ownerProfileUrl = userData['profileImageUrl'] ?? '';
          ownerRating = (userData['customerRating'] ?? 0.0).toDouble();
        }
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
            // Exibe as imagens e detalhes dos livros envolvidos na troca
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (requestedBook != null) _buildBookImage(requestedBook!),
                Icon(Icons.swap_horiz, size: 40, color: Colors.grey),
                if (selectedOfferedBook != null) _buildBookImage(selectedOfferedBook!),
              ],
            ),
            const SizedBox(height: 20),

            // Exibe o endereço, se disponível
            _buildAddressSection(),
            const SizedBox(height: 20),

            // Exibe informações dos usuários envolvidos
            _buildUserInfoSection(ownerProfileUrl, ownerName, ownerRating, "Dono do Livro"),
            const SizedBox(height: 20),
            _buildUserInfoSection(requesterProfileUrl, requesterName, requesterRating, "Solicitante"),
            const SizedBox(height: 20),

            // Exibe detalhes da troca
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
        SizedBox(
          width: 120,
          child: Text(
            'Ano: ${book.publicationYear.isNotEmpty ? book.publicationYear : 'Ano não disponível'}',
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    if (_deliveryAddressList.isEmpty) {
      return Container();
    }

    return Card(
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
    );
  }

  Widget _buildUserInfoSection(String profileUrl, String name, double rating, String role) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          role,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: CachedNetworkImageProvider(profileUrl.isNotEmpty ? profileUrl : 'https://via.placeholder.com/50'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(
                      5,
                          (index) => Icon(
                        Icons.star,
                        color: index < rating.round() ? Colors.amber : Colors.grey,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
          ],
        ),
      ),
    );
  }
}
