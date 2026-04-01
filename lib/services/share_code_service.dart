import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../models/lista_compras.dart';

/// Gera e interpreta códigos de compartilhamento de listas.
///
/// Versões suportadas:
///   NE1: = V1 legado (JSON puro + GZIP + Base64Url)
///   NE2: = V2 (chaves curtas + datas como timestamp + GZIP + Base64Url)
///   NE2: = V2+ (igual V2 mas sem IDs nem datas de criação, regenerados na importação)
///
/// A V2+ é retrocompatível: o decoder já consegue lidar com IDs ausentes.
class ShareCodeService {
  ShareCodeService._();

  static const _prefixV1 = 'NE1:';
  static const _prefixV2 = 'NE2:';

  // Chaves curtas para V2/V2+
  static const _keyMap = {
    'i':  'id',
    'n':  'nome',
    'd':  'descricao',
    'it': 'itens',
    'dc': 'dataCriacao',
    'df': 'dataFinalizacao',
    'f':  'finalizada',
    'c':  'cor',
    'q':  'quantidade',
    'p':  'preco',
    'co': 'comprado',
    'o':  'observacoes',
    'dm': 'dataCompra',
  };

  static final _reverseKeyMap = _keyMap.map((k, v) => MapEntry(v, k));

  // Caracteres seguros para transmissão por qualquer canal de texto
  // (sem +, /, = que podem ser modificados por WhatsApp/email/SMS)
  static const _safeAlphabet =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';

  /// Codifica uma [ListaCompras] em um código de texto compacto.
  /// Remove IDs e datas de criação de itens (regenerados na importação),
  /// reduzindo o tamanho em até 50% para listas grandes.
  static String encodeList(ListaCompras lista) {
    final map = lista.toJson();

    // Converte para V2 (chaves curtas + timestamps)
    final v2Map = _toShortKeys(map);

    // Remove campos que são regenerados na importação:
    // - 'i' (id da lista): home_screen regenera com Uuid().v4()
    // - 'i' dos itens (id de cada item): regenerado no decode
    // - 'dc' dos itens (dataCriacao): irrelevante para o receptor
    _stripDesnecessario(v2Map, isRaiz: true);

    final jsonStr = jsonEncode(v2Map);
    final compressed = gzip.encode(utf8.encode(jsonStr));

    // Limite de 16KB compactado para garantir transmissão segura
    if (compressed.length > 16 * 1024) {
      throw const ShareCodeOversizedException();
    }

    return '$_prefixV2${base64Url.encode(compressed)}';
  }

  /// Remove campos desnecessários para o compartilhamento.
  static void _stripDesnecessario(Map<String, dynamic> map, {bool isRaiz = false}) {
    // Remove o ID (será regenerado)
    map.remove('i');

    // Remove dataCriacao do item (não é 'dc' da raiz, que é da lista)
    // Na raiz: 'dc' = dataCriacao da lista (mantemos para contexto)
    // Nos itens: 'dc' = dataCriacao do item (desnecessário)
    if (!isRaiz) {
      map.remove('dc');
    }

    // Processa itens recursivamente
    final itens = map['it'];
    if (itens is List) {
      for (final item in itens) {
        if (item is Map<String, dynamic>) {
          _stripDesnecessario(item, isRaiz: false);
        }
      }
    }
  }

  static Map<String, dynamic> _toShortKeys(Map<String, dynamic> source) {
    final result = <String, dynamic>{};
    source.forEach((key, value) {
      final shortKey = _reverseKeyMap[key] ?? key;

      // Otimização de datas: converte ISO8601 para Unix timestamp (mais curto)
      if ((shortKey == 'dc' || shortKey == 'df' || shortKey == 'dm') &&
          value is String) {
        try {
          result[shortKey] = DateTime.parse(value).millisecondsSinceEpoch;
        } catch (_) {
          result[shortKey] = value;
        }
      } else if (value is List) {
        result[shortKey] = value
            .map((e) => e is Map<String, dynamic> ? _toShortKeys(e) : e)
            .toList();
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

      // Otimização de datas: converte de volta para ISO8601
      if ((key == 'dc' || key == 'df' || key == 'dm') && value is int) {
        result[longKey] =
            DateTime.fromMillisecondsSinceEpoch(value).toIso8601String();
      } else if (value is List) {
        result[longKey] = value
            .map((e) => e is Map<String, dynamic> ? _fromShortKeys(e) : e)
            .toList();
      } else if (value is Map<String, dynamic>) {
        result[longKey] = _fromShortKeys(value);
      } else {
        result[longKey] = value;
      }
    });
    return result;
  }

  /// Injeta IDs e campos obrigatórios ausentes após o decode.
  static void _injetarCamposAusentes(Map<String, dynamic> map) {
    // ID da lista (caso ausente no código compartilhado)
    if (!map.containsKey('id') || map['id'] == null) {
      map['id'] = _gerarId();
    }

    // Processa itens
    final itens = map['itens'];
    if (itens is List) {
      final agora = DateTime.now().toIso8601String();
      for (final item in itens) {
        if (item is Map<String, dynamic>) {
          // ID do item
          if (!item.containsKey('id') || item['id'] == null) {
            item['id'] = _gerarId();
          }
          // dataCriacao do item (obrigatória no modelo)
          if (!item.containsKey('dataCriacao') || item['dataCriacao'] == null) {
            item['dataCriacao'] = agora;
          }
          // comprado (default false)
          item.putIfAbsent('comprado', () => false);
          // quantidade (default 1)
          item.putIfAbsent('quantidade', () => 1);
        }
      }
    }
  }

  /// Gera um ID curto seguro (sem dependência do pacote uuid).
  /// Usa Random.secure() para 16 bytes → hex de 32 chars.
  static String _gerarId() {
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    // Formata como UUID v4
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  /// Decodifica um código de texto de volta para [ListaCompras].
  /// Retorna null se o código for inválido, corrompido ou não reconhecido.
  static ListaCompras? decodeList(String code) {
    try {
      // Remove espaços, quebras de linha e caracteres invisíveis
      // que WhatsApp/SMS adoram inserir em textos longos
      final stripped = code.replaceAll(RegExp(r'[\s\u200B-\u200D\uFEFF]+'), '');

      final isV1 = stripped.startsWith(_prefixV1);
      final isV2 = stripped.startsWith(_prefixV2);

      if (!isV1 && !isV2) return null;

      final prefix = isV1 ? _prefixV1 : _prefixV2;
      String encoded = stripped.substring(prefix.length);

      // Normaliza o padding do Base64Url
      switch (encoded.length % 4) {
        case 2:
          encoded += '==';
          break;
        case 3:
          encoded += '=';
          break;
      }

      final compressed = base64Url.decode(encoded);
      final jsonStr = utf8.decode(gzip.decode(compressed));

      var json = jsonDecode(jsonStr) as Map<String, dynamic>;

      if (isV2) {
        json = _fromShortKeys(json);
      }

      // Injeta campos obrigatórios que podem estar ausentes nos códigos V2+
      _injetarCamposAusentes(json);

      return ListaCompras.fromJson(json);
    } catch (_) {
      return null;
    }
  }
}

class ShareCodeOversizedException implements Exception {
  const ShareCodeOversizedException();
  @override
  String toString() =>
      'A lista é muito grande para compartilhar por código de texto. '
      'Tente exportar como arquivo e compartilhá-lo diretamente.';
}
