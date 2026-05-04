import 'api_service.dart';

class DashboardApiService {
  final ApiService _apiService;

  DashboardApiService({required ApiService apiService})
      : _apiService = apiService;

  // Get stock quote for a specific symbol
  Future<Map<String, dynamic>> getStockQuote(String symbol) async {
    return await _apiService.getWithParams('/quote', {'symbol': symbol});
  }

  // Get multiple stock quotes
  Future<List<Map<String, dynamic>>> getMultipleQuotes(List<String> symbols) async {
    final quotes = <Map<String, dynamic>>[];
    for (final symbol in symbols) {
      try {
        final quote = await getStockQuote(symbol);
        quotes.add(quote);
      } catch (e) {
        // Skip failed quotes
        continue;
      }
    }
    return quotes;
  }

  // Get company profile
  Future<Map<String, dynamic>> getCompanyProfile(String symbol) async {
    return await _apiService.getWithParams('/stock/profile2', {'symbol': symbol});
  }

  // Get market news
  Future<List<Map<String, dynamic>>> getMarketNews({String category = 'general'}) async {
    final response = await _apiService.getWithParams('/news', {'category': category});
    return (response['news'] as List?)?.cast<Map<String, dynamic>>() ?? [];
  }
}
