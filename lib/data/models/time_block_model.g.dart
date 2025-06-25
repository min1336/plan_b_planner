// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_block_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimeBlockModelAdapter extends TypeAdapter<TimeBlockModel> {
  @override
  final int typeId = 2;

  @override
  TimeBlockModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimeBlockModel(
      id: fields[0] as String,
      title: fields[1] as String,
      startMinuteOfDay: fields[2] as int,
      endMinuteOfDay: fields[3] as int,
      category: fields[4] as Category,
      isFlexible: fields[5] as bool,
      dayOfWeek: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TimeBlockModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.startMinuteOfDay)
      ..writeByte(3)
      ..write(obj.endMinuteOfDay)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.isFlexible)
      ..writeByte(6)
      ..write(obj.dayOfWeek);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeBlockModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
