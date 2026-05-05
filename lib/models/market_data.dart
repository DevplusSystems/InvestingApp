import 'package:equatable/equatable.dart';

// Base market data model
abstract class MarketData extends Equatable {
  final String symbol;
  final String name;
  final double price;
  final double change;
  final double changePercent;
  final DateTime lastUpdate;

  const MarketData({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.lastUpdate,
  });

  @override
  List<Object?> get props => [symbol, name, price, change, changePercent, lastUpdate];
}

// Stock data model
class StockData extends MarketData {
  final String exchange;
  final String sector;
  final double marketCap;
  final double volume;

  const StockData({
    required super.symbol,
    required super.name,
    required super.price,
    required super.change,
    required super.changePercent,
    required super.lastUpdate,
    required this.exchange,
    required this.sector,
    required this.marketCap,
    required this.volume,
  });

  @override
  List<Object?> get props => [...super.props, exchange, sector, marketCap, volume];
}

// Index data model
class IndexData extends MarketData {
  final String country;
  final String currency;
  final List<String> components;

  const IndexData({
    required super.symbol,
    required super.name,
    required super.price,
    required super.change,
    required super.changePercent,
    required super.lastUpdate,
    required this.country,
    required this.currency,
    required this.components,
  });

  @override
  List<Object?> get props => [...super.props, country, currency, components];
}

// Commodity data model
class CommodityData extends MarketData {
  final String unit;
  final String market;
  final double high24h;
  final double low24h;

  const CommodityData({
    required super.symbol,
    required super.name,
    required super.price,
    required super.change,
    required super.changePercent,
    required super.lastUpdate,
    required this.unit,
    required this.market,
    required this.high24h,
    required this.low24h,
  });

  @override
  List<Object?> get props => [...super.props, unit, market, high24h, low24h];
}

// Crypto data model
class CryptoData extends MarketData {
  final String exchange;
  final double marketCap;
  final double volume24h;
  final double circulatingSupply;

  const CryptoData({
    required super.symbol,
    required super.name,
    required super.price,
    required super.change,
    required super.changePercent,
    required super.lastUpdate,
    required this.exchange,
    required this.marketCap,
    required this.volume24h,
    required this.circulatingSupply,
  });

  @override
  List<Object?> get props => [...super.props, exchange, marketCap, volume24h, circulatingSupply];
}

// Market movers response model
class MarketMoversResponse {
  final List<MarketData> gainers;
  final List<MarketData> losers;
  final List<MarketData> mostActive;
  final DateTime timestamp;

  const MarketMoversResponse({
    required this.gainers,
    required this.losers,
    required this.mostActive,
    required this.timestamp,
  });
}

// API response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final String? message;

  const ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.message,
  });

  factory ApiResponse.success(T data) {
    return ApiResponse(
      success: true,
      data: data,
    );
  }

  factory ApiResponse.error(String error, {String? message}) {
    return ApiResponse(
      success: false,
      error: error,
      message: message,
    );
  }
}
