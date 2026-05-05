// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portfolio_transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PortfolioTransactionAdapter extends TypeAdapter<PortfolioTransaction> {
  @override
  final int typeId = 1;

  @override
  PortfolioTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PortfolioTransaction(
      type: fields[0] as TransactionType,
      symbol: fields[1] as String,
      quantity: fields[2] as int,
      price: fields[3] as double,
      commission: fields[4] as double,
      date: fields[5] as DateTime,
      notes: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PortfolioTransaction obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.symbol)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.commission)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PortfolioTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PortfolioHoldingAdapter extends TypeAdapter<PortfolioHolding> {
  @override
  final int typeId = 2;

  @override
  PortfolioHolding read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PortfolioHolding(
      symbol: fields[0] as String,
      name: fields[1] as String,
      quantity: fields[2] as int,
      averagePrice: fields[3] as double,
      totalInvested: fields[4] as double,
      currentPrice: fields[5] as double,
      lastUpdated: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PortfolioHolding obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.symbol)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.averagePrice)
      ..writeByte(4)
      ..write(obj.totalInvested)
      ..writeByte(5)
      ..write(obj.currentPrice)
      ..writeByte(6)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PortfolioHoldingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
