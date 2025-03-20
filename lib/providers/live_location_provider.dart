import 'dart:convert';
import 'dart:io';

import 'package:app_5/helper/sharedPreference_helper.dart';
import 'package:app_5/service/location_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LiverLocationProvider extends ChangeNotifier{
  final LocationService _locationService = LocationService();
  Position? currentPosition;
  WebSocket? _socket;
  SharedPreferences prefs = SharedpreferenceHelper.getInstance;

  /// Connnect to the WebSocket server
  /// Step 1: Start the WebSocket connection
  /// Step 2: Check the Location permission
  /// Step 3: Get the current location stream
  /// Step 4: Send the location to the server
  Future<void> connect() async {
     try {
      await WebSocket.connect("ws://192.168.1.19/pasumanibhoomi-latest/public/api/update-location");
      print('Connected to WebSocket');

      _socket!.listen((data) {
        print('Received message: $data');
      }, onError: (error) {
        print('WebSocket Error: $error');
      }, onDone: () {
        print('WebSocket Disconnected');
      });
    } catch (e) {
      print('WebSocket Connection Error: $e');
    }
    await _locationService.init();
    _locationService.getLocationStream().listen((Position position) {
      currentPosition = position;
      _sendLocation(position);
      notifyListeners();
    });
  }

  void _sendLocation(Position position) async {
    if (_socket != null && _socket!.readyState == WebSocket.open) {
      Map<String, dynamic> data = {
        'executive_id': prefs.getString("executiveId") ?? '4',
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
      _socket!.add(jsonEncode(data));
      print('Sent location: ${position.latitude}, ${position.longitude}');
    }
  }
}