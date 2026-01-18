import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core/config/firebase_config.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Setup FCM message handlers
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Get FCM token and send to backend
    final token = await FirebaseConfig.getFCMToken();
    if (token != null) {
      _sendTokenToBackend(token);
    }

    // Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      _sendTokenToBackend(newToken);
    });

    _initialized = true;
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      // Save FCM token directly to Firestore
      final currentUser = FirebaseConfig.auth?.currentUser;
      if (currentUser != null && FirebaseConfig.firestore != null) {
        await FirebaseConfig.firestore!
            .collection('users')
            .doc(currentUser.uid)
            .update({
              'fcmToken': token,
              'fcmTokenUpdatedAt': DateTime.now().toIso8601String(),
            });
        print('FCM Token saved to Firestore: $token');
      }
    } catch (e) {
      print('Failed to save FCM token to Firestore: $e');
      // Don't throw - this is not critical for app functionality
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    // Show local notification when app is in foreground
    await _showLocalNotification(
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? '',
      message.data,
    );
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    // Handle background message
    print('Background message: ${message.messageId}');
  }

  Future<void> _showLocalNotification(String title, String body, Map<String, dynamic> data) async {
    const androidDetails = AndroidNotificationDetails(
      'amrutha_academy_channel',
      'Amrutha Academy',
      channelDescription: 'Notifications for Amrutha Academy',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
      payload: data.toString(),
    );
  }

  Future<void> scheduleClassReminder({
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    // Schedule local notification for class reminder (15 minutes before)
    final reminderTime = scheduledTime.subtract(const Duration(minutes: 15));
    if (reminderTime.isBefore(DateTime.now())) return;

    const androidDetails = AndroidNotificationDetails(
      'amrutha_academy_reminders',
      'Class Reminders',
      channelDescription: 'Reminders for upcoming classes',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Note: schedule() method may not be available in all versions
    // Using show() as fallback for now
    await _localNotifications.show(
      scheduledTime.millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
    );
  }
}
