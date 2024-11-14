import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controller/books.controller.dart';
import '../controller/login.controller.dart';
import '../models/book.model.dart';
import '../services/chats.service.dart';
import '../user.dart';
import 'selected.book.page.dart';

class RequestPage extends StatefulWidget {
  final BookModel book;

  const RequestPage({super.key, required this.book});

  @override
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  final loginController = LoginController();
  final booksController = BooksController();
  final ChatsService chatsService = ChatsService();
  late final String userId;
  final List<BookModel> _books = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Enviar Pedido'),
        backgroundColor: const Color(0xFFD8D5B3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Livro Desejado', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5A5A5A))),
            const SizedBox(height: 10),
            _buildDesiredBookCard(widget.book),
            const SizedBox(height: 20),

            // Container que envolve "Livros Selecionados" e a área de rolagem
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row com título "Livros Selecionados" e botão "Adicionar Livro" à direita
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Livros Selecionados',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5A5A5A)),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final selectedBook = await Navigator.push<BookModel>(
                            context,
                            MaterialPageRoute(builder: (context) => SelectedBookPage()),
                          );

                          if (selectedBook != null) {
                            bool bookExists = _books.any((existingBook) => existingBook.id == selectedBook.id);
                            if (bookExists) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Este livro já foi adicionado!')),
                              );
                            } else {
                              setState(() {
                                _books.add(selectedBook);
                              });
                            }
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_circle, color: Color.fromARGB(255, 82, 82, 82)),
                            SizedBox(width: 8),
                            Text(
                              'Adicionar Livro',
                              style: TextStyle(color: Color.fromARGB(255, 82, 82, 82)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  // Caixa de rolagem de livros selecionados com altura adaptável
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 300, // Altura máxima da área de rolagem
                    ),
                    child: Scrollbar(
                      thumbVisibility: true, // Mostra a barra de rolagem ao lado
                      child: _books.isEmpty
                          ? SizedBox(
                        height: 50, // Altura mínima apenas para a mensagem
                        child: Center(
                          child: Text(
                            'Nenhum livro selecionado ainda',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ),
                      )
                          : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _books.length,
                        itemBuilder: (context, index) {
                          final book = _books[index];
                          return _buildUserBookCard(book);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            // Texto informativo com ícone
            Row(
              children: const [
                Icon(Icons.info, color: Colors.grey, size: 16),
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Os livros enviados para troca não ficarão disponíveis até que a pessoa responda.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 35.0, horizontal: 32.0), // Ajusta a posição dos botões para cima
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              width: 150, // Define uma largura fixa para os botões
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDD585B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Text('Cancelar', style: TextStyle(color: Colors.black)),
              ),
            ),
            SizedBox(
              width: 150, // Define uma largura fixa para os botões
              child: ElevatedButton(
                onPressed: () {
                  // Verificação de livros selecionados antes de mostrar o pop-up
                  if (_books.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Adicione pelo menos um livro para troca.')),
                    );
                  } else {
                    _showConfirmationDialog(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF77C593),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Text('Enviar', style: TextStyle(color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Função para exibir o pop-up de confirmação
  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmação de Envio'),
          content: Text(
            'Seus livros só voltarão a ficar disponíveis para você quando a pessoa responder. '
                'Caso ela escolha um livro, os outros ficarão disponíveis novamente, ou se a troca for rejeitada, '
                'todos os livros enviados voltarão para você.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Fecha o pop-up
              child: Text('Voltar'),
            ),
            TextButton(
              onPressed: () async {
                await _handleRequestSubmission(); // Executa o envio da solicitação
                Navigator.of(context).pushNamed('/tradeStatus');// Navega para a página de status
              },
              child: Text('Continuar'),
            ),
          ],
        );
      },
    );
  }

// Função para processar o envio da solicitação
  Future<void> _handleRequestSubmission() async {
    if (_books.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Adicione pelo menos um livro para troca.')),
      );
      return;
    }
    final userCredential = FirebaseAuth.instance.currentUser;
    if (userCredential == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuário não autenticado.')),
      );
      return;
    }

    final requestData = {
      'requestedBook': {
        'id': widget.book.id,
        'title': widget.book.title,
        'author': widget.book.author,
        'imageUrl': widget.book.bookImageUserUrls[0],
      },
      'offeredBooks': _books.map((book) => {
        'id': book.id,
        'title': book.title,
        'author': book.author,
        'imageUrl': book.bookImageUserUrls[0],
      }).toList(),
      'requesterId': userCredential.uid,
      'ownerId': widget.book.userId,
      'status': 'pending',
      'createdAt': Timestamp.now(),
    };

    try {
      // Salva a solicitação no Firestore
      await FirebaseFirestore.instance.collection('requests').add(requestData);

      // Atualiza o campo isAvailable para false para cada livro oferecido
      for (var book in _books) {
        await FirebaseFirestore.instance
            .collection('books')
            .doc(book.id)
            .update({'isAvailable': false});
      }

      // Exibe a mensagem de sucesso para o usuário
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Solicitação enviada com sucesso!')),
      );

      // Cria uma nova conversa com o destinatário da solicitação
      await chatsService.newChat(
        senderId: user.value.uid,
        receiverId: widget.book.userInfo.id,
        timestamp: FieldValue.serverTimestamp(),
      );

      // Exibe uma mensagem adicional informando sobre a criação da conversa
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uma conversa foi criada para que você possa combinar detalhes da troca.')),
      );
    } catch (e) {
      print('Erro ao enviar a solicitação: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar a solicitação. Tente novamente.')),
      );
    }
  }

  Widget _buildDesiredBookCard(BookModel book) {
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
              child: CachedNetworkImage(
                imageUrl: book.bookImageUserUrls[0],
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('De ${book.author}', style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('Publicado em: ${book.publishedDate.year}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('Estado: ${book.condition}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserBookCard(BookModel book) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
              child: CachedNetworkImage(
                imageUrl: book.bookImageUserUrls[0],
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('De ${book.author}', style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(
                    'Postado em: ${DateFormat.yMMMd().format(book.publishedDate)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                _removeBook(book);
              },
              icon: const Icon(Icons.remove_circle, color: Color.fromARGB(255, 82, 82, 82)),
            ),
          ],
        ),
      ),
    );
  }

  void _removeBook(BookModel book) {
    setState(() {
      _books.remove(book);
    });
  }
}
