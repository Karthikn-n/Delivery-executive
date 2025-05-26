import 'package:app_5/firebase_options.dart';
import 'package:app_5/helper/sharedPreference_helper.dart';
import 'package:app_5/providers/api_provider.dart';
import 'package:app_5/providers/connectivity_helper.dart';
import 'package:app_5/providers/live_location_provider.dart';
import 'package:app_5/screens/main_screen/home_screen.dart';
import 'package:app_5/screens/main_screen/sigin_page.dart';
import 'package:app_5/service/background_service.dart';
import 'package:app_5/service/firebase_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );
  await SharedpreferenceHelper.init();
  await BackgroundService.initializeNotificationChannel();
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

class _MyAppState extends State<MyApp> with WidgetsBindingObserver{
  SharedPreferences prefs = SharedpreferenceHelper.getInstance;
  final service = FlutterBackgroundService();
  bool isloggedIn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    checked();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void checked() async {
    final provider = Provider.of<ApiProvider>(context, listen: false);
    bool loggedIn = await provider.isloggedIn();
    print("Delivery Logged $loggedIn");
    setState(() {
      isloggedIn = loggedIn;
    });
    if(loggedIn){
      FirebaseService locationService = FirebaseService();
      await locationService.sendLocationToFirebase();
      await locationService.getFCMToken();
    }
  }

   @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
   if (state == AppLifecycleState.paused) {
      // App is in background -> Restart background service
      bool isRunning = await service.isRunning();
      if (!isRunning) {
        service.startService();
        print("🟢 Background service started as app is in background");
      }
    }
  }

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
      home: isloggedIn ? const HomeScreen() : const LoginPage()
    );
  }
}
