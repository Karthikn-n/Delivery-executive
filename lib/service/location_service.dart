import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:app_5/encrypt_decrypt.dart';
import 'package:app_5/helper/sharedPreference_helper.dart';
import 'package:app_5/repository/app_repository.dart';
import 'package:app_5/service/api_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static final LocationService _locationService = LocationService._internal();

  factory LocationService() {
    return _locationService;
  }

  LocationService._internal();
  StreamSubscription<Position>? _positionSubscription;
  Timer? _timer;
  final AppRepository _repo = AppRepository( ApiService(baseUrl: "https://maduraimarket.in/api"));
  final SharedPreferences _prefs = SharedpreferenceHelper.getInstance;
  Future<void> init() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      await openAppSettings();
      // print('Location permissions are permanently denied.');
      // return;
    }
    await _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    Position? position;
    _positionSubscription = getLocationStream().listen((event) {
      position = event;
    },);
    await updateLocation(position, DateTime.now());
    _timer = Timer.periodic(const Duration(minutes: 5), (timer) async{
      await updateLocation(position, DateTime.now());
    },);
  }
  
  void cancelTimer() => _timer?.cancel();

  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      )
    );
  }

  Future<void> updateLocation(Position? position, DateTime time) async {
    try {
      Map<String, dynamic> body = {
        "latitude": position!.latitude,
        "longitude": position.longitude,
        "updating_time": time,
        "executive_id": _prefs.getString("executiveId")
      };
      final response = await _repo.updateLocation(body);
      if(response.statusCode == 200) {
        final decreyptedResponse = decryptAES(response.body).replaceAll(RegExp(r'[\x00-\x1F\x7F-\x9F]'), "");
        final decodedMessage = json.decode(decreyptedResponse);
        log("Response : $decodedMessage");
      } else {
        log("Something went wrong on updating location");
      }
    } catch (e) {
      throw Exception(e);
    } 
  }

} 