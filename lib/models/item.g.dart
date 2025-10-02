// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemAdapter extends TypeAdapter<Item> {
  @override
  final int typeId = 0;

  @override
  Item read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Item(
      id: fields[0] as String,
      nome: fields[1] as String,
      quantidade: fields[2] as int,
      preco: fields[3] as double?,
      comprado: fields[4] as bool,
      observacoes: fields[5] as String?,
      dataCriacao: fields[6] as DateTime,
      dataCompra: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Item obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nome)
      ..writeByte(2)
      ..write(obj.quantidade)
      ..writeByte(3)
      ..write(obj.preco)
      ..writeByte(4)
      ..write(obj.comprado)
      ..writeByte(5)
      ..write(obj.observacoes)
      ..writeByte(6)
      ..write(obj.dataCriacao)
      ..writeByte(7)
      ..write(obj.dataCompra);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
