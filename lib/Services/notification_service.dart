import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices {
  //initialising firebase message plugin
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  //initialising local notifications plugin
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Callback function to update FCM token
  Function(String)? onTokenRefresh;

  //function to initialise flutter local notification plugin to show notifications for android when app is active
  void initLocalNotifications(BuildContext context) async {
    try {
      const androidInitializationSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher'); // ✅ FIXED

      const iosInitializationSettings = DarwinInitializationSettings();

      const initializationSetting = InitializationSettings(
        android: androidInitializationSettings,
        iOS: iosInitializationSettings,
      );

      await _flutterLocalNotificationsPlugin.initialize(initializationSetting);
    } catch (e) {
      // ✅ Prevent app from crashing (so your navbar/UI can load)
      debugPrint("❌ initLocalNotifications error: $e");
    }
  }

  void firebaseInit(BuildContext context) {
    initLocalNotifications(context);

    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;

      if (kDebugMode) {
        print("notifications title:${notification?.title}");
        print("notifications body:${notification?.body}");
        print('data:${message.data.toString()}');
      }

      if (Platform.isIOS) {
        forgroundMessage();
      }

      if (Platform.isAndroid) {
        showNotification(message);
      }
    });
  }

  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('user granted permission');
      }
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      if (kDebugMode) {
        print('user granted provisional permission');
      }
    } else {
      if (kDebugMode) {
        print('user denied permission');
      }
    }
  }

  Future<void> showSimpleNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'chat_channel',
      'Chat Notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher', // ✅ OK
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }

  // function to show visible notification when app is active
  Future<void> showNotification(RemoteMessage message) async {
    // NOTE: Keeping your logic same, only making channel id/name safe & stable
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      message.notification?.android?.channelId ?? 'default_channel',
      message.notification?.android?.channelId ?? 'Default Channel',
      importance: Importance.max,
      showBadge: true,
      playSound: true,
      // ⚠️ If this causes issues, remove sound OR move file to android/res/raw
      sound: const UriAndroidNotificationSound('assets/tunes/pop.mp3'),
    );

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channel.id.toString(),
      channel.name.toString(),
      channelDescription: "This is my notification channel description",
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      ticker: 'ticker',
      sound: channel.sound,
      icon: '@mipmap/ic_launcher', 
    );

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      message.hashCode, // Unique ID for the notification
      message.notification?.title.toString(),
      message.notification?.body.toString(),
      notificationDetails,
      payload: jsonEncode(message.data),
    );
  }

  //function to get device token on which we will send the notifications
  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    return token ?? "";
  }

  void isTokenRefresh() async {
    messaging.onTokenRefresh.listen((event) {
      if (kDebugMode) {
        print('Token refreshed: $event');
      }
      // Call the callback to update FCM token in the backend
      if (onTokenRefresh != null) {
        onTokenRefresh!(event);
      }
    });
  }

  Future forgroundMessage() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}