import 'package:flutter/material.dart';
import 'package:one_app/scoped_model/main_model.dart';
import 'package:scoped_model/scoped_model.dart';
import './product_edit.dart';

class ProductListPage extends StatefulWidget {
  final MainModel model;
  ProductListPage(this.model);

  @override
  State<StatefulWidget> createState() {
    return _ProductListPageState();
  }
}

class _ProductListPageState extends State<ProductListPage> {
  @override
  initState() {
    widget.model.fetchProducts();
    super.initState();
  }

  Widget _buildEditButton(BuildContext context, int index, MainModel model) {
    return IconButton(
      icon: Icon(Icons.edit),
      onPressed: () {
        model.selectProduct(model.allProducts[index].productId);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return ProductEditPage();
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return Dismissible(
              key: Key(model.allProducts[index].id.toString()),
              onDismissed: (DismissDirection direction) {
                if (direction == DismissDirection.endToStart) {
     //             _deleteProduct(model, index);
                   model
        .deleteProduct(model.allProducts[index].productId)
        .then((bool success) {
      if (success) {
        Scaffold.of(context).showSnackBar(SnackBar(content: Text('Product deleted!')));
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                  title: Text('Something went wrong!'),
                  content: Text('Please try again'),
                  actions: <Widget>[
                    FlatButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Okay'))
                  ]);
            });
      }
    });
                } else if (direction == DismissDirection.startToEnd) {
                  print('Swiped start to end');
                } else {
                  print('Other swiping');
                }
              },
              background: Container(color: Colors.red),
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(model.allProducts[index].image),
                    ),
                    title: Text(model.allProducts[index].title),
                    subtitle:
                        Text('\$${model.allProducts[index].price.toString()}'),
                    trailing: _buildEditButton(context, index, model),
                  ),
                  Divider()
                ],
              ),
            );
          },
          itemCount: model.allProducts.length,
        );
      },
    );
  }
}
