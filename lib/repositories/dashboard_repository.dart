import '../models/dashboard_data.dart';
import '../services/cache_service.dart';
import '../services/dashboard_api_service.dart';

class DashboardRepository {
  final DashboardApiService _apiService;
  final CacheService _cacheService;

  // Default watchlist symbols - can be made configurable
  static const List<String> defaultWatchlist = [
    'AAPL',  // Apple
    'MSFT',  // Microsoft
    'GOOGL', // Google
    'AMZN',  // Amazon
    'TSLA',  // Tesla
  ];

  DashboardRepository({
    required DashboardApiService apiService,
    required CacheService cacheService,
  })  : _apiService = apiService,
        _cacheService = cacheService;

  Future<DashboardData> getDashboardData({bool forceRefresh = false}) async {
    try {
      // Try to get from cache first (unless force refresh)
      if (!forceRefresh && _cacheService.hasValidDashboardCache()) {
        final cachedData = _cacheService.getCachedDashboardData();
        if (cachedData != null) {
          return DashboardData.fromJson(cachedData);
        }
      }

      // Fetch quotes for watchlist
      final quotes = await _apiService.getMultipleQuotes(defaultWatchlist);
      
      // Calculate portfolio totals
      double totalValue = 0;
      double totalChange = 0;
      final holdings = <AssetHolding>[];

      for (final quoteData in quotes) {
        final quote = StockQuote.fromJson(quoteData);
        final holding = AssetHolding.fromQuote(quote, shares: 10.0); // Assume 10 shares per stock
        holdings.add(holding);
        totalValue += holding.value;
        totalChange += holding.value * (holding.changePercent / 100);
      }

      final totalChangePercent = totalValue > 0 ? (totalChange / totalValue) * 100 : 0;

      final dashboardData = DashboardData(
        totalPortfolioValue: totalValue,
        dailyChange: totalChange,
        dailyChangePercent: totalChangePercent,
        topHoldings holdings,
      );

      // Cache the result
      await _cacheService.cacheDashboardData({
        'totalPortfolioValue': dashboardData.totalPortfolioValue,
        'dailyChange': dashboardData.dailyChange,
        'dailyChangePercent': dashboardData.dailyChangePercent,
        'topHoldings': dashboardData.topHoldings.map((h) => {
          'symbol': h.symbol,
          'name': h.name,
          'value': h.value,
          'shares': h.shares,
          'changePercent': h.changePercent,
        }).toList(),
      });

      return dashboardData;
    } catch (e) {
      // If API fails, try to return cached data even if expired
      final cachedData = _cacheService.getCachedDashboardData(maxAge: const Duration(hours: 24));
      if (cachedData != null) {
        return DashboardData.fromJson(cachedData);
      }
      throw Exception('Failed to fetch dashboard data: $e');
    }
  }

  Future<StockQuote> getStockQuote(String symbol, {bool forceRefresh = false}) async {
    try {
      // Try cache first
      if (!forceRefresh && _cacheService.hasValidQuoteCache(symbol)) {
        final cachedQuote = _cacheService.getCachedQuote(symbol);
        if (cachedQuote != null) {
          return StockQuote.fromJson(cachedQuote);
        }
      }

      // Fetch from API
      final quoteData = await _apiService.getStockQuote(symbol);
      final quote = StockQuote.fromJson(quoteData);

      // Cache the result
      await _cacheService.cacheQuote(symbol, quoteData);

      return quote;
    } catch (e) {
      // If API fails, try to return cached data even if expired
      final cachedQuote = _cacheService.getCachedQuote(symbol, maxAge: const Duration(hours: 24));
      if (cachedQuote != null) {
        return StockQuote.fromJson(cachedQuote);
      }
      throw Exception('Failed to fetch stock quote: $e');
    }
  }
}
