import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lista_compras/models/listas_provider.dart';
import 'package:lista_compras/models/lista_compras.dart';
import 'package:lista_compras/models/item.dart';
import 'package:lista_compras/screens/edit_item_screen.dart';
import 'package:lista_compras/screens/confirmation_dialog.dart';
import 'package:flutter/services.dart';
import 'package:lista_compras/utils/app_utils.dart';

class ListDetailScreen extends StatefulWidget {
  final String listaId;

  const ListDetailScreen({super.key, required this.listaId});

  @override
  State<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> {
  void _editarNomeLista(BuildContext context, ListaCompras lista) async {
    final controller = TextEditingController(text: lista.nome);

    final String? novoNome = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar nome da lista'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nome'),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('SALVAR'),
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
        buffer.writeln('  • ${item.quantidade}x ${item.nome}$preco');
      }
    }

    if (itensComprados.isNotEmpty) {
      buffer.writeln('\n✅ *Já Peguei:*');
      for (var item in itensComprados) {
        buffer.writeln('  • ${item.quantidade}x ${item.nome}');
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
            appBar: AppBar(title: const Text('Erro')),
            body: const Center(child: Text('Lista não encontrada.')),
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
                icon: const Icon(Icons.share),
                onPressed: () => _copiarParaAreaTransferencia(lista),
                tooltip: 'Copiar lista',
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'excluir') {
                    final confirmed = await showGenericConfirmationDialog(
                      context,
                      title: 'Excluir Lista',
                      content: 'Tem certeza? Isso apagará todos os itens.',
                      confirmColor: Colors.red,
                      confirmText: 'EXCLUIR PERMANENTEMENTE',
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
                  const PopupMenuItem(
                    value: 'excluir',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          'Excluir Lista',
                          style: TextStyle(color: Colors.red),
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
                            const Text(
                              'Lista vazia. Adicione itens!',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 80),
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
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ${AppUtils.formatMoney(lista.precoTotal)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      lista.finalizada = !lista.finalizada;
                      if (lista.finalizada) {
                        lista.dataFinalizacao = DateTime.now();
                      } else {
                        lista.dataFinalizacao = null;
                      }
                      provider.atualizarLista(lista);
                      Navigator.pop(
                        context,
                      ); // Volta pra home pois a lista mudou de tab (provavelmente)
                    },
                    icon: Icon(lista.finalizada ? Icons.replay : Icons.check),
                    label: Text(
                      lista.finalizada ? 'Reabrir Lista' : 'Finalizar Compra',
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
          floatingActionButtonLocation:
              FloatingActionButtonLocation.endContained,
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
            label: 'Itens',
            value: '${lista.itensComprados}/${lista.totalItens}',
            icon: Icons.checklist,
            color: Colors.blue,
          ),
          _buildSummaryItem(
            label: 'Carrinho',
            value: AppUtils.formatMoney(lista.precoComprado),
            icon: Icons.shopping_cart,
            color: Colors.green,
          ),
          _buildSummaryItem(
            label: 'Faltam',
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
          onChanged: (val) => provider.alternarStatusItem(lista, item),
          activeColor: Colors.green,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        title: Text(
          item.nome,
          style: TextStyle(
            decoration: item.comprado ? TextDecoration.lineThrough : null,
            color: item.comprado ? Colors.grey : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${item.quantidade} un${item.preco != null ? ' x ${AppUtils.formatMoney(item.preco!)}' : ''}',
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
}
