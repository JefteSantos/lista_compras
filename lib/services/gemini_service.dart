import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

import 'hive_service.dart';

/// Serviço de integração com o Google Gemini (BYOK — chave do próprio usuário).
///
/// ## Arquitetura da análise de preço
///
/// A IA **nunca recebe o preço pago pelo usuário**. Ela responde uma única
/// pergunta: *"qual a faixa de preço deste produto no Brasil?"*.
///
/// Isso elimina o viés de **anchoring**: quando o preço pago vai no prompt, o
/// modelo ajusta a estimativa para perto dele (R$ 17 → faixa 16–25;
/// R$ 35 → faixa 28–42), o que torna a comparação inútil.
///
/// O veredito (Barato / Justo / Caro) é calculado **localmente em Dart**, por
/// comparação numérica — determinístico e independente do humor do modelo.
///
/// Contrato de retorno de [analisarPreco] — sempre 3 partes separadas por `|`:
/// ```
/// STATUS | FAIXA | DICA
/// Barato | R$ 25,00 a R$ 35,00 | Cerca de 32% abaixo da faixa
/// ```
class GeminiService {
  static const String _apiKeyConfigKey = 'gemini_api_key';
  static const String _modelConfigKey = 'gemini_model_working';
  static const String _modelPadrao = 'gemini-1.5-flash';

  /// Modelos preferidos, na ordem. Qualquer outro modelo da conta é testado depois.
  static const List<String> _prioridade = [
    'gemini-1.5-flash',
    'gemini-1.5-flash-latest',
    'gemini-2.0-flash',
    'gemini-1.5-pro',
    'gemini-1.0-pro',
    'gemini-pro',
  ];

  // ---------------------------------------------------------------------------
  // Chave de API
  // ---------------------------------------------------------------------------

  static String? get apiKey =>
      HiveService.obterConfiguracao<String>(_apiKeyConfigKey);

  static String? get modeloAtivo =>
      HiveService.obterConfiguracao<String>(_modelConfigKey);

  static Future<void> salvarApiKey(String key) =>
      HiveService.salvarConfiguracao(_apiKeyConfigKey, key.trim());

  static Future<void> removerApiKey() async {
    await HiveService.removerConfiguracao(_apiKeyConfigKey);
    await HiveService.removerConfiguracao(_modelConfigKey);
  }

  // ---------------------------------------------------------------------------
  // Validação da chave + descoberta do modelo
  // ---------------------------------------------------------------------------

  /// Valida a chave e descobre, na conta do usuário, o **primeiro modelo que
  /// realmente responde**. Salva esse modelo no Hive para uso posterior.
  ///
  /// Testa TODOS os modelos disponíveis (não só uma lista fixa), porque o Google
  /// aposenta modelos com frequência e cada chave tem acesso a um conjunto diferente.
  static Future<bool> testarChave(String key) async {
    final modelos = await _listarModelosDisponiveis(key);
    if (modelos.isEmpty) {
      debugPrint('[Gemini] Nenhum modelo com generateContent para esta chave.');
      return false;
    }

    debugPrint('[Gemini] Modelos candidatos: $modelos');

    for (final nome in modelos) {
      try {
        final model = GenerativeModel(
          model: nome,
          apiKey: key,
          generationConfig: GenerationConfig(maxOutputTokens: 10),
        );
        final r = await model.generateContent([Content.text('Diga OK')]);
        if (r.text != null && r.text!.trim().isNotEmpty) {
          debugPrint('[Gemini] Modelo funcional: $nome');
          await HiveService.salvarConfiguracao(_modelConfigKey, nome);
          return true;
        }
      } catch (e) {
        debugPrint('[Gemini] $nome falhou: $e');
      }
    }
    return false;
  }

  /// Retorna os modelos da conta que suportam `generateContent`,
  /// já ordenados pela nossa lista de preferência.
  static Future<List<String>> _listarModelosDisponiveis(String key) async {
    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models?key=$key',
      );
      final resp = await http.get(url);
      if (resp.statusCode != 200) {
        debugPrint('[Gemini] ListModels ${resp.statusCode}: ${resp.body}');
        return const [];
      }

