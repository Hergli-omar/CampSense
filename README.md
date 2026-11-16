# CampSense 🏕️

Application mobile Flutter pour campeurs et randonneurs fonctionnant **100 % hors-ligne** (*offline-first*), basée sur SQLite (`sqflite`), Provider et une architecture découplée par fonctionnalités (*Feature-First*).

---

## 🚀 Démarrage Rapide

### Prérequis
* Flutter 3.47.5 (channel stable, Dart 3.13.4). Tout le monde doit utiliser la même version.
* Émulateur Android (ou appareil physique Android)

### Installation & Lancement
```bash
# 1. Cloner le projet (branche par défaut : develop) et installer les dépendances
git clone https://github.com/Hergli-omar/campsense.git
cd campsense
flutter pub get

# 2. Vérifier la conformité du code (0 erreurs / 0 warnings attendus)
flutter analyze

# 3. Exécuter tous les tests unitaires
flutter test

# 4. Lancer l'application sur l'émulateur
flutter run
```

---

## 👥 Comptes de Démonstration Pré-enregistrés

Au premier lancement, l'application insère automatiquement les comptes de test suivants :

| Rôle | Email | Mot de Passe | Description |
|---|---|---|---|
| **Administrateur** | `omar@campsense.com` | `Admin1234` | Accès à l'AdminShell (Utilisateurs, Signalements, Profil) |
| **Campeur** | `azza.drissi@example.com` | `Camp1234` | Profil campeur complet avec 3 séjours et contact d'urgence |
| **Organisateur** | `noe.bernard@example.com` | `Camp1234` | Compte organisateur de sorties |

---

## 📚 Documentation Technique

* [**ARCHITECTURE.md**](ARCHITECTURE.md) : Schéma d'arborescence, contrats SQLite (`ModuleSchema`), routage modulaire (`AppRouter`), API publique inter-modules (`user_api.dart`) et checklist pas à pas pour brancher un nouveau module.
* [**CONTRIBUTING.md**](CONTRIBUTING.md) : Workflow Git (branches `main` / `develop` / `feature/*`, Pull Requests vers `develop`, format des commits).