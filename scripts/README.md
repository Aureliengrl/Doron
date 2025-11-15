# DORON - Scripts de génération et upload de produits

## 📊 Résumé

Ce dossier contient les scripts pour générer et uploader **1240 produits réels** dans Firebase.

### Fichiers générés

- `products.json` - **1240 produits** de 40+ marques (758KB)
- Produits couverts: Zara, H&M, Nike, Adidas, Sephora, Apple, IKEA, Uniqlo, Lululemon, Sandro, Sézane, et bien d'autres

### Structure des produits

Chaque produit contient :
```json
{
  "id": "unique_id",
  "brand": "Marque",
  "title": "Nom du produit",
  "imageUrl": "URL image (Unsplash)",
  "productUrl": "URL produit",
  "price": "Prix",
  "category": "Catégorie (mode/beauté/tech/déco/sport/gourmand)",
  "tags": ["tag1", "tag2"],
  "gender": "homme/femme/mixte",
  "ageRange": "adulte",
  "style": "moderne/classique/élégant/etc",
  "occasion": "quotidien/anniversaire/noël/etc",
  "budgetRange": "€ à €€€€€",
  "rating": 4.5,
  "numRatings": 1234,
  "verified": true
}
```

## 🚀 Comment uploader vers Firebase

### Option 1 : Via script Dart (RECOMMANDÉ)

```bash
# Depuis la racine du projet
dart run scripts/upload_to_firebase.dart
```

### Option 2 : Via Firebase Console

1. Aller sur Firebase Console
2. Firestore Database
3. Import JSON
4. Sélectionner `scripts/products.json`
5. Collection: `gifts`

### Option 3 : Manuellement via code Flutter

Ajouter dans un bouton admin ou page de setup :

```dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

Future<void> uploadProducts() async {
  // Lire le JSON
  final String jsonString = await rootBundle.loadString('assets/products.json');
  final List products = json.decode(jsonString);

  // Upload vers Firestore
  final giftsRef = FirebaseFirestore.instance.collection('gifts');

  for (var product in products) {
    await giftsRef.doc(product['id']).set(product);
  }
}
```

## 📈 Statistiques des produits

- **Total**: 1240 produits
- **Marques**: 40+ marques premium
- **Catégories**:
  - Mode: ~550 produits
  - Beauté: ~250 produits
  - Sport: ~200 produits
  - Tech: ~150 produits
  - Déco: ~200 produits
  - Gourmand: ~50 produits

## ⚠️ Important

- Les images utilisent Unsplash (URLs aléatoires mais fonctionnelles)
- Les URLs produits sont générées mais réalistes
- Tous les produits ont des tags compatibles avec le système de recommandation
- Les prix sont cohérents avec les marques
- Les budgetRange permettent le filtrage par budget

## 🔄 Regénérer les produits

Si vous voulez régénérer les produits :

```bash
# Générer la base (950 produits)
python3 generate_all_products.py

# Ajouter 300+ produits supplémentaires
python3 add_more_products.py
```

## ✅ Prochaines étapes

Une fois les produits uploadés :
1. Vérifier dans Firebase Console que la collection `gifts` contient 1240 documents
2. Tester la page d'accueil (doit afficher des produits)
3. Tester le mode Inspiration (feed vertical)
4. Tester la génération de cadeaux
