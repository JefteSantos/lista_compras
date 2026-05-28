import 'package:hive/hive.dart';

part 'categoria_item.g.dart';

@HiveType(typeId: 4)
class CategoriaItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nome;

  @HiveField(2)
  int? ordem;

  CategoriaItem({required this.id, required this.nome, this.ordem});
}
