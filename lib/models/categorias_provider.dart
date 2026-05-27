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

  void _carregar() {
    final box = HiveService.categoriasBox;
    _categorias = box.values.toList()
      ..sort((a, b) => a.nome.compareTo(b.nome));

    // Popula com as categorias padrão na primeira execução
    if (_categorias.isEmpty) {
      _popularPadrao();
    }
  }

  Future<void> _popularPadrao() async {
    const uuid = Uuid();
    for (final nome in _categoriasPadrao) {
      final cat = CategoriaItem(id: uuid.v4(), nome: nome);
      await HiveService.categoriasBox.put(cat.id, cat);
    }
    _categorias = HiveService.categoriasBox.values.toList()
      ..sort((a, b) => a.nome.compareTo(b.nome));
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
    final cat = CategoriaItem(id: uuid.v4(), nome: nomeTrimmed);
    await HiveService.categoriasBox.put(cat.id, cat);
    _categorias = HiveService.categoriasBox.values.toList()
      ..sort((a, b) => a.nome.compareTo(b.nome));
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
