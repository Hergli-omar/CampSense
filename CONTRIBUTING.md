# Guide de Contribution & Workflow Git - CampSense

Ce document définit les règles de collaboration Git pour le développement en équipe de **CampSense**.

---

## 1. Branches Git & Rôles

```
main        ← version stable (validations, livraisons)
  └── develop     ← intégration : toutes les fonctionnalités arrivent ici (branche par défaut)
        ├── feature/event-...
        ├── feature/marketplace-...
        └── feature/user-...
```

* **`main` (protégée)** : code stable, testé, livrable. Personne ne pousse directement dessus. Elle ne reçoit du code que par une Pull Request depuis `develop`.
* **`develop` (protégée, branche par défaut)** : branche d'intégration. Personne ne pousse directement dessus. Elle reçoit les fonctionnalités par Pull Request depuis les branches `feature/*`.
* **`feature/<module>-<sujet>`** : une branche par fonctionnalité et par personne, créée à partir de `develop`. Exemples :
  - `feature/event-creation-sortie`
  - `feature/marketplace-nfc-tag`
  - `feature/transport-gps-route`
  - `feature/tutorial-accelerometer`
  - `feature/campsite-magnetometer-compass`
  - `feature/user-email-login`

---

## 2. Cycle de Développement Pas à Pas

1. **Partir de `develop` à jour :**
   ```bash
   git switch develop
   git pull origin develop
   git switch -c feature/<module>-<sujet>
   ```
2. **Développer dans son dossier (`lib/features/<module>/`)** :
   - Ne pas modifier les dossiers des autres modules.
   - Utiliser uniquement `lib/features/user/user_api.dart` pour accéder à l'utilisateur connecté ou à la session.
3. **Valider souvent avec de petits commits** (voir section 3).
4. **Mettre à jour sa branche avec `develop` avant d'ouvrir une PR :**
   ```bash
   git switch develop
   git pull origin develop
   git switch feature/<module>-<sujet>
   git merge develop
   ```
5. **Vérifier localement :**
   ```bash
   flutter analyze
   flutter test
   ```
   Une PR avec des erreurs d'analyse ou des tests échoués sera rejetée.
6. **Pousser sa branche et ouvrir une Pull Request vers `develop`** (et non vers `main`) :
   ```bash
   git push -u origin feature/<module>-<sujet>
   ```
7. **Relecture :** au moins une autre personne relit et approuve la PR. Les conflits éventuels sont résolus par l'auteur de la PR.
8. **Livraison :** quand `develop` est stable (tout compile, les tests passent, l'application se lance), le responsable d'intégration ouvre une PR `develop` → `main`, puis crée un tag : `git tag v1.0` et `git push --tags`.

---

## 3. Convention de Nommage des Commits

Format *Conventional Commits* :
* `feat(event): ajout du service BarometerService et de l'écran principal`
* `fix(marketplace): correction de la lecture du tag NFC sous Android`
* `test(transport): ajout des tests unitaires pour le calcul de distance GPS`
* `docs(readme): mise à jour de la documentation d'intégration`
* `refactor(tutorial): séparation des constantes de chaînes`

---

## 4. Règles de Code Obligatoires

* **Architecture figée :** la structure des dossiers et les contrats entre modules (`*_api.dart`, schémas de base, routes, shell) ne changent pas sans l'accord de toute l'équipe et une PR dédiée. Le contenu des modules évolue librement.
* **Aucune couleur ni texte en dur :** utiliser `Theme.of(context)`, `context.colors`, `context.text` et les fichiers de textes (`common_strings.dart`, `<module>_strings.dart`).
* **Base de données :** les écrans et providers n'appellent jamais `sqflite` directement ; ils passent par le repository de leur module. Chaque module a son schéma (`<module>_schema.dart`) et ses tables préfixées (`events_`, `listings_`, `trips_`, `guides_`, `campsites_`).
* **Ne jamais commiter :** `build/`, `.dart_tool/`, `.idea/`, `local.properties`, les fichiers `*.db`, `*.jks`, `*.keystore`, ni aucune clé ou secret.

---

## 5. Fichiers Partagés Sensibles (À modifier avec accord)

Prévenir l'équipe avant de modifier ces fichiers, faire des changements courts et les pousser vite :
* `pubspec.yaml` : prévenir avant d'ajouter un package.
* `lib/core/database/app_database.dart` : seul le responsable d'intégration incrémente la version de la base.
* `lib/core/routes/app_routes.dart`
* `lib/shell/app_shell.dart` et `lib/shell/shell_tab.dart` : chaque coéquipier modifie uniquement la ligne de son propre onglet.
* `lib/core/` (thème, widgets, utilitaires)
* `lib/app.dart` et `lib/main.dart`

---

## 6. Résolution de Problèmes Courants

* **Conflit Git :** Git marque le fichier avec `<<<<<<<`, `=======` et `>>>>>>>`. Dans VS Code, choisir Accept Current, Incoming ou Both, tester que l'application compile, puis `git add .` et `git commit`.
* **Conflit de lockfile Flutter sous Windows :**
  ```powershell
  Remove-Item C:\flutter\bin\cache\lockfile -Force -ErrorAction SilentlyContinue
  ```
* **Base SQLite corrompue ou en désaccord de schéma :** désinstaller l'application de l'émulateur Android pour supprimer la base locale, puis relancer avec `flutter run`.