import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/services.dart';
import '../models/lista_compras.dart';
import '../models/item.dart';
import '../services/hive_service.dart';
import '../screens/edit_item_screen.dart';
import '../screens/confirmation_dialog.dart';

class HiveExample extends StatefulWidget {
  const HiveExample({super.key});

  @override
  State<HiveExample> createState() => _HiveExampleState();
}

enum FiltroLista { ativas, finalizadas, todas }

class _HiveExampleState extends State<HiveExample> {
  List<ListaCompras> _listas = [];
  FiltroLista _filtroSelecionado =
      FiltroLista.ativas; // Começa mostrando ativas

  @override
  void initState() {
    super.initState();
    _carregarListas();
  }

  void _carregarListas() {
    final todas = HiveService.obterTodasListasCompras();

    setState(() {
      switch (_filtroSelecionado) {
        case FiltroLista.ativas:
          _listas = todas.where((l) => !l.finalizada).toList();
          break;
        case FiltroLista.finalizadas:
          _listas = todas.where((l) => l.finalizada).toList();
          break;
        case FiltroLista.todas:
          _listas = todas;
          break;
      }
    });
  }

  void _alterarFiltro(FiltroLista filtro) {
    setState(() {
      _filtroSelecionado = filtro;
      _carregarListas();
    });
  }

  void _criarListaExemplo() {
    final lista = ListaCompras(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nome: 'Nova Lista de Compras ${_listas.length + 1}',
      descricao: null,
      dataCriacao: DateTime.now(),
    );

    HiveService.salvarListaCompras(lista);
    _carregarListas();
  }

