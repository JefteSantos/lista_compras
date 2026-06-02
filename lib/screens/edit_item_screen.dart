import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'confirmation_dialog.dart';
import '../models/item.dart';
import '../models/categorias_provider.dart';
import 'package:lista_compras/models/listas_provider.dart';
import 'package:lista_compras/utils/app_utils.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../l10n/generated/app_localizations.dart';

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

  String? _categoriaSelecionada;
  bool _isEditing = false;
  String _ultimoNomeSugerido = ''; // evita sugestão repetida para o mesmo nome

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
    _categoriaSelecionada = widget.item?.categoria;

    // Bug 5 fix: listeners para o Preview atualizar em tempo real
    _nomeController.addListener(_onNomeChanged);
    _quantidadeController.addListener(() => setState(() {}));
    _precoController.addListener(() => setState(() {}));
    _observacoesController.addListener(() => setState(() {}));
  }

  /// Listener do campo nome: atualiza preview e sugere categoria.
  void _onNomeChanged() {
    setState(() {});

    // Só sugere para itens novos e se não tem categoria selecionada
    if (_isEditing) return;
    final nome = _nomeController.text.trim();
    if (nome.isEmpty || nome.length < 2) return;
    if (nome.toLowerCase() == _ultimoNomeSugerido.toLowerCase()) return;

    final provider = Provider.of<ListasProvider>(context, listen: false);
    final categoriaSugerida = provider.obterUltimaCategoria(nome);

    if (categoriaSugerida != null && _categoriaSelecionada == null) {
      _ultimoNomeSugerido = nome;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"$nome" já foi em "$categoriaSugerida"'),
          action: SnackBarAction(
            label: 'USAR',
            textColor: Colors.white,
            onPressed: () {
              setState(() => _categoriaSelecionada = categoriaSugerida);
            },
          ),
          backgroundColor: Colors.deepPurple,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
        SnackBar(content: Text(AppLocalizations.of(context)!.itemNameRequired)),
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
      categoria: _categoriaSelecionada,
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
        title: Text(_isEditing ? AppLocalizations.of(context)!.editItem : AppLocalizations.of(context)!.newItem),
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
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.itemNameLabel,
                  hintText: AppLocalizations.of(context)!.itemNameHint,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.shopping_basket),
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
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.quantity,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.numbers),
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
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.priceOptional,
                        hintText: AppLocalizations.of(context)!.priceHint,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.attach_money),
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
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.notesOptional,
                  hintText: AppLocalizations.of(context)!.notesHint,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.note),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(height: 16),

            // ----------- CATEGORIA (CORREDOR) -----------
            Consumer<CategoriasProvider>(
              builder: (context, categoriasProvider, _) {
                final categorias = categoriasProvider.categorias;
                // Garante que a categoria salva ainda existe; caso contrário, limpa
                if (_categoriaSelecionada != null &&
                    !categorias.any((c) => c.nome == _categoriaSelecionada)) {
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => setState(() => _categoriaSelecionada = null),
                  );
                }
                return InputDecorator(
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.aisleOptional,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.local_offer_outlined),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: _categoriaSelecionada,
                      isExpanded: true,
                      hint: Text(AppLocalizations.of(context)!.none),
                      items: [
                        // Opção "Nenhuma"
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(AppLocalizations.of(context)!.none, style: const TextStyle(color: Colors.grey)),
                        ),
                        // Categorias existentes
                        ...categorias.map(
                          (cat) => DropdownMenuItem<String?>(
                            value: cat.nome,
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: corDaCategoria(cat.nome),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(cat.nome),
                              ],
                            ),
                          ),
                        ),
                        // Opção para criar nova categoria
                        DropdownMenuItem<String?>(
                          value: '__nova__',
                          child: Row(
                            children: [
                              const Icon(Icons.add, size: 16, color: Colors.deepPurple),
                              const SizedBox(width: 6),
                              Text(
                                AppLocalizations.of(context)!.newCategoryEllipsis,
                                style: const TextStyle(color: Colors.deepPurple),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) async {
                        if (value == '__nova__') {
                          // Abre dialog para criar nova categoria
                          final novoNome = await _dialogNovaCategoriaInline(
                            context,
                            categoriasProvider,
                          );
                          if (novoNome != null && mounted) {
                            setState(() => _categoriaSelecionada = novoNome);
                          }
                        } else {
                          setState(() => _categoriaSelecionada = value);
                        }
                      },
                    ),
                  ),
                );
              },
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _nomeController.text.isEmpty
                              ? 'Nome do item'
                              : _nomeController.text,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      if (_categoriaSelecionada != null) ...
                        [_buildCategoriaTag(_categoriaSelecionada!)],
                    ],
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
                  _isEditing ? AppLocalizations.of(context)!.saveChanges : AppLocalizations.of(context)!.addItem,
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
  /// Constrói a tag visual da categoria.
  Widget _buildCategoriaTag(String nome) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: corDaCategoria(nome),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        nome,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  /// Dialog para criar uma nova categoria inline, sem sair da tela.
  Future<String?> _dialogNovaCategoriaInline(
    BuildContext context,
    CategoriasProvider provider,
  ) async {
    final controller = TextEditingController();
    String? erro;

    return showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.local_offer_outlined, color: Colors.deepPurple),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.newCategoryTitle),
            ],
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.categoryName,
              hintText: AppLocalizations.of(context)!.categoryNameHint,
              border: const OutlineInputBorder(),
              errorText: erro,
            ),
            onChanged: (_) {
              if (erro != null) setStateDialog(() => erro = null);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: Text(AppLocalizations.of(ctx)!.cancel.toUpperCase()),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final nome = controller.text.trim();
                if (nome.isEmpty) {
                  setStateDialog(() => erro = AppLocalizations.of(ctx)!.typeAName);
                  return;
                }
                if (provider.existeNome(nome)) {
                  setStateDialog(() => erro = AppLocalizations.of(ctx)!.categoryExists);
                  return;
                }
                await provider.adicionar(nome);
                if (ctx.mounted) Navigator.of(ctx).pop(nome);
              },
              child: Text(AppLocalizations.of(ctx)!.create),
            ),
          ],
        ),
      ),
    );
  }
}
