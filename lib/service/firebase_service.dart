import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_5/helper/sharedPreference_helper.dart';
import 'package:app_5/service/location_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseService with WidgetsBindingObserver{

  static final FirebaseService _firebaseService = FirebaseService._internal();
  FirebaseService._internal();
  factory FirebaseService() {
    return _firebaseService;
  }

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocationService _locationService = LocationService();
  SharedPreferences prefs = SharedpreferenceHelper.getInstance;

  /// Create a new document and collection for the delivery executive location updated
  /// 1) Create a collection called 'executive_locations'
  /// 2) create a document with the executive id
  /// 3) Set the location data in the document
  Future<void> updateExecutiveLocation(double latitude, double longitude) async {
    try {
      final executiveId = prefs.getString("executiveId") ?? '4';
      await _firestore.collection('executive_locations').doc(executiveId).set({
        'latitude': latitude,
        'longitude': longitude,
      });
    } catch (e) {
      print('Error updating executive location: $e');
    }
  }

  

  // Send the location to the firebase on every second
  Future<void> sendLocationToFirebase() async {
    await _locationService.init();
    _locationService.getLocationStream().listen((position) {
      updateExecutiveLocation(position.latitude, position.longitude);
      print("Sent Location to firebase");
    });
  }

   void startBackgroundLocationUpdates() {
    sendLocationToFirebase();
    print("Background Location Updated");
      
  }

  
  Future<void> getFCMToken() async {
    // Initialize the firebase messaging automatically once the app is opened
    FirebaseMessaging.instance.setAutoInitEnabled(true);
    // This will access the token even if changes and store it in the preferences
    // for android devices
    FirebaseMessaging.instance.onTokenRefresh.listen((token) async{
        await prefs.setString("fcm_token", token);
        String key = prefs.getString("fcm_token") ?? "";
        debugPrint("FCM Token: $key");
    },).onError((error, stackTrace){
      debugPrint("error: $error");
    });
    
    // Get the token for the first time
    await FirebaseMessaging.instance.getToken().then((token) async{
      if (token != null) {
        await prefs.setString("fcm_token", token);
        String key = prefs.getString("fcm_token") ?? "";
        debugPrint("FCM Token: $key");
      }
    },);
    // For iOS devices we need to get the APN token and set things up in the iOS developer console
    // https://firebase.google.com/docs/cloud-messaging/flutter/client?hl=en&authuser=0#ios
  }

}