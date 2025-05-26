class ProductsModel{
  final int id;
  final String name;
  final String quantity;
  final int price;
  final int finalPrice;
  final String description;
  final String image;

  ProductsModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.finalPrice,
    required this.description,
    required this.image,
  });

  Map<String, dynamic> toMap(){
    final result = <String, dynamic>{};

    result.addAll({"product_id": id});
    result.addAll({"product_name": name});
    result.addAll({"quantity": quantity});
    result.addAll({"price": price});
    result.addAll({"final_price": finalPrice});
    result.addAll({"description": description});
    result.addAll({"image": image});

    return result;
  }

  factory ProductsModel.fromMap(Map<String, dynamic> map){
    return ProductsModel(
      id: map["product_id"], 
      name: map["product_name"], 
      quantity: map["quantity"], 
      price: int.tryParse(map["price"].toString()) ?? 0, 
      finalPrice: int.tryParse(map["final_price"].toString()) ?? 0, 
      description: map["description"], 
      image: map["image"]
    );
  }
}