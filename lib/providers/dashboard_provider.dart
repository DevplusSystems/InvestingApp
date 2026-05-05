import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/api_config.dart';
import '../models/dashboard_data.dart';
import '../repositories/dashboard_repository.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../services/dashboard_api_service.dart';
import '../services/global_market_service.dart';

// Finnhub API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(
    baseUrl: ApiConfig.finnhubBaseUrl,
    apiKey: ApiConfig.finnhubApiKey,
  );
});

// Twelve Data API Service Provider
final twelveDataApiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(
    baseUrl: ApiConfig.twelveDataBaseUrl,
    apiKey: ApiConfig.twelveDataApiKey,
  );
});

// Dashboard API Service Provider
final dashboardApiServiceProvider = Provider<DashboardApiService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return DashboardApiService(apiService: apiService);
});

// Global Market Service Provider
final globalMarketServiceProvider = Provider<GlobalMarketService>((ref) {
  final apiService = ref.watch(twelveDataApiServiceProvider);
  return GlobalMarketService(apiService: apiService);
});

// Cache Service Provider
final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService();
});

// Dashboard Repository Provider
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final apiService = ref.watch(dashboardApiServiceProvider);
  final globalMarketService = ref.watch(globalMarketServiceProvider);
  final cacheService = ref.watch(cacheServiceProvider);
  return DashboardRepository(
    apiService: apiService,
    globalMarketService: globalMarketService,
    cacheService: cacheService,
  );
});

// Dashboard Data Provider
final dashboardDataProvider =
    FutureProvider<DashboardData>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return await repository.getDashboardData();
});
