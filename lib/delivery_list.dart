// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:app_5/common_data.dart';
import 'package:app_5/map_route.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeliveryListPage extends StatefulWidget {
  const DeliveryListPage({super.key});

  @override
  State<DeliveryListPage> createState() => _DeliveryListPageState();
}

class _DeliveryListPageState extends State<DeliveryListPage> {
  //  DateTime selectedDate = DateTime.now();
  late DateTime selectedDate = DateTime.now();
  bool isorderTotalSelected = true;
  bool isorderDeliveredSelected = false;
  bool isorderPedningSelected = false;
  bool isProductcollectedSelected = false;
  bool isProductPendingSelected = false;
  List<String> names = [
    'Rajesh Kumar',
    'Saranya Devi',
    'Prakash Raj',
    'Deepa Senthil',
    'Gokul Kumar',
  ];
  List<String> addresses = [
    'W48J+4RP, AA Road, Chairman Muthuramaiyer Rd, Balrangapuram, Tamil Nadu 625009',
    'Old Kuyavar Palayam Rd, near Agarwal Bhavan, Munichali, Madurai, Tamil Nadu 625009',
    'W48J+FVR, Chairman Muthuramaiyer Rd, Munichali, Navarathinapuram, Madurai, Tamil Nadu 625009',
    '139, New Ramnad Rd, Meenakshi Nagar, Madurai, Tamil Nadu 625009',
    'Navarathinapuram, Madurai, Tamil Nadu 625009',
  ];

  List<String> packing = [
    'Keep in bag',
    'Keep in bag',
    'In hand Delivery',
    'In hand Delivery',
    'Keep in bag',
  ];
  List<String> notes = [
    'Need 250g packet',
    '',
    '',
    'Need 200g packet',
    'Need 500g packet',
  ];
  List<LatLng> cutomerLocation = [];
  List<String> customerName = [];
  List<String> customerAddress = [];
  List<ProductDetails> productDetailsList = [];


  @override
  void initState() {
    super.initState();
    loadSelectedDate();
  }
  
  Future<void> loadSelectedDate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? savedTimestamp = prefs.getInt('selectedDate');

