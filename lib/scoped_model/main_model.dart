
import 'package:scoped_model/scoped_model.dart';
import './product_model.dart';

class MainModel extends Model with ConnectedProductModel, ProductModel, UserModel {

}