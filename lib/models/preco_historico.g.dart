// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preco_historico.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrecoEntradaAdapter extends TypeAdapter<PrecoEntrada> {
  @override
  final int typeId = 3;

  @override
  PrecoEntrada read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrecoEntrada(
      preco: fields[0] as double,
      data: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PrecoEntrada obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.preco)
      ..writeByte(1)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrecoEntradaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PrecoHistoricoAdapter extends TypeAdapter<PrecoHistorico> {
  @override
  final int typeId = 2;

  @override
  PrecoHistorico read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrecoHistorico(
      nomeItem: fields[0] as String,
      entradas: (fields[1] as List?)?.cast<PrecoEntrada>(),
    );
  }

  @override
  void write(BinaryWriter writer, PrecoHistorico obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.nomeItem)
      ..writeByte(1)
      ..write(obj.entradas);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrecoHistoricoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
