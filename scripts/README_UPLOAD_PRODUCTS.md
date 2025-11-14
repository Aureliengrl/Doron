# 🎁 Upload des Produits vers Firebase

## Résumé

✅ **1430 produits** générés pour **143 marques** principales !

Le fichier `realistic_bestsellers_complete.json` contient tous les produits avec :
- Noms de produits réalistes
- Prix cohérents selon les marques
- URLs vers les sites des marques
- Tags, catégories et genres
- Photos (URLs générées)

## 📊 Statistiques

- **143 marques** traitées (les plus importantes)
- **1430 produits** (10 par marque)
- **Catégories** : Mode, Tech, Sport, Beauté, Maison, Luxe
- **Fichier** : `realistic_bestsellers_complete.json` (716KB)

## 🚀 Comment Uploader vers Firebase

### Option 1 : Via Script Dart (Recommandé)

Le script `upload_products_flutter.dart` est prêt à être exécuté depuis votre environnement Flutter :

```bash
# Depuis la racine du projet Doron
cd /path/to/Doron
dart run scripts/upload_products_flutter.dart
```

Le script va :
1. ✅ Supprimer tous les anciens produits
2. ✅ Uploader les 1430 nouveaux produits
3. ✅ Afficher un résumé

### Option 2 : Via Console Firebase

1. Allez sur https://console.firebase.google.com
2. Sélectionnez votre projet "doron-b3011"
3. Allez dans Firestore Database
4. Utilisez l'outil d'import/export pour importer le JSON

### Option 3 : Via Script Python (si l'environnement le permet)

```bash
cd scripts
python3 generate_realistic_bestsellers.py --upload
```

## 📝 Structure d'un Produit

```json
{
  "product_title": "Zara - Veste en laine",
  "product_price": "130.84",
  "product_original_price": "157.01",
  "product_star_rating": "4.9",
  "product_num_ratings": 1354,
  "product_url": "https://www.zara.com/fr/products/veste-en-laine",
  "product_photo": "https://images.zara.com/products/1.jpg",
  "platform": "Zara",
  "tags": ["mode", "vêtements", "style", "tendance"],
  "gender": "unisexe",
  "category": "mode"
}
```

## 🏷️ Marques Incluses (143)

### Mode (45 marques)
Zara, H&M, Mango, Sézane, Sandro, Maje, ba&sh, The Kooples, A.P.C., AMI Paris, Isabel Marant, Jacquemus, Reformation, Ganni, Totême, Anine Bing, The Frankie Shop, Acne Studios, Lemaire, Officine Générale, Maison Margiela, etc.

### Luxe (20 marques)
Louis Vuitton, Gucci, Dior, Chanel, Hermès, Prada, Miu Miu, Fendi, Celine, Balenciaga, Loewe, Valentino, Givenchy, Burberry, Alexander McQueen, Versace, Balmain, Bottega Veneta, Tom Ford, etc.

### Sport (25 marques)
Nike, Adidas, On Running, HOKA, Lululemon, Alo Yoga, Gymshark, Jordan, New Balance, Puma, Asics, Salomon, Veja, Common Projects, Converse, Vans, etc.

### Tech (15 marques)
Apple, Samsung, Dyson, Bose, Sony, JBL, Bang & Olufsen, PlayStation, Xbox, Nintendo, Logitech G, Razer, etc.

### Beauté (20 marques)
Sephora, Byredo, Diptyque, Le Labo, Maison Francis Kurkdjian, Aesop, Cire Trudon, Dior Beauty, Chanel Beauty, YSL Beauty, Lancôme, NARS, Fenty Beauty, Rituals, L'Occitane, The Body Shop, Lush, etc.

### Maison (18 marques)
IKEA, Maisons du Monde, Zara Home, H&M Home, Vitra, Hay, Le Creuset, Staub, KitchenAid, SMEG, Nespresso, etc.

## 🔄 Régénérer les Produits

Si vous voulez régénérer tous les produits :

```bash
cd scripts
python3 generate_realistic_bestsellers.py
```

## 🎯 Prochaines Étapes

1. ✅ Uploader les produits vers Firebase (via Option 1 ou 2)
2. ✅ Tester l'application pour vérifier que les cadeaux apparaissent
3. ✅ Si nécessaire, ajuster les marques ou catégories
4. ✅ Générer plus de produits pour d'autres marques si besoin

## 💡 Notes

- Les URLs de produits et images sont générées de manière cohérente
- Les prix sont réalistes selon les gammes de marques
- Les tags et catégories permettent une recherche efficace
- Le fichier JSON peut être édité manuellement si besoin

## 🐛 Dépannage

### Si l'upload échoue
- Vérifiez que Firebase est bien initialisé dans votre projet
- Vérifiez les permissions Firestore
- Essayez d'uploader en plusieurs fois (par lots de 500)

### Si les produits n'apparaissent pas dans l'app
- Vérifiez la collection 'products' dans Firestore
- Vérifiez les règles de sécurité Firestore
- Redémarrez l'application

## 📧 Support

Si vous rencontrez des problèmes, vérifiez :
1. La connexion Firebase dans l'app
2. Les règles Firestore (lecture publique)
3. La structure des documents dans Firestore

---

**Fichiers créés :**
- ✅ `realistic_bestsellers_complete.json` - 1430 produits
- ✅ `upload_products_flutter.dart` - Script d'upload
- ✅ `generate_realistic_bestsellers.py` - Générateur de produits
