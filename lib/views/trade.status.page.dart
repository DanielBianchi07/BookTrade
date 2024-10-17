import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class TradeStatusPage extends StatelessWidget {
  const TradeStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD8D5B3), // Cor amarelada semelhante à parte superior
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black), // Ícone de voltar
          onPressed: () {
            Navigator.pop(context); // Ação para voltar
          },
        ),
        title: const Text(
          'Status da Troca',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informações do Livro
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  'https://via.placeholder.com/80',
                  height: 80,
                  width: 60,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '1984',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'George Orwell',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      '4ª Edição',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Status do Pedido
            _buildStatusCard(
              context,
              title: 'Pedido enviado',
              content:
                  'Endereço de entrega: Rua Top 123,\nBairro dos Carvalhos, São José do Rio\nPreto, São Paulo',
              idLabel: 'ID da troca:',
              id: '237yb189fgp',
              copyLabel: 'Copiar ID',
            ),
            const SizedBox(height: 20),

            // Informações do Solicitante
            const Text(
              'Solicitante',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const CircleAvatar(
                  backgroundImage: NetworkImage('https://via.placeholder.com/50'),
                  radius: 25,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bernardo Almeida',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: List.generate(5, (index) {
                        return const Icon(Icons.star, color: Colors.amber, size: 18);
                      }),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.chat, color: Colors.black, size: 30),
                  onPressed: () {
                    Navigator.pushNamed(context, '/chat');
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Informações da Troca
            const Text(
              'Informações da troca',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildStatusCard(
              context,
              title: 'ORWELL, George. 1984, 4ª Edição',
              idLabel: 'Código de rastreio:',
              id: 'NR0124BF2BR',
              copyLabel: 'Copiar código de rastreio', content: 'Data da solicitação: 5 de setembro de 2024\n\n'
                  'Status de Envio: Seu pedido foi enviado para a transportadora',
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper para criar Cards de status
  Widget _buildStatusCard(BuildContext context,
      {required String title,
      required String content,
      required String idLabel,
      required String id,
      required String copyLabel}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(
          color: Colors.grey.shade400, // Adiciona a borda ao card
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título do Card (Status do pedido)
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            // Conteúdo do Card (Endereço ou informações)
            Text(
              content,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            // ID e Botão para copiar ID
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: id));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$id copiado para a área de transferência')),
                );
              },
              child: Text(
                '$idLabel $id',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: id));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$copyLabel copiado para a área de transferência')),
                );
              },
              child: Text(
                copyLabel,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.green,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
