import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/listas_provider.dart';
import '../models/lista_compras.dart';
import '../utils/app_utils.dart';
import '../services/export_service.dart';
import '../models/iap_provider.dart';
import '../screens/paywall_screen.dart';
import '../l10n/generated/app_localizations.dart';

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

    final filteredList = allListas.where((lista) {
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

    filteredList.sort((a, b) => b.dataCriacao.compareTo(a.dataCriacao));
    _filteredList = filteredList;

    double totalGeralComprado = 0;
    double totalGeralAberto = 0;
    double totalGeral = 0;

    for (var l in filteredList) {
      totalGeralComprado += l.precoComprado;
      totalGeralAberto += (l.precoTotal - l.precoComprado);
      totalGeral += l.precoTotal;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.reportTitle),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: AppLocalizations.of(context)!.exportReport,
            onPressed: () => _showExportOptions(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          const Divider(height: 1),
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Text(AppLocalizations.of(context)!.noListsForFilters),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      return _buildReportCard(filteredList[index]);
                    },
                  ),
          ),
          _buildFooterTotals(totalGeralComprado, totalGeralAberto, totalGeral),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('dd/MM/yyyy');
    final dateText = _selectedDateRange == null
        ? AppLocalizations.of(context)!.allDates
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
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.search,
                      prefixIcon: const Icon(Icons.search),
                      isDense: true,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
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
                    Text(AppLocalizations.of(context)!.showItems),
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
                  border: Border.all(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: isDark ? Colors.purpleAccent.shade100 : Colors.deepPurple,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                  '${AppLocalizations.of(context)!.total}: ${AppUtils.formatMoney(lista.precoTotal)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${AppLocalizations.of(context)!.totalSpentLabel}: ${AppUtils.formatMoney(lista.precoComprado)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.greenAccent : Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),

          if (_showItems && lista.itens.isNotEmpty)
            Container(
              color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      '${AppLocalizations.of(context)!.items}:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.deepPurple.shade700 : Colors.deepPurple,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            AppLocalizations.of(context)!.descName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: Text(
                            AppLocalizations.of(context)!.qty,
                            style: const TextStyle(
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
                            AppLocalizations.of(context)!.val,
                            style: const TextStyle(
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
                            color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
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
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                if (item.observacoes != null &&
                                    item.observacoes!.isNotEmpty)
                                  Text(
                                    item.observacoes!,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            child: Text(
                              AppUtils.formatQuantity(item.quantidade),
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              item.preco != null
                                  ? AppUtils.formatMoney(item.preco!)
                                  : '-',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
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
                _buildMiniStat(AppLocalizations.of(context)!.bought, lista.precoComprado, Colors.green),
                _buildMiniStat(AppLocalizations.of(context)!.totalPendingLabel, valorAberto, Colors.orange),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, double value, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayColor = isDark
        ? (color == Colors.green ? Colors.greenAccent : Colors.orangeAccent)
        : color;

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: displayColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey),
        ),
        Text(
          AppUtils.formatMoney(value),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: displayColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFooterTotals(double comprado, double aberto, double total) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
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
                Text(
                  AppLocalizations.of(context)!.grandTotal,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  AppUtils.formatMoney(total),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isDark ? Colors.purpleAccent.shade100 : Colors.deepPurple,
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
                      color: isDark ? Colors.green.shade900.withValues(alpha: 0.35) : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isDark ? Colors.green.shade700 : Colors.green.shade200,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.bought,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.greenAccent : Colors.green.shade800,
                          ),
                        ),
                        Text(
                          AppUtils.formatMoney(comprado),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.greenAccent : Colors.green.shade900,
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
                      color: isDark ? Colors.orange.shade900.withValues(alpha: 0.35) : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isDark ? Colors.orange.shade700 : Colors.orange.shade200,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.notBought,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.orangeAccent : Colors.orange.shade800,
                          ),
                        ),
                        Text(
                          AppUtils.formatMoney(aberto),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.orangeAccent : Colors.orange.shade900,
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
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: Colors.deepPurpleAccent,
                    onPrimary: Colors.white,
                    surface: Color(0xFF1E1E1E),
                    onSurface: Colors.white,
                  ),
                )
              : ThemeData.light().copyWith(
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
    final iap = Provider.of<IapProvider>(context, listen: false);
    if (!iap.podeUsarExport()) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PaywallScreen()),
      );
      return;
    }

    final isFreeTrial = !iap.isPro && iap.exportUsosCount == 0;

    void processarUsoTrial() {
      if (isFreeTrial) {
        iap.registrarUsoExport();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ Você usou seu teste grátis de exportação! Seja PRO para exportar sem limites.'),
            backgroundColor: Colors.deepPurple,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.exportReport,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: Text(AppLocalizations.of(context)!.exportPdf),
                onTap: () {
                  Navigator.pop(ctx);
                  processarUsoTrial();
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
                title: Text(AppLocalizations.of(context)!.exportExcel),
                onTap: () {
                  Navigator.pop(ctx);
                  processarUsoTrial();
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
                title: Text(AppLocalizations.of(context)!.exportCsv),
                onTap: () {
                  Navigator.pop(ctx);
                  processarUsoTrial();
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
