/// Chaînes de caractères communes à l'ensemble des modules de CampSense.
/// Contient le vocabulaire global, les noms de modules, actions génériques et erreurs système.
class CommonStrings {
  // Application
  static const String appName = 'CampSense';
  static const String appTagline = 'Votre compagnon de bivouac';

  // Noms des 6 modules de l'application
  static const String moduleUser = 'Profil';
  static const String moduleEvents = 'Sorties';
  static const String moduleMarketplace = 'Matériel';
  static const String moduleTransport = 'Trajets';
  static const String moduleTutorial = 'Guides';
  static const String moduleCampsite = 'Camp';

  // Capteurs associés aux modules
  static const String moduleInProgress = 'en cours de développement';
  static const String moduleSensorLabel = 'Capteur associé :';
  static const String sensorLight = 'Capteur de lumière';
  static const String sensorBarometer = 'Baromètre';
  static const String sensorNfc = 'NFC';
  static const String sensorGps = 'GPS';
  static const String sensorAccelerometer = 'Accéléromètre';
  static const String sensorMagnetometer = 'Magnétomètre';

  // Actions génériques réutilisables
  static const String cancel = 'Annuler';
  static const String save = 'Enregistrer';
  static const String confirm = 'Confirmer';
  static const String delete = 'Supprimer';
  static const String edit = 'Modifier';
  static const String close = 'Fermer';
  static const String back = 'Retour';
  static const String retry = 'Réessayer';
  static const String search = 'Rechercher';
  static const String searchComingSoon = 'Recherche bientôt disponible';
  static const String seeMore = 'Voir plus';
  static const String featureComingSoon =
      'Bientôt disponible : fonctionnalité en cours de développement';

  // Erreurs génériques
  static const String errorGeneric = 'Une erreur inattendue est survenue.';
  static const String errorFieldRequired = 'Ce champ est obligatoire';
  static const String errorNetwork = 'Connexion réseau indisponible';
  static const String errorUnauthorized = 'Accès non autorisé';
}
