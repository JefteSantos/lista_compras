import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'categoria_item.dart';
import '../services/hive_service.dart';

/// Paleta de cores curadas para as tags de categoria.
/// A cor é determinada automaticamente por hash do nome da categoria.
const List<Color> _paletaCategorias = [
  Color(0xFF4CAF50), // Verde — Hortifruti
  Color(0xFF2196F3), // Azul — Bebidas
  Color(0xFFF44336), // Vermelho — Carnes
  Color(0xFFFF9800), // Laranja — Padaria
  Color(0xFF9C27B0), // Roxo — Limpeza
  Color(0xFF00BCD4), // Ciano — Laticínios
  Color(0xFFE91E63), // Rosa — Higiene
  Color(0xFF607D8B), // Cinza azulado — Outros
  Color(0xFF795548), // Marrom — Mercearia
  Color(0xFF009688), // Teal — Congelados
];

/// Categorias padrão pré-cadastradas.
const List<String> _categoriasPadrao = [
  'Hortifruti',
  'Laticínios',
  'Carnes',
  'Padaria',
  'Limpeza',
  'Bebidas',
  'Higiene',
  'Outros',
];

/// Retorna a cor associada ao nome de uma categoria de forma consistente.
Color corDaCategoria(String nome) {
  final hash = nome.codeUnits.fold<int>(0, (acc, c) => acc + c);
  return _paletaCategorias[hash % _paletaCategorias.length];
}

class CategoriasProvider with ChangeNotifier {
  List<CategoriaItem> _categorias = [];

  List<CategoriaItem> get categorias => List.unmodifiable(_categorias);

  CategoriasProvider() {
    _carregar();
  }

  int _compararCategorias(CategoriaItem a, CategoriaItem b) {
    final oA = a.ordem ?? 0;
    final oB = b.ordem ?? 0;
    if (oA != oB) {
      return oA.compareTo(oB);
    }
    return a.nome.compareTo(b.nome);
  }

  void _carregar() {
    final box = HiveService.categoriasBox;
    _categorias = box.values.toList()
      ..sort(_compararCategorias);

    // Popula com as categorias padrão na primeira execução
    if (_categorias.isEmpty) {
      _popularPadrao();
    }
  }

  Future<void> _popularPadrao() async {
    const uuid = Uuid();
    for (int i = 0; i < _categoriasPadrao.length; i++) {
      final nome = _categoriasPadrao[i];
      final cat = CategoriaItem(id: uuid.v4(), nome: nome, ordem: i);
      await HiveService.categoriasBox.put(cat.id, cat);
    }
    _categorias = HiveService.categoriasBox.values.toList()
      ..sort(_compararCategorias);
    notifyListeners();
  }

  Future<void> adicionar(String nome) async {
    final nomeTrimmed = nome.trim();
    if (nomeTrimmed.isEmpty) return;

    // Evita duplicatas (case-insensitive)
    final jaExiste = _categorias.any(
      (c) => c.nome.toLowerCase() == nomeTrimmed.toLowerCase(),
    );
    if (jaExiste) return;

    const uuid = Uuid();
    final cat = CategoriaItem(
      id: uuid.v4(),
      nome: nomeTrimmed,
      ordem: _categorias.length,
    );
    await HiveService.categoriasBox.put(cat.id, cat);
    _categorias = HiveService.categoriasBox.values.toList()
      ..sort(_compararCategorias);
    notifyListeners();
  }

  Future<void> reordenar(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = _categorias.removeAt(oldIndex);
    _categorias.insert(newIndex, item);

    // Atualiza o índice de ordem de todas as categorias na lista e persiste no Hive
    for (int i = 0; i < _categorias.length; i++) {
      _categorias[i].ordem = i;
      await _categorias[i].save();
    }
    notifyListeners();
  }

  Future<void> remover(String id) async {
    await HiveService.categoriasBox.delete(id);
    _categorias.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  /// Retorna true se o nome da categoria já existe (para validação na UI).
  bool existeNome(String nome) {
    return _categorias.any(
      (c) => c.nome.toLowerCase() == nome.trim().toLowerCase(),
    );
  }
}
