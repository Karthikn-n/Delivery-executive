// import 'dart:async';

// import 'package:app_5/helper/sharedPreference_helper.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class LoginHelper extends ChangeNotifier{
//   SharedPreferences prefs = SharedpreferenceHelper.getInstance;
//   LoginHelper();


  
//   Future<void> setLoginTime(DateTime? loggedInTime) async {
//     await prefs.setString('loggedInAlready', DateTime(loggedInTime!.year, loggedInTime.month, loggedInTime.day).toString());
//   }
 
//   bool hasLoggedInToday(){
//     String? loggedInAlready = prefs.getString('loggedInAlready');
//     if (loggedInAlready != null) {
//       DateTime lastLogin = DateTime.parse(loggedInAlready);
//       DateTime today = DateTime.now();
//       return lastLogin.year == today.year && lastLogin.month == today.month && lastLogin.day == today.day;
//     }
//     return false;
//   }
  

//   Future<void> logoutToday() async => await prefs.remove('loggedInAlready');
  
// }