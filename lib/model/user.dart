import 'package:flutter/material.dart';

class User {
  String name;
  String email;
  String userId;
  String token;

  User(
      {this.name,
      @required this.email,
      @required this.userId,
      @required this.token});
}
