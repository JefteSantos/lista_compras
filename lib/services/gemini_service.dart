import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';
import 'hive_service.dart';

/// Serviço para integração com o Google Gemini AI.
/// Permite analisar preços de itens baseando-se no mercado brasileiro.
class GeminiService {
  static const String _apiKeyConfigKey = 'gemini_api_key';
  static const String _modelName = 'gemini-1.5-flash';

  /// Obtém a chave de API salva no Hive.
  static String? get apiKey => HiveService.obterConfiguracao<String>(_apiKeyConfigKey);

  /// Salva a chave de API no Hive.
  static Future<void> salvarApiKey(String key) async {
    await HiveService.salvarConfiguracao(_apiKeyConfigKey, key);
  }

  /// Remove a chave de API do Hive.
  static Future<void> removerApiKey() async {
    await HiveService.removerConfiguracao(_apiKeyConfigKey);
  }

  /// Testa se a chave de API fornecida é válida fazendo uma chamada simples.
  static Future<bool> testarChave(String key) async {
    try {
      final model = GenerativeModel(model: _modelName, apiKey: key);
      final content = [Content.text('Diga "OK"')];
      final response = await model.generateContent(content);
      return response.text != null;
    } catch (e) {
      debugPrint('Erro ao testar chave Gemini: $e');
      return false;
    }
  }

  /// Analisa o preço de um item e retorna uma string curta com a análise.
  /// Ex: "💰 Preço Justo (Média no Brasil)"
  static Future<String> analisarPreco(String item, double preco) async {
    final key = apiKey;
    if (key == null || key.isEmpty) {
      return 'Chave de API não configurada';
    }

    try {
      final model = GenerativeModel(
        model: _modelName,
        apiKey: key,
        generationConfig: GenerationConfig(
          temperature: 0.4,
          topK: 32,
          topP: 1,
          maxOutputTokens: 60,
        ),
      );

      final prompt = '''
Você é um assistente de compras especializado no mercado brasileiro.
Analise se o preço informado para o produto abaixo está barato, justo ou caro em relação à média de mercado no Brasil.
Considere o contexto de supermercados brasileiros em 2024-2026.

Produto: $item
Preço: R\$ ${preco.toStringAsFixed(2)}

Responda de forma extremamente curta, começando obrigatoriamente com um dos seguintes status:
- 💰 Preço Barato
- ⚖️ Preço Justo
- ⚠️ Preço Caro

Após o status, adicione uma justificativa curtíssima (máximo 5 palavras).
Exemplo: "⚖️ Preço Justo (Média para leite integral)"
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      final text = response.text?.trim() ?? 'Não foi possível analisar';
      return text;
    } catch (e) {
      debugPrint('Erro na análise Gemini: $e');
      if (e.toString().contains('API_KEY_INVALID')) {
        return 'Chave de API inválida';
      }
      return 'Erro na análise: $e';
    }
  }
}
