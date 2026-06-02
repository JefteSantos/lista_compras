// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'N\'oublie Pas !';

  @override
  String get myLists => 'Mes Listes';

  @override
  String get newList => 'Nouvelle Liste';

  @override
  String get listName => 'Nom de la liste';

  @override
  String get createList => 'Créer';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get close => 'Fermer';

  @override
  String get error => 'Erreur';

  @override
  String get success => 'Succès';

  @override
  String get loading => 'Chargement...';

  @override
  String get ok => 'OK';

  @override
  String get duplicateList => 'Dupliquer la liste';

  @override
  String get duplicateListSubtitle =>
      'Crée une copie avec les articles décochés';

  @override
  String get deleteList => 'Supprimer la liste';

  @override
  String listCreated(String name) {
    return 'Liste \"$name\" créée !';
  }

  @override
  String get open => 'OUVRIR';

  @override
  String get pasteFromClipboard => 'Coller depuis le presse-papiers';

  @override
  String get importByCode => 'Importer par code';

  @override
  String get scanPhysicalList => 'Scanner une liste physique';

  @override
  String get reports => 'Rapports';

  @override
  String get settings => 'Paramètres';

  @override
  String get importCode => 'Code d\'importation';

  @override
  String get importCodeHint => 'Collez le code NE1: ou NE2: ici';

  @override
  String get import => 'Importer';

  @override
  String get importSuccess => 'Liste importée avec succès !';

  @override
  String get importError => 'Code invalide ou corrompu.';

  @override
  String get ocrConfirmTitle => 'Articles trouvés';

  @override
  String ocrConfirmMessage(int count) {
    return '$count articles détectés. Souhaitez-vous créer une liste avec ces articles ?';
  }

  @override
  String get ocrNoItems => 'Aucun article détecté dans l\'image.';

  @override
  String get ocrCreateList => 'Créer la Liste';

  @override
  String get emptyListTitle => 'Aucune liste pour le moment';

  @override
  String get emptyListSubtitle =>
      'Appuyez sur + pour créer votre première liste de courses !';

  @override
  String get emptyFinishedTitle => 'Aucune liste terminée';

  @override
  String get emptyFinishedSubtitle => 'Les listes terminées apparaîtront ici.';

  @override
  String get activeLists => 'Actives';

  @override
  String get finishedLists => 'Terminées';

  @override
  String get listNotFound => 'Liste introuvable.';

  @override
  String get groupByCategory => 'Grouper par catégorie';

  @override
  String get ungroupItems => 'Dégrouper les articles';

  @override
  String get copyList => 'Copier la liste';

  @override
  String get generateShareCode => 'Générer un Code de Partage';

  @override
  String get deleteListTitle => 'Supprimer la Liste';

  @override
  String get deleteListConfirm =>
      'Êtes-vous sûr ? Cela supprimera tous les articles.';

  @override
  String get deletePermanently => 'SUPPRIMER DÉFINITIVEMENT';

  @override
  String get shareCodeError =>
      'Erreur inattendue lors de la génération du code.';

  @override
  String get shareCodeCopied =>
      'Code copié ! Envoyez-le à qui vous voulez pour importer la liste.';

  @override
  String get shareCodeTitle => 'Code de Partage';

  @override
  String get shareCodeInstruction =>
      'Copiez et envoyez par WhatsApp, SMS ou tout autre messageur :';

  @override
  String get copyCode => 'Copier le Code';

  @override
  String get codeCopied => 'Code copié !';

  @override
  String get total => 'Total';

  @override
  String estimatedTotal(String value) {
    return 'Total estimé : $value';
  }

  @override
  String get finishShopping => 'Terminer les Courses';

  @override
  String get reopenList => 'Rouvrir la Liste';

  @override
  String get emptyList => 'Liste vide. Ajoutez des articles !';

  @override
  String get items => 'articles';

  @override
  String itemsCount(int bought, int total) {
    return '$bought/$total articles';
  }

  @override
  String get noCategory => 'Sans Catégorie';

  @override
  String get shoppingList => 'Liste de Courses';

  @override
  String get pending => 'À prendre';

  @override
  String get alreadyGot => 'Déjà pris';

  @override
  String get listCopied => 'Liste copiée dans le presse-papiers !';

  @override
  String get headerSummary => 'Résumé';

  @override
  String get totalItems => 'Total d\'articles';

  @override
  String get boughtItems => 'Articles achetés';

  @override
  String get pendingItems => 'Articles en attente';

  @override
  String get totalSpent => 'Total dépensé';

  @override
  String get totalPending => 'Total en attente';

  @override
  String get editItem => 'Modifier l\'Article';

  @override
  String get newItem => 'Nouvel Article';

  @override
  String get itemName => 'Nom de l\'Article *';

  @override
  String get itemNameHint => 'Ex : Lait, Pain, Riz...';

  @override
  String get quantity => 'Quantité';

  @override
  String get priceOptional => 'Prix (optionnel)';

  @override
  String get priceHint => 'Ex : 4,50';

  @override
  String get notesOptional => 'Notes (optionnel)';

  @override
  String get notesHint => 'Ex : Marque préférée, quantité spécifique...';

  @override
  String get categoryOptional => 'Rayon / Catégorie (optionnel)';

  @override
  String get none => 'Aucune';

  @override
  String get newCategory => 'Nouvelle catégorie...';

  @override
  String get saveChanges => 'Enregistrer les Modifications';

  @override
  String get addItem => 'Ajouter un Article';

  @override
  String get itemRequired => 'Le nom de l\'article est obligatoire';

  @override
  String get duplicateItem => 'Article en Double';

  @override
  String duplicateItemMessage(String name) {
    return 'L\'article \"$name\" est déjà dans la liste. Voulez-vous l\'ajouter/enregistrer quand même ?';
  }

  @override
  String get saveAnyway => 'Enregistrer Quand Même';

  @override
  String get preview => 'Aperçu :';

  @override
  String get priceNotSet => 'Prix non renseigné';

  @override
  String lastPaid(String value) {
    return 'Dernier prix : $value';
  }

  @override
  String obs(String text) {
    return 'Note : $text';
  }

  @override
  String categorySuggestion(String item, String category) {
    return '\"$item\" était dans \"$category\"';
  }

  @override
  String get useCategory => 'UTILISER';

  @override
  String get newCategoryTitle => 'Nouvelle Catégorie';

  @override
  String get categoryName => 'Nom de la catégorie';

  @override
  String get categoryNameHint => 'Ex : Surgelés, Animalerie...';

  @override
  String get typeAName => 'Saisissez un nom';

  @override
  String get categoryExists => 'La catégorie existe déjà';

  @override
  String get create => 'CRÉER';

  @override
  String get appearance => 'Apparence';

  @override
  String get darkMode => 'Mode Sombre';

  @override
  String get darkModeOn => 'Thème sombre activé';

  @override
  String get darkModeOff => 'Thème clair activé';

  @override
  String get googleAccount => 'Compte Google';

  @override
  String get signedInAs => 'Connecté en tant que';

  @override
  String get signIn => 'Se connecter avec Google';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get aisles => 'Rayons / Catégories';

  @override
  String get driveBackup => 'Sauvegarde Google Drive';

  @override
  String get createBackup => 'Créer une Sauvegarde';

  @override
  String get restoreBackup => 'Restaurer la Sauvegarde';

  @override
  String get backupSuccess => 'Sauvegarde effectuée avec succès !';

  @override
  String get backupError => 'Erreur de sauvegarde';

  @override
  String get restoreSuccess => 'Sauvegarde restaurée avec succès !';

  @override
  String get restoreError => 'Erreur lors de la restauration';

  @override
  String get aboutBackup => 'À propos de la Sauvegarde';

  @override
  String get backupInfo =>
      'Vos données sont enregistrées dans Google Drive dans un dossier privé de l\'app. Aucune donnée n\'est envoyée à nos serveurs.';

  @override
  String get legal => 'Mentions légales';

  @override
  String get privacyPolicy => 'Politique de Confidentialité';

  @override
  String get deleteCategory => 'Supprimer la Catégorie';

  @override
  String deleteCategoryConfirm(String name) {
    return 'Supprimer \"$name\" ?';
  }

  @override
  String get noCategoriesYet => 'Aucune catégorie enregistrée.';

  @override
  String get addCategoryHint =>
      'Ajoutez des catégories pour organiser vos articles par rayon du magasin.';

  @override
  String get dragToReorder => 'Glissez pour réorganiser';

  @override
  String get reportTitle => 'Rapport de Courses';

  @override
  String get exportReport => 'Exporter le Rapport';

  @override
  String get noListsForFilters =>
      'Aucune liste trouvée pour les filtres sélectionnés.';

  @override
  String get filterByDate => 'Filtrer par date';

  @override
  String get search => 'Rechercher...';

  @override
  String get showItems => 'Afficher les articles';

  @override
  String get hideItems => 'Masquer les articles';

  @override
  String get totalSpentLabel => 'Dépensé';

  @override
  String get totalPendingLabel => 'En attente';

  @override
  String get totalLabel => 'Total';

  @override
  String listsFound(int count) {
    return '$count listes trouvées';
  }

  @override
  String get exportPdf => 'Exporter en PDF';

  @override
  String get exportExcel => 'Exporter en Excel';

  @override
  String get exportCsv => 'Exporter en CSV';

  @override
  String exportSuccess(String type) {
    return '$type exporté avec succès !';
  }

  @override
  String exportError(String type, String error) {
    return 'Erreur lors de la génération du $type : $error';
  }

  @override
  String get bought => 'Acheté';

  @override
  String get notBought => 'En attente';

  @override
  String get finalized => 'Terminée';

  @override
  String get inProgress => 'En Cours';

  @override
  String get proPlan => 'N\'oublie Pas ! PRO';

  @override
  String get proSubtitle =>
      'Débloquez toute la puissance de l\'app avec un\nACHAT UNIQUE À VIE.';

  @override
  String get proFeatureOcr => 'Scanner OCR de listes physiques';

  @override
  String get proFeatureExport => 'Exportation illimitée en PDF et Excel';

  @override
  String get proFeatureHistory => 'Historique des Prix illimité';

  @override
  String get proPayOnce => 'Payez une fois, utilisez pour toujours !';

  @override
  String get proUnlock => 'DÉBLOQUER MAINTENANT';

  @override
  String get proWelcome => '🎉 Bienvenue en PRO ! Fonctionnalités débloquées.';

  @override
  String get proFailed => 'Paiement annulé ou échoué.';

  @override
  String get proRestore => 'Restaurer';

  @override
  String get proRestoring => 'Recherche d\'achats précédents...';

  @override
  String get privacyTitle => 'N\'oublie Pas ! — Politique de Confidentialité';

  @override
  String get privacyIntro =>
      'Cette Politique de Confidentialité décrit comment l\'application \"N\'oublie Pas !\" traite vos données personnelles. Veuillez lire attentivement.';

  @override
  String get privacyDataTitle => '1. Données Collectées';

  @override
  String get privacyDataBody =>
      'L\'application ne collecte AUCUNE donnée personnelle sur ses propres serveurs. Toutes les données saisies (listes de courses, articles, prix) sont stockées exclusivement :\n\n• Dans le stockage local de votre appareil (Hive/SQLite).\n• Dans votre propre Google Drive (dossier privé de l\'app), si vous choisissez d\'activer la sauvegarde.';

  @override
  String get privacyDriveTitle => '2. Google Drive et Google Sign-In';

  @override
  String get privacyDriveBody =>
      'Si vous choisissez de sauvegarder, l\'app demandera l\'accès à votre compte Google avec le scope \"drive.appdata\". Ce scope permet de sauvegarder des fichiers uniquement dans le dossier caché et privé de l\'app sur votre Google Drive.\n\nAucune autre donnée de votre compte Google n\'est consultée. Les fichiers de sauvegarde ne sont pas visibles dans l\'interface normale de Google Drive.';

  @override
  String get privacySharingTitle => '3. Partage des Données';

  @override
  String get privacySharingBody =>
      'L\'application ne partage PAS vos données avec des tiers. Les codes de partage de listes sont générés localement sur votre appareil et transitent uniquement par les canaux que vous choisissez (WhatsApp, SMS, e-mail, etc.).';

  @override
  String get privacyStorageTitle => '4. Stockage et Sécurité';

  @override
  String get privacyStorageBody =>
      'Vos données sont sous votre contrôle exclusif :\n\n• Données locales : stockées sur votre appareil.\n• Sauvegarde : dans votre compte Google Drive, protégée par les politiques de sécurité de Google.\n\nNous n\'avons pas accès, ni la capacité d\'accéder, à vos données personnelles.';

  @override
  String get privacyDeleteTitle => '5. Suppression des Données';

  @override
  String get privacyDeleteBody =>
      'Pour supprimer vos données :\n\n• Données locales : désinstallez l\'application.\n• Sauvegarde Drive : accédez à drive.google.com/drive/appdata et supprimez le fichier \"nao_esquece_backup.json\".';

  @override
  String get privacyChangesTitle => '6. Modifications de cette Politique';

  @override
  String get privacyChangesBody =>
      'Nous pouvons mettre à jour cette politique périodiquement. Les mises à jour importantes seront communiquées au sein de l\'application.';

  @override
  String get privacyContactTitle => '7. Contact';

  @override
  String get privacyContactBody =>
      'Des questions sur la confidentialité ? Contactez-nous via l\'e-mail indiqué sur la page de l\'app sur le Play Store.';

  @override
  String get privacyLastUpdate => 'Dernière mise à jour : mars 2026';

  @override
  String get onboardingWelcomeTitle => 'Bienvenue sur\nN\'oublie Pas !';

  @override
  String get onboardingWelcomeDesc =>
      'Ne revenez plus jamais du magasin sans un article. Créez et gérez vos listes de courses simplement et intelligemment.';

  @override
  String get onboardingOrganizeTitle => 'Organisez\nvos courses';

  @override
  String get onboardingOrganizeDesc =>
      'Ajoutez des articles avec prix, quantité et notes. Suivez le total estimé en temps réel pendant vos courses.';

  @override
  String get onboardingHistoryTitle => 'Historique\ndes prix';

  @override
  String get onboardingHistoryDesc =>
      'Lorsque vous terminez une liste, les prix sont enregistrés automatiquement. Lors de votre prochaine visite, voyez si les articles ont augmenté ou baissé.';

  @override
  String get onboardingScannerTitle => 'Scanner\nde listes';

  @override
  String get onboardingScannerDesc =>
      'Photographiez une liste écrite (imprimée ou manuscrite) et l\'app convertit les articles automatiquement via OCR.';

  @override
  String get onboardingShareTitle => 'Partagez\nvos listes';

  @override
  String get onboardingShareDesc =>
      'Générez un code compact et envoyez-le par WhatsApp ou SMS. L\'autre personne importe la liste complète instantanément.';

  @override
  String get onboardingTextShareTitle => 'Partagez\nen texte';

  @override
  String get onboardingTextShareDesc =>
      'Copiez la liste formatée avec prix unitaires et totaux pour la coller sur WhatsApp, sans que l\'autre ait besoin de l\'app.';

  @override
  String get onboardingWidgetTitle => 'Widget sur\nl\'écran d\'accueil';

  @override
  String get onboardingWidgetDesc =>
      'Voyez les articles manquants de votre liste active directement sur l\'écran d\'accueil, sans ouvrir l\'app.';

  @override
  String get onboardingBackupTitle => 'Sauvegarde\nautomatique';

  @override
  String get onboardingBackupDesc =>
      'Vos données sont enregistrées sur Google Drive. Changez d\'appareil et récupérez toutes vos listes en un geste.';

  @override
  String get onboardingExportTitle => 'Exportez\nvos listes';

  @override
  String get onboardingExportDesc =>
      'Exportez vos listes en PDF, Excel ou CSV pour imprimer, archiver ou analyser vos dépenses.';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingStart => 'Commencer !';

  @override
  String get removeItem => 'Supprimer';

  @override
  String removeItemConfirm(String name) {
    return 'Supprimer \"$name\" ?';
  }

  @override
  String get editListName => 'Renommer la Liste';

  @override
  String get listNameLabel => 'Nom de la liste';

  @override
  String get backupLoginRequired =>
      'Connectez-vous d\'abord avec Google dans les Paramètres.';

  @override
  String get shareCode => 'Code de Partage';

  @override
  String get copy => 'COPIER';

  @override
  String get name => 'Nom';

  @override
  String get emptyListAdd => 'Liste vide. Ajoutez des articles !';

  @override
  String get finishPurchase => 'Terminer les Achats';

  @override
  String get cart => 'Panier';

  @override
  String get remaining => 'Restant';

  @override
  String get itemNameRequired => 'Le nom de l\'article est obligatoire';

  @override
  String get itemNameLabel => 'Nom de l\'Article *';

  @override
  String get aisleOptional => 'Rayon / Catégorie (optionnel)';

  @override
  String get newCategoryEllipsis => 'Nouvelle catégorie...';

  @override
  String get allDates => 'Toutes les dates';

  @override
  String get descName => 'Desc / Nom';

  @override
  String get qty => 'Qté';

  @override
  String get val => 'Valeur';

  @override
  String get grandTotal => 'TOTAL GÉNÉRAL :';
}
