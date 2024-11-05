import 'package:flutter/cupertino.dart';

class IUser {
  String uid = "";
  String name = "";
  String picture = "";
  String email = "";
  String telephone = "";
}

ValueNotifier<IUser> user = ValueNotifier(IUser());