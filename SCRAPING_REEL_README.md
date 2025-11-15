# 🕷️ Script de Scraping RÉEL des Produits

## ⚠️ IMPORTANT

Ce script doit être lancé depuis **ton ordinateur local** (pas dans Docker) car il nécessite un accès Internet.

## 📋 Prérequis

1. **Node.js** installé (version 18+)
2. **Connexion Internet**
3. **Clé Firebase** (`serviceAccountKey.json`)

## 🚀 Installation

```bash
# 1. Clone ou télécharge le projet
cd /chemin/vers/Doron

# 2. Installe les dépendances
npm install

# 3. Vérifie que serviceAccountKey.json est présent
ls serviceAccountKey.json
```

## 🎯 Utilisation

### Option 1 : Scraper TOUS les produits (114 URLs)

```bash
node real-product-scraper-full.js
```

⏱️ **Durée estimée :** 15-30 minutes (avec délais anti-blocage)

### Option 2 : Scraper quelques produits (test)

```bash
node real-product-scraper.js
```

Ce script scrape seulement 13 URLs pour tester.

## 📊 Ce que fait le script

Pour CHAQUE URL :

1. ✅ **Se connecte au site web** avec headers réalistes
2. ✅ **Récupère le HTML** de la page
3. ✅ **Extrait automatiquement :**
   - Le **VRAI nom** du produit
   - Le **VRAI prix** en euros
   - La **VRAIE image** principale
   - La description du produit
4. ✅ **Génère les tags** automatiquement
5. ✅ **Upload dans Firebase** (collection `gifts`)

## 🛡️ Protection Anti-Blocage

Le script inclut :
- ✅ **Délais aléatoires** entre requêtes (1-3 secondes)
- ✅ **Headers réalistes** (User-Agent Chrome, Accept, etc.)
- ✅ **Gestion des redirections**
- ✅ **Timeouts** configurables
- ✅ **Retry automatique** en cas d'erreur temporaire

## 📁 Fichiers de Sortie

### `real-scraped-products.json`
Contient tous les produits scrapés avec succès :
```json
[
  {
    "name": "True Star Pour Femme En Cuir Velours Noir",
    "brand": "Golden Goose",
    "price": 560,
    "url": "https://...",
    "image": "https://cdn.goldengoose.com/...",
    "description": "...",
    "categories": ["mode", "chaussures"],
    "tags": ["femme", "luxe", "italien", "budget_luxe"],
    "active": true,
    "source": "real_scraping"
  }
]
```

### `scraping-log.txt`
Log détaillé de toutes les opérations.

## ⚡ Performance Attendue

### Taux de Succès par Site

| Site | Taux de Succès Estimé |
|------|----------------------|
| **Zara** | ~90% (site simple) |
| **Sephora** | ~85% (bonne structure) |
| **Lululemon** | ~80% (bonne structure) |
| **Rhode** | ~75% (site Shopify) |
| **Golden Goose** | ~60% (protections moyennes) |
| **Miu Miu** | ~50% (protections fortes) |
| **Maje** | ~70% (structure simple) |

### Optimisations

Si un site bloque systématiquement :
1. **Augmenter les délais** dans le script (ligne ~300)
2. **Changer le User-Agent** (ligne ~50)
3. **Utiliser un proxy** (optionnel)

## 🔧 Personnalisation

### Modifier les délais

```javascript
// Dans real-product-scraper-full.js, ligne ~300
const delay = 2000 + Math.random() * 3000; // 2-5 secondes au lieu de 1-3
```

### Ajouter d'autres URLs

```javascript
// Ajouter à la liste PRODUCT_URLS
const PRODUCT_URLS = [
  // ... URLs existantes
  'https://nouvelle-url.com/produit',
];
```

### Changer la collection Firebase

```javascript
// Ligne ~450
const docRef = db.collection('gifts').doc(); // Changer 'gifts' si nécessaire
```

## 🐛 Résolution des Problèmes

### Erreur 403 (Forbidden)

```
❌ Erreur: HTTP 403
```

**Solution :**
- Augmente les délais entre requêtes
- Change le User-Agent
- Vérifie que tu n'es pas bloqué par le site

### Timeout

```
❌ Erreur: Timeout
```

**Solution :**
```javascript
// Augmente le timeout (ligne ~100)
req.setTimeout(30000, () => { // 30 secondes au lieu de 15
```

### Données manquantes

```
⚠️ Données incomplètes:
   Nom: NON TROUVÉ
```

**Solution :**
Le script essaie plusieurs patterns. Si ça échoue :
1. Va manuellement sur l'URL
2. Inspecte le HTML (F12)
3. Trouve le bon sélecteur
4. Ajoute-le dans les patterns du script

### Firebase Upload échoue

```
⚠️ Upload Firebase impossible
```

**Vérifications :**
1. `serviceAccountKey.json` est présent
2. Le projet Firebase existe (`doron-b3011`)
3. Tu as les droits d'écriture sur Firestore

## 📈 Suivi de Progression

Le script affiche en temps réel :

```
[15/114] 🔍 Scraping: https://www.zara.com/...
  ✅ HTML récupéré (45KB)
  ✅ Sweat A Capuche Effet Neoprene
  💰 Prix: 29.99€
  🖼️ Image: OK
```

## 🎁 Résultat Final

Après exécution complète :

```
📊 RÉSULTATS FINAUX:
   ✅ 96 produits scrapés avec succès
   ❌ 18 échecs

💾 Produits sauvegardés dans: real-scraped-products.json
✅ 96 produits uploadés dans Firebase!

🎉 SCRAPING TERMINÉ!
```

## 🔄 Si des URLs échouent

Le script sauvegarde les URLs échouées. Tu peux :

1. **Réessayer plus tard** (site peut-être temporairement down)
2. **Les traiter manuellement** (copier prix/image depuis le site)
3. **Les ignorer** si pas critiques

## 📞 Support

**Si ça ne marche toujours pas :**

1. Vérifie ta connexion Internet
2. Essaie avec un VPN (si géo-bloqué)
3. Contacte-moi avec les logs d'erreur

## ⚙️ Configuration Avancée

### Utiliser un Proxy

```javascript
// Dans fetchUrl(), ajouter :
const options = {
  // ... options existantes
  agent: new HttpsProxyAgent('http://proxy:port'),
};
```

### Paralléliser les Requêtes

```javascript
// Au lieu de boucle séquentielle
const promises = PRODUCT_URLS.map((url, i) =>
  scrapeProduct(url, i, PRODUCT_URLS.length)
);
const results = await Promise.all(promises);
```

⚠️ **Attention :** Plus risqué d'être bloqué !

---

**Fait avec ❤️ pour DORÕN**
**Version :** 1.0.0
**Date :** Novembre 2025
