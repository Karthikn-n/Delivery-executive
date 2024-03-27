// ignore_for_file: prefer_final_fields, library_private_types_in_public_api, no_leading_underscores_for_local_identifiers, avoid_print

import 'dart:convert';

import 'package:app_5/common_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/directions.dart' as poly;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart' as poll;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  final List<LatLng> locations;
  final List<String> addresses;
  final List<String> names;
  final List<ProductDetails> productDetails;
  const MapScreen({
    super.key, 
    required this.locations, 
    required this.addresses, 
    required this.names, 
    required this.productDetails
  });

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  MapType _mapType = MapType.normal;
  Position? _currentLocation;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  String key = 'AIzaSyDbZcQiUQy-YyCN08yz8OQxQd4z4eRmMqA';
  DateTime selectedDateTime = DateTime.now();

  List<LatLng> waypoints = const [
    LatLng(9.9279202, 78.1430728),
    LatLng(9.9263217, 78.1447517),
    LatLng(9.9292882, 78.147079),
    LatLng(9.93062, 78.1485474),
    LatLng(9.926907, 78.1485786),
  ];

  @override
  void initState() {
    super.initState();
    _checkLocationService();
  }

  Future<void> _checkLocationService() async {
    bool _locationServiceEnabled;
    LocationPermission _locationPermission;

    _locationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!_locationServiceEnabled) {
      _locationServiceEnabled = await Geolocator.openLocationSettings();
      if (!_locationServiceEnabled) {
        _showSnackbar('Location services are disabled');
        return;
      }
    }

    _locationPermission = await Geolocator.checkPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
      if (_locationPermission != LocationPermission.whileInUse &&
          _locationPermission != LocationPermission.always) {
        _showSnackbar('Location permission denied');
        return;
      }
    }

    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      _currentLocation = await Geolocator.getCurrentPosition();
      _moveToLocation(_currentLocation!);
      _getPolylines();
    } catch (e) {
      _showSnackbar('Unable to get current location');
    }
  }

  Future<void> _getPolylines() async {
    List<LatLng> polylineCoordinates = [];
    final directions = poly.GoogleMapsDirections(apiKey: key);
    List<TextEditingController> _productControllers = List.generate(
      waypoints.length,
      (index) => TextEditingController(),
    );
    List<String> milkOptions = ['250ml', '500ml', '1ltr'];
    List<String> curdOptions = ['200ml', '500ml'];
    List<String> paneerOptions = ['200g', '500g'];
    List<String> gheeOptions = ['100ml', '200ml', '500ml'];
    List<String> selectedOption = [
      milkOptions.first,
      curdOptions.first,
      paneerOptions.first,
      gheeOptions.first,
      gheeOptions.first,
      
    ];
    List<List<String>> options = [
      ['250ml', '500ml', '1ltr'],
      ['200ml', '500ml'],
      ['200g', '500g'],
      ['100ml', '200ml', '500ml'],
      ['100ml', '200ml', '500ml'],
    ];
    List<String> names =[
      'Milk',
      'Curd',
      'Panneer',
      'Ghee',
      'Rose Milk',
    ];
    polylineCoordinates.add(LatLng(_currentLocation!.latitude, _currentLocation!.longitude));

     // Part 1: Generate polyline from current location to the first waypoint
      poly.DirectionsResponse firstResult = await directions.directionsWithLocation(
        poly.Location(lat: _currentLocation!.latitude, lng: _currentLocation!.longitude),
        poly.Location(lat: waypoints[0].latitude, lng: waypoints[0].longitude),
        travelMode: poly.TravelMode.driving,
      );

      if (firstResult.isOkay) {
        for (var step in firstResult.routes.first.legs.first.steps) {
          List<poll.PointLatLng> points = _decodePolyline(step.polyline.points);
          for (var point in points) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          }
        }
      }

      // Part 2: Generate polylines between the rest of the waypoints
      for (var i = 0; i < waypoints.length - 1; i++) {
        poly.DirectionsResponse result = await directions.directionsWithLocation(
          poly.Location(lat: waypoints[i].latitude, lng: waypoints[i].longitude),
          poly.Location(lat: waypoints[i + 1].latitude, lng: waypoints[i + 1].longitude),
          travelMode: poly.TravelMode.driving,
        );

        if (result.isOkay) {
          for (var step in result.routes.first.legs.first.steps) {
            List<poll.PointLatLng> points = _decodePolyline(step.polyline.points);
            for (var point in points) {
              polylineCoordinates.add(LatLng(point.latitude, point.longitude));
            }
          }
        }
      }

    setState(() {
      _polylines.clear();
      _polylines.add(Polyline(
        polylineId: const PolylineId("route"),
        color: Colors.blue,
        points: polylineCoordinates,
        width: 8,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ));
      _markers.clear();
      for (var i = 0; i < waypoints.length; i++) {
        //  String shopName = await _getShopName(waypoints[i]);
        _markers.add(Marker(
          markerId: MarkerId("Delivery $i"),
          position: waypoints[i],
          infoWindow: InfoWindow(
            title: "Waypoint ${i + 1}", snippet: 'Prdocuts delivered ${_productControllers[i].text}',
            onTap: () {
               showDialog(
                context: context,
                builder: (BuildContext context) {
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
                        Row(
                          children: [
                            const SizedBox(width: 50,),
                            const Text('Select date: ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),),
                            GestureDetector(
                              onTap: () {
                                _selectDateTime(context);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFF60B47B))
                                ),
                                child: Text(
                                  DateFormat('yyyy-MM-dd').format(selectedDateTime), 
                                  style: const TextStyle(
                                    fontSize: 12, 
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF60B47B)
                                  ),
                                )
                              )
                            ),
                          ],
                        ),
                      ],
                    ),
                    content: SizedBox(
                      height: 500,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Text('You tapped on Waypoint ${i+1}'),
                            const Align(
                              alignment: Alignment.topRight,
                              child: SizedBox(
                                height: 40,
                                width: 75,
                                child: Text('Additional Quantity:', overflow: TextOverflow.ellipsis, maxLines: 2, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),),
                              ),
                            ),
                            for(var j = 0; j < selectedOption.length; j++)
                              _buildProductDropdown(names[j], selectedOption, options, j)
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(color: Color(0xFF60B47B)),
                        child: TextButton(
                          style: ButtonStyle(
                            surfaceTintColor: MaterialStateProperty.all<Color>(Colors.transparent),
                            shape:MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))),
                          ),
                          onPressed: () {
                            // sendData(products, weight, quantities, additional, names, addresses)
                            Navigator.of(context).pop();
                          },
                          child: const Text('Delivered', style: TextStyle(color: Colors.white),),
                        ),
                      ),
                    ],
                  );
                },
              );
            
            },
          ),
        ));
      }
    });
  }

  List<poll.PointLatLng> _decodePolyline(String encoded) {
    List<poll.PointLatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));

      points.add(poll.PointLatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  void _moveToLocation(Position location) {
    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLng(LatLng(
        location.latitude,
        location.longitude,
      )));
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: selectedDateTime,
    firstDate: DateTime.now(),
    lastDate: DateTime(2101),
  );

  if (pickedDate != null && pickedDate != selectedDateTime) {
    // Keep the time part from the existing selectedDateTime
    final pickedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      selectedDateTime.hour,
      selectedDateTime.minute,
    );

    setState(() {
      selectedDateTime = pickedDateTime;
    });

    // Convert selectedDateTime to Indian Standard Time (IST)
    final indianStandardTime = selectedDateTime.toLocal();

    // Print the result
    print('Selected DateTime: $selectedDateTime');
    print('Indian Standard Time: $indianStandardTime');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Locations'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              setState(() {
                _mapController = controller;
              });
            },
            initialCameraPosition: CameraPosition(
              target: waypoints.first,
              zoom: 15.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapType: _mapType,
            markers: _markers,
            polylines: _polylines,
            
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _mapType = _mapType == MapType.normal ? MapType.hybrid : MapType.normal;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _mapType == MapType.hybrid ? Colors.white : Colors.black,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    height: 50,
                    width: 50,
                    child: CachedNetworkImage(
                      imageUrl: _mapType == MapType.hybrid
                          ? 'https://images.unsplash.com/photo-1574786199452-c7a5f69fb6e9?q=80&w=1480&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'
                          : 'https://s1.cdn.autoevolution.com/images/news/gallery/how-google-maps-knows-youre-braking-hard-so-it-can-find-safer-routes_1.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildProductDropdown(String productName, List<String> selectedoptions, List<List<String>> options, int i) {
    List<String> option = options[i];
    List<int> quantityCounters = List<int>.filled(option.length, 0); // Initial quantity counters

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(child: Text('$productName:')),
                // Display available options as a list
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var j = 0; j < option.length; j++)
                      Row(
                        children: [
                          SizedBox(
                            width: 50,
                            child: Column(
                              children: [
                                Text('${option[j]}: ', overflow: TextOverflow.ellipsis,),
                              ],
                            ),
                          ),
                          // const SizedBox(width: 10,),
                          // Quantity counter for each option
                          Column(
                            children: [
                              Row(
                                children: [
                                  // GestureDetector(
                                  //   onTap: () {
                                  //     setState(() {
                                  //       if (quantityCounters[j] > 0) {
                                  //         quantityCounters[j]--;
                                  //       }
                                  //     });
                                  //   },
                                  //   child: Container(
                                  //     margin: const EdgeInsets.only(top: 4),
                                  //     decoration: BoxDecoration(
                                  //       color: Colors.grey.shade300
                                  //     ),
                                  //     height: 30,
                                  //     width: 25,
                                  //     child: const Icon(Icons.remove, size: 12,),
                                  //   ),
                                  // ),
                                  
                                  Container(
                                    decoration: const BoxDecoration(
                                        color: Colors.white
                                      ),
                                    height: 20,
                                    width: 40,
                                    child: Center(
                                      child: Text(quantityCounters[j].toString())
                                    )
                                  ),
                                  // GestureDetector(
                                  //   onTap: () {
                                  //     setState(() {
                                  //       quantityCounters[j]++;
                                  //     });
                                  //   },
                                  //   child: Container(
                                  //     decoration: BoxDecoration(
                                  //       color: Colors.grey.shade300
                                  //     ),
                                  //     height: 30,
                                  //     width: 25,
                                  //     child: const Icon(Icons.add, size: 12,),
                                  //   ),
                                  // ),
                                
                                ],
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Container(
                                height: 30,
                                width: 70,
                                margin: const EdgeInsets.only(left: 10, right: 10, top: 5),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.1),
                                ),
                                child: TextFormField(
                                  textAlign: TextAlign.center,
                                  textAlignVertical: TextAlignVertical.center,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              // width: ,
                child: Divider(
                color: Colors.black26,
                thickness: 1,
              ),
              )
          ],
        );
      },
    );
  }
  Future<void> sendData(List<String> products, List<String> weight, List<String> quantities, List<String> additional, List<String> names, List<String> addresses) async {
    List<Map<String, dynamic>> quantityList = [];
    for (int i = 0; i < products.length; i++) {
      Map<String, dynamic> quantity = {
        'product_name': {
          products[i] :  {
              weight[i] : quantities[i],
            }
          },
          'address': addresses[i],
          'name': names[i],
         'additional_quantity': {
          weight[i] : additional[i]
         }
      };
      quantityList.add(quantity);
    }
    String url = 'http://pasumaibhoomi.com/api/delivered';
    Map<String, dynamic> userData = {
      'agent_id': UserId.getAgentId(),
      'product_id': UserId.getproductId(),
      'customer_id': UserId.getUserId(),
      'delivered_product': quantityList
    };
    String jsonData = json.encode(userData);
    String encryptedData = encryptAES(jsonData);
    print('Encrypted: $encryptedData');
    final response = await http.post(Uri.parse(url), body: {'data': encryptedData});
    print('Success: ${response.body}');
    if (response.statusCode == 200) {
      print('Success: ${response.statusCode}');
    }else{
      print('Error: ${response.body}');
    }
  }
}
