import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/book.model.dart';
import 'chat.page.dart';

class TradeConfirmationPage extends StatefulWidget {
  final String requestId;
  final String otherUserId;
  final BookModel requestedBook;
  final BookModel selectedOfferedBook;
  final String requesterName;
  final String requesterProfileUrl;
  final bool isRequester;

  const TradeConfirmationPage({
    Key? key,
    required this.requestId,
    required this. otherUserId,
    required this.requestedBook,
    required this.selectedOfferedBook,
    required this.requesterName,
    required this.requesterProfileUrl,
    required this.isRequester,
  }) : super(key: key);

  @override
  _TradeConfirmationPageState createState() => _TradeConfirmationPageState();
}

class _TradeConfirmationPageState extends State<TradeConfirmationPage> {
  final TextEditingController _addressController = TextEditingController();
  bool _isAddressProvided = false;
  List<String> _deliveryAddressList = [];
  BookModel? requestedBook;
  BookModel? selectedOfferedBook;

  @override
  void initState() {
    super.initState();
    _loadExistingAddress();
    _initializeConfirmationStatus();
    fetchRequestedBookData();
    fetchSelectedBookData();
  }

  Future<void> fetchRequestedBookData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('books')
          .doc(widget.requestedBook.id)
          .get();

      if (snapshot.exists) {
        setState(() {
          requestedBook = BookModel.fromMap(snapshot.data()!);
        });
      } else {
        print("O documento requestedBook não foi encontrado.");
      }
    } catch (e) {
      print("Erro ao buscar o documento: $e");
    }
  }

  Future<void> fetchSelectedBookData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('books')
          .doc(widget.selectedOfferedBook.id)
          .get();

      if (snapshot.exists) {
        setState(() {
          selectedOfferedBook = BookModel.fromMap(snapshot.data()!);
        });
      } else {
        print("O documento selectedOfferedBook não foi encontrado.");
      }
    } catch (e) {
      print("Erro ao buscar o documento: $e");
    }
  }

  Future<void> _loadExistingAddress() async {
    try {
      final requestDoc = await FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.requestId)
          .get();
      if (requestDoc.exists) {
        final data = requestDoc.data();
        if (data != null && data['deliveryAddress'] != null) {
          _deliveryAddressList = List<String>.from(data['deliveryAddress']);
          if (_deliveryAddressList.isNotEmpty) {
            _addressController.text = _deliveryAddressList.last;
            _isAddressProvided = true;
            setState(() {});
          }
        }
      }
    } catch (e) {
      print('Erro ao carregar endereço existente: $e');
    }
  }

  Future<void> _initializeConfirmationStatus() async {
    final requestRef = FirebaseFirestore.instance.collection('requests').doc(widget.requestId);

    await requestRef.get().then((doc) {
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          if (!data.containsKey('requesterConfirmationStatus')) {
            requestRef.update({'requesterConfirmationStatus': 'Aguardando confirmação'});
          }
          if (!data.containsKey('ownerConfirmationStatus')) {
            requestRef.update({'ownerConfirmationStatus': 'Aguardando confirmação'});
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Finalizar Troca'),
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
                if (requestedBook != null)
                _buildBookImage(requestedBook!),
                Icon(Icons.swap_horiz, size: 40, color: Colors.grey),
                if (selectedOfferedBook != null)
                  _buildBookImage(selectedOfferedBook!),
              ],
            ),
            const SizedBox(height: 20),
            _buildAddressSection(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _showCancelConfirmationDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text('Cancelar'),
                ),
                if (!widget.isRequester)
                  ElevatedButton(
                    onPressed: _isAddressProvided ? _confirmAddress : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF77C593),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: const Text('Confirmar endereço'),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            if (!widget.isRequester) _buildRequesterInfo(),
            const SizedBox(height: 20),
            _buildTradeDetails(),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _deliveryAddressList.isNotEmpty ? _showMarkAsCompletedDialog : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Text('Marcar como concluído'),
              ),
            ),
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
            book.bookImageUserUrls.isNotEmpty ? book.bookImageUserUrls[0] : '',
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
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Endereço', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            widget.isRequester
                ? Text(
              _deliveryAddressList.isNotEmpty
                  ? _deliveryAddressList.last
                  : 'Aguardando confirmação do endereço...',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            )
                : TextField(
              controller: _addressController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Insira o endereço de troca combinado',
              ),
              onChanged: (value) {
                setState(() {
                  _isAddressProvided = value.isNotEmpty;
                });
              },
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
        Text(
          'Solicitante',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: CachedNetworkImageProvider(widget.requesterProfileUrl),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.requesterName,
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      otherUserId: widget.otherUserId,
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
              widget.isRequester
                  ? 'Livro a ser Recebido:\n${widget.requestedBook.author}, ${widget.requestedBook.title}, Ano: ${requestedBook?.publicationYear ?? 'Ano não disponível'}'
                  : 'Livro a ser Recebido:\n${widget.selectedOfferedBook.author}, ${widget.selectedOfferedBook.title}, Ano: ${selectedOfferedBook?.publicationYear ?? 'Ano não disponível'}',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            Text(
              widget.isRequester
                  ? 'Livro a ser Enviado:\n${widget.selectedOfferedBook.author}, ${widget.selectedOfferedBook.title}, Ano: ${selectedOfferedBook?.publicationYear ?? 'Ano não disponível'}'
                  : 'Livro a ser Enviado:\n${widget.requestedBook.author}, ${widget.requestedBook.title}, Ano: ${requestedBook?.publicationYear ?? 'Ano não disponível'}',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
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
                Navigator.of(context).pop();
                await _cancelTrade();
              },
              child: Text('Sim'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelTrade() async {
    try {
      final requestRef = FirebaseFirestore.instance.collection('requests').doc(widget.requestId);
      final requestData = await requestRef.get();

      if (requestData.exists) {
        final data = requestData.data();
        final requesterConfirmationStatus = data?['requesterConfirmationStatus'] ?? 'Aguardando confirmação';
        final ownerConfirmationStatus = data?['ownerConfirmationStatus'] ?? 'Aguardando confirmação';
        final deliveryAddressList = List<String>.from(data?['deliveryAddress'] ?? []);

        // Verifica se a lista de endereços está vazia
        final isAddressEmpty = deliveryAddressList.isEmpty;

        // Determina qual status de confirmação deve ser atualizado para "cancelado"
        if (widget.isRequester) {
          await requestRef.update({'requesterConfirmationStatus': 'cancelado'});
        } else {
          await requestRef.update({'ownerConfirmationStatus': 'cancelado'});
        }

        // Se nenhum endereço foi adicionado, atualiza ambos os livros para isAvailable: true e exclui o request
        if (isAddressEmpty) {
          await FirebaseFirestore.instance
              .collection('books')
              .doc(widget.requestedBook.id)
              .update({'isAvailable': true});

          await FirebaseFirestore.instance
              .collection('books')
              .doc(widget.selectedOfferedBook.id)
              .update({'isAvailable': true});

          await requestRef.delete();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pedido excluído pois nenhum endereço foi registrado.')),
          );

          Navigator.of(context).pop();
          return;
        }

        // Atualiza apenas o livro do usuário que está cancelando para isAvailable: true
        final bookIdToUpdate = widget.isRequester ? widget.selectedOfferedBook.id : widget.requestedBook.id;
        await FirebaseFirestore.instance
            .collection('books')
            .doc(bookIdToUpdate)
            .update({'isAvailable': true});

        // Checa se ambos os status estão como "cancelado" e muda o status do request para "cancelado" se necessário
        final bothCancelled = requesterConfirmationStatus == 'cancelado' && ownerConfirmationStatus == 'cancelado';
        final oneCancelledOneConfirmed =
            (requesterConfirmationStatus == 'concluído' && ownerConfirmationStatus == 'cancelado') ||
                (requesterConfirmationStatus == 'cancelado' && ownerConfirmationStatus == 'concluído');

        if (bothCancelled) {
          await requestRef.update({'status': 'cancelado'});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pedido marcado como cancelado com sucesso!')),
          );
        } else if (oneCancelledOneConfirmed) {
          await requestRef.update({
            'status': 'Finalizado com divergência',
            'completedAt': FieldValue.serverTimestamp(),
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pedido finalizado com divergência.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cancelamento registrado com sucesso!')),
          );
        }

        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cancelar o pedido. Tente novamente.')),
      );
    }
  }

  Future<void> _confirmAddress() async {
    try {
      _deliveryAddressList.add(_addressController.text);
      await FirebaseFirestore.instance.collection('requests').doc(widget.requestId).update({
        'status': 'Aguardando confirmação do recebimento',
        'deliveryAddress': _deliveryAddressList,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Endereço confirmado com sucesso! Aguardando confirmação do recebimento.')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao confirmar o endereço. Tente novamente.')),
      );
    }
  }

  void _showMarkAsCompletedDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmar Conclusão'),
          content: Text('Tem certeza de que deseja marcar a troca como concluída? Esta ação não poderá ser desfeita.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Não'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Fecha o diálogo de confirmação antes
                //_showRatingDialog(); // Mostra o pop-up de avaliação
                await _markAsCompleted();
              },
              child: Text('Sim'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _markAsCompleted() async {
    try {
      final requestRef = FirebaseFirestore.instance.collection('requests').doc(widget.requestId);
      final requestData = await requestRef.get();

      if (requestData.exists) {
        final data = requestData.data();
        final requesterConfirmationStatus = data?['requesterConfirmationStatus'];
        final ownerConfirmationStatus = data?['ownerConfirmationStatus'];

        if (widget.isRequester) {
          await requestRef.update({'requesterConfirmationStatus': 'concluído'});
        } else {
          await requestRef.update({'ownerConfirmationStatus': 'concluído'});
        }

        final bothConfirmed = requesterConfirmationStatus == 'concluído' && ownerConfirmationStatus == 'concluído';
        final oneCancelledOneConfirmed =
            (requesterConfirmationStatus == 'concluído' && ownerConfirmationStatus == 'cancelado') ||
                (requesterConfirmationStatus == 'cancelado' && ownerConfirmationStatus == 'concluído');

        if (bothConfirmed) {
          // Ambos confirmaram, o status é atualizado para "concluído"
          await requestRef.update({
            'status': 'concluído',
            'completedAt': FieldValue.serverTimestamp(),
          });
        } else if (oneCancelledOneConfirmed) {
          // Um confirmou e o outro cancelou, atualiza o status para "Finalizado com divergência"
          await requestRef.update({
            'status': 'Finalizado com divergência',
            'completedAt': FieldValue.serverTimestamp(),
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Confirmação de troca registrada com sucesso!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao marcar a troca como concluída. Tente novamente.')),
      );
    }
  }

  void _showRatingDialog() {
    double rating = 3.0; // Avaliação inicial
    String otherUserId = widget.otherUserId;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Avalie o outro usuário'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Por favor, avalie a experiência com o outro usuário.'),
                  SizedBox(height: 10),
                  Slider(
                    value: rating,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: rating.toString(),
                    onChanged: (newRating) {
                      setState(() {
                        rating = newRating;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(); // Fecha o diálogo de avaliação
                    await _updateCustomerRating(rating, otherUserId); // Atualiza a avaliação do outro usuário
                  },
                  child: Text('Enviar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateCustomerRating(double rating, String otherUserId) async {
    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(otherUserId);
      final userData = await userRef.get();

      if (userData.exists) {
        final currentRating = (userData.data()?['customerRating'] ?? 0.0) as double;
        final totalRatings = (userData.data()?['totalRatings'] ?? 0) as int;

        // Calcula o novo rating médio
        final newTotalRatings = totalRatings + 1;
        final newRating = ((currentRating * totalRatings) + rating) / newTotalRatings;

        await userRef.update({
          'customerRating': newRating,
          'totalRatings': newTotalRatings,
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: Usuário não encontrado.')),
        );
      }
    } catch (e) {
      print("Erro ao atualizar a avaliação do usuário: $e"); // Log do erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar a avaliação do usuário: $e')),
      );
    }
  }
}
