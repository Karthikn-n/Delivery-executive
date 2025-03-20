import 'package:app_5/helper/sharedPreference_helper.dart';
import 'package:app_5/providers/api_provider.dart';
import 'package:app_5/providers/connectivity_helper.dart';
import 'package:app_5/providers/live_location_provider.dart';
import 'package:app_5/screens/main_screen/sigin_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedpreferenceHelper.init();
  runApp( 
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectivityService(),),
        ChangeNotifierProvider(create: (_) => ApiProvider()),
        ChangeNotifierProvider(create: (_) => LiverLocationProvider()),
      ],
      child: const MyApp()
    )
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SharedPreferences prefs = SharedpreferenceHelper.getInstance;


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white
        ),
        primaryColorLight: Colors.white,
        colorScheme:  const ColorScheme.light(
          primary: Color(0xFF60B47B),
        ),
        primaryColor: const Color(0xFF60B47B),
        datePickerTheme: const DatePickerThemeData(
          backgroundColor: Colors.white,
          headerBackgroundColor: Color(0xFF60B47B),
          headerForegroundColor: Colors.white,
          dividerColor:  Color(0xFF60B47B),
          rangePickerBackgroundColor: Color(0xFF60B47B),
          cancelButtonStyle: ButtonStyle(
            textStyle: WidgetStatePropertyAll(
              TextStyle(color: Color(0xFF60B47B))
            ),
            foregroundColor: WidgetStatePropertyAll(Color(0xFF60B47B))
          ),
          yearStyle: TextStyle(color: Colors.white),
          confirmButtonStyle: ButtonStyle(
            textStyle: WidgetStatePropertyAll(
              TextStyle(color: Color(0xFF60B47B))
            ),
            foregroundColor: WidgetStatePropertyAll(Color(0xFF60B47B))
          ),
        ),
        primaryColorDark: Colors.black,
        scaffoldBackgroundColor: Colors.white,
        
      ),
      home: const LoginPage()
    );
  }
}
