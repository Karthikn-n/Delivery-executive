import 'package:app_5/helper/sharedPreference_helper.dart';
import 'package:app_5/providers/api_provider.dart';
import 'package:app_5/providers/connectivity_helper.dart';
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
        ChangeNotifierProvider(create: (_) => ApiProvider())
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
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent.withOpacity(0.0)
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        primaryColor: const Color(0xFF60B47B),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: const LoginPage()
    );
  }
}
