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
      color: Color(0xFF00796B),
      colorEnd: Color(0xFF004D40),
      icon: Icons.cloud_sync_outlined,
      title: 'Backup\nautomático',
      description:
          'Seus dados ficam salvos no seu Google Drive. Troque de aparelho e recupere todas as suas listas com 1 toque.',
    ),
    _OnboardingPage(
      color: Color(0xFF2E7D32),
      colorEnd: Color(0xFF1B5E20),
      icon: Icons.qr_code_outlined,
      title: 'Compartilhe\nsuas listas',
      description:
          'Gere um código e envie por WhatsApp. A outra pessoa importa a lista completa no app instantaneamente.',
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
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == _currentPage ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == _currentPage
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(4),
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
