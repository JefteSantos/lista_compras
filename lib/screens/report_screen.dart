import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/listas_provider.dart';
import '../models/lista_compras.dart';
import '../utils/app_utils.dart';
import '../services/export_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  DateTimeRange? _selectedDateRange;
  bool _showItems = false;
  String _searchQuery = '';

  List<ListaCompras> _filteredList = [];

  @override
  void initState() {
    super.initState();
  }

  void _updateFilter() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final allListas = Provider.of<ListasProvider>(context).listas;

    _filteredList = allListas.where((lista) {
      if (_selectedDateRange != null) {
        if (lista.dataCriacao.isBefore(_selectedDateRange!.start) ||
            lista.dataCriacao.isAfter(
              _selectedDateRange!.end.add(const Duration(days: 1)),
            )) {
          return false;
        }
      }

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesListName = lista.nome.toLowerCase().contains(query);
        final matchesItemOptions = lista.itens.any(
          (i) => i.nome.toLowerCase().contains(query),
        );

        if (!matchesListName && !matchesItemOptions) {
          return false;
        }
      }

      return true;
    }).toList();

    _filteredList.sort((a, b) => b.dataCriacao.compareTo(a.dataCriacao));

    double totalGeralComprado = 0;
    double totalGeralAberto = 0;
    double totalGeral = 0;

    for (var l in _filteredList) {
      totalGeralComprado += l.precoComprado;
      totalGeralAberto += (l.precoTotal - l.precoComprado);
      totalGeral += l.precoTotal;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatório de Compras'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Exportar Relatório',
            onPressed: () => _showExportOptions(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          const Divider(height: 1),
          Expanded(
            child: _filteredList.isEmpty
                ? const Center(
                    child: Text('Nenhua lista encontrada para os filtros.'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: _filteredList.length,
                    itemBuilder: (context, index) {
                      return _buildReportCard(_filteredList[index]);
                    },
                  ),
          ),
          _buildFooterTotals(totalGeralComprado, totalGeralAberto, totalGeral),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final dateText = _selectedDateRange == null
        ? 'Todas as datas'
        : '${dateFormat.format(_selectedDateRange!.start)} - ${dateFormat.format(_selectedDateRange!.end)}';

    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Buscar lista ou item...',
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (val) {
                      _searchQuery = val;
                      _updateFilter();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: [
                    Checkbox(
                      value: _showItems,
                      onChanged: (val) {
                        setState(() {
                          _showItems = val ?? false;
                        });
                      },
                    ),
                    const Text('Itens'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDateRange,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(dateText)),
                    if (_selectedDateRange != null)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDateRange = null;
                          });
                        },
                        child: const Icon(Icons.close, size: 16),
                      )
                    else
                      const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(ListaCompras lista) {
    final valorAberto = lista.precoTotal - lista.precoComprado;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 1,
      child: Column(
        children: [
          ListTile(
            title: Text(
              lista.nome,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              DateFormat('dd/MM/yyyy HH:mm').format(lista.dataCriacao),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Total: ${AppUtils.formatMoney(lista.precoTotal)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Pago: ${AppUtils.formatMoney(lista.precoComprado)}', // Simplificado para caber
                  style: const TextStyle(fontSize: 11, color: Colors.green),
                ),
              ],
            ),
          ),

          if (_showItems && lista.itens.isNotEmpty)
            Container(
              color: Colors.grey.shade50,
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      'Itens:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(color: Colors.deepPurple),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: const [
                        Expanded(
                          flex: 4,
                          child: Text(
                            'Desc / Nome',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: Text(
                            'Qtd',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Valor',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...lista.itens.map((item) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade300,
                            width: 0.5,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.nome,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                if (item.observacoes != null &&
                                    item.observacoes!.isNotEmpty)
                                  Text(
                                    item.observacoes!,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            child: Text(
                              '${item.quantidade}',
                              style: const TextStyle(fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              item.preco != null
                                  ? AppUtils.formatMoney(item.preco!)
                                  : '-',
                              style: const TextStyle(fontSize: 12),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniStat('Comprado', lista.precoComprado, Colors.green),
                _buildMiniStat('Em Aberto', valorAberto, Colors.orange),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, double value, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        Text(
          AppUtils.formatMoney(value),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildFooterTotals(double comprado, double aberto, double total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL GERAL:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  AppUtils.formatMoney(total),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Comprado',
                          style: TextStyle(fontSize: 12, color: Colors.green),
                        ),
                        Text(
                          AppUtils.formatMoney(comprado),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Em Aberto',
                          style: TextStyle(fontSize: 12, color: Colors.orange),
                        ),
                        Text(
                          AppUtils.formatMoney(aberto),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final initialDateRange =
        _selectedDateRange ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 30)),
          end: DateTime.now(),
        );

    final newRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: initialDateRange,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.deepPurple,
            colorScheme: const ColorScheme.light(primary: Colors.deepPurple),
          ),
          child: child!,
        );
      },
    );

    if (newRange != null) {
      setState(() {
        _selectedDateRange = newRange;
      });
    }
  }

  void _showExportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Exportar Relatório',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('PDF'),
                onTap: () {
                  Navigator.pop(ctx);
                  ExportService.exportToPdf(
                    context,
                    _filteredList,
                    _selectedDateRange,
                    _showItems,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.table_chart, color: Colors.green),
                title: const Text('Excel (.xlsx)'),
                onTap: () {
                  Navigator.pop(ctx);
                  ExportService.exportToExcel(
                    context,
                    _filteredList,
                    _showItems,
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.insert_drive_file,
                  color: Colors.blue,
                ),
                title: const Text('CSV'),
                onTap: () {
                  Navigator.pop(ctx);
                  ExportService.exportToCsv(context, _filteredList, _showItems);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
