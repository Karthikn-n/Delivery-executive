class OrderedProductsModel{
  final int orderid;
  final int productId;
  final String productName;
  final dynamic quantity;
  final String price;

  OrderedProductsModel({
    required this.orderid,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price
  });

  
  Map<String, dynamic> toMap(){
    final result = <String, dynamic>{};

    result.addAll({"order_id": orderid});
    result.addAll({"product_id": productId});
    result.addAll({"product_name": productName});
    result.addAll({"quantity": quantity});
    result.addAll({"product_price": price});

    return result;
  }

  factory OrderedProductsModel.fromMap(Map<String, dynamic> map){
    return OrderedProductsModel(
      orderid: map["order_id"], 
      productId: map["product_id"], 
      productName: map["product_name"], 
      quantity: map["quantity"] ?? 0, 
      price: map["product_price"]
    );
  }
}