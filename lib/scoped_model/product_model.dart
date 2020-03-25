import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:scoped_model/scoped_model.dart';
import '../model/product.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user.dart';
import 'package:rxdart/subjects.dart';

class ConnectedProductModel extends Model {
  // Shared Prefrences Constants.
  final String SH_PREF_KEY = 'authtoken';
  final String SH_PREF_EMAIL = 'email';
  final String SH_PREF_USER_ID = 'userid';
  final String SH_PREF_EXPIRY_TIME = 'expiry_time';

  static String _baseURL = "http://192.168.0.156:8080/products-mobile-api/";
  String _loginUserURL = _baseURL + "users/login";
  String _createUserURL = _baseURL + "user";
  String _updateProductURL = _baseURL + "products";
  String _deleteProductURL = _baseURL + "products";
  String _fetchProductsURL = _baseURL + "products";
  String _createProductsURL = _baseURL + "products";

  List<Product> _products = [];
  String _selectedProductId;
  bool _showFavorites = false;
  bool _isLoading = false;
  User _authenticatedUser;
}

mixin ProductModel on ConnectedProductModel {
  Future<Null> fetchProducts() async {
    _isLoading = true;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = prefs.getString(SH_PREF_KEY);
    return http.get(_fetchProductsURL, headers: {
      "content-type": "application/json",
      "accept": "application/json",
      HttpHeaders.authorizationHeader: key
    }).then<Null>((http.Response response) {
      if (response.statusCode == 403) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      Iterable productsList = json.decode(response.body);
      _products = productsList.map((model) => Product.fromJson(model)).toList();
      _isLoading = false;
      _selectedProductId = null;
      notifyListeners();
    }).catchError((onError) {
      _isLoading = false;
      notifyListeners();
      _selectedProductId = null;
      notifyListeners();
    });
  }

  List<Product> get allProducts {
    return List.from(_products);
  }

  List<Product> get displayedProducts {
    if (_showFavorites) {
      return _products.where((Product product) => product.isFavorite).toList();
    }
    return List.from(_products);
  }

  String get selectedProductId {
    return _selectedProductId;
  }

  Product get selectedProduct {
    if (_selectedProductId == null) {
      return null;
    }
    // return the product if selected id is matches.
    return _products.firstWhere((Product product) {
      return product.productId == _selectedProductId;
    });
  }

  bool get displayFavoritesOnly {
    return _showFavorites;
  }

  bool get isLoading {
    return _isLoading;
  }

  Future<bool> addProduct(
      String ttl, String desc, String img, double prc) async {
    // start loader
    _isLoading = true;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = prefs.getString(SH_PREF_KEY);
    String userid = prefs.getString(SH_PREF_USER_ID);

    // Construct data
    final Map<String, dynamic> productData = {
      'userId': userid,
      'title': ttl,
      'description': desc,
      'price': prc.toString(),
      'image':
          'https://sweetsandsnacks.com/wordpress/wp-content/uploads/2017/06/candy_snack.jpg',
      'isFavorite': false
    };
    try {
      // make http post call asynchronously
      final http.Response response = await http
          .post(_createProductsURL, body: json.encode(productData), headers: {
        "content-type": "application/json",
        "accept": "application/json",
        HttpHeaders.authorizationHeader: key
      });
      if (response.statusCode != 200 && response.statusCode != 201) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final Map<String, dynamic> responseData = json.decode(response.body);
      print(responseData);
      final Product product = new Product(
          id: responseData['id'],
          title: responseData['title'],
          description: responseData['description'],
          price: double.parse(responseData['price']),
          image: responseData['image'],
          isFavorite: responseData['isFavorite']);
      _products.add(product);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(Product product) async {
    _isLoading = true;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = prefs.getString(SH_PREF_KEY);
    String userid = prefs.getString(SH_PREF_USER_ID);
    final Map<String, dynamic> productData = {
      'userId': userid,
      'title': product.title,
      'description': product.description,
      'price': product.price.toString(),
      'image':
          'https://img3.goodfon.com/wallpaper/nbig/7/b1/sweets-candy-chocolate-shokolad-konfety-sladkoe.jpg',
      'isFavorite': selectedProduct.isFavorite
    };
    http.Response response = await http.put(
        _updateProductURL + '/${selectedProduct.productId}',
        body: json.encode(productData),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          HttpHeaders.authorizationHeader: key
        });

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      print(responseData);
      final Product product = new Product(
          id: responseData['id'],
          productId: responseData['productId'],
          userId: responseData['userId'],
          title: responseData['title'],
          description: responseData['description'],
          price: double.parse(responseData['price']),
          image: responseData['image'],
          isFavorite: responseData['isFavorite']);
      _products[_selectedProductIndex] = product;
      _selectedProductId = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = prefs.getString(SH_PREF_KEY);
    _selectedProductId = productId;
    print(_deleteProductURL + "/" + _selectedProductId.toString());
    try {
      http.Response response = await http
          .delete(_deleteProductURL + "/" + _selectedProductId, headers: {
        "content-type": "application/json",
        "accept": "application/json",
        HttpHeaders.authorizationHeader: key
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        _products.removeAt(_selectedProductIndex);
        _selectedProductId = null;
        return true;
      } else {
        _selectedProductId = null;
        print("DELETE ::::::::   :::::::::: " + json.decode(response.body));
        return false;
      }
    } catch (error) {
      print("DELETE ::::::::   :::::::::: " + error.toString());
      _selectedProductId = null;
      return false;
    }
  }

  Future<bool> toggleProductFavoriteStatus() async {
    final bool isCurrentlyFavorite = selectedProduct.isFavorite;
    final bool newFavoriteStatus = !isCurrentlyFavorite;

    final Map<String, dynamic> updatedProduct = {
      'userId': selectedProduct.userId,
      'title': selectedProduct.title,
      'description': selectedProduct.description,
      'price': selectedProduct.price,
      'image': selectedProduct.image,
      'isFavorite': newFavoriteStatus
    };
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = prefs.getString(SH_PREF_KEY);
    print('FAVORITE ::::   :::: ' +
        _updateProductURL +
        '/${selectedProduct.productId}');
    try {
      http.Response response = await http.put(
          _updateProductURL + '/${selectedProduct.productId}',
          body: json.encode(updatedProduct),
          headers: {
            "content-type": "application/json",
            "accept": "application/json",
            HttpHeaders.authorizationHeader: key
          });
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print(responseData);
        final Product product = new Product(
            id: responseData['id'],
            productId: responseData['productId'],
            userId: responseData['userId'],
            title: responseData['title'],
            description: responseData['description'],
            price: double.parse(responseData['price']),
            image: responseData['image'],
            isFavorite: responseData['isFavorite']);
        _products[_selectedProductIndex] = product;
        _selectedProductId = null;
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (error) {
      print('FAVORITE ::::: ERROR :::' + error.toString());
      return false;
    }
  }

  void selectProduct(String productId) {
    _selectedProductId = productId;
    notifyListeners();
  }

  void toggleDisplayMode() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }

// get the index of selected product
  int get _selectedProductIndex {
    return _products.indexWhere((Product product) {
      return product.productId == _selectedProductId;
    });
  }
}

mixin UserModel on ConnectedProductModel {
  PublishSubject<bool> _userSubject = PublishSubject();
  Timer _authTimer;

  User get user {
    return _authenticatedUser;
  }

  PublishSubject<bool> get userSubject {
    return _userSubject;
  }

// Construct data
  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> loginData = {
      'email': email,
      'password': password
    };
    try {
      http.Response response = await http
          .post(_loginUserURL, body: json.encode(loginData), headers: {
        "content-type": "application/json",
        "accept": "application/json",
      });
      if (response.statusCode == 200) {
        Map<String, dynamic> headerData = response.headers;
        String _key = headerData['authorization'].toString();
        String _userId = headerData['userid'].toString();
        String _expiry_time = headerData['expiration_time'].toString();
        final DateTime now = DateTime.now();
        final DateTime expiryTime =
            now.add(Duration(seconds: int.parse(_expiry_time)));
        setAuthTimeOut(int.parse(_expiry_time));
        _userSubject.add(true);
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(SH_PREF_KEY, _key);
        prefs.setString(SH_PREF_EMAIL, email);
        prefs.setString(SH_PREF_USER_ID, _userId);
        prefs.setString(SH_PREF_EXPIRY_TIME, expiryTime.toIso8601String());
        _authenticatedUser = User(userId: _userId, email: email, token: _key);
        _isLoading = false;
        notifyListeners();
        return {'success': true, 'message': 'Authentication succeeded!'};
      } else {
        _isLoading = false;
        notifyListeners();
        return {'success': false, 'message': 'Authentication Failed!'};
      }
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Authentication Failed!'};
    }
  }

  Future<Map<String, dynamic>> signup(
      String firstName, String lastName, String email, String password) async {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> signupData = {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password
    };
    try {
      final http.Response response = await http
          .post(_createUserURL, body: json.encode(signupData), headers: {
        "content-type": "application/json",
        "accept": "application/json",
      });

      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return {'success': true, 'message': 'Authentication succeeded!'};
      } else {
        _isLoading = false;
        notifyListeners();
        return {'success': false, 'message': 'Authentication Failed!'};
      }
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Authentication Failed!'};
    }
  }

  void autoAuthenticate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString(SH_PREF_KEY);
    final String expiryTime = prefs.getString(SH_PREF_EXPIRY_TIME);
    if (token != null) {
      final DateTime now = DateTime.now();
      final parseExpiryTime = DateTime.parse(expiryTime);
      if (parseExpiryTime.isBefore(now)) {
        _authenticatedUser = null;
        notifyListeners();
        return;
      }
      final String email = prefs.getString(SH_PREF_EMAIL);
      final String userid = prefs.getString(SH_PREF_USER_ID);
      final int tokenLifeSpan = parseExpiryTime.difference(now).inSeconds;
      _authenticatedUser = User(email: email, userId: userid, token: token);
      _userSubject.add(true);
      setAuthTimeOut(tokenLifeSpan);
      notifyListeners();
    }
  }

  void logout() async {
    _isLoading = false;
    notifyListeners();
    print('Logout ::::::: !!!!!!!!!!!!');
    _authenticatedUser = null;
    _authTimer.cancel();
    _userSubject.add(false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //   prefs.clear();    // this method will clear the complete shared prefrences data.
    prefs.remove(SH_PREF_KEY);
    prefs.remove(SH_PREF_EMAIL);
    prefs.remove(SH_PREF_USER_ID);
  }

  void setAuthTimeOut(int time) {
    _authTimer = Timer(Duration(seconds: time), () {
      logout();
      _userSubject.add(false);
    });
  }
}
