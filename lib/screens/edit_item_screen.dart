import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'confirmation_dialog.dart';
import '../models/item.dart';
import 'package:lista_compras/models/listas_provider.dart';
import 'package:lista_compras/utils/app_utils.dart';
import 'package:intl/intl.dart';

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
    
    // Parse currency allowing comma as decimal separator. 
    // This supports "10,50" -> "10.50" and "10.50" -> "10.50".
    String precoText = _precoController.text.replaceAll(',', '.');
    final preco = double.tryParse(precoText);

    final item = Item(
      id: widget.item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do Item *',
                hintText: 'Ex: Leite, Pão, Arroz...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.shopping_basket),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
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
                const SizedBox(width: 16),

                Expanded(
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
              ],
            ),
            const SizedBox(height: 16),

            TextField(
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
                        _precoController.text.isEmpty
                            ? 'Preço não informado'
                            : (() {
                                try {
                                  String clean = _precoController.text.replaceAll('.', '').replaceAll(',', '.');
                                  double? val = double.tryParse(clean);
                                  return val != null ? AppUtils.formatMoney(val) : 'R\$ ${_precoController.text}';
                                } catch (e) {
                                  return 'R\$ ${_precoController.text}';
                                }
                              })(),
                      ),
                    ],
                  ),
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

            const Spacer(),

            SizedBox(
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
          ],
        ),
      ),
    );
  }
}
