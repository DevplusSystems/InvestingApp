import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/portfolio_transaction.dart';

class PortfolioNotifier extends StateNotifier<AsyncValue<List<PortfolioTransaction>>> {
  PortfolioNotifier() : super(const AsyncValue.loading()) {
    _loadPortfolio();
  }

  late Box<PortfolioTransaction> _transactionsBox;

  Future<void> _loadPortfolio() async {
    try {
      _transactionsBox = await Hive.openBox<PortfolioTransaction>('portfolio_transactions');
      final transactions = _transactionsBox.values.toList();
      state = AsyncValue.data(transactions);
    } catch (e) {
      debugPrint('Error loading portfolio: $e');
      state = AsyncValue.error('Failed to load portfolio data: ${e.toString()}', StackTrace.current);
    }
  }

  Future<void> addTransaction(PortfolioTransaction transaction) async {
    try {
      await _transactionsBox.add(transaction);
      final transactions = [...(state.value ?? const <PortfolioTransaction>[]), transaction];
      state = AsyncValue.data(transactions);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateTransaction(int key, PortfolioTransaction transaction) async {
    try {
      await _transactionsBox.put(key, transaction);
      final transactions = (state.value ?? const <PortfolioTransaction>[])
          .map((t) => t.key == key ? transaction : t)
          .toList();
      state = AsyncValue.data(transactions);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteTransaction(int key) async {
    try {
      await _transactionsBox.delete(key);
      final transactions =
          (state.value ?? const <PortfolioTransaction>[]).where((t) => t.key != key).toList();
      state = AsyncValue.data(transactions);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> clearPortfolio() async {
    try {
      await _transactionsBox.clear();
      state = const AsyncValue.data([]);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Get current holdings by stock symbol
  Map<String, Map<String, dynamic>> getCurrentHoldings() {
    final transactions = state.value ?? const <PortfolioTransaction>[];
    final holdings = <String, Map<String, dynamic>>{};

    for (final transaction in transactions) {
      final symbol = transaction.symbol;
      
      if (!holdings.containsKey(symbol)) {
        holdings[symbol] = {
          'quantity': 0,
          'totalCost': 0.0,
          'totalValue': 0.0,
          'avgPrice': 0.0,
        };
      }

      if (transaction.type == TransactionType.buy) {
        holdings[symbol]!['quantity'] += transaction.quantity;
        holdings[symbol]!['totalCost'] += (transaction.quantity * transaction.price);
        holdings[symbol]!['totalValue'] += (transaction.quantity * transaction.price);
      } else {
        holdings[symbol]!['quantity'] -= transaction.quantity;
        holdings[symbol]!['totalCost'] -= (transaction.quantity * transaction.price);
        holdings[symbol]!['totalValue'] -= (transaction.quantity * transaction.price);
      }

      // Calculate average price
      if (holdings[symbol]!['quantity'] > 0) {
        holdings[symbol]!['avgPrice'] = holdings[symbol]!['totalCost'] / holdings[symbol]!['quantity'];
      }
    }

    return holdings;
  }

  // Get available quantity for a specific stock
  int getAvailableQuantity(String symbol) {
    final holdings = getCurrentHoldings();
    return holdings[symbol]?['quantity'] ?? 0;
  }

  // Check if user can sell specified quantity
  bool canSellStock(String symbol, int quantity) {
    final available = getAvailableQuantity(symbol);
    return available >= quantity;
  }

  Future<double> getTotalValue() async {
    try {
      final holdings = getCurrentHoldings();
      double total = 0.0;
      for (final holding in holdings.values) {
        total += holding['totalValue'] as double;
      }
      return total;
    } catch (e) {
      return 0.0;
    }
  }

  Future<double> getTotalInvestment() async {
    try {
      final transactions = state.value ?? const <PortfolioTransaction>[];
      return transactions.fold<double>(
        0.0,
        (sum, transaction) => sum + (transaction.quantity * transaction.price),
      );
    } catch (e) {
      return 0.0;
    }
  }

  Future<double> getTotalProfitLoss() async {
    try {
      final transactions = state.value ?? const <PortfolioTransaction>[];
      return transactions.fold<double>(0.0, (sum, transaction) {
        if (transaction.type == TransactionType.sell) {
          return sum - (transaction.quantity * transaction.price);
        } else {
          return sum + (transaction.quantity * transaction.price);
        }
      });
    } catch (e) {
      return 0.0;
    }
  }

  Future<Map<String, dynamic>> getPortfolioSummary() async {
    try {
      final currentValue = await getTotalValue();
      final totalInvestment = await getTotalInvestment();
      final totalProfitLoss = await getTotalProfitLoss();
      final totalProfitLossPercent = totalInvestment > 0 ? (totalProfitLoss / totalInvestment) * 100 : 0.0;

      return {
        'currentValue': currentValue,
        'totalInvestment': totalInvestment,
        'totalProfitLoss': totalProfitLoss,
        'totalProfitLossPercent': totalProfitLossPercent,
      };
    } catch (e) {
      return {
        'currentValue': 0.0,
        'totalInvestment': 0.0,
        'totalProfitLoss': 0.0,
        'totalProfitLossPercent': 0.0,
      };
    }
  }

  @override
  void dispose() {
    _transactionsBox.close();
    super.dispose();
  }
}

// Providers
final portfolioProvider = StateNotifierProvider<PortfolioNotifier, AsyncValue<List<PortfolioTransaction>>>((ref) {
  return PortfolioNotifier();
});

final portfolioSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final notifier = ref.read(portfolioProvider.notifier);
  return await notifier.getPortfolioSummary();
});
