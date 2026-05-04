import 'dart:convert';
import 'package:hive/hive.dart';

class CacheService {
  static const String _dashboardBox = 'dashboard_cache';
  static const String _quotesBox = 'quotes_cache';
  static const Duration _defaultCacheDuration = Duration(minutes: 15);

  late Box _dashboardBox;
  late Box _quotesBox;

  Future<void> init() async {
    _dashboardBox = await Hive.openBox(_dashboardBox);
    _quotesBox = await Hive.openBox(_quotesBox);
  }

  // Cache dashboard data
  Future<void> cacheDashboardData(Map<String, dynamic> data) async {
    await _dashboardBox.put('data', data);
    await _dashboardBox.put('timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  // Get cached dashboard data
  Map<String, dynamic>? getCachedDashboardData({Duration? maxAge}) {
    final data = _dashboardBox.get('data');
    final timestamp = _dashboardBox.get('timestamp');

    if (data == null || timestamp == null) return null;

    final cacheAge = maxAge ?? _defaultCacheDuration;
    final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final isExpired = DateTime.now().difference(cachedTime) > cacheAge;

    if (isExpired) {
      clearDashboardCache();
      return null;
    }

    return data as Map<String, dynamic>;
  }

  // Cache stock quote
  Future<void> cacheQuote(String symbol, Map<String, dynamic> data) async {
    await _quotesBox.put(symbol, data);
    await _quotesBox.put('${symbol}_timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  // Get cached stock quote
  Map<String, dynamic>? getCachedQuote(String symbol, {Duration? maxAge}) {
    final data = _quotesBox.get(symbol);
    final timestamp = _quotesBox.get('${symbol}_timestamp');

    if (data == null || timestamp == null) return null;

    final cacheAge = maxAge ?? _defaultCacheDuration;
    final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final isExpired = DateTime.now().difference(cachedTime) > cacheAge;

    if (isExpired) {
      clearQuoteCache(symbol);
      return null;
    }

    return data as Map<String, dynamic>;
  }

  // Clear caches
  Future<void> clearDashboardCache() async {
    await _dashboardBox.clear();
  }

  Future<void> clearQuoteCache(String symbol) async {
    await _quotesBox.delete(symbol);
    await _quotesBox.delete('${symbol}_timestamp');
  }

  Future<void> clearAllCache() async {
    await _dashboardBox.clear();
    await _quotesBox.clear();
  }

  // Check if cache is available and valid
  bool hasValidDashboardCache({Duration? maxAge}) {
    return getCachedDashboardData(maxAge: maxAge) != null;
  }

  bool hasValidQuoteCache(String symbol, {Duration? maxAge}) {
    return getCachedQuote(symbol, maxAge: maxAge) != null;
  }

  Future<void> close() async {
    await _dashboardBox.close();
    await _quotesBox.close();
  }
}
