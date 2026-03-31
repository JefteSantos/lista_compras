import 'dart:convert';
import 'dart:io';

import '../models/lista_compras.dart';

/// Gera e interpreta códigos de compartilhamento de listas.
///
/// Formato do código: "NE1:" + base64url
/// O conteúdo é o JSON da lista comprimido com GZIP e codificado em base64url.
/// Pode ser compartilhado via WhatsApp, SMS, email ou qualquer canal de texto.
class ShareCodeService {
  ShareCodeService._();

  static const _prefixV1 = 'NE1:';
  static const _prefixV2 = 'NE2:';

  // Chaves curtas para V2
  static const _keyMap = {
    'i': 'id',
    'n': 'nome',
    'd': 'descricao',
    'it': 'itens',
    'dc': 'dataCriacao',
    'df': 'dataFinalizacao',
    'f': 'finalizada',
    'c': 'cor',
    'q': 'quantidade',
    'p': 'preco',
    'co': 'comprado',
    'o': 'observacoes',
    'dm': 'dataCompra',
  };

  static final _reverseKeyMap = _keyMap.map((k, v) => MapEntry(v, k));

  /// Codifica uma [ListaCompras] em um código de texto compacto.
  /// Lança uma exceção se a lista for excessivamente grande para compartilhar por texto.
  static String encodeList(ListaCompras lista) {
    var map = lista.toJson();
    
    // Converte para V2 (chaves curtas)
    final v2Map = _toShortKeys(map);
    final jsonStr = jsonEncode(v2Map);
    final compressed = gzip.encode(utf8.encode(jsonStr));

    // Limite de 32KB compactado (~43 mil chars Base64) 
    // É muito mais seguro para evitar truncamento em apps de chat.
    if (compressed.length > 32 * 1024) {
      throw const ShareCodeOversizedException();
    }

    return '$_prefixV2${base64Url.encode(compressed)}';
  }

  static Map<String, dynamic> _toShortKeys(Map<String, dynamic> source) {
    final result = <String, dynamic>{};
    source.forEach((key, value) {
      final shortKey = _reverseKeyMap[key] ?? key;
      
      // Otimização de datas: converte Strings ISO8601 (longas) para Unix Timestamps (curtas)
      if ((shortKey == 'dc' || shortKey == 'df' || shortKey == 'dm') && value is String) {
        try {
          result[shortKey] = DateTime.parse(value).millisecondsSinceEpoch;
        } catch (_) {
          result[shortKey] = value;
        }
      } else if (value is List) {
        result[shortKey] = value.map((e) => e is Map<String, dynamic> ? _toShortKeys(e) : e).toList();
      } else if (value is Map<String, dynamic>) {
        result[shortKey] = _toShortKeys(value);
      } else {
        result[shortKey] = value;
      }
    });
    return result;
  }

  static Map<String, dynamic> _fromShortKeys(Map<String, dynamic> source) {
    final result = <String, dynamic>{};
    source.forEach((key, value) {
      final longKey = _keyMap[key] ?? key;
      
      // Otimização de datas: converte de volta para ISO8601 que os modelos esperam
      if ((key == 'dc' || key == 'df' || key == 'dm') && value is int) {
        result[longKey] = DateTime.fromMillisecondsSinceEpoch(value).toIso8601String();
      } else if (value is List) {
        result[longKey] = value.map((e) => e is Map<String, dynamic> ? _fromShortKeys(e) : e).toList();
      } else if (value is Map<String, dynamic>) {
        result[longKey] = _fromShortKeys(value);
      } else {
        result[longKey] = value;
      }
    });
    return result;
  }

  /// Decodifica um código de texto de volta para [ListaCompras].
  /// Retorna null se o código for inválido, corrompido ou não reconhecido.
  static ListaCompras? decodeList(String code) {
    try {
      // Remove espaços e quebras de linha que o WhatsApp adora inserir
      final stripped = code.replaceAll(RegExp(r'\s+'), '');
      
      bool isV1 = stripped.startsWith(_prefixV1);
      bool isV2 = stripped.startsWith(_prefixV2);
      
      if (!isV1 && !isV2) return null;
      
      final prefix = isV1 ? _prefixV1 : _prefixV2;
      String encoded = stripped.substring(prefix.length);
      
      // Validação rápida: comprimento % 4 não pode ser 1 no Base64
      if (encoded.length % 4 == 1) return null;

      // Normaliza o padding do Base64 (o Dart é exigente com comprimento múltiplo de 4)
      switch (encoded.length % 4) {
        case 2: encoded += '=='; break;
        case 3: encoded += '='; break;
      }
      
      final compressed = base64Url.decode(encoded);
      final jsonStr = utf8.decode(gzip.decode(compressed));
      
      var json = jsonDecode(jsonStr) as Map<String, dynamic>;
      
      if (isV2) {
        json = _fromShortKeys(json);
      }
      
      return ListaCompras.fromJson(json);
    } catch (_) {
      return null;
    }
  }
}

class ShareCodeOversizedException implements Exception {
  const ShareCodeOversizedException();
  @override
  String toString() => 'A lista é muito grande para compartilhar por código. Use a exportação em PDF ou arquivo.';
}
