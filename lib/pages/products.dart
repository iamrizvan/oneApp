import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';
import '../scoped_model/products.dart';
import '../widget/products/products.dart';
import '../scoped_model/products.dart';

class ProductsPage extends StatefulWidget {
  final ProductsModel productsModel;
  ProductsPage(this.productsModel);
  @override
  State<StatefulWidget> createState() {
    return _ProductPageState();
  }
}

class _ProductPageState extends State<ProductsPage>{
  @override
  initState(){
    widget.productsModel.products;
     super.initState();
  }
  
  Widget _buildSideDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            automaticallyImplyLeading: false,
            title: Text('Choose'),
          ),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Manage Products'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/admin');
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildSideDrawer(context),
      appBar: AppBar(
        title: Text('EasyList'),
        actions: <Widget>[
          ScopedModelDescendant<ProductsModel>(
            builder: (BuildContext context, Widget child, ProductsModel model) {
              return IconButton(
                icon: Icon(model.displayFavoritesOnly
                    ? Icons.favorite
                    : Icons.favorite_border),
                onPressed: () {
                  model.toggleDisplayMode();
                },
              );
            },
          )
        ],
      ),
      body: Products(),
    );
  }
}
