import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/watchlist_item.dart';

class WatchlistNotifier extends StateNotifier<AsyncValue<List<WatchlistItem>>> {
  WatchlistNotifier() : super(const AsyncValue.loading()) {
    _loadWatchlist();
  }

  Future<void> reload() => _loadWatchlist();

  Future<void> _loadWatchlist() async {
    state = const AsyncValue.loading();
    
    try {
      final box = await Hive.openBox<WatchlistItem>('watchlist');
      final watchlist = box.values.toList();
      state = AsyncValue.data(watchlist);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addToWatchlist(WatchlistItem item) async {
    try {
      final box = await Hive.openBox<WatchlistItem>('watchlist');
      await box.put(item.symbol, item);
      
      // Reload watchlist
      await _loadWatchlist();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> removeFromWatchlist(String symbol) async {
    try {
      final box = await Hive.openBox<WatchlistItem>('watchlist');
      await box.delete(symbol);
      
      // Reload watchlist
      await _loadWatchlist();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateWatchlistItem(WatchlistItem item) async {
    try {
      final box = await Hive.openBox<WatchlistItem>('watchlist');
      await box.put(item.symbol, item);
      
      // Reload watchlist
      await _loadWatchlist();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> clearWatchlist() async {
    try {
      final box = await Hive.openBox<WatchlistItem>('watchlist');
      await box.clear();
      
      // Reload watchlist
      await _loadWatchlist();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  bool isInWatchlist(String symbol) {
    if (state is! AsyncData) return false;
    final watchlist = (state as AsyncData).value;
    return watchlist.any((item) => item.symbol == symbol);
  }

  WatchlistItem? getWatchlistItem(String symbol) {
    if (state is! AsyncData) return null;
    final watchlist = (state as AsyncData).value;
    try {
      return watchlist.firstWhere((item) => item.symbol == symbol);
    } catch (e) {
      return null;
    }
  }
}

final watchlistProvider = StateNotifierProvider<WatchlistNotifier, AsyncValue<List<WatchlistItem>>>(
  (ref) => WatchlistNotifier(),
);

final watchlistCountProvider = Provider<int>((ref) {
  final watchlistAsync = ref.watch(watchlistProvider);
  return watchlistAsync.when(
    data: (watchlist) => watchlist.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});
