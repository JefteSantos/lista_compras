// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => '¡No Olvides!';

  @override
  String get myLists => 'Mis Listas';

  @override
  String get newList => 'Nueva Lista';

  @override
  String get listName => 'Nombre de la lista';

  @override
  String get createList => 'Crear';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get close => 'Cerrar';

  @override
  String get error => 'Error';

  @override
  String get success => 'Éxito';

  @override
  String get loading => 'Cargando...';

  @override
  String get ok => 'OK';

  @override
  String get duplicateList => 'Duplicar lista';

  @override
  String get duplicateListSubtitle =>
      'Crea una copia con artículos desmarcados';

  @override
  String get deleteList => 'Eliminar lista';

  @override
  String listCreated(String name) {
    return '¡Lista \"$name\" creada!';
  }

  @override
  String get open => 'ABRIR';

  @override
  String get pasteFromClipboard => 'Pegar del portapapeles';

  @override
  String get importByCode => 'Importar por código';

  @override
  String get scanPhysicalList => 'Escanear lista física';

  @override
  String get reports => 'Informes';

  @override
  String get settings => 'Configuración';

  @override
  String get importCode => 'Código de importación';

  @override
  String get importCodeHint => 'Pegue el código NE1: o NE2: aquí';

  @override
  String get import => 'Importar';

  @override
  String get importSuccess => '¡Lista importada con éxito!';

  @override
  String get importError => 'Código inválido o corrupto.';

  @override
  String get ocrConfirmTitle => 'Artículos encontrados';

  @override
  String ocrConfirmMessage(int count) {
    return '$count artículos detectados. ¿Desea crear una lista con estos artículos?';
  }

  @override
  String get ocrNoItems => 'No se detectaron artículos en la imagen.';

  @override
  String get ocrCreateList => 'Crear Lista';

  @override
  String get emptyListTitle => 'Aún no hay listas';

  @override
  String get emptyListSubtitle =>
      '¡Toque + para crear su primera lista de compras!';

  @override
  String get emptyFinishedTitle => 'No hay listas finalizadas';

  @override
  String get emptyFinishedSubtitle => 'Las listas finalizadas aparecerán aquí.';

  @override
  String get activeLists => 'Activas';

  @override
  String get finishedLists => 'Finalizadas';

  @override
  String get listNotFound => 'Lista no encontrada.';

  @override
  String get groupByCategory => 'Agrupar por categoría';

  @override
  String get ungroupItems => 'Desagrupar artículos';

  @override
  String get copyList => 'Copiar lista';

  @override
  String get generateShareCode => 'Generar Código para Compartir';

  @override
  String get deleteListTitle => 'Eliminar Lista';

  @override
  String get deleteListConfirm =>
      '¿Está seguro? Esto eliminará todos los artículos.';

  @override
  String get deletePermanently => 'ELIMINAR PERMANENTEMENTE';

  @override
  String get shareCodeError => 'Error inesperado al generar el código.';

  @override
  String get shareCodeCopied =>
      '¡Código copiado! Envíelo a quien quiera importar la lista.';

  @override
  String get shareCodeTitle => 'Código para Compartir';

  @override
  String get shareCodeInstruction =>
      'Copie y envíe por WhatsApp, SMS o cualquier mensajero:';

  @override
  String get copyCode => 'Copiar Código';

  @override
  String get codeCopied => '¡Código copiado!';

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
  String get emptyList => 'Lista vacía. ¡Agregue artículos!';

  @override
  String get items => 'artículos';

  @override
  String itemsCount(int bought, int total) {
    return '$bought/$total artículos';
  }

  @override
  String get noCategory => 'Sin Categoría';

  @override
  String get shoppingList => 'Lista de Compras';

  @override
  String get pending => 'Faltan';

  @override
  String get alreadyGot => 'Ya tengo';

  @override
  String get listCopied => '¡Lista copiada al portapapeles!';

  @override
  String get headerSummary => 'Resumen';

  @override
  String get totalItems => 'Total de artículos';

  @override
  String get boughtItems => 'Artículos comprados';

  @override
  String get pendingItems => 'Artículos pendientes';

  @override
  String get totalSpent => 'Total gastado';

  @override
  String get totalPending => 'Total pendiente';

  @override
  String get editItem => 'Editar Artículo';

  @override
  String get newItem => 'Nuevo Artículo';

  @override
  String get itemName => 'Nombre del Artículo *';

  @override
  String get itemNameHint => 'Ej: Leche, Pan, Arroz...';

  @override
  String get quantity => 'Cantidad';

  @override
  String get priceOptional => 'Precio (opcional)';

  @override
  String get priceHint => 'Ej: 4,50';

  @override
  String get notesOptional => 'Notas (opcional)';

  @override
  String get notesHint => 'Ej: Marca preferida, cantidad específica...';

  @override
  String get categoryOptional => 'Pasillo / Categoría (opcional)';

  @override
  String get none => 'Ninguna';

  @override
  String get newCategory => 'Nueva categoría...';

  @override
  String get saveChanges => 'Guardar Cambios';

  @override
  String get addItem => 'Agregar Artículo';

  @override
  String get itemRequired => 'El nombre del artículo es obligatorio';

  @override
  String get duplicateItem => 'Artículo Repetido';

  @override
  String duplicateItemMessage(String name) {
    return 'El artículo \"$name\" ya está en la lista. ¿Desea agregarlo/guardarlo de todos modos?';
  }

  @override
  String get saveAnyway => 'Guardar de Todos Modos';

  @override
  String get preview => 'Vista previa:';

  @override
  String get priceNotSet => 'Precio no informado';

  @override
  String lastPaid(String value) {
    return 'Último pago: $value';
  }

  @override
  String obs(String text) {
    return 'Nota: $text';
  }

  @override
  String categorySuggestion(String item, String category) {
    return '\"$item\" estaba en \"$category\"';
  }

  @override
  String get useCategory => 'USAR';

  @override
  String get newCategoryTitle => 'Nueva Categoría';

  @override
  String get categoryName => 'Nombre de la categoría';

  @override
  String get categoryNameHint => 'Ej: Congelados, Mascotas...';

  @override
  String get typeAName => 'Escriba un nombre';

  @override
  String get categoryExists => 'La categoría ya existe';

  @override
  String get create => 'CREAR';

  @override
  String get appearance => 'Apariencia';

  @override
  String get darkMode => 'Modo Oscuro';

  @override
  String get darkModeOn => 'Tema oscuro activado';

  @override
  String get darkModeOff => 'Tema claro activado';

  @override
  String get googleAccount => 'Cuenta Google';

  @override
  String get signedInAs => 'Conectado como';

  @override
  String get signIn => 'Iniciar sesión con Google';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get aisles => 'Pasillos / Categorías';

  @override
  String get driveBackup => 'Backup en Google Drive';

  @override
  String get createBackup => 'Crear Backup Ahora';

  @override
  String get restoreBackup => 'Restaurar Backup';

  @override
  String get backupSuccess => '¡Backup realizado con éxito!';

  @override
  String get backupError => 'Error en el backup';

  @override
  String get restoreSuccess => '¡Backup restaurado con éxito!';

  @override
  String get restoreError => 'Error al restaurar';

  @override
  String get aboutBackup => 'Acerca del Backup';

  @override
  String get backupInfo =>
      'Sus datos se guardan en Google Drive en una carpeta privada de la app. Ningún dato se envía a nuestros servidores.';

  @override
  String get legal => 'Legal';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get deleteCategory => 'Eliminar Categoría';

  @override
  String deleteCategoryConfirm(String name) {
    return '¿Eliminar \"$name\"?';
  }

  @override
  String get noCategoriesYet => 'Ninguna categoría registrada.';

  @override
  String get addCategoryHint =>
      'Agregue categorías para organizar sus artículos por pasillo del supermercado.';

  @override
  String get dragToReorder => 'Arrastre para reordenar';

  @override
  String get reportTitle => 'Informe de Compras';

  @override
  String get exportReport => 'Exportar Informe';

  @override
  String get noListsForFilters =>
      'No se encontraron listas para los filtros seleccionados.';

  @override
  String get filterByDate => 'Filtrar por fecha';

  @override
  String get search => 'Buscar...';

  @override
  String get showItems => 'Mostrar artículos';

  @override
  String get hideItems => 'Ocultar artículos';

  @override
  String get totalSpentLabel => 'Gastado';

  @override
  String get totalPendingLabel => 'Pendiente';

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
    return '¡$type exportado con éxito!';
  }

  @override
  String exportError(String type, String error) {
    return 'Error al generar $type: $error';
  }

  @override
  String get bought => 'Comprado';

  @override
  String get notBought => 'Pendiente';

  @override
  String get finalized => 'Finalizada';

  @override
  String get inProgress => 'En Progreso';

  @override
  String get proPlan => '¡No Olvides! PRO';

  @override
  String get proSubtitle =>
      'Desbloquee todo el poder de la app con una\nCOMPRA ÚNICA DE POR VIDA.';

  @override
  String get proFeatureOcr => 'Scanner OCR de listas físicas';

  @override
  String get proFeatureExport => 'Exportación ilimitada a PDF y Excel';

  @override
  String get proFeatureHistory => 'Historial de Precios ilimitado';

  @override
  String get proPayOnce => '¡Pague una vez, úselo para siempre!';

  @override
  String get proUnlock => 'DESBLOQUEAR AHORA';

  @override
  String get proWelcome =>
      '🎉 ¡Bienvenido a PRO! Funcionalidades desbloqueadas.';

  @override
  String get proFailed => 'Pago cancelado o fallido.';

  @override
  String get proRestore => 'Restaurar';

  @override
  String get proRestoring => 'Buscando compras anteriores...';

  @override
  String get privacyTitle => '¡No Olvides! — Política de Privacidad';

  @override
  String get privacyIntro =>
      'Esta Política de Privacidad describe cómo la aplicación \"¡No Olvides!\" maneja sus datos personales. Lea atentamente.';

  @override
  String get privacyDataTitle => '1. Datos Recopilados';

  @override
  String get privacyDataBody =>
      'La aplicación NO recopila ningún dato personal en servidores propios. Todos los datos ingresados (listas de compras, artículos, precios) se almacenan exclusivamente:\n\n• En el almacenamiento local de su dispositivo (Hive/SQLite).\n• En su propio Google Drive (carpeta privada de la app), si elige activar el backup.';

  @override
  String get privacyDriveTitle => '2. Google Drive y Google Sign-In';

  @override
  String get privacyDriveBody =>
      'Si elige hacer backup, la app solicitará acceso a su cuenta Google con el alcance \"drive.appdata\". Este alcance permite guardar archivos solo en la carpeta oculta y privada de la app en su Google Drive.\n\nNo se accede a ningún otro dato de su cuenta Google. Los archivos de backup no son visibles en la interfaz normal de Google Drive.';

  @override
  String get privacySharingTitle => '3. Compartición de Datos';

  @override
  String get privacySharingBody =>
      'La aplicación NO comparte sus datos con terceros. Los códigos de compartición de listas se generan localmente en su dispositivo y viajan solo por los canales que usted elija (WhatsApp, SMS, correo electrónico, etc.).';

  @override
  String get privacyStorageTitle => '4. Almacenamiento y Seguridad';

  @override
  String get privacyStorageBody =>
      'Sus datos están bajo su control exclusivo:\n\n• Datos locales: almacenados en su dispositivo.\n• Backup: en su cuenta de Google Drive, protegida por las políticas de seguridad de Google.\n\nNo tenemos acceso ni capacidad de acceder a sus datos personales.';

  @override
  String get privacyDeleteTitle => '5. Eliminación de Datos';

  @override
  String get privacyDeleteBody =>
      'Para eliminar sus datos:\n\n• Datos locales: desinstale la aplicación.\n• Backup en Drive: acceda a drive.google.com/drive/appdata y elimine el archivo \"nao_esquece_backup.json\".';

  @override
  String get privacyChangesTitle => '6. Cambios en esta Política';

  @override
  String get privacyChangesBody =>
      'Podemos actualizar esta política periódicamente. Las actualizaciones relevantes serán comunicadas dentro de la propia app.';

  @override
  String get privacyContactTitle => '7. Contacto';

  @override
  String get privacyContactBody =>
      '¿Preguntas sobre privacidad? Contáctenos por el correo electrónico informado en la página de la app en Play Store.';

  @override
  String get privacyLastUpdate => 'Última actualización: marzo de 2026';

  @override
  String get onboardingWelcomeTitle => 'Bienvenido a\n¡No Olvides!';

  @override
  String get onboardingWelcomeDesc =>
      'Nunca más vuelva del supermercado sin un artículo. Cree y administre sus listas de compras de forma simple e inteligente.';

  @override
  String get onboardingOrganizeTitle => 'Organice\nsus compras';

  @override
  String get onboardingOrganizeDesc =>
      'Agregue artículos con precio, cantidad y notas. Acompañe el total estimado en tiempo real mientras compra.';

  @override
  String get onboardingHistoryTitle => 'Historial\nde precios';

  @override
  String get onboardingHistoryDesc =>
      'Al finalizar una lista, los precios se guardan automáticamente. En su próxima compra, vea si el artículo subió o bajó de precio.';

  @override
  String get onboardingScannerTitle => 'Escáner\nde listas';

  @override
  String get onboardingScannerDesc =>
      'Fotografíe una lista escrita (letra de imprenta o impresa) y la app convierte los artículos automáticamente usando OCR.';

  @override
  String get onboardingShareTitle => 'Comparta\nsus listas';

  @override
  String get onboardingShareDesc =>
      'Genere un código compacto y envíelo por WhatsApp o SMS. La otra persona importa la lista completa instantáneamente.';

  @override
  String get onboardingTextShareTitle => 'Comparta\ncomo texto';

  @override
  String get onboardingTextShareDesc =>
      'Copie la lista formateada con precios unitarios y totales para pegar en WhatsApp, sin necesidad de que el otro tenga la app.';

  @override
  String get onboardingWidgetTitle => 'Widget en la\npantalla de inicio';

  @override
  String get onboardingWidgetDesc =>
      'Vea los artículos pendientes de su lista activa directamente en la pantalla de inicio, sin abrir la app.';

  @override
  String get onboardingBackupTitle => 'Backup\nautomático';

  @override
  String get onboardingBackupDesc =>
      'Sus datos quedan guardados en Google Drive. Cambie de dispositivo y recupere todas sus listas con 1 toque.';

  @override
  String get onboardingExportTitle => 'Exporte\nsus listas';

  @override
  String get onboardingExportDesc =>
      'Exporte sus listas en PDF, Excel o CSV para imprimir, archivar o analizar sus gastos.';

  @override
  String get onboardingSkip => 'Saltar';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingStart => '¡Empezar!';

  @override
  String get removeItem => 'Eliminar';

  @override
  String removeItemConfirm(String name) {
    return '¿Eliminar \"$name\"?';
  }

  @override
  String get editListName => 'Renombrar Lista';

  @override
  String get listNameLabel => 'Nombre de la lista';

  @override
  String get backupLoginRequired =>
      'Inicie sesión con Google primero en Configuración.';

  @override
  String get shareCode => 'Código para Compartir';

  @override
  String get copy => 'COPIAR';

  @override
  String get name => 'Nombre';

  @override
  String get emptyListAdd => 'Lista vacía. ¡Agregue items!';

  @override
  String get finishPurchase => 'Finalizar Compra';

  @override
  String get cart => 'Carrito';

  @override
  String get remaining => 'Faltan';

  @override
  String get itemNameRequired => 'El nombre del artículo es obligatorio';

  @override
  String get itemNameLabel => 'Nombre del Artículo *';

  @override
  String get aisleOptional => 'Pasillo / Categoría (opcional)';

  @override
  String get newCategoryEllipsis => 'Nueva categoría...';

  @override
  String get allDates => 'Todas las fechas';

  @override
  String get descName => 'Desc / Nombre';

  @override
  String get qty => 'Cant';

  @override
  String get val => 'Valor';

  @override
  String get grandTotal => 'TOTAL GENERAL:';
}
