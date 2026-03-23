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

  static const _prefix = 'NE1:';

  /// Codifica uma [ListaCompras] em um código de texto compacto.
  static String encodeList(ListaCompras lista) {
    final jsonStr = jsonEncode(lista.toJson());
    final compressed = gzip.encode(utf8.encode(jsonStr));
    return '$_prefix${base64Url.encode(compressed)}';
  }

  /// Decodifica um código de texto de volta para [ListaCompras].
  /// Retorna null se o código for inválido, corrompido ou não reconhecido.
  static ListaCompras? decodeList(String code) {
    try {
      final stripped = code.trim();
      if (!stripped.startsWith(_prefix)) return null;
      final encoded = stripped.substring(_prefix.length);
      final compressed = base64Url.decode(encoded);
      final jsonStr = utf8.decode(gzip.decode(compressed));
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return ListaCompras.fromJson(json);
    } catch (_) {
      return null;
    }
  }
}
