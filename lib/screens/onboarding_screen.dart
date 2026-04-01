import 'package:flutter/material.dart';
import 'package:lista_compras/services/hive_service.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPage(
      color: Color(0xFF6200EE),
      colorEnd: Color(0xFF3700B3),
      icon: Icons.shopping_cart_outlined,
      title: 'Bem-vindo ao\nNão Esquece!',
      description:
          'Nunca mais volte do mercado sem um item. Crie e gerencie suas listas de compras de forma simples e inteligente.',
    ),
    _OnboardingPage(
      color: Color(0xFF1565C0),
      colorEnd: Color(0xFF0D47A1),
      icon: Icons.checklist_rtl_outlined,
      title: 'Organize\nsuas compras',
      description:
          'Adicione itens com preço, quantidade e observações. Acompanhe o total estimado em tempo real enquanto faz as compras.',
    ),
    _OnboardingPage(
      color: Color(0xFF6A1B9A),
      colorEnd: Color(0xFF4A148C),
      icon: Icons.trending_up_outlined,
      title: 'Histórico\nde preços',
      description:
          'Ao finalizar uma lista, os preços são salvos automaticamente. Na próxima compra, veja se o item ficou mais caro ou mais barato.',
    ),
    _OnboardingPage(
      color: Color(0xFF00838F),
      colorEnd: Color(0xFF006064),
      icon: Icons.camera_alt_outlined,
      title: 'Scanner\nde listas',
      description:
          'Fotografe uma lista escrita (letras de forma ou impressa) e o app converte os itens automaticamente usando OCR.',
    ),
    _OnboardingPage(
      color: Color(0xFF2E7D32),
      colorEnd: Color(0xFF1B5E20),
      icon: Icons.qr_code_outlined,
      title: 'Compartilhe\nsuas listas',
      description:
          'Gere um código compacto e envie por WhatsApp ou SMS. A outra pessoa importa a lista completa no app instantaneamente.',
    ),
    _OnboardingPage(
      color: Color(0xFFE65100),
      colorEnd: Color(0xFFBF360C),
      icon: Icons.share_outlined,
      title: 'Compartilhe\ncomo texto',
      description:
          'Copie a lista formatada com preços unitários e totais para colar no WhatsApp, sem precisar que o outro tenha o app.',
    ),
    _OnboardingPage(
      color: Color(0xFF1565C0),
      colorEnd: Color(0xFF0D47A1),
      icon: Icons.widgets_outlined,
      title: 'Widget na\ntela inicial',
      description:
          'Veja os itens pendentes da sua lista ativa diretamente na tela inicial do celular, sem nem precisar abrir o app.',
    ),
    _OnboardingPage(
      color: Color(0xFF00796B),
      colorEnd: Color(0xFF004D40),
      icon: Icons.cloud_sync_outlined,
      title: 'Backup\nautomático',
      description:
          'Seus dados ficam salvos no Google Drive. Troque de aparelho e recupere todas as suas listas com 1 toque.',
    ),
    _OnboardingPage(
      color: Color(0xFF37474F),
      colorEnd: Color(0xFF263238),
      icon: Icons.picture_as_pdf_outlined,
      title: 'Exporte\nsuas listas',
      description:
          'Exporte suas listas em PDF, Excel ou CSV para imprimir, arquivar ou analisar seus gastos como preferir.',
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _finish() {
    HiveService.salvarConfiguracao('onboarding_completo', true);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (_, i) => _buildPage(_pages[i]),
          ),
          // Indicadores e botões
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(),
          ),
          // Botão Skip
          if (_currentPage < _pages.length - 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 16,
              child: TextButton(
                onPressed: _finish,
                child: const Text(
                  'Pular',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [page.color, page.colorEnd],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(page.icon, size: 72, color: Colors.white),
            ),
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                page.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                page.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final page = _pages[_currentPage];
    final isLast = _currentPage == _pages.length - 1;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [page.colorEnd.withValues(alpha: 0), page.colorEnd],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 48),
      child: Column(
        children: [
          // Indicadores de página
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _currentPage ? 24 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _currentPage
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Botão principal
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: page.color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                isLast ? 'Começar!' : 'Próximo',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final Color color;
  final Color colorEnd;
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.color,
    required this.colorEnd,
    required this.icon,
    required this.title,
    required this.description,
  });
}
