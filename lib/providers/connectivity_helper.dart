import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService with ChangeNotifier{
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  List<ConnectivityResult> _isConnected = [];
  ConnectivityService(){
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((event) {
      _isConnected = event;
      notifyListeners();
    },);
  }
  
  // check is internet connected or not
  bool get isConnected 
    => _isConnected.contains(ConnectivityResult.mobile) 
      || _isConnected.contains( ConnectivityResult.wifi)  
      || _isConnected.contains( ConnectivityResult.ethernet);



  @override
  void dispose(){
    _connectivitySubscription.cancel();
    super.dispose();
  }
} 