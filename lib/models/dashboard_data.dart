class DashboardData {
  final double totalPortfolioValue;
  final double dailyChange;
  final double dailyChangePercent;
  final List<AssetHolding> topHoldings;

  DashboardData({
    required this.totalPortfolioValue,
    required this.dailyChange,
    required this.dailyChangePercent,
    required this.topHoldings,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      totalPortfolioValue: json['totalPortfolioValue']?.toDouble() ?? 0.0,
      dailyChange: json['dailyChange']?.toDouble() ?? 0.0,
      dailyChangePercent: json['dailyChangePercent']?.toDouble() ?? 0.0,
      topHoldings: (json['topHoldings'] as List?)
              ?.map((e) => AssetHolding.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class StockQuote {
  final String symbol;
  final double currentPrice;
  final double change;
  final double percentChange;
  final double high;
  final double low;
  final double open;
  final double previousClose;
  final int timestamp;

  StockQuote({
    required this.symbol,
    required this.currentPrice,
    required this.change,
    required this.percentChange,
    required this.high,
    required this.low,
    required this.open,
    required this.previousClose,
    required this.timestamp,
  });

  factory StockQuote.fromJson(Map<String, dynamic> json) {
    return StockQuote(
      symbol: json['s'] ?? json['symbol'] ?? '',
      currentPrice: (json['c'] ?? json['currentPrice'])?.toDouble() ?? 0.0,
      change: (json['d'] ?? json['change'])?.toDouble() ?? 0.0,
      percentChange: (json['dp'] ?? json['percentChange'])?.toDouble() ?? 0.0,
      high: (json['h'] ?? json['high'])?.toDouble() ?? 0.0,
      low: (json['l'] ?? json['low'])?.toDouble() ?? 0.0,
      open: (json['o'] ?? json['open'])?.toDouble() ?? 0.0,
      previousClose: (json['pc'] ?? json['previousClose'])?.toDouble() ?? 0.0,
      timestamp: json['t'] ?? json['timestamp'] ?? 0,
    );
  }
}

class AssetHolding {
  final String symbol;
  final String name;
  final double value;
  final double shares;
  final double changePercent;

  AssetHolding({
    required this.symbol,
    required this.name,
    required this.value,
    required this.shares,
    required this.changePercent,
  });

  factory AssetHolding.fromJson(Map<String, dynamic> json) {
    return AssetHolding(
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      value: json['value']?.toDouble() ?? 0.0,
      shares: json['shares']?.toDouble() ?? 0.0,
      changePercent: json['changePercent']?.toDouble() ?? 0.0,
    );
  }

  factory AssetHolding.fromQuote(StockQuote quote, {double shares = 1.0}) {
    return AssetHolding(
      symbol: quote.symbol,
      name: quote.symbol, // Name would come from profile API
      value: quote.currentPrice * shares,
      shares: shares,
      changePercent: quote.percentChange,
    );
  }
}
