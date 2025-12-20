import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart'; // Handles web download automatically
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import '../models/lista_compras.dart';
import '../utils/app_utils.dart';

class ExportService {
  static int _exportCounter = 0;

  static String _generateFileName(String extension) {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyyMMdd_HHmm').format(now);
    _exportCounter++;

    if (_exportCounter > 9999) {
      _exportCounter = 1;
    }

    return 'NaoEsquece_Relatorio_${dateStr}_$_exportCounter.$extension';
  }

  static Future<void> exportToPdf(
    BuildContext context,
    List<ListaCompras> listas,
    DateTimeRange? periodo,
    bool includeItems,
  ) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Relatorio de Compras',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
                  ),
                ],
              ),
            ),
            if (periodo != null)
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 20),
                child: pw.Text(
                  'Periodo: ${DateFormat('dd/MM/yyyy').format(periodo.start)} a ${DateFormat('dd/MM/yyyy').format(periodo.end)}',
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey700,
                  ),
                ),
              ),

            ...listas.map((lista) {
              final valorAberto = lista.precoTotal - lista.precoComprado;

              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(5),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      color: PdfColors.grey100,
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            lista.nome,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text(
                            DateFormat('dd/MM/yyyy').format(lista.dataCriacao),
                          ),
                        ],
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Total: ${AppUtils.formatMoney(lista.precoTotal)}',
                          ),
                          pw.Text(
                            'Pago: ${AppUtils.formatMoney(lista.precoComprado)}',
                          ),
                          pw.Text(
                            'Aberto: ${AppUtils.formatMoney(valorAberto)}',
                          ),
                        ],
                      ),
                    ),
                    // Tabela de itens
                    if (includeItems && lista.itens.isNotEmpty)
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Itens:',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            ...lista.itens.map((item) {
                              return pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 2),
                                child: pw.Row(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Expanded(
                                      child: pw.Text(
                                        '${item.quantidade}x ${item.nome}',
                                        style: const pw.TextStyle(fontSize: 10),
                                      ),
                                    ),
                                    pw.Text(
                                      item.preco != null
                                          ? AppUtils.formatMoney(item.preco!)
                                          : '-',
                                      style: const pw.TextStyle(fontSize: 10),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            }),

            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  'TOTAL GERAL: ${AppUtils.formatMoney(listas.fold(0.0, (sum, item) => sum + item.precoTotal))}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: _generateFileName('pdf'),
      );
    } catch (e) {
      debugPrint('Erro ao exportar PDF: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao gerar PDF: $e')));
      }
    }
  }

  static Future<void> exportToCsv(
    BuildContext context,
    List<ListaCompras> listas,
    bool includeItems,
  ) async {
    try {
      List<List<dynamic>> rows = [];

      List<dynamic> header = [
        "Data Criacao",
        "Nome Lista",
        "Total Lista",
        "Valor Pago",
        "Valor Aberto",
      ];

      if (includeItems) {
        header.addAll(["Nome Item", "Quantidade", "Valor Item", "Observacoes"]);
      }

      rows.add(header);

      for (var lista in listas) {
        if (!includeItems || lista.itens.isEmpty) {
          List<dynamic> row = [
            DateFormat('dd/MM/yyyy').format(lista.dataCriacao),
            lista.nome,
            lista.precoTotal.toStringAsFixed(2),
            lista.precoComprado.toStringAsFixed(2),
            (lista.precoTotal - lista.precoComprado).toStringAsFixed(2),
          ];

          if (includeItems) {
            row.addAll(["-", "-", "-", "-"]);
          }

          rows.add(row);
        } else {
          for (var item in lista.itens) {
            rows.add([
              DateFormat('dd/MM/yyyy').format(lista.dataCriacao),
              lista.nome,
              lista.precoTotal.toStringAsFixed(2),
              lista.precoComprado.toStringAsFixed(2),
              (lista.precoTotal - lista.precoComprado).toStringAsFixed(2),
              item.nome,
              item.quantidade.toString(),
              item.preco?.toStringAsFixed(2) ?? "0.00",
              item.observacoes ?? "",
            ]);
          }
        }
      }

      String csvData = const ListToCsvConverter().convert(rows);
      final fileName = _generateFileName('csv');

      if (kIsWeb) {
        final bom = [0xEF, 0xBB, 0xBF];
        final bytes = bom + utf8.encode(csvData);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        // ignore: unused_local_variable
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final path = "${directory.path}/$fileName";
        final file = File(path);

        // Write with UTF-8 BOM
        final bom = [0xEF, 0xBB, 0xBF];
        final bytes = bom + utf8.encode(csvData);
        await file.writeAsBytes(bytes);

        await OpenFilex.open(path);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CSV exportado com sucesso!')),
        );
      }
    } catch (e) {
      debugPrint('Erro ao exportar CSV: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao gerar CSV: $e')));
      }
    }
  }

  static Future<void> exportToExcel(
    BuildContext context,
    List<ListaCompras> listas,
    bool includeItems,
  ) async {
    try {
      var excel = Excel.createExcel();
      Sheet sheet = excel['Relatorio'];

      // Headers
      List<String> headers = [
        "Data Criacao",
        "Nome Lista",
        "Total Lista",
        "Valor Pago",
        "Valor Aberto",
      ];

      if (includeItems) {
        headers.addAll([
          "Nome Item",
          "Quantidade",
          "Valor Item",
          "Observacoes",
        ]);
      }

      sheet.appendRow(headers.map((e) => TextCellValue(e)).toList());

      for (var lista in listas) {
        if (!includeItems || lista.itens.isEmpty) {
          List<CellValue> row = [
            TextCellValue(DateFormat('dd/MM/yyyy').format(lista.dataCriacao)),
            TextCellValue(lista.nome),
            DoubleCellValue(lista.precoTotal),
            DoubleCellValue(lista.precoComprado),
            DoubleCellValue(lista.precoTotal - lista.precoComprado),
          ];

          if (includeItems) {
            row.addAll([
              TextCellValue("-"),
              TextCellValue("-"),
              TextCellValue("-"),
              TextCellValue("-"),
            ]);
          }

          sheet.appendRow(row);
        } else {
          for (var item in lista.itens) {
            sheet.appendRow([
              TextCellValue(DateFormat('dd/MM/yyyy').format(lista.dataCriacao)),
              TextCellValue(lista.nome),
              DoubleCellValue(lista.precoTotal),
              DoubleCellValue(lista.precoComprado),
              DoubleCellValue(lista.precoTotal - lista.precoComprado),
              TextCellValue(item.nome),
              IntCellValue(item.quantidade),
              DoubleCellValue(item.preco ?? 0),
              TextCellValue(item.observacoes ?? ""),
            ]);
          }
        }
      }

      // Remove sheet default
      if (excel.sheets.containsKey('Sheet1')) {
        excel.delete('Sheet1');
      }

      final List<int>? fileBytes = excel.save();
      final fileName = _generateFileName('xlsx');

      if (fileBytes != null) {
        if (kIsWeb) {
          final blob = html.Blob([fileBytes]);
          final url = html.Url.createObjectUrlFromBlob(blob);
          // ignore: unused_local_variable
          final anchor = html.AnchorElement(href: url)
            ..setAttribute("download", fileName)
            ..click();
          html.Url.revokeObjectUrl(url);
        } else {
          final directory = await getApplicationDocumentsDirectory();
          final path = "${directory.path}/$fileName";
          final file = File(path);

          await file.writeAsBytes(fileBytes);
          await OpenFilex.open(path);
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Excel exportado com sucesso!')),
          );
        }
      }
    } catch (e) {
      debugPrint('Erro ao exportar Excel: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao gerar Excel: $e')));
      }
    }
  }
}
