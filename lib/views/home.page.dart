import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myapp/controller/login.controller.dart';

import 'login.page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Chave global para acessar o Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final loginController = new LoginController();
  var busy = false;

  handleSignOut() {
    setState(() {
      busy = true;
    });
    loginController.logout().then((data) {
      onSuccess();
    }).whenComplete(() {
      onComplete();
    });
  }

  onSuccess() {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage(),
        ),
    );
  }

  onError(e) {
    Fluttertoast.showToast(
      msg: "Erro ao sair: $e",
      toastLength: Toast.LENGTH_LONG,
    );
  }

  onComplete() {
    setState(() {
      busy = false;
    });
  }

  // Lista para gerenciar o estado dos corações (favoritados ou não)
  List<bool> favoriteStatus = [false, false, false]; // Exemplo com 3 itens
  List<bool> favoriteStatusAround = [false, false]; // Exemplo com 3 itens

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white, // Cor de fundo branca para o aplicativo
      appBar: AppBar(
        backgroundColor: const Color(0xFFD8D5B3), // Cor amarelada apenas na parte de cima
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black), // Ícone do menu hambúrguer no lado esquerdo
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barra de pesquisa mais estreita e com borda verde
            Container(
              height: 28, // Reduzindo ainda mais a altura da barra de pesquisa
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green, width: 1.5), // Borda verde
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.grey, size: 18), // Ícone menor
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar...',
                        hintStyle: TextStyle(fontSize: 14), // Fonte menor para o placeholder
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            // Endereço logo abaixo da barra de pesquisa
            const Row(
              children: [
                Icon(Icons.location_on, color: Colors.green, size: 18), // Ícone menor
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Endereço 1 - Bairro',
                    style: TextStyle(color: Colors.black, fontSize: 12), // Tamanho da fonte reduzido
                    overflow: TextOverflow.ellipsis, // Caso o texto seja muito longo
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho do menu com foto, endereço, estrelas, e botão de edição
            Container(
              color: const Color(0xFFD8D5B3), // Cor amarelada semelhante à AppBar
              padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 16.0),
              child: Stack(
                children: [
                  Column(
                    children: [
                      const Center(
                        child: CircleAvatar(
                          backgroundImage: NetworkImage('https://i.pravatar.cc/300'), // Substituir pela URL da imagem do perfil
                          radius: 40,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Nome do usuário
                      const Text(
                        'Fulano da Silva',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      // Endereço do usuário
                      const Text(
                        'Address',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      // Estrelas de avaliação
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return const Icon(Icons.star, color: Colors.amber, size: 18);
                        }),
                      ),
                    ],
                  ),
                  // Botão de edição no canto inferior direito
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/editProfile'); // Navegação para a página de edição
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Opções do menu
            ListTile(
              leading: const Icon(Icons.book, color: Colors.black),
              title: const Text('Meus livros'),
              onTap: () {
                Navigator.pushNamed(context, '/publicatedBooks');
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.black),
              title: const Text('Histórico de trocas'),
              onTap: () {Navigator.pushNamed(context, '/tradeHistory');},
            ),
            ListTile(
              leading: const Icon(Icons.notifications, color: Colors.black),
              title: const Text('Notificações'),
              onTap: () {Navigator.pushNamed(context, '/notifications');},
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz, color: Colors.black),
              title: const Text('Status de trocas'),
              onTap: () {Navigator.pushNamed(context, '/tradeStatus');},
            ),
            ListTile(
              leading: const Icon(Icons.favorite, color: Colors.black),
              title: const Text('Lista de desejos'),
              onTap: () {
                Navigator.pushNamed(context, '/favoriteBooks');
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.black),
              title: const Text('Chat'),
              onTap: () {Navigator.pushNamed(context, '/chats');},
            ),
            // Opção de sair
            const Spacer(),
            ListTile(
              title: const Text(
                'Sair',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                handleSignOut();
              },
            ),
          ],
        ),
      ),




      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seção Recomendações
            const Text(
              'Recomendados:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: favoriteStatus.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {Navigator.pushNamed(context, '/tradeOffer');},
                  child: BookCard(
                    title: '1984',
                    author: 'De George Orwell',
                    postedBy: 'José Almeida',
                    imageUrl: 'https://via.placeholder.com/150',
                    profileImageUrl: 'https://via.placeholder.com/50',
                    isFavorite: favoriteStatus[index],
                    rating: 4.5,
                    onFavoritePressed: () {
                      setState(() {
                        favoriteStatus[index] = !favoriteStatus[index];
                      });
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Seção Perto de você
            const Text(
              'Pertos de você:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: favoriteStatusAround.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {Navigator.pushNamed(context, '/tradeOffer');},
                  child: BookCard(
                    title: '1984',
                    author: 'De George Orwell',
                    postedBy: 'José Almeida',
                    imageUrl: 'https://via.placeholder.com/150',
                    profileImageUrl: 'https://via.placeholder.com/50',
                    isFavorite: favoriteStatusAround[index],
                    rating: 4.5,
                    onFavoritePressed: () {
                      setState(() {
                        favoriteStatusAround[index] = !favoriteStatusAround[index];
                      });
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/newBook');// Ação para adicionar um novo livro
        },
        backgroundColor: const Color(0xFF77C593), // Cor verde usada no app
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  final String title;
  final String author;
  final String postedBy;
  final String imageUrl;
  final String profileImageUrl;
  final bool isFavorite;
  final double rating;
  final VoidCallback onFavoritePressed;

  const BookCard({super.key,
    required this.title,
    required this.author,
    required this.postedBy,
    required this.imageUrl,
    required this.profileImageUrl,
    required this.isFavorite,
    required this.rating,
    required this.onFavoritePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(
          color: Colors.grey.shade400, // Adiciona a borda à caixa do livro
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Imagem do livro
                Image.network(
                  imageUrl,
                  height: 100,
                  width: 80,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 16),

                // Informações do livro
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        author,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Postado por:',
                        style: TextStyle(fontSize: 12),
                      ),
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(profileImageUrl),
                            radius: 15,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            postedBy,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Estrelas de avaliação
                      RatingBarIndicator(
                        rating: rating,
                        itemBuilder: (context, index) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 18.0,
                        direction: Axis.horizontal,
                      ),
                    ],
                  ),
                ),

                // Botão de coração
                IconButton(
                  onPressed: onFavoritePressed,
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.green, // Ícone de coração na cor verde
                    size: 24,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}