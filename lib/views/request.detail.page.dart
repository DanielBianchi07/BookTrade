import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/views/exchange.tracking.page.dart';
import '../models/book.model.dart';
import '../models/user.info.model.dart';
import 'chat.page.dart';
import 'home.page.dart';

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
      final requestDoc = await FirebaseFirestore.instance.collection('requests')
          .doc(widget.requestId)
          .get();
      if (requestDoc.exists) {
        final requestData = requestDoc.data()!;

        final requesterId = requestData['requesterId'];
        final ownerId = requestData['ownerId'];
        final requestedBookData = requestData['requestedBook'];
        final offeredBooksData = List<Map<String, dynamic>>.from(
            requestData['offeredBooks']);

        // Obtém informações adicionais do solicitante e do dono do livro solicitado
        final requesterDoc = await FirebaseFirestore.instance.collection(
            'users').doc(requesterId).get();
        final ownerDoc = await FirebaseFirestore.instance.collection('users')
            .doc(ownerId)
            .get();
        final requestedBookDoc = await FirebaseFirestore.instance.collection(
            'books').doc(requestedBookData['id']).get();

        // Informações do solicitante
        if (requesterDoc.exists) {
          final requesterData = requesterDoc.data()!;
          requesterName = requesterData['name'] ?? 'Nome não encontrado';
          requesterProfileUrl = requesterData['profileImageUrl'] ?? '';
          requesterRating = requesterData['customerRating'] ?? 0;
        }

        // Informações do proprietário (owner) do livro solicitado
        if (ownerDoc.exists) {
          final ownerData = ownerDoc.data()!;
          ownerName = ownerData['name'] ?? 'Nome não encontrado';
          ownerProfileUrl = ownerData['profileImageUrl'] ?? '';
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
            condition: requestedBookInfo['condition'] ??
                'Condição não disponível',
            publishedDate: DateTime.now(),
            // Ajuste a data conforme necessário
            edition: requestedBookInfo['edition'] ?? 'Edição não disponível',
            genres: [],
            isbn: '',
            publicationYear: requestedBookInfo['publicationYear'] ??
                'Ano de publicação não disponível',
            // Altere aqui
            publisher: '',
            description: '',
            isAvailable: requestedBookInfo['isAvailable'] ?? true,
            userInfo: UInfo.fromMap(requestedBookInfo['userInfo']),
          );
        }

        // Mapeia `offeredBooks` de forma assíncrona
        offeredBooks = await Future.wait(offeredBooksData.map((bookData) async {
          final bookDoc = await FirebaseFirestore.instance.collection('books')
              .doc(bookData['id'])
              .get();
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
              publicationYear: bookInfo['publicationYear'] ??
                  'Ano de publicação não disponível',
              // Altere aqui
              publisher: '',
              description: '',
              isAvailable: bookInfo['isAvailable'] ?? true,
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
              publicationYear: 'Ano de publicação não disponível',
              // Altere aqui também
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

  Future<void> _cancelTrade() async {
    try {
      // Atualiza o campo isAvailable para true em cada livro ofertado
      for (var book in offeredBooks) {
        await FirebaseFirestore.instance
            .collection('books')
            .doc(book.id)
            .update({'isAvailable': true});
      }

      // Exclui o documento de solicitação da coleção requests
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.requestId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Solicitação de troca cancelada com sucesso')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cancelar a solicitação de troca')),
      );
    }
  }

  void _showCancelConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Cancelar Troca'),
          content: Text('Tem certeza de que deseja cancelar esta troca? Esta ação não pode ser desfeita.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Não'),
            ),
            TextButton(
              onPressed: () async {
                await _cancelTrade();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(),
                  ),
                      (Route<dynamic> route) => false, // Remove todas as rotas anteriores
                );
              },
              child: Text('Sim'),
            ),
          ],
        );
      },
    );
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
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Scrollbar(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.isRequester) ...[
                          const Text('Livro Solicitado', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          _buildRequestedBookCard(requestedBook),
                          Row(
                            children: [
                              const Icon(Icons.info_outline, color: Colors.orange),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Aguardando resposta de ${requestedBook.userInfo.name}...',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text('Livro(s) Enviado(s) para Troca', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.all(10.0),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: 400,
                              ),
                              child: Scrollbar(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ...offeredBooks.map(
                                            (offerbook) => _buildOfferedBookCard(offerbook),
                                      ).toList(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 50), // Espaço extra para o botão fixo
                        ] else ...[
                          const Text('Seu Livro', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          _buildRequestedBookCard(requestedBook),
                          const SizedBox(height: 20),
                          _buildRequesterInfo(),
                          const SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.all(10.0),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: 400,
                              ),
                              child: Scrollbar(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Livro(s) Recebido(s) para Troca', style: TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Icon(Icons.info_outline, color: Colors.grey),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Selecione apenas um livro caso queira realizar a troca.',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      ...offeredBooks.map((book) => _buildOfferedBookCard(book)).toList(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 10), // Espaço para manter os botões na posição fixa
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.isRequester) // Botão fixo para o requester
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.white,
                child: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      _showCancelConfirmationDialog();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                    ),
                    child: const Text(
                      'Cancelar Troca',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (!widget.isRequester) // Botões "Rejeitar" e "Confirmar" fixos para quem não é requester
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 35.0, vertical: 20.0),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            _showCancelConfirmationDialog();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erro ao rejeitar a troca')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDD585B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: const Text(
                          'Rejeitar',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 80),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _selectedBook == null
                            ? null
                            : () async {
                          try {
                            await FirebaseFirestore.instance
                                .collection('requests')
                                .doc(widget.requestId)
                                .update({
                              'status': 'Aguardando confirmação do endereço',
                              'offeredBooks': offeredBooks
                                  .where((book) => book.id == _selectedBook!.id)
                                  .map((book) => {
                                'id': book.id,
                                'title': book.title,
                                'author': book.author,
                                'imageUrl': book.bookImageUserUrls.isNotEmpty
                                    ? book.bookImageUserUrls[0]
                                    : '',
                              })
                                  .toList(),
                            });

                            for (var book in offeredBooks) {
                              if (book.id != _selectedBook!.id) {
                                await FirebaseFirestore.instance
                                    .collection('books')
                                    .doc(book.id)
                                    .update({'isAvailable': true});
                              }
                            }

                            await FirebaseFirestore.instance
                                .collection('books')
                                .doc(requestedBook.id)
                                .update({'isAvailable': false});

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Troca confirmada, aguardando confirmação do endereço'),
                              ),
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ExchangeTrackingPage(),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erro ao confirmar a troca')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF77C593),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: const Text(
                          'Confirmar',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
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
            color: _selectedBook == offerbook ? Colors.green : Colors
                .transparent,
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
                  placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                  const Icon(
                      Icons.image_not_supported, size: 50, color: Colors.grey),
                  fit: BoxFit.cover,
                )
                    : const Icon(
                    Icons.image_not_supported, size: 50, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(offerbook.title, style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('De ${offerbook.author}',
                        style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 8),
                    Text('Estado: ${offerbook.condition ?? 'Não informado'}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey)),
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
                placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                const Icon(
                    Icons.image_not_supported, size: 50, color: Colors.grey),
                fit: BoxFit.cover,
              )
                  : const Icon(
                  Icons.image_not_supported, size: 50, color: Colors.grey),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title, style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('De ${book.author}',
                      style: const TextStyle(fontSize: 14)),

                  // Exibe o estado de conservação
                  Text('Estado: ${book.condition}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),

                  // Exibe as informações do proprietário (owner) do livro solicitado se `isRequester` for true
                  if (widget.isRequester)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(
                                ownerProfileUrl!),
                            radius: 20,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ownerName ?? 'Nome não encontrado'),
                              const SizedBox(height: 4),
                              Row(
                                children: List.generate(5, (index) => Icon(
                                    Icons.star, color: Colors.amber,
                                    size: 16)),
                              ),
                            ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Solicitante',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: CachedNetworkImageProvider(requesterProfileUrl),
                ),
                const SizedBox(height: 4),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    requesterName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(
                      5,
                          (index) => Icon(Icons.star, color: Colors.amber, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.chat_bubble_outline, color: Colors.black),
              onPressed: () {
                // Ação ao clicar no ícone de chat
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      otherUserId: offeredBooks.first.userId,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}