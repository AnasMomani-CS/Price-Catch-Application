// lib/core/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings darwinSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // معالجة النقر على الإشعار
      },
    );
  }

  static Future<void> showPriceAlert(String productName, double price) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'price_catch_id',
      'Price Catch Alerts',
      channelDescription: 'Notifications for target price matches',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      0, 
      'Target Reached! 🔥',
      'The price of $productName dropped to ${price.toStringAsFixed(2)} JOD!',
      details,
      payload: 'price_data',
    );
  }
}
