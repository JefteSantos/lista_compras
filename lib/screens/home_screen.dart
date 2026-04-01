import 'package:flutter/material.dart';
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
import 'package:lista_compras/services/ocr_service.dart';
import 'package:lista_compras/models/item.dart';

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
      builder: (context) => AlertDialog(
        title: const Text('Nova Lista'),
        content: Semantics(
          label: 'nome_lista',
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Nome da Lista',
              hintText: 'Ex: Supermercado Semanal',
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: const Text('CRIAR'),
          ),
        ],
      ),
    );

    if (nome != null && mounted) {
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
                  hintText: 'Cole o código NE2:...',
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
                    tooltip: 'Colar do teclado',
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
            child: const Text('CANCELAR', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.download, size: 18),
            label: const Text('IMPORTAR'),
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
                  const SnackBar(
                    content: Text('Código inválido ou corrompido!'),
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
            content: Text('Lista "${novaLista.nome}" importada com sucesso!'),
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
        title: const Text('Itens Escaneados'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: itensScan.length,
            itemBuilder: (context, index) {
              final item = itensScan[index];
              return ListTile(
                leading: CircleAvatar(child: Text(item.quantidade.toString())),
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
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () async {
              final controller = TextEditingController(
                text: 'Scanner ${DateTime.now().day}/${DateTime.now().month}',
              );
              final nome = await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Nome da Nova Lista'),
                  content: TextField(controller: controller, autofocus: true),
                  actions: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, controller.text),
                      child: const Text('CRIAR'),
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
            child: const Text('CRIAR LISTA'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Listas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () async {
              final result = await OCRService.scanList(fromCamera: true);
              if (result.isNotEmpty && mounted) {
                _exibirConfirmacaoOCR(context, result);
              }
            },
            tooltip: 'Escanear lista física',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _importarPorCodigo,
            tooltip: 'Importar por código',
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Relatórios',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ReportScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Configurações',
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
          tabs: const [
            Tab(text: 'Ativas', icon: Icon(Icons.shopping_cart_outlined)),
            Tab(text: 'Histórico', icon: Icon(Icons.history)),
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
        label: const Text('Nova Lista'),
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
                  ? 'Nenhuma lista ativa no momento.'
                  : 'Nenhum histórico disponível.',
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
                    '${lista.itensComprados}/${lista.totalItens} itens',
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
                  'Total estimado: ${AppUtils.formatMoney(lista.precoTotal)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
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
        lista.finalizada ? 'Concluída' : 'Em andamento',
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
    return '${date.day}/${date.month}/${date.year}';
  }
}
