import 'dart:async';
import 'dart:convert';

import 'package:app_5/encrypt_decrypt.dart';
import 'package:app_5/providers/connectivity_helper.dart';
import 'package:app_5/repository/app_repository.dart';
import 'package:app_5/service/api_service.dart';
import 'package:app_5/widgets/common_widgets/button.dart';
import 'package:app_5/widgets/common_widgets/snackbar_message.dart';
import 'package:app_5/widgets/common_widgets/text_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';


class UpdateLocation extends StatefulWidget {
  final String name;
  final int customerId;
  final int addressId;
  const UpdateLocation({
    super.key, 
    required this.name, 
    required this.customerId, 
    required this.addressId
  });

  @override
  State<UpdateLocation> createState() => _UpdateLocationState();
}

class _UpdateLocationState extends State<UpdateLocation> {
  AppRepository updateLocationRepo = AppRepository(ApiService(baseUrl: 'https://maduraimarket.in/api'));
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();
  LatLng? currentLocation;
  LatLng maduraiLat = const LatLng(9.9193256,78.0958682);
  final Set<Marker> _markers = {};
  MapType selectedMapType = MapType.normal;
   List<MapType> mapTypes = [
    MapType.normal,
    MapType.satellite,
    MapType.terrain
  ];
  List<String> mapNames = ['Default', 'Satelite', 'Terrain'];
  @override
  void initState(){
    super.initState();
    _checkLocationService();
    _goToCurrentLocation();
    // _getCurrentLocation();
  }

  @override
  void dispose() {
    super.dispose();
    disposecontroller();    
  }

  Future<void> disposecontroller() async{
    final GoogleMapController controller = await _mapController.future;
    controller.dispose();
  }

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
    // await _goToCurrentLocation();
  }

  Future<void> _goToCurrentLocation() async {
    final GoogleMapController controller = await _mapController.future;
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final latLng = LatLng(position.latitude, position.longitude);
   
    setState(() {
      currentLocation = latLng;
      currentLocation != null ? _addMarker(latLng, "User Location") : null;
         
    });
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: latLng,
      zoom: 15.0,
    )));
    print('Called');
  }
  
 
  void _addMarker(LatLng position, String markerId, ) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(markerId),
          position: position,
          infoWindow: InfoWindow(
            title: 'Update correct Address',
            snippet: markerId,
            onTap: () {
             
            },
          ),
          onTap: () {
            showDialog(
              context: context, 
              builder: (context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // Set your desired border radius
                  ),
                  backgroundColor: Colors.transparent,
                  child: Container(
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 10.0,),
                              child: Text(
                                'Update Location',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Padding(
                            padding:  EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                'Did you verfiy this is correct address of',
                                style: TextStyle(fontSize: 12.0),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                widget.name,
                                style: const TextStyle(fontSize: 12.0,fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 5),
                            child: GestureDetector(
                              onTap: (){
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Colors.grey.shade200),
                                    top:  BorderSide(color: Colors.grey.shade200),
                                  )
                                ),
                                child: const Center(
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(0),
                            child: GestureDetector(
                              onTap: () async {
                                Map<String, dynamic> updateLocationData = {
                                  'customer_id': widget.customerId,
                                  'address_id': widget.addressId,
                                  'latitude': currentLocation!.latitude,
                                  'longitude': currentLocation!.longitude
                                };
                                final response = await updateLocationRepo.updateLatLang(updateLocationData);
                                String decryptedResponse = decryptAES(response.body).replaceAll(RegExp(r'[\x00-\x1F\x7F-\x9F]'), '');
                                final decodedResponse = json.decode(decryptedResponse);
                                print('Update Location Response : $decodedResponse, Status Code: ${response.statusCode}');
                                final updateLocationMessage = snackBarMessage(
                                  context: context, 
                                  message: decodedResponse['message'], 
                                  backgroundColor: Theme.of(context).primaryColor 
                                );
                                if(response.statusCode == 200 && decodedResponse['status'] == "success"){
                                  ScaffoldMessenger.of(context).showSnackBar(updateLocationMessage).closed.then((value) {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },);
                                }else{
                                   ScaffoldMessenger.of(context).showSnackBar(updateLocationMessage);
                                   print('Error $decodedResponse');
                                }
                              },
                              child: const SizedBox(
                                height: 40,
                                child: Center(
                                  child: Text(
                                    'Update',
                                    style: TextStyle(
                                      color: Colors.blue, // Set your desired color
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        )
      );
    });
    }


  @override
  Widget build(BuildContext context) {
    final checkConnectivity = Provider.of<ConnectivityService>(context);
    Size size = MediaQuery.sizeOf(context);
    return !checkConnectivity.isConnected
    ? Scaffold(
        // appBar: AppBar(),
        body: Center(
          child: Column(
            children: [
              SizedBox(height: size.height * 0.25,),
              GestureDetector(
                onTap: () =>  print('${size.height} ${size.width}'),
                child: SizedBox(
                  height: size.height * 0.3,
                  width: size.width * 0.6,
                  child: Image.asset(
                    'assets/nointernet.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.005,),
              const TextWidget(text: 'OOPS!', fontWeight: FontWeight.w800, fontSize: 24),
              SizedBox(height: size.height * 0.005,),
              const TextWidget(text: 'NO INTERNET', fontWeight: FontWeight.w800, fontSize: 24),
              SizedBox(height: size.height * 0.01,),
              const TextWidget(text: 'Please check your internet connection.', fontWeight: FontWeight.w400, fontSize: 16),
              SizedBox(height: size.height * 0.02,),
              SizedBox(
              height: size.height * 0.06,
              width: size.width * 0.7,
              child: ButtonWidget(title: 'Try Again', onPressed: () => checkConnectivity.isConnected ,)
              ),
              SizedBox(height: size.height * 0.22,),
            ],
          ),
        ),
      )
    : Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Update location',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) async {
              // setState(() {
              //   _mapController = controller;
              // });
              _mapController.complete(controller);
            },
            initialCameraPosition: CameraPosition(
              target: currentLocation ?? const LatLng(10.708176,78.3843511),
              zoom: currentLocation != null ? 7.28 : 10.0
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            mapType: selectedMapType,
            markers: _markers,
            zoomControlsEnabled: false,
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
      ),                         
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
                              shadowColor: WidgetStatePropertyAll(Colors.transparent.withOpacity(0.1)),
                              padding: const WidgetStatePropertyAll(EdgeInsets.only(top: 20)),
                              surfaceTintColor: WidgetStateProperty.all(Colors.transparent.withOpacity(0.0))
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



