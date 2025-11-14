# 🎁 Upload 2500 produits vers Firebase - MÉTHODE SIMPLE

## ✅ TU AS DÉJÀ TOUT!
- ✅ 2500 produits de 208 marques dans `products_all_brands.json`
- ✅ Script d'upload `upload_to_firebase.js`

## 🚀 MÉTHODE RAPIDE (depuis un ordinateur)

### Étape 1: Obtenir ta clé Firebase

1. Va sur: https://console.firebase.google.com
2. Sélectionne projet **Doron**
3. Clique ⚙️ → **Project Settings** → **Service Accounts**
4. Clique **Generate New Private Key**
5. Télécharge le fichier JSON (ex: `doron-firebase-xxxxx.json`)
6. **Renomme-le** en `firebase-service-account.json`
7. **Place-le dans ce dossier** (à côté de `upload_to_firebase.js`)

### Étape 2: Modifier le script

Ouvre `upload_to_firebase.js` et change la ligne 4:

**AVANT:**
```javascript
const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
```

**APRÈS:**
```javascript
const serviceAccount = require('./firebase-service-account.json');
```

### Étape 3: Installer et lancer!

```bash
# Installe les dépendances
npm install

# Lance l'upload!
node upload_to_firebase.js
```

**Durée:** 5-10 minutes pour uploader les 2500 produits ⚡

---

## 📱 ALTERNATIVE iPad (via GitHub Web)

Si tu ne peux vraiment utiliser qu'un iPad:

1. **Crée une Pull Request** sur GitHub:
   - Va sur: https://github.com/Aureliengrl/Doron/compare
   - From: `claude/firebase-products-population-011CV4gq7P36zPna18n37Wtj`
   - To: `main` (ou ta branche par défaut)
   - Clique "Create Pull Request" puis "Merge"

2. **Ensuite** tu pourras voir le workflow dans Actions et le lancer!

---

## ⚠️ IMPORTANT

**N'oublie pas** d'ajouter `firebase-service-account.json` dans `.gitignore` pour ne pas pusher ta clé privée!

```bash
echo "firebase-service-account.json" >> .gitignore
```
