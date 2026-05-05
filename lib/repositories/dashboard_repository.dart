import '../models/dashboard_data.dart';
import '../services/cache_service.dart';
import '../services/dashboard_api_service.dart';
import '../services/global_market_service.dart';
import '../config/api_config.dart';

class DashboardRepository {
  final DashboardApiService _apiService;
  final GlobalMarketService _globalMarketService;
  final CacheService _cacheService;

  // Combined watchlist with US and PSX stocks
  static const List<String> defaultWatchlist = [
    // US Stocks (Finnhub)
    'AAPL',  // Apple
    'MSFT',  // Microsoft
    'GOOGL', // Google
    'AMZN',  // Amazon
    'TSLA',  // Tesla
    // PSX Stocks (Twelve Data)
    ...ApiConfig.psxSymbols,
  ];

  DashboardRepository({
    required DashboardApiService apiService,
    required GlobalMarketService globalMarketService,
    required CacheService cacheService,
  })  : _apiService = apiService,
        _globalMarketService = globalMarketService,
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

      // Fetch quotes from multiple exchanges
      final usStocks = ['AAPL', 'MSFT', 'GOOGL', 'AMZN', 'TSLA'];
      final psxStocks = ApiConfig.psxSymbols;
      
      // Get US stock quotes from Finnhub
      final usQuotes = await _apiService.getMultipleQuotes(usStocks);
      
      // Get PSX stock quotes from Twelve Data
      final psxQuotes = await _globalMarketService.getMultipleQuotes(psxStocks);
      
      // Combine all quotes
      final allQuotes = [...usQuotes, ...psxQuotes];
      
      // Calculate portfolio totals
      double totalValue = 0;
      double totalChange = 0;
      final holdings = <AssetHolding>[];

      for (final quoteData in allQuotes) {
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

      // Determine which API to use based on symbol
      Map<String, dynamic> quoteData;
      if (symbol.endsWith('.PK')) {
        // PSX stock - use Twelve Data
        quoteData = await _globalMarketService.getStockQuote(symbol);
      } else {
        // US stock - use Finnhub
        quoteData = await _apiService.getStockQuote(symbol);
      }
      
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

  // Get PSX specific data
  Future<Map<String, dynamic>> getPSXData() async {
    try {
      return await _globalMarketService.getPSXData();
    } catch (e) {
      throw Exception('Failed to fetch PSX data: $e');
    }
  }

  // Get PSX index
  Future<StockQuote> getKSE100Index() async {
    try {
      final indexData = await _globalMarketService.getKSE100Index();
      return StockQuote.fromJson(indexData);
    } catch (e) {
      throw Exception('Failed to fetch KSE 100 index: $e');
    }
  }
}
