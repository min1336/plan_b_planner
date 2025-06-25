// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fixed_appointment_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FixedAppointmentModelAdapter extends TypeAdapter<FixedAppointmentModel> {
  @override
  final int typeId = 3;

  @override
  FixedAppointmentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FixedAppointmentModel(
      id: fields[0] as String,
      title: fields[1] as String,
      date: fields[2] as DateTime,
      startMinuteOfDay: fields[3] as int,
      endMinuteOfDay: fields[4] as int,
      category: fields[5] as Category,
    );
  }

  @override
  void write(BinaryWriter writer, FixedAppointmentModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.startMinuteOfDay)
      ..writeByte(4)
      ..write(obj.endMinuteOfDay)
      ..writeByte(5)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FixedAppointmentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
