# 🎁 Script de Scraping Amélioré pour DORON

Ce dossier contient les scripts améliorés pour scraper et importer les nouveaux produits dans Firebase.

## 📁 Fichiers

1. **`main_enhanced.py`** - Script principal amélioré avec génération de tags enrichis
2. **`links.csv`** - Liste de 114 nouveaux liens de produits
3. **`README.md`** - Ce fichier d'instructions

## 🚀 Comment utiliser

### Étape 1: Préparer Replit

1. Créez un nouveau Repl sur **Replit.com**
2. Choisissez le template **Python**
3. Nommez-le par exemple `doron-scraper-final`

### Étape 2: Uploader les fichiers

Uploadez ces fichiers dans votre Repl:
- `main_enhanced.py`
- `links.csv` (déjà présent dans ce dossier)
- `serviceAccountKey.json` (votre clé Firebase - **ne PAS commit sur GitHub!**)

### Étape 3: Installer les dépendances

Créez un fichier `requirements.txt` avec ce contenu:

```
firebase-admin==6.3.0
selenium==4.15.2
beautifulsoup4==4.12.2
```

Puis dans le terminal Replit, exécutez:
```bash
pip install -r requirements.txt
```

### Étape 4: Lancer le script

Dans le terminal Replit:
```bash
python main_enhanced.py
```

## ✨ Améliorations du script

Ce script amélioré inclut:

### 🏷️ Tags enrichis et intelligents

Le script génère automatiquement des tags basés sur:
- **Genre**: femme, homme, unisexe
- **Type de produit**: chaussures, sneakers, vêtements, accessoires, beauté, etc.
- **Budget**: budget_petit (<50€), budget_moyen (50-150€), budget_luxe (150-400€), budget_premium (>400€)
- **Style**: sportif, casual, élégant, luxe, vintage, moderne, streetwear
- **Occasions**: travail, soirée, quotidien
- **Matières**: cuir, coton, laine, velours
- **Âge**: 18-25ans, 20-30ans, 30-50ans
- **Marque**: tags spécifiques (italien, designer, fast-fashion, etc.)
- **Saisons**: hiver, été

### 📂 Catégories précises

- `chaussures` - Toutes les chaussures (sneakers, boots, mocassins, etc.)
- `vetements` - Vêtements (pulls, vestes, pantalons, robes, etc.)
- `accessoires` - Sacs, ceintures, lunettes, etc.
- `beaute` - Soins de la peau (skincare, crèmes, sérums, etc.)
- `maquillage` - Produits de maquillage (rouge à lèvres, palettes, etc.)
- `parfums` - Parfums et eaux de toilette
- `sport` - Vêtements et accessoires de sport
- `maison` - Décoration et articles maison
- `mode` - Catégorie générique pour les produits de mode

### 🎯 Marques supportées

- **Golden Goose** - Sneakers de luxe italiennes
- **Zara** - Mode tendance et accessible
- **Maje** - Mode française élégante
- **Miu Miu** - Haute couture italienne
- **Rhode** - Skincare naturel
- **Sephora** - Beauté et cosmétiques
- **Lululemon** - Vêtements de sport et yoga

## 📊 Produits dans le CSV

Le fichier `links.csv` contient **114 produits** de différentes catégories:

- **30 produits Golden Goose** - Sneakers, sacs, vêtements, accessoires
- **36 produits Zara** - Vêtements, chaussures, décoration
- **4 produits Maje** - Vêtements et chaussures
- **6 produits Miu Miu** - Accessoires et vêtements de luxe
- **7 produits Rhode** - Skincare et beauté
- **23 produits Sephora** - Maquillage, parfums, soins
- **8 produits Lululemon** - Vêtements et accessoires de sport

## 🔒 Sécurité

**IMPORTANT**: Ne jamais commit le fichier `serviceAccountKey.json` sur GitHub!

Assurez-vous que votre `.gitignore` contient:
```
serviceAccountKey.json
*.json
*.log
```

## 📝 Logs

Le script génère un fichier `scraping_log.txt` qui contient:
- L'historique complet de chaque scraping
- Les produits réussis et échoués
- Les détails de chaque produit (nom, prix, tags, catégories)
- Les statistiques finales

## 🎨 Diversité des produits

Le script est conçu pour créer une base de données variée avec:
- Différentes catégories de produits
- Différents budgets (de 15€ à 1000€+)
- Différents styles (sportif, élégant, casual, luxe)
- Différentes marques (luxe, accessible, sport, beauté)

Cela permet d'avoir une variété suffisante pour éviter d'afficher des produits similaires côte à côte dans l'application.

## ⚡ Performance

- Délai aléatoire entre chaque requête (3-6 secondes)
- Headers anti-détection
- Mode headless pour performance
- Gestion des erreurs robuste
- Retry automatique en cas d'échec

## 📞 Support

Si vous rencontrez des problèmes:
1. Vérifiez que `serviceAccountKey.json` est présent
2. Vérifiez que toutes les dépendances sont installées
3. Consultez le fichier `scraping_log.txt` pour les détails des erreurs
4. Assurez-vous que votre connexion Internet est stable

## 🎯 Résultat attendu

Après l'exécution, vous devriez avoir **~114 nouveaux produits** dans Firebase avec:
- Des tags pertinents et variés
- Des catégories précises
- Des images de produits réelles
- Des prix corrects
- Des descriptions

Ces produits s'ajouteront à votre base existante pour créer un catalogue riche et diversifié! 🎉
