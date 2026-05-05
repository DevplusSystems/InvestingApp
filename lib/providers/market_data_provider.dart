import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/market_data.dart';
import '../services/market_api_service.dart';
import '../providers/market_filter_provider.dart';

// Market API service provider
final marketApiServiceProvider = Provider<MarketApiService>((ref) {
  return MarketApiService();
});

// Real-time market data providers
final stockPriceProvider = FutureProvider.family<StockData, String>((ref, symbol) async {
  final apiService = ref.watch(marketApiServiceProvider);
  final response = await apiService.getStockPrice(symbol);
  
  if (!response.success || response.data == null) {
    throw Exception(response.error ?? 'Failed to fetch stock price');
  }
  
  return response.data!;
});

final marketMoversProvider = FutureProvider<MarketMoversResponse>((ref) async {
  final apiService = ref.watch(marketApiServiceProvider);
  final response = await apiService.getMarketMovers();
  
  if (!response.success || response.data == null) {
    throw Exception(response.error ?? 'Failed to fetch market movers');
  }
  
  return response.data!;
});

final indicesProvider = FutureProvider<List<IndexData>>((ref) async {
  final apiService = ref.watch(marketApiServiceProvider);
  final response = await apiService.getIndicesList();
  
  if (!response.success || response.data == null) {
    throw Exception(response.error ?? 'Failed to fetch indices');
  }
  
  return response.data!;
});

final goldPriceProvider = FutureProvider<CommodityData>((ref) async {
  final apiService = ref.watch(marketApiServiceProvider);
  final response = await apiService.getGoldPrice();
  
  if (!response.success || response.data == null) {
    throw Exception(response.error ?? 'Failed to fetch gold price');
  }
  
  return response.data!;
});

final silverPriceProvider = FutureProvider<CommodityData>((ref) async {
  final apiService = ref.watch(marketApiServiceProvider);
  final response = await apiService.getSilverPrice();
  
  if (!response.success || response.data == null) {
    throw Exception(response.error ?? 'Failed to fetch silver price');
  }
  
  return response.data!;
});

// Enhanced market movers provider with filtering
final enhancedMarketMoversProvider = Provider<List<MarketData>>((ref) {
  final marketMoversAsync = ref.watch(marketMoversProvider);
  final filter = ref.watch(marketFilterProvider);
  
  return marketMoversAsync.when(
    data: (marketMovers) {
      List<MarketData> baseData;
      
      // Get data based on type filter
      switch (filter.type) {
        case 'Gainers':
          baseData = marketMovers.gainers;
          break;
        case 'Losers':
          baseData = marketMovers.losers;
          break;
        case 'Most Active':
          baseData = marketMovers.mostActive;
          break;
        default:
          baseData = [...marketMovers.gainers, ...marketMovers.losers, ...marketMovers.mostActive];
      }
      
      // Apply category filter
      if (filter.category != 'All') {
        baseData = baseData.where((item) {
          switch (filter.category) {
            case 'Stocks':
              return item is StockData;
            case 'Indices':
              return item is IndexData;
            case 'Commodities':
              return item is CommodityData;
            case 'Crypto':
              return item is CryptoData;
            default:
              return true;
          }
        }).toList();
      }
      
      // Apply search filter
      if (filter.searchQuery.isNotEmpty) {
        final query = filter.searchQuery.toLowerCase();
        baseData = baseData.where((item) =>
            item.symbol.toLowerCase().contains(query) ||
            item.name.toLowerCase().contains(query)
        ).toList();
      }
      
      // Sort by change percentage (highest first)
      baseData.sort((a, b) => b.changePercent.abs().compareTo(a.changePercent.abs()));
      
      return baseData;
    },
    loading: () => [],
    error: (error, stack) => [],
  );
});

// Combined market data provider for dashboard
final dashboardMarketDataProvider = Provider<DashboardMarketData>((ref) {
  final marketMoversAsync = ref.watch(marketMoversProvider);
  final goldPriceAsync = ref.watch(goldPriceProvider);
  final silverPriceAsync = ref.watch(silverPriceAsync);
  
  return DashboardMarketData(
    marketMovers: marketMoversAsync,
    goldPrice: goldPriceAsync,
    silverPrice: silverPriceAsync,
  );
});

class DashboardMarketData {
  final AsyncValue<MarketMoversResponse> marketMovers;
  final AsyncValue<CommodityData> goldPrice;
  final AsyncValue<CommodityData> silverPrice;
  
  const DashboardMarketData({
    required this.marketMovers,
    required this.goldPrice,
    required this.silverPrice,
  });
  
  bool get isLoading => 
      marketMovers.isLoading || goldPrice.isLoading || silverPrice.isLoading;
  
  bool get hasError => 
      marketMovers.hasError || goldPrice.hasError || silverPrice.hasError;
  
  List<Object?> get errors => [
        if (marketMovers.hasError) marketMovers.error,
        if (goldPrice.hasError) goldPrice.error,
        if (silverPrice.hasError) silverPrice.error,
      ].whereType<Object?>().toList();
}

// Auto-refresh provider for real-time data
final marketDataRefreshProvider = Provider.autoDispose<void>((ref) {
  // Refresh every 60 seconds
  final timer = Timer.periodic(const Duration(seconds: 60), (_) {
    ref.invalidate(marketMoversProvider);
    ref.invalidate(goldPriceProvider);
    ref.invalidate(silverPriceProvider);
  });
  
  ref.onDispose(() => timer.cancel());
  
  return;
});
