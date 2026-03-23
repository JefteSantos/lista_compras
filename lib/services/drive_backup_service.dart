import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

import '../models/lista_compras.dart';
import '../services/auth_service.dart';
import '../services/hive_service.dart';

/// Resultado de um download de backup do Drive.
class BackupResult {
  final List<ListaCompras> listas;
  final DateTime dataBackup;
  BackupResult({required this.listas, required this.dataBackup});
}

/// Serviço de backup no Google Drive AppData (pasta privada do app no Drive do usuário).
/// Os dados ficam INVISÍVEIS para o usuário no Drive normal — apenas o app consegue acessar.
class DriveBackupService {
  DriveBackupService._();

  static const _backupFileName = 'nao_esquece_backup.json';
  static const _chaveUltimoBackup = 'ultimo_backup';

  // ─── API privada ────────────────────────────────────────────────────────────

  static Future<drive.DriveApi?> _getDriveApi() async {
    var account = AuthService.currentUser;
    account ??= await AuthService.signInSilently();
    if (account == null) return null;

    final authHeaders = await account.authHeaders;
    return drive.DriveApi(_AuthClient(authHeaders));
  }

  // ─── Upload ─────────────────────────────────────────────────────────────────

  /// Serializa todas as [listas] em JSON comprimido (GZIP) e faz upload
  /// para a pasta appDataFolder do Drive do usuário autenticado.
  static Future<void> uploadBackup(List<ListaCompras> listas) async {
    final api = await _getDriveApi();
    if (api == null) throw Exception('Usuário não autenticado no Google.');

    final payload = jsonEncode({
      'versao': 1,
      'dataBackup': DateTime.now().toIso8601String(),
      'listas': listas.map((l) => l.toJson()).toList(),
    });

    final compressed = gzip.encode(utf8.encode(payload));
    final stream = Stream.fromIterable([compressed]);
    final media = drive.Media(
      stream,
      compressed.length,
      contentType: 'application/octet-stream',
    );

    // Verifica se já existe um arquivo de backup
    final existing = await api.files.list(
      spaces: 'appDataFolder',
      q: "name = '$_backupFileName'",
      $fields: 'files(id)',
    );

    if (existing.files?.isNotEmpty == true) {
      // Atualiza o arquivo existente
      await api.files.update(
        drive.File(),
        existing.files!.first.id!,
        uploadMedia: media,
      );
    } else {
      // Cria o arquivo pela primeira vez
      final file = drive.File()
        ..name = _backupFileName
        ..parents = ['appDataFolder'];
      await api.files.create(file, uploadMedia: media);
    }

    // Salva a data localmente para exibição rápida sem precisar consultar o Drive
    final agora = DateTime.now();
    await HiveService.salvarConfiguracao(
      _chaveUltimoBackup,
      agora.toIso8601String(),
    );

    final tamanhoKb = (compressed.length / 1024).toStringAsFixed(1);
    debugPrint(
      '[DriveBackup] Backup realizado — '
      'Tamanho: ${tamanhoKb} KB | '
      'Data: $agora',
    );
  }

  // ─── Download ───────────────────────────────────────────────────────────────

  /// Baixa o backup do Drive e retorna as listas deserializadas.
  /// Retorna null se o usuário não estiver autenticado ou não houver backup.
  static Future<BackupResult?> downloadBackup() async {
    final api = await _getDriveApi();
    if (api == null) return null;

    final existing = await api.files.list(
      spaces: 'appDataFolder',
      q: "name = '$_backupFileName'",
      $fields: 'files(id, modifiedTime)',
    );

    if (existing.files?.isEmpty ?? true) return null;

    final fileInfo = existing.files!.first;
    final media = await api.files.get(
      fileInfo.id!,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final bytes = await media.stream.expand((b) => b).toList();
    final jsonStr = utf8.decode(gzip.decode(bytes));
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;

    final listas = (data['listas'] as List<dynamic>)
        .map((j) => ListaCompras.fromJson(j as Map<String, dynamic>))
        .toList();

    final dataBackup = data['dataBackup'] != null
        ? DateTime.parse(data['dataBackup'] as String)
        : (fileInfo.modifiedTime ?? DateTime.now());

    return BackupResult(listas: listas, dataBackup: dataBackup);
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  /// Retorna a data do último backup salva localmente (leitura instantânea).
  static DateTime? getLastBackupDateLocal() {
    final raw = HiveService.obterConfiguracao<String>(_chaveUltimoBackup);
    return raw != null ? DateTime.parse(raw) : null;
  }

  /// Tenta fazer backup silencioso (sem exibir erros para o usuário).
  static Future<void> uploadBackupSilently(List<ListaCompras> listas) async {
    try {
      if (!AuthService.isSignedIn) return;
      await uploadBackup(listas);
    } catch (e) {
      debugPrint('Backup silencioso falhou: $e');
    }
  }
}

// ─── HTTP Client autenticado ─────────────────────────────────────────────────

class _AuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final _inner = http.Client();

  _AuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }
}
