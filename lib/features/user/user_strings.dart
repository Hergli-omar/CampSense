import '../../core/constants/common_strings.dart';

/// Chaînes de caractères spécifiques au module User (campeurs, organisateurs et administration).
class UserStrings {
  // Application
  static const String appName = CommonStrings.appName;
  static const String appTagline = CommonStrings.appTagline;

  // Navigation Shell Tabs (Campeur)
  static const String tabProfile = CommonStrings.moduleUser;
  static const String tabEvents = CommonStrings.moduleEvents;
  static const String tabMarketplace = CommonStrings.moduleMarketplace;
  static const String tabTransport = CommonStrings.moduleTransport;
  static const String tabTutorial = CommonStrings.moduleTutorial;
  static const String tabCampsite = CommonStrings.moduleCampsite;

  // Capteurs associés aux modules (Placeholders)
  static const String moduleInProgress = CommonStrings.moduleInProgress;
  static const String moduleSensorLabel = CommonStrings.moduleSensorLabel;
  static const String sensorBarometer = CommonStrings.sensorBarometer;
  static const String sensorNfc = CommonStrings.sensorNfc;
  static const String sensorGps = CommonStrings.sensorGps;
  static const String sensorAccelerometer = CommonStrings.sensorAccelerometer;
  static const String sensorMagnetometer = CommonStrings.sensorMagnetometer;
  static const String sensorLight = CommonStrings.sensorLight;

  // Surtitres / Fil d'Ariane
  static const String overtitleAccount = 'COMPTE';
  static const String overtitleProfile = 'PROFIL';
  static const String overtitleEditProfile = 'MODIFIER LE PROFIL';
  static const String overtitleSecurity = 'SÉCURITÉ';
  static const String overtitleStays = 'SÉJOURS';
  static const String overtitleAppearance = 'APPARENCE';
  static const String overtitleAdmin = 'ADMINISTRATION';

  // Rôles
  static const String roleCamper = 'Campeur';
  static const String roleOrganizer = 'Organisateur';
  static const String roleAdmin = 'Administrateur';

  // Niveaux d'expérience
  static const String experienceLevelLabel = "Niveau d'expérience";
  static const String experienceBeginner = 'Débutant';
  static const String experienceIntermediate = 'Intermédiaire';
  static const String experienceAdvanced = 'Avancé';

  // Authentification & Splash
  static const String splashLoading = 'Chargement de votre session...';
  static const String loginTitle = 'Connexion';
  static const String loginSubtitle = 'Retrouvez votre carnet de camping';
  static const String registerTitle = 'Créer un compte';
  static const String registerSubtitle = 'Rejoignez la communauté des campeurs';
  static const String emailLabel = 'Email';
  static const String emailHint = 'nom@exemple.com';
  static const String passwordLabel = 'Mot de passe';
  static const String passwordHint = '8 caractères min., lettre et chiffre';
  static const String confirmPasswordLabel = 'Confirmer le mot de passe';
  static const String confirmPasswordHint = 'Retapez votre mot de passe';
  static const String fullNameLabel = 'Nom complet';
  static const String fullNameHint = 'Prénom et nom';
  static const String roleLabel = 'Votre rôle';

  static const String emergencyContactSection = "Contact d'urgence (optionnel)";
  static const String emergencyContactNameLabel = 'Nom du contact';
  static const String emergencyContactNameHint = 'Ex. Jean Dupont';
  static const String emergencyContactPhoneLabel = 'Téléphone du contact';
  static const String emergencyContactPhoneHint = 'Ex. 06 00 00 00 27';
  static const String termsAcceptance =
      "J'accepte les conditions générales et la politique de confidentialité";
  static const String termsRequiredError =
      'Vous devez accepter les conditions pour continuer';

  static const String loginButton = 'Se connecter';
  static const String registerButton = 'Créer mon compte';
  static const String noAccountPrompt = "Vous n'avez pas encore de compte ?";
  static const String alreadyAccountPrompt = 'Vous avez déjà un compte ?';
  static const String createAccountLink = 'Créer un compte';
  static const String loginLink = 'Se connecter';

  // Verrouillage & Erreurs d'authentification
  static const String genericAuthError = 'Email ou mot de passe incorrect';
  static const String accountLockedMessage =
      'Trop de tentatives infructueuses. Veuillez patienter';
  static const String sessionExpired =
      'Votre session a expiré. Veuillez vous reconnecter.';
  static const String emailAlreadyExists =
      'Cette adresse email est déjà utilisée.';

  // Force du mot de passe
  static const String passwordStrengthWeak = 'Trop court ou incomplet';
  static const String passwordStrengthMedium =
      'Moyen (ajoutez des caractères)';
  static const String passwordStrengthStrong = 'Mot de passe robuste';

