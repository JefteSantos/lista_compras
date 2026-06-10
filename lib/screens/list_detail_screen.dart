import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lista_compras/models/listas_provider.dart';
import 'package:lista_compras/models/lista_compras.dart';
import 'package:lista_compras/models/item.dart';
import 'package:lista_compras/models/categorias_provider.dart';
import 'package:lista_compras/screens/edit_item_screen.dart';
import 'package:lista_compras/screens/confirmation_dialog.dart';
import 'package:flutter/services.dart';
import 'package:lista_compras/utils/app_utils.dart';
import 'package:lista_compras/services/share_code_service.dart';
import 'package:lista_compras/services/hive_service.dart';
import 'package:lista_compras/l10n/generated/app_localizations.dart';

class ListDetailScreen extends StatefulWidget {
  final String listaId;

  const ListDetailScreen({super.key, required this.listaId});

  @override
  State<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> {
  bool _agruparPorCategoria = false;

  @override
  void initState() {
    super.initState();
    _agruparPorCategoria =
        HiveService.obterConfiguracao<bool>('agrupar_por_categoria') ?? false;
  }

  void _gerarCodigo(BuildContext context, ListaCompras lista) {
    String codigo;
    try {
      codigo = ShareCodeService.encodeList(lista);
    } on ShareCodeOversizedException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro inesperado ao gerar código.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.qr_code, color: Colors.deepPurple),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.shareCode),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Compartilhe este código com alguém que tenha o app. '
              'Ele poderá importar a lista "${lista.nome}" completamente.',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SelectableText(
                codigo,
                style: const TextStyle(
                  fontSize: 10,
                  fontFamily: 'monospace',
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(ctx)!.close),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.copy),
            label: Text(AppLocalizations.of(ctx)!.copy),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: codigo));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Código copiado! Cole no WhatsApp, SMS ou email.',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  void _editarNomeLista(BuildContext context, ListaCompras lista) async {
    final controller = TextEditingController(text: lista.nome);

    final String? novoNome = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.editListName),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.name),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text(AppLocalizations.of(context)!.cancel.toUpperCase()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );

    if (novoNome != null && novoNome.isNotEmpty && novoNome != lista.nome) {
      lista.nome = novoNome;
      if (context.mounted) {
        Provider.of<ListasProvider>(
          context,
          listen: false,
        ).atualizarLista(lista);
      }
    }
  }

  void _adicionarOuEditarItem(
    BuildContext context,
    ListaCompras lista, {
    Item? item,
  }) async {
    final novoItem = await Navigator.of(context).push<Item>(
      MaterialPageRoute(
        builder: (context) => EditItemScreen(item: item, listaId: lista.id),
      ),
    );

    if (novoItem != null && context.mounted) {
      final provider = Provider.of<ListasProvider>(context, listen: false);
      if (item == null) {
        provider.adicionarItem(lista, novoItem);
      } else {
        provider.atualizarItem(lista, novoItem);
      }
    }
  }

  void _copiarParaAreaTransferencia(ListaCompras lista) {
    final buffer = StringBuffer();
    buffer.writeln('🛒 *${lista.nome}*');

    final itensPendentes = lista.itens.where((i) => !i.comprado).toList();
    final itensComprados = lista.itens.where((i) => i.comprado).toList();

    if (itensPendentes.isNotEmpty) {
      buffer.writeln('\n⬜ *Falta Comprar:*');
      for (var item in itensPendentes) {
        final preco = item.preco != null
            ? ' (${AppUtils.formatMoney(item.preco!)})'
            : '';
        buffer.writeln('  • ${AppUtils.formatQuantity(item.quantidade)}x ${item.nome}$preco');
      }
    }

    if (itensComprados.isNotEmpty) {
      buffer.writeln('\n✅ *Já Peguei:*');
      for (var item in itensComprados) {
        final preco = item.preco != null
            ? ' - ${AppUtils.formatMoney(item.preco!)}${item.quantidade > 1 ? ' (total: ${AppUtils.formatMoney(item.precoTotal)})' : ''}'
            : '';
        buffer.writeln('  • ${AppUtils.formatQuantity(item.quantidade)}x ${item.nome}$preco');
      }
    }

    final totalFaltando = lista.precoTotal - lista.precoComprado;

    buffer.writeln('\n📊 *Resumo:*');
    if (lista.precoComprado > 0) {
      buffer.writeln(
        '✅ Carrinho: ${AppUtils.formatMoney(lista.precoComprado)}',
      );
    }
    if (totalFaltando > 0) {
      buffer.writeln('⬜ Falta: ${AppUtils.formatMoney(totalFaltando)}');
    }
    buffer.writeln('💰 *Total: ${AppUtils.formatMoney(lista.precoTotal)}*');

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Lista copiada com sucesso! Pronta para colar no WhatsApp.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ListasProvider>(
      builder: (context, provider, child) {
        final lista = provider.getListaPorId(widget.listaId);

        if (lista == null) {
          return Scaffold(
            appBar: AppBar(title: Text(AppLocalizations.of(context)!.error)),
            body: Center(child: Text(AppLocalizations.of(context)!.listNotFound)),
          );
        }

        // Ordenar itens: Pendentes primeiro
        final itensOrdenados = [...lista.itens];
        itensOrdenados.sort((a, b) {
          if (a.comprado == b.comprado) {
            return 0;
          }
          return a.comprado ? 1 : -1;
        });

        return Scaffold(
          appBar: AppBar(
            title: GestureDetector(
              onTap: () => _editarNomeLista(context, lista),
              child: Row(
                children: [
                  Expanded(
                    child: Text(lista.nome, overflow: TextOverflow.ellipsis),
                  ),
                  const Icon(Icons.edit, size: 16),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _agruparPorCategoria ? Icons.filter_list_off : Icons.filter_list,
                ),
                onPressed: () {
                  setState(() => _agruparPorCategoria = !_agruparPorCategoria);
                  HiveService.salvarConfiguracao(
                    'agrupar_por_categoria',
                    _agruparPorCategoria,
                  );
                },
                tooltip: _agruparPorCategoria
                    ? AppLocalizations.of(context)!.ungroupItems
                    : AppLocalizations.of(context)!.groupByCategory,
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _copiarParaAreaTransferencia(lista),
                tooltip: AppLocalizations.of(context)!.copyList,
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'gerar_codigo') {
                    _gerarCodigo(context, lista);
                  } else if (value == 'excluir') {
                    final confirmed = await showGenericConfirmationDialog(
                      context,
                      title: AppLocalizations.of(context)!.deleteList,
                      content: AppLocalizations.of(context)!.deleteListConfirm,
                      confirmColor: Colors.red,
                      confirmText: AppLocalizations.of(context)!.deletePermanently,
                    );
                    if (confirmed && context.mounted) {
                      await provider.removerLista(lista.id);
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    }
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'gerar_codigo',
                    child: Row(
                      children: [
                        const Icon(Icons.qr_code, color: Colors.deepPurple),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.of(context)!.generateShareCode),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'excluir',
                    child: Row(
                      children: [
                        const Icon(Icons.delete, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.deleteList,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              _buildHeaderSummary(lista),
              Expanded(
                child: itensOrdenados.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.list_alt,
                              size: 60,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              AppLocalizations.of(context)!.emptyListAdd,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : _agruparPorCategoria
                        ? _buildGroupedList(itensOrdenados, provider, lista)
                        : ListView.separated(
                            padding: const EdgeInsets.only(bottom: 100),
                            itemCount: itensOrdenados.length,
                            separatorBuilder: (_, i) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = itensOrdenados[index];
                              return _buildItemTile(context, provider, lista, item);
                            },
                          ),
              ),
            ],
          ),
          bottomNavigationBar: BottomAppBar(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Total: ${AppUtils.formatMoney(lista.precoTotal)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (lista.finalizada) {
                        // Reabrir: apenas atualiza o estado da lista
                        lista.reabrirLista();
                        await provider.atualizarLista(lista);
                      } else {
                        // Finalizar: usa o método do provider que também
                        // salva o histórico de preços dos itens comprados
                        await provider.finalizarLista(lista);
                      }
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    icon: Icon(lista.finalizada ? Icons.replay : Icons.check),
                    label: Text(
                      lista.finalizada ? AppLocalizations.of(context)!.reopenList : AppLocalizations.of(context)!.finishPurchase,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lista.finalizada
                          ? Colors.orange
                          : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            key: const Key('fabNovoItem'),
            onPressed: () => _adicionarOuEditarItem(context, lista),
            child: const Icon(Icons.add),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }

  Widget _buildHeaderSummary(ListaCompras lista) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            label: AppLocalizations.of(context)!.items,
            value: '${lista.itensComprados}/${lista.totalItens}',
            icon: Icons.checklist,
            color: Colors.blue,
          ),
          _buildSummaryItem(
            label: AppLocalizations.of(context)!.cart,
            value: AppUtils.formatMoney(lista.precoComprado),
            icon: Icons.shopping_cart,
            color: Colors.green,
          ),
          _buildSummaryItem(
            label: AppLocalizations.of(context)!.remaining,
            value: AppUtils.formatMoney(lista.precoTotal - lista.precoComprado),
            icon: Icons.remove_shopping_cart,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildItemTile(
    BuildContext context,
    ListasProvider provider,
    ListaCompras lista,
    Item item,
  ) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showGenericConfirmationDialog(
          context,
          title: 'Excluir',
          content: 'Remover "${item.nome}"?',
          confirmColor: Colors.red,
        );
      },
      onDismissed: (direction) {
        provider.removerItem(lista, item);
      },
      child: ListTile(
        leading: Checkbox(
          value: item.comprado,
          onChanged: (val) {
            HapticFeedback.lightImpact();
            provider.alternarStatusItem(lista, item);
          },
          activeColor: Colors.green,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        title: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            decoration: item.comprado ? TextDecoration.lineThrough : null,
            color: item.comprado ? Colors.grey : Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          child: item.categoria != null
              ? Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  children: [
                    Text(item.nome),
                    _buildCategoriaTag(item.categoria!, comprado: item.comprado),
                  ],
                )
              : Text(item.nome),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppUtils.formatQuantity(item.quantidade)} un${item.preco != null ? ' x ${AppUtils.formatMoney(item.preco!)}' : ''}',
              style: TextStyle(
                color: item.comprado
                    ? Colors.grey.shade400
                    : Colors.grey.shade700,
              ),
            ),
            if (item.observacoes != null && item.observacoes!.isNotEmpty)
              Text(
                'Obs: ${item.observacoes}',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade500,
                ),
              ),
          ],
        ),
        trailing: item.precoTotal > 0
            ? Text(
                AppUtils.formatMoney(item.precoTotal),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: item.comprado ? Colors.grey : Colors.black,
                ),
              )
            : null,
        onTap: () => _adicionarOuEditarItem(context, lista, item: item),
      ),
    );
  }

  Widget _buildCategoriaTag(String nome, {bool comprado = false}) {
    final cor = corDaCategoria(nome);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: comprado ? cor.withValues(alpha: 0.35) : cor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        nome,
        style: TextStyle(
          color: comprado ? Colors.grey.shade600 : Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  /// Constrói a lista agrupada por categoria com headers visuais.
  Widget _buildGroupedList(
    List<Item> itens,
    ListasProvider provider,
    ListaCompras lista,
  ) {
    // Agrupa por categoria
    final Map<String, List<Item>> grupos = {};
    for (final item in itens) {
      final cat = item.categoria ?? AppLocalizations.of(context)!.noCategory;
      grupos.putIfAbsent(cat, () => []).add(item);
    }

    // Ordena: categorias com nome primeiro, "Sem Categoria" por último
    final categoriasOrdenadas = grupos.keys.toList()
      ..sort((a, b) {
        if (a == AppLocalizations.of(context)!.noCategory) return 1;
        if (b == AppLocalizations.of(context)!.noCategory) return -1;
        return a.compareTo(b);
      });

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: categoriasOrdenadas.length,
      itemBuilder: (context, groupIndex) {
        final categoria = categoriasOrdenadas[groupIndex];
        final itensDoGrupo = grupos[categoria]!;
        final cor = categoria == AppLocalizations.of(context)!.noCategory
            ? Colors.grey
            : corDaCategoria(categoria);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header da categoria
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: cor.withValues(alpha: 0.12),
                border: Border(
                  left: BorderSide(color: cor, width: 4),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: cor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    categoria,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: cor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${itensDoGrupo.where((i) => i.comprado).length}/${itensDoGrupo.length}',
                    style: TextStyle(fontSize: 11, color: cor),
                  ),
                ],
              ),
            ),
            // Itens do grupo
            ...itensDoGrupo.map(
              (item) => Column(
                children: [
                  _buildItemTile(context, provider, lista, item),
                  const Divider(height: 1),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
