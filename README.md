# DariBudget — Budget familial (Flutter, Offline‑First)

**DariBudget** est une application **mobile‑first** de gestion de budget familial : simple, rapide, élégante (thème **Forest & Gold**), et surtout **offline‑first**.

> Objectif : noter ses dépenses en 3 secondes, suivre ses enveloppes (budgets) et gérer ses courses — même sans internet.

## ✅ Fonctionnalités (v1)

- **Dashboard** (navigation) : accès rapide aux modules
- **Dépenses (SQLite)** : ajouter / lister / supprimer
- **Budgets (SQLite)** : ajouter / lister / supprimer (par mois)
- **Courses (SQLite)** : ajouter / cocher “fait” / supprimer
- **Multi‑langues** : **FR / AR (RTL) / EN**
- **Stockage local** : base **SQLite** via **Drift**

## 🧭 Roadmap

- **v1.1** : Dashboard calculé (totaux, reste du mois, graphiques)
- **v1.2** : Catégories (icônes, couleurs), filtres, recherche
- **v1.3** : Export/backup local
- **v2** : Sync cloud optionnelle (payante) + chiffrement (AES‑256)
- **v3** : Coach IA (conseils, anomalies)

## 🧱 Architecture

- **App** : Flutter
- **Routing** : `go_router`
- **State** : `provider`
- **DB locale** : SQLite (`drift`, `sqlite3_flutter_libs`)

## 🗂️ Structure du dépôt

- `daribudget/` → **nouvelle application Flutter**
- `legacy/v1/` → **ancienne version archivée** (historique conservé)

## ▶️ Lancer en local (dev)

Pré‑requis : Flutter installé (v3+).

```bash
cd daribudget
flutter pub get
flutter run
```

### Build Android (APK)
```bash
cd daribudget
flutter build apk --release
# APK : build/app/outputs/flutter-apk/app-release.apk
```

## 🌍 Langues / RTL

- FR : `fr`
- AR : `ar` (**RTL activé automatiquement**)
- EN : `en`

> Les traductions “propres” via fichiers ARB seront ajoutées au fur et à mesure (actuellement : UI de base + sélecteur de langue).

## 🔐 Sécurité

- Aucune clé/token ne doit être commitée.
- Données **locales** par défaut (SQLite).
- Sync cloud : prévue plus tard, avec chiffrement.

## 🤝 Contribution

- Issues / PR bienvenues.
- Merci de respecter `legacy/v1/` : on n’y modifie plus le code, c’est une archive.

## 📄 Licence

Voir `legacy/v1/LICENSE` (la licence sera dupliquée à la racine si nécessaire).

