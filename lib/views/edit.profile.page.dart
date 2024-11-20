import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/controller/edit.profile.controller.dart';
import 'package:myapp/views/home.page.dart';
import '../controller/login.controller.dart';
import '../models/user.info.model.dart';
import '../services/image.service.dart';
import '../user.dart';
import '../widgets/busy.widget.dart';
import 'change.email.page.dart';
import 'change.password.page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  List<String> cities = [];
  String? selectedCity;
  bool isLoadingCities = false;
  final loginController = LoginController();
  final controller = EditProfileController();
  final imageUploadService = ImageUploadService();

  final TextEditingController name = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController currentPassword = TextEditingController();
  final TextEditingController newPassword = TextEditingController();
  final TextEditingController confirmNewPassword = TextEditingController();

  String? profileImageUrl;
  File? selectedImage;
  var busy = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _inicializarDados();
    fetchCities();
  }

  Future<void> fetchCities() async {
    setState(() {
      isLoadingCities = true;
    });

    try {
      final response = await http.get(Uri.parse(
          "https://servicodados.ibge.gov.br/api/v1/localidades/municipios"));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          cities = data
              .map<String>((city) =>
                  "${city['nome']} - ${city['microrregiao']['mesorregiao']['UF']['sigla']}")
              .toList();
        });
      } else {
        throw Exception("Erro ao carregar as cidades.");
      }
    } catch (error) {
      print("Erro ao buscar cidades: $error");
    } finally {
      setState(() {
        isLoadingCities = false;
      });
    }
  }

  _inicializarDados() async {
    // Aguarda a execução de uma função assíncrona antes de prosseguir
    await loginController.AssignUserData(context);
    setState(() {
      _isLoading = false;
    });

    if (_isLoading == false) {
      name.text = user.value.name;
      phone.text = user.value.telephone;
      if (user.value.address != null) {
        address.text = user.value.address!;
        selectedCity = user.value.address; // Sincroniza com a cidade existente
      } else {
        address.text = '';
      }
      email.text = user.value.email;
      print('dados carregados aos labels');
      profileImageUrl = user.value.picture;
    }
  }

  Future<void> handleEditProfile() async {
    if (selectedCity == null || selectedCity!.isEmpty) {
      Fluttertoast.showToast(msg: "Por favor, selecione uma cidade válida.");
      return;
    }
    setState(() => busy = true);

    // Atualiza o perfil do usuário (nome, telefone e endereço)
    try {
      await controller.updateUserProfile(
          context, name.text.trim(), phone.text.trim(), selectedCity);

      // Se uma nova imagem foi selecionada, faça o upload e atualize a URL no Firestore
      if (selectedImage != null) {
        String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
        String? newProfileImageUrl =
            await imageUploadService.uploadProfileImage(selectedImage!, userId);

        if (newProfileImageUrl != null) {
          setState(() {
            profileImageUrl = newProfileImageUrl;
          });
        }
      }
      // Atualiza o UserInfoModel na coleção de livros
      await updateUserInfoInBooks();
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomePage()), (Route<dynamic> route) => false,);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Perfil atualizado com sucesso!')),
      );
    } catch (err) {
      onError(err);
    } finally {
      onComplete();
    }
  }

  Future<void> updateUserInfoInBooks() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    // Carregar os valores atuais de customerRating e favoriteGenres
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    double currentCustomerRating = userDoc['customerRating'] ?? 0.0;
    List<String> currentFavoriteGenres =
        List<String>.from(userDoc['favoriteGenres'] ?? []);
    final userInfo = UInfo(
      id: userId,
      name: name.text,
      email: email.text,
      phone: phone.text,
      address: address.text,
      profileImageUrl: profileImageUrl ?? '',
      customerRating: currentCustomerRating,
      favoriteGenres: currentFavoriteGenres,
    );

    final userMap = userInfo.toMap();

    try {
      // Busca todos os documentos onde o `userId` corresponde ao usuário logado
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('books')
          .where('userId', isEqualTo: userId)
          .get();

      // Atualiza o campo `userInfo` em cada documento encontrado
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        await doc.reference.update({
          'userInfo': userMap,
        });
      }
    } catch (e) {
      print("Erro ao atualizar userInfo nos livros: $e");
    }
  }

  onError(err) {
    if (err is FirebaseAuthException) {
      loginController.handleFirebaseAuthError(err);
    } else {
      Fluttertoast.showToast(
        msg: "Erro inesperado: $err",
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  onComplete() {
    if (mounted) {
      setState(() {
        busy = false;
      });
    }
  }

  Future<void> _addImage() async {
    final source = await _showImageSourceDialog();
    if (source != null) {
      final pickedImage  = await imageUploadService.pickImage(source);
      if (pickedImage  != null) {
        setState(() {
          selectedImage = pickedImage ;
        });
      }
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escolha por onde deseja carregar a foto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Câmera'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Galeria'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TDBusy(busy: busy, child: Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD8D5B3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () async{
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
                  (Route<dynamic> route) => false, // Remove todas as rotas anteriores
            );
          },
        ),
        title:
            const Text('Editar Perfil', style: TextStyle(color: Colors.black)),
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
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: selectedImage != null
                            ? FileImage(selectedImage!)
                            : (profileImageUrl != null &&
                                    profileImageUrl!.isNotEmpty
                                ? NetworkImage(profileImageUrl!)
                                : const NetworkImage('')),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _addImage, // Selecionar nova imagem
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
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    user.value.name,
                    style: const TextStyle(
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
              controller: name,
            ),
            const SizedBox(height: 5),

            // Campo de Telefone Editável
            _buildEditableField(
              label: 'Telefone:',
              controller: phone,
            ),
            const SizedBox(height: 5),

            _buildCityField(),

            const SizedBox(height: 5),
            // Campo de E-mail NÃO Editável
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'E-mail',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: email,
                  obscureText: false,
                  readOnly: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment
                  .center, // Centraliza os botões horizontalmente
              children: [
                // Botão Alterar E-mail
                SizedBox(
                  width: 150, // Largura fixa do botão
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChangeEmailPage()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD8D5B3),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Padding(
                      padding:
                          EdgeInsets.all(10.0), // Ajusta o padding do botão
                      child: Text(
                        'Alterar e-mail',
                        style: TextStyle(
                            fontSize: 12), // Ajuste do tamanho do texto
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                    width:
                        20), // Espaçamento entre os botões (ajuste conforme necessário)
                // Botão Alterar Senha
                SizedBox(
                  width: 150, // Largura fixa do botão
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChangePasswordPage()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD8D5B3),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Padding(
                      padding:
                          EdgeInsets.all(10.0), // Ajusta o padding do botão
                      child: Text(
                        'Alterar senha',
                        style: TextStyle(
                            fontSize: 12), // Ajuste do tamanho do texto
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            // Botão Salvar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  handleEditProfile();
                  imageUploadService.uploadProfileImage(selectedImage!,
                      user.value.uid); // Faz o upload da nova imagem de perfil
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF77C593),
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
    )
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
            fillColor: Colors.grey.shade200,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cidade:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            // Filtra as cidades conforme o texto digitado
            return cities.where((city) {
              return city.toLowerCase().contains(textEditingValue.text.toLowerCase());
            }).toList();
          },
          onSelected: (String selection) {
            setState(() {
              selectedCity = selection; // Atualiza a cidade selecionada
              address.text = selection;
            });
          },
          fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: user.value.address ?? 'Digite sua cidade',
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                errorText: selectedCity == null && controller.text.isNotEmpty
                    ? 'Cidade inválida. Por favor, escolha da lista.'
                    : null,
              ),
              onEditingComplete: onEditingComplete,
              onChanged: (value) {
                // Verifica se a cidade digitada é válida
                if (!cities.contains(value.trim())) {
                  setState(() {
                    selectedCity = null; // Limpa a seleção se não for válido
                  });
                }
              },
            );
          },
        ),
      ],
    );
  }
}
