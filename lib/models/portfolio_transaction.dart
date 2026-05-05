import 'package:hive/hive.dart';

part 'portfolio_transaction.g.dart';

enum TransactionType { buy, sell }

@HiveType(typeId: 1)
class PortfolioTransaction extends HiveObject {
  @HiveField(0)
  final TransactionType type;
  
  @HiveField(1)
  final String symbol;
  
  @HiveField(2)
  final int quantity;
  
  @HiveField(3)
  final double price;
  
  @HiveField(4)
  final double commission;
  
  @HiveField(5)
  final DateTime date;
  
  @HiveField(6)
  final String? notes;

  PortfolioTransaction({
    required this.type,
    required this.symbol,
    required this.quantity,
    required this.price,
    required this.commission,
    required this.date,
    this.notes,
  });

  double get totalCost {
    return (quantity * price) + commission;
  }

  double get totalValue {
    return quantity * price;
  }

  @override
  String toString() {
    return 'PortfolioTransaction(type: $type, symbol: $symbol, quantity: $quantity, price: $price, commission: $commission, date: $date)';
  }
}

@HiveType(typeId: 2)
class PortfolioHolding {
  @HiveField(0)
  final String symbol;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final int quantity;
  
  @HiveField(3)
  final double averagePrice;
  
  @HiveField(4)
  final double totalInvested;
  
  @HiveField(5)
  final double currentPrice;
  
  @HiveField(6)
  final DateTime lastUpdated;

  PortfolioHolding({
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.averagePrice,
    required this.totalInvested,
    required this.currentPrice,
    required this.lastUpdated,
  });

  double get currentValue {
    return quantity * currentPrice;
  }

  double get profitLoss {
    return currentValue - totalInvested;
  }

  double get profitLossPercent {
    if (totalInvested == 0) return 0.0;
    return (profitLoss / totalInvested) * 100;
  }

  PortfolioHolding copyWith({
    String? symbol,
    String? name,
    int? quantity,
    double? averagePrice,
    double? totalInvested,
    double? currentPrice,
    DateTime? lastUpdated,
  }) {
    return PortfolioHolding(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      averagePrice: averagePrice ?? this.averagePrice,
      totalInvested: totalInvested ?? this.totalInvested,
      currentPrice: currentPrice ?? this.currentPrice,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() {
    return 'PortfolioHolding(symbol: $symbol, quantity: $quantity, avgPrice: $averagePrice, currentValue: $currentValue)';
  }
}
