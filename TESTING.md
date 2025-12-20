# Testes Automatizados - Não Esquece!

Este projeto possui uma suíte completa de testes automatizados para garantir a qualidade do código.

## 📋 Tipos de Testes

### 1. **Testes Unitários** (`test/models_test.dart`)
Testa a lógica de negócio dos modelos:
- ✅ Criação de listas
- ✅ Adição/remoção de itens
- ✅ Cálculos de preços
- ✅ Finalização de listas
- ✅ Manipulação de itens

### 2. **Testes de Utilidades** (`test/utils_test.dart`)
Testa funções auxiliares:
- ✅ Formatação de valores monetários (R$)
- ✅ Valores positivos e negativos
- ✅ Valores decimais

### 3. **Testes de Widget** (`test/widget_test.dart`)
Testa componentes visuais:
- ✅ Renderização da tela inicial
- ✅ Tabs (Ativas/Histórico)
- ✅ Botões e ícones
- ✅ FAB (FloatingActionButton)

### 4. **Testes de Integração** (`test/integration_test.dart`)
Testa fluxos completos do app:
- ✅ Criação de nova lista
- ✅ Navegação entre tabs
- ✅ Interação completa do usuário

## 🚀 Como Rodar os Testes

### Todos os Testes
```bash
flutter test
```

### Teste Específico
```bash
flutter test test/models_test.dart
```

### Com Cobertura
```bash
flutter test --coverage
```

### Ver Relatório de Cobertura
```bash
# Instalar lcov (Windows)
choco install lcov

# Gerar relatório HTML
genhtml coverage/lcov.info -o coverage/html

# Abrir no navegador
start coverage/html/index.html
```

## 📊 Cobertura de Testes

Os testes cobrem:
- ✅ Modelos de dados (ListaCompras, Item)
- ✅ Utilitários (formatação)
- ✅ Widgets principais
- ✅ Fluxos de usuário

## 🔄 CI/CD

Os testes rodam automaticamente no GitHub Actions em cada:
- Push para `main`
- Pull Request

Veja o arquivo `.github/workflows/ios.yml` para detalhes.

## 📝 Adicionando Novos Testes

1. Crie um arquivo `*_test.dart` na pasta `test/`
2. Importe `package:flutter_test/flutter_test.dart`
3. Use `group()` para agrupar testes relacionados
4. Use `test()` ou `testWidgets()` para cada teste
5. Use `expect()` para validações

### Exemplo:
```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Meu Grupo de Testes', () {
    test('deve fazer algo', () {
      final resultado = minhaFuncao();
      expect(resultado, equals(valorEsperado));
    });
  });
}
```

## 🐛 Debugging Testes

Para debugar um teste específico:
```bash
flutter test --plain-name "nome do teste"
```

## 📚 Recursos

- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Widget Testing](https://docs.flutter.dev/cookbook/testing/widget/introduction)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)
