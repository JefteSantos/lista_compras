# Configuração do Hive - Lista de Compras

## ✅ Configuração Completa

O Hive foi configurado completamente no seu projeto! Aqui está o que foi feito:

### 1. Dependências Adicionadas

```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.7
```

### 2. Estrutura Criada

```
lib/
├── models/
│   ├── item.dart              # Modelo para itens da lista
│   └── lista_compras.dart     # Modelo para lista de compras
├── services/
│   └── hive_service.dart      # Serviço de gerenciamento do Hive
├── examples/
│   └── hive_example.dart      # Exemplo de uso completo
└── main.dart                  # Configurado para inicializar o Hive
```

### 3. Como Usar

#### Instalar Dependências
```bash
flutter pub get
```

#### Gerar Adapters (Importante!)
```bash
flutter packages pub run build_runner build
```

#### Executar o App
```bash
flutter run
```

## 📱 Funcionalidades Implementadas

### Modelos de Dados
- **Item**: Representa um item da lista com nome, quantidade, preço, status de compra, etc.
- **ListaCompras**: Representa uma lista completa com múltiplos itens

### Serviço HiveService
- ✅ Inicialização automática do Hive
- ✅ CRUD completo para listas e itens
- ✅ Filtros (listas ativas, finalizadas)
- ✅ Estatísticas
- ✅ Configurações persistentes

### Exemplo de Uso
O arquivo `hive_example.dart` demonstra:
- ✅ Criação de listas e itens
- ✅ Marcação de itens como comprados
- ✅ Finalização de listas
- ✅ Estatísticas em tempo real
- ✅ **Edição de itens** com tela dedicada
- ✅ **Compartilhamento de listas** via área de transferência
- ✅ **Preços opcionais** nos itens
- ✅ **Observações** nos itens
- ✅ Interface completa funcional

## 🔧 Próximos Passos

1. **Execute o comando de build_runner** para gerar os adapters:
   ```bash
   flutter packages pub run build_runner build
   ```

2. **Execute o app** para ver o exemplo funcionando:
   ```bash
   flutter run
   ```

3. **Personalize** os modelos conforme suas necessidades específicas

## 📚 Exemplos de Código

### Criar uma nova lista
```dart
final lista = ListaCompras(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  nome: 'Minha Lista',
  descricao: 'Lista para o supermercado',
  dataCriacao: DateTime.now(),
);

await HiveService.salvarListaCompras(lista);
```

### Adicionar um item
```dart
final item = Item(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  nome: 'Leite',
  quantidade: 2,
  preco: 4.50,
  dataCriacao: DateTime.now(),
);

lista.adicionarItem(item);
```

### Obter todas as listas
```dart
final listas = HiveService.obterTodasListasCompras();
final listasAtivas = HiveService.obterListasAtivas();
```

## ⚠️ Importante

- **Sempre execute o build_runner** após modificar os modelos
- **O Hive é inicializado automaticamente** no main.dart
- **Os dados são persistentes** entre sessões do app
- **Use os métodos do HiveService** para todas as operações de dados

## 🎯 Pronto para Usar!

Seu projeto está completamente configurado com o Hive. Execute os comandos acima e comece a usar o armazenamento local!
