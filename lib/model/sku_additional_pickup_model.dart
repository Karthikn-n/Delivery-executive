class SkuAdditionalPickupModel{
  final int productId;
  final int executiveid;
  final int skuPickupQunatity;
  final int additionalquantity;
  final String date;

  SkuAdditionalPickupModel({
    required this.productId,
    required this.executiveid,
    required this.skuPickupQunatity,
    required this.additionalquantity,
    required this.date
  });

  Map<String, dynamic> toMap(){
    final results = <String, dynamic>{};
    results.addAll({"product_id": productId});
    results.addAll({"deliveryexecutive_id": executiveid});
    results.addAll({"sku_pickup_quantity": skuPickupQunatity});
    results.addAll({"additional_quantity": additionalquantity});
    results.addAll({"date": date});
    return results;
  }

  factory SkuAdditionalPickupModel.fromMap(Map<String, dynamic> map){
    return SkuAdditionalPickupModel(
      productId: map["product_id"], 
      executiveid: map["deliveryexecutive_id"], 
      skuPickupQunatity: map["sku_pickup_quantity"], 
      additionalquantity: map["additional_quantity"], 
      date: map["date"]
    );
  }
}