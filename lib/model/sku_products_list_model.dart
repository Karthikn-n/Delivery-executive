class SkuProduct {
  final int productId;
  final String productName;
  final String quantity;
  final double productPrice;
  final int mrgQty;
  final int evgQty;

  SkuProduct({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.productPrice,
    required this.mrgQty,
    required this.evgQty,
  });

  // Factory constructor to create a Product instance from JSON data
  factory SkuProduct.fromJson(Map<String, dynamic> json) {
    return SkuProduct(
      productId: json['product_id'],
      productName: json['product_name'],
      quantity: json['quantity'],
      productPrice: json['product_price'].toDouble(),
      mrgQty: json['mrg_qty'],
      evgQty: json['evg_qty'],
    );
  }

  Map<String, dynamic> toMap(){
    final results = <String, dynamic>{};
    results.addAll({"product_id": productId});
    results.addAll({"product_name": productName});
    results.addAll({"quantity": quantity});
    results.addAll({"product_price": productPrice});
    results.addAll({"mrg_qty": mrgQty});
    results.addAll({"evg_qty": evgQty});
    return results;
  }
}
