# 🎁 Scripts de Scraping pour DORON - Version 2.0 STRICT

Ce dossier contient les scripts améliorés pour scraper et gérer les produits dans Firebase avec **VALIDATION STRICTE**.

## 📁 Fichiers

1. **`main_strict.py`** ⭐ - **NOUVEAU** Script ultra-strict (upload uniquement les produits 100% complets)
2. **`cleanup_firebase.py`** 🧹 - **NOUVEAU** Script de nettoyage (supprime les produits incomplets de Firebase)
3. **`main_enhanced.py`** - Script original avec tags enrichis (moins strict)
4. **`links.csv`** - Liste de **372 nouveaux liens** de produits
5. **`requirements.txt`** - Dépendances Python
6. **`README.md`** - Ce fichier d'instructions

## 🆕 Nouveautés Version 2.0

### ✅ Validation Stricte

Les nouveaux scripts garantissent que **100% des produits uploadés** ont:
- ✓ **Nom** valide (minimum 3 caractères)
- ✓ **Marque** reconnue (pas de "Unknown")
- ✓ **Prix** valide (> 0€)
- ✓ **Image** valide (URL complète)

### 🧹 Nettoyage Automatique

- Détecte tous les produits incomplets dans Firebase
- Tente de re-scraper les informations manquantes
- **Supprime automatiquement** les produits non récupérables
- Log complet de toutes les opérations

## 🚀 Comment utiliser

### Option 1: Scraper de nouveaux produits (RECOMMANDÉ) ⭐

Utilisez **`main_strict.py`** pour scraper les 372 nouveaux produits avec validation stricte.

#### Étape 1: Préparer Replit

1. Créez un nouveau Repl sur **Replit.com**
2. Choisissez le template **Python**
3. Nommez-le `doron-scraper-strict`

#### Étape 2: Uploader les fichiers

Uploadez ces fichiers dans votre Repl:
- `main_strict.py`
- `links.csv`
- `requirements.txt`
- `serviceAccountKey.json` (votre clé Firebase - **ne PAS commit sur GitHub!**)

#### Étape 3: Installer les dépendances

Dans le terminal Replit:
```bash
pip install -r requirements.txt
```

#### Étape 4: Lancer le script strict

```bash
python main_strict.py
```

**Résultat**: Seuls les produits avec TOUTES les informations seront uploadés.

---

### Option 2: Nettoyer Firebase des produits incomplets 🧹

Utilisez **`cleanup_firebase.py`** pour nettoyer les produits existants dans Firebase.

#### Étape 1-3: Identiques à l'Option 1

#### Étape 4: Lancer le script de nettoyage

```bash
python cleanup_firebase.py
```

**Résultat**:
- Produits valides: ✅ Conservés
- Produits incomplets mais réparables: 🔧 Corrigés automatiquement
- Produits non réparables: 🗑️ Supprimés de Firebase

## 📊 Produits dans le CSV (372 nouveaux liens)

Le fichier `links.csv` contient **372 produits** de marques variées:

### 💎 Joaillerie de Luxe (36 produits)
- **3 Messika** - Bracelets diamants or blanc
- **33 Zag Bijoux** - Bijoux tendance français

### 📱 Tech & Électronique (85 produits)
- **13 Back Market** - iPhone, MacBook, iPad, PS5, Galaxy (reconditionnés)
- **27 Boulanger** - Électronique et gaming
- **45 Fnac** - Casques audio, AirPods, gaming, vinyles, cadeaux personnalisés

### 👗 Mode & Luxe (206 produits)
- **204 Galeries Lafayette** - Mode luxe, beauté, accessoires
- **2 Maison Margiela** - Haute couture

### 🏃 Sport & Bien-être (19 produits)
- **19 Alo Yoga** - Vêtements de yoga et athleisure

### 🕶️ Accessoires (18 produits)
- **5 Printemps** - Lunettes de soleil
- **7 Rimowa** - Valises et accessoires de voyage
- **5 Ikea** - Maison et décoration
- **10 Moon Nude** - Trousses maquillage

### Total: **372 nouveaux produits** 🎉

## 🏷️ Tags et Catégories Automatiques

Le script génère automatiquement des tags basés sur:

### Genre
- femme, homme, unisexe

### Catégories de produits
- **Mode**: chaussures, vêtements, accessoires
- **Beauté**: maquillage, parfums, skincare
- **Sport**: fitness, yoga, running
- **Tech**: électronique, gaming, audio
- **Maison**: décoration, meubles
- **Voyage**: valises, bagages

### Budget
- `budget_petit` - Moins de 50€
- `budget_moyen` - 50-150€
- `budget_luxe` - 150-400€
- `budget_premium` - Plus de 400€

### Style
- sportif, casual, élégant, luxe, vintage, moderne, streetwear

### Occasions
- travail, soirée, quotidien