      final models = (jsonDecode(resp.body)['models'] as List?) ?? const [];
      final disponiveis = models
          .where((m) =>
              (m['supportedGenerationMethods'] as List?)
                  ?.contains('generateContent') ??
              false)
          .map((m) => m['name'].toString().replaceFirst('models/', ''))
          .toList();

      // Prioridade primeiro, depois o restante (ex.: gemma-*, gemini-3.x etc).
      return <String>[
        ..._prioridade.where(disponiveis.contains),
        ...disponiveis.where((m) => !_prioridade.contains(m)),
      ];
    } catch (e) {
      debugPrint('[Gemini] Erro ao listar modelos: $e');
      return const [];
    }
  }

  // ---------------------------------------------------------------------------
  // Análise de preço
  // ---------------------------------------------------------------------------

  /// Compara o [preco] informado com a faixa de mercado do [item].
  ///
  /// Retorna sempre `STATUS | FAIXA | DICA`.
  static Future<String> analisarPreco(String item, double preco) async {
    final key = apiKey;
    if (key == null || key.isEmpty) {
      return 'Erro | — | Configure sua chave de API';
    }

    final nomeItem = item.trim();
    if (nomeItem.isEmpty) {
      return 'Erro | — | Informe o nome do item';
    }

    final modelo = modeloAtivo ?? _modelPadrao;

    try {
      return await _analisar(modelo, key, nomeItem, preco);
    } catch (e) {
      debugPrint('[Gemini] Falha com "$modelo": $e');

      // O modelo salvo pode ter sido aposentado pelo Google. Redescobre e tenta 1x.
      if (await testarChave(key)) {
        final novo = modeloAtivo;
        if (novo != null && novo != modelo) {
          try {
            return await _analisar(novo, key, nomeItem, preco);
          } catch (e2) {
            debugPrint('[Gemini] Falha também com "$novo": $e2');
          }
        }
      }
      return 'Erro | — | Não foi possível analisar agora';
    }
  }

  /// Consulta a faixa de mercado e monta o veredito.
  ///
  /// O prompt **não menciona o preço pago** — apenas o produto.
  static Future<String> _analisar(
    String modelo,
    String key,
    String item,
    double preco,
  ) async {
    final model = GenerativeModel(
      model: modelo,
      apiKey: key,
      generationConfig: GenerationConfig(
        temperature: 0.2,
        // Modelos de raciocínio (gemma-*) escrevem uma análise longa antes da
        // conclusão. Com pouco token a resposta é truncada antes da faixa.
        maxOutputTokens: 1000,
      ),
    );

    final prompt = '''
Em supermercados do Brasil, qual a faixa de preço normalmente cobrada
por este produto?

Produto: $item

Termine sua resposta com esta linha:
FAIXA: R\$ valor mínimo a R\$ valor máximo

Use valores numéricos com centavos, considerando a embalagem mais comum.
''';

    final resposta = await model.generateContent([Content.text(prompt)]);
    final bruto = resposta.text?.trim() ?? '';

    debugPrint('[Gemini/$modelo] resposta bruta:\n$bruto');

    return _montarVeredito(bruto, preco);
  }

  // ---------------------------------------------------------------------------
  // Normalização + cálculo local do veredito
  // ---------------------------------------------------------------------------

  /// Palavras que denunciam uma linha de **instrução ecoada** pelo modelo
  /// (ex.: "Constraint: End with a specific line format: ...").
  static final RegExp _linhaDeInstrucao = RegExp(
    r'constraint|instruction|format|task:|goal|tarefa:|<|>|\[|\]',
    caseSensitive: false,
  );

  /// Extrai a faixa da resposta e calcula o veredito **em Dart**.
  static String _montarVeredito(String bruto, double preco) {
    final limpo = bruto.replaceAll(RegExp(r'[*`#]'), '').trim();
    if (limpo.isEmpty) {
      return 'Erro | — | A IA não retornou resposta';
    }

    // Descarta linhas que são apenas o prompt sendo repetido.
    final texto = limpo
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty && !_linhaDeInstrucao.hasMatch(l))
        .join('\n');

    // 1) Faixa explícita (min a max).
    final faixa = _extrairFaixa(texto);
    if (faixa != null) {
      return _formatar(preco, faixa.$1, faixa.$2);
    }

    // 2) Só um valor: monta uma faixa de ±12% em volta dele.
    final unico = _extrairValorUnico(texto);
    if (unico != null) {
      return _formatar(preco, unico * 0.88, unico * 1.12);
    }

    debugPrint('[Gemini] Nenhum valor numérico encontrado na resposta.');
    return 'Erro | — | Não foi possível estimar a faixa';
  }

  /// Monta a string final `STATUS | FAIXA | DICA`.
  static String _formatar(double preco, double min, double max) {
    final status = _statusPorFaixa(preco, min, max);
    final resultado =
        '$status | ${_moeda(min)} a ${_moeda(max)} | ${_dica(preco, min, max)}';
    debugPrint('[Gemini] veredito calculado: $resultado');
    return resultado;
  }

  /// Comparação puramente numérica — nada de opinião do modelo aqui.
  static String _statusPorFaixa(double preco, double min, double max) {
    if (preco < min) return 'Barato';
    if (preco > max) return 'Caro';
    return 'Justo';
  }

  /// Dica com o percentual real de diferença.
  static String _dica(double preco, double min, double max) {
    if (preco < min) {
      final pct = ((min - preco) / min * 100).round();
      return pct >= 1
          ? 'Cerca de $pct% abaixo da faixa, boa compra'
          : 'No limite inferior da faixa, boa compra';
    }
    if (preco > max) {
      final pct = ((preco - max) / max * 100).round();
      return pct >= 1
          ? 'Cerca de $pct% acima da faixa, vale pesquisar'
          : 'No limite superior da faixa, vale pesquisar';
    }
    return 'Dentro da faixa praticada no mercado';
  }

  // ---------------------------------------------------------------------------
  // Extração de números
  // ---------------------------------------------------------------------------

  /// Procura a **última** faixa do texto (a conclusão vem depois do raciocínio).
  ///
  /// Reconhece: `R$ 25,00 a R$ 35,00`, `entre R$ 25 e R$ 35`,
  /// `R$ 25 - R$ 35`, `from R$ 25 to R$ 35`.
  static (double, double)? _extrairFaixa(String texto) {
    final re = RegExp(
      r'R?\$?\s*(\d+(?:[.,]\d{1,2})?)\s*(?:a|at[eé]|to|e|-|–|—)\s*R?\$?\s*(\d+(?:[.,]\d{1,2})?)',
      caseSensitive: false,
    );

    for (final m in re.allMatches(texto).toList().reversed) {
      final min = _valorDe(m.group(1)!);
      final max = _valorDe(m.group(2)!);
      if (min == null || max == null) continue;
      if (min <= 0 || max <= 0 || max <= min) continue;
      // Faixas absurdas (ex.: "2 a 2024", pegando um ano) são descartadas.
      if (max / min > 6) continue;
      return (min, max);
    }
    return null;
  }

  /// Último valor monetário citado, para quando o modelo dá só a média.
  static double? _extrairValorUnico(String texto) {
    final rotulado = RegExp(
      r'(?:faixa|m[eé]dia|average|range|pre[cç]o\s+m[eé]dio)\D{0,20}(\d+(?:[.,]\d{1,2})?)',
      caseSensitive: false,
    );
    for (final m in rotulado.allMatches(texto).toList().reversed) {
      final v = _valorDe(m.group(1)!);
      if (v != null && v > 0) return v;
    }

    final comMoeda = RegExp(r'R\$\s?(\d+(?:[.,]\d{1,2})?)');
    for (final m in comMoeda.allMatches(texto).toList().reversed) {
      final v = _valorDe(m.group(1)!);
      if (v != null && v > 0) return v;
    }
    return null;
  }

  /// Converte o número escrito pela IA (`29,50`, `29.50`, `1.299,90`) em double.
  static double? _valorDe(String numero) => double.tryParse(
        numero.replaceAll(RegExp(r'\.(?=\d{3}\b)'), '').replaceAll(',', '.'),
      );

  static String _moeda(double valor) =>
      'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
}
