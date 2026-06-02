// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Não Esquece!';

  @override
  String get myLists => 'Minhas Listas';

  @override
  String get newList => 'Nova Lista';

  @override
  String get listName => 'Nome da lista';

  @override
  String get createList => 'Criar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get save => 'Salvar';

  @override
  String get delete => 'Excluir';

  @override
  String get close => 'Fechar';

  @override
  String get error => 'Erro';

  @override
  String get success => 'Sucesso';

  @override
  String get loading => 'Carregando...';

  @override
  String get ok => 'OK';

  @override
  String get duplicateList => 'Duplicar lista';

  @override
  String get duplicateListSubtitle => 'Cria uma cópia com itens desmarcados';

  @override
  String get deleteList => 'Excluir lista';

  @override
  String listCreated(String name) {
    return 'Lista \"$name\" criada!';
  }

  @override
  String get open => 'ABRIR';

  @override
  String get pasteFromClipboard => 'Colar da área de transferência';

  @override
  String get importByCode => 'Importar por código';

  @override
  String get scanPhysicalList => 'Escanear lista física';

  @override
  String get reports => 'Relatórios';

  @override
  String get settings => 'Configurações';

  @override
  String get importCode => 'Código de importação';

  @override
  String get importCodeHint => 'Cole o código NE1: ou NE2: aqui';

  @override
  String get import => 'Importar';

  @override
  String get importSuccess => 'Lista importada com sucesso!';

  @override
  String get importError => 'Código inválido ou corrompido.';

  @override
  String get ocrConfirmTitle => 'Itens encontrados';

  @override
  String ocrConfirmMessage(int count) {
    return '$count itens detectados. Deseja criar uma lista com esses itens?';
  }

  @override
  String get ocrNoItems => 'Nenhum item detectado na imagem.';

  @override
  String get ocrCreateList => 'Criar Lista';

  @override
  String get emptyListTitle => 'Nenhuma lista ainda';

  @override
  String get emptyListSubtitle =>
      'Toque no + para criar sua primeira lista de compras!';

  @override
  String get emptyFinishedTitle => 'Nenhuma lista finalizada';

  @override
  String get emptyFinishedSubtitle => 'As listas finalizadas aparecerão aqui.';

  @override
  String get activeLists => 'Ativas';

  @override
  String get finishedLists => 'Finalizadas';

  @override
  String get listNotFound => 'Lista não encontrada.';

  @override
  String get groupByCategory => 'Agrupar por categoria';

  @override
  String get ungroupItems => 'Desagrupar itens';

  @override
  String get copyList => 'Copiar lista';

  @override
  String get generateShareCode => 'Gerar Código de Compartilhamento';

  @override
  String get deleteListTitle => 'Excluir Lista';

  @override
  String get deleteListConfirm => 'Tem certeza? Isso apagará todos os itens.';

  @override
  String get deletePermanently => 'EXCLUIR PERMANENTEMENTE';

  @override
  String get shareCodeError => 'Erro inesperado ao gerar código.';

  @override
  String get shareCodeCopied =>
      'Código copiado! Envie para quem quiser importar a lista.';

  @override
  String get shareCodeTitle => 'Código de Compartilhamento';

  @override
  String get shareCodeInstruction =>
      'Copie e envie por WhatsApp, SMS ou qualquer mensageiro:';

  @override
  String get copyCode => 'Copiar Código';

  @override
  String get codeCopied => 'Código copiado!';

  @override
  String get total => 'Total';

  @override
  String estimatedTotal(String value) {
    return 'Total estimado: $value';
  }

  @override
  String get finishShopping => 'Finalizar Compra';

  @override
  String get reopenList => 'Reabrir Lista';

  @override
  String get emptyList => 'Lista vazia. Adicione itens!';

  @override
  String get items => 'itens';

  @override
  String itemsCount(int bought, int total) {
    return '$bought/$total itens';
  }

  @override
  String get noCategory => 'Sem Categoria';

  @override
  String get shoppingList => 'Lista de Compras';

  @override
  String get pending => 'Falta pegar';

  @override
  String get alreadyGot => 'Já peguei';

  @override
  String get listCopied => 'Lista copiada para a área de transferência!';

  @override
  String get headerSummary => 'Resumo';

  @override
  String get totalItems => 'Total de itens';

  @override
  String get boughtItems => 'Itens comprados';

  @override
  String get pendingItems => 'Itens pendentes';

  @override
  String get totalSpent => 'Total gasto';

  @override
  String get totalPending => 'Total pendente';

  @override
  String get editItem => 'Editar Item';

  @override
  String get newItem => 'Novo Item';

  @override
  String get itemName => 'Nome do Item *';

  @override
  String get itemNameHint => 'Ex: Leite, Pão, Arroz...';

  @override
  String get quantity => 'Quantidade';

  @override
  String get priceOptional => 'Preço (opcional)';

  @override
  String get priceHint => 'Ex: 4,50';

  @override
  String get notesOptional => 'Observações (opcional)';

  @override
  String get notesHint => 'Ex: Marca preferida, quantidade específica...';

  @override
  String get categoryOptional => 'Corredor / Categoria (opcional)';

  @override
  String get none => 'Nenhuma';

  @override
  String get newCategory => 'Nova categoria...';

  @override
  String get saveChanges => 'Salvar Alterações';

  @override
  String get addItem => 'Adicionar Item';

  @override
  String get itemRequired => 'Nome do item é obrigatório';

  @override
  String get duplicateItem => 'Item Repetido';

  @override
  String duplicateItemMessage(String name) {
    return 'O item \"$name\" já está na lista. Deseja adicioná-lo/salvá-lo mesmo assim?';
  }

  @override
  String get saveAnyway => 'Salvar Mesmo Assim';

  @override
  String get preview => 'Preview:';

  @override
  String get priceNotSet => 'Preço não informado';

  @override
  String lastPaid(String value) {
    return 'Último pago: $value';
  }

  @override
  String obs(String text) {
    return 'Obs: $text';
  }

  @override
  String categorySuggestion(String item, String category) {
    return '\"$item\" já foi em \"$category\"';
  }

  @override
  String get useCategory => 'USAR';

  @override
  String get newCategoryTitle => 'Nova Categoria';

  @override
  String get categoryName => 'Nome da categoria';

  @override
  String get categoryNameHint => 'Ex: Congelados, Pet Shop...';

  @override
  String get typeAName => 'Digite um nome';

  @override
  String get categoryExists => 'Categoria já existe';

  @override
  String get create => 'CRIAR';

  @override
  String get appearance => 'Aparência';

  @override
  String get darkMode => 'Modo Escuro';

  @override
  String get darkModeOn => 'Tema escuro ativado';

  @override
  String get darkModeOff => 'Tema claro ativado';

  @override
  String get googleAccount => 'Conta Google';

  @override
  String get signedInAs => 'Conectado como';

  @override
  String get signIn => 'Entrar com Google';

  @override
  String get signOut => 'Desconectar';

  @override
  String get aisles => 'Corredores / Categorias';

  @override
  String get driveBackup => 'Backup no Google Drive';

  @override
  String get createBackup => 'Criar Backup Agora';

  @override
  String get restoreBackup => 'Restaurar Backup';

  @override
  String get backupSuccess => 'Backup realizado com sucesso!';

  @override
  String get backupError => 'Erro no backup';

  @override
  String get restoreSuccess => 'Backup restaurado com sucesso!';

  @override
  String get restoreError => 'Erro ao restaurar';

  @override
  String get aboutBackup => 'Sobre o Backup';

  @override
  String get backupInfo =>
      'Seus dados são salvos no Google Drive em uma pasta privada do app. Nenhum dado é enviado para nossos servidores.';

  @override
  String get legal => 'Legal';

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String get deleteCategory => 'Excluir Categoria';

  @override
  String deleteCategoryConfirm(String name) {
    return 'Excluir \"$name\"?';
  }

  @override
  String get noCategoriesYet => 'Nenhuma categoria cadastrada.';

  @override
  String get addCategoryHint =>
      'Adicione categorias para organizar seus itens por corredor do mercado.';

  @override
  String get dragToReorder => 'Arraste para reordenar';

  @override
  String get reportTitle => 'Relatório de Compras';

  @override
  String get exportReport => 'Exportar Relatório';

  @override
  String get noListsForFilters => 'Nenhuma lista encontrada para os filtros.';

  @override
  String get filterByDate => 'Filtrar por data';

  @override
  String get search => 'Buscar...';

  @override
  String get showItems => 'Mostrar itens';

  @override
  String get hideItems => 'Ocultar itens';

  @override
  String get totalSpentLabel => 'Gasto';

  @override
  String get totalPendingLabel => 'Pendente';

  @override
  String get totalLabel => 'Total';

  @override
  String listsFound(int count) {
    return '$count listas encontradas';
  }

  @override
  String get exportPdf => 'Exportar PDF';

  @override
  String get exportExcel => 'Exportar Excel';

  @override
  String get exportCsv => 'Exportar CSV';

  @override
  String exportSuccess(String type) {
    return '$type exportado com sucesso!';
  }

  @override
  String exportError(String type, String error) {
    return 'Erro ao gerar $type: $error';
  }

  @override
  String get bought => 'Comprado';

  @override
  String get notBought => 'Pendente';

  @override
  String get finalized => 'Finalizada';

  @override
  String get inProgress => 'Em Andamento';

  @override
  String get proPlan => 'Não Esquece! PRO';

  @override
  String get proSubtitle =>
      'Desbloqueie todo o poder do aplicativo com uma\nCOMPRA ÚNICA VITALÍCIA.';

  @override
  String get proFeatureOcr => 'Scanner OCR de listas físicas';

  @override
  String get proFeatureExport => 'Exportação ilimitada para PDF e Excel';

  @override
  String get proFeatureHistory => 'Histórico de Preços infinito';

  @override
  String get proPayOnce => 'Pague uma vez, use para sempre!';

  @override
  String get proUnlock => 'DESBLOQUEAR AGORA';

  @override
  String get proWelcome =>
      '🎉 Bem-vindo ao PRO! Funcionalidades desbloqueadas.';

  @override
  String get proFailed => 'Pagamento cancelado ou falhou.';

  @override
  String get proRestore => 'Restaurar';

  @override
  String get proRestoring => 'Buscando compras anteriores...';

  @override
  String get privacyTitle => 'Não Esquece! — Política de Privacidade';

  @override
  String get privacyIntro =>
      'Esta Política de Privacidade descreve como o aplicativo \"Não Esquece!\" trata os seus dados pessoais. Leia com atenção.';

  @override
  String get privacyDataTitle => '1. Dados Coletados';

  @override
  String get privacyDataBody =>
      'O aplicativo NÃO coleta nenhum dado pessoal em servidores próprios. Todos os dados inseridos (listas de compras, itens, preços) são armazenados exclusivamente:\n\n• No armazenamento local do seu dispositivo (Hive/SQLite).\n• No seu próprio Google Drive (pasta privada do app), caso você opte por ativar o backup.';

  @override
  String get privacyDriveTitle => '2. Google Drive e Google Sign-In';

  @override
  String get privacyDriveBody =>
      'Se você optar por fazer backup, o aplicativo solicitará acesso à sua conta Google com o escopo \"drive.appdata\". Este escopo permite salvar arquivos apenas na pasta oculta e privada do app no seu Google Drive.\n\nNenhum outro dado da sua conta Google é acessado. Os arquivos de backup não ficam visíveis na interface normal do Google Drive.';

  @override
  String get privacySharingTitle => '3. Compartilhamento de Dados';

  @override
  String get privacySharingBody =>
      'O aplicativo NÃO compartilha seus dados com terceiros. Os códigos de compartilhamento de listas são gerados localmente no seu dispositivo e trafegam apenas pelos canais que você escolher (WhatsApp, SMS, e-mail, etc.).';

  @override
  String get privacyStorageTitle => '4. Armazenamento e Segurança';

  @override
  String get privacyStorageBody =>
      'Seus dados ficam sob controle exclusivo seu:\n\n• Dados locais: armazenados no seu dispositivo.\n• Backup: na sua conta Google Drive, protegida pelas políticas de segurança do Google.\n\nNão temos acesso, nem capacidade de acessar, seus dados pessoais.';

  @override
  String get privacyDeleteTitle => '5. Exclusão de Dados';

  @override
  String get privacyDeleteBody =>
      'Para excluir seus dados:\n\n• Dados locais: desinstale o aplicativo.\n• Backup no Drive: acesse drive.google.com/drive/appdata e exclua o arquivo \"nao_esquece_backup.json\".';

  @override
  String get privacyChangesTitle => '6. Alterações nesta Política';

  @override
  String get privacyChangesBody =>
      'Podemos atualizar esta política periodicamente. Atualizações relevantes serão comunicadas dentro do próprio app.';

  @override
  String get privacyContactTitle => '7. Contato';

  @override
  String get privacyContactBody =>
      'Dúvidas sobre privacidade? Entre em contato pelo e-mail informado na página do app na Play Store.';

  @override
  String get privacyLastUpdate => 'Última atualização: março de 2026';

  @override
  String get onboardingWelcomeTitle => 'Bem-vindo ao\nNão Esquece!';

  @override
  String get onboardingWelcomeDesc =>
      'Nunca mais volte do mercado sem um item. Crie e gerencie suas listas de compras de forma simples e inteligente.';

  @override
  String get onboardingOrganizeTitle => 'Organize\nsuas compras';

  @override
  String get onboardingOrganizeDesc =>
      'Adicione itens com preço, quantidade e observações. Acompanhe o total estimado em tempo real enquanto faz as compras.';

  @override
  String get onboardingHistoryTitle => 'Histórico\nde preços';

  @override
  String get onboardingHistoryDesc =>
      'Ao finalizar uma lista, os preços são salvos automaticamente. Na próxima compra, veja se o item ficou mais caro ou mais barato.';

  @override
  String get onboardingScannerTitle => 'Scanner\nde listas';

  @override
  String get onboardingScannerDesc =>
      'Fotografe uma lista escrita (letras de forma ou impressa) e o app converte os itens automaticamente usando OCR.';

  @override
  String get onboardingShareTitle => 'Compartilhe\nsuas listas';

  @override
  String get onboardingShareDesc =>
      'Gere um código compacto e envie por WhatsApp ou SMS. A outra pessoa importa a lista completa no app instantaneamente.';

  @override
  String get onboardingTextShareTitle => 'Compartilhe\ncomo texto';

  @override
  String get onboardingTextShareDesc =>
      'Copie a lista formatada com preços unitários e totais para colar no WhatsApp, sem precisar que o outro tenha o app.';

  @override
  String get onboardingWidgetTitle => 'Widget na\ntela inicial';

  @override
  String get onboardingWidgetDesc =>
      'Veja os itens pendentes da sua lista ativa diretamente na tela inicial do celular, sem nem precisar abrir o app.';

  @override
  String get onboardingBackupTitle => 'Backup\nautomático';

  @override
  String get onboardingBackupDesc =>
      'Seus dados ficam salvos no Google Drive. Troque de aparelho e recupere todas as suas listas com 1 toque.';

  @override
  String get onboardingExportTitle => 'Exporte\nsuas listas';

  @override
  String get onboardingExportDesc =>
      'Exporte suas listas em PDF, Excel ou CSV para imprimir, arquivar ou analisar seus gastos como preferir.';

  @override
  String get onboardingSkip => 'Pular';

  @override
  String get onboardingNext => 'Próximo';

  @override
  String get onboardingStart => 'Começar!';

  @override
  String get removeItem => 'Excluir';

  @override
  String removeItemConfirm(String name) {
    return 'Remover \"$name\"?';
  }

  @override
  String get editListName => 'Renomear Lista';

  @override
  String get listNameLabel => 'Nome da lista';

  @override
  String get backupLoginRequired =>
      'Faça login com o Google primeiro nas Configurações.';

  @override
  String get shareCode => 'Código de Compartilhamento';

  @override
  String get copy => 'COPIAR';

  @override
  String get name => 'Nome';

  @override
  String get emptyListAdd => 'Lista vazia. Adicione itens!';

  @override
  String get finishPurchase => 'Finalizar Compra';

  @override
  String get cart => 'Carrinho';

  @override
  String get remaining => 'Faltam';

  @override
  String get itemNameRequired => 'Nome do item é obrigatório';

  @override
  String get itemNameLabel => 'Nome do Item *';

  @override
  String get aisleOptional => 'Corredor / Categoria (opcional)';

  @override
  String get newCategoryEllipsis => 'Nova categoria...';

  @override
  String get allDates => 'Todas as datas';

  @override
  String get descName => 'Desc / Nome';

  @override
  String get qty => 'Qtd';

  @override
  String get val => 'Valor';

  @override
  String get grandTotal => 'TOTAL GERAL:';
}
