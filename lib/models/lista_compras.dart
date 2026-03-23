import 'package:hive/hive.dart';
import 'item.dart';

part 'lista_compras.g.dart';

@HiveType(typeId: 1)
class ListaCompras extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nome;

  @HiveField(2)
  String? descricao;

  @HiveField(3)
  List<Item> itens;

  @HiveField(4)
  DateTime dataCriacao;

  @HiveField(5)
  DateTime? dataFinalizacao;

  @HiveField(6)
  bool finalizada;

  @HiveField(7)
  String? cor;

  ListaCompras({
    required this.id,
    required this.nome,
    this.descricao,
    List<Item>? itens,
    required this.dataCriacao,
    this.dataFinalizacao,
    this.finalizada = false,
    this.cor,
  }) : itens = itens ?? <Item>[];

  int get totalItens => itens.length;

  int get itensComprados => itens.where((item) => item.comprado).length;

  double get precoTotal =>
      itens.fold(0, (total, item) => total + item.precoTotal);

  double get precoComprado => itens
      .where((item) => item.comprado)
      .fold(0, (total, item) => total + item.precoTotal);

  ListaCompras copyWith({
    String? id,
    String? nome,
    String? descricao,
    List<Item>? itens,
    DateTime? dataCriacao,
    DateTime? dataFinalizacao,
    bool? finalizada,
    String? cor,
  }) {
    return ListaCompras(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      itens: itens ?? this.itens,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataFinalizacao: dataFinalizacao ?? this.dataFinalizacao,
      finalizada: finalizada ?? this.finalizada,
      cor: cor ?? this.cor,
    );
  }

  void adicionarItem(Item item) {
    itens.add(item);
    if (isInBox) save();
  }

  void removerItem(Item item) {
    itens.remove(item);
    if (isInBox) save();
  }

  void atualizarItem(Item item) {
    final index = itens.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      itens[index] = item;
      if (isInBox) save();
    }
  }

  void finalizarLista() {
    finalizada = true;
    dataFinalizacao = DateTime.now();
    if (isInBox) save();
  }

  void reabrirLista() {
    finalizada = false;
    dataFinalizacao = null;
    if (isInBox) save();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'descricao': descricao,
        'itens': itens.map((i) => i.toJson()).toList(),
        'dataCriacao': dataCriacao.toIso8601String(),
        'dataFinalizacao': dataFinalizacao?.toIso8601String(),
        'finalizada': finalizada,
        'cor': cor,
      };

  factory ListaCompras.fromJson(Map<String, dynamic> json) => ListaCompras(
        id: json['id'] as String,
        nome: json['nome'] as String,
        descricao: json['descricao'] as String?,
        itens: (json['itens'] as List<dynamic>)
            .map((i) => Item.fromJson(i as Map<String, dynamic>))
            .toList(),
        dataCriacao: DateTime.parse(json['dataCriacao'] as String),
        dataFinalizacao: json['dataFinalizacao'] != null
            ? DateTime.parse(json['dataFinalizacao'] as String)
            : null,
        finalizada: json['finalizada'] as bool,
        cor: json['cor'] as String?,
      );
}
