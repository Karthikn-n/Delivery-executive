class SubscribedProductData{
  final int subId;
  final int productId;
  final String productName;
  final int mrngQty;
  final int price;
  final String quantity;
  final int evgQty;

  SubscribedProductData({
    required this.subId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.mrngQty,
    required this.evgQty
  });

  factory SubscribedProductData.fromJson(Map<String, dynamic> json){
    return SubscribedProductData(
      subId: int.parse(json['sub_id'].toString()) , 
      productId: int.parse(json['product_id'].toString()) , 
      price: int.parse(json['product_price'].toString()),
      quantity: json['quantity'] ?? "",
      productName: json['product_name'] ?? "", 
      mrngQty: int.parse(json['mrg_qty'].toString()) , 
      evgQty: int.parse(json['evg_qty'].toString()) 
    );
  }
}
