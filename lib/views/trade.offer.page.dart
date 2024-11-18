import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/book.model.dart';
import 'request.page.dart';

class TradeOfferPage extends StatefulWidget {
  final BookModel book;

  const TradeOfferPage({Key? key, required this.book}) : super(key: key);

  @override
  _TradeOfferPageState createState() => _TradeOfferPageState();
}

class _TradeOfferPageState extends State<TradeOfferPage> {
  int _currentPage = 0; // Página atual no carrossel
  final PageController _pageController = PageController();
  bool showFullDescription = false;
  final ScrollController _scrollController = ScrollController();

  Future<void> _checkAvailabilityAndRequest() async {
    try {
      final bookDoc = await FirebaseFirestore.instance
          .collection('books')
          .doc(widget.book.id)
          .get();

      if (bookDoc.exists && bookDoc.data()?['isAvailable'] == true) {
        // Se o livro ainda está disponível, navega para a página de solicitação
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RequestPage(book: widget.book),
          ),
        );
      } else {
        // Se o livro não está mais disponível, exibe uma mensagem
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('O livro não está mais disponível para troca.')),
        );
      }
    } catch (e) {
      print("Erro ao verificar disponibilidade: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao verificar a disponibilidade do livro. Tente novamente.')),
      );
    }
  }

  Widget _buildScrollableBookDetails() {
    final details = [
      {
        'icon': Icons.apartment,
        'label': 'Editora',
        'value': widget.book.publisher,
      },
      {
        'icon': Icons.qr_code,
        'label': 'ISBN-10',
        'value': widget.book.isbn ?? 'N/A',
      },
      {
        'icon': Icons.book,
        'label': 'Condição',
        'value': widget.book.condition,
      },
      {
        'icon': Icons.format_list_numbered,
        'label': 'Edição',
        'value': widget.book.edition,
      },
      {
        'icon': Icons.category,
        'label': 'Gênero',
        'value': widget.book.genres?.join(', ') ?? 'N/A',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Informações do Livro',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 10),
        Container(
          height: 115, // Altura fixa para os itens
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: details.length,
            itemBuilder: (context, index) {
              final detail = details[index];
              return Container(
                width: 110, // Largura fixa para cada item
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(detail['icon'] as IconData, size: 30, color: Colors.black),
                    const SizedBox(height: 8),
                    Text(
                      detail['label'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detail['value'] as String,
                      style: const TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildImageCarousel() {
    return Stack(
      children: [
        SizedBox(
          height: 250,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.book.bookImageUserUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildBookImage(widget.book.bookImageUserUrls[index]);
            },
          ),
        ),
        // Seta para a esquerda
        if (_currentPage > 0)
          Positioned(
            left: -10,
            top: 125,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),
        // Seta para a direita
        if (_currentPage < widget.book.bookImageUserUrls.length - 1)
          Positioned(
            right: -10,
            top: 125,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_ios, color: Colors.black),
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildBookImage(String imageUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD8D5B3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carrossel de Imagens com Setas
                _buildImageCarousel(),
                const SizedBox(height: 10),

                // Título e Autor
                Text(
                  widget.book.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'De: ${widget.book.author}, ${widget.book.publicationYear}',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),

                // Linha de separação
                Divider(color: Colors.grey.shade400, thickness: 1),
                const SizedBox(height: 10),

                // Detalhes do Livro
                _buildScrollableBookDetails(),
                const SizedBox(height: 10),

                // Linha de separação
                Divider(color: Colors.grey.shade400, thickness: 1),
                const SizedBox(height: 10),
                const Text(
                  'Dono do Livro',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                // Informação do Usuário
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(widget.book.userInfo.profileImageUrl),
                      radius: 25,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.book.userInfo.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            ...List.generate(widget.book.userInfo.customerRating.floor(), (index) {
                              return const Icon(Icons.star, color: Colors.amber, size: 18);
                            }),
                            if (widget.book.userInfo.customerRating -
                                widget.book.userInfo.customerRating.floor() >=
                                0.5)
                              const Icon(Icons.star_half, color: Colors.amber, size: 18),
                            ...List.generate((5 - widget.book.userInfo.customerRating.ceil()), (index) {
                              return const Icon(Icons.star_border, color: Colors.amber, size: 18);
                            }),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.book.userInfo.address!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 128, 128, 128), // Cinza médio
                            ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Linha de separação
                Divider(color: Colors.grey.shade400, thickness: 1),
                const SizedBox(height: 10),

                // Sinopse do Livro
                const Text(
                  'Sinopse',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _buildDescription(),
                ),
                const SizedBox(height: 5),
                const SizedBox(height: 100), // Espaçamento para o botão fixo
              ],
            ),
          ),

          // Botão de Solicitar fixo na parte inferior
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: _checkAvailabilityAndRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Fundo branco
                  side: const BorderSide(color: Color(0xFF77C593), width: 2), // Borda verde
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text(
                  'Solicitar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF77C593), // Texto verde
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    // Verifica se a descrição é nula ou vazia
    if (widget.book.description == null || widget.book.description!.trim().isEmpty) {
      return const Text(
        'Sinopse não disponível.',
        style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
      );
    }

    final text = showFullDescription
        ? widget.book.description!
        : (widget.book.description!.length > 200
        ? '${widget.book.description!.substring(0, 200)}...'
        : widget.book.description!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: const TextStyle(fontSize: 16),
        ),
        if (widget.book.description!.length > 200)
          GestureDetector(
            onTap: () {
              setState(() {
                showFullDescription = !showFullDescription;
              });
            },
            child: Text(
              showFullDescription ? 'Ver menos' : 'Ver mais...',
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}
