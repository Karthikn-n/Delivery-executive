// ignore_for_file: file_names

import 'package:shared_preferences/shared_preferences.dart';

class SharedpreferenceHelper{
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get getInstance => _prefs;
}