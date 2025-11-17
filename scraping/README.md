# 🎯 Scraper Strict Firebase - DORON

## 📋 Description

Système de scraping e-commerce avec **validation stricte à 100%** qui garantit que **AUCUN** produit incomplet ne sera uploadé dans Firebase.

### ✨ Caractéristiques

- ✅ **Validation Stricte** : Refuse TOUT produit sans prix, sans image ou incomplet
- 🔄 **Retry Automatique** : 3 tentatives avant abandon
- 🎯 **Sélecteurs CSS Optimisés** : Configuration par site pour une extraction précise
- 📊 **Logging Détaillé** : Logs complets de chaque opération
- 🗑️ **Nettoyage Automatique** : Script de cleanup pour supprimer les données invalides
- 🔒 **Sécurisé** : Credentials Firebase isolés

---

## 🚀 Installation

### 1. Installer les dépendances Python

```bash
cd scraping
pip install -r requirements.txt
```

### 2. Vérifier les credentials Firebase

Le fichier `firebase_credentials.json` doit être présent dans le dossier `scraping/`.

---

## 📖 Utilisation

### Script Principal - Scraping Strict

```bash
python main_strict.py
```

**Ce script va :**
1. 📡 Scraper les sites configurés (Amazon, Cdiscount, Fnac, etc.)
2. ✅ Valider STRICTEMENT chaque produit
3. ❌ Rejeter tout produit incomplet
4. 📤 Uploader uniquement les produits 100% valides
5. 📊 Générer un rapport détaillé dans `scraping_strict_log.txt`

### Script de Nettoyage Firebase

```bash
python cleanup_firebase.py
```

**Ce script va :**
1. 🔍 Analyser tous les produits dans Firebase
2. ❌ Identifier les produits invalides (sans prix, sans image, etc.)
3. 📋 Afficher un rapport détaillé
4. 🗑️ Supprimer les produits invalides (avec confirmation)
5. 📊 Générer un rapport dans `cleanup_log.txt`

---

## ⚙️ Configuration

### Modifier les sites à scraper

Éditer `config.py` :

```python
# Ajouter un nouveau site
SITES_CONFIG = {
    "mon_site": {
        "name": "Mon Site",
        "base_url": "https://www.monsite.com",
        "selectors": {
            "product_card": "div.product",
            "title": "h2.title",
            "price": "span.price",
            "image": "img.product-img",
            "url": "a.product-link"
        },
        "search_params": {
            "q": "{query}"
        }
    }
}
```

### Modifier les requêtes de recherche

Dans `main_strict.py`, fonction `main()` :

```python
sites_to_scrape = ["amazon", "cdiscount", "fnac"]
queries = ["smartphone", "laptop", "casque audio"]
```

### Modifier les règles de validation

Dans `config.py`, section `VALIDATION_RULES` :

```python
VALIDATION_RULES = {
    "title": {
        "min_length": 5,
        "max_length": 500,
        "required": True
    },
    "price": {
        "min_value": 0.01,
        "max_value": 999999.99,
        "required": True,
        "type": "float"
    }
}
```

---

## 📊 Logs et Rapports

### `scraping_strict_log.txt`

Log détaillé du scraping :
- ✅ Produits acceptés avec détails
- ❌ Produits rejetés avec raisons
- 📊 Statistiques globales
- ⚠️ Erreurs rencontrées

**Exemple :**
```
2025-11-17 18:00:00 - INFO - 🎯 SCRAPING: Amazon
2025-11-17 18:00:01 - INFO - 📦 50 produits trouvés
2025-11-17 18:00:02 - INFO - ✅ PRODUIT ACCEPTÉ
2025-11-17 18:00:03 - ERROR - ❌ PRODUIT REJETÉ - Prix manquant
```

### `cleanup_log.txt`

Log du nettoyage Firebase :
- 🔍 Produits analysés
- ❌ Produits invalides détectés
- 🗑️ Produits supprimés
- 📊 Statistiques par site

---

## 🔍 Validation Stricte

### Champs REQUIS (obligatoires)

Tous ces champs **DOIVENT** être présents :

- ✅ `title` : Titre du produit (5-500 caractères)
- ✅ `price` : Prix (>0.01, format float)
- ✅ `image` : URL de l'image (format HTTP/HTTPS)
- ✅ `url` : URL du produit (format HTTP/HTTPS)
- ✅ `site` : Nom du site source

### Champs OPTIONNELS

- `rating` : Note du produit
- `category` : Catégorie du produit
- `description` : Description

---

## 💡 Avantages vs Ancien Script

### ❌ Ancien Script (main_enhanced.py)

- ⚠️ Uploadait des produits sans prix
- ⚠️ Uploadait des produits sans image
- ⚠️ Pas de retry en cas d'échec
- ⚠️ Validation partielle

### ✅ Nouveau Script (main_strict.py)

- ✅ Refuse TOUT produit incomplet
- ✅ 3 tentatives avant abandon
- ✅ Validation stricte à 100%
- ✅ Sélecteurs CSS optimisés par site
- ✅ Logs détaillés
- ✅ Statistiques complètes

---

## 🎯 Résultat

**Garantie : Tu n'auras plus JAMAIS de produits vides dans Firebase! 🎉**

Chaque produit uploadé est :
- ✅ 100% complet
- ✅ 100% validé
- ✅ 100% conforme

---

## 🛠️ Structure des Fichiers

```
scraping/
├── main_strict.py              # Script principal de scraping
├── cleanup_firebase.py         # Script de nettoyage
├── config.py                   # Configuration des sites et règles
├── requirements.txt            # Dépendances Python
├── firebase_credentials.json   # Credentials Firebase
├── scraping_strict_log.txt    # Log du scraping (généré)
├── cleanup_log.txt            # Log du nettoyage (généré)
└── README.md                  # Cette documentation
```

---

## 📞 Support

En cas de problème :

1. Vérifier les logs dans `scraping_strict_log.txt`
2. Vérifier que Firebase est accessible
3. Vérifier que les sélecteurs CSS sont à jour
4. Ajuster la configuration dans `config.py`

---

## 🔐 Sécurité

⚠️ **IMPORTANT** : Ne jamais commit `firebase_credentials.json` sur GitHub !

Le fichier est déjà dans `.gitignore`.

---

**Créé avec ❤️ pour DORON**
