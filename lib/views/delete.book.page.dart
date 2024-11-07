import 'package:flutter/material.dart';
import '../models/book.model.dart'; // Importe o modelo Book
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DeleteBookPage extends StatelessWidget {
  final BookModel book; // Receber o livro como argumento

  const DeleteBookPage({super.key, required this.book});

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
            // Carrossel de Imagens
            SizedBox(
              height: 200,
              child: PageView(
                children: [
                  _buildBookImage(book.imageUserUrl), // Imagem do livro
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Informações do Livro
            Text(
              book.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Autor: ${book.author}\nPublicado em: ${book.publishedDate.year}',
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 0),
            Text(
              'Condição: ${book.condition}\nEdição: ${book.edition}\nGêneros: ${book.genres?.join(', ') ?? 'N/A'}\nISBN: ${book.isbn ?? 'N/A'}\nAno de publicação: ${book.publicationYear}\nEditora: ${book.publisher}',
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            // Sinopse do Livro
            const Text(
              'Sinopse',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Aqui você pode adicionar uma sinopse se estiver disponível...',
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            // Botões de Solicitar e Chat
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _confirmDelete(context, book.id); // Chama a função de confirmação
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFDD585B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Excluir'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookImage(String imageUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
      ),
    );
  }

  // Função para confirmar a exclusão do livro
  Future<void> _confirmDelete(BuildContext context, String bookId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // O usuário deve tocar em um botão
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Você tem certeza que deseja excluir este livro?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Excluir'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteBook(bookId, context); // Chama a função de exclusão
              },
            ),
          ],
        );
      },
    );
  }

  // Função para excluir o livro
  Future<void> _deleteBook(String bookId, BuildContext context) async {
    try {
      // Obtém o usuário logado
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário não está logado')),
        );
        return;
      }

      // Exclui o livro da coleção Firestore
      await FirebaseFirestore.instance.collection('books').doc(bookId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Livro removido com sucesso!')),
      );

      // Retorna para a página anterior (opcional)
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir o livro: $e')),
      );
    }
  }
}