  // Écran Profil
  static const String profileTitle = 'Mon profil';
  static const String registeredSince = 'Membre depuis le';
  static const String emergencyContactTitle = "Contact d'urgence";
  static const String emergencyContactHiddenNotice =
      'Numéro sécurisé. Confirmez votre mot de passe pour l’afficher.';
  static const String revealPhoneButton = 'Afficher le numéro';
  static const String hidePhoneButton = 'Masquer le numéro';
  static const String noEmergencyContact =
      'Aucun contact d’urgence renseigné';
  static const String verifyIdentityDialogTitle = "Vérification d'identité";
  static const String verifyIdentityDialogDesc =
      'Saisissez votre mot de passe pour révéler le numéro de contact d’urgence.';
  static const String verifyButton = 'Vérifier';
  static const String cancelButton = CommonStrings.cancel;
  static const String incorrectPassword = 'Mot de passe incorrect';

  // Séjours / Historique
  static const String staysHistoryTitle = 'Historique des séjours';
  static const String staysHistorySubtitle =
      'Vos bivouacs passés et à venir (Module Sorties en attente)';
  static const String stayUpcoming = 'À venir';
  static const String stayFinished = 'Terminé';
  static const String noStaysYet =
      'Aucun séjour enregistré pour le moment.';
  static const String addStayDemoButton = 'Ajouter un séjour (démo)';
  static const String addStayDialogTitle = 'Nouveau séjour de démo';
  static const String stayPlaceLabel = 'Lieu du séjour';
  static const String stayPlaceHint = 'Ex. Ain Drahem';
  static const String stayStartDateLabel = 'Date de début';
  static const String stayEndDateLabel = 'Date de fin';
  static const String stayNotesLabel = 'Notes (optionnel)';
  static const String stayNotesHint = 'Ex. Matériel léger, météo humide';
  static const String saveStayButton = 'Ajouter';
  static const String stayDeletedNotice = 'Séjour supprimé';

  // Apparence & Capteur de lumière
  static const String appearanceTitle = 'Apparence & Luminosité';
  static const String themeModeAuto = 'Auto';
  static const String themeModeLight = 'Clair';
  static const String themeModeDark = 'Sombre';
  static const String sensorUnavailable =
      'Capteur de lumière indisponible';
  static const String sensorFallbackManual =
      'Le mode automatique bascule en mode manuel.';
  static const String luxFullSun = 'Plein soleil';
  static const String luxBright = 'Lumineux';
  static const String luxShade = 'Ombre';
  static const String luxLowLight = 'Faible lumière';
  static const String luxDarkness = 'Obscurité';
  static const String debugSimulation = 'Simulation de luminosité (debug)';
  static const String simulatedLux = 'Luminosité simulée :';

  // Écran Modifier Profil
  static const String editProfileTitle = 'Modifier mon profil';
  static const String personalInfoSection = 'Informations personnelles';
  static const String changePasswordSection = 'Changer le mot de passe';
  static const String currentPasswordLabel = 'Mot de passe actuel';
  static const String currentPasswordHint = 'Votre mot de passe actuel';
  static const String newPasswordLabel = 'Nouveau mot de passe';
  static const String newPasswordHint = 'Nouveau mot de passe sécurisé';
  static const String saveChangesButton = 'Enregistrer les modifications';
  static const String discardChangesButton = 'Abandonner les modifications';
  static const String discardConfirmTitle =
      'Abandonner les modifications ?';
  static const String discardConfirmMessage =
      'Vos modifications non enregistrées seront perdues.';
  static const String discardConfirmYes = 'Oui, abandonner';
  static const String discardConfirmNo = 'Continuer l’édition';
  static const String profileUpdatedSuccess =
      'Profil mis à jour avec succès';
  static const String passwordUpdatedSuccess =
      'Mot de passe modifié avec succès';

  // Déconnexion & Suppression compte
  static const String logoutButton = 'Se déconnecter';
  static const String logoutConfirmTitle = 'Déconnexion';
  static const String logoutConfirmMessage =
      'Êtes-vous sûr de vouloir vous déconnecter de CampSense ?';
  static const String deleteAccountButton = 'Supprimer mon compte';
  static const String deleteAccountDangerZone = 'Zone de danger';
  static const String deleteAccountDialogTitle = 'Supprimer votre compte ?';
  static const String deleteAccountConfirmButton = 'Supprimer définitivement';
  static const String deleteAccountCancelButton = 'Non, conserver';
  static const String deleteAccountSuccessNotice =
      'Votre compte a été supprimé avec succès.';
  static String deleteAccountDialogBody(String name, int staysCount) =>
      "Le profil de $name et l'historique de $staysCount séjour(s) seront effacés définitivement.";

  // Erreurs de validation de formulaires
  static const String errFieldRequired = CommonStrings.errorFieldRequired;
  static const String errNameTooShort =
      'Le nom doit comporter au moins 3 caractères';
  static const String errInvalidEmail =
      'Veuillez saisir une adresse email valide';
  static const String errPasswordTooShort =
      'Le mot de passe doit comporter au moins 8 caractères, dont une lettre et un chiffre';
  static const String errPasswordsDoNotMatch =
      'Les mots de passe ne correspondent pas';
  static const String errInvalidPhone =
      'Numéro invalide (8 à 15 chiffres, indicatif + et espaces autorisés)';
  static const String errStayEndDateBeforeStart =
      'La date de fin doit être postérieure à la date de début';

