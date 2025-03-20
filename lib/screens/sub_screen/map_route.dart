import 'dart:async';
import 'dart:convert';

import 'package:app_5/encrypt_decrypt.dart';
import 'package:app_5/helper/sharedPreference_helper.dart';
import 'package:app_5/model/ordered_products_model.dart';
import 'package:app_5/model/products_model.dart';
import 'package:app_5/providers/api_provider.dart';
import 'package:app_5/repository/app_repository.dart';
import 'package:app_5/service/api_service.dart';
import 'package:app_5/widgets/common_widgets/snackbar_message.dart';
import 'package:app_5/widgets/common_widgets/text_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/subscribed_product_data_model.dart';
import '../../model/delivery_products_model.dart';

class MapScreen extends StatefulWidget {
  final DeliveryProducts productDetails;
  final String address;
  final int customerId;
  final int addressId;
  const MapScreen({
    super.key, 
    required this.productDetails,
    required this.address,
    required this.addressId,
    required this.customerId
  });

  @override
  // ignore: library_private_types_in_public_api
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> mapController = Completer<GoogleMapController>();
  AppRepository userLocationRepository = AppRepository(ApiService(baseUrl: 'https://maduraimarket.in/api'));
  final SharedPreferences prefs = SharedpreferenceHelper.getInstance;
  LatLng? _currentLocation;
  Set<Marker> markers = {};
  final Set<Polyline> _polylines = {};
  LatLng destination = const LatLng(9.9279202, 78.1430728);
  List<int> additionalQuantities = [];
  List<int> additionalOrderedQuantites = [];
  List<int> additionalAllProductQuantites = [];
  List<ProductsModel> allProducts = [];
  List<ProductsModel> tempAllProducts = [];
  late FocusNode _focusNode;
  MapType selectedMapType = MapType.normal;
   List<MapType> mapTypes = [
    MapType.normal,
    MapType.satellite,
    MapType.terrain
  ];
  bool isDelivered = false;
  List<String> mapNames = ['Default', 'Satelite', 'Terrain'];
  // List<String> allProductsNames = [];
  String? selectedProduct;
  List<ProductsModel> addedAllProducts = [];
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _checkLocationService();
    _goToCurrentLocation();
    // _addMarkers();
    // convertAddressToLatLong();
    additionalQuantities = List.generate(widget.productDetails.products.length, (index) => 0,);
    additionalOrderedQuantites = List.generate(widget.productDetails.orderProducts.length, (index) => 0,);
    
  }


  // Check location service is enable or not
  Future<void> _checkLocationService() async {
    var status =  await Permission.location.status;
    if (status.isDenied) {
      if (await Permission.location.request().isGranted) {
        // Permission granted
      }
    } else if (status.isGranted) {
      // Permission already granted
    } else if (status.isPermanentlyDenied) {
      // Handle the case when the user has denied the permission permanently
      openAppSettings();
    }
    await _goToCurrentLocation();
  }

  // Get User Current Location
  Future<void> _goToCurrentLocation() async {
    final GoogleMapController controller = await mapController.future;
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final latLng = LatLng(position.latitude, position.longitude);
    print('current Lat Lang: $latLng');
    setState(() {
      _currentLocation = latLng;
      _addMarkers();
         
    });
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: latLng,
      zoom: 15.0,
    )));
  }
  
  // Get route coordinates from the Map Response
  Future<List<LatLng>> getRouteCoordinates(LatLng start, LatLng wayPointsMap) async {
    const String apiKey = 'AIzaSyDbZcQiUQy-YyCN08yz8OQxQd4z4eRmMqA';
   
    final String url = 'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${wayPointsMap.latitude},${wayPointsMap.longitude}&mode=driving&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final String route = data['routes'][0]['overview_polyline']['points'];
      return _decodePolyline(route);
    } else {
      throw Exception('Failed to load directions');
    }
  }

  // Decode the Poly lines from the Map Response
   List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> points = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  // Create a Marker and the pop-up for update orders
  void _addMarkers() async{
    if (_currentLocation == null) return;
    final routePoints = await getRouteCoordinates(_currentLocation!, destination );
      
    setState(() {
      markers.clear();
    _polylines.clear();
      _polylines.add(Polyline(
        polylineId: const PolylineId('route'),
        points: routePoints,
        color: Colors.blue,
        width: 10,
        jointType: JointType.round,
        endCap: Cap.roundCap,
        startCap: Cap.roundCap,
      ));
      markers.add(Marker(
        markerId: const MarkerId("1"), // Generates 'A', 'B', 'C', etc.
        position: destination,
        infoWindow: InfoWindow(
          title: 'Waypoint 1',
          onTap: () {
          },
        ),
        onTap: (){
          // setState(() {
          //   // final provider = Provider.of<ApiProvider>(context, listen: false);
          //   // tempAllProducts.clear();
          //   // additionalAllProductQuantites.clear();
            
          //   print("All product length: ${allProducts.length}");
          //   print('Temp all products inital length: ${tempAllProducts.length}');
          // });
          showDialog(
            context: context,
            builder: (dialogContext) {
              return Consumer<ApiProvider>(
                builder: (providerContext, provider, child) {
                  selectedProduct = null;
                  allProducts = provider.allProducts;
                  tempAllProducts = provider.allProducts;
                  return AlertDialog(
                    contentPadding: const EdgeInsetsDirectional.all(5),
                    backgroundColor: Colors.white,
                    // scrollable: true,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    surfaceTintColor: Colors.transparent,
                    actionsAlignment: MainAxisAlignment.center,
                    actionsPadding: EdgeInsetsDirectional.zero,
                    title: Column(
                      children: [
                        const Text('Delivery Form'),
                        const SizedBox(height: 10,),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFF60B47B)),
                              borderRadius: BorderRadius.circular(8)
                            ),
                            child: TextWidget(
                              text: DateFormat('dd MMM yyyy').format(DateTime.now()), 
                              fontSize: 14, 
                              fontWeight: FontWeight.w600,
                              fontColor: Theme.of(context).primaryColor
                            )
                          ),
                        ),
                      ],
                    ),
                    content: SizedBox(
                      height: 500,
                      child: CupertinoScrollbar(
                        controller: _scrollController,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Column(
                            children: [
                              _updateProducts(widget.productDetails),
                            ],
                          ),
                        ),
                      ),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Container(
                          width: double.infinity,
                          decoration:  BoxDecoration(color: const Color(0xFF60B47B), borderRadius: BorderRadius.circular(8)),
                          margin: const EdgeInsets.only(top: 10, right: 8, left: 8, bottom: 10),
                          child: TextButton(
                            style: ButtonStyle(
                              surfaceTintColor: WidgetStateProperty.all<Color>(Colors.transparent),
                              shape:WidgetStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                            ),
                            onPressed: () async {
                              try {
                                List<Map<String, dynamic>> updatedSubscribedProductData = [];
                                List<Map<String, dynamic>> updatedOrderedData = [];
                                // List of subscribed Product that delivered to the Customer Data
                                for (int i = 0; i < widget.productDetails.products.length; i++) {
                                  SubscribedProductData productList = widget.productDetails.products[i];
                                  Map<String, dynamic> subscribedProductData = {
                                    'quantity': productList.evgQty + productList.evgQty + additionalQuantities[i],
                                    'sub_id': productList.subId, // Assuming subId is required
                                    'product_id': productList.productId , // Assuming productId is required
                                    'amount': productList.price ,
                                    'delivery_date' : DateFormat("yyyy-MM-dd").format(DateTime.now())// Assuming price is required
                                  };
                                  updatedSubscribedProductData.add(subscribedProductData);
                                }
                                // List of ordered product by user and delivered to the Customer Data
                                for (var i = 0; i < widget.productDetails.orderProducts.length; i++) {
                                  OrderedProductsModel product = widget.productDetails.orderProducts[i];
                                  Map<String, dynamic> orderedData = {
                                    "sub_id": product.orderid,
                                    "product_id": product.productId,
                                    "product_name": product.productName,
                                    "quantity": product.quantity + additionalOrderedQuantites[i],
                                    "product_price":  product.price
                                  };
                                  updatedOrderedData.add(orderedData);
                                }
                                Map<String, dynamic> deliveryData = {
                                  'deliveryexecutive_id': prefs.getString('executiveId'),
                                  'customer_id': widget.customerId,
                                  'address_id': widget.addressId,
                                  'product_data': updatedSubscribedProductData,
                                  'order_data': updatedOrderedData,
                                };
                                final response = await userLocationRepository.updateDelivery(deliveryData);
                                String decryptedResponse= decryptAES(response.body).replaceAll(RegExp(r'[\x00-\x1F\x7F-\x9F]'), '');
                                final decodedResponse = json.decode(decryptedResponse);
                                print('Updated Delivery Response: $decodedResponse, Status Code: ${response.statusCode}');
                                // final deliveredMessage = snackBarMessage(
                                //   context: context, 
                                //   message: decodedResponse['message'], 
                                //   backgroundColor: const Color(0xFF60B47B), 
                                //   sidePadding: MediaQuery.sizeOf(context).width * 0.1,
                                //   bottomPadding: MediaQuery.sizeOf(context).width * 0.05,
                                // );
                                if (response.statusCode == 200 && decodedResponse['status'] == "success") {
                                  provider.messagePopup(context, MediaQuery.sizeOf(context), "assets/happy-face.png", "Order Delivered Successfully");
                                  // Navigator.pop(dialogContext);
                                  // ScaffoldMessenger.of(context).showSnackBar(deliveredMessage).closed.then((value) {
                                    Future.delayed(const Duration(seconds: 2),() {
                                      Navigator.pop(context);
                                      Navigator.pop(dialogContext);
                                      Navigator.pop(context);
                                    },);
                                  // },);
                                }else{
                                  print('Error: $decodedResponse');
                                }
                              } catch (e) {
                                final deliveredMessage = snackBarMessage(
                                  context: context, 
                                  message: "Something went wrong contact admin", 
                                  backgroundColor: const Color(0xFF60B47B), 
                                );
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(deliveredMessage);
                              } 
                            },
                            child: const Text('Mark us Delivered', style: TextStyle(color: Colors.white),),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              );
            },
          );
              
        }
      ));
    });
  }


  @override
  void dispose() {
    super.dispose();
    disposecontroller();
    _focusNode.dispose();
  }

  
  Future<void> disposecontroller() async{
    final GoogleMapController controller = await mapController.future;
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Stack(
      children: [
        GoogleMap(
          zoomControlsEnabled: false,
          onMapCreated: (controller) {
            mapController.complete(controller);
          },
          initialCameraPosition: CameraPosition(
            target: _currentLocation ?? const LatLng(10.708176,78.3843511),
            zoom: _currentLocation != null ? 7.28 : 10.0
          ),
          mapType: selectedMapType,
          trafficEnabled: true,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          compassEnabled: true,
          markers: markers,
          polylines: _polylines,
          onTap: (position) {
            print('Lat Lang: $position');
           
          },
        ),
        Positioned(
          top: size.height * 0.12,
          left: size.width * 0.83,
          child: GestureDetector(
            onTap: (){
              showBottomBar(context: context, size: size, updateMapType: updateMapType);
            },
            child: CircleAvatar(
              radius: size.width * 0.06,
              backgroundColor: const Color(0xFF60B47B,),
              child: const Icon(CupertinoIcons.layers, color: Colors.white,),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          right: 10,
          child: FloatingActionButton(
            elevation: 0,
            backgroundColor: const Color(0xFF60B47B),
            onPressed: _goToCurrentLocation,
            child: const Icon(Icons.my_location, color: Colors.white,),
          ),
        ),
      ],
    );
  }
  
  Widget _updateProducts(DeliveryProducts productList){
    Size size = MediaQuery.sizeOf(context);
    return StatefulBuilder(
      builder: (context, StateSetter update) {
        return CupertinoScrollbar(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10,),
              // subscribe Products to Deliver
              productList.products.isEmpty
              ? Container()
              : const Padding(
                  padding: EdgeInsets.only(left: 12.0),
                  child: TextWidget(text: 'Subscribed Product', fontSize: 16, fontWeight: FontWeight.w500,),
                ),
                SizedBox(
                  height: productList.products.length * 120,
                // subscribe Products List 
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: productList.products.length,
                    itemBuilder: (context, index) {
                      SubscribedProductData product = productList.products[index];
                      return Padding(
                        padding: const EdgeInsets.only(top: 10, left: 12, right: 12),
                        child: Container(
                          height: 110,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8)
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget(
                                text: product.productName, 
                                fontSize: 14, 
                                fontWeight: FontWeight.w600
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: size.width * 0.34,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TextWidget(
                                          text: 'Mrng: ${product.mrngQty.toString()} x ${product.quantity}',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        TextWidget(
                                          text: 'Evng: ${product.evgQty.toString()} x ${product.quantity}',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        TextWidget(
                                          text: 'Price : ₹${product.price.toString()}', 
                                          fontSize: 14, 
                                          fontWeight: FontWeight.w600, 
                                          fontColor: Theme.of(context).primaryColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Additional Quantity enter button
                                  Container(
                                    height: size.height * 0.04,
                                    width: size.width * 0.22,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade400),
                                      borderRadius: BorderRadius.circular(8)
                                    ),
                                    child: Row(
                                      children: [
                                        // Product Quantity decrease
                                        GestureDetector(
                                          onTap: (){
                                            update(() {
                                              if (additionalQuantities[index] > 0) {
                                                additionalQuantities[index] = additionalQuantities[index] - 1;
                                              }
                                            });
                                          },
                                          child: Container(
                                            width: size.width * 0.07,
                                            height: size.height * 0.04,
                                            decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(8),
                                                bottomLeft: Radius.circular(8)
                                              ),
                                              border: Border(right: BorderSide(color: Colors.grey.shade400,))
                                            ),
                                            child: const Icon(Icons.remove, size: 15,),
                                          ),
                                        ),
                                        // Product Quantity Count
                                        SizedBox(
                                          width: size.width * 0.07,
                                          child: Center(
                                            child: Text(
                                              '${additionalQuantities[index]}',
                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ),
                                        // Product Quantity increase
                                        GestureDetector(
                                          onTap: (){
                                              update(() {
                                              additionalQuantities[index] = additionalQuantities[index] + 1;
                                            });
                                          },
                                          child: Container(
                                            width: size.width * 0.07,
                                            height: size.height * 0.04,
                                            decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.only(
                                                topRight: Radius.circular(8),
                                                bottomRight: Radius.circular(8)
                                              ),
                                              border: Border(left: BorderSide(color: Colors.grey.shade400,))
                                            ),
                                            child: Icon(
                                              Icons.add, 
                                              size: 15,
                                              color: additionalQuantities[index] >= 1 
                                              ? const Color(0xFF60B47B)
                                              :  Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                        
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 10,),
              // ordered products list
              productList.orderProducts.isEmpty
              ? Container()
              : const Padding(
                  padding: EdgeInsets.only(left: 12.0),
                  child: TextWidget(text: 'Ordered Product', fontSize: 16, fontWeight: FontWeight.w500,),
                ),
                SizedBox(
                  height: productList.orderProducts.length * size.height * 0.12,
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: productList.orderProducts.length,
                    itemBuilder: (context, index) {
                      OrderedProductsModel product = productList.orderProducts[index];
                      return Padding(
                        padding: const EdgeInsets.only(top: 10, left: 12, right: 12),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          // height: size.height * 0.1,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8)
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  SizedBox(
                                    width: size.width * 0.4,
                                    child: TextWidget(
                                      text: '${product.productName}(${product.quantity})', 
                                      fontSize: 14, 
                                      maxLines: 2,
                                      textOverflow: TextOverflow.ellipsis,
                                      fontWeight: FontWeight.w600
                                    ),
                                  ),
                                  TextWidget(
                                    text: 'Price : ₹${product.price.toString()}', 
                                    fontSize: 14, 
                                    fontWeight: FontWeight.w600, 
                                    fontColor: Theme.of(context).primaryColor,
                                  ),
                                ],
                              ),
                              Container(
                                height: size.height * 0.04,
                                width: size.width * 0.22,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade400),
                                  borderRadius: BorderRadius.circular(8)
                                ),
                                child: Row(
                                  children: [
                                    // Product Quantity decrease
                                    GestureDetector(
                                      onTap: (){
                                        update(() {
                                          if (additionalOrderedQuantites[index] > 1) {
                                            additionalOrderedQuantites[index] = additionalOrderedQuantites[index] - 1;
                                          }
                                        });
                                      },
                                      child: Container(
                                        width: size.width * 0.07,
                                        height: size.height * 0.04,
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(8),
                                            bottomLeft: Radius.circular(8)
                                          ),
                                          border: Border(right: BorderSide(color: Colors.grey.shade400,))
                                        ),
                                        child: const Icon(
                                          CupertinoIcons.minus, 
                                          size: 15,
                                        ),
                                      ),
                                    ),
                                    // Product Quantity Count
                                    SizedBox(
                                      width: size.width * 0.07,
                                      child: Center(
                                        child: Text(
                                          '${additionalOrderedQuantites[index]}',
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ),
                                    // Product Quantity increase
                                    GestureDetector(
                                      onTap: (){
                                        update(() {
                                          additionalOrderedQuantites[index] = additionalOrderedQuantites[index] + 1;
                                        });
                                      },
                                      child: Container(
                                        width: size.width * 0.07,
                                        height: size.height * 0.04,
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(8),
                                            bottomRight: Radius.circular(8)
                                          ),
                                          border: Border(left: BorderSide(color: Colors.grey.shade400,))
                                        ),
                                        child: Icon(
                                          Icons.add, 
                                          size: 15,
                                          color: additionalOrderedQuantites[index] >= 1 
                                          ? const Color(0xFF60B47B)
                                          :  Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                                        
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 10,),
              // All products for Delivery Agent
              const Padding(
                padding: EdgeInsets.only(left: 12.0),
                child: TextWidget(text: 'Additional Product', fontSize: 16, fontWeight: FontWeight.w500,),
              ),
              const SizedBox(height: 10,),
              addedAllProducts.isEmpty
              ? Container()
              : SizedBox(
                  height: addedAllProducts.length * size.height * 0.115,
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: addedAllProducts.length,
                    itemBuilder: (context, index) {
                      // OrderedProductsModel product = productList.orderProducts[index];
                      return Padding(
                        padding: const EdgeInsets.only(top: 10, left: 12, right: 12),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          height: size.height * 0.1,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8)
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextWidget(
                                text: '${addedAllProducts[index].name}(${addedAllProducts[index].quantity})', 
                                fontSize: 14, 
                                fontWeight: FontWeight.w600
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TextWidget(
                                    text: 'Price : ₹${addedAllProducts[index].price.toString()}', 
                                    fontSize: 14, 
                                    fontWeight: FontWeight.w600, 
                                    fontColor: Theme.of(context).primaryColor,
                                  ),
                                  // Additional product count
                                  Container(
                                    height: size.height * 0.04,
                                    width: size.width * 0.22,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade400),
                                      borderRadius: BorderRadius.circular(8)
                                    ),
                                    child: Row(
                                      children: [
                                        // Product Quantity decrease
                                        GestureDetector(
                                          onTap: (){
                                            update(() {
                                              if (additionalAllProductQuantites[index] > 1) {
                                                additionalAllProductQuantites[index] = additionalAllProductQuantites[index] - 1;
                                              }
                                              if (additionalAllProductQuantites[index] == 1) {
                                                tempAllProducts.add(addedAllProducts[index]);
                                                addedAllProducts.removeAt(index);
                                                additionalAllProductQuantites.removeAt(index);
                                              }
                                            });
                                          },
                                          child: Container(
                                            width: size.width * 0.07,
                                            height: size.height * 0.04,
                                            decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(8),
                                                bottomLeft: Radius.circular(8)
                                              ),
                                              border: Border(right: BorderSide(color: Colors.grey.shade400,))
                                            ),
                                            child: Icon(
                                              additionalAllProductQuantites[index] == 1 
                                              ? CupertinoIcons.delete 
                                              : CupertinoIcons.minus, 
                                              size: 15,
                                              color: additionalAllProductQuantites[index] == 1
                                                ? Colors.red
                                                : null,
                                            ),
                                          ),
                                        ),
                                        // Product Quantity Count
                                        SizedBox(
                                          width: size.width * 0.07,
                                          child: Center(
                                            child: Text(
                                              '${additionalAllProductQuantites[index]}',
                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ),
                                        // Product Quantity increase
                                        GestureDetector(
                                          onTap: (){
                                            update(() {
                                              additionalAllProductQuantites[index] = additionalAllProductQuantites[index] + 1;
                                            });
                                          },
                                          child: Container(
                                            width: size.width * 0.07,
                                            height: size.height * 0.04,
                                            decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.only(
                                                topRight: Radius.circular(8),
                                                bottomRight: Radius.circular(8)
                                              ),
                                              border: Border(left: BorderSide(color: Colors.grey.shade400,))
                                            ),
                                            child: Icon(
                                              Icons.add, 
                                              size: 15,
                                              color: additionalAllProductQuantites[index] >= 1 
                                              ? const Color(0xFF60B47B)
                                              :  Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                    
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              // const SizedBox(height: ,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: GestureDetector(
                  onTap: (){
                    print(tempAllProducts.length);
                    FocusScope.of(context).requestFocus(_focusNode);
                  },
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: size.height * 0.05
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade300
                          ),
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Consumer<ApiProvider>(
                          builder: (context, provider, child) {
                            return DropdownButton(
                              dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                              elevation: 3,
                              focusNode: _focusNode,
                              menuMaxHeight: size.height * 0.6,
                              underline: Container(),
                              borderRadius: BorderRadius.circular(8),
                              value: selectedProduct,
                              icon: Container(),
                              alignment: Alignment.center,
                              hint: const TextWidget(
                                text: 'Add Product +', 
                                fontWeight: FontWeight.w500, 
                                fontSize: 13
                              ),
                              items: provider.allProducts.map((product) {
                                return DropdownMenuItem(
                                  value: product.name,
                                  child: TextWidget(
                                    text: product.name, 
                                    fontWeight: FontWeight.w500, 
                                    fontSize: 13
                                  ),
                                );
                              },).toList(), 
                              onChanged: (value) {
                                update(() {
                                  selectedProduct = value!;
                                  print('Selected Product: $selectedProduct');
                                  ProductsModel? selectedModel = provider.allProducts.firstWhere((element) => element.name == selectedProduct, orElse: () => ProductsModel(id: 0, name: "", quantity: "1", price: 0, finalPrice: 0, description: "", image: ""),);
                                  addedAllProducts.add(selectedModel);
                                  print('Added Prodct length: ${addedAllProducts.length}');
                                  additionalAllProductQuantites.add(1);
                                  print('Qunatites - $additionalAllProductQuantites');
                                  selectedProduct = null;
                                });
                              },
                            );
                          }
                        ),
                      ),
                    ),
                  ),
               
                ),
              )
            ],
          ),
        );
        
      },
    );
  }
  
  // change Map Type
  void updateMapType(MapType type){
     setState(() {
      selectedMapType = type;
    });
  }

  // Change map type
  void showBottomBar({
    required BuildContext context,
    required Size size,
    required void Function(MapType) updateMapType
  }){
    showModalBottomSheet(
      backgroundColor: Theme.of(context).cardColor,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero
      ),
      isScrollControlled: true,
      enableDrag: false,
      context: context, 
      builder: (context) {
        List<bool> isSelectedMap = [true, false, false];
        return StatefulBuilder(
          builder: (bottomContext, bottomState) {
            List<String> images = [
              'https://static.packt-cdn.com/products/9781849698863/graphics/B00100_03_01.jpg',
              'https://eos.com/wp-content/uploads/2019/04/free-sat-imgs.jpg.webp',
              'https://cdn.britannica.com/80/149180-050-23E41CF0/topographic-map.jpg'
            ];
            return SizedBox(
              height: size.height * 0.6,
              width: size.width,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20, left: 15, right: 15, bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const TextWidget(
                          text: 'Map Type', 
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                        GestureDetector(
                          onTap: (){
                            Navigator.pop(context);
                          },
                          child: const Icon(CupertinoIcons.xmark)
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      mapTypes.length, 
                      (index) {
                        return SizedBox(
                          height: size.height * 0.15,
                          width: size.width * 0.32,
                          child: ElevatedButton(
                            focusNode: FocusNode(canRequestFocus: false, descendantsAreFocusable: false, descendantsAreTraversable: false),
                            onPressed: (){
                              bottomState(() {
                                for (var i = 0; i < isSelectedMap.length; i++) {
                                  isSelectedMap[i] = false;
                                }
                                isSelectedMap[index] = true;
                                updateMapType(mapTypes[index]);
                              });
                            },
                            style: ButtonStyle(
                              alignment: Alignment.bottomCenter,
                              tapTargetSize: MaterialTapTargetSize.padded,
                              backgroundColor: WidgetStateProperty.all(Theme.of(context).cardColor),
                              elevation: WidgetStateProperty.all(0),
                              maximumSize: WidgetStatePropertyAll(size),
                              shape: WidgetStateProperty.all(const CircleBorder()),
                              shadowColor: WidgetStatePropertyAll(Colors.transparent.withValues(alpha: 0.1)),
                              padding: const WidgetStatePropertyAll(EdgeInsets.only(top: 20)),
                              surfaceTintColor: WidgetStateProperty.all(Colors.transparent.withValues(alpha: 0.0))
                            ),
                            child: Center(
                              child: Column(
                                children: [
                                  Container(
                                    height: 60,
                                    width: 60,
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border:  isSelectedMap[index] 
                                      ? Border.all(
                                        color: Colors.blue,
                                        width: 3.0,
                                      )
                                      : Border.all(width: 0, color: Colors.white)
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        imageUrl: images[index],
                                        fit: BoxFit.cover,
                                        alignment: Alignment.topCenter,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5,),
                                  TextWidget(
                                    text: mapNames[index], 
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    fontColor: isSelectedMap[index] ? Colors.blue : null,
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }


}
