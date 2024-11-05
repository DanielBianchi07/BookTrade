import 'package:flutter/material.dart';

class UIHelper {
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red, // Apenas para destacar o erro visualmente
      ),
    );
  }
}