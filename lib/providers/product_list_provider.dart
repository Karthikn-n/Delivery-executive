import 'dart:convert';

import 'package:app_5/helper/sharedPreference_helper.dart';
import 'package:app_5/model/ordered_products_model.dart';
import 'package:app_5/model/products_model.dart';
import 'package:app_5/model/sku_products_list_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductListProvider with ChangeNotifier{

  SharedPreferences prefs = SharedpreferenceHelper.getInstance;
  List<SkuProduct> skuPickList = [];
  List<ProductsModel> allProducts = [];
  List<OrderedProductsModel> orderedProducts= [];

  Future<void> getProductsList() async {
    List<String> tempSkuList = prefs.getStringList('skulist') ?? [];
    skuPickList = tempSkuList.map((skulist) => SkuProduct.fromJson(json.decode(skulist)),).toList();
    List<String> tempAllProductList = prefs.getStringList('allproducts') ?? [];
    allProducts = tempAllProductList.map((all) => ProductsModel.fromMap(json.decode(all)),).toList();
    List<String> temporderedList = prefs.getStringList('orderedproducts') ?? [];
    orderedProducts = temporderedList.map((order) => OrderedProductsModel.fromMap(json.decode(order)),).toList();
  }

  List<SkuProduct> get skuProducts => skuPickList;
  List<ProductsModel> get allProductsList => allProducts;
  List<OrderedProductsModel> get orderedProductsList => orderedProducts;

}