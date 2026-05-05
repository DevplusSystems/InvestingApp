import 'package:hive/hive.dart';

part 'watchlist_item.g.dart';

@HiveType(typeId: 0)
class WatchlistItem extends HiveObject {
  @HiveField(0)
  final String symbol;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final double price;
  
  @HiveField(3)
  final double change;
  
  @HiveField(4)
  final double changePercent;
  
  @HiveField(5)
  final DateTime addedAt;
  
  @HiveField(6)
  final String exchange;

  WatchlistItem({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.addedAt,
    this.exchange = '',
  });

  WatchlistItem copyWith({
    String? symbol,
    String? name,
    double? price,
    double? change,
    double? changePercent,
    DateTime? addedAt,
    String? exchange,
  }) {
    return WatchlistItem(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      price: price ?? this.price,
      change: change ?? this.change,
      changePercent: changePercent ?? this.changePercent,
      addedAt: addedAt ?? this.addedAt,
      exchange: exchange ?? this.exchange,
    );
  }

  @override
  String toString() {
    return 'WatchlistItem(symbol: $symbol, name: $name, price: $price, change: $change, changePercent: $changePercent)';
  }
}
