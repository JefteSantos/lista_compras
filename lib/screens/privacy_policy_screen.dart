import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Política de Privacidade')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _Section(
            title: 'Não Esquece! — Política de Privacidade',
            body:
                'Esta Política de Privacidade descreve como o aplicativo "Não Esquece!" '
                'trata os seus dados pessoais. Leia com atenção.',
          ),
          _Section(
            title: '1. Dados Coletados',
            body:
                'O aplicativo NÃO coleta nenhum dado pessoal em servidores próprios. '
                'Todos os dados inseridos (listas de compras, itens, preços) são '
                'armazenados exclusivamente:\n\n'
                '• No armazenamento local do seu dispositivo (Hive/SQLite).\n'
                '• No seu próprio Google Drive (pasta privada do app), '
                'caso você opte por ativar o backup.',
          ),
          _Section(
            title: '2. Google Drive e Google Sign-In',
            body:
                'Se você optar por fazer backup, o aplicativo solicitará acesso '
                'à sua conta Google com o escopo "drive.appdata". Este escopo '
                'permite salvar arquivos apenas na pasta oculta e privada do app '
                'no seu Google Drive.\n\n'
                'Nenhum outro dado da sua conta Google é acessado. '
                'Os arquivos de backup não ficam visíveis na interface normal '
                'do Google Drive.',
          ),
          _Section(
            title: '3. Compartilhamento de Dados',
            body:
                'O aplicativo NÃO compartilha seus dados com terceiros. '
                'Os códigos de compartilhamento de listas são gerados '
                'localmente no seu dispositivo e trafegam apenas pelos '
                'canais que você escolher (WhatsApp, SMS, e-mail, etc.).',
          ),
          _Section(
            title: '4. Armazenamento e Segurança',
            body:
                'Seus dados ficam sob controle exclusivo seu:\n\n'
                '• Dados locais: armazenados no seu dispositivo.\n'
                '• Backup: na sua conta Google Drive, protegida pelas '
                'políticas de segurança do Google.\n\n'
                'Não temos acesso, nem capacidade de acessar, seus dados pessoais.',
          ),
          _Section(
            title: '5. Exclusão de Dados',
            body:
                'Para excluir seus dados:\n\n'
                '• Dados locais: desinstale o aplicativo.\n'
                '• Backup no Drive: acesse drive.google.com/drive/appdata '
                'e exclua o arquivo "nao_esquece_backup.json".',
          ),
          _Section(
            title: '6. Alterações nesta Política',
            body:
                'Podemos atualizar esta política periodicamente. '
                'Atualizações relevantes serão comunicadas dentro do próprio app.',
          ),
          _Section(
            title: '7. Contato',
            body:
                'Dúvidas sobre privacidade? Entre em contato pelo e-mail '
                'informado na página do app na Play Store.',
          ),
          SizedBox(height: 32),
          Center(
            child: Text(
              'Última atualização: março de 2026',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;

  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
