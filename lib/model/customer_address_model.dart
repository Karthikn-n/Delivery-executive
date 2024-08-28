class CustomerAddress{
  final int customerId;
  final String firstName;
  final String lastName;
  final String email;
  final String mobileNo;
  final int addressId;
  final String address;
  final String floor;
  final String flatNo;
  final String landmark;
  final String pincode;
  final String location;
  final String region;


  CustomerAddress({
    required this.customerId, 
    required this.firstName, 
    required this.lastName, 
    required this.email, 
    required this.mobileNo, 
    required this.addressId, 
    required this.address, 
    required this.floor, 
    required this.flatNo, 
    required this.landmark, 
    required this.pincode, 
    required this.location, 
    required this.region, 
 
  });

  factory CustomerAddress.fromJson(Map<String, dynamic> json){
    return CustomerAddress(
      customerId: json['customer_id'] ?? 0, 
      firstName: json['first_name'] ?? '', 
      lastName: json['last_name'] ?? '', 
      email: json['email'] ?? '', 
      mobileNo: json['mobile_no'] ?? '', 
      addressId: json['address_id'] ?? 0, 
      address: json['address'] ?? '', 
      floor: json['floor'] ?? '', 
      flatNo: json['flat_no'] ?? '', 
      landmark: json['landmark'] ?? '', 
      pincode: json['pincode'] ?? '', 
      location: json['location'] ?? '', 
      region: json['region'] ?? '', 
    );
  }
}
