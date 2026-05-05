import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/market_filter.dart';
import '../models/market_data.dart';
import 'market_data_provider.dart';

final marketFilterProvider = StateNotifierProvider<MarketFilterNotifier, MarketFilter>((ref) {
  return MarketFilterNotifier();
});

class MarketFilterNotifier extends StateNotifier<MarketFilter> {
  MarketFilterNotifier() : super(const MarketFilter());

  void updateRegion(String region) {
    state = state.copyWith(region: region);
  }

  void updateCategory(String category) {
    state = state.copyWith(category: category);
  }

  void updateType(String type) {
    state = state.copyWith(type: type);
  }

  void updateSearchQuery(String searchQuery) {
    state = state.copyWith(searchQuery: searchQuery);
  }

  void updateFilter(MarketFilter newFilter) {
    state = newFilter;
  }

  void resetFilter() {
    state = const MarketFilter();
  }
}

// Legacy MarketMover class for backward compatibility
class MarketMover {
  final String symbol;
  final double price;
  final double change;
  final double changePercent;

  MarketMover({
    required this.symbol,
    required this.price,
    required this.change,
    required this.changePercent,
  });

  factory MarketMover.fromMarketData(MarketData data) {
    return MarketMover(
      symbol: data.symbol,
      price: data.price,
      change: data.change,
      changePercent: data.changePercent,
    );
  }
}

// Updated filtered market movers provider using real API data
final filteredMarketMoversProvider = Provider<List<MarketMover>>((ref) {
  final enhancedMovers = ref.watch(enhancedMarketMoversProvider);
  
  return enhancedMovers.map((data) => MarketMover.fromMarketData(data)).toList();
});
