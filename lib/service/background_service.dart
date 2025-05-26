import 'dart:async';
import 'package:app_5/service/firebase_service.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class BackgroundService {
  static final BackgroundService _backgroundService = BackgroundService._internal();
  BackgroundService._internal();
  factory BackgroundService() {
    return _backgroundService;
  }

  static final FirebaseService _firebaseService = FirebaseService();


  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    /// Ensuring the service runs even when the app is killed
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: true, // ✅ Required for Android 8+
        autoStart: true,
        notificationChannelId: 'my_foreground', // 🔥 Ensure it matches
        initialNotificationTitle: 'Delivery Executive',
        initialNotificationContent: 'Tracking location...',
      ),
      iosConfiguration: IosConfiguration(
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    if (service is AndroidServiceInstance) {
      // This will send the data even app ios closed
      service.setAsForegroundService();

      service.setForegroundNotificationInfo(
        title: "Delivery Executive",
        content: "Tracking location in the background...",
      );
    }
    await _firebaseService.sendLocationToFirebase();
  }

  @pragma('vm:entry-point')
  static bool onIosBackground(ServiceInstance service) {
    return true;
  }

  @pragma('vm:entry-point')
  static Future<void> initializeNotificationChannel() async{
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'my_foreground', // MUST match `notificationChannelId`
      'Background Service',
      description: 'Tracking location in background',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

  }
  

}