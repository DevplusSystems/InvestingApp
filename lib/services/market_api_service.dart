import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/market_data.dart';
import '../config/api_config.dart';

class MarketApiService {
  static final MarketApiService _instance = MarketApiService._internal();
  factory MarketApiService() => _instance;
  MarketApiService._internal();

  // HTTP client with timeout
  final _client = http.Client();

  // Generic API request handler
  Future<ApiResponse<Map<String, dynamic>>> _makeRequest(
    String url, {
    Map<String, String>? headers,
    int retryCount = 0,
  }) async {
    try {
      final response = await _client
          .get(Uri.parse(url), headers: headers)
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return ApiResponse.success(data);
      } else if (response.statusCode == 429) {
        // Rate limited - wait and retry
        if (retryCount < ApiConfig.maxRetries) {
          await Future.delayed(ApiConfig.rateLimitDelay);
          return _makeRequest(url, headers: headers, retryCount: retryCount + 1);
        }
        return ApiResponse.error('Rate limit exceeded', message: 'Too many requests');
      } else {
        return ApiResponse.error(
          'HTTP ${response.statusCode}',
          message: 'Request failed with status ${response.statusCode}',
        );
      }
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

  // Twelve Data API Methods
  Future<ApiResponse<StockData>> getStockPrice(String symbol) async {
    final url = ApiConfig.getStockPrice(symbol);
    final response = await _makeRequest(url);

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
    final url = '${ApiConfig.twelveDataBaseUrl}/time_series?symbol=${symbols.join(',')}&apikey=${ApiConfig.twelveDataApiKey}';
    final response = await _makeRequest(url);

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
    final gainersUrl = ApiConfig.getMarketMovers('stock_market/gainers');
    final losersUrl = ApiConfig.getMarketMovers('stock_market/losers');
    final mostActiveUrl = ApiConfig.getMarketMovers('stock_market/most_active');

    try {
      final responses = await Future.wait([
        _makeRequest(gainersUrl),
        _makeRequest(losersUrl),
        _makeRequest(mostActiveUrl),
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
    final response = await _makeRequest(url);

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
    final response = await _makeRequest(url);

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
    final response = await _makeRequest(url);

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

  // Data parsing methods
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

  List<MarketData> _parseMarketMoversList(dynamic data) {
    if (data is! List) {
      return [];
    }
    
    return (data as List).map((item) {
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
      change: 0.0, // Index data may not include change
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

  // Dispose client
  void dispose() {
    _client.close();
  }
}
