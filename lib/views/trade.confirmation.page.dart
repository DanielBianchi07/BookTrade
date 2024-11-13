import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/book.model.dart';
import 'chat.page.dart';

class TradeConfirmationPage extends StatefulWidget {
  final String requestId;
  final BookModel requestedBook;
  final BookModel selectedOfferedBook;
  final String requesterName;
  final String requesterProfileUrl;
  final bool isRequester;

  const TradeConfirmationPage({
    Key? key,
    required this.requestId,
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

  @override
  void initState() {
    super.initState();
    _loadExistingAddress();
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
          _addressController.text = data['deliveryAddress'];
          _isAddressProvided = true;
          setState(() {});
        }
      }
    } catch (e) {
      print('Erro ao carregar endereço existente: $e');
    }
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
                _buildBookImage(widget.requestedBook),
                Icon(Icons.swap_horiz, size: 40, color: Colors.grey),
                _buildBookImage(widget.selectedOfferedBook),
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
                onPressed: _markAsCompleted,
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
              _addressController.text.isNotEmpty
                  ? _addressController.text
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
                      otherUserId: widget.selectedOfferedBook.userId,
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
              'Livro a ser Recebido:\n${widget.selectedOfferedBook.author}, ${widget.selectedOfferedBook.title}, Ano: ${widget.selectedOfferedBook.publicationYear}',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            Text(
              'Livro a ser Enviado:\n${widget.requestedBook.author}, ${widget.requestedBook.title}, Ano: ${widget.requestedBook.publicationYear}',
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
      await FirebaseFirestore.instance.collection('requests').doc(widget.requestId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pedido cancelado com sucesso!')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cancelar o pedido. Tente novamente.')),
      );
    }
  }

  Future<void> _confirmAddress() async {
    try {
      await FirebaseFirestore.instance.collection('requests').doc(widget.requestId).update({
        'status': 'Aguardando confirmação do recebimento',
        'deliveryAddress': _addressController.text,
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

  Future<void> _markAsCompleted() async {
    try {
      await FirebaseFirestore.instance.collection('requests').doc(widget.requestId).update({
        'status': 'concluído',
        'completedAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Troca marcada como concluída com sucesso!')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao marcar a troca como concluída. Tente novamente.')),
      );
    }
  }
}
