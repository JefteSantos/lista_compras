import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/listas_provider.dart';
import '../services/auth_service.dart';
import '../services/drive_backup_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  GoogleSignInAccount? _currentUser;
  bool _isLoading = false;
  String? _statusMsg;
  bool _statusIsError = false;
  DateTime? _ultimoBackup;

  @override
  void initState() {
    super.initState();
    _currentUser = AuthService.currentUser;
    _ultimoBackup = DriveBackupService.getLastBackupDateLocal();
    AuthService.onCurrentUserChanged.listen((user) {
      if (mounted) setState(() => _currentUser = user);
    });
  }

  void _setStatus(String msg, {bool error = false}) {
    setState(() {
      _statusMsg = msg;
      _statusIsError = error;
    });
  }

  // ─── Ações ────────────────────────────────────────────────────────────────

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    final user = await AuthService.signIn();
    setState(() {
      _currentUser = user;
      _isLoading = false;
    });
    if (user != null) {
      _setStatus('Login realizado! Agora você pode fazer backup das suas listas.');
    } else {
      _setStatus('Login cancelado.', error: true);
    }
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text(
          'Deseja desconectar sua conta Google?\n'
          'O backup automático será desativado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('SAIR'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await AuthService.signOut();
      if (mounted) {
        setState(() => _currentUser = null);
        _setStatus('Conta desconectada.');
      }
    }
  }

  Future<void> _fazerBackup() async {
    setState(() => _isLoading = true);
    _setStatus('Fazendo backup...');
    try {
      final listas = Provider.of<ListasProvider>(context, listen: false).listas;
      await DriveBackupService.uploadBackup(listas);
      final agora = DateTime.now();
      setState(() => _ultimoBackup = agora);
      _setStatus('✅ Backup de ${listas.length} lista(s) realizado com sucesso!');
    } catch (e) {
      _setStatus('Erro no backup: $e', error: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _restaurarBackup() async {
    final temDadosLocais =
        Provider.of<ListasProvider>(context, listen: false).listas.isNotEmpty;

    bool substituir = false;

    if (temDadosLocais) {
      final opcao = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Restaurar Backup'),
          content: const Text(
            'Você já tem listas salvas neste aparelho.\nO que deseja fazer?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCELAR'),
            ),
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx, 'mesclar'),
              child: const Text('MESCLAR'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(ctx, 'substituir'),
              child: const Text('SUBSTITUIR TUDO'),
            ),
          ],
        ),
      );
      if (opcao == null) return;
      substituir = opcao == 'substituir';
    }

    setState(() => _isLoading = true);
    _setStatus('Baixando backup do Drive...');

    try {
      final result = await DriveBackupService.downloadBackup();
      if (result == null) {
        _setStatus('Nenhum backup encontrado no seu Google Drive.', error: true);
        return;
      }
      if (mounted) {
        await Provider.of<ListasProvider>(context, listen: false)
            .importarListas(result.listas, substituir: substituir);
        _setStatus(
          '✅ ${result.listas.length} lista(s) restaurada(s) com sucesso!',
        );
      }
    } catch (e) {
      _setStatus('Erro ao restaurar: $e', error: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── UI ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader(Icons.account_circle_outlined, 'Conta Google'),
              _buildAccountCard(),
              const SizedBox(height: 24),
              _buildSectionHeader(Icons.cloud_outlined, 'Backup no Google Drive'),
              _buildBackupCard(),
              const SizedBox(height: 16),
              if (_statusMsg != null) _buildStatusBanner(),
              const SizedBox(height: 24),
              _buildSectionHeader(Icons.info_outline, 'Sobre o Backup'),
              _buildInfoCard(),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.deepPurple),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.deepPurple.shade700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child:
            _currentUser == null ? _buildLoginButton() : _buildUserInfo(),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Entre com sua conta Google para ativar o backup automático das suas listas na nuvem.',
          style: TextStyle(color: Colors.grey, height: 1.4),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _signIn,
            icon: const Icon(Icons.login),
            label: const Text('Entrar com Google'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.deepPurple,
              side: const BorderSide(color: Colors.deepPurple),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundImage: _currentUser?.photoUrl != null
              ? NetworkImage(_currentUser!.photoUrl!)
              : null,
          backgroundColor: Colors.deepPurple.shade100,
          child: _currentUser?.photoUrl == null
              ? const Icon(Icons.person, color: Colors.deepPurple)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _currentUser?.displayName ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                _currentUser?.email ?? '',
                style:
                    TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: _isLoading ? null : _signOut,
          child: const Text('Sair', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  Widget _buildBackupCard() {
    final fmt = DateFormat("dd/MM/yyyy 'às' HH:mm", 'pt_BR');
    final backupStr = _ultimoBackup != null
        ? fmt.format(_ultimoBackup!)
        : 'Nenhum backup realizado ainda';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 6),
                Text(
                  'Último backup: $backupStr',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_currentUser == null)
              Text(
                'Entre com sua conta Google para habilitar o backup.',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              )
            else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _fazerBackup,
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('Fazer Backup Agora'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _restaurarBackup,
                  icon: const Icon(Icons.cloud_download),
                  label: const Text('Restaurar do Backup'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                    side: const BorderSide(color: Colors.deepPurple),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    final color = _statusIsError ? Colors.red : Colors.deepPurple;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.shade200),
      ),
      child: Row(
        children: [
          Icon(
            _statusIsError ? Icons.error_outline : Icons.check_circle_outline,
            color: color.shade400,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _statusMsg!,
              style: TextStyle(color: color.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 1,
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Como funciona?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            _infoItem('☁️', 'Seus dados ficam no seu próprio Google Drive (pasta privada)'),
            _infoItem('🔒', 'Nenhum servidor externo. Só você tem acesso.'),
            _infoItem('📱', 'Ao logar em outro aparelho, restaure com 1 toque'),
            _infoItem('🔄', 'Backup automático ao fechar o app'),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
            ),
          ),
        ],
      ),
    );
  }
}
