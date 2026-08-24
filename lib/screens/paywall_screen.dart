import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/iap_provider.dart';
import '../l10n/generated/app_localizations.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _comprando = false;

  void _comprar() async {
    final iap = Provider.of<IapProvider>(context, listen: false);

    if (iap.produtoDetails == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produto não disponível. Tente novamente mais tarde.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _comprando = true);

    final started = await iap.comprarPro();

    if (!mounted) return;

    if (!started) {
      setState(() => _comprando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            iap.erroLoja ?? AppLocalizations.of(context)!.proFailed,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<IapProvider>(
      builder: (context, iap, _) {
        // Se acabou de ficar PRO, mostra sucesso e fecha
        if (iap.isPro) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.proWelcome),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.of(context).pop();
            }
          });
        }

        if (!iap.compraPendente && _comprando) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _comprando = false);
          });
        }

        final isProcessando = _comprando || iap.compraPendente;

        return Scaffold(
          backgroundColor: Colors.deepPurple.shade50,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.deepPurple),
            actions: [
              TextButton(
                onPressed: isProcessando
                    ? null
                    : () {
                        iap.restaurarCompras();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Buscando compras anteriores...'),
                          ),
                        );
                      },
                child: Text(AppLocalizations.of(context)!.proRestore),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  const Icon(
                    Icons.star_rounded,
                    size: 72,
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Não Esquece! PRO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppLocalizations.of(context)!.proSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),

                  // Benefícios
                  _buildFeatureRow(
                    Icons.format_list_bulleted,
                    'Listas ilimitadas (plano grátis até 5)',
                  ),
                  _buildFeatureRow(
                    Icons.document_scanner,
                    AppLocalizations.of(context)!.proFeatureOcr,
                  ),
                  _buildFeatureRow(
                    Icons.picture_as_pdf,
                    AppLocalizations.of(context)!.proFeatureExport,
                  ),
                  _buildFeatureRow(
                    Icons.trending_up,
                    AppLocalizations.of(context)!.proFeatureHistory,
                  ),
                  _buildFeatureRow(
                    Icons.cloud_done_outlined,
                    'Backup em nuvem automático no Drive',
                  ),
                  const SizedBox(height: 24),

                  // Preço com ancoragem visual
                  _buildPrecoCard(iap),
                  const SizedBox(height: 20),

                  // Botão de Desbloquear
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: (isProcessando || iap.isLoading || iap.produtoDetails == null)
                          ? null
                          : () => _comprar(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: isProcessando
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Processando...',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              AppLocalizations.of(context)!.proUnlock,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrecoCard(IapProvider iap) {
    if (iap.isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.deepPurple.shade100, width: 2),
        ),
        child: const Column(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(height: 8),
            Text(
              'Carregando oferta...',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (iap.erroLoja != null && iap.produtoDetails == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade200, width: 2),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 32),
            const SizedBox(height: 8),
            Text(
              iap.erroLoja!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.red.shade700),
            ),
          ],
        ),
      );
    }

    final preco = iap.produtoDetails?.price ?? 'R\$ 14,90';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepPurple.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.shade700,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '🔥 OFERTA DE LANÇAMENTO',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                'De R\$ 29,90  ',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const Text(
                'Por ',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              Text(
                preco,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context)!.proPayOnce,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.deepPurple, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
        ],
      ),
    );
  }
}
