import 'package:flutter/material.dart';
import 'trade.offer.page.dart';  // Certifique-se de importar a página TradeOfferPage
import '../models/book.dart';    // Importe o modelo Book

class HomePage extends StatelessWidget {
  final List<Book> books = [];  // Exemplo de lista de livros

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
      ),
      body: ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return InkWell(
            onTap: () {
              // Navegar para a página TradeOfferPage passando o livro selecionado
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TradeOfferPage(book: book), // Passando o livro
                ),
              );
            },
            child: Card(
              child: ListTile(
                leading: Image.network(book.imageUrl),
                title: Text(book.title),
                subtitle: Text(book.author),
              ),
            ),
          );
        },
      ),
    );
  }
}
