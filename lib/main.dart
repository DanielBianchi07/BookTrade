import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:myapp/firebase_options.dart';
import 'package:myapp/views/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate();

  // Teste rápido de Firebase Storage
  try {
    final ref = FirebaseStorage.instance.ref().child('test').child('test.txt');
    await ref.putString('Teste de upload para verificar configuração do Firebase Storage');
    print('Upload de teste concluído com sucesso');
  } catch (e) {
    print('Erro ao fazer upload de teste: $e');
  }

  runApp(BookTradeApp());
}
