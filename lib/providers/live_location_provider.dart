import 'dart:convert';

import 'package:app_5/helper/sharedPreference_helper.dart';
import 'package:app_5/service/location_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';

class LiverLocationProvider extends ChangeNotifier{
  final LocationService _locationService = LocationService();
  Position? currentPosition;
  IOWebSocketChannel? _socket;
  SharedPreferences prefs = SharedpreferenceHelper.getInstance;

  /// Connnect to the WebSocket server
  /// Step 1: Start the WebSocket connection
  /// Step 2: Check the Location permission
  /// Step 3: Get the current location stream
  /// Step 4: Send the location to the server
  Future<void> connect() async {
     try {
        _socket = IOWebSocketChannel.connect("ws://192.168.1.19:6001/app/local_key?protocol=7&client=js&version=7.0.0");

      print('Connected to WebSocket');
      await _locationService.init();
      _locationService.getLocationStream().listen((Position position) {
        _sendLocation(position);
        notifyListeners();
      });
      
    } catch (e) {
      print('WebSocket Connection Error: $e');
    }
  }


  void _sendLocation(Position position) async {
    if (_socket == null || _socket!.closeCode != null) {
      print("WebSocket not connected, reconnecting...");
      await connect();
      await Future.delayed(const Duration(seconds: 2)); // Give it time to reconnect
    }
    if (_socket != null) {
      Map<String, dynamic> data = {
        'executive_id': prefs.getString("executiveId") ?? '4',
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
      _socket!.sink.add(jsonEncode(data));
      print('Sent location: ${position.latitude}, ${position.longitude}');
    } else {
      await connect();
    }
  }
}