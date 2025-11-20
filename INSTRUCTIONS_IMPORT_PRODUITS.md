# 📦 Instructions pour importer les produits d'exemple dans Firebase

## 🎯 Objectif
Importer 10 produits correctement tagués dans Firebase pour tester le nouveau système de tags.

---

## 🚀 OPTION 1: Import Automatique (Recommandé)

### Étape 1: Télécharger la clé de service Firebase

1. Va sur [Firebase Console](https://console.firebase.google.com)
2. Sélectionne ton projet **doron-b3011**
3. Clique sur l'icône ⚙️ (Paramètres) → **Project settings**
4. Va dans l'onglet **Service accounts**
5. Clique sur **Generate new private key**
6. Un fichier JSON sera téléchargé (ex: `doron-b3011-firebase-adminsdk-xxxxx.json`)
7. **Renomme-le** en `serviceAccountKey.json`
8. **Place-le** dans le dossier racine du projet (même niveau que `import_products.js`)

### Étape 2: Installer les dépendances

```bash
npm install firebase-admin
```

### Étape 3: Lancer l'import

```bash
node import_products.js
```

### Résultat attendu:
```
🔄 Début de l'importation des produits...

✅ Exemple 1: Montre connectée Samsung (Tech, Mixte, 100-200€)
   ID: prod_001
   Tags: 10 tags
   Prix: 129€

✅ Exemple 2: Sac à main Longchamp (Mode, Femme, 100-200€)
   ID: prod_002
   Tags: 9 tags
   Prix: 145€

... (8 autres produits)

═══════════════════════════════════════
📊 RÉSUMÉ DE L'IMPORTATION
═══════════════════════════════════════
✅ Produits importés: 10
❌ Erreurs: 0
📦 Total: 10

🎉 Tous les produits ont été importés avec succès!
```

---

## 📝 OPTION 2: Import Manuel (Si option 1 ne marche pas)

### Étape 1: Ouvrir Firebase Console

1. Va sur https://console.firebase.google.com
2. Sélectionne **doron-b3011**
3. Clique sur **Firestore Database** dans le menu de gauche
4. Clique sur **Start collection** (ou ouvre la collection `gifts` si elle existe)

### Étape 2: Créer la collection (si nécessaire)

- Collection ID: `gifts`
- Clique sur **Next**

### Étape 3: Importer chaque produit

Ouvre le fichier `EXEMPLES_PRODUITS_FIREBASE.json` et pour chaque produit:

#### Exemple pour le Produit 1 (Montre Samsung):

1. Clique sur **Add document**
2. Document ID: `prod_001` (ou laisse auto-générer)
3. Ajoute les champs suivants:

**Champs STRING:**
- `name` = `Montre Connectée Samsung Galaxy Watch 6`
- `brand` = `Samsung`
- `description` = `Montre connectée avec suivi santé complet, GPS, étanche`
- `image` = `https://example.com/samsung-watch.jpg`
- `source` = `Amazon`

**Champs NUMBER:**
- `price` = `129`
- `popularity` = `85`

**Champ ARRAY (tags):**
- Clique sur **Add field**
- Field: `tags`
- Type: **array**
- Ajoute chaque tag un par un:
  - `gender_mixte`
  - `cat_tech`
  - `budget_100_200`
  - `style_moderne`
  - `style_sportif`
  - `perso_actif`
  - `perso_techie`
  - `passion_tech`
  - `passion_sport`
  - `type_high_tech`

**Champ ARRAY (categories):**
- Field: `categories`
- Type: **array**
- Valeurs:
  - `Électronique`
  - `Sport`
  - `Santé`

4. Clique sur **Save**

**Répète pour les 9 autres produits** en suivant les données de `EXEMPLES_PRODUITS_FIREBASE.json`

---

## 🔍 Vérification après import

### 1. Dans Firebase Console

1. Ouvre Firestore Database
2. Collection `gifts`
3. Tu devrais voir 10 documents
4. Clique sur un produit
5. Vérifie que le champ `tags` contient bien les tags au format:
   - `gender_*`
   - `cat_*`
   - `budget_*`
   - Etc.

### 2. Dans l'application

1. Lance l'app
2. Va sur la page d'accueil
3. Tu devrais voir des produits s'afficher
4. Teste les filtres:
   - Filtre "Tech" → devrait montrer la montre Samsung, la Switch, l'enceinte JBL
   - Filtre "Mode" → devrait montrer le sac Longchamp
   - Filtre "0-50€" → devrait montrer le kit jardinage, le livre, le tapis de yoga

### 3. Vérifier les logs

Dans la console de l'app, tu devrais voir:
```
✅ Tags convertis: 5 tags valides sur 5 générés
🏷️ Tags finaux: gender_femme, cat_mode, budget_100_200, style_elegant, passion_mode
🔍 Scoring produit "Sac Longchamp Le Pliage": 9 tags
✅ GENRE MATCH: gender_femme = +100 points
✅ CATÉGORIE MATCH: cat_mode = +80 points
✅ BUDGET MATCH: budget_100_200 = +60 points
🎨 STYLES: 1 matches = +20 points
❤️ PASSIONS: 1 matches = +25 points
🏁 SCORE FINAL: 285.3 points
```

---

## ⚠️ IMPORTANT: Structure obligatoire des tags

Chaque produit **DOIT** avoir au minimum:

### Tags STRICTS (obligatoires):
```json
"tags": [
  "gender_*",      // gender_femme, gender_homme, ou gender_mixte
  "cat_*",         // cat_tech, cat_mode, cat_maison, cat_beaute, cat_food, cat_tendances
  "budget_*"       // budget_0_50, budget_50_100, budget_100_200, budget_200+
]
```

### Tags SOUPLES (recommandés):
```json
"tags": [
  "style_*",       // style_elegant, style_moderne, etc. (0-3 tags)
  "perso_*",       // perso_creatif, perso_actif, etc. (0-3 tags)
  "passion_*",     // passion_sport, passion_mode, etc. (0-5 tags)
  "type_*"         // type_high_tech, type_mode_accessoires, etc. (0-2 tags)
]
```

**Sans les tags STRICTS, le produit sera EXCLU du matching!**

---

## 🎯 Tags disponibles (liste complète)

### Genre (1 obligatoire)
- `gender_femme`
- `gender_homme`
- `gender_mixte`

### Catégories (1 obligatoire)
- `cat_tendances` - Produits viraux, TikTok, nouveautés
- `cat_tech` - High-tech, gadgets, électronique
- `cat_mode` - Vêtements, accessoires mode
- `cat_maison` - Déco, maison, intérieur
- `cat_beaute` - Beauté, soins, parfums
- `cat_food` - Gastronomie, cuisine, alimentaire

### Budget (1 obligatoire)
- `budget_0_50` - Moins de 50€
- `budget_50_100` - Entre 50€ et 100€
- `budget_100_200` - Entre 100€ et 200€
- `budget_200+` - Plus de 200€

### Styles (optionnel, 0-3 recommandé)
`style_elegant`, `style_tendance`, `style_minimaliste`, `style_classique`, `style_decontracte`, `style_sportif`, `style_vintage`, `style_moderne`, `style_luxe`, `style_boheme`, `style_streetwear`, `style_eco_responsable`

### Personnalités (optionnel, 0-3 recommandé)
`perso_creatif`, `perso_actif`, `perso_cool`, `perso_bienveillant`, `perso_ambitieux`, `perso_romantique`, `perso_aventurier`, `perso_intellectuel`, `perso_sociable`, `perso_zen`, `perso_excentrique`, `perso_pratique`, `perso_gourmand`, `perso_techie`

### Passions (optionnel, 0-5 recommandé)
`passion_sport`, `passion_cuisine`, `passion_voyages`, `passion_photo`, `passion_jeuxvideo`, `passion_lecture`, `passion_musique`, `passion_cinema`, `passion_mode`, `passion_beaute`, `passion_tech`, `passion_art`, `passion_jardinage`, `passion_bricolage`, `passion_yoga`, `passion_danse`, `passion_nature`, `passion_animaux`, `passion_automobile`, `passion_vins`

### Types de cadeaux (optionnel, 0-2 recommandé)
`type_mode_accessoires`, `type_bien_etre`, `type_sport_outdoor`, `type_gastronomie`, `type_culture`, `type_high_tech`, `type_maison_deco`, `type_beaute_soins`, `type_loisirs_creatifs`, `type_jeux_jouets`, `type_livres_bd`, `type_musique_audio`, `type_voyage_aventure`, `type_automobile`, `type_bijoux`

---

## 🚨 Problèmes courants

### Problème: "firebase-admin not found"
**Solution:**
```bash
npm install firebase-admin
```

### Problème: "serviceAccountKey.json not found"
**Solution:** Assure-toi d'avoir:
1. Téléchargé la clé de service depuis Firebase Console
2. Renommé le fichier en `serviceAccountKey.json`
3. Placé le fichier dans le dossier racine

### Problème: "Permission denied"
**Solution:**
1. Vérifie que tu as les droits Admin sur le projet Firebase
2. Régénère une nouvelle clé de service

### Problème: "Produits importés mais app n'affiche rien"
**Solution:**
1. Vérifie que les tags sont au bon format (gender_*, cat_*, budget_*)
2. Vérifie que le champ `tags` est bien un **array**, pas un string
3. Relance l'app complètement

---

## ✅ Checklist finale

Après l'import, vérifie:
- [ ] 10 produits dans Firestore collection `gifts`
- [ ] Chaque produit a un champ `tags` de type **array**
- [ ] Chaque produit a au moins 3 tags: gender_*, cat_*, budget_*
- [ ] Chaque produit a un prix (field `price` de type number)
- [ ] Chaque produit a une image (field `image` de type string avec URL)
- [ ] L'app affiche des produits sur la page d'accueil
- [ ] Les filtres fonctionnent (catégorie, prix)
- [ ] Les logs montrent des scores de matching

**Si tous les points sont cochés, le système est prêt!** 🎉
