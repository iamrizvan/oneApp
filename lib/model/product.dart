import 'package:flutter/material.dart';

class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final String image;
  final bool isFavorite;

  Product(
      {this.id,
      @required this.title,
      @required this.description,
      @required this.price,
      @required this.image,
      this.isFavorite = false});

     Product.fromJson(Map json)
     : id = json[''],
   title = json['title'],
   description = json['description'],
   price = double.parse(json['price']),
   image = json['image'],
   isFavorite = json['isFavorite'];
   

}
