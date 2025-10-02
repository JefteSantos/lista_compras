import 'package:flutter/material.dart';
import '../models/lista_compras.dart';
import '../models/item.dart';
import '../services/hive_service.dart';
import '../services/share_service.dart';
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
    final bool deleted = await handleDeleteItem(context, item.nome, item.id);

    if (deleted) {
      lista.itens.removeWhere((i) => i.id == item.id);
      HiveService.salvarListaCompras(lista);
      _carregarListas();
    }
  }

  void _compartilharLista(ListaCompras lista) async {
    try {
      await ShareService.compartilharLista(lista);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lista copiada para a área de transferência!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao compartilhar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editarNomeLista(ListaCompras lista) async {
    final nomeController = TextEditingController(text: lista.nome);
    final descController = TextEditingController(text: lista.descricao ?? '');

    final resultado = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Lista'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome da lista',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Descrição da lista',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop({
              'nome': nomeController.text.trim(),
              'descricao': descController.text.trim(),
            }),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (resultado != null && resultado['nome']?.isNotEmpty == true) {
      lista.nome = resultado['nome']!;
      lista.descricao = resultado['descricao']?.isEmpty == true
          ? null
          : resultado['descricao'];
      HiveService.salvarListaCompras(lista);
      _carregarListas();
    }
  }

  void _excluirLista(ListaCompras lista) async {
    // Recebe o status da exclusão (true se foi excluída, false se cancelada)
    final bool deleted = await handleDeleteList(context, lista.nome, lista.id);

    // Só recarrega as listas se o item foi realmente deletado.
    if (deleted) {
      _carregarListas();
    }
  }

  Future<bool> handleDeleteList(
    BuildContext context,
    String listName,
    String listId,
  ) async {
    // 1. Chama o diálogo com a mensagem específica
    final bool confirmed = await showGenericConfirmationDialog(
      context,
      title: 'Excluir Lista Permanentemente',
      content:
          'Tem certeza que deseja excluir a lista "$listName"? Esta ação não pode ser desfeita.',
      confirmText: 'EXCLUIR',
      confirmColor: Colors.red, // Usa vermelho para a ação de exclusão
    );

    if (!mounted) return false;

    // 2. Trata o resultado
    if (confirmed) {
      HiveService.excluirListaCompras(listId);
      // Lógica para excluir a lista no seu banco de dados ou estado.
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lista "$listName" excluída.')));
      return true;
    } else {
      return false;
    }
  }

  Future<bool> handleDeleteItem(
    BuildContext context,
    String itemName,
    String itemId,
  ) async {
    final bool confirmed = await showGenericConfirmationDialog(
      context,
      title: 'Excluir item Permanentemente',
      content:
          'Tem certeza que deseja excluir o item "$itemName"? Esta ação não pode ser desfeita.',
      confirmText: 'EXCLUIR',
      confirmColor: Colors.red,
    );

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
                                    ...lista.itens.map(
                                      (item) => ListTile(
                                        title: Text(
                                          item.nome,
                                          style: TextStyle(
                                            decoration: item.comprado
                                                ? TextDecoration.lineThrough
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
                                            if (item.observacoes != null &&
                                                item.observacoes!.isNotEmpty)
                                              Text(
                                                'Obs: ${item.observacoes}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                  fontStyle: FontStyle.italic,
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
                                                  _editarItem(lista, item),
                                              tooltip: 'Editar item',
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                size: 20,
                                              ),
                                              onPressed: () =>
                                                  _excluirItem(lista, item),
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
                                        onTap: () =>
                                            _alternarStatusItem(lista, item),
                                      ),
                                    ),
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
