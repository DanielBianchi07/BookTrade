import 'package:flutter/material.dart';


class EditProfilePage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController(text: 'Fulano da Silva');
  final TextEditingController phoneController = TextEditingController(text: '4002-8922');
  final TextEditingController emailController = TextEditingController(text: 'fulano@gmail.com');
  final TextEditingController passwordController = TextEditingController(text: '************');

  EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD8D5B3), // Cor amarelada na parte superior
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop(); // Seta de navegação para voltar
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // Foto de perfil e nome do usuário
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(
                            'https://via.placeholder.com/150'), // Substituir pela URL da imagem do perfil
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Fulano da Silva',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),

            // Campo de Nome Editável
            _buildEditableField(
              label: 'Nome:',
              controller: nameController,
            ),
            const SizedBox(height: 5),

            // Campo de Telefone Editável
            _buildEditableField(
              label: 'Telefone:',
              controller: phoneController,
            ),
            const SizedBox(height: 5),

            // Campo de E-mail Editável
            _buildEditableField(
              label: 'E-mail:',
              controller: emailController,
            ),
            const SizedBox(height: 5),

            // Campo de Senha Editável
            _buildEditableField(
              label: 'Senha:',
              controller: passwordController,
              obscureText: true,
            ),
            const SizedBox(height: 20),

            // Botão Salvar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Lógica para salvar as informações
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF77C593), // Cor do botão "Salvar"
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Text('Salvar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Função para construir cada campo de edição do perfil
  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade200, // Cor de fundo cinza claro
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}