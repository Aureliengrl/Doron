# 🚀 UPLOAD RAPIDE - 3 commandes

## Sur ton ordinateur:

```bash
# 1. Clone le repo et va sur la bonne branche
git clone https://github.com/Aureliengrl/Doron.git
cd Doron
git checkout claude/firebase-upload-complete-011CV4gq7P36zPna18n37Wtj

# 2. Télécharge ta clé Firebase depuis:
#    https://console.firebase.google.com
#    Projet Doron → Settings → Service Accounts → Generate New Private Key
#    Sauvegarde le fichier comme: firebase-service-account.json

# 3. Lance l'upload!
npm install
node upload_to_firebase_local.js
```

**C'est tout!** Les 2500 produits seront uploadés en 5-10 minutes! 🎉

---

## Contenu du repo:

✅ `products_all_brands.json` - 2500 produits de 208 marques premium
✅ `upload_to_firebase_local.js` - Script d'upload qui marche localement
✅ Toutes les marques: Gucci, Dior, Nike, Sephora, IKEA, Zara, etc.

---

## Besoin d'aide?

Le script affichera:
```
📦 Loading products from JSON...
✅ Loaded 2500 products
🚀 Starting upload to Firebase Firestore...
✅ Uploaded 500/2500 products (20%)
✅ Uploaded 1000/2500 products (40%)
...
🎉 Successfully uploaded 2500 products to Firebase!
```
