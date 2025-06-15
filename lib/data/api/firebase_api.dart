import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:absensi_app/data/api/api_service.dart';
import 'package:absensi_app/data/api/endpoints.dart';
import 'package:absensi_app/providers/notification_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class FirebaseApi {
  // create an instance of Firebase Messaging
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final ApiService _apiService = ApiService();

  //function to initialize Notifications
  Future<void> initializeNotifications() async {
    // Request permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM token
    String? token = await _messaging.getToken();
    print("token fcm:" + (token ?? "null"));

    if (token != null) {
      await saveTokenToBackend(token);
    }

    // Handle token refresh
    _messaging.onTokenRefresh.listen((token) async {
      await saveTokenToBackend(token);
    });

    // Initialize push notifications
    await initPushNotifications();
  }

  Future<void> saveTokenToBackend(String? token) async {
    if (token == null) return;

    try {
      final response = await _apiService.post(
        ApiEndpoints.saveFcmToken,
        body: {
          'fcm_token': token,
        },
      );

      if (!response['success']) {
        print('Failed to save FCM token: ${response['message']}');
      }
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  //function to handle received messages
  void handleMessage(BuildContext context, RemoteMessage? message) {
    if (message == null) return;

    // Refresh notifications in the provider
    if (context.mounted) {
      context.read<NotificationProvider>().refreshNotifications();
    }
  }

  //function to initialize foreground and background settings
  Future<void> initPushNotifications() async {
    // Handle initial message when app is opened from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        // You can handle initial message here if needed
        print('Initial message: ${message.notification?.title}');
      }
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    // Handle when app is opened from background state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!');
      print('Message data: ${message.data}');
    });
  }

  // Background message handler
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Handling a background message: ${message.notification?.title}');
    // You can add your custom logic here
  }
}
