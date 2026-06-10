import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:lista_compras/models/listas_provider.dart';
import 'package:lista_compras/models/lista_compras.dart';
import 'package:lista_compras/screens/list_detail_screen.dart';
import 'package:lista_compras/screens/report_screen.dart';
import 'package:lista_compras/screens/settings_screen.dart';
import 'package:lista_compras/services/share_code_service.dart';
import 'package:lista_compras/utils/app_utils.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:lista_compras/services/text_parser_service.dart';
import 'package:lista_compras/services/ocr_service.dart';
import 'package:lista_compras/models/item.dart';
import 'package:lista_compras/models/iap_provider.dart';
import 'package:lista_compras/screens/paywall_screen.dart';
import 'package:lista_compras/l10n/generated/app_localizations.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _criarNovaLista() async {
    final controller = TextEditingController();
    final String? nome = await showDialog<String>(
      context: context,
      builder: (context) {
        final l = AppLocalizations.of(context)!;
        return AlertDialog(
        title: Text(l.newList),
        content: Semantics(
          label: 'nome_lista',
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: l.listName,
              hintText: 'Ex: Supermercado Semanal',
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _importarListaTexto();
            },
            child: const Text('COLAR TEXTO'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.cancel.toUpperCase()),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: Text(l.create),
          ),
        ],
      );
      },
    );

    if (nome != null && mounted) {
      HapticFeedback.selectionClick();
      final novaLista = ListaCompras(
        id: const Uuid().v4(), // Bug 9 fix: UUID evita colisão de IDs
        nome: nome,
        dataCriacao: DateTime.now(),
      );

      await Provider.of<ListasProvider>(
        context,
        listen: false,
      ).adicionarLista(novaLista);

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ListDetailScreen(listaId: novaLista.id),
          ),
        );
      }
    }
  }

  void _importarListaTexto() async {
    final controller = TextEditingController();
    final String? texto = await showDialog<String>(
      context: context,
      builder: (context) {
        final l = AppLocalizations.of(context)!;
        return AlertDialog(
          title: const Text('Importar de Texto'),
          content: TextField(
            controller: controller,
            maxLines: 8,
            decoration: const InputDecoration(
              hintText: 'Cole aqui o texto da lista exportada do WhatsApp...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.cancel.toUpperCase()),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  Navigator.pop(context, controller.text.trim());
                }
              },
              child: const Text('IMPORTAR'),
            ),
          ],
        );
      },
    );

    if (texto != null && mounted) {
      final novaLista = TextParserService.parseText(texto);
      if (novaLista != null) {
        final listaComId = novaLista.copyWith(id: const Uuid().v4());
        await Provider.of<ListasProvider>(context, listen: false).adicionarLista(listaComId);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.importSuccess), backgroundColor: Colors.green),
          );
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ListDetailScreen(listaId: listaComId.id),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.importError), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  void _importarPorCodigo() async {
    final controller = TextEditingController();
    final ListaCompras? lista = await showDialog<ListaCompras>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.qr_code_2, color: Colors.deepPurple),
            ),
            const SizedBox(width: 12),
            const Text('Importar Lista', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cole abaixo o código da lista que você recebeu:',
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Semantics(
              label: 'import_codigo_field',
              child: TextField(
                controller: controller,
                maxLines: 4,
                autofocus: true,
                style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.importCodeHint,
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  prefixIcon: const Icon(Icons.qr_code, size: 18),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.content_paste, size: 20),
                    onPressed: () async {
                      final data = await Clipboard.getData('text/plain');
                      if (data?.text != null) {
                        controller.text = data!.text!;
                      }
                    },
                    tooltip: AppLocalizations.of(context)!.pasteFromClipboard,
                  ),
                ),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(ctx)!.cancel.toUpperCase(), style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.download, size: 18),
            label: Text(AppLocalizations.of(ctx)!.import.toUpperCase()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final lista = ShareCodeService.decodeList(controller.text);
              if (lista != null) {
                Navigator.pop(ctx, lista);
              } else {
                ScaffoldMessenger.of(ctx).showSnackBar(
                   SnackBar(
                     content: Text(AppLocalizations.of(ctx)!.importError),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );

    if (lista != null && mounted) {
      // Gera novo ID para evitar conflito com lista original
      final novaLista = lista.copyWith(id: const Uuid().v4());
      await Provider.of<ListasProvider>(
        context,
        listen: false,
      ).adicionarLista(novaLista);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.importSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _exibirConfirmacaoOCR(BuildContext context, List<Item> itensScan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.ocrConfirmTitle),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: itensScan.length,
            itemBuilder: (context, index) {
              final item = itensScan[index];
              return ListTile(
                leading: CircleAvatar(child: Text(AppUtils.formatQuantity(item.quantidade))),
                title: Text(item.nome),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    (ctx as Element).markNeedsBuild();
                    itensScan.removeAt(index);
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(ctx)!.cancel.toUpperCase()),
          ),
          ElevatedButton(
            onPressed: () async {
              final controller = TextEditingController(
                text: 'Scanner ${DateTime.now().day}/${DateTime.now().month}',
              );
              final nome = await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(AppLocalizations.of(context)!.newList),
                  content: TextField(controller: controller, autofocus: true),
                  actions: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, controller.text),
                      child: Text(AppLocalizations.of(context)!.create),
                    ),
                  ],
                ),
              );

              if (nome != null && context.mounted) {
                final novaLista = ListaCompras(
                  id: const Uuid().v4(),
                  nome: nome,
                  dataCriacao: DateTime.now(),
                  itens: itensScan,
                );
                await Provider.of<ListasProvider>(context, listen: false)
                    .adicionarLista(novaLista);
                if (context.mounted) {
                  Navigator.pop(ctx);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ListDetailScreen(listaId: novaLista.id),
                    ),
                  );
                }
              }
            },
            child: Text(AppLocalizations.of(ctx)!.ocrCreateList.toUpperCase()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myLists),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () async {
              final isPro = Provider.of<IapProvider>(context, listen: false).isPro;
              if (!isPro) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PaywallScreen()),
                );
                return;
              }
              final result = await OCRService.scanList(fromCamera: true);
              if (result.isNotEmpty && context.mounted) {
                _exibirConfirmacaoOCR(context, result);
              }
            },
            tooltip: AppLocalizations.of(context)!.scanPhysicalList,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _importarPorCodigo,
            tooltip: AppLocalizations.of(context)!.importByCode,
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: AppLocalizations.of(context)!.reports,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ReportScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: AppLocalizations.of(context)!.settings,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: AppLocalizations.of(context)!.activeLists, icon: const Icon(Icons.shopping_cart_outlined)),
            Tab(text: AppLocalizations.of(context)!.finishedLists, icon: const Icon(Icons.history)),
          ],
        ),
      ),
      body: Consumer<ListasProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildListasView(provider.listasAtivas, isAtivas: true),
              _buildListasView(provider.listasFinalizadas, isAtivas: false),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('fabNovaLista'),
        onPressed: _criarNovaLista,
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)!.newList),
      ),
    );
  }

  Widget _buildListasView(List<ListaCompras> listas, {required bool isAtivas}) {
    if (listas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isAtivas ? Icons.remove_shopping_cart : Icons.history_toggle_off,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              isAtivas
                  ? AppLocalizations.of(context)!.emptyListTitle
                  : AppLocalizations.of(context)!.emptyFinishedTitle,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: listas.length,
      itemBuilder: (context, index) {
        final lista = listas[index];
        return _buildListaCard(lista);
      },
    );
  }

  Widget _buildListaCard(ListaCompras lista) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ListDetailScreen(listaId: lista.id),
            ),
          );
        },
        onLongPress: () => _mostrarMenuLista(lista),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      lista.nome,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_all, size: 20),
                    color: Colors.deepPurple.shade300,
                    tooltip: AppLocalizations.of(context)!.duplicateList,
                    onPressed: () => _duplicarLista(lista),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  const SizedBox(width: 4),
                  _buildStatusBadge(lista),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(lista.dataCriacao),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const Spacer(),
                  Text(
                    AppLocalizations.of(context)!.itemsCount(lista.itensComprados, lista.totalItens),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: lista.finalizada ? Colors.green : Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: lista.totalItens == 0
                    ? 0
                    : lista.itensComprados / lista.totalItens,
                backgroundColor: Colors.grey.shade200,
                color: lista.finalizada ? Colors.green : Colors.blue,
                borderRadius: BorderRadius.circular(2),
              ),
              if (lista.precoTotal > 0) ...[
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.estimatedTotal(AppUtils.formatMoney(lista.precoTotal)),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _duplicarLista(ListaCompras lista) async {
    final provider = Provider.of<ListasProvider>(context, listen: false);
    final novaLista = await provider.duplicarLista(lista);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.listCreated(novaLista.nome)),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: AppLocalizations.of(context)!.open,
            textColor: Colors.white,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ListDetailScreen(listaId: novaLista.id),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  void _mostrarMenuLista(ListaCompras lista) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                lista.nome,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.copy_all, color: Colors.deepPurple),
              title: Text(AppLocalizations.of(context)!.duplicateList),
              subtitle: Text(AppLocalizations.of(context)!.duplicateListSubtitle),
              onTap: () {
                Navigator.pop(ctx);
                _duplicarLista(lista);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text(AppLocalizations.of(context)!.deleteList, style: const TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(ctx);
                final provider = Provider.of<ListasProvider>(context, listen: false);
                await provider.removerLista(lista.id);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ListaCompras lista) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: lista.finalizada ? Colors.green.shade100 : Colors.blue.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        lista.finalizada ? AppLocalizations.of(context)!.finalized : AppLocalizations.of(context)!.inProgress,
        style: TextStyle(
          color: lista.finalizada
              ? Colors.green.shade800
              : Colors.blue.shade800,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat.yMd(Localizations.localeOf(context).toLanguageTag()).format(date);
  }
}
