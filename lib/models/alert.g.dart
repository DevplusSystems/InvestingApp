// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlertModelAdapter extends TypeAdapter<AlertModel> {
  @override
  final int typeId = 3;

  @override
  AlertModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AlertModel(
      id: fields[0] as String,
      symbol: fields[1] as String,
      alertType: fields[2] as AlertType,
      condition: fields[3] as AlertCondition,
      targetPrice: fields[4] as double,
      targetPercentage: fields[5] as double,
      targetVolume: fields[6] as double,
      createdAt: fields[7] as DateTime,
      triggeredAt: fields[8] as DateTime?,
      isActive: fields[9] as bool,
      isTriggered: fields[10] as bool,
      lastNotifiedAt: fields[11] as DateTime?,
      notes: fields[12] as String?,
      frequency: fields[13] as AlertFrequency,
    );
  }

  @override
  void write(BinaryWriter writer, AlertModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.symbol)
      ..writeByte(2)
      ..write(obj.alertType)
      ..writeByte(3)
      ..write(obj.condition)
      ..writeByte(4)
      ..write(obj.targetPrice)
      ..writeByte(5)
      ..write(obj.targetPercentage)
      ..writeByte(6)
      ..write(obj.targetVolume)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.triggeredAt)
      ..writeByte(9)
      ..write(obj.isActive)
      ..writeByte(10)
      ..write(obj.isTriggered)
      ..writeByte(11)
      ..write(obj.lastNotifiedAt)
      ..writeByte(12)
      ..write(obj.notes)
      ..writeByte(13)
      ..write(obj.frequency);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlertModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AlertTypeAdapter extends TypeAdapter<AlertType> {
  @override
  final int typeId = 4;

  @override
  AlertType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AlertType.price;
      case 1:
        return AlertType.percentage;
      case 2:
        return AlertType.volume;
      default:
        return AlertType.price;
    }
  }

  @override
  void write(BinaryWriter writer, AlertType obj) {
    switch (obj) {
      case AlertType.price:
        writer.writeByte(0);
        break;
      case AlertType.percentage:
        writer.writeByte(1);
        break;
      case AlertType.volume:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlertTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AlertConditionAdapter extends TypeAdapter<AlertCondition> {
  @override
  final int typeId = 5;

  @override
  AlertCondition read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AlertCondition.above;
      case 1:
        return AlertCondition.below;
      case 2:
        return AlertCondition.equals;
      default:
        return AlertCondition.above;
    }
  }

  @override
  void write(BinaryWriter writer, AlertCondition obj) {
    switch (obj) {
      case AlertCondition.above:
        writer.writeByte(0);
        break;
      case AlertCondition.below:
        writer.writeByte(1);
        break;
      case AlertCondition.equals:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlertConditionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AlertFrequencyAdapter extends TypeAdapter<AlertFrequency> {
  @override
  final int typeId = 6;

  @override
  AlertFrequency read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AlertFrequency.once;
      case 1:
        return AlertFrequency.hourly;
      case 2:
        return AlertFrequency.daily;
      case 3:
        return AlertFrequency.weekly;
      default:
        return AlertFrequency.once;
    }
  }

  @override
  void write(BinaryWriter writer, AlertFrequency obj) {
    switch (obj) {
      case AlertFrequency.once:
        writer.writeByte(0);
        break;
      case AlertFrequency.hourly:
        writer.writeByte(1);
        break;
      case AlertFrequency.daily:
        writer.writeByte(2);
        break;
      case AlertFrequency.weekly:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlertFrequencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
