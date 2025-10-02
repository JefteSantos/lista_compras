# [INSIRA O NOME DO APP AQUI]

Aplicativo Flutter para criar, salvar, atualizar, compartilhar e consultar o histórico de listas de compras. Este repositório contém o código-fonte do projeto desenvolvido por Paulo.

> Substitua o marcador acima por um nome curto e memorável quando definir o nome oficial do app.

## ✨ Principais recursos
- **Criar listas**: itens com nome, quantidade, unidade e observações.
- **Salvar e atualizar**: edite itens e listas a qualquer momento com feedback visual.
- **Compartilhar**: envie a lista por WhatsApp, e-mail, apps sociais ou exporte como texto/arquivo.
- **Histórico**: reabra listas antigas, duplique e reutilize modelos.
- **Buscar e filtrar**: encontre itens rapidamente (por status, categoria, texto).
- **Marcar como comprado**: riscar itens e ver progresso.
- **Multiplataforma**: Android e Web (Chrome) já suportados.

## 🗃 Persistência de dados (atual e planejado)
- **Local (padrão)**: `shared_preferences` ou `hive` para listas recentes e preferências.
- **Nuvem (futuro opcional)**: provider a definir (ex.: Firebase/Firestore) para backup e sincronização.

## 🔄 Compartilhamento
- **Android**: intent de compartilhamento de texto/arquivo.
- **Web**: Web Share API (quando disponível) e fallback para copiar texto.

## 📱 Telas esperadas
- Lista de listas (home) → criar nova, abrir existente, pesquisar
- Editor de lista → adicionar/editar/remover itens, marcar como comprado
- Histórico → listas antigas com data, duplicar/renomear
- Compartilhar/Exportar → gerar texto limpo e/ou arquivo

## 🛠 Pré-requisitos
- Flutter (canal stable) no PATH
- Android Studio com Android SDK (ou navegador Chrome para Web)
- Git instalado

Verifique rapidamente:
```powershell
flutter --version
flutter doctor
flutter doctor --android-licenses
```

## 🚀 Como executar
Na pasta do projeto:
```bash
flutter pub get
flutter run                  # dispositivo/emulador padrão
# ou Web:
flutter run -d chrome
```

## ⚙️ Configuração Android (resumo)
- Android Studio > SDK Manager
  - SDK Platforms: instale a API estável mais recente
  - SDK Tools: ative "Android SDK Command-line Tools" e "Build-Tools"
- Variáveis (Windows exemplo):
```powershell
setx ANDROID_SDK_ROOT "C:\Users\Paulo\AppData\Local\Android\Sdk"
```
Abra um terminal novo e confira com `flutter doctor`.

## 📦 Estrutura sugerida
```
lib/
  main.dart
  app/
    app.dart              # MaterialApp/rotas/tema
    router.dart           # rotas nomeadas/navegação
    theme.dart            # ThemeData
  features/
    shopping_list/        # telas, estados e serviços da lista
    history/              # histórico de listas
    sharing/              # lógica de compartilhamento/exportação
  data/
    models/               # modelos (Item, Lista, etc.)
    local/                # storage local (hive/shared_prefs)
    remote/               # storage remoto (futuro)
  widgets/                # componentes reutilizáveis
```

## 🧪 Testes
```bash
flutter test
```

## 🧭 Convenções e qualidade
- Nomenclatura clara e componentes pequenos
- Evitar lógica pesada em widgets; preferir camadas em `features/` e `data/`
- Commits: `feat:`, `fix:`, `refactor:`, `test:`, `docs:`

## 🧰 Personalização do projeto
- Nome do app: edite este README e o `pubspec.yaml` quando definir o nome oficial.
- Ícones/splash (Android):
  ```bash
  flutter pub add flutter_launcher_icons
  # configure no pubspec.yaml
  flutter pub run flutter_launcher_icons
  ```
- Ícones/splash (Web): atualize `web/` (manifest, favicon) conforme necessário.

## 📸 Capturas de tela
Coloque imagens em `assets/screenshots/` e referencie-as aqui.

## 🗺 Roadmap curto
- Categorias de itens e filtros por categoria
- Exportar como CSV/JSON
- Importar lista de arquivos CSV/JSON
- Backup/sync em nuvem (opt-in)
- Modo escuro

## 🤝 Contribuição
1. Abra uma issue descrevendo a proposta/bug
2. Crie um branch a partir de `main`
3. Envie PR com descrição objetiva e screenshots quando aplicável

## 📄 Licença
Defina a licença (ex.: MIT) e adicione `LICENSE` na raiz. 
