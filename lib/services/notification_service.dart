import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/alert.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Android initialization settings
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS initialization settings
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined initialization settings
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    await _createNotificationChannels();

    _isInitialized = true;
  }

  Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel priceChannel = AndroidNotificationChannel(
      'price_alerts',
      'Price Alerts',
      description: 'Notifications for price-based alerts',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    const AndroidNotificationChannel percentageChannel = AndroidNotificationChannel(
      'percentage_alerts',
      'Percentage Change Alerts',
      description: 'Notifications for percentage change alerts',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    const AndroidNotificationChannel volumeChannel = AndroidNotificationChannel(
      'volume_alerts',
      'Volume Alerts',
      description: 'Notifications for volume-based alerts',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(priceChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(percentageChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(volumeChannel);
  }

  Future<void> sendAlertNotification(AlertModel alert, {
    double? currentPrice,
    double? currentVolume,
    double? currentPercentage,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    final channel = _getNotificationChannel(alert.alertType);

    await _notifications.show(
      notificationId,
      _getNotificationTitle(alert),
      _getNotificationBody(alert, currentPrice, currentVolume, currentPercentage),
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.high,
          priority: Priority.high,
          color: _getNotificationColor(alert.alertType),
          enableVibration: true,
          playSound: true,
          icon: '@mipmap/ic_launcher',
          largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          styleInformation: BigTextStyleInformation(
            _getNotificationBody(alert, currentPrice, currentVolume, currentPercentage),
            contentTitle: _getNotificationTitle(alert),
            htmlFormatBigText: true,
            htmlFormatContentTitle: true,
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'default',
        ),
      ),
      payload: alert.id,
    );
  }

  String _getNotificationTitle(AlertModel alert) {
    switch (alert.alertType) {
      case AlertType.price:
        return '📈 Price Alert Triggered';
      case AlertType.percentage:
        return '📊 Percentage Alert Triggered';
      case AlertType.volume:
        return '📦 Volume Alert Triggered';
    }
  }

  String _getNotificationBody(
    AlertModel alert,
    double? currentPrice,
    double? currentVolume,
    double? currentPercentage,
  ) {
    switch (alert.alertType) {
      case AlertType.price:
        return '${alert.symbol} is now \$${currentPrice?.toStringAsFixed(2) ?? 'N/A'} (${alert.condition.displayName} target \$${alert.targetPrice.toStringAsFixed(2)})';
      case AlertType.percentage:
        return '${alert.symbol} changed by ${currentPercentage?.toStringAsFixed(1) ?? 'N/A'}% (${alert.condition.displayName} target ${alert.targetPercentage.toStringAsFixed(1)}%)';
      case AlertType.volume:
        return '${alert.symbol} volume is ${currentVolume?.toInt() ?? 'N/A'} (${alert.condition.displayName} target ${alert.targetVolume.toInt()})';
    }
  }

  AndroidNotificationChannel _getNotificationChannel(AlertType alertType) {
    switch (alertType) {
      case AlertType.price:
        return const AndroidNotificationChannel(
          'price_alerts',
          'Price Alerts',
          description: 'Notifications for price-based alerts',
          importance: Importance.high,
          enableVibration: true,
          playSound: true,
        );
      case AlertType.percentage:
        return const AndroidNotificationChannel(
          'percentage_alerts',
          'Percentage Change Alerts',
          description: 'Notifications for percentage change alerts',
          importance: Importance.high,
          enableVibration: true,
          playSound: true,
        );
      case AlertType.volume:
        return const AndroidNotificationChannel(
          'volume_alerts',
          'Volume Alerts',
          description: 'Notifications for volume-based alerts',
          importance: Importance.high,
          enableVibration: true,
          playSound: true,
        );
    }
  }

  Color _getNotificationColor(AlertType alertType) {
    switch (alertType) {
      case AlertType.price:
        return Colors.blue;
      case AlertType.percentage:
        return Colors.green;
      case AlertType.volume:
        return Colors.orange;
    }
  }

  Future<void> _onNotificationTapped(NotificationResponse response) async {
    // Handle notification tap - navigate to relevant screen
    if (response.payload != null) {
      // Navigate to stock detail or alerts screen
      // This would integrate with your navigation system
    }
  }

  Future<bool> requestPermissions() async {
    final result = await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    final iosResult = await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    return result ?? iosResult ?? false;
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  Future<void> scheduleNotification(
    int id,
    String title,
    String body, {
    required DateTime scheduledTime,
    String? payload,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'scheduled_alerts',
          'Scheduled Alerts',
          channelDescription: 'Scheduled alert notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