### Matières
- cuir, coton, laine, velours

### Âge cible
- 18-25ans, 20-30ans, 30-50ans

## 🎯 Marques Supportées (20 marques)

### Mode Luxe
- **Messika** - Joaillerie diamants
- **Maison Margiela** - Avant-garde
- **Miu Miu** - Haute couture italienne
- **Golden Goose** - Sneakers luxe
- **Galeries Lafayette** - Grand magasin luxe
- **Printemps** - Grand magasin parisien

### Mode Accessible
- **Zara** - Fast-fashion tendance
- **Maje** - Mode française
- **Zag Bijoux** - Bijoux accessibles

### Sport & Bien-être
- **Lululemon** - Athleisure premium
- **Alo Yoga** - Vêtements de yoga

### Beauté
- **Sephora** - Cosmétiques
- **Rhode** - Skincare naturel
- **Moon Nude** - Accessoires beauté

### Tech & Électronique
- **Back Market** - Tech reconditionné
- **Boulanger** - Électronique
- **Fnac** - Multimédia et culture

### Maison & Voyage
- **Ikea** - Meubles et décoration
- **Rimowa** - Bagagerie luxe

## 🔍 Sélecteurs CSS Spécifiques par Site

Le script `main_strict.py` inclut des sélecteurs CSS optimisés pour chaque site:

- **Messika**: `.product-name`, `.price`
- **Back Market**: `[data-qa="product-title"]`, `[data-qa="price"]`
- **Boulanger**: `.product-title`, `.price`
- **Fnac**: `.f-productHeader-Title`, `.f-priceBox-price`
- **Galeries Lafayette/Printemps**: `.ProductName`, `.ProductPrice`
- **Ikea**: `.pip-header-section__title`, `.pip-temp-price__integer`
- **Alo Yoga**: `[data-testid="product-title"]`
- Et bien plus...

## 🔒 Sécurité

**IMPORTANT**: Ne jamais commit le fichier `serviceAccountKey.json` sur GitHub!

Assurez-vous que votre `.gitignore` contient:
```
serviceAccountKey.json
*.json
*.log
```

## 📝 Logs

### `main_strict.py` génère `scraping_strict_log.txt`
- Historique complet de chaque scraping
- Produits valides uploadés
- Produits rejetés avec raisons
- Statistiques finales

### `cleanup_firebase.py` génère `cleanup_log.txt`
- Produits analysés
- Produits valides conservés
- Produits corrigés
- Produits supprimés

## ⚡ Performance & Sécurité

- **3 tentatives** de scraping par produit avant abandon
- Délai aléatoire entre requêtes (4-7 secondes)
- Headers anti-détection
- Mode headless pour performance
- Gestion des erreurs robuste
- Validation stricte avant upload

## 🎯 Workflow Recommandé

### 1️⃣ Nettoyer Firebase d'abord
```bash
python cleanup_firebase.py
```
Cela supprimera tous les produits incomplets existants.

### 2️⃣ Scraper les nouveaux produits
```bash
python main_strict.py
```
Cela ajoutera 372 nouveaux produits 100% complets.

### 3️⃣ Vérifier les résultats
Consultez les logs pour voir:
- Combien de produits ont été uploadés
- Combien ont été rejetés
- Pourquoi certains ont échoué

## 📈 Résultat Attendu

Après l'exécution complète, vous devriez avoir:

✅ **0 produits incomplets** dans Firebase
✅ **Tous les produits** avec nom + marque + prix + image
✅ **Tags pertinents** pour chaque produit
✅ **Catégories précises**
✅ **Base de données propre et fiable**

## ❓ FAQ

### Le script rejette beaucoup de produits, c'est normal?

**Oui!** Le mode strict est conçu pour rejeter les produits incomplets. C'est voulu pour garantir la qualité.

### Que faire si un produit important est rejeté?

1. Vérifiez les logs pour voir quelle information manque
2. Vérifiez manuellement le site web
3. Si le site est en maintenance ou bloque le scraping, réessayez plus tard

### Puis-je utiliser l'ancien script `main_enhanced.py`?

Oui, mais il peut uploader des produits incomplets. Utilisez `main_strict.py` pour garantir la qualité.

### Combien de temps prend le scraping de 372 produits?

Environ **30-45 minutes** avec les délais anti-blocage (4-7 secondes par produit).

## 📞 Support

Si vous rencontrez des problèmes:
1. Vérifiez que `serviceAccountKey.json` est présent
2. Vérifiez que toutes les dépendances sont installées
3. Consultez les fichiers de log pour les détails des erreurs
4. Assurez-vous que votre connexion Internet est stable
5. Certains sites peuvent bloquer le scraping - c'est normal

## 🎉 Succès!

Félicitations! Vous avez maintenant un système de scraping professionnel qui garantit une base de données Firebase propre et complète pour l'application DORON! 🚀
