import 'dart:convert';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import '../model/product.dart';

class ProductsModel extends Model {
  String baseURL = "http://192.168.0.195:8080/products-mobile-api/products";
  List<Product> _products = [];
  int _selectedProductIndex;
  bool _showFavorites = false;
  bool _isLoading = false;


  List<Product> get products{
    return List.from(_products);
  }


  void  fetchProducts() {
    _isLoading = true;
    notifyListeners();

    http.get(baseURL, headers: {
      "content-type": "application/json",
      "accept": "application/json",
    }).then((http.Response response) {
      
      Iterable productsList = json.decode(response.body);
      _products = productsList.map((model) => Product.fromJson(model)).toList();
    });
    notifyListeners();
  }

  List<Product> get displayedProducts {
    if (_showFavorites) {
      return _products.where((Product product) => product.isFavorite).toList();
    }
    return List.from(_products);
  }

  int get selectedProductIndex {
    return _selectedProductIndex;
  }

  Product get selectedProduct {
    if (_selectedProductIndex == null) {
      return null;
    }
    return _products[_selectedProductIndex];
  }

  bool get displayFavoritesOnly {
    return _showFavorites;
  }

  void addProduct(String ttl, String desc, String img, double prc) {
    _isLoading = true;
    final Map<String, dynamic> productData = {
      'title': ttl,
      'description': desc,
      'price': prc.toString(),
      'image': img,
      'isFavorite': false
    };
    http.post(baseURL, body: json.encode(productData), headers: {
      "content-type": "application/json",
      "accept": "application/json",
    }).then((http.Response response) {
      _isLoading = false;
      final Map<String, dynamic> responseData = json.decode(response.body);
      print(responseData);
      final Product product = new Product(
          title: responseData['title'],
          description: responseData['description'],
          price: double.parse(responseData['price']),
          image: responseData['image'],
          isFavorite: responseData['isFavorite']);
      _products.add(product);
      notifyListeners();
    });
  }

  void updateProduct(Product product) {
    _products[_selectedProductIndex] = product;
    _selectedProductIndex = null;
    notifyListeners();
  }

  void deleteProduct() {
    http.delete(baseURL+'\$/selectedProduct.id').then(
      (http.Response response){
        dynamic deleteResponse = response.body;
        print(deleteResponse.toString());
      }
    );
    _products.removeAt(_selectedProductIndex);
    _selectedProductIndex = null;
    notifyListeners();
  }

  void toggleProductFavoriteStatus() {
    final bool isCurrentlyFavorite = selectedProduct.isFavorite;
    final bool newFavoriteStatus = !isCurrentlyFavorite;
    final Product updatedProduct = Product(
        title: selectedProduct.title,
        description: selectedProduct.description,
        price: selectedProduct.price,
        image: selectedProduct.image,
        isFavorite: newFavoriteStatus);
    _products[_selectedProductIndex] = updatedProduct;
    _selectedProductIndex = null;
    notifyListeners();
  }

  void selectProduct(int index) {
    _selectedProductIndex = index;
    notifyListeners();
  }

  void toggleDisplayMode() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }
}
