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

  @HiveField(8)
  String? categoria;

  Item({
    required this.id,
    required this.nome,
    this.quantidade = 1,
    this.preco,
    this.comprado = false,
    this.observacoes,
    required this.dataCriacao,
    this.dataCompra,
    this.categoria,
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
    Object? categoria = _sentinel,
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
      categoria: categoria == _sentinel ? this.categoria : categoria as String?,
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
        'categoria': categoria,
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
        categoria: json['categoria'] as String?,
      );
}

// Sentinela para distinguir null explícito de "não fornecido" no copyWith
const Object _sentinel = Object();
