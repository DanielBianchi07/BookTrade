import 'package:flutter/material.dart';


class TradeOfferPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFD8D5B3), // Cor amarelada na parte superior
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop(); // Seta de navegação para voltar
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carrossel de Imagens
            Container(
              height: 200,
              child: PageView(
                children: [
                  _buildBookImage('https://via.placeholder.com/150'), // Imagem de exemplo
                  _buildBookImage('https://via.placeholder.com/150'),
                  _buildBookImage('https://via.placeholder.com/150'),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Informações do Livro
            Text(
              'Código Da Vinci',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Autor: Dan Brown\nEdição: 8\nISBN: 2a18s76zc\nPublicado em: 1990\nEditora: Gota de peroba\nEstado de conservação: Novo',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
            SizedBox(height: 20),
            // Sinopse do Livro
            Text(
              'Sinopse',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Era uma vez um homem montado em um cavalo branco de napoleão que saiu de um buraco negro soltando arco íris. '
              'Ver mais...',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),

            // Informação do Usuário
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Imagem do perfil do usuário
                  radius: 25,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'José Almeida',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(Icons.star, color: Colors.amber, size: 16);
                      }),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),

            // Botões de Solicitar e Chat
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Lógica para solicitar troca
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF77C593), // Cor verde do botão "Solicitar"
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text('Solicitar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/chat');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Cor azul do botão "Chat"
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text('Chat'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Função para construir a imagem do livro no carrossel
  Widget _buildBookImage(String imageUrl) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.0),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
      ),
    );
  }
}