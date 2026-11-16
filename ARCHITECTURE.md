# Architecture Logicielle - CampSense

Ce document décrit l'organisation globale du projet, les conventions architecturales et les règles d'intégration pour permettre à 6 développeurs de travailler en parallèle sans conflits.

---

## 1. Vue d'Ensemble

**CampSense** est une application Flutter pour campeurs fonctionnant **100 % hors-ligne** (*offline-first*), basée sur SQLite (`sqflite`), Provider pour l'état, et structurée en **6 modules métiers**. Chaque module exploite un capteur matériel spécifique de l'appareil :

| Module | Nom Français | Responsabilité Métier | Capteur Associé | Statut |
|---|---|---|---|---|
| **User** | Profil | Authentification, profil, contacts, séjours, admin | **Capteur de lumière** (thème auto) | **Version 1 terminée (évolutions prévues)** |
| **Event** | Sorties | Randonnées, bivouacs collectifs, météo | **Baromètre** | En attente |
| **Marketplace** | Matériel | Annonces de prêt / vente, fiches équipement | **NFC** | En attente |
| **Transport** | Trajets | Covoiturage, points de rendez-vous | **GPS** | En attente |
| **Tutorial** | Guides | Guides de survie, premiers secours, nœuds | **Accéléromètre** | En attente |
| **Campsite** | Camp | Emplacements de tente, orientation, vent | **Magnétomètre** | En attente |

---

## 2. Arborescence du Projet & Propriété du Code

```
lib/
├── core/                         # [RESPONSABLE D'INTÉGRATION] Socle transversal commun
│   ├── constants/
│   │   ├── common_strings.dart   # Textes partagés (Annuler, Enregistrer, Noms modules...)
│   │   └── admin_seed.dart       # Identifiants de l'administrateur
│   ├── database/
│   │   ├── module_schema.dart    # Contrat abstrait pour le schéma de chaque module
│   │   └── app_database.dart     # Singleton SQLite central & registre des schémas
│   ├── routes/
│   │   └── app_routes.dart       # AppRouter central combinant les routes des modules
│   ├── theme/
│   │   ├── app_colors.dart       # Palettes officielles claire & sombre
│   │   ├── app_theme.dart        # Thèmes ThemeData Material 3
│   │   ├── camp_sense_colors.dart# Extension ThemeExtension sémantique
│   │   └── theme_x.dart          # context.colors, context.text, context.isDarkMode
│   ├── utils/                    # PasswordHasher, DateFormatFr, Validators
│   └── widgets/                  # Composants visuels cs_* (cs_card, cs_button_*, cs_chip...)
├── shell/                        # [RESPONSABLE D'INTÉGRATION] Coques de navigation
│   ├── app_shell.dart            # Barre du haut commune + 5 onglets modules (Sorties, Matériel, Trajets, Guides, Camp)
│   ├── admin_shell.dart          # Barre 3 onglets pour l'administrateur (Utilisateurs, Signalements, Profil)
│   ├── shell_tab.dart            # Définition déclarative d'un onglet (avec onSearch & searchHint optionnels)
│   └── module_placeholder_screen.dart # Écran temporaire d'attente d'intégration
├── features/                     # [ÉQUIPES MODULES] Chaque équipe possède son dossier
│   ├── user/                     # Module User (exemple de référence complet)
│   │   ├── user_api.dart         # SEUL point d'entrée exposé aux autres modules
│   │   ├── user_routes.dart      # Map des routes du module
│   │   ├── user_strings.dart     # Chaînes françaises du module
│   │   ├── models/               # User, Stay
│   │   ├── data/                 # UserRepository (abstrait), SqliteUserRepository, UserSchema
│   │   ├── services/             # AuthService, AdminSeeder, Permissions, LightSensorService
│   │   ├── providers/            # AuthProvider, UserProvider, AdminUsersProvider, ThemeProvider
│   │   ├── screens/              # Splash, Login, Register, Profile, EditProfile + admin/
│   │   └── widgets/              # StayTile, AmbientLightCard, EmergencyContactCard...
│   ├── event/                    # Module Sorties (à créer par l'équipe Event)
│   ├── marketplace/              # Module Matériel (à créer par l'équipe Marketplace)
│   ├── transport/                # Module Trajets (à créer par l'équipe Transport)
│   ├── tutorial/                 # Module Guides (à créer par l'équipe Tutorial)
│   └── campsite/                 # Module Camp (à créer par l'équipe Campsite)
├── app.dart                      # [RESPONSABLE D'INTÉGRATION] MaterialApp, MultiProvider
└── main.dart                     # [RESPONSABLE D'INTÉGRATION] Point d'entrée de l'app
```

---

## 3. Structure Type d'un Module

Tout nouveau module (ex: `event`) doit être structuré de manière identique et autonome :

```
lib/features/event/
├── event_api.dart             # API publique du module (export modèles nécessaires, helpers)
├── event_routes.dart          # Map<String, WidgetBuilder> des routes du module
├── event_strings.dart         # Textes 100% français propres au module
├── models/                    # Modèles immuables (toMap, fromMap, copyWith)
├── data/
│   ├── event_schema.dart      # implements ModuleSchema (création des tables & migrations)
│   ├── event_repository.dart  # Interface abstraite (CRUD métier)
│   └── sqlite_event_repository.dart # Implémentation SQLite
├── services/                  # Logique métier et capteur (ex: BarometerService)
├── providers/                 # ChangeNotifiers pour l'état de l'écran
├── screens/                   # Écran principal et écrans secondaires
└── widgets/                   # Widgets réutilisables spécifiques au module
```

---

## 4. Guide Pas à Pas pour Intégrer un Module

Pour brancher votre module dans l'application, suivez cette checklist :

1. **Créer le schéma SQLite de votre module :**
   Créez `lib/features/<module>/data/<module>_schema.dart` qui implémente `ModuleSchema` :
   ```dart
   class EventSchema implements ModuleSchema {
     @override
     String get moduleName => 'event';

     @override
     Future<void> onCreate(Database db) async {
       await db.execute('''
         CREATE TABLE events_sorties (
           id INTEGER PRIMARY KEY AUTOINCREMENT,
           user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
           title TEXT NOT NULL,
           date TEXT NOT NULL
         );
       ''');
     }

     @override
     Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {}
   }
   ```
2. **Enregistrer le schéma dans `AppDatabase` :**
   Ajoutez votre schéma dans `AppDatabase.registeredSchemas` (`lib/core/database/app_database.dart`). Le responsable d'intégration incrémente `_dbVersion`.
3. **Déclarer les routes de votre module :**
   Dans `<module>_routes.dart`, définissez vos écrans. Ajoutez ensuite votre map dans `AppRouter.moduleRoutes` (`lib/core/routes/app_routes.dart`).
4. **Remplacer le builder et brancher la recherche dans la barre de navigation :**
   Dans `lib/shell/app_shell.dart`, remplacez le `builder` de votre onglet par votre écran racine et définissez optionnellement `onSearch` et `searchHint` :
   ```dart
   ShellTab(
     label: CommonStrings.moduleEvents,
     icon: Icons.explore_outlined,
     selectedIcon: Icons.explore_rounded,
     searchHint: 'Rechercher une sortie...',
     onSearch: () {
       // Déclencher la recherche spécifique à votre module
     },
     builder: (context) => const EventHomeScreen(),
   ),
   ```
5. **Enregistrer vos Providers :**
   Ajoutez vos `ChangeNotifierProvider` dans le `MultiProvider` de `lib/app.dart`.
6. **Vérification qualité :**
   `flutter analyze` doit afficher 0 problème et `flutter test` doit valider l'ensemble des tests.

---

## 5. Navigation & Ergonomie de l'Application

L'application utilise deux coques de navigation adaptées au rôle de l'utilisateur :

### A. Coque Utilisateur (`AppShell` — Campeur & Organisateur)
* **Barre du haut (`AppBar`) commune et persistante :**
  - **Gauche :** Logo montagne stylisé + Nom de marque **CampSense**.
  - **Droite :** Icône loupe de recherche (`Icons.search_rounded`), suivie de l'**avatar** de l'utilisateur (cercle vert sauge avec ses initiales).
  - **Accès au Profil :** Un appui sur l'avatar ouvre l'écran **Profil** (`ProfileScreen`) par-dessus la coque avec un bouton retour permettant de revenir aux onglets.
  - **Recherche par onglet :** L'icône de recherche appelle le callback `onSearch` défini sur l'onglet actif (`ShellTab.onSearch`). S'il n'est pas encore implémenté, un message temporaire *"Recherche bientôt disponible"* s'affiche sans bloquer la navigation.
* **Barre de navigation du bas (`NavigationBar`) :**
  - Contient exactement **5 onglets métiers** : **Sorties**, **Matériel**, **Trajets**, **Guides**, **Camp**.
  - L'onglet affiché par défaut au démarrage est **Sorties** (index 0).
  - Chaque onglet conserve son propre état et sa pile de navigation indépendante (`IndexedStack`).

### B. Coque Administrateur (`AdminShell` — Rôle Admin uniquement)
* L'administrateur n'a pas accès aux 5 onglets métiers ni à la navigation standard.
* Coque dédiée à 3 onglets : **Utilisateurs** (gestion & CRUD), **Signalements** (modération), **Profil** (carte admin, capteur de lumière & déconnexion).

---

## 6. Règles Obligatoires (Garde-Fous)

1. **Isolation stricte de la base de données :**
   - Les écrans et les Providers n'appellent **JAMAIS** `sqflite` directement.
   - Tout passe par l'interface abstraite du Repository (`EventRepository`).
2. **Encapsulation inter-modules :**
   - Les modules ne s'importent **JAMAIS** directement entre eux.
   - Pour accéder à l'utilisateur courant, importez uniquement `lib/features/user/user_api.dart` et utilisez :
     ```dart
     final user = context.currentUser;
     final userId = context.currentUserId;
     final isAuth = context.isLoggedIn;
     ```
   - Pour conditionner l'affichage à la connexion : `<RequireLogin child: MonWidget() />`.
3. **Préfixes de tables obligatoires :**
   Pour éviter tout conflit SQLite, chaque table doit respecter son préfixe :
   - User : `users`, `stays`
   - Event : `events_*`
   - Marketplace : `listings_*`
   - Transport : `trips_*`
   - Tutorial : `guides_*`
   - Campsite : `campsites_*`
4. **Zéro texte en dur :**
   Toutes les chaînes françaises doivent être regroupées dans `<module>_strings.dart` ou `common_strings.dart`.
5. **Zéro couleur en dur :**
   N'utilisez jamais `Color(0xFF...)` ou `Colors.blue` dans les écrans. Utilisez `context.colors` ou `Theme.of(context)`.
6. **Gestion de `pubspec.yaml` :**
   Un seul responsable gère `pubspec.yaml` et `app_database.dart` (`_dbVersion`). Prévenez l'équipe avant d'ajouter une dépendance.
7. **Stabilité de l'architecture :**
   La structure des dossiers et les contrats entre modules (`*_api.dart`, `ModuleSchema`, `AppRouter`, `AppShell`) sont **FIGÉS**. Le contenu interne des modules peut évoluer librement. Modifier la structure nécessite l'accord de toute l'équipe et une PR dédiée.
8. **Workflow Git :**
   Voir `CONTRIBUTING.md`. Les branches `feature/*` sont fusionnées dans `develop` par Pull Request, et `develop` est fusionnée dans `main` uniquement pour les versions stables.

---

## 7. Contrat de Suppression d'un Utilisateur

Toute table liée à un utilisateur doit référencer `users(id)` avec la contrainte adaptée :
* **Données qui appartiennent exclusivement à l'utilisateur** (ex: les annonces qu'il a postées, les trajets qu'il conduit, les sorties qu'il organise) :
  `ON DELETE CASCADE` → effacées automatiquement quand le compte est supprimé.
* **Données partagées avec d'autres utilisateurs** (ex: participations à une sortie organisée par un tiers, réservations de covoiturage) :
  Supprimer uniquement la ligne d'association/participation, sans détruire l'événement ou le trajet parent.

---

## 8. Comptes de Démonstration & Commandes

### Comptes pré-configurés :
* **Administrateur :** `omar@campsense.com` / `Admin1234` (accès à l'espace d'administration à 3 onglets).
* **Campeur Démo :** `azza.drissi@example.com` / `Camp1234` (3 séjours enregistrés).
* **Organisateur Démo :** `noe.bernard@example.com` / `Camp1234`.

### Commandes utiles :
```powershell
# Installer les dépendances
flutter pub get

# Vérifier la qualité du code (doit être 0/0)
flutter analyze

# Lancer la suite de tests unitaires
flutter test

# Réinitialiser la base de données locale si nécessaire
# (Désinstallez l'application depuis l'émulateur Android puis relancez)
flutter run
```