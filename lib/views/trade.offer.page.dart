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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carrossel de Imagens com Setas
            Stack(
              children: [
                SizedBox(
                  height: 300,
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
                // Setas para navegar no carrossel
                if (_currentPage > 0)
                  Positioned(
                    left: 10,
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
                if (_currentPage < widget.book.bookImageUserUrls.length - 1)
                  Positioned(
                    right: 10,
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
            ),
            const SizedBox(height: 20),

            // Informações do Livro
            Text(
              widget.book.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Autor: ${widget.book.author}\nPublicado em: ${widget.book.publicationYear}',
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 5),
            Text('Condição: ${widget.book.condition}', style: const TextStyle(fontSize: 14)),
            Text('Edição: ${widget.book.edition}', style: const TextStyle(fontSize: 14)),
            Text('Gêneros: ${widget.book.genres?.join(', ') ?? 'N/A'}', style: const TextStyle(fontSize: 14)),
            Text('ISBN: ${widget.book.isbn ?? 'N/A'}', style: const TextStyle(fontSize: 14)),
            Text('Editora: ${widget.book.publisher}', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 20),

            // Sinopse do Livro
            const Text(
              'Sinopse',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(widget.book.description ?? 'Sinopse não disponível', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),

            // Informação do Usuário e Avaliação com Estrelas
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...List.generate(widget.book.userInfo.customerRating.floor(), (index) {
                          return const Icon(Icons.star, color: Colors.amber, size: 18);
                        }),
                        if (widget.book.userInfo.customerRating - widget.book.userInfo.customerRating.floor() >= 0.5)
                          const Icon(Icons.star_half, color: Colors.amber, size: 18),
                        ...List.generate((5 - widget.book.userInfo.customerRating.ceil()), (index) {
                          return const Icon(Icons.star_border, color: Colors.amber, size: 18);
                        }),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Botão de Solicitar
            Center(
              child: ElevatedButton(
                onPressed: _checkAvailabilityAndRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF77C593),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Solicitar'),
              ),
            ),
          ],
        ),
      ),
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
}
