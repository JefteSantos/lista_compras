import '../models/lista_compras.dart';
import '../models/item.dart';
import 'package:uuid/uuid.dart';

class TextParserService {
  /// Recebe o texto de exportação (ex: do WhatsApp) e converte em ListaCompras.
  static ListaCompras? parseText(String text) {
    if (text.trim().isEmpty) return null;

    final lines = text.split('\n');
    String nomeLista = 'Lista Importada';
    List<Item> itens = [];
    
    // Expressão para extrair o nome da lista: 🛒 *NOME*
    final nameRegExp = RegExp(r'🛒\s*\*(.*?)\*');
    
    // Expressão para extrair item: "• 1x Requeijão - R$ 11,97"
    final itemRegExp = RegExp(r'^\s*[•\-\*]?\s*([0-9.,]+)[xX]\s+(.*)');
    
    bool lendoComprados = false; // Estado para saber se o item já foi pego

    for (var line in lines) {
      final tLine = line.trim();
      if (tLine.isEmpty) continue;

      // 1. Verificar se é a linha do título
      if (nameRegExp.hasMatch(tLine)) {
        nomeLista = nameRegExp.firstMatch(tLine)?.group(1)?.trim() ?? nomeLista;
        continue;
      }

      // 2. Verificar a seção (Falta Comprar vs Já Peguei)
      final lowerLine = tLine.toLowerCase();
      if (tLine.contains('✅') || lowerLine.contains('já peguei')) {
        lendoComprados = true;
        continue;
      }
      if (tLine.contains('⬜') || lowerLine.contains('falta comprar') || lowerLine.contains('falta pegar')) {
        lendoComprados = false;
        continue;
      }
      
      // 3. Parar de analisar se chegamos no resumo
      if (tLine.contains('📊') || lowerLine.contains('resumo:')) {
        break;
      }

      // 4. Analisar linha como item
      final itemMatch = itemRegExp.firstMatch(tLine);
      if (itemMatch != null) {
        final qtdStr = itemMatch.group(1)!.replaceAll(',', '.');
        final int qtd = double.tryParse(qtdStr)?.toInt() ?? 1;
        
        String remainder = itemMatch.group(2)!.trim();
        String nome = remainder;
        double? preco;

        // Limpar o "(total: ...)" do final da string, se houver
        if (remainder.toLowerCase().contains('(total:')) {
           final idx = remainder.toLowerCase().lastIndexOf('(total:');
           remainder = remainder.substring(0, idx).trim();
        }

        // Tentar extrair nome e preço separando por " - " (usado para comprados) 
        // ou " (" (usado para não comprados)
        String? possiblePrice;
        if (remainder.contains(' - ')) {
          final idx = remainder.lastIndexOf(' - ');
          nome = remainder.substring(0, idx).trim();
          possiblePrice = remainder.substring(idx + 3).trim();
        } else if (remainder.contains(' (')) {
          final idx = remainder.lastIndexOf(' (');
          nome = remainder.substring(0, idx).trim();
          possiblePrice = remainder.substring(idx + 2).trim();
        }

        // Se encontrou possível preço (ex: "R$ 39,90" ou "$ 1,168.60")
        if (possiblePrice != null) {
          // Extraímos apenas os dígitos numéricos
          final digits = possiblePrice.replaceAll(RegExp(r'[^\d]'), '');
          if (digits.isNotEmpty) {
            // Como a formatação sempre exporta com 2 casas decimais (100 = 1.00), 
            // basta dividir por 100 para ter o valor exato independente do locale.
            preco = int.parse(digits) / 100.0;
          }
        }

        itens.add(Item(
          id: const Uuid().v4(),
          nome: nome,
          quantidade: qtd,
          preco: preco,
          comprado: lendoComprados,
          dataCriacao: DateTime.now(),
        ));
      }
    }

    if (itens.isEmpty) return null;

    final lista = ListaCompras(
      id: const Uuid().v4(),
      nome: nomeLista,
      dataCriacao: DateTime.now(),
    );
    lista.itens.addAll(itens);
    return lista;
  }
}