    if (savedTimestamp != null) {
      setState(() {
        selectedDate = DateTime.fromMillisecondsSinceEpoch(savedTimestamp);
      });
    } else {
      // If no saved date, use the current date as default
      selectedDate = DateTime.now();
    }
  }

  Future<void> saveSelectedDate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('selectedDate', selectedDate.millisecondsSinceEpoch);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2050, 12, 31),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        saveSelectedDate();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deliver List'),
        actions: [
          action()
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 210,
              width: double.infinity,
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 50,
                    width: 300,
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Search Customer Name',
                        suffixIcon: const Icon(Icons.search),
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: Colors.grey.withOpacity(0.5) 
                        )
                      ),
                      textInputAction: TextInputAction.search,
                    ),
                  ),
                  
                  Row(
                    children: [
                      Container(
                        height: 120,
                        width: 180,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        child: Column(
                          children: [
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Text('ORDERS', style: TextStyle(letterSpacing: -0.5),),
                              ),
                            ),
                            const Divider(
                              color: Colors.black26,
                              thickness: 1,
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isorderTotalSelected = true;
                                      isorderDeliveredSelected = false;
                                      isorderPedningSelected = false;
                                      isProductcollectedSelected = false;
                                      isProductPendingSelected = false;
                                    });
                                  },
                                  child: Container(
                                    height: 80,
                                    width: 55 ,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: isorderTotalSelected
                                                ? Colors.blue
                                              : Colors.transparent,
                                          )
                                      ),
                                    ),
                                    child: details('order', 'Total', '24')
                                  )
                                ),
                                const SizedBox(width: 4,),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isorderTotalSelected = false;
                                      isorderDeliveredSelected = true;
                                      isorderPedningSelected = false;
                                      isProductcollectedSelected = false;
                                      isProductPendingSelected = false;
                                    });
                                  },
                                  child: Container(
                                    height: 80,
                                    width: 55 ,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: isorderDeliveredSelected
                                                ? Colors.blue
                                              : Colors.transparent,
                                          )
                                      ),
                                    ),
                                    child: details('order', 'Delivered', '0')
                                  ),
                                ),
                                const SizedBox(width: 4,),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isorderTotalSelected = false;
                                      isorderDeliveredSelected = false;
                                      isorderPedningSelected = true;
                                      isProductcollectedSelected = false;
                                      isProductPendingSelected = false;
                                    });
                                  },
                                  child: Container(
                                    height: 80,
                                    width: 55 ,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: isorderPedningSelected
                                                ? Colors.blue
                                              : Colors.transparent,
                                          )
                                      ),
                                    ),
                                    child: details('order', 'Pending', '24')
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                      Container(
                        height: 120,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Text('PRODUCTS', style: TextStyle(letterSpacing: -0.5),),
                              ),
                            ),
                            const Divider(
                              color: Colors.black26,
                              thickness: 1,
                            ),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isorderTotalSelected = false;
                                          isorderDeliveredSelected = false;
                                          isorderPedningSelected = false;
                                          isProductcollectedSelected = true;
                                          isProductPendingSelected = false;
                                        });
                                      },
                                      child: Container(
                                        height: 80,
                                        width: 72 ,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: isProductcollectedSelected
                                                    ? Colors.blue
                                                  : Colors.transparent,
                                              )
                                          ),
                                        ),
                                        child: details('product', 'Collected', '24')
                                      ),
                                    ),
                                    const SizedBox(width: 4,),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isorderTotalSelected = false;
                                          isorderDeliveredSelected = false;
                                          isorderPedningSelected = false;
                                          isProductcollectedSelected = false;
                                          isProductPendingSelected = true;
                                        });
                                      },
                                      child: Container(
                                        height: 80,
                                        width: 72 ,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: isProductPendingSelected
                                                    ? Colors.blue
                                                  : Colors.transparent,
                                              )
                                          ),
                                        ),
                                        child: details('product','Pending', '0')
                                      ),
                                    )
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            if(isorderTotalSelected)
             orderTotal()
            else if(isorderDeliveredSelected)
              const Text('Delivered')
            else if(isorderPedningSelected)
              const Text('Pending')
            else if(isProductcollectedSelected)
              const Text('Collected')
            else 
              const Text('data')
          ],
        ),
      ),
    );
  }
  
  Widget action(){
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        height: 25,
        width: 104,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(6)
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month),
            Text(
              "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
  Widget details(String title,String name, String quality){
    return SizedBox(
      height: 80,
      width: title == 'product' ? 72 :55,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(name, style: const TextStyle(letterSpacing: -0.5),),
              Text(quality, style: const TextStyle(letterSpacing: -0.5),)
            ],
          ),
        ),
      )
    );
  }
  Widget orderTotal(){
    return SizedBox(
      height: 450,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        child: ListView.builder(
          itemCount: names.length,
          itemBuilder: (context, index) {
            String name = names[index];
            String address = addresses[index];
            String note = notes[index];
            String pack = packing[index];
            return  Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)
              ),
              margin: const EdgeInsets.only(top: 10),
              width: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 5, top: 5),
                    child: Text(name, style: const TextStyle(fontSize: 16, color: Color(0xFF60B47B)),),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5, bottom: 5),
                    child: Row(
                      children: [
                        const Icon(Icons.home_outlined, color:Color(0xFF60B47B),),
                        const SizedBox(width: 4,),
                        Expanded(child: Text(address))
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5, bottom: 5),
                    child: Row(
                      children: [
                        const Icon(Icons.shopping_bag, color: Color(0xFF60B47B),),
                        const SizedBox(width: 4,),
                        Text(pack)
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5, bottom: 5),
                    child: Row(
                      children: [
                        const Icon(Icons.edit_document, color: Color(0xFF60B47B),),
                        const SizedBox(width: 4,),
                        Text(note)
                      ],
                    ),
                  ),
                  const Divider(
                    color: Colors.black26,
                    thickness: 1,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5, top: 5, bottom: 5),
                    child: Row(
                      children: [
                        const SizedBox(width: 4,),
                        const Row(
                          children: [
                            Icon(Icons.water_drop, size: 12, color: Colors.black54,),
                            SizedBox(width: 4,),
                            Text('Product')
                          ],
                        ),
                        const SizedBox(height: 40, child: VerticalDivider(color: Colors.black26, thickness: 1,)),
                        SizedBox(width: 4,),
                        Row(
                          children: [
                            Icon(Icons.currency_rupee, size: 12, color: Colors.black54,),
                            SizedBox(width: 4,),
                            Text('Payment')
                          ],
                        ),
                        SizedBox(height: 40, child: VerticalDivider(color: Colors.black26, thickness: 1,)),
                        SizedBox(width: 4,),
                        Row(
                          children: [
                            Icon(Icons.phone,  size: 12, color: Colors.black54,),
                            SizedBox(width: 8,),
                            Text('Call'),
                            SizedBox(width: 4,),
                          ],
                        ),
                        SizedBox(height: 40, child: VerticalDivider(color: Colors.black26, thickness: 1,)),
                        SizedBox(width: 4,),
                        GestureDetector(
                          onTap: () async {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => MapScreen(
                                  locations: cutomerLocation, 
                                  addresses: customerAddress, 
                                  names: customerName, 
                                  productDetails: productDetailsList,
                                ),
                              )
                            );
                          },
                          child: Row(
                            children: [
                              Icon(Icons.directions, size: 12, color: Colors.black54,),
                              SizedBox(width: 4,),
                              Text('Direction')
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
  Future<void> sendData() async {
    String url = 'http://pasumaibhoomi.com/api/customer_location';
    Map<String, dynamic> userData = {
      'agent_id': UserId.getAgentId()
    };
    String jsonData = json.encode(userData);
    String encryptedData = encryptAES(jsonData);
    final response = await http.post(Uri.parse(url), body: {'data': encryptedData});
    if(response.statusCode == 200){
      String decryptedData = decryptAES(response.body);
      Map<String, dynamic> decodedData = json.decode(decryptedData);
      if (decodedData.containsKey('results')) {
        List<dynamic> results = decodedData['results'];

        for (var result in results) {
          // Extracting data
          int customerId = result['customer_id'];
          String firstName = result['first_name'];
          String lastName = result['last_name'];
          String flatNo = result['flat_no'];
          String mobileNo = result['mobile_no'];
          String address = result['address'];
          String floor = result['floor'];

          // Creating LatLng from address
          LatLng latLng = await _getLatLngFromAddress(address);
          cutomerLocation.add(latLng);

          // Creating a single string from first name and last name
          String fullName = '$firstName $lastName';
          customerName.add(fullName);

          // Creating a single string from flat no, mobile no, address, and floor
          String fullAddress = '$flatNo, $mobileNo, $address, $floor';
          customerAddress.add(fullAddress);
          List<dynamic> productData = result['product_data'];
           for (var product in productData) {
              int productId = product['product_id'];
              String productName = product['product_name'];
              String quantity = product['quantity'];
              int mrngQty = product['mrg_qty'];
              int evgQty = product['evg_qty'];
              String productPrice = product['product_price'];

              // Creating a ProductDetails object
              ProductDetails productDetails = ProductDetails(
                productId: productId,
                productName: productName,
                quantity: quantity,
                mrngQty: mrngQty,
                evgQty: evgQty,
                productPrice: productPrice,
              );

              // Adding the product details to the list
              productDetailsList.add(productDetails);
            }
        }
      }
    }
  }
  Future<LatLng> _getLatLngFromAddress(String address) async {
      final places = await GeocodingPlatform.instance
          .locationFromAddress(address);
      LatLng latLng = LatLng(places.first.latitude, places.first.longitude);
      return latLng;
    }

}

