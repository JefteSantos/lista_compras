import 'package:hive/hive.dart';

part 'item.g.dart';

@HiveType(typeId: 0)
class Item extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nome;

  @HiveField(2)
  int quantidade;

  @HiveField(3)
  double? preco;

  @HiveField(4)
  bool comprado;

  @HiveField(5)
  String? observacoes;

  @HiveField(6)
  DateTime dataCriacao;

  @HiveField(7)
  DateTime? dataCompra;

  Item({
    required this.id,
    required this.nome,
    this.quantidade = 1,
    this.preco,
    this.comprado = false,
    this.observacoes,
    required this.dataCriacao,
    this.dataCompra,
  });

  double get precoTotal => (preco ?? 0) * quantidade;

  Item copyWith({
    String? id,
    String? nome,
    int? quantidade,
    double? preco,
    bool? comprado,
    String? observacoes,
    DateTime? dataCriacao,
    DateTime? dataCompra,
  }) {
    return Item(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      quantidade: quantidade ?? this.quantidade,
      preco: preco ?? this.preco,
      comprado: comprado ?? this.comprado,
      observacoes: observacoes ?? this.observacoes,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataCompra: dataCompra ?? this.dataCompra,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'quantidade': quantidade,
        'preco': preco,
        'comprado': comprado,
        'observacoes': observacoes,
        'dataCriacao': dataCriacao.toIso8601String(),
        'dataCompra': dataCompra?.toIso8601String(),
      };

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json['id'] as String,
        nome: json['nome'] as String,
        quantidade: (json['quantidade'] as num).toInt(),
        preco: (json['preco'] as num?)?.toDouble(),
        comprado: json['comprado'] as bool,
        observacoes: json['observacoes'] as String?,
        dataCriacao: DateTime.parse(json['dataCriacao'] as String),
        dataCompra: json['dataCompra'] != null
            ? DateTime.parse(json['dataCompra'] as String)
            : null,
      );
}
