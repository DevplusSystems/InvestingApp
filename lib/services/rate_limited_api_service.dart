import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/market_data.dart';
import '../config/api_config.dart';
import 'api_usage_tracker.dart';

class RateLimitedApiService {
  static final RateLimitedApiService _instance = RateLimitedApiService._internal();
  factory RateLimitedApiService() => _instance;
  RateLimitedApiService._internal();

  final _client = http.Client();
  final _usageTracker = ApiUsageTracker();
  final _cache = <String, CachedResponse>{};
  final Map<String, Timer> _rateLimitTimers = {};

  // Cache duration for different data types
  static const Duration stockPriceCache = Duration(minutes: 1);
  static const Duration marketMoversCache = Duration(minutes: 5);
  static const Duration commodityCache = Duration(minutes: 2);
  static const Duration indicesCache = Duration(minutes: 10);

  // Generic API request with rate limiting and caching
  Future<ApiResponse<Map<String, dynamic>>> _makeRequest(
    String apiName,
    String url, {
    Map<String, String>? headers,
    Duration? cacheDuration,
    int retryCount = 0,
  }) async {
    // Check cache first
    if (cacheDuration != null) {
      final cached = _getCachedResponse(url);
      if (cached != null && !cached.isExpired) {
        return ApiResponse.success(cached.data);
      }
    }

    try {
      // Track API call
      _usageTracker.trackApiCall(apiName);

      final response = await _client
          .get(Uri.parse(url), headers: headers)
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        
        // Cache successful response
        if (cacheDuration != null) {
          _cacheResponse(url, data, cacheDuration);
        }
        
        return ApiResponse.success(data);
      } else if (response.statusCode == 429) {
        // Rate limited - implement exponential backoff
        if (retryCount < ApiConfig.maxRetries) {
          final delay = Duration(milliseconds: (100 * (1 << retryCount))); // 100ms, 200ms, 400ms
          await Future.delayed(delay);
          return _makeRequest(apiName, url, headers: headers, cacheDuration: cacheDuration, retryCount: retryCount + 1);
        }
        return ApiResponse.error('Rate limit exceeded', message: 'Too many requests');
      } else {
        return ApiResponse.error(
          'HTTP ${response.statusCode}',
          message: 'Request failed with status ${response.statusCode}',
        );
      }
    } on ApiRateLimitException catch (e) {
      // Schedule retry when rate limit resets
      if (!_rateLimitTimers.containsKey(apiName)) {
        _rateLimitTimers[apiName] = Timer(e.timeUntilReset, () {
          _rateLimitTimers.remove(apiName);
        });
      }
      return ApiResponse.error(e.message);
    } on SocketException {
      return ApiResponse.error('No internet connection');
    } on HttpException {
      return ApiResponse.error('HTTP error occurred');
    } on FormatException {
      return ApiResponse.error('Invalid response format');
    } catch (e) {
      return ApiResponse.error('Unexpected error', message: e.toString());
    }
  }

  // Twelve Data API Methods with rate limiting
  Future<ApiResponse<StockData>> getStockPrice(String symbol) async {
    final url = ApiConfig.getStockPrice(symbol);
    final response = await _makeRequest(
      'twelveData',
      url,
      cacheDuration: stockPriceCache,
    );

    if (!response.success || response.data == null) {
      return ApiResponse.error(response.error ?? 'Failed to fetch stock price');
    }

    try {
      final data = response.data!;
      return ApiResponse.success(_parseStockData(data));
    } catch (e) {
      return ApiResponse.error('Failed to parse stock data', message: e.toString());
    }
  }

  Future<ApiResponse<List<StockData>>> getMultipleStockPrices(List<String> symbols) async {
    // Batch request to reduce API calls
    final url = '${ApiConfig.twelveDataBaseUrl}/time_series?symbol=${symbols.join(',')}&outputsize=1&apikey=${ApiConfig.twelveDataApiKey}';
    final response = await _makeRequest(
      'twelveData',
      url,
      cacheDuration: stockPriceCache,
    );

    if (!response.success || response.data == null) {
      return ApiResponse.error(response.error ?? 'Failed to fetch stock prices');
    }

    try {
      final data = response.data!;
      final stocks = <StockData>[];
      
      for (final symbol in symbols) {
        if (data.containsKey(symbol)) {
          final symbolData = data[symbol] as Map<String, dynamic>;
          stocks.add(_parseStockDataFromTimeSeries(symbol, symbolData));
        }
      }
      
      return ApiResponse.success(stocks);
    } catch (e) {
      return ApiResponse.error('Failed to parse stock data', message: e.toString());
    }
  }

  // Financial Modeling Prep API Methods
  Future<ApiResponse<MarketMoversResponse>> getMarketMovers() async {
    // Use parallel requests for efficiency
    final gainersUrl = ApiConfig.getStockMarketGainers();
    final losersUrl = ApiConfig.getStockMarketLosers();
    final mostActiveUrl = ApiConfig.getStockMarketMostActive();

    try {
      final responses = await Future.wait([
        _makeRequest('fmp', gainersUrl, cacheDuration: marketMoversCache),
        _makeRequest('fmp', losersUrl, cacheDuration: marketMoversCache),
        _makeRequest('fmp', mostActiveUrl, cacheDuration: marketMoversCache),
      ]);

      if (responses.any((r) => !r.success)) {
        return ApiResponse.error('Failed to fetch market movers');
      }

      final gainers = _parseMarketMoversList(responses[0].data!);
      final losers = _parseMarketMoversList(responses[1].data!);
      final mostActive = _parseMarketMoversList(responses[2].data!);

      return ApiResponse.success(MarketMoversResponse(
        gainers: gainers,
        losers: losers,
        mostActive: mostActive,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      return ApiResponse.error('Failed to fetch market movers', message: e.toString());
    }
  }

  Future<ApiResponse<List<IndexData>>> getIndicesList() async {
    final url = ApiConfig.getIndicesList();
    final response = await _makeRequest(
      'fmp',
      url,
      cacheDuration: indicesCache,
    );

    if (!response.success || response.data == null) {
      return ApiResponse.error(response.error ?? 'Failed to fetch indices');
    }

    try {
      final data = response.data! as List;
      final indices = data.map((item) => _parseIndexData(item as Map<String, dynamic>)).toList();
      return ApiResponse.success(indices);
    } catch (e) {
      return ApiResponse.error('Failed to parse indices data', message: e.toString());
    }
  }

  // GoldAPI Methods
  Future<ApiResponse<CommodityData>> getGoldPrice() async {
    final url = ApiConfig.getGoldPrice();
    final response = await _makeRequest(
      'goldApi',
      url,
      cacheDuration: commodityCache,
    );

    if (!response.success || response.data == null) {
      return ApiResponse.error(response.error ?? 'Failed to fetch gold price');
    }

    try {
      final data = response.data!;
      return ApiResponse.success(_parseCommodityData(data, 'Gold', 'XAU'));
    } catch (e) {
      return ApiResponse.error('Failed to parse gold data', message: e.toString());
    }
  }

  Future<ApiResponse<CommodityData>> getSilverPrice() async {
    final url = ApiConfig.getSilverPrice();
    final response = await _makeRequest(
      'goldApi',
      url,
      cacheDuration: commodityCache,
    );

    if (!response.success || response.data == null) {
      return ApiResponse.error(response.error ?? 'Failed to fetch silver price');
    }

    try {
      final data = response.data!;
      return ApiResponse.success(_parseCommodityData(data, 'Silver', 'XAG'));
    } catch (e) {
      return ApiResponse.error('Failed to parse silver data', message: e.toString());
    }
  }

  // Cache management
  CachedResponse? _getCachedResponse(String url) {
    return _cache[url];
  }

  void _cacheResponse(String url, Map<String, dynamic> data, Duration duration) {
    _cache[url] = CachedResponse(
      data: data,
      timestamp: DateTime.now(),
      duration: duration,
    );
  }

  void clearCache() {
    _cache.clear();
  }

  void cleanExpiredCache() {
    final now = DateTime.now();
    _cache.removeWhere((key, value) => value.isExpired(now));
  }

  // Data parsing methods (same as before)
  StockData _parseStockData(Map<String, dynamic> data) {
    return StockData(
      symbol: data['symbol'] ?? '',
      name: data['name'] ?? data['symbol'] ?? '',
      price: double.tryParse(data['price']?.toString() ?? '0') ?? 0.0,
      change: double.tryParse(data['change']?.toString() ?? '0') ?? 0.0,
      changePercent: double.tryParse(data['percent_change']?.toString() ?? '0') ?? 0.0,
      lastUpdate: DateTime.tryParse(data['timestamp'] ?? '') ?? DateTime.now(),
      exchange: data['exchange'] ?? 'NASDAQ',
      sector: data['sector'] ?? 'Technology',
      marketCap: double.tryParse(data['market_cap']?.toString() ?? '0') ?? 0.0,
      volume: double.tryParse(data['volume']?.toString() ?? '0') ?? 0.0,
    );
  }

  StockData _parseStockDataFromTimeSeries(String symbol, Map<String, dynamic> data) {
    final values = data['values'] as List?;
    if (values == null || values.isEmpty) {
      throw Exception('No time series data available');
    }

    final latest = values.first as Map<String, dynamic>;
    final previous = values.length > 1 ? values[1] as Map<String, dynamic> : latest;

    final price = double.tryParse(latest['close']?.toString() ?? '0') ?? 0.0;
    final prevPrice = double.tryParse(previous['close']?.toString() ?? '0') ?? 0.0;
    final change = price - prevPrice;
    final changePercent = prevPrice > 0 ? (change / prevPrice) * 100 : 0.0;

    return StockData(
      symbol: symbol,
      name: symbol,
      price: price,
      change: change,
      changePercent: changePercent,
      lastUpdate: DateTime.tryParse(latest['datetime'] ?? '') ?? DateTime.now(),
      exchange: 'NASDAQ',
      sector: 'Technology',
      marketCap: 0.0,
      volume: double.tryParse(latest['volume']?.toString() ?? '0') ?? 0.0,
    );
  }

  List<MarketData> _parseMarketMoversList(List<dynamic> data) {
    return data.map((item) {
      final stock = item as Map<String, dynamic>;
      final price = double.tryParse(stock['price']?.toString() ?? '0') ?? 0.0;
      final change = double.tryParse(stock['change']?.toString() ?? '0') ?? 0.0;
      final changePercent = double.tryParse(stock['changesPercentage']?.toString()?.replaceAll('%', '') ?? '0') ?? 0.0;

      return StockData(
        symbol: stock['ticker'] ?? '',
        name: stock['companyName'] ?? stock['ticker'] ?? '',
        price: price,
        change: change,
        changePercent: changePercent,
        lastUpdate: DateTime.now(),
        exchange: stock['exchange'] ?? 'NASDAQ',
        sector: 'Technology',
        marketCap: double.tryParse(stock['marketCap']?.toString() ?? '0') ?? 0.0,
        volume: double.tryParse(stock['volume']?.toString() ?? '0') ?? 0.0,
      );
    }).toList();
  }

  IndexData _parseIndexData(Map<String, dynamic> data) {
    return IndexData(
      symbol: data['symbol'] ?? '',
      name: data['name'] ?? '',
      price: double.tryParse(data['price']?.toString() ?? '0') ?? 0.0,
      change: 0.0,
      changePercent: 0.0,
      lastUpdate: DateTime.now(),
      country: data['country'] ?? 'US',
      currency: data['currency'] ?? 'USD',
      components: [],
    );
  }

  CommodityData _parseCommodityData(Map<String, dynamic> data, String name, String symbol) {
    final price = double.tryParse(data['price']?.toString() ?? '0') ?? 0.0;
    final change = double.tryParse(data['change']?.toString() ?? '0') ?? 0.0;
    final changePercent = double.tryParse(data['change_percent']?.toString() ?? '0') ?? 0.0;

    return CommodityData(
      symbol: symbol,
      name: name,
      price: price,
      change: change,
      changePercent: changePercent,
      lastUpdate: DateTime.now(),
      unit: data['unit'] ?? 'oz',
      market: data['market'] ?? 'COMEX',
      high24h: double.tryParse(data['high_24h']?.toString() ?? '0') ?? 0.0,
      low24h: double.tryParse(data['low_24h']?.toString() ?? '0') ?? 0.0,
    );
  }

  // Get usage statistics
  ApiUsageTracker get usageTracker => _usageTracker;
  Map<String, ApiUsage> get allUsage => _usageTracker.getAllUsage();
  List<ApiUsage> get criticalUsage => _usageTracker.getCriticalUsage();

  void dispose() {
    _client.close();
    for (final timer in _rateLimitTimers.values) {
      timer.cancel();
    }
    _rateLimitTimers.clear();
  }
}

class CachedResponse {
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final Duration duration;

  CachedResponse({
    required this.data,
    required this.timestamp,
    required this.duration,
  });

  bool get isExpired => DateTime.now().difference(timestamp) > duration;
  bool get isExpired(DateTime now) => now.difference(timestamp) > duration;
}
