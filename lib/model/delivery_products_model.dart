import 'package:app_5/model/ordered_products_model.dart';

import 'subscribed_product_data_model.dart';

class DeliveryProducts{
  final int customerId;
  final String firstName;
  final String lastName;
  final String email;
  final String mobileNo;
  final int addressId;
  final String flatNo;
  final String address;
  final String floor;
  final String landmark;
  final String location;
  final String region;
  final List<SubscribedProductData> products;
  final List<OrderedProductsModel> orderProducts;
 
  DeliveryProducts({
    required this.customerId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobileNo,
    required this.addressId,
    required this.address,
    required this.flatNo,
    required this.floor,
    required this.landmark,
    required this.location,
    required this.region,
    required this.products,
    required this.orderProducts
  });

  factory DeliveryProducts.fromJson(Map<String, dynamic> json){
    List<SubscribedProductData> productList = [];
    List<OrderedProductsModel> orderProductList = [];
    if (json['product_data'] != null) {
      productList = List<SubscribedProductData>.from(json['product_data'].map(
        (productJson) => SubscribedProductData.fromJson(productJson),
      ));
    }
    if (json['order_products'] != null) {
      orderProductList = List<OrderedProductsModel>.from(json['order_products'].map(
        (productJson) => OrderedProductsModel.fromMap(productJson),
      ));
    }
    return DeliveryProducts(
      customerId: int.parse(json['customer_id'].toString()) , 
      firstName: json['first_name'] ?? '', 
      lastName: json['last_name'] ?? '', 
      email: json['email'] ?? '', 
      mobileNo: json['mobile_no'] ?? '', 
      addressId: int.parse(json['address_id'].toString()), 
      address: json['address'] ?? '', 
      flatNo: json['flat_no'] ?? '', 
      floor: json['floor'] ?? '', 
      landmark:json['landmark']  ?? '', 
      location: json['location'] ?? '', 
      region: json['region'] ?? '', 
      products: productList,
      orderProducts: orderProductList
    );
  }
}
