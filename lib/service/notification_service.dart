import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '';

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();

  static NotificationService get instance => _notificationService;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  int id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  Future<void> initialize() async {
    const AndroidInitializationSettings android = AndroidInitializationSettings("@mimap/ic_launcher");
    const DarwinInitializationSettings ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    InitializationSettings initialize = const InitializationSettings(android: android, iOS: ios);

    _notificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()!
      .requestNotificationsPermission();
    
    await _notificationsPlugin.initialize(
      initialize,
    );
  }

  Future<void> showNotifiation(String? message, String? title, String? body, String? payload) async {
    final AndroidNotificationDetails android = AndroidNotificationDetails(
      "delivery_executive", 
      "deliver_channel",
      importance: Importance.high,
      channelDescription: 'All notifications related to delivery executive.',
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(
        message ?? "",
        contentTitle: title,
        summaryText: body
      ),
      groupKey: 'orders',
    );
    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    final NotificationDetails platformDetails = NotificationDetails(
      android: android,
      iOS: iosDetails,
    );
    _notificationsPlugin.show(id, title, body, platformDetails, payload: payload);
  }

}