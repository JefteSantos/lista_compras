import 'package:flutter/material.dart';
import 'package:lista_compras/services/hive_service.dart';
import 'package:lista_compras/l10n/generated/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  List<_OnboardingPage> _pages(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return [
      _OnboardingPage(
        color: const Color(0xFF6200EE),
        colorEnd: const Color(0xFF3700B3),
        icon: Icons.shopping_cart_outlined,
        title: l.onboardingWelcomeTitle,
        description: l.onboardingWelcomeDesc,
      ),
      _OnboardingPage(
        color: const Color(0xFF1565C0),
        colorEnd: const Color(0xFF0D47A1),
        icon: Icons.checklist_rtl_outlined,
        title: l.onboardingOrganizeTitle,
        description: l.onboardingOrganizeDesc,
      ),
      _OnboardingPage(
        color: const Color(0xFF6A1B9A),
        colorEnd: const Color(0xFF4A148C),
        icon: Icons.trending_up_outlined,
        title: l.onboardingHistoryTitle,
        description: l.onboardingHistoryDesc,
      ),
      _OnboardingPage(
        color: const Color(0xFF00838F),
        colorEnd: const Color(0xFF006064),
        icon: Icons.camera_alt_outlined,
        title: l.onboardingScannerTitle,
        description: l.onboardingScannerDesc,
      ),
      _OnboardingPage(
        color: const Color(0xFF2E7D32),
        colorEnd: const Color(0xFF1B5E20),
        icon: Icons.qr_code_outlined,
        title: l.onboardingShareTitle,
        description: l.onboardingShareDesc,
      ),
      _OnboardingPage(
        color: const Color(0xFFE65100),
        colorEnd: const Color(0xFFBF360C),
        icon: Icons.share_outlined,
        title: l.onboardingTextShareTitle,
        description: l.onboardingTextShareDesc,
      ),
      _OnboardingPage(
        color: const Color(0xFF1565C0),
        colorEnd: const Color(0xFF0D47A1),
        icon: Icons.widgets_outlined,
        title: l.onboardingWidgetTitle,
        description: l.onboardingWidgetDesc,
      ),
      _OnboardingPage(
        color: const Color(0xFF00796B),
        colorEnd: const Color(0xFF004D40),
        icon: Icons.cloud_sync_outlined,
        title: l.onboardingBackupTitle,
        description: l.onboardingBackupDesc,
      ),
      _OnboardingPage(
        color: const Color(0xFF37474F),
        colorEnd: const Color(0xFF263238),
        icon: Icons.picture_as_pdf_outlined,
        title: l.onboardingExportTitle,
        description: l.onboardingExportDesc,
      ),
    ];
  }

  void _next() {
    if (_currentPage < _pages(context).length - 1) {
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
            itemCount: _pages(context).length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (_, i) => _buildPage(_pages(context)[i]),
          ),
          // Indicadores e botões
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(),
          ),
          // Botão Skip
          if (_currentPage < _pages(context).length - 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 16,
              child: TextButton(
                onPressed: _finish,
                child: Text(
                  AppLocalizations.of(context)!.onboardingSkip,
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
    final page = _pages(context)[_currentPage];
    final isLast = _currentPage == _pages(context).length - 1;

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
              _pages(context).length,
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
                isLast ? AppLocalizations.of(context)!.onboardingStart : AppLocalizations.of(context)!.onboardingNext,
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
