import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/book.model.dart';
import '../models/user.info.model.dart';
import 'trade.confirmation.page.dart';

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
  BookModel? _selectedBook;
  late BookModel requestedBook;
  late List<BookModel> offeredBooks;
  late String requesterName;
  late double requesterRating;
  late String requesterProfileUrl;
  late String ownerName;
  late String ownerProfileUrl;
  late String status;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequestDetails();
  }

  Future<void> _fetchRequestDetails() async {
    try {
      final requestDoc = await FirebaseFirestore.instance.collection('requests').doc(widget.requestId).get();
      final requesterDoc = await FirebaseFirestore.instance.collection('users').doc(requestDoc['requests']['requesterId']).get();
      if (requestDoc.exists) {
        final requestData = requestDoc.data()!;
        final requestedBookData = requestData['requestedBook'];
        final offeredBooksData = List<Map<String, dynamic>>.from(requestData['offeredBooks']);
        final requesterId = requestData['requesterId'];
        final ownerId = requestData['ownerId'];

        // Obtém informações adicionais do solicitante e do dono do livro solicitado
        final requesterDoc = await FirebaseFirestore.instance.collection('users').doc(requesterId).get();
        final requestedBookDoc = await FirebaseFirestore.instance.collection('books').doc(requestedBookData['id']).get();

        // Informações do solicitante
        if (requesterDoc.exists) {
          final requesterData = requesterDoc.data()!;
          requesterName = requesterData['name'] ?? 'Nome não encontrado';
          requesterProfileUrl = requesterData['profileImageUrl'] ?? '';
          requesterRating = requesterData['customerRating'] ?? 0;
        }

        // Informações do livro solicitado
        if (requestedBookDoc.exists) {
          final requestedBookInfo = requestedBookDoc.data()!;
          requestedBook = BookModel(
            userId: requestedBookInfo['userId'] ?? '',
            id: requestedBookData['id'] ?? '',
            title: requestedBookData['title'] ?? 'Título não disponível',
            author: requestedBookData['author'] ?? 'Autor desconhecido',
            bookImageUserUrls: [requestedBookData['imageUrl']],
            condition: requestedBookInfo['condition'] ?? 'Condição não disponível',
            publishedDate: DateTime.now(), // Ajuste a data conforme necessário
            edition: requestedBookInfo['edition'] ?? 'Edição não disponível',
            genres: [],
            isbn: '',
            publicationYear: '',
            publisher: '',
            description: '',
            isAvailable: true,
            userInfo: UInfo.fromMap(requestedBookInfo['userInfo']),
          );
        }

        // Mapeia `offeredBooks` de forma assíncrona
        offeredBooks = await Future.wait(offeredBooksData.map((bookData) async {
          final bookDoc = await FirebaseFirestore.instance.collection('books').doc(bookData['id']).get();
          if (bookDoc.exists) {
            final bookInfo = bookDoc.data()!;
            return BookModel(
              userId: bookInfo['userId'] ?? '',
              id: bookData['id'] ?? '',
              title: bookData['title'] ?? 'Título não disponível',
              author: bookData['author'] ?? 'Autor desconhecido',
              bookImageUserUrls: [bookData['imageUrl']],
              condition: bookInfo['condition'] ?? 'Condição não disponível',
              publishedDate: DateTime.now(),
              edition: bookInfo['edition'] ?? 'Edição não disponível',
              genres: [],
              isbn: '',
              publicationYear: '',
              publisher: '',
              description: '',
              isAvailable: false,
              userInfo: UInfo.fromMap(bookInfo['userInfo']),
            );
          } else {
            // Retorna um BookModel vazio caso o documento não exista
            return BookModel(
              userId: '',
              id: '',
              title: 'Título não disponível',
              author: 'Autor desconhecido',
              bookImageUserUrls: ['https://via.placeholder.com/100'],
              condition: 'Condição não disponível',
              publishedDate: DateTime.now(),
              edition: 'Edição não disponível',
              genres: [],
              isbn: '',
              publicationYear: '',
              publisher: '',
              description: '',
              isAvailable: false,
              userInfo: UInfo.empty(),
            );
          }
        }).toList());

        setState(() {
          status = requestData['status'] ?? 'Aguardando resposta';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao buscar detalhes da solicitação: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Oferta de Troca'),
          backgroundColor: const Color(0xFFD8D5B3),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Oferta de Troca'),
        backgroundColor: const Color(0xFFD8D5B3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.isRequester) ...[
              const Text('Livro Solicitado', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildRequestedBookCard(requestedBook),
              const SizedBox(height: 20),
              const Text('Livros Disponíveis para Troca', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...offeredBooks.map((offerbook) => _buildOfferedBookCard(offerbook)).toList(),
              const SizedBox(height: 20),
              Text('Status: $status', style: TextStyle(fontWeight: FontWeight.bold)),
            ] else ...[
              const Text('Seu Livro', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildRequestedBookCard(requestedBook),
              const SizedBox(height: 20),
              const Text('Livros Oferecidos', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...offeredBooks.map((book) => _buildOfferedBookCard(book)).toList(),
              const SizedBox(height: 20),
              _buildRequesterInfo(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Função para rejeitar a oferta de troca
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDD585B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: const Text('Rejeitar'),
                  ),
                  ElevatedButton(
                    onPressed: _selectedBook == null ? null : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TradeConfirmationPage(
                            requestId: widget.requestId,
                            requestedBook: requestedBook,
                            selectedOfferedBook: _selectedBook!,
                            requesterName: requesterName,
                            requesterProfileUrl: requesterProfileUrl,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF77C593),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: const Text('Confirmar'),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildOfferedBookCard(BookModel offerbook) {
    return GestureDetector(
      onTap: widget.isRequester ? null : () {
        setState(() {
          _selectedBook = offerbook;
        });
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: _selectedBook == offerbook ? Colors.green : Colors.transparent,
            width: 2,
          ),
        ),
        margin: const EdgeInsets.only(bottom: 16.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 100,
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.grey[200],
                ),
                child: offerbook.bookImageUserUrls.isNotEmpty
                    ? CachedNetworkImage(
                  imageUrl: offerbook.bookImageUserUrls[0],
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                  fit: BoxFit.cover,
                )
                    : const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(offerbook.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('De ${offerbook.author}', style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 8),
                    Text('Estado: ${offerbook.condition ?? 'Não informado'}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestedBookCard(BookModel book) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              height: 100,
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.grey[200],
              ),
              child: book.bookImageUserUrls.isNotEmpty
                  ? CachedNetworkImage(
                imageUrl: book.bookImageUserUrls[0],
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                fit: BoxFit.cover,
              )
                  : const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('De ${book.author}', style: const TextStyle(fontSize: 14)),

                  // Exibe o estado de conservação

                  Text('Estado: ${book.condition}', style: const TextStyle(fontSize: 12, color: Colors.grey)),

                  // Exibe as informações do usuário solicitante
                  if (widget.isRequester)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(requesterProfileUrl),
                            radius: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(requesterName),
                          const SizedBox(width: 8),
                          Row(
                            children: List.generate(5, (index) => Icon(Icons.star, color: Colors.amber, size: 16)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequesterInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundImage: CachedNetworkImageProvider(requesterProfileUrl),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(requesterName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Row(
              children: List.generate(5, (index) => Icon(Icons.star, color: Colors.amber, size: 16)),
            ),
          ],
        ),
      ],
    );
  }
}