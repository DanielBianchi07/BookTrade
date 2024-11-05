import 'package:flutter/cupertino.dart';

class IUser {
  String uid = "";
  String name = "";
  String picture = "";
  String email = "";
  String telephone = "";
  double customerRating = 0.0;
  String? address;
}

ValueNotifier<IUser> user = ValueNotifier(IUser());