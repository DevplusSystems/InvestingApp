import 'api_service.dart';
import '../config/api_config.dart';

class GlobalMarketService {
  final ApiService _apiService;

  GlobalMarketService({required ApiService apiService})
      : _apiService = apiService;

  // Get stock quote from Twelve Data (supports PSX and global markets)
  Future<Map<String, dynamic>> getStockQuote(String symbol) async {
    return await _apiService.getWithParams('/quote', {
      'symbol': symbol,
      'apikey': ApiConfig.twelveDataApiKey,
    });
  }

  // Get multiple stock quotes
  Future<List<Map<String, dynamic>>> getMultipleQuotes(List<String> symbols) async {
    if (symbols.isEmpty) return [];

    // Twelve Data supports batch quotes
    final symbolsStr = symbols.join(',');
    try {
      final response = await _apiService.getWithParams('/time_series', {
        'symbol': symbolsStr,
        'interval': '1min',
        'apikey': ApiConfig.twelveDataApiKey,
      });
      
      // Parse the response for multiple symbols
      final quotes = <Map<String, dynamic>>[];
      if (response['values'] != null) {
        final values = response['values'] as List;
        for (int i = 0; i < symbols.length && i < values.length; i++) {
          final value = values[i] as Map<String, dynamic>;
          quotes.add({
            'symbol': symbols[i],
            'price': double.tryParse(value['close'] ?? '0') ?? 0.0,
            'change': double.tryParse(value['change'] ?? '0') ?? 0.0,
            'change_percent': double.tryParse(value['percent_change'] ?? '0') ?? 0.0,
            'volume': int.tryParse(value['volume'] ?? '0') ?? 0,
            'timestamp': value['datetime'] ?? '',
          });
        }
      }
      return quotes;
    } catch (e) {
      // Fallback to individual requests
      final quotes = <Map<String, dynamic>>[];
      for (final symbol in symbols) {
        try {
          final quote = await getStockQuote(symbol);
          quotes.add(quote);
        } catch (e) {
          continue;
        }
      }
      return quotes;
    }
  }

  // Get exchange information
  Future<Map<String, dynamic>> getExchangeInfo(String exchange) async {
    return await _apiService.getWithParams('/exchanges', {
      'exchange': exchange,
      'apikey': ApiConfig.twelveDataApiKey,
    });
  }

  // Get market indices
  Future<Map<String, dynamic>> getMarketIndices(String exchange) async {
    return await _apiService.getWithParams('/indices', {
      'exchange': exchange,
      'apikey': ApiConfig.twelveDataApiKey,
    });
  }

  // Get PSX specific data
  Future<Map<String, dynamic>> getPSXData() async {
    return await getExchangeInfo('XKAR');
  }

  // Get PSX index (KSE 100)
  Future<Map<String, dynamic>> getKSE100Index() async {
    return await getStockQuote('KSE100');
  }

  // Get top PSX movers
  Future<List<Map<String, dynamic>>> getPSXMovers() async {
    try {
      final response = await _apiService.getWithParams('/stocks/movers', {
        'exchange': 'XKAR',
        'apikey': ApiConfig.twelveDataApiKey,
      });
      
      return (response['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    } catch (e) {
      // Fallback to major PSX stocks
      return await getMultipleQuotes(ApiConfig.psxSymbols);
    }
  }

  // Get stock fundamentals
  Future<Map<String, dynamic>> getStockFundamentals(String symbol) async {
    return await _apiService.getWithParams('/quote', {
      'symbol': symbol,
      'apikey': ApiConfig.twelveDataApiKey,
      'fields': 'name,currency,exchange,sector,industry,market_cap,pe_ratio,pb_ratio,dividend_yield',
    });
  }

  // Get technical indicators
  Future<Map<String, dynamic>> getTechnicalIndicators(String symbol) async {
    return await _apiService.getWithParams('/technical_indicators', {
      'symbol': symbol,
      'interval': '1day',
      'indicators': 'SMA,EMA,RSI,MACD',
      'apikey': ApiConfig.twelveDataApiKey,
    });
  }
}
