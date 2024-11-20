import 'dart:ui';
import 'package:flutter/material.dart';

class TDBusy extends StatelessWidget {
  bool busy = false;
  Widget child;

  TDBusy({super.key,
    required this.busy,
    required this.child,
});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // O conteúdo principal da tela
        child,
        // O overlay que será exibido se estiver "busy"
        if (busy)
          Positioned.fill(
            child: Stack(
              children: [
                // Fundo desfocado
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    color: Colors.black.withOpacity(0.3), // Fundo semitransparente
                  ),
                ),
                // O CircularProgressIndicator centralizado
                Center(
                  child: CircularProgressIndicator(
                    color: const Color(0xFF77C593),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class TDBusyClear extends StatelessWidget {
  bool busy = false;
  Widget child;

  TDBusyClear({super.key, 
    required this.busy,
    required this.child,
});

  @override
  Widget build(BuildContext context) {
    return busy
        ? Container(
      child: Center(),
    )
        : child;
  }
}