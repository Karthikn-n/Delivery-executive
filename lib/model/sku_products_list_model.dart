class SkuProduct {
  final int productId;
  final String productName;
  final int quantity;
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
      quantity: int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      productPrice: double.tryParse(json['product_price'].toString()) ?? 0.0,
      mrgQty: json['mrg_qty'],
      evgQty: json['evg_qty'],
    );
  }

}
