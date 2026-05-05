import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/portfolio_transaction.dart';

class PortfolioNotifier extends StateNotifier<AsyncValue<List<PortfolioHolding>>> {
  PortfolioNotifier() : super(const AsyncValue.loading()) {
    _loadPortfolio();
  }

  Future<void> _loadPortfolio() async {
    state = const AsyncValue.loading();
    
    try {
      final transactionsBox = await Hive.openBox<PortfolioTransaction>('transactions');
      final transactions = transactionsBox.values.toList();
      
      // Calculate holdings from transactions
      final holdings = _calculateHoldings(transactions);
      
      state = AsyncValue.data(holdings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  List<PortfolioHolding> _calculateHoldings(List<PortfolioTransaction> transactions) {
    final Map<String, List<PortfolioTransaction>> symbolTransactions = {};
    
    // Group transactions by symbol
    for (final transaction in transactions) {
      if (!symbolTransactions.containsKey(transaction.symbol)) {
        symbolTransactions[transaction.symbol] = [];
      }
      symbolTransactions[transaction.symbol]!.add(transaction);
    }

    final holdings = <PortfolioHolding>[];
    
    // Calculate holdings for each symbol
    for (final entry in symbolTransactions.entries) {
      final symbol = entry.key;
      final symbolTransactions = entry.value;
      
      int totalQuantity = 0;
      double totalInvested = 0.0;
      
      // Calculate net quantity and total invested
      for (final transaction in symbolTransactions) {
        if (transaction.type == TransactionType.buy) {
          totalQuantity += transaction.quantity;
          totalInvested += transaction.totalCost;
        } else {
          totalQuantity -= transaction.quantity;
          // For sell transactions, we reduce invested amount proportionally
          totalInvested -= (transaction.quantity / totalQuantity) * transaction.totalValue;
        }
      }
      
      // Only include holdings with positive quantity
      if (totalQuantity > 0) {
        final averagePrice = totalInvested / totalQuantity;
        
        holdings.add(PortfolioHolding(
          symbol: symbol,
          name: symbol, // TODO: Get actual name from API
          quantity: totalQuantity,
          averagePrice: averagePrice,
          totalInvested: totalInvested,
          currentPrice: averagePrice, // TODO: Get current price from API
          lastUpdated: DateTime.now(),
        ));
      }
    }
    
    return holdings;
  }

  Future<void> addTransaction(PortfolioTransaction transaction) async {
    try {
      final transactionsBox = await Hive.openBox<PortfolioTransaction>('transactions');
      await transactionsBox.add(transaction);
      
      // Reload portfolio
      await _loadPortfolio();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> buyStock({
    required String symbol,
    required int quantity,
    required double price,
    double commission = 0.0,
    String? notes,
  }) async {
    final transaction = PortfolioTransaction(
      type: TransactionType.buy,
      symbol: symbol,
      quantity: quantity,
      price: price,
      commission: commission,
      date: DateTime.now(),
      notes: notes,
    );
    
    await addTransaction(transaction);
  }

  Future<void> sellStock({
    required String symbol,
    required int quantity,
    required double price,
    double commission = 0.0,
    String? notes,
  }) async {
    // Check if user has enough shares
    final currentHoldings = state.whenData((holdings) => holdings) ?? [];
    final holding = currentHoldings.firstWhere(
      (h) => h.symbol == symbol,
      orElse: () => throw Exception('No holdings found for $symbol'),
    );
    
    if (holding.quantity < quantity) {
      throw Exception('Insufficient shares. You have ${holding.quantity} shares of $symbol');
    }
    
    final transaction = PortfolioTransaction(
      type: TransactionType.sell,
      symbol: symbol,
      quantity: quantity,
      price: price,
      commission: commission,
      date: DateTime.now(),
      notes: notes,
    );
    
    await addTransaction(transaction);
  }

  Future<void> updateCurrentPrices(Map<String, double> prices) async {
    try {
      final currentHoldings = state.whenData((holdings) => holdings) ?? [];
      
      final updatedHoldings = currentHoldings.map((holding) {
        final currentPrice = prices[holding.symbol] ?? holding.currentPrice;
        return holding.copyWith(
          currentPrice: currentPrice,
          lastUpdated: DateTime.now(),
        );
      }).toList();
      
      state = AsyncValue.data(updatedHoldings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> clearPortfolio() async {
    try {
      final transactionsBox = await Hive.openBox<PortfolioTransaction>('transactions');
      await transactionsBox.clear();
      
      state = const AsyncValue.data([]);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Get portfolio summary
  double get totalInvestment {
    if (state is! AsyncData) return 0.0;
    final holdings = (state as AsyncData).value;
    return holdings.fold(0.0, (sum, holding) => sum + holding.totalInvested);
  }

  double get currentValue {
    if (state is! AsyncData) return 0.0;
    final holdings = (state as AsyncData).value;
    return holdings.fold(0.0, (sum, holding) => sum + holding.currentValue);
  }

  double get totalProfitLoss {
    return currentValue - totalInvestment;
  }

  double get totalProfitLossPercent {
    if (totalInvestment == 0.0) return 0.0;
    return (totalProfitLoss / totalInvestment) * 100.0;
  }

  int get holdingsCount {
    if (state is! AsyncData) return 0;
    return (state as AsyncData).value.length;
  }
}

final portfolioProvider = StateNotifierProvider<PortfolioNotifier, AsyncValue<List<PortfolioHolding>>>(
  (ref) => PortfolioNotifier(),
);

final portfolioSummaryProvider = Provider<Map<String, double>>((ref) {
  final portfolioNotifier = ref.watch(portfolioProvider.notifier);
  return {
    'totalInvestment': portfolioNotifier.totalInvestment,
    'currentValue': portfolioNotifier.currentValue,
    'totalProfitLoss': portfolioNotifier.totalProfitLoss,
    'totalProfitLossPercent': portfolioNotifier.totalProfitLossPercent,
    'holdingsCount': portfolioNotifier.holdingsCount.toDouble(),
  };
});

final portfolioHoldingsProvider = Provider<List<PortfolioHolding>>((ref) {
  final portfolioAsync = ref.watch(portfolioProvider);
  return portfolioAsync.when(
    data: (holdings) => holdings,
    loading: () => [],
    error: (_, __) => [],
  );
});
