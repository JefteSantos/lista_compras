import 'package:hive/hive.dart';

part 'preco_historico.g.dart';

@HiveType(typeId: 3)
class PrecoEntrada extends HiveObject {
  @HiveField(0)
  final double preco;

  @HiveField(1)
  final DateTime data;

  PrecoEntrada({required this.preco, required this.data});
}

@HiveType(typeId: 2)
class PrecoHistorico extends HiveObject {
  @HiveField(0)
  final String nomeItem;

  @HiveField(1)
  final List<PrecoEntrada> entradas;

  PrecoHistorico({
    required this.nomeItem,
    List<PrecoEntrada>? entradas,
  }) : entradas = entradas ?? <PrecoEntrada>[];

  double? get ultimoPreco => entradas.isNotEmpty ? entradas.last.preco : null;
  
  DateTime? get ultimaData => entradas.isNotEmpty ? entradas.last.data : null;

  /// Adiciona um novo preço ao histórico, mantendo apenas os últimos 20 registros
  /// para não sobrecarregar o banco de dados.
  void adicionarEntrada(double preco, DateTime data) {
    // Evita duplicados no mesmo dia com o mesmo preço
    if (entradas.isNotEmpty) {
      final ultima = entradas.last;
      if (ultima.preco == preco && 
          ultima.data.year == data.year && 
          ultima.data.month == data.month && 
          ultima.data.day == data.day) {
        return;
      }
    }

    entradas.add(PrecoEntrada(preco: preco, data: data));
    
    // Ordena por data (garante que o gráfico saia certo)
    entradas.sort((a, b) => a.data.compareTo(b.data));

    // Mantém um limite saudável de dados
    if (entradas.length > 20) {
      entradas.removeAt(0);
    }
  }
}
