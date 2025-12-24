# 📦 Upload des Produits dans Firebase

## ✅ Produits Générés

**114 produits** ont été générés automatiquement à partir des URLs fournies :
- 30 produits Golden Goose
- 36 produits Zara
- 4 produits Maje
- 6 produits Miu Miu
- 7 produits Rhode
- 22 produits Sephora
- 9 produits Lululemon

Les produits sont prêts dans le fichier : **`gifts-ready-for-upload.json`**

## 📋 Structure des Produits

Chaque produit contient :
- ✅ **name** : Nom complet du produit
- ✅ **brand** : Marque (Golden Goose, Zara, Maje, etc.)
- ✅ **price** : Prix en euros (numérique)
- ✅ **url** : Lien d'achat original
- ✅ **image** : URL de l'image (placeholder Unsplash de qualité)
- ✅ **description** : Description du produit
- ✅ **categories** : Array de catégories (mode, beauté, sport, déco)
- ✅ **tags** : Array de tags (femme/homme, âge, style, occasion, prix)
- ✅ **popularity** : Score de popularité (75)
- ✅ **active** : true (tous les produits sont actifs)
- ✅ **source** : "smart_parser"

## 🚀 Comment Uploader les Produits

### Option 1 : Upload via la Console Firebase (Recommandé)

1. Ouvre la [Console Firebase](https://console.firebase.google.com/)
2. Sélectionne le projet **doron-b3011**
3. Va dans **Firestore Database**
4. Crée la collection **`gifts`** si elle n'existe pas
5. Importe le fichier `gifts-ready-for-upload.json`

### Option 2 : Upload via Script Node.js (Environnement Local)

Si tu as un environnement local avec accès Firebase :

```bash
node prepare-gifts-for-upload.js
```

Le script va automatiquement uploader tous les produits dans la collection `gifts`.

### Option 3 : Upload Progressif via l'App

Une fois l'app déployée, tu peux utiliser la fonctionnalité admin pour uploader les produits progressivement.

## 🎯 Utilisation dans l'App

Une fois les produits uploadés, ils seront automatiquement disponibles dans :
- **Page d'accueil** : Affichage personnalisé basé sur l'onboarding
- **Page Recherche** : Suggestions de cadeaux pour chaque personne
- **Mode Inspiration** : Scroll vertical type TikTok
- **Favoris** : Possibilité de sauvegarder des cadeaux

## 🔧 Schema Dart Créé

Le schema `GiftsRecord` a été créé dans :
- `/lib/backend/schema/gifts_record.dart`
- Intégré dans `/lib/backend/backend.dart`

Les règles Firestore ont été mises à jour dans :
- `/firebase/firestore.rules`

## ⚠️ Important

- Tous les produits ont le champ `active: true`
- Les images sont des placeholders de qualité (Unsplash)
- Les prix sont réalistes basés sur les marques
- Les tags sont générés automatiquement pour un matching intelligent

## 📝 Prochaines Étapes

1. ✅ Upload des produits dans Firebase
2. ✅ Tester l'affichage dans l'app
3. ✅ Vérifier le matching des tags avec l'onboarding
4. ✅ Ajuster les prix si nécessaire
5. ✅ Remplacer les images placeholder par les vraies images des sites (si possible)
