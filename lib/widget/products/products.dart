import 'package:flutter/material.dart';
import 'package:one_app/scoped_model/main_model.dart';

import 'package:scoped_model/scoped_model.dart';

import './product_card.dart';
import '../../model/product.dart';

class Products extends StatelessWidget {

  Widget _buildProductList(MainModel model) {
    List<Product> products = model.displayedProducts;
    Widget productCards; 
    if (products.length > 0) {
      productCards = ListView.builder(
        itemBuilder: (BuildContext context, int index) =>
            ProductCard(products[index], index),
        itemCount: products.length,
      );
    } else {
      productCards = Container(
        child: Center(
          child: Text('No Product Found.'),
        ),
      );
    }
    return productCards;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(builder: (BuildContext context, Widget child, MainModel model) {
      return  _buildProductList(model);
          },);
  }
}
