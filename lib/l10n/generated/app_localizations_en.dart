// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Don\'t Forget!';

  @override
  String get myLists => 'My Lists';

  @override
  String get newList => 'New List';

  @override
  String get listName => 'List name';

  @override
  String get createList => 'Create';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get close => 'Close';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get loading => 'Loading...';

  @override
  String get ok => 'OK';

  @override
  String get duplicateList => 'Duplicate list';

  @override
  String get duplicateListSubtitle => 'Creates a copy with unchecked items';

  @override
  String get deleteList => 'Delete list';

  @override
  String listCreated(String name) {
    return 'List \"$name\" created!';
  }

  @override
  String get open => 'OPEN';

  @override
  String get pasteFromClipboard => 'Paste from clipboard';

  @override
  String get importByCode => 'Import by code';

  @override
  String get scanPhysicalList => 'Scan physical list';

  @override
  String get reports => 'Reports';

  @override
  String get settings => 'Settings';

  @override
  String get importCode => 'Import code';

  @override
  String get importCodeHint => 'Paste the NE1: or NE2: code here';

  @override
  String get import => 'Import';

  @override
  String get importSuccess => 'List imported successfully!';

  @override
  String get importError => 'Invalid or corrupted code.';

  @override
  String get ocrConfirmTitle => 'Items found';

  @override
  String ocrConfirmMessage(int count) {
    return '$count items detected. Would you like to create a list with these items?';
  }

  @override
  String get ocrNoItems => 'No items detected in the image.';

  @override
  String get ocrCreateList => 'Create List';

  @override
  String get emptyListTitle => 'No lists yet';

  @override
  String get emptyListSubtitle => 'Tap + to create your first shopping list!';

  @override
  String get emptyFinishedTitle => 'No finished lists';

  @override
  String get emptyFinishedSubtitle => 'Finished lists will appear here.';

  @override
  String get activeLists => 'Active';

  @override
  String get finishedLists => 'Finished';

  @override
  String get listNotFound => 'List not found.';

  @override
  String get groupByCategory => 'Group by category';

  @override
  String get ungroupItems => 'Ungroup items';

  @override
  String get copyList => 'Copy list';

  @override
  String get generateShareCode => 'Generate Share Code';

  @override
  String get deleteListTitle => 'Delete List';

  @override
  String get deleteListConfirm => 'Are you sure? This will delete all items.';

  @override
  String get deletePermanently => 'DELETE PERMANENTLY';

  @override
  String get shareCodeError => 'Unexpected error generating code.';

  @override
  String get shareCodeCopied =>
      'Code copied! Send it to whoever wants to import the list.';

  @override
  String get shareCodeTitle => 'Share Code';

  @override
  String get shareCodeInstruction =>
      'Copy and send via WhatsApp, SMS, or any messenger:';

  @override
  String get copyCode => 'Copy Code';

  @override
  String get codeCopied => 'Code copied!';

  @override
  String get total => 'Total';

  @override
  String estimatedTotal(String value) {
    return 'Estimated total: $value';
  }

  @override
  String get finishShopping => 'Finish Shopping';

  @override
  String get reopenList => 'Reopen List';

  @override
  String get emptyList => 'Empty list. Add items!';

  @override
  String get items => 'items';

  @override
  String itemsCount(int bought, int total) {
    return '$bought/$total items';
  }

  @override
  String get noCategory => 'No Category';

  @override
  String get shoppingList => 'Shopping List';

  @override
  String get pending => 'Still need';

  @override
  String get alreadyGot => 'Already got';

  @override
  String get listCopied => 'List copied to clipboard!';

  @override
  String get headerSummary => 'Summary';

  @override
  String get totalItems => 'Total items';

  @override
  String get boughtItems => 'Items bought';

  @override
  String get pendingItems => 'Items pending';

  @override
  String get totalSpent => 'Total spent';

  @override
  String get totalPending => 'Total pending';

  @override
  String get editItem => 'Edit Item';

  @override
  String get newItem => 'New Item';

  @override
  String get itemName => 'Item Name *';

  @override
  String get itemNameHint => 'e.g. Milk, Bread, Rice...';

  @override
  String get quantity => 'Quantity';

  @override
  String get priceOptional => 'Price (optional)';

  @override
  String get priceHint => 'e.g. 4.50';

  @override
  String get notesOptional => 'Notes (optional)';

  @override
  String get notesHint => 'e.g. Preferred brand, specific amount...';

  @override
  String get categoryOptional => 'Aisle / Category (optional)';

  @override
  String get none => 'None';

  @override
  String get newCategory => 'New category...';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get addItem => 'Add Item';

  @override
  String get itemRequired => 'Item name is required';

  @override
  String get duplicateItem => 'Duplicate Item';

  @override
  String duplicateItemMessage(String name) {
    return 'The item \"$name\" is already in the list. Add/save it anyway?';
  }

  @override
  String get saveAnyway => 'Save Anyway';

  @override
  String get preview => 'Preview:';

  @override
  String get priceNotSet => 'Price not set';

  @override
  String lastPaid(String value) {
    return 'Last paid: $value';
  }

  @override
  String obs(String text) {
    return 'Note: $text';
  }

  @override
  String categorySuggestion(String item, String category) {
    return '\"$item\" was in \"$category\"';
  }

  @override
  String get useCategory => 'USE';

  @override
  String get newCategoryTitle => 'New Category';

  @override
  String get categoryName => 'Category name';

  @override
  String get categoryNameHint => 'e.g. Frozen, Pet Shop...';

  @override
  String get typeAName => 'Enter a name';

  @override
  String get categoryExists => 'Category already exists';

  @override
  String get create => 'CREATE';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get darkModeOn => 'Dark theme enabled';

  @override
  String get darkModeOff => 'Light theme enabled';

  @override
  String get googleAccount => 'Google Account';

  @override
  String get signedInAs => 'Signed in as';

  @override
  String get signIn => 'Sign in with Google';

  @override
  String get signOut => 'Sign Out';

  @override
  String get aisles => 'Aisles / Categories';

  @override
  String get driveBackup => 'Google Drive Backup';

  @override
  String get createBackup => 'Create Backup Now';

  @override
  String get restoreBackup => 'Restore Backup';

  @override
  String get backupSuccess => 'Backup completed successfully!';

  @override
  String get backupError => 'Backup error';

  @override
  String get restoreSuccess => 'Backup restored successfully!';

  @override
  String get restoreError => 'Error restoring backup';

  @override
  String get aboutBackup => 'About Backup';

  @override
  String get backupInfo =>
      'Your data is saved to Google Drive in a private app folder. No data is sent to our servers.';

  @override
  String get legal => 'Legal';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get deleteCategory => 'Delete Category';

  @override
  String deleteCategoryConfirm(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get noCategoriesYet => 'No categories registered.';

  @override
  String get addCategoryHint =>
      'Add categories to organize your items by store aisle.';

  @override
  String get dragToReorder => 'Drag to reorder';

  @override
  String get reportTitle => 'Shopping Report';

  @override
  String get exportReport => 'Export Report';

  @override
  String get noListsForFilters => 'No lists found for the selected filters.';

  @override
  String get filterByDate => 'Filter by date';

  @override
  String get search => 'Search...';

  @override
  String get showItems => 'Show items';

  @override
  String get hideItems => 'Hide items';

  @override
  String get totalSpentLabel => 'Spent';

  @override
  String get totalPendingLabel => 'Pending';

  @override
  String get totalLabel => 'Total';

  @override
  String listsFound(int count) {
    return '$count lists found';
  }

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get exportExcel => 'Export Excel';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String exportSuccess(String type) {
    return '$type exported successfully!';
  }

  @override
  String exportError(String type, String error) {
    return 'Error generating $type: $error';
  }

  @override
  String get bought => 'Bought';

  @override
  String get notBought => 'Pending';

  @override
  String get finalized => 'Finished';

  @override
  String get inProgress => 'In Progress';

  @override
  String get proPlan => 'Don\'t Forget! PRO';

  @override
  String get proSubtitle =>
      'Unlock the full power of the app with a\nONE-TIME LIFETIME PURCHASE.';

  @override
  String get proFeatureOcr => 'OCR scanner for physical lists';

  @override
  String get proFeatureExport => 'Unlimited PDF and Excel export';

  @override
  String get proFeatureHistory => 'Unlimited Price History';

  @override
  String get proPayOnce => 'Pay once, use forever!';

  @override
  String get proUnlock => 'UNLOCK NOW';

  @override
  String get proWelcome => '🎉 Welcome to PRO! Features unlocked.';

  @override
  String get proFailed => 'Payment cancelled or failed.';

  @override
  String get proRestore => 'Restore';

  @override
  String get proRestoring => 'Looking for previous purchases...';

  @override
  String get privacyTitle => 'Don\'t Forget! — Privacy Policy';

  @override
  String get privacyIntro =>
      'This Privacy Policy describes how the \"Don\'t Forget!\" app handles your personal data. Please read carefully.';

  @override
  String get privacyDataTitle => '1. Data Collected';

  @override
  String get privacyDataBody =>
      'The app does NOT collect any personal data on its own servers. All data you enter (shopping lists, items, prices) is stored exclusively:\n\n• In your device\'s local storage (Hive/SQLite).\n• In your own Google Drive (private app folder), if you choose to enable backup.';

  @override
  String get privacyDriveTitle => '2. Google Drive and Google Sign-In';

  @override
  String get privacyDriveBody =>
      'If you choose to back up, the app will request access to your Google account with the \"drive.appdata\" scope. This scope allows saving files only in the hidden, private app folder on your Google Drive.\n\nNo other data from your Google account is accessed. Backup files are not visible in the normal Google Drive interface.';

  @override
  String get privacySharingTitle => '3. Data Sharing';

  @override
  String get privacySharingBody =>
      'The app does NOT share your data with third parties. List sharing codes are generated locally on your device and travel only through the channels you choose (WhatsApp, SMS, email, etc.).';

  @override
  String get privacyStorageTitle => '4. Storage and Security';

  @override
  String get privacyStorageBody =>
      'Your data is under your exclusive control:\n\n• Local data: stored on your device.\n• Backup: in your Google Drive account, protected by Google\'s security policies.\n\nWe do not have access to, nor the ability to access, your personal data.';

  @override
  String get privacyDeleteTitle => '5. Data Deletion';

  @override
  String get privacyDeleteBody =>
      'To delete your data:\n\n• Local data: uninstall the app.\n• Drive backup: go to drive.google.com/drive/appdata and delete the file \"nao_esquece_backup.json\".';

  @override
  String get privacyChangesTitle => '6. Changes to this Policy';

  @override
  String get privacyChangesBody =>
      'We may update this policy periodically. Relevant updates will be communicated within the app itself.';

  @override
  String get privacyContactTitle => '7. Contact';

  @override
  String get privacyContactBody =>
      'Questions about privacy? Contact us via the email listed on the app\'s Play Store page.';

  @override
  String get privacyLastUpdate => 'Last updated: March 2026';

  @override
  String get onboardingWelcomeTitle => 'Welcome to\nDon\'t Forget!';

  @override
  String get onboardingWelcomeDesc =>
      'Never come home without an item again. Create and manage your shopping lists simply and smartly.';

  @override
  String get onboardingOrganizeTitle => 'Organize\nyour shopping';

  @override
  String get onboardingOrganizeDesc =>
      'Add items with price, quantity, and notes. Track the estimated total in real time while shopping.';

  @override
  String get onboardingHistoryTitle => 'Price\nhistory';

  @override
  String get onboardingHistoryDesc =>
      'When you finish a list, prices are saved automatically. On your next trip, see if items got more expensive or cheaper.';

  @override
  String get onboardingScannerTitle => 'List\nscanner';

  @override
  String get onboardingScannerDesc =>
      'Photograph a written list (print or handwritten) and the app converts the items automatically using OCR.';

  @override
  String get onboardingShareTitle => 'Share\nyour lists';

  @override
  String get onboardingShareDesc =>
      'Generate a compact code and send via WhatsApp or SMS. The other person imports the complete list instantly.';

  @override
  String get onboardingTextShareTitle => 'Share\nas text';

  @override
  String get onboardingTextShareDesc =>
      'Copy the formatted list with unit prices and totals to paste on WhatsApp, without needing the other person to have the app.';

  @override
  String get onboardingWidgetTitle => 'Home screen\nwidget';

  @override
  String get onboardingWidgetDesc =>
      'See pending items from your active list right on your home screen, without opening the app.';

  @override
  String get onboardingBackupTitle => 'Automatic\nbackup';

  @override
  String get onboardingBackupDesc =>
      'Your data is saved to Google Drive. Switch devices and recover all your lists with one tap.';

  @override
  String get onboardingExportTitle => 'Export\nyour lists';

  @override
  String get onboardingExportDesc =>
      'Export your lists as PDF, Excel, or CSV to print, archive, or analyze your spending.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Get Started!';

  @override
  String get removeItem => 'Delete';

  @override
  String removeItemConfirm(String name) {
    return 'Remove \"$name\"?';
  }

  @override
  String get editListName => 'Rename List';

  @override
  String get listNameLabel => 'List name';

  @override
  String get backupLoginRequired => 'Sign in with Google first in Settings.';

  @override
  String get shareCode => 'Share Code';

  @override
  String get copy => 'COPY';

  @override
  String get name => 'Name';

  @override
  String get emptyListAdd => 'Empty list. Add items!';

  @override
  String get finishPurchase => 'Finish Shopping';

  @override
  String get cart => 'Cart';

  @override
  String get remaining => 'Remaining';

  @override
  String get itemNameRequired => 'Item name is required';

  @override
  String get itemNameLabel => 'Item Name *';

  @override
  String get aisleOptional => 'Aisle / Category (optional)';

  @override
  String get newCategoryEllipsis => 'New category...';

  @override
  String get allDates => 'All dates';

  @override
  String get descName => 'Desc / Name';

  @override
  String get qty => 'Qty';

  @override
  String get val => 'Value';

  @override
  String get grandTotal => 'GRAND TOTAL:';
}
