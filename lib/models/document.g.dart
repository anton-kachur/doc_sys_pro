// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DocumentAdapter extends TypeAdapter<Document> {
  @override
  final int typeId = 0;

  @override
  Document read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Document(
      name: fields[0] as String,
      type: fields[1] as String,
      number: fields[2] as String,
      docNumber: fields[3] as String,
      dateFrom: fields[4] as DateTime,
      dateTo: fields[5] as DateTime,
      image: fields[6] as String,
      description: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Document obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.number)
      ..writeByte(3)
      ..write(obj.docNumber)
      ..writeByte(4)
      ..write(obj.dateFrom)
      ..writeByte(5)
      ..write(obj.dateTo)
      ..writeByte(6)
      ..write(obj.image)
      ..writeByte(7)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
