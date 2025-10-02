// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lista_compras.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ListaComprasAdapter extends TypeAdapter<ListaCompras> {
  @override
  final int typeId = 1;

  @override
  ListaCompras read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ListaCompras(
      id: fields[0] as String,
      nome: fields[1] as String,
      descricao: fields[2] as String?,
      itens: (fields[3] as List?)?.cast<Item>(),
      dataCriacao: fields[4] as DateTime,
      dataFinalizacao: fields[5] as DateTime?,
      finalizada: fields[6] as bool,
      cor: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ListaCompras obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nome)
      ..writeByte(2)
      ..write(obj.descricao)
      ..writeByte(3)
      ..write(obj.itens)
      ..writeByte(4)
      ..write(obj.dataCriacao)
      ..writeByte(5)
      ..write(obj.dataFinalizacao)
      ..writeByte(6)
      ..write(obj.finalizada)
      ..writeByte(7)
      ..write(obj.cor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListaComprasAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
