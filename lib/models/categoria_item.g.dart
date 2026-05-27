// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categoria_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CategoriaItemAdapter extends TypeAdapter<CategoriaItem> {
  @override
  final int typeId = 4;

  @override
  CategoriaItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CategoriaItem(
      id: fields[0] as String,
      nome: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CategoriaItem obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nome);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoriaItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
