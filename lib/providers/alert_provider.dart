import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/alert.dart';
import '../services/rate_limited_api_service.dart';
import '../services/notification_service.dart';

class AlertNotifier extends StateNotifier<List<AlertModel>> {
  AlertNotifier(this._apiService) : super([]) {
    _loadAlerts();
  }

  final RateLimitedApiService _apiService;
  late Box<AlertModel> _alertsBox;

  Future<void> _loadAlerts() async {
    try {
      _alertsBox = await Hive.openBox<AlertModel>('alerts');
      state = _alertsBox.values.toList();
    } catch (e) {
      // Handle error opening box
      state = [];
    }
  }

  Future<void> addAlert(AlertModel alert) async {
    try {
      await _alertsBox.put(alert.id, alert);
      state = [...state, alert];
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateAlert(AlertModel alert) async {
    try {
      await _alertsBox.put(alert.id, alert);
      state = state.map((a) => a.id == alert.id ? alert : a).toList();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteAlert(String alertId) async {
    try {
      await _alertsBox.delete(alertId);
      state = state.where((alert) => alert.id != alertId).toList();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> toggleAlert(String alertId) async {
    try {
      final alert = _alertsBox.get(alertId);
      if (alert != null) {
        final updatedAlert = alert.copyWith(isActive: !alert.isActive);
        await _alertsBox.put(alertId, updatedAlert);
        state = state.map((a) => a.id == alertId ? updatedAlert : a).toList();
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> markAsTriggered(String alertId) async {
    try {
      final alert = _alertsBox.get(alertId);
      if (alert != null) {
        final updatedAlert = alert.copyWith(
          isTriggered: true,
          triggeredAt: DateTime.now(),
        );
        await _alertsBox.put(alertId, updatedAlert);
        state = state.map((a) => a.id == alertId ? updatedAlert : a).toList();
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateLastNotified(String alertId) async {
    try {
      final alert = _alertsBox.get(alertId);
      if (alert != null) {
        final updatedAlert = alert.copyWith(lastNotifiedAt: DateTime.now());
        await _alertsBox.put(alertId, updatedAlert);
        state = state.map((a) => a.id == alertId ? updatedAlert : a).toList();
      }
    } catch (e) {
      // Handle error
    }
  }

  List<AlertModel> getActiveAlerts() {
    return state.where((alert) => alert.isActive && !alert.isTriggered).toList();
  }

  List<AlertModel> getAlertsForSymbol(String symbol) {
    return state.where((alert) => alert.symbol == symbol).toList();
  }

  Future<void> clearAllAlerts() async {
    try {
      await _alertsBox.clear();
      state = [];
    } catch (e) {
      // Handle error
    }
  }

  void dispose() {
    _alertsBox.close();
    super.dispose();
  }
}

// Alert checker service
class AlertCheckerService {
  static final AlertCheckerService _instance = AlertCheckerService._internal();
  factory AlertCheckerService() => _instance;
  AlertCheckerService._internal();

  final RateLimitedApiService _apiService = RateLimitedApiService();
  late Box<AlertModel> _alertsBox;
  Timer? _checkingTimer;

  Future<void> initialize() async {
    try {
      _alertsBox = await Hive.openBox<AlertModel>('alerts');
    } catch (e) {
      // Handle error
    }
  }

  void startChecking() {
    // Check every 30 seconds
    _checkingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkAlerts();
    });
  }

  void stopChecking() {
    _checkingTimer?.cancel();
    _checkingTimer = null;
  }

  Future<void> _checkAlerts() async {
    if (_alertsBox == null || _alertsBox.isEmpty) return;

    final alerts = _alertsBox.values.where((alert) => 
        alert.isActive && !alert.isTriggered).toList();

    for (final alert in alerts) {
      await _checkSingleAlert(alert);
    }
  }

  Future<void> _checkSingleAlert(AlertModel alert) async {
    try {
      // Get current market data based on alert type
      switch (alert.alertType) {
        case AlertType.price:
          await _checkPriceAlert(alert);
          break;
        case AlertType.percentage:
          await _checkPercentageAlert(alert);
          break;
        case AlertType.volume:
          await _checkVolumeAlert(alert);
          break;
      }
    } catch (e) {
      // Handle error checking alert
    }
  }

  Future<void> _checkPriceAlert(AlertModel alert) async {
    final response = await _apiService.getStockPrice(alert.symbol);
    if (!response.success || response.data == null) return;

    final currentPrice = response.data!.price;
    if (alert.shouldTrigger(currentPrice, 0, 0)) {
      await _triggerAlert(alert, currentPrice, 0, 0);
    }
  }

  Future<void> _checkPercentageAlert(AlertModel alert) async {
    // For percentage alerts, we need historical data
    // This is a simplified version - in production, you'd calculate actual percentage change
    final response = await _apiService.getStockPrice(alert.symbol);
    if (!response.success || response.data == null) return;

    final currentPrice = response.data!.price;
    // Simplified percentage calculation (would need historical data for real implementation)
    final mockPercentage = (currentPrice - alert.targetPrice) / alert.targetPrice * 100;
    
    if (alert.shouldTrigger(0, 0, mockPercentage)) {
      await _triggerAlert(alert, currentPrice, 0, mockPercentage);
    }
  }

  Future<void> _checkVolumeAlert(AlertModel alert) async {
    // Volume alerts would need real-time volume data
    // This is a placeholder implementation
    final response = await _apiService.getStockPrice(alert.symbol);
    if (!response.success || response.data == null) return;

    final currentVolume = response.data!.volume;
    if (alert.shouldTrigger(0, currentVolume, 0)) {
      await _triggerAlert(alert, 0, currentVolume, 0);
    }
  }

  Future<void> _triggerAlert(AlertModel alert, double price, double volume, double percentage) async {
    // Mark alert as triggered
    await _alertsBox.put(alert.id, alert.copyWith(
      isTriggered: true,
      triggeredAt: DateTime.now(),
    ));

    // Send notification (would integrate with local notifications)
    await _sendNotification(alert, price, volume, percentage);
  }

  Future<void> _sendNotification(AlertModel alert, double price, double volume, double percentage) async {
    final notificationService = NotificationService();
    
    // Check if notification can be sent (cooldown, frequency)
    if (!alert.canNotify()) return;
    
    // Send local notification
    await notificationService.sendAlertNotification(
      alert,
      currentPrice: price,
      currentVolume: volume,
      currentPercentage: percentage,
    );
    
    // Update last notified timestamp
    await _alertsBox.put(alert.id, alert.copyWith(
      lastNotifiedAt: DateTime.now(),
    ));
    
    print('ALERT TRIGGERED: ${alert.displayText}');
  }

  void dispose() {
    stopChecking();
    _alertsBox.close();
  }
}

// Providers
final alertProvider = StateNotifierProvider<AlertNotifier, List<AlertModel>>((ref) {
  return AlertNotifier(RateLimitedApiService());
});

final activeAlertsProvider = Provider<List<AlertModel>>((ref) {
  final alerts = ref.watch(alertProvider);
  return alerts.where((alert) => alert.isActive && !alert.isTriggered).toList();
});

final alertCheckerServiceProvider = Provider<AlertCheckerService>((ref) {
  return AlertCheckerService();
});
