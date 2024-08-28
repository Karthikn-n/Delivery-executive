import 'package:app_5/model/products_model.dart';

class AllProductsHelper{
  AllProductsHelper._allProducts();

  static final AllProductsHelper instance = AllProductsHelper._allProducts();
  List<ProductsModel> _allProducts = [];

  void storeAllProducts(List<ProductsModel> products) {
    _allProducts = products;
  }

  List<ProductsModel> get allProducts => _allProducts;
}