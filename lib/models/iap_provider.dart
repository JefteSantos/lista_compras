import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../services/hive_service.dart';

/// ID do produto configurado no Google Play Console.
/// Deve corresponder exatamente ao ID criado em Monetizar > Produtos no app.
const String kProProductId = 'nao_esquece_pro';

class IapProvider extends ChangeNotifier {
  // ─── Constantes de Limites ───────────────────────────────────────────────
  static const int maxListasFree = 5;

  // ─── Estado ──────────────────────────────────────────────────────────────

  bool _isPro = false;
  bool _isLoading = true;
  bool _compraPendente = false;
  String? _erroLoja;
  ProductDetails? _produtoDetails;

  /// Retorna verdadeiro se o usuário tiver comprado a versão PRO.
  bool get isPro => _isPro;

  /// Verdadeiro enquanto carrega os detalhes do produto da loja.
  bool get isLoading => _isLoading;

  /// Verdadeiro quando há uma compra em processamento.
  bool get compraPendente => _compraPendente;

  /// Mensagem de erro caso a loja não esteja disponível ou o produto não seja encontrado.
  String? get erroLoja => _erroLoja;

  /// Detalhes do produto carregados da loja (preço, título, etc.).
  ProductDetails? get produtoDetails => _produtoDetails;

  // ─── Controle de Degustação (Trial Gratuito de 1 Uso) ─────────────────────

  /// Quantidade de scans OCR já realizados no plano gratuito.
  int get ocrUsosCount =>
      HiveService.obterConfiguracao<int>('free_ocr_usos') ?? 0;

  /// Quantidade de exportações (PDF/Excel/CSV) já realizadas no plano gratuito.
  int get exportUsosCount =>
      HiveService.obterConfiguracao<int>('free_export_usos') ?? 0;

  /// Verifica se o usuário pode usar o OCR (ilimitado se PRO, ou 1 uso grátis).
  bool podeUsarOcr() => _isPro || ocrUsosCount < 1;

  /// Verifica se o usuário pode exportar (ilimitado se PRO, ou 1 uso grátis).
  bool podeUsarExport() => _isPro || exportUsosCount < 1;

  /// Verifica se o usuário pode criar uma nova lista (máx 5 no Free, ilimitado no PRO).
  bool podeCriarLista(int totalListas) => _isPro || totalListas < maxListasFree;

  /// Registra o uso do teste gratuito do Scanner OCR.
  Future<void> registrarUsoOcr() async {
    if (_isPro) return;
    final novosUsos = ocrUsosCount + 1;
    await HiveService.salvarConfiguracao('free_ocr_usos', novosUsos);
    notifyListeners();
  }

  /// Registra o uso do teste gratuito de exportação.
  Future<void> registrarUsoExport() async {
    if (_isPro) return;
    final novosUsos = exportUsosCount + 1;
    await HiveService.salvarConfiguracao('free_export_usos', novosUsos);
    notifyListeners();
  }

  // ─── Internos ────────────────────────────────────────────────────────────

  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  // ─── Inicialização ───────────────────────────────────────────────────────

  IapProvider() {
    _init();
  }

  Future<void> _init() async {
    // 1. Carrega o cache local (Hive) para exibir algo enquanto consulta a loja
    _isPro = HiveService.obterConfiguracao<bool>('usuario_pro') ?? false;

    // 2. Na Web, não há loja — usamos apenas o cache local
    if (kIsWeb) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    // 3. Assina o stream de compras ANTES de qualquer query
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdated,
      onDone: () => _subscription.cancel(),
      onError: (error) {
        debugPrint('[IAP] Erro no purchaseStream: $error');
      },
    );

    // 4. Verifica se a loja está disponível
    final bool available = await _iap.isAvailable();
    if (!available) {
      _erroLoja = 'Loja indisponível neste dispositivo.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    // 5. Carrega os detalhes do produto
    await _carregarProduto();
  }

  Future<void> _carregarProduto() async {
    _isLoading = true;
    _erroLoja = null;
    notifyListeners();

    try {
      final ProductDetailsResponse response = await _iap.queryProductDetails(
        <String>{kProProductId},
      );

      if (response.error != null) {
        _erroLoja = 'Erro ao buscar produto: ${response.error!.message}';
        debugPrint('[IAP] ProductDetailsResponse error: ${response.error}');
      } else if (response.productDetails.isEmpty) {
        _erroLoja =
            'Produto "$kProProductId" não encontrado na loja. '
            'Verifique se ele foi criado e ativado no Google Play Console.';
        debugPrint('[IAP] Produto não encontrado: $kProProductId');
      } else {
        _produtoDetails = response.productDetails.first;
        debugPrint(
          '[IAP] Produto carregado: ${_produtoDetails!.title} — ${_produtoDetails!.price}',
        );
      }

      // Também verifica se há compras pendentes não finalizadas
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('[IAP] IDs não encontrados: ${response.notFoundIDs}');
      }
    } catch (e) {
      _erroLoja = 'Falha ao consultar a loja: $e';
      debugPrint('[IAP] Exceção em _carregarProduto: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ─── Comprar PRO ─────────────────────────────────────────────────────────

  /// Inicia o fluxo de compra real com o Google Play.
  Future<bool> comprarPro() async {
    if (_produtoDetails == null) {
      _erroLoja = 'Produto não disponível. Tente novamente mais tarde.';
      notifyListeners();
      return false;
    }

    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: _produtoDetails!,
    );

    try {
      final bool started = await _iap.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
      if (!started) {
        _erroLoja = 'Não foi possível iniciar a compra.';
        notifyListeners();
      }
      return started;
    } catch (e) {
      _erroLoja = 'Erro ao iniciar compra: $e';
      notifyListeners();
      debugPrint('[IAP] Erro em comprarPro: $e');
      return false;
    }
  }

  // ─── Restaurar Compras ───────────────────────────────────────────────────

  /// Restaura compras anteriores consultando a loja.
  Future<void> restaurarCompras() async {
    try {
      await _iap.restorePurchases();
    } catch (e) {
      _erroLoja = 'Erro ao restaurar compras: $e';
      notifyListeners();
      debugPrint('[IAP] Erro em restaurarCompras: $e');
    }
  }

  // ─── Listener de Compras ─────────────────────────────────────────────────

  void _onPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchase in purchaseDetailsList) {
      if (purchase.productID != kProProductId) continue;

      switch (purchase.status) {
        case PurchaseStatus.pending:
          _compraPendente = true;
          notifyListeners();
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _onCompraConfirmada(purchase);
          break;

        case PurchaseStatus.error:
          _compraPendente = false;
          _erroLoja = purchase.error?.message ?? 'Erro desconhecido na compra.';
          notifyListeners();
          debugPrint('[IAP] Erro de compra: ${purchase.error}');
          // Sempre completar a transação, mesmo em erro
          if (purchase.pendingCompletePurchase) {
            _iap.completePurchase(purchase);
          }
          break;

        case PurchaseStatus.canceled:
          _compraPendente = false;
          notifyListeners();
          // Sempre completar a transação
          if (purchase.pendingCompletePurchase) {
            _iap.completePurchase(purchase);
          }
          break;
      }
    }
  }

  Future<void> _onCompraConfirmada(PurchaseDetails purchase) async {
    // Marca como PRO localmente
    _isPro = true;
    _compraPendente = false;
    _erroLoja = null;

    // Persiste no Hive como cache
    await HiveService.salvarConfiguracao('usuario_pro', true);

    notifyListeners();

    // IMPORTANTE: Sempre completar a transação para evitar reembolso automático
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }

    debugPrint('[IAP] ✅ Compra confirmada! Usuário agora é PRO.');
  }

  // ─── Dispose ─────────────────────────────────────────────────────────────

  @override
  void dispose() {
    if (!kIsWeb) {
      _subscription.cancel();
    }
    super.dispose();
  }
}
