/*import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../core/helper/logger_helper.dart';
import '../db/shared_pref_manager.dart';

/// Top-level background handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  printMessage('🔔 [BG] Notification received: ${message.messageId}');
}

class NotificationServices {
  NotificationServices._();

  static final instance = NotificationServices._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  // ─── Android notification channel ────────────────────────────────────────────
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'sai_associates_notification',
    'Go Travel Mart Notification',
    description:
        'This channel is used for important Go Travel User notifications.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  // ─── Public: get FCM token ────────────────────────────────────────────────────
  /// Returns the current FCM device token, or null if unavailable.
  Future<String?> getFcmToken() async {
    try {
      final token = await _messaging.getToken();
      printMessage('📱 FCM Token: $token');
      return token;
    } catch (e) {
      printMessage('⚠️ Failed to get FCM token: $e');
      return null;
    }
  }

  // ─── Initialize ──────────────────────────────────────────────────────────────
  Future<void> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        printMessage(
          '⚠️ Firebase not initialized; skipping NotificationServices setup.',
        );
        return;
      }

      // 1️⃣ Request permission (required on Android 13+ and all iOS)
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );
      printMessage(
        '🔔 Notification permission: ${settings.authorizationStatus}',
      );

      // 2️⃣ Initialise flutter_local_notifications (Android only)
      await _localNotifications.initialize(
        settings: InitializationSettings(
          android: AndroidInitializationSettings('@drawable/ic_notification'),
        ),
        onDidReceiveNotificationResponse: _onLocalNotificationTap,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_channel);

      // 4️⃣ Register background handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 5️⃣ Foreground messages → show local notification manually (Android)
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // 6️⃣ Background → app opened via notification tap
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // 7️⃣ Terminated → app launched via notification tap
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          _routeFromMessage(initialMessage);
        });
      }

      // 8️⃣ Log the FCM token for debugging
      await getFcmToken();

      printMessage('✅ FirebaseNotificationService initialised');
    } catch (e) {
      printMessage('⚠️ FirebaseNotificationService initialization error: $e');
    }
  }

  // ─── Foreground ──────────────────────────────────────────────────────────────
  void _handleForegroundMessage(RemoteMessage message) {
    printMessage('🔔 [FG] ${message.notification?.title}');
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      _localNotifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: '@drawable/ic_notification',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  // ─── Background tap ──────────────────────────────────────────────────────────
  void _handleMessageOpenedApp(RemoteMessage message) {
    printMessage('🔔 [BG-tap] ${message.notification?.title}');
    _routeFromMessage(message);
  }

  // ─── Local notification tap ───────────────────────────────────────────────────
  void _onLocalNotificationTap(NotificationResponse response) {
    if (response.payload == null) return;
    try {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      _routeFromData(data);
    } catch (_) {}
  }

  // ─── Routing logic ────────────────────────────────────────────────────────────
  void _routeFromMessage(RemoteMessage message) => _routeFromData(message.data);

  /// Adjust routing to match your backend's `type` payload values.
  /* void _routeFromData(Map<String, dynamic> data) {
    if (data.containsKey("order_id")) {
      Get.toNamed(AppRoutes.orderTracking, arguments: data['order_id']);
    } else {
      Get.toNamed(AppRoutes.notification);
    }
  } */

  void _routeFromData(Map<String, dynamic> data) {
    final type = (data['type'] ?? '').toString().toLowerCase();
    final orderId = data['order_id']?.toString();
    final productId = data['product_id']?.toString();
    printMessage('🔔 Routing from notification type: $type, orderId: $orderId');
    SharedPrefManager().saveBool(blockSplashNavigation, true);
    if (orderId != null && orderId.isNotEmpty) {
    } else if (productId != null && productId.isNotEmpty) {
      SharedPrefManager().saveBool(blockSplashNavigation, true);
    } else {
      // Get.toNamed(AppRoutes.notification);
    }
  }
}
*/
