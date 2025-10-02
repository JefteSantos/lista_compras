import 'package:flutter/services.dart';
import '../models/lista_compras.dart';

class ShareService {
  static Future<void> compartilharLista(ListaCompras lista) async {
    final texto = _gerarTextoCompartilhamento(lista);

    await Clipboard.setData(ClipboardData(text: texto));
  }

  static String _gerarTextoCompartilhamento(ListaCompras lista) {
    final buffer = StringBuffer();

    buffer.writeln('🛒 ${lista.nome}');
    if (lista.descricao != null && lista.descricao!.isNotEmpty) {
      buffer.writeln('📝 ${lista.descricao}');
    }
    buffer.writeln('📅 Criada em: ${_formatarData(lista.dataCriacao)}');
    buffer.writeln();

    if (lista.finalizada) {
      buffer.writeln('✅ Lista Finalizada');
      if (lista.dataFinalizacao != null) {
        buffer.writeln(
          '📅 Finalizada em: ${_formatarData(lista.dataFinalizacao!)}',
        );
      }
    } else {
      buffer.writeln('🔄 Lista Ativa');
    }
    buffer.writeln();

    buffer.writeln(
      '📋 Itens (${lista.itensComprados}/${lista.totalItens} comprados):',
    );
    buffer.writeln();

    for (int i = 0; i < lista.itens.length; i++) {
      final item = lista.itens[i];
      final status = item.comprado ? '✅' : '⏳';

      buffer.write('$status ${item.nome}');

      if (item.quantidade > 1) {
        buffer.write(' (x${item.quantidade})');
      }

      if (item.preco != null) {
        buffer.write(' - R\$ ${item.preco!.toStringAsFixed(2)}');
        if (item.quantidade > 1) {
          buffer.write(' = R\$ ${item.precoTotal.toStringAsFixed(2)}');
        }
      }

      if (item.observacoes != null && item.observacoes!.isNotEmpty) {
        buffer.write(' - ${item.observacoes}');
      }

      buffer.writeln();
    }

    if (lista.precoTotal > 0) {
      buffer.writeln();
      buffer.writeln('💰 Resumo Financeiro:');
      buffer.writeln(
        'Total da lista: R\$ ${lista.precoTotal.toStringAsFixed(2)}',
      );
      buffer.writeln(
        'Valor comprado: R\$ ${lista.precoComprado.toStringAsFixed(2)}',
      );
      if (lista.precoTotal > lista.precoComprado) {
        buffer.writeln(
          'Valor pendente: R\$ ${(lista.precoTotal - lista.precoComprado).toStringAsFixed(2)}',
        );
      }
    }

    buffer.writeln();
    buffer.writeln('📱 Gerado pelo App Lista de Compras');

    return buffer.toString();
  }

  static String _formatarData(DateTime data) {
    final meses = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];

    return '${data.day.toString().padLeft(2, '0')}/${meses[data.month - 1]}/${data.year}';
  }

  static String gerarTextoResumido(ListaCompras lista) {
    final buffer = StringBuffer();
    buffer.write('🛒 ${lista.nome}');

    if (lista.totalItens > 0) {
      buffer.write(' (${lista.itensComprados}/${lista.totalItens} itens)');
    }

    if (lista.precoTotal > 0) {
      buffer.write(' - R\$ ${lista.precoTotal.toStringAsFixed(2)}');
    }

    return buffer.toString();
  }
}
