import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'Não Esquece!'**
  String get appTitle;

  /// No description provided for @myLists.
  ///
  /// In pt, this message translates to:
  /// **'Minhas Listas'**
  String get myLists;

  /// No description provided for @newList.
  ///
  /// In pt, this message translates to:
  /// **'Nova Lista'**
  String get newList;

  /// No description provided for @listName.
  ///
  /// In pt, this message translates to:
  /// **'Nome da lista'**
  String get listName;

  /// No description provided for @createList.
  ///
  /// In pt, this message translates to:
  /// **'Criar'**
  String get createList;

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get delete;

  /// No description provided for @close.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get close;

  /// No description provided for @error.
  ///
  /// In pt, this message translates to:
  /// **'Erro'**
  String get error;

  /// No description provided for @success.
  ///
  /// In pt, this message translates to:
  /// **'Sucesso'**
  String get success;

  /// No description provided for @loading.
  ///
  /// In pt, this message translates to:
  /// **'Carregando...'**
  String get loading;

  /// No description provided for @ok.
  ///
  /// In pt, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @duplicateList.
  ///
  /// In pt, this message translates to:
  /// **'Duplicar lista'**
  String get duplicateList;

  /// No description provided for @duplicateListSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Cria uma cópia com itens desmarcados'**
  String get duplicateListSubtitle;

  /// No description provided for @deleteList.
  ///
  /// In pt, this message translates to:
  /// **'Excluir lista'**
  String get deleteList;

  /// No description provided for @listCreated.
  ///
  /// In pt, this message translates to:
  /// **'Lista \"{name}\" criada!'**
  String listCreated(String name);

  /// No description provided for @open.
  ///
  /// In pt, this message translates to:
  /// **'ABRIR'**
  String get open;

  /// No description provided for @pasteFromClipboard.
  ///
  /// In pt, this message translates to:
  /// **'Colar da área de transferência'**
  String get pasteFromClipboard;

  /// No description provided for @importByCode.
  ///
  /// In pt, this message translates to:
  /// **'Importar por código'**
  String get importByCode;

  /// No description provided for @scanPhysicalList.
  ///
  /// In pt, this message translates to:
  /// **'Escanear lista física'**
  String get scanPhysicalList;

  /// No description provided for @reports.
  ///
  /// In pt, this message translates to:
  /// **'Relatórios'**
  String get reports;

  /// No description provided for @settings.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get settings;

  /// No description provided for @importCode.
  ///
  /// In pt, this message translates to:
  /// **'Código de importação'**
  String get importCode;

  /// No description provided for @importCodeHint.
  ///
  /// In pt, this message translates to:
  /// **'Cole o código NE1: ou NE2: aqui'**
  String get importCodeHint;

  /// No description provided for @import.
  ///
  /// In pt, this message translates to:
  /// **'Importar'**
  String get import;

  /// No description provided for @importSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Lista importada com sucesso!'**
  String get importSuccess;

  /// No description provided for @importError.
  ///
  /// In pt, this message translates to:
  /// **'Código inválido ou corrompido.'**
  String get importError;

  /// No description provided for @ocrConfirmTitle.
  ///
  /// In pt, this message translates to:
  /// **'Itens encontrados'**
  String get ocrConfirmTitle;

  /// No description provided for @ocrConfirmMessage.
  ///
  /// In pt, this message translates to:
  /// **'{count} itens detectados. Deseja criar uma lista com esses itens?'**
  String ocrConfirmMessage(int count);

  /// No description provided for @ocrNoItems.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum item detectado na imagem.'**
  String get ocrNoItems;

  /// No description provided for @ocrCreateList.
  ///
  /// In pt, this message translates to:
  /// **'Criar Lista'**
  String get ocrCreateList;

  /// No description provided for @emptyListTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma lista ainda'**
  String get emptyListTitle;

  /// No description provided for @emptyListSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Toque no + para criar sua primeira lista de compras!'**
  String get emptyListSubtitle;

  /// No description provided for @emptyFinishedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma lista finalizada'**
  String get emptyFinishedTitle;

  /// No description provided for @emptyFinishedSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'As listas finalizadas aparecerão aqui.'**
  String get emptyFinishedSubtitle;

  /// No description provided for @activeLists.
  ///
  /// In pt, this message translates to:
  /// **'Ativas'**
  String get activeLists;

  /// No description provided for @finishedLists.
  ///
  /// In pt, this message translates to:
  /// **'Finalizadas'**
  String get finishedLists;

  /// No description provided for @listNotFound.
  ///
  /// In pt, this message translates to:
  /// **'Lista não encontrada.'**
  String get listNotFound;

  /// No description provided for @groupByCategory.
  ///
  /// In pt, this message translates to:
  /// **'Agrupar por categoria'**
  String get groupByCategory;

  /// No description provided for @ungroupItems.
  ///
  /// In pt, this message translates to:
  /// **'Desagrupar itens'**
  String get ungroupItems;

  /// No description provided for @copyList.
  ///
  /// In pt, this message translates to:
  /// **'Copiar lista'**
  String get copyList;

  /// No description provided for @generateShareCode.
  ///
  /// In pt, this message translates to:
  /// **'Gerar Código de Compartilhamento'**
  String get generateShareCode;

  /// No description provided for @deleteListTitle.
  ///
  /// In pt, this message translates to:
  /// **'Excluir Lista'**
  String get deleteListTitle;

  /// No description provided for @deleteListConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Tem certeza? Isso apagará todos os itens.'**
  String get deleteListConfirm;

  /// No description provided for @deletePermanently.
  ///
  /// In pt, this message translates to:
  /// **'EXCLUIR PERMANENTEMENTE'**
  String get deletePermanently;

  /// No description provided for @shareCodeError.
  ///
  /// In pt, this message translates to:
  /// **'Erro inesperado ao gerar código.'**
  String get shareCodeError;

  /// No description provided for @shareCodeCopied.
  ///
  /// In pt, this message translates to:
  /// **'Código copiado! Envie para quem quiser importar a lista.'**
  String get shareCodeCopied;

  /// No description provided for @shareCodeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Código de Compartilhamento'**
  String get shareCodeTitle;

  /// No description provided for @shareCodeInstruction.
  ///
  /// In pt, this message translates to:
  /// **'Copie e envie por WhatsApp, SMS ou qualquer mensageiro:'**
  String get shareCodeInstruction;

  /// No description provided for @copyCode.
  ///
  /// In pt, this message translates to:
  /// **'Copiar Código'**
  String get copyCode;

  /// No description provided for @codeCopied.
  ///
  /// In pt, this message translates to:
  /// **'Código copiado!'**
  String get codeCopied;

  /// No description provided for @total.
  ///
  /// In pt, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @estimatedTotal.
  ///
  /// In pt, this message translates to:
  /// **'Total estimado: {value}'**
  String estimatedTotal(String value);

  /// No description provided for @finishShopping.
  ///
  /// In pt, this message translates to:
  /// **'Finalizar Compra'**
  String get finishShopping;

  /// No description provided for @reopenList.
  ///
  /// In pt, this message translates to:
  /// **'Reabrir Lista'**
  String get reopenList;

  /// No description provided for @emptyList.
  ///
  /// In pt, this message translates to:
  /// **'Lista vazia. Adicione itens!'**
  String get emptyList;

  /// No description provided for @items.
  ///
  /// In pt, this message translates to:
  /// **'itens'**
  String get items;

  /// No description provided for @itemsCount.
  ///
  /// In pt, this message translates to:
  /// **'{bought}/{total} itens'**
  String itemsCount(int bought, int total);

  /// No description provided for @noCategory.
  ///
  /// In pt, this message translates to:
  /// **'Sem Categoria'**
  String get noCategory;

  /// No description provided for @shoppingList.
  ///
  /// In pt, this message translates to:
  /// **'Lista de Compras'**
  String get shoppingList;

  /// No description provided for @pending.
  ///
  /// In pt, this message translates to:
  /// **'Falta pegar'**
  String get pending;

  /// No description provided for @alreadyGot.
  ///
  /// In pt, this message translates to:
  /// **'Já peguei'**
  String get alreadyGot;

  /// No description provided for @listCopied.
  ///
  /// In pt, this message translates to:
  /// **'Lista copiada para a área de transferência!'**
  String get listCopied;

  /// No description provided for @headerSummary.
  ///
  /// In pt, this message translates to:
  /// **'Resumo'**
  String get headerSummary;

  /// No description provided for @totalItems.
  ///
  /// In pt, this message translates to:
  /// **'Total de itens'**
  String get totalItems;

  /// No description provided for @boughtItems.
  ///
  /// In pt, this message translates to:
  /// **'Itens comprados'**
  String get boughtItems;

  /// No description provided for @pendingItems.
  ///
  /// In pt, this message translates to:
  /// **'Itens pendentes'**
  String get pendingItems;

  /// No description provided for @totalSpent.
  ///
  /// In pt, this message translates to:
  /// **'Total gasto'**
  String get totalSpent;

  /// No description provided for @totalPending.
  ///
  /// In pt, this message translates to:
  /// **'Total pendente'**
  String get totalPending;

  /// No description provided for @editItem.
  ///
  /// In pt, this message translates to:
  /// **'Editar Item'**
  String get editItem;

  /// No description provided for @newItem.
  ///
  /// In pt, this message translates to:
  /// **'Novo Item'**
  String get newItem;

  /// No description provided for @itemName.
  ///
  /// In pt, this message translates to:
  /// **'Nome do Item *'**
  String get itemName;

  /// No description provided for @itemNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex: Leite, Pão, Arroz...'**
  String get itemNameHint;

  /// No description provided for @quantity.
  ///
  /// In pt, this message translates to:
  /// **'Quantidade'**
  String get quantity;

  /// No description provided for @priceOptional.
  ///
  /// In pt, this message translates to:
  /// **'Preço (opcional)'**
  String get priceOptional;

  /// No description provided for @priceHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex: 4,50'**
  String get priceHint;

  /// No description provided for @notesOptional.
  ///
  /// In pt, this message translates to:
  /// **'Observações (opcional)'**
  String get notesOptional;

  /// No description provided for @notesHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex: Marca preferida, quantidade específica...'**
  String get notesHint;

  /// No description provided for @categoryOptional.
  ///
  /// In pt, this message translates to:
  /// **'Corredor / Categoria (opcional)'**
  String get categoryOptional;

  /// No description provided for @none.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma'**
  String get none;

  /// No description provided for @newCategory.
  ///
  /// In pt, this message translates to:
  /// **'Nova categoria...'**
  String get newCategory;

  /// No description provided for @saveChanges.
  ///
  /// In pt, this message translates to:
  /// **'Salvar Alterações'**
  String get saveChanges;

  /// No description provided for @addItem.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar Item'**
  String get addItem;

  /// No description provided for @itemRequired.
  ///
  /// In pt, this message translates to:
  /// **'Nome do item é obrigatório'**
  String get itemRequired;

  /// No description provided for @duplicateItem.
  ///
  /// In pt, this message translates to:
  /// **'Item Repetido'**
  String get duplicateItem;

  /// No description provided for @duplicateItemMessage.
  ///
  /// In pt, this message translates to:
  /// **'O item \"{name}\" já está na lista. Deseja adicioná-lo/salvá-lo mesmo assim?'**
  String duplicateItemMessage(String name);

  /// No description provided for @saveAnyway.
  ///
  /// In pt, this message translates to:
  /// **'Salvar Mesmo Assim'**
  String get saveAnyway;

  /// No description provided for @preview.
  ///
  /// In pt, this message translates to:
  /// **'Preview:'**
  String get preview;

  /// No description provided for @priceNotSet.
  ///
  /// In pt, this message translates to:
  /// **'Preço não informado'**
  String get priceNotSet;

  /// No description provided for @lastPaid.
  ///
  /// In pt, this message translates to:
  /// **'Último pago: {value}'**
  String lastPaid(String value);

  /// No description provided for @obs.
  ///
  /// In pt, this message translates to:
  /// **'Obs: {text}'**
  String obs(String text);

  /// No description provided for @categorySuggestion.
  ///
  /// In pt, this message translates to:
  /// **'\"{item}\" já foi em \"{category}\"'**
  String categorySuggestion(String item, String category);

  /// No description provided for @useCategory.
  ///
  /// In pt, this message translates to:
  /// **'USAR'**
  String get useCategory;

  /// No description provided for @newCategoryTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nova Categoria'**
  String get newCategoryTitle;

  /// No description provided for @categoryName.
  ///
  /// In pt, this message translates to:
  /// **'Nome da categoria'**
  String get categoryName;

  /// No description provided for @categoryNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex: Congelados, Pet Shop...'**
  String get categoryNameHint;

  /// No description provided for @typeAName.
  ///
  /// In pt, this message translates to:
  /// **'Digite um nome'**
  String get typeAName;

  /// No description provided for @categoryExists.
  ///
  /// In pt, this message translates to:
  /// **'Categoria já existe'**
  String get categoryExists;

  /// No description provided for @create.
  ///
  /// In pt, this message translates to:
  /// **'CRIAR'**
  String get create;

  /// No description provided for @appearance.
  ///
  /// In pt, this message translates to:
  /// **'Aparência'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In pt, this message translates to:
  /// **'Modo Escuro'**
  String get darkMode;

  /// No description provided for @darkModeOn.
  ///
  /// In pt, this message translates to:
  /// **'Tema escuro ativado'**
  String get darkModeOn;

  /// No description provided for @darkModeOff.
  ///
  /// In pt, this message translates to:
  /// **'Tema claro ativado'**
  String get darkModeOff;

  /// No description provided for @googleAccount.
  ///
  /// In pt, this message translates to:
  /// **'Conta Google'**
  String get googleAccount;

  /// No description provided for @signedInAs.
  ///
  /// In pt, this message translates to:
  /// **'Conectado como'**
  String get signedInAs;

  /// No description provided for @signIn.
  ///
  /// In pt, this message translates to:
  /// **'Entrar com Google'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In pt, this message translates to:
  /// **'Desconectar'**
  String get signOut;

  /// No description provided for @aisles.
  ///
  /// In pt, this message translates to:
  /// **'Corredores / Categorias'**
  String get aisles;

  /// No description provided for @driveBackup.
  ///
  /// In pt, this message translates to:
  /// **'Backup no Google Drive'**
  String get driveBackup;

  /// No description provided for @createBackup.
  ///
  /// In pt, this message translates to:
  /// **'Criar Backup Agora'**
  String get createBackup;

  /// No description provided for @restoreBackup.
  ///
  /// In pt, this message translates to:
  /// **'Restaurar Backup'**
  String get restoreBackup;

  /// No description provided for @backupSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Backup realizado com sucesso!'**
  String get backupSuccess;

  /// No description provided for @backupError.
  ///
  /// In pt, this message translates to:
  /// **'Erro no backup'**
  String get backupError;

  /// No description provided for @restoreSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Backup restaurado com sucesso!'**
  String get restoreSuccess;

  /// No description provided for @restoreError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao restaurar'**
  String get restoreError;

  /// No description provided for @aboutBackup.
  ///
  /// In pt, this message translates to:
  /// **'Sobre o Backup'**
  String get aboutBackup;

  /// No description provided for @backupInfo.
  ///
  /// In pt, this message translates to:
  /// **'Seus dados são salvos no Google Drive em uma pasta privada do app. Nenhum dado é enviado para nossos servidores.'**
  String get backupInfo;

  /// No description provided for @legal.
  ///
  /// In pt, this message translates to:
  /// **'Legal'**
  String get legal;

  /// No description provided for @privacyPolicy.
  ///
  /// In pt, this message translates to:
  /// **'Política de Privacidade'**
  String get privacyPolicy;

  /// No description provided for @deleteCategory.
  ///
  /// In pt, this message translates to:
  /// **'Excluir Categoria'**
  String get deleteCategory;

  /// No description provided for @deleteCategoryConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Excluir \"{name}\"?'**
  String deleteCategoryConfirm(String name);

  /// No description provided for @noCategoriesYet.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma categoria cadastrada.'**
  String get noCategoriesYet;

  /// No description provided for @addCategoryHint.
  ///
  /// In pt, this message translates to:
  /// **'Adicione categorias para organizar seus itens por corredor do mercado.'**
  String get addCategoryHint;

  /// No description provided for @dragToReorder.
  ///
  /// In pt, this message translates to:
  /// **'Arraste para reordenar'**
  String get dragToReorder;

  /// No description provided for @reportTitle.
  ///
  /// In pt, this message translates to:
  /// **'Relatório de Compras'**
  String get reportTitle;

  /// No description provided for @exportReport.
  ///
  /// In pt, this message translates to:
  /// **'Exportar Relatório'**
  String get exportReport;

  /// No description provided for @noListsForFilters.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma lista encontrada para os filtros.'**
  String get noListsForFilters;

  /// No description provided for @filterByDate.
  ///
  /// In pt, this message translates to:
  /// **'Filtrar por data'**
  String get filterByDate;

  /// No description provided for @search.
  ///
  /// In pt, this message translates to:
  /// **'Buscar...'**
  String get search;

  /// No description provided for @showItems.
  ///
  /// In pt, this message translates to:
  /// **'Mostrar itens'**
  String get showItems;

  /// No description provided for @hideItems.
  ///
  /// In pt, this message translates to:
  /// **'Ocultar itens'**
  String get hideItems;

  /// No description provided for @totalSpentLabel.
  ///
  /// In pt, this message translates to:
  /// **'Gasto'**
  String get totalSpentLabel;

  /// No description provided for @totalPendingLabel.
  ///
  /// In pt, this message translates to:
  /// **'Pendente'**
  String get totalPendingLabel;

  /// No description provided for @totalLabel.
  ///
  /// In pt, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @listsFound.
  ///
  /// In pt, this message translates to:
  /// **'{count} listas encontradas'**
  String listsFound(int count);

  /// No description provided for @exportPdf.
  ///
  /// In pt, this message translates to:
  /// **'Exportar PDF'**
  String get exportPdf;

  /// No description provided for @exportExcel.
  ///
  /// In pt, this message translates to:
  /// **'Exportar Excel'**
  String get exportExcel;

  /// No description provided for @exportCsv.
  ///
  /// In pt, this message translates to:
  /// **'Exportar CSV'**
  String get exportCsv;

  /// No description provided for @exportSuccess.
  ///
  /// In pt, this message translates to:
  /// **'{type} exportado com sucesso!'**
  String exportSuccess(String type);

  /// No description provided for @exportError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao gerar {type}: {error}'**
  String exportError(String type, String error);

  /// No description provided for @bought.
  ///
  /// In pt, this message translates to:
  /// **'Comprado'**
  String get bought;

  /// No description provided for @notBought.
  ///
  /// In pt, this message translates to:
  /// **'Pendente'**
  String get notBought;

  /// No description provided for @finalized.
  ///
  /// In pt, this message translates to:
  /// **'Finalizada'**
  String get finalized;

  /// No description provided for @inProgress.
  ///
  /// In pt, this message translates to:
  /// **'Em Andamento'**
  String get inProgress;

  /// No description provided for @proPlan.
  ///
  /// In pt, this message translates to:
  /// **'Não Esquece! PRO'**
  String get proPlan;

  /// No description provided for @proSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Desbloqueie todo o poder do aplicativo com uma\nCOMPRA ÚNICA VITALÍCIA.'**
  String get proSubtitle;

  /// No description provided for @proFeatureOcr.
  ///
  /// In pt, this message translates to:
  /// **'Scanner OCR de listas físicas'**
  String get proFeatureOcr;

  /// No description provided for @proFeatureExport.
  ///
  /// In pt, this message translates to:
  /// **'Exportação ilimitada para PDF e Excel'**
  String get proFeatureExport;

  /// No description provided for @proFeatureHistory.
  ///
  /// In pt, this message translates to:
  /// **'Histórico de Preços infinito'**
  String get proFeatureHistory;

  /// No description provided for @proPayOnce.
  ///
  /// In pt, this message translates to:
  /// **'Pague uma vez, use para sempre!'**
  String get proPayOnce;

  /// No description provided for @proUnlock.
  ///
  /// In pt, this message translates to:
  /// **'DESBLOQUEAR AGORA'**
  String get proUnlock;

  /// No description provided for @proWelcome.
  ///
  /// In pt, this message translates to:
  /// **'🎉 Bem-vindo ao PRO! Funcionalidades desbloqueadas.'**
  String get proWelcome;

  /// No description provided for @proFailed.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento cancelado ou falhou.'**
  String get proFailed;

  /// No description provided for @proRestore.
  ///
  /// In pt, this message translates to:
  /// **'Restaurar'**
  String get proRestore;

  /// No description provided for @proRestoring.
  ///
  /// In pt, this message translates to:
  /// **'Buscando compras anteriores...'**
  String get proRestoring;

  /// No description provided for @privacyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Não Esquece! — Política de Privacidade'**
  String get privacyTitle;

  /// No description provided for @privacyIntro.
  ///
  /// In pt, this message translates to:
  /// **'Esta Política de Privacidade descreve como o aplicativo \"Não Esquece!\" trata os seus dados pessoais. Leia com atenção.'**
  String get privacyIntro;

  /// No description provided for @privacyDataTitle.
  ///
  /// In pt, this message translates to:
  /// **'1. Dados Coletados'**
  String get privacyDataTitle;

  /// No description provided for @privacyDataBody.
  ///
  /// In pt, this message translates to:
  /// **'O aplicativo NÃO coleta nenhum dado pessoal em servidores próprios. Todos os dados inseridos (listas de compras, itens, preços) são armazenados exclusivamente:\n\n• No armazenamento local do seu dispositivo (Hive/SQLite).\n• No seu próprio Google Drive (pasta privada do app), caso você opte por ativar o backup.'**
  String get privacyDataBody;

  /// No description provided for @privacyDriveTitle.
  ///
  /// In pt, this message translates to:
  /// **'2. Google Drive e Google Sign-In'**
  String get privacyDriveTitle;

  /// No description provided for @privacyDriveBody.
  ///
  /// In pt, this message translates to:
  /// **'Se você optar por fazer backup, o aplicativo solicitará acesso à sua conta Google com o escopo \"drive.appdata\". Este escopo permite salvar arquivos apenas na pasta oculta e privada do app no seu Google Drive.\n\nNenhum outro dado da sua conta Google é acessado. Os arquivos de backup não ficam visíveis na interface normal do Google Drive.'**
  String get privacyDriveBody;

  /// No description provided for @privacySharingTitle.
  ///
  /// In pt, this message translates to:
  /// **'3. Compartilhamento de Dados'**
  String get privacySharingTitle;

  /// No description provided for @privacySharingBody.
  ///
  /// In pt, this message translates to:
  /// **'O aplicativo NÃO compartilha seus dados com terceiros. Os códigos de compartilhamento de listas são gerados localmente no seu dispositivo e trafegam apenas pelos canais que você escolher (WhatsApp, SMS, e-mail, etc.).'**
  String get privacySharingBody;

  /// No description provided for @privacyStorageTitle.
  ///
  /// In pt, this message translates to:
  /// **'4. Armazenamento e Segurança'**
  String get privacyStorageTitle;

  /// No description provided for @privacyStorageBody.
  ///
  /// In pt, this message translates to:
  /// **'Seus dados ficam sob controle exclusivo seu:\n\n• Dados locais: armazenados no seu dispositivo.\n• Backup: na sua conta Google Drive, protegida pelas políticas de segurança do Google.\n\nNão temos acesso, nem capacidade de acessar, seus dados pessoais.'**
  String get privacyStorageBody;

  /// No description provided for @privacyDeleteTitle.
  ///
  /// In pt, this message translates to:
  /// **'5. Exclusão de Dados'**
  String get privacyDeleteTitle;

  /// No description provided for @privacyDeleteBody.
  ///
  /// In pt, this message translates to:
  /// **'Para excluir seus dados:\n\n• Dados locais: desinstale o aplicativo.\n• Backup no Drive: acesse drive.google.com/drive/appdata e exclua o arquivo \"nao_esquece_backup.json\".'**
  String get privacyDeleteBody;

  /// No description provided for @privacyChangesTitle.
  ///
  /// In pt, this message translates to:
  /// **'6. Alterações nesta Política'**
  String get privacyChangesTitle;

  /// No description provided for @privacyChangesBody.
  ///
  /// In pt, this message translates to:
  /// **'Podemos atualizar esta política periodicamente. Atualizações relevantes serão comunicadas dentro do próprio app.'**
  String get privacyChangesBody;

  /// No description provided for @privacyContactTitle.
  ///
  /// In pt, this message translates to:
  /// **'7. Contato'**
  String get privacyContactTitle;

  /// No description provided for @privacyContactBody.
  ///
  /// In pt, this message translates to:
  /// **'Dúvidas sobre privacidade? Entre em contato pelo e-mail informado na página do app na Play Store.'**
  String get privacyContactBody;

  /// No description provided for @privacyLastUpdate.
  ///
  /// In pt, this message translates to:
  /// **'Última atualização: março de 2026'**
  String get privacyLastUpdate;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo ao\nNão Esquece!'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeDesc.
  ///
  /// In pt, this message translates to:
  /// **'Nunca mais volte do mercado sem um item. Crie e gerencie suas listas de compras de forma simples e inteligente.'**
  String get onboardingWelcomeDesc;

  /// No description provided for @onboardingOrganizeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Organize\nsuas compras'**
  String get onboardingOrganizeTitle;

  /// No description provided for @onboardingOrganizeDesc.
  ///
  /// In pt, this message translates to:
  /// **'Adicione itens com preço, quantidade e observações. Acompanhe o total estimado em tempo real enquanto faz as compras.'**
  String get onboardingOrganizeDesc;

  /// No description provided for @onboardingHistoryTitle.
  ///
  /// In pt, this message translates to:
  /// **'Histórico\nde preços'**
  String get onboardingHistoryTitle;

  /// No description provided for @onboardingHistoryDesc.
  ///
  /// In pt, this message translates to:
  /// **'Ao finalizar uma lista, os preços são salvos automaticamente. Na próxima compra, veja se o item ficou mais caro ou mais barato.'**
  String get onboardingHistoryDesc;

  /// No description provided for @onboardingScannerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Scanner\nde listas'**
  String get onboardingScannerTitle;

  /// No description provided for @onboardingScannerDesc.
  ///
  /// In pt, this message translates to:
  /// **'Fotografe uma lista escrita (letras de forma ou impressa) e o app converte os itens automaticamente usando OCR.'**
  String get onboardingScannerDesc;

  /// No description provided for @onboardingShareTitle.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhe\nsuas listas'**
  String get onboardingShareTitle;

  /// No description provided for @onboardingShareDesc.
  ///
  /// In pt, this message translates to:
  /// **'Gere um código compacto e envie por WhatsApp ou SMS. A outra pessoa importa a lista completa no app instantaneamente.'**
  String get onboardingShareDesc;

  /// No description provided for @onboardingTextShareTitle.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhe\ncomo texto'**
  String get onboardingTextShareTitle;

  /// No description provided for @onboardingTextShareDesc.
  ///
  /// In pt, this message translates to:
  /// **'Copie a lista formatada com preços unitários e totais para colar no WhatsApp, sem precisar que o outro tenha o app.'**
  String get onboardingTextShareDesc;

  /// No description provided for @onboardingWidgetTitle.
  ///
  /// In pt, this message translates to:
  /// **'Widget na\ntela inicial'**
  String get onboardingWidgetTitle;

  /// No description provided for @onboardingWidgetDesc.
  ///
  /// In pt, this message translates to:
  /// **'Veja os itens pendentes da sua lista ativa diretamente na tela inicial do celular, sem nem precisar abrir o app.'**
  String get onboardingWidgetDesc;

  /// No description provided for @onboardingBackupTitle.
  ///
  /// In pt, this message translates to:
  /// **'Backup\nautomático'**
  String get onboardingBackupTitle;

  /// No description provided for @onboardingBackupDesc.
  ///
  /// In pt, this message translates to:
  /// **'Seus dados ficam salvos no Google Drive. Troque de aparelho e recupere todas as suas listas com 1 toque.'**
  String get onboardingBackupDesc;

  /// No description provided for @onboardingExportTitle.
  ///
  /// In pt, this message translates to:
  /// **'Exporte\nsuas listas'**
  String get onboardingExportTitle;

  /// No description provided for @onboardingExportDesc.
  ///
  /// In pt, this message translates to:
  /// **'Exporte suas listas em PDF, Excel ou CSV para imprimir, arquivar ou analisar seus gastos como preferir.'**
  String get onboardingExportDesc;

  /// No description provided for @onboardingSkip.
  ///
  /// In pt, this message translates to:
  /// **'Pular'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In pt, this message translates to:
  /// **'Próximo'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In pt, this message translates to:
  /// **'Começar!'**
  String get onboardingStart;

  /// No description provided for @removeItem.
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get removeItem;

  /// No description provided for @removeItemConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Remover \"{name}\"?'**
  String removeItemConfirm(String name);

  /// No description provided for @editListName.
  ///
  /// In pt, this message translates to:
  /// **'Renomear Lista'**
  String get editListName;

  /// No description provided for @listNameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome da lista'**
  String get listNameLabel;

  /// No description provided for @backupLoginRequired.
  ///
  /// In pt, this message translates to:
  /// **'Faça login com o Google primeiro nas Configurações.'**
  String get backupLoginRequired;

  /// No description provided for @shareCode.
  ///
  /// In pt, this message translates to:
  /// **'Código de Compartilhamento'**
  String get shareCode;

  /// No description provided for @copy.
  ///
  /// In pt, this message translates to:
  /// **'COPIAR'**
  String get copy;

  /// No description provided for @name.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get name;

  /// No description provided for @emptyListAdd.
  ///
  /// In pt, this message translates to:
  /// **'Lista vazia. Adicione itens!'**
  String get emptyListAdd;

  /// No description provided for @finishPurchase.
  ///
  /// In pt, this message translates to:
  /// **'Finalizar Compra'**
  String get finishPurchase;

  /// No description provided for @cart.
  ///
  /// In pt, this message translates to:
  /// **'Carrinho'**
  String get cart;

  /// No description provided for @remaining.
  ///
  /// In pt, this message translates to:
  /// **'Faltam'**
  String get remaining;

  /// No description provided for @itemNameRequired.
  ///
  /// In pt, this message translates to:
  /// **'Nome do item é obrigatório'**
  String get itemNameRequired;

  /// No description provided for @itemNameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome do Item *'**
  String get itemNameLabel;

  /// No description provided for @aisleOptional.
  ///
  /// In pt, this message translates to:
  /// **'Corredor / Categoria (opcional)'**
  String get aisleOptional;

  /// No description provided for @newCategoryEllipsis.
  ///
  /// In pt, this message translates to:
  /// **'Nova categoria...'**
  String get newCategoryEllipsis;

  /// No description provided for @allDates.
  ///
  /// In pt, this message translates to:
  /// **'Todas as datas'**
  String get allDates;

  /// No description provided for @descName.
  ///
  /// In pt, this message translates to:
  /// **'Desc / Nome'**
  String get descName;

  /// No description provided for @qty.
  ///
  /// In pt, this message translates to:
  /// **'Qtd'**
  String get qty;

  /// No description provided for @val.
  ///
  /// In pt, this message translates to:
  /// **'Valor'**
  String get val;

  /// No description provided for @grandTotal.
  ///
  /// In pt, this message translates to:
  /// **'TOTAL GERAL:'**
  String get grandTotal;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
