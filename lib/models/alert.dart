import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'alert.g.dart';

@HiveType(typeId: 3)
class AlertModel extends HiveObject implements Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String symbol;
  
  @HiveField(2)
  final AlertType alertType;
  
  @HiveField(3)
  final AlertCondition condition;
  
  @HiveField(4)
  final double targetPrice;
  
  @HiveField(5)
  final double targetPercentage;
  
  @HiveField(6)
  final double targetVolume;
  
  @HiveField(7)
  final DateTime createdAt;
  
  @HiveField(8)
  final DateTime? triggeredAt;
  
  @HiveField(9)
  final bool isActive;
  
  @HiveField(10)
  final bool isTriggered;
  
  @HiveField(11)
  final DateTime? lastNotifiedAt;
  
  @HiveField(12)
  final String? notes;
  
  @HiveField(13)
  final AlertFrequency frequency;

  const AlertModel({
    required this.id,
    required this.symbol,
    required this.alertType,
    required this.condition,
    required this.targetPrice,
    required this.targetPercentage,
    required this.targetVolume,
    required this.createdAt,
    this.triggeredAt,
    required this.isActive,
    required this.isTriggered,
    this.lastNotifiedAt,
    this.notes,
    required this.frequency,
  });

  AlertModel copyWith({
    String? id,
    String? symbol,
    AlertType? alertType,
    AlertCondition? condition,
    double? targetPrice,
    double? targetPercentage,
    double? targetVolume,
    DateTime? createdAt,
    DateTime? triggeredAt,
    bool? isActive,
    bool? isTriggered,
    DateTime? lastNotifiedAt,
    String? notes,
    AlertFrequency? frequency,
  }) {
    return AlertModel(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      alertType: alertType ?? this.alertType,
      condition: condition ?? this.condition,
      targetPrice: targetPrice ?? this.targetPrice,
      targetPercentage: targetPercentage ?? this.targetPercentage,
      targetVolume: targetVolume ?? this.targetVolume,
      createdAt: createdAt ?? this.createdAt,
      triggeredAt: triggeredAt ?? this.triggeredAt,
      isActive: isActive ?? this.isActive,
      isTriggered: isTriggered ?? this.isTriggered,
      lastNotifiedAt: lastNotifiedAt ?? this.lastNotifiedAt,
      notes: notes ?? this.notes,
      frequency: frequency ?? this.frequency,
    );
  }

  @override
  List<Object?> get props => [
        id,
        symbol,
        alertType,
        condition,
        targetPrice,
        targetPercentage,
        targetVolume,
        createdAt,
        triggeredAt,
        isActive,
        isTriggered,
        lastNotifiedAt,
        notes,
        frequency,
      ];

  @override
  String toString() {
    return 'AlertModel(id: $id, symbol: $symbol, type: $alertType, condition: $condition)';
  }

  // Helper methods
  bool shouldTrigger(double currentPrice, double currentVolume, double currentPercentage) {
    if (!isActive || isTriggered) return false;

    switch (alertType) {
      case AlertType.price:
        return _checkPriceCondition(currentPrice);
      case AlertType.percentage:
        return _checkPercentageCondition(currentPercentage);
      case AlertType.volume:
        return _checkVolumeCondition(currentVolume);
    }
  }

  bool _checkPriceCondition(double currentPrice) {
    switch (condition) {
      case AlertCondition.above:
        return currentPrice >= targetPrice;
      case AlertCondition.below:
        return currentPrice <= targetPrice;
      case AlertCondition.equals:
        return (currentPrice - targetPrice).abs() < 0.01; // Within 1 cent
    }
  }

  bool _checkPercentageCondition(double currentPercentage) {
    switch (condition) {
      case AlertCondition.above:
        return currentPercentage >= targetPercentage;
      case AlertCondition.below:
        return currentPercentage <= targetPercentage;
      case AlertCondition.equals:
        return (currentPercentage - targetPercentage).abs() < 0.1; // Within 0.1%
    }
  }

  bool _checkVolumeCondition(double currentVolume) {
    switch (condition) {
      case AlertCondition.above:
        return currentVolume >= targetVolume;
      case AlertCondition.below:
        return currentVolume <= targetVolume;
      case AlertCondition.equals:
        return (currentVolume - targetVolume).abs() < 1000; // Within 1000 shares
    }
  }

  bool canNotify() {
    if (!isTriggered) return false;
    
    final now = DateTime.now();
    
    switch (frequency) {
      case AlertFrequency.once:
        return lastNotifiedAt == null;
      case AlertFrequency.hourly:
        return lastNotifiedAt == null || 
               now.difference(lastNotifiedAt!).inHours >= 1;
      case AlertFrequency.daily:
        return lastNotifiedAt == null || 
               now.difference(lastNotifiedAt!).inDays >= 1;
      case AlertFrequency.weekly:
        return lastNotifiedAt == null || 
               now.difference(lastNotifiedAt!).inDays >= 7;
    }
  }

  String get displayText {
    switch (alertType) {
      case AlertType.price:
        return 'Alert when ${symbol} price goes ${condition.name} \$${targetPrice.toStringAsFixed(2)}';
      case AlertType.percentage:
        return 'Alert when ${symbol} changes ${condition.name} ${targetPercentage.toStringAsFixed(1)}%';
      case AlertType.volume:
        return 'Alert when ${symbol} volume goes ${condition.name} ${targetVolume.toInt()}';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'alertType': alertType.name,
      'condition': condition.name,
      'targetPrice': targetPrice,
      'targetPercentage': targetPercentage,
      'targetVolume': targetVolume,
      'createdAt': createdAt.toIso8601String(),
      'triggeredAt': triggeredAt?.toIso8601String(),
      'isActive': isActive,
      'isTriggered': isTriggered,
      'lastNotifiedAt': lastNotifiedAt?.toIso8601String(),
      'notes': notes,
      'frequency': frequency.name,
    };
  }

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'],
      symbol: json['symbol'],
      alertType: AlertType.values.firstWhere((e) => e.name == json['alertType']),
      condition: AlertCondition.values.firstWhere((e) => e.name == json['condition']),
      targetPrice: json['targetPrice']?.toDouble() ?? 0.0,
      targetPercentage: json['targetPercentage']?.toDouble() ?? 0.0,
      targetVolume: json['targetVolume']?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt']),
      triggeredAt: json['triggeredAt'] != null ? DateTime.parse(json['triggeredAt']) : null,
      isActive: json['isActive'] ?? true,
      isTriggered: json['isTriggered'] ?? false,
      lastNotifiedAt: json['lastNotifiedAt'] != null ? DateTime.parse(json['lastNotifiedAt']) : null,
      notes: json['notes'],
      frequency: AlertFrequency.values.firstWhere((e) => e.name == json['frequency']),
    );
  }
}

@HiveType(typeId: 4)
enum AlertType {
  @HiveField(0)
  price,
  @HiveField(1)
  percentage,
  @HiveField(2)
  volume;
}

@HiveType(typeId: 5)
enum AlertCondition {
  @HiveField(0)
  above('Above ⬆️'),
  @HiveField(1)
  below('Below ⬇️'),
  @HiveField(2)
  equals('Equals =');

  const AlertCondition(this.displayName);
  
  final String displayName;
}

@HiveType(typeId: 6)
enum AlertFrequency {
  @HiveField(0)
  once('Once'),
  @HiveField(1)
  hourly('Hourly'),
  @HiveField(2)
  daily('Daily'),
  @HiveField(3)
  weekly('Weekly');

  const AlertFrequency(this.displayName);
  
  final String displayName;
}
