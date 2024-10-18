import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TDBusy extends StatelessWidget {
  bool busy = false;
  Widget child;

  TDBusy({
    required this.busy,
    required this.child,
});

  @override
  Widget build(BuildContext context) {
    return busy
        ? Container(
      child: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF77C593),
        ),
      )
    )
        : child;
  }
}

class TDBusyClear extends StatelessWidget {
  bool busy = false;
  Widget child;

  TDBusyClear({
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