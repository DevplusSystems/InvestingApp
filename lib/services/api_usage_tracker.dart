import 'dart:async';
import 'dart:collection';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/api_config.dart';

class ApiUsage {
  final String apiName;
  final int callsMade;
  final int maxCalls;
  final DateTime lastReset;
  final DateTime lastCall;
  final Duration resetPeriod;

  const ApiUsage({
    required this.apiName,
    required this.callsMade,
    required this.maxCalls,
    required this.lastReset,
    required this.lastCall,
    required this.resetPeriod,
  });

  double get usagePercentage => maxCalls > 0 ? (callsMade / maxCalls) * 100 : 0;
  
  bool get isNearLimit => usagePercentage >= 80;
  
  bool get isAtLimit => callsMade >= maxCalls;
  
  bool get shouldReset => DateTime.now().difference(lastReset) >= resetPeriod;
  
  Duration get timeUntilReset {
    final nextReset = lastReset.add(resetPeriod);
    return nextReset.difference(DateTime.now());
  }

  ApiUsage copyWith({
    int? callsMade,
    DateTime? lastCall,
    DateTime? lastReset,
  }) {
    return ApiUsage(
      apiName: apiName,
      callsMade: callsMade ?? this.callsMade,
      maxCalls: maxCalls,
      lastReset: lastReset ?? this.lastReset,
      lastCall: lastCall ?? this.lastCall,
      resetPeriod: resetPeriod,
    );
  }
}

class ApiUsageTracker {
  static final ApiUsageTracker _instance = ApiUsageTracker._internal();
  factory ApiUsageTracker() => _instance;
  ApiUsageTracker._internal();

  final Map<String, ApiUsage> _usage = {};
  final Map<String, Queue<DateTime>> _callTimes = {};
  final Map<String, Timer> _resetTimers = {};

  void trackApiCall(String apiName) {
    final now = DateTime.now();
    
    // Initialize if not exists
    if (!_usage.containsKey(apiName)) {
      _initializeApi(apiName);
    }

    final usage = _usage[apiName]!;
    
    // Reset if period has passed
    if (usage.shouldReset) {
      _resetApiUsage(apiName);
    }

    // Check rate limit before proceeding
    if (_isRateLimited(apiName)) {
      throw ApiRateLimitException(
        'Rate limit exceeded for $apiName. Try again in ${usage.timeUntilReset.inMinutes} minutes.',
        timeUntilReset: usage.timeUntilReset,
      );
    }

    // Track the call
    _usage[apiName] = usage.copyWith(
      callsMade: usage.callsMade + 1,
      lastCall: now,
    );

    // Track call times for per-minute tracking
    _callTimes[apiName] ??= Queue<DateTime>();
    _callTimes[apiName]!.add(now);
    
    // Clean old calls (older than 1 minute)
    _cleanOldCalls(apiName);
  }

  void _initializeApi(String apiName) {
    final maxCalls = _getMaxCallsForApi(apiName);
    final resetPeriod = _getResetPeriodForApi(apiName);
    
    _usage[apiName] = ApiUsage(
      apiName: apiName,
      callsMade: 0,
      maxCalls: maxCalls,
      lastReset: DateTime.now(),
      lastCall: DateTime.now(),
      resetPeriod: resetPeriod,
    );

    _callTimes[apiName] = Queue<DateTime>();
  }

  void _resetApiUsage(String apiName) {
    final usage = _usage[apiName]!;
    final now = DateTime.now();
    
    _usage[apiName] = usage.copyWith(
      callsMade: 0,
      lastReset: now,
    );
    
    _callTimes[apiName]?.clear();
  }

  bool _isRateLimited(String apiName) {
    final usage = _usage[apiName]!;
    final callTimes = _callTimes[apiName]!;
    
    // Check daily limit
    if (usage.isAtLimit) {
      return true;
    }

    // Check per-minute limit (for real-time APIs)
    final oneMinuteAgo = DateTime.now().subtract(const Duration(minutes: 1));
    final recentCalls = callTimes.where((time) => time.isAfter(oneMinuteAgo)).length;
    
    switch (apiName) {
      case 'twelveData':
        return recentCalls >= 8; // 8 calls per minute
      case 'fmp':
        return recentCalls >= 4; // Conservative limit
      case 'goldApi':
        return recentCalls >= 2; // Conservative limit
      default:
        return false;
    }
  }

  void _cleanOldCalls(String apiName) {
    final callTimes = _callTimes[apiName];
    if (callTimes == null) return;
    
    final oneMinuteAgo = DateTime.now().subtract(const Duration(minutes: 1));
    while (callTimes.isNotEmpty && callTimes.first.isBefore(oneMinuteAgo)) {
      callTimes.removeFirst();
    }
  }

  int _getMaxCallsForApi(String apiName) {
    switch (apiName) {
      case 'twelveData':
        return ApiConfig.twelveDataRateLimit;
      case 'fmp':
        return ApiConfig.fmpRateLimit;
      case 'goldApi':
        return ApiConfig.goldApiRateLimit;
      case 'finnhub':
        return ApiConfig.finnhubRateLimit;
      default:
        return 100;
    }
  }

  Duration _getResetPeriodForApi(String apiName) {
    switch (apiName) {
      case 'twelveData':
      case 'fmp':
      case 'goldApi':
      case 'finnhub':
        return const Duration(days: 1); // Daily reset
      default:
        return const Duration(hours: 1);
    }
  }

  ApiUsage? getUsage(String apiName) {
    return _usage[apiName];
  }

  Map<String, ApiUsage> getAllUsage() {
    return Map.unmodifiable(Map.from(_usage));
  }

  List<ApiUsage> getCriticalUsage() {
    return _usage.values.where((usage) => usage.isNearLimit).toList();
  }

  Map<String, dynamic> getUsageStats() {
    return {
      'totalApis': _usage.length,
      'criticalApis': getCriticalUsage().length,
      'apis': _usage.map((key, value) => MapEntry(
        key,
        {
          'callsMade': value.callsMade,
          'maxCalls': value.maxCalls,
          'usagePercentage': value.usagePercentage.toStringAsFixed(1),
          'lastCall': value.lastCall.toIso8601String(),
          'timeUntilReset': value.timeUntilReset.inMinutes,
        },
      )),
    };
  }
}

class ApiRateLimitException implements Exception {
  final String message;
  final Duration timeUntilReset;

  const ApiRateLimitException(this.message, {required this.timeUntilReset});

  @override
  String toString() => message;
}

// Riverpod providers for API usage tracking
final apiUsageTrackerProvider = Provider<ApiUsageTracker>((ref) {
  return ApiUsageTracker();
});

final apiUsageStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final tracker = ref.watch(apiUsageTrackerProvider);
  return tracker.getUsageStats();
});

final criticalApiUsageProvider = Provider<List<ApiUsage>>((ref) {
  final tracker = ref.watch(apiUsageTrackerProvider);
  return tracker.getCriticalUsage();
});
