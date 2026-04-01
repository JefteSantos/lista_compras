import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'confirmation_dialog.dart';
import '../models/item.dart';
import 'package:lista_compras/models/listas_provider.dart';
import 'package:lista_compras/utils/app_utils.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class EditItemScreen extends StatefulWidget {
  final Item? item;
  final String listaId;

  const EditItemScreen({super.key, this.item, required this.listaId});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  late TextEditingController _nomeController;
  late TextEditingController _quantidadeController;
  late TextEditingController _precoController;
  late TextEditingController _observacoesController;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.item != null;

    _nomeController = TextEditingController(text: widget.item?.nome ?? '');
    _quantidadeController = TextEditingController(
      text: widget.item?.quantidade.toString() ?? '1',
    );
    _precoController = TextEditingController(
      text: widget.item?.preco != null 
          ? NumberFormat.simpleCurrency(locale: 'pt_BR', name: '').format(widget.item!.preco).trim()
          : '',
    );
    _observacoesController = TextEditingController(
      text: widget.item?.observacoes ?? '',
    );

    // Bug 5 fix: listeners para o Preview atualizar em tempo real
    _nomeController.addListener(() => setState(() {}));
    _quantidadeController.addListener(() => setState(() {}));
    _precoController.addListener(() => setState(() {}));
    _observacoesController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _quantidadeController.dispose();
    _precoController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  Future<void> _salvarItem() async {
      final listasProvider = Provider.of<ListasProvider>(context, listen: false);
      final listaDeItens = listasProvider.getListaPorId(widget.listaId)?.itens ?? [];
    
    if (_nomeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome do item é obrigatório')),
      );
      return;
    }

    // --- LÓGICA DE VALIDAÇÃO DE DUPLICIDADE (CORRIGIDA E USANDO widget.itensAtuais) ---
    final nomeDigitadoNormalizado = _nomeController.text.trim().toLowerCase();

    if (listaDeItens.any(
      (item) =>
          item.nome.trim().toLowerCase() == nomeDigitadoNormalizado &&
          item.id != widget.item?.id,
    )) {
      final confirmed = await showGenericConfirmationDialog(
        context,
        title: 'Item Repetido',
        content: 'O item "${_nomeController.text.trim()}" já está na lista. Deseja adicioná-lo/salvá-lo mesmo assim?',
        confirmText: 'Salvar Mesmo Assim',
        cancelText: 'Cancelar',
      );

      // Proteção contra BuildContext
      if (!mounted) return; 

      if (!confirmed) {
        return; 
      }
    }
    // ----------------------------------------------------------------------------------

    final quantidade = int.tryParse(_quantidadeController.text) ?? 1;

    // Bug 4 fix: remove separador de milhar antes de trocar vírgula por ponto
    // Suporta: "1.500,50" → 1500.50, "10,50" → 10.50, "10.50" → 10.50
    final precoText = _precoController.text
        .replaceAll('.', '')   // remove separador de milhar
        .replaceAll(',', '.'); // converte decimal
    final preco = double.tryParse(precoText);

    final item = Item(
      id: widget.item?.id ?? const Uuid().v4(), // Bug 9 fix: UUID evita colisão de IDs
      nome: _nomeController.text.trim(),
      quantidade: quantidade,
      preco: preco,
      observacoes: _observacoesController.text.trim().isEmpty
          ? null
          : _observacoesController.text.trim(),
      dataCriacao: widget.item?.dataCriacao ?? DateTime.now(),
      comprado: widget.item?.comprado ?? false,
      dataCompra: widget.item?.dataCompra,
    );

    Navigator.of(context).pop(item);
  }

  /// Getter que faz o parse do campo de preço usando a mesma lógica do _salvarItem.
  /// Retorna null se o campo estiver vazio ou inválido.
  double? get _precoAtual {
    if (_precoController.text.trim().isEmpty) return null;
    final clean = _precoController.text
        .replaceAll('.', '')
        .replaceAll(',', '.');
    return double.tryParse(clean);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Item' : 'Novo Item'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: _salvarItem, icon: const Icon(Icons.save)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
            Semantics(
              label: 'item_nome',
              child: TextField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Item *',
                  hintText: 'Ex: Leite, Pão, Arroz...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_basket),
                ),
                textCapitalization: TextCapitalization.words,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Semantics(
                    label: 'item_quantidade',
                    child: TextField(
                      controller: _quantidadeController,
                      decoration: const InputDecoration(
                        labelText: 'Quantidade',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Semantics(
                    label: 'item_preco',
                    child: TextField(
                      controller: _precoController,
                      decoration: const InputDecoration(
                        labelText: 'Preço (opcional)',
                        hintText: 'Ex: 4,50',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                        prefixText: 'R\$ ',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        // Allow digits and one comma or dot
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Semantics(
              label: 'item_observacoes',
              child: TextField(
                controller: _observacoesController,
                decoration: const InputDecoration(
                  labelText: 'Observações (opcional)',
                  hintText: 'Ex: Marca preferida, quantidade específica...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Preview:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _nomeController.text.isEmpty
                        ? 'Nome do item'
                        : _nomeController.text,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Qtd: ${_quantidadeController.text.isEmpty ? '1' : _quantidadeController.text}',
                      ),
                      const SizedBox(width: 16),
                      Text(
                        _precoAtual == null
                            ? 'Preço não informado'
                            : AppUtils.formatMoney(_precoAtual!),
                      ),
                    ],
                  ),
                  // --- SEÇÃO DE HISTÓRICO E TENDÊNCIA ---
                  if (_nomeController.text.isNotEmpty) ...[
                    Consumer<ListasProvider>(
                      builder: (context, provider, child) {
                        final ultimoPreco = provider.obterUltimoPreco(_nomeController.text);
                        if (ultimoPreco == null) return const SizedBox.shrink();

                        final precoAtual = _precoAtual;
                        final diferenca = precoAtual != null ? (precoAtual - ultimoPreco) : 0.0;
                        final ehMaisCaro = precoAtual != null && diferenca > 0.01;
                        final ehMaisBarato = precoAtual != null && diferenca < -0.01;

                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              Icon(
                                precoAtual == null 
                                  ? Icons.history 
                                  : (ehMaisCaro ? Icons.trending_up : (ehMaisBarato ? Icons.trending_down : Icons.trending_flat)),
                                size: 16,
                                color: precoAtual == null 
                                  ? Colors.grey 
                                  : (ehMaisCaro ? Colors.red : (ehMaisBarato ? Colors.green : Colors.grey)),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Último pago: ${AppUtils.formatMoney(ultimoPreco)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: precoAtual == null 
                                    ? Colors.grey.shade700 
                                    : (ehMaisCaro ? Colors.red : (ehMaisBarato ? Colors.green : Colors.grey.shade700)),
                                ),
                              ),
                              if (precoAtual != null && (ehMaisCaro || ehMaisBarato))
                                Text(
                                  ' (${ehMaisCaro ? '+' : ''}${AppUtils.formatMoney(diferenca.abs())})',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: ehMaisCaro ? Colors.red : Colors.green,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                  // --------------------------------------
                  // Campo Total: só aparece quando preço é válido
                  if (_precoAtual != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Total: ${AppUtils.formatMoney(_precoAtual! * (int.tryParse(_quantidadeController.text) ?? 1))}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                  if (_observacoesController.text.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Obs: ${_observacoesController.text}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),

                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _salvarItem,
                icon: const Icon(Icons.save),
                label: Text(
                  _isEditing ? 'Salvar Alterações' : 'Adicionar Item',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
