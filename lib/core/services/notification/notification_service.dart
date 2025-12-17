import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:paypulse/app/config/app_config.dart';
import 'package:paypulse/core/errors/exceptions.dart';

abstract class NotificationService {
  Future<void> initialize();
  Future<String?> getFCMToken();
  Future<void> requestPermission();
  Future<void> showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? payload,
    String? channelId,
    String? channelName,
  });
  Future<void> cancelAllNotifications();
  Future<void> subscribeToTopic(String topic);
  Future<void> unsubscribeFromTopic(String topic);
  Stream<RemoteMessage> get onMessage;
  Stream<RemoteMessage> get onMessageOpenedApp;
  Stream<RemoteMessage> get onBackgroundMessage;
}

class NotificationServiceImpl implements NotificationService {
  final FirebaseMessaging _firebaseMessaging;
  final FlutterLocalNotificationsPlugin _localNotifications;

  static const AndroidNotificationDetails _androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'paypulse_channel_id',
    'PayPulse Notifications',
    channelDescription: 'PayPulse notification channel',
    importance: Importance.high,
    priority: Priority.high,
    ticker: 'ticker',
    enableVibration: true,
    vibrationPattern: Int64List.fromList([0, 250, 250, 250]),
    playSound: true,
  );

  static const DarwinNotificationDetails _iosPlatformChannelSpecifics =
      DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  NotificationServiceImpl({
    FirebaseMessaging? firebaseMessaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  })  : _firebaseMessaging = firebaseMessaging ?? FirebaseMessaging.instance,
        _localNotifications =
            localNotifications ?? FlutterLocalNotificationsPlugin();

  @override
  Future<void> initialize() async {
    try {
      // Initialize Firebase Messaging
      await _setupFirebaseMessaging();

      // Initialize local notifications
      await _setupLocalNotifications();

      // Configure notification settings
      await _configureNotificationSettings();
    } catch (e) {
      throw NotificationException(
        message: 'Failed to initialize notification service: $e',
        data: {'error': e.toString()},
      );
    }
  }

  Future<void> _setupFirebaseMessaging() async {
    // Request permission
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // Get token
    final token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    // Handle token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      print('FCM Token refreshed: $newToken');
      // Send new token to your server
    });
  }

  Future<void> _setupLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onSelectNotification: _onSelectNotification,
    );
  }

  Future<void> _configureNotificationSettings() async {
    // Set foreground notification presentation options
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Configure notification channels for Android
    if (AppConfig.isProduction) {
      await _createNotificationChannels();
    }
  }

  Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _onSelectNotification(String? payload) async {
    if (payload != null) {
      print('Notification payload: $payload');
      // Handle notification tap
      // You might want to navigate to a specific screen based on payload
    }
  }

  @override
  Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      throw NotificationException(
        message: 'Failed to get FCM token: $e',
        data: {'error': e.toString()},
      );
    }
  }

  @override
  Future<void> requestPermission() async {
    try {
      final settings = await _firebaseMessaging.requestPermission();

      if (settings.authorizationStatus != AuthorizationStatus.authorized &&
          settings.authorizationStatus != AuthorizationStatus.provisional) {
        throw NotificationException(
          message: 'Notification permission not granted',
          data: {'status': settings.authorizationStatus.name},
        );
      }
    } catch (e) {
      throw NotificationException(
        message: 'Failed to request notification permission: $e',
        data: {'error': e.toString()},
      );
    }
  }

  @override
  Future<void> showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? payload,
    String? channelId,
    String? channelName,
  }) async {
    try {
      final notificationDetails = NotificationDetails(
        android: _androidPlatformChannelSpecifics.copyWith(
          channelId: channelId ?? _androidPlatformChannelSpecifics.channelId,
          channelName:
              channelName ?? _androidPlatformChannelSpecifics.channelName,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _localNotifications.show(
        0,
        title,
        body,
        notificationDetails,
        payload: payload != null ? payload.toString() : null,
      );
    } catch (e) {
      throw NotificationException(
        message: 'Failed to show local notification: $e',
        data: {
          'title': title,
          'body': body,
          'error': e.toString(),
        },
      );
    }
  }

  @override
  Future<void> cancelAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
    } catch (e) {
      throw NotificationException(
        message: 'Failed to cancel all notifications: $e',
        data: {'error': e.toString()},
      );
    }
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      throw NotificationException(
        message: 'Failed to subscribe to topic: $e',
        data: {'topic': topic, 'error': e.toString()},
      );
    }
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      throw NotificationException(
        message: 'Failed to unsubscribe from topic: $e',
        data: {'topic': topic, 'error': e.toString()},
      );
    }
  }

  @override
  Stream<RemoteMessage> get onMessage => _firebaseMessaging.onMessage;

  @override
  Stream<RemoteMessage> get onMessageOpenedApp =>
      _firebaseMessaging.onMessageOpenedApp;

  @override
  Stream<RemoteMessage> get onBackgroundMessage =>
      FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessageHandler);

  // Custom notification methods for PayPulse

  Future<void> showTransactionNotification({
    required String title,
    required String body,
    required String transactionId,
    required double amount,
    required String type,
  }) async {
    await showLocalNotification(
      title: title,
      body: body,
      payload: {
        'type': 'transaction',
        'transaction_id': transactionId,
        'amount': amount,
        'transaction_type': type,
      },
      channelId: 'transactions',
      channelName: 'Transaction Notifications',
    );
  }

  Future<void> showPaymentReminderNotification({
    required String billName,
    required double amount,
    required DateTime dueDate,
  }) async {
    final daysRemaining = dueDate.difference(DateTime.now()).inDays;

    await showLocalNotification(
      title: 'Payment Reminder',
      body: '$billName of \$$amount is due in $daysRemaining days',
      payload: {
        'type': 'payment_reminder',
        'bill_name': billName,
        'amount': amount,
        'due_date': dueDate.toIso8601String(),
      },
      channelId: 'reminders',
      channelName: 'Payment Reminders',
    );
  }

  Future<void> showInvestmentNotification({
    required String investmentName,
    required double returnRate,
    required String changeType, // 'up' or 'down'
  }) async {
    final changeSymbol = changeType == 'up' ? '📈' : '📉';

    await showLocalNotification(
      title: 'Investment Update $changeSymbol',
      body:
          '$investmentName is ${changeType == 'up' ? 'up' : 'down'} by ${returnRate.toStringAsFixed(2)}%',
      payload: {
        'type': 'investment_update',
        'investment_name': investmentName,
        'return_rate': returnRate,
        'change_type': changeType,
      },
      channelId: 'investments',
      channelName: 'Investment Updates',
    );
  }

  Future<void> showSecurityNotification({
    required String title,
    required String body,
    required String securityLevel, // 'info', 'warning', 'critical'
  }) async {
    await showLocalNotification(
      title: title,
      body: body,
      payload: {
        'type': 'security',
        'security_level': securityLevel,
        'timestamp': DateTime.now().toIso8601String(),
      },
      channelId: 'security',
      channelName: 'Security Alerts',
    );
  }
}

Future<void> _firebaseBackgroundMessageHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');

  // You can handle background messages here
  // For example, show a local notification
  final notification = message.notification;
  if (notification != null) {
    print('Notification: ${notification.title} - ${notification.body}');
  }
}

class NotificationException extends AppException {
  NotificationException({
    required String message,
    int? statusCode,
    dynamic data,
  }) : super(message: message, statusCode: statusCode, data: data);
}