  // --- Espace Administration ---
  static const String adminTabUsers = 'Utilisateurs';
  static const String adminTabReports = 'Signalements';
  static const String adminTabProfile = 'Profil';

  static const String adminUsersTitle = 'Utilisateurs';
  static const String adminReportsTitle = 'Signalements';
  static const String adminProfileTitle = 'Profil Administrateur';

  // Compteurs & Filtres Admin
  static const String countCampers = 'Campeurs';
  static const String countOrganizers = 'Organisateurs';
  static const String filterAll = 'Tous';
  static const String filterCampers = 'Campeurs';
  static const String filterOrganizers = 'Organisateurs';
  static const String searchUsersHint = 'Rechercher par nom ou email...';
  static const String noUsersFound = 'Aucun utilisateur trouvé';
  static const String createAccountAdminButton = 'Créer un compte';

  // Détail Utilisateur Admin
  static const String userDetailTitle = 'Fiche utilisateur';
  static const String userDetailMemberSince = 'Inscrit le';
  static const String userDetailLastUpdated = 'Dernière mise à jour';
  static const String userDetailStayCount = 'Nombre de séjours';
  static const String userDetailEmergencyContact = "Contact d'urgence";
  static const String editUserButton = 'Modifier';
  static const String deleteUserButton = 'Supprimer ce compte';

  // Formulaire Création / Modification Admin
  static const String adminCreateUserTitle = 'Créer un compte';
  static const String adminCreateUserSubtitle =
      'Ajouter un nouveau campeur ou organisateur';
  static const String adminEditUserTitle = "Modifier l'utilisateur";
  static const String adminEditUserSubtitle =
      'Mettre à jour les coordonnées du compte';
  static const String adminSubmitCreateUser = 'Créer le compte';
  static const String adminSubmitEditUser = 'Enregistrer les modifications';
  static const String userCreatedSuccess = 'Utilisateur créé avec succès';
  static const String userUpdatedSuccess = 'Compte mis à jour avec succès';
  static const String userDeletedSuccess = 'Compte supprimé avec succès';

  // Dialogue de suppression Admin
  static const String adminDeleteDialogTitle = 'Supprimer ce compte ?';
  static String adminDeleteDialogBody(String name, int staysCount) =>
      "Le compte de $name et l'historique de $staysCount séjour(s) seront effacés définitivement.";
  static const String adminPasswordConfirmLabel =
      'Votre mot de passe administrateur';
  static const String adminPasswordConfirmHint =
      'Confirmez avec votre mot de passe';
  static const String adminDeleteConfirmButton = 'Supprimer le compte';
  static const String adminDeleteCancelButton = 'Non, conserver';

  // Signalements Admin (Maquette)
  static const String reportsBannerNotice =
      'Aperçu de l’interface : les signalements seront branchés lors de l’intégration des modules.';
  static const String reportsCountOpen = 'Ouverts';
  static const String reportsCountInProgress = 'En cours';
  static const String reportsCountResolved = 'Résolus';
  static const String filterReportsAll = 'Tous';
  static const String filterReportsOpen = 'Ouverts';
  static const String filterReportsInProgress = 'En cours';
  static const String filterReportsResolved = 'Résolus';
  static const String noReportsFound = 'Aucun signalement trouvé';
  static const String reportDetailTitle = 'Détail du signalement';
  static const String reportAuthorLabel = 'Signalé par';
  static const String reportTargetLabel = 'Élément signalé';
  static const String reportReasonLabel = 'Motif';
  static const String reportDateLabel = 'Date du signalement';
  static const String reportDescriptionLabel = 'Description';
  static const String reportStatusLabel = 'Statut';
  static const String reportResponseLabel = 'Réponse à l’utilisateur';
  static const String reportResponseHint =
      'Rédigez votre réponse ou justification...';
  static const String reportSaveResponse = 'Enregistrer la réponse';
  static const String reportViewContent = 'Voir le contenu concerné';
  static const String reportDeleteContent = 'Supprimer le contenu';
  static const String featureComingSoon = CommonStrings.featureComingSoon;

  // Sécurité & Permissions Admin
  static const String unauthorizedAccess =
      'Accès refusé : espace réservé aux administrateurs.';
  static const String cannotDeleteSelf =
      'Vous ne pouvez pas supprimer votre propre compte administrateur.';
  static const String cannotModifyAdmin =
      'Les comptes administrateurs ne peuvent pas être modifiés depuis cet écran.';
}

/// Alias rétro-compatible pendant la migration pour ne casser aucun composant existant.
typedef AppStrings = UserStrings;