  void _alternarStatusItem(ListaCompras lista, Item item) {
    final itemAtualizado = item.copyWith(
      comprado: !item.comprado,
      dataCompra: !item.comprado ? DateTime.now() : null,
    );

    final index = lista.itens.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      lista.itens[index] = itemAtualizado;
      HiveService.salvarListaCompras(lista);
      _carregarListas();
    }
  }

  void _editarItem(ListaCompras lista, Item? item) async {
    final resultado = await Navigator.of(context).push<Item>(
      MaterialPageRoute(
        builder: (context) => EditItemScreen(item: item, listaId: lista.id),
      ),
    );

    if (resultado != null) {
      if (item == null) {
        lista.itens.add(resultado);
      } else {
        final index = lista.itens.indexWhere((i) => i.id == item.id);
        if (index != -1) {
          lista.itens[index] = resultado;
        }
      }

      HiveService.salvarListaCompras(lista);
      _carregarListas();
    }
  }

  void _excluirItem(ListaCompras lista, Item item) async {
    final bool deleted = await handleDeleteItem(item.nome, item.id);

    if (deleted) {
      lista.itens.removeWhere((i) => i.id == item.id);
      HiveService.salvarListaCompras(lista);
      _carregarListas();
    }
  }

  void _excluirLista(ListaCompras lista) async {
    // Recebe o status da exclusão (true se foi excluída, false se cancelada)
    final bool deleted = await handleDeleteList(lista.nome, lista.id);

    // Só recarrega as listas se o item foi realmente deletado.
    if (deleted) {
      _carregarListas();
    }
  }

  void _editarNomeLista(ListaCompras lista) async {
    final controller = TextEditingController(text: lista.nome);

    final String? novoNome = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar nome da lista'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nome'),
          autofocus: true,
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

    if (!mounted) return;

    if (novoNome != null && novoNome.isNotEmpty && novoNome != lista.nome) {
      lista.nome = novoNome;
      HiveService.salvarListaCompras(lista);
      _carregarListas();
    }
  }

  Future<bool> handleDeleteList(String listName, String listId) async {
    // Chama o diálogo — usamos o State.context aqui.
    final bool confirmed = await showGenericConfirmationDialog(
      context,
      title: 'Excluir Lista Permanentemente',
      content:
          'Tem certeza que deseja excluir a lista "$listName"? Esta ação não pode ser desfeita.',
      confirmText: 'EXCLUIR',
      confirmColor: Colors.red,
    );

    // Protege o uso do State.context após await
    if (!mounted) return false;

    if (confirmed) {
      HiveService.excluirListaCompras(listId);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lista "$listName" excluída.')));
      return true;
    } else {
      return false;
    }
  }

  Future<bool> handleDeleteItem(String itemName, String itemId) async {
    final bool confirmed = await showGenericConfirmationDialog(
      context,
      title: 'Excluir item Permanentemente',
      content:
          'Tem certeza que deseja excluir o item "$itemName"? Esta ação não pode ser desfeita.',
      confirmText: 'EXCLUIR',
      confirmColor: Colors.red,
    );

    // Protege o uso do State.context após await
    if (!mounted) return false;

    if (confirmed) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Item "$itemName" excluído.')));
      return true;
    } else {
      return false;
    }
  }

  void _compartilharLista(ListaCompras lista) async {
    final buffer = StringBuffer();
    buffer.writeln(lista.nome);
    if (lista.descricao != null) buffer.writeln(lista.descricao);
    buffer.writeln('');

    for (final item in lista.itens) {
      final statusEmoji = item.comprado ? '✅' : '❌';
      buffer.writeln(
        '$statusEmoji - ${item.quantidade} x ${item.nome}${item.preco != null ? ' - R\$ ${item.precoTotal.toStringAsFixed(2)}' : ''}',
      );
    }

    final total = lista.precoTotal;
    final comprado = lista.precoComprado;
    final faltando = (total - comprado).clamp(0, double.infinity);

    buffer.writeln('');
    buffer.writeln('✅ - Valor comprado: R\$ ${comprado.toStringAsFixed(2)}');
    buffer.writeln('❌ - Valor faltando: R\$ ${faltando.toStringAsFixed(2)}');
    buffer.writeln('💰 - Total: R\$ ${total.toStringAsFixed(2)}');

    // obtenha info do app (nome/versão) — usa package_info_plus
    String appName = 'Lista de Compras';
    try {
      final pkg = await PackageInfo.fromPlatform();
      appName = pkg.appName.isNotEmpty ? pkg.appName : appName;
      final version = pkg.version;
      buffer.writeln('');
      buffer.writeln(
        'Compartilhado via $appName${version.isNotEmpty ? ' v$version' : ''}',
      );
    } catch (_) {
      buffer.writeln('');
      buffer.writeln('Compartilhado via $appName');
    }

    // copia para a área de transferência
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Texto copiado para a área de transferência'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Compras'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<FiltroLista>(
            icon: const Icon(Icons.filter_list),
            onSelected: _alterarFiltro,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: FiltroLista.ativas,
                child: Text('Ativas'),
              ),
              const PopupMenuItem(
                value: FiltroLista.finalizadas,
                child: Text('Finalizadas'),
              ),
              const PopupMenuItem(
                value: FiltroLista.todas,
                child: Text('Todas'),
              ),
            ],
          ),
        ],
      ),

      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.deepPurple.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '${HiveService.totalListas}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Total Listas'),
                    IconButton(
                      onPressed: () {
                        _alterarFiltro(FiltroLista.todas);
                      },
                      icon: const Icon(Icons.list),
                      tooltip: 'Mostrar todas as listas',
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '${HiveService.listasAtivas}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const Text('Listas Ativas'),
                    IconButton(
                      onPressed: () {
                        _alterarFiltro(FiltroLista.ativas);
                      },
                      icon: const Icon(Icons.shopping_cart),
                      tooltip: 'Mostrar apenas listas ativas',
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '${HiveService.listasFinalizadas}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const Text('Finalizadas'),
                    IconButton(
                      onPressed: () {
                        _alterarFiltro(FiltroLista.finalizadas);
                      },
                      icon: const Icon(Icons.check),
                      tooltip: 'Mostrar apenas listas finalizadas',
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: _listas.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhuma lista encontrada.\nToque no botão + para criar uma nova lista vazia.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _listas.length,
                    itemBuilder: (context, index) {
                      final lista = _listas[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ExpansionTile(
                          title: Text(lista.nome),
                          subtitle: Text(
                            '${lista.itensComprados}/${lista.totalItens} itens comprados - R\$ ${lista.precoTotal.toStringAsFixed(2)}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _editarNomeLista(lista),
                                tooltip: 'Editar nome da lista',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                onPressed: () => _excluirLista(lista),
                                tooltip: 'Excluir lista',
                              ),
                              Icon(
                                lista.finalizada
                                    ? Icons.check_circle
                                    : Icons.shopping_cart,
                                color: lista.finalizada
                                    ? Colors.green
                                    : Colors.blue,
                              ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  if (lista.descricao != null)
                                    Text(
                                      lista.descricao!,
                                      style: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  if (lista.itens.isEmpty)
                                    const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text(
                                        'Esta lista está vazia.\nToque no botão + para adicionar itens.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    )
                                  else
                                    // Ordena itens: não comprados primeiro, comprados por último
                                    ...(() {
                                      final sorted = [...lista.itens];
                                      sorted.sort((a, b) {
                                        if (a.comprado == b.comprado) return 0;
                                        return a.comprado ? 1 : -1;
                                      });
                                      return sorted
                                          .map(
                                            (item) => ListTile(
                                              leading: Text(
                                                item.comprado ? '✅' : '❌',
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                              title: Text(
                                                item.nome,
                                                style: TextStyle(
                                                  decoration: item.comprado
                                                      ? TextDecoration
                                                            .lineThrough
                                                      : TextDecoration.none,
                                                  color: item.comprado
                                                      ? Colors.grey
                                                      : Colors.black,
                                                ),
                                              ),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Qtd: ${item.quantidade}${item.preco != null ? ' - R\$ ${item.precoTotal.toStringAsFixed(2)}' : ''}',
                                                  ),
                                                  if (item.observacoes !=
                                                          null &&
                                                      item
                                                          .observacoes!
                                                          .isNotEmpty)
                                                    Text(
                                                      'Obs: ${item.observacoes}',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors
                                                            .grey
                                                            .shade600,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.edit,
                                                      size: 20,
                                                    ),
                                                    onPressed: () =>
                                                        _editarItem(
                                                          lista,
                                                          item,
                                                        ),
                                                    tooltip: 'Editar item',
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.delete,
                                                      size: 20,
                                                    ),
                                                    onPressed: () =>
                                                        _excluirItem(
                                                          lista,
                                                          item,
                                                        ),
                                                    tooltip: 'Excluir item',
                                                  ),
                                                  Checkbox(
                                                    value: item.comprado,
                                                    onChanged: (value) =>
                                                        _alternarStatusItem(
                                                          lista,
                                                          item,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                              onTap: () => _alternarStatusItem(
                                                lista,
                                                item,
                                              ),
                                            ),
                                          )
                                          .toList();
                                    }()),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (lista.precoTotal > 0)
                                            Text(
                                              'Total: R\$ ${lista.precoTotal.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          else
                                            const Text(
                                              'Preços não informados',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                              ),
                                            ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.add),
                                            onPressed: () =>
                                                _editarItem(lista, null),
                                            tooltip: 'Adicionar item',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.share),
                                            onPressed: () =>
                                                _compartilharLista(lista),
                                            tooltip: 'Compartilhar lista',
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              if (lista.finalizada) {
                                                lista.finalizada = false;
                                                lista.dataFinalizacao = null;
                                              } else {
                                                lista.finalizada = true;
                                                lista.dataFinalizacao =
                                                    DateTime.now();
                                              }
                                              HiveService.salvarListaCompras(
                                                lista,
                                              );
                                              _carregarListas();
                                            },
                                            child: Text(
                                              lista.finalizada
                                                  ? 'Reabrir'
                                                  : 'Finalizar',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _criarListaExemplo,
        tooltip: 'Criar Nova Lista',
        child: const Icon(Icons.add),
      ),
    );
  }
}
