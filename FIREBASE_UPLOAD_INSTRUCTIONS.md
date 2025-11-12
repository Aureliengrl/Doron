# 🎁 Instructions pour uploader 2500 produits vers Firebase

## ✅ Ce qui est prêt
- ✅ **2500 produits** générés de **208 marques** (Zara, Gucci, Nike, IKEA, Sephora, etc.)
- ✅ Script d'upload Firebase automatique
- ✅ GitHub Actions workflow configuré

## 📱 ÉTAPES DEPUIS TON iPad

### Étape 1: Obtenir ta clé Firebase Service Account

1. Va sur **Firebase Console**: https://console.firebase.google.com
2. Sélectionne ton projet **Doron**
3. Clique sur l'icône ⚙️ (Settings) → **Project Settings**
4. Va dans l'onglet **Service Accounts**
5. Clique sur **Generate New Private Key**
6. Télécharge le fichier JSON (ex: `doron-firebase-adminsdk-xxxxx.json`)
7. **IMPORTANT**: Ouvre ce fichier avec l'app **Fichiers** (Files) sur ton iPad
8. Copie **TOUT le contenu du fichier** (c'est du JSON)

### Étape 2: Ajouter le secret dans GitHub

1. Va sur GitHub (Safari sur iPad): https://github.com/Aureliengrl/Doron
2. Clique sur **Settings** (en haut à droite du repo)
3. Dans le menu de gauche, clique sur **Secrets and variables** → **Actions**
4. Clique sur **New repository secret**
5. **Name**: `FIREBASE_SERVICE_ACCOUNT`
6. **Value**: Colle **TOUT le contenu JSON** que tu as copié à l'étape 1
7. Clique sur **Add secret**

### Étape 3: Lancer l'upload automatique ⚡

1. Va sur: https://github.com/Aureliengrl/Doron/actions
2. Dans la liste de gauche, clique sur **"Upload Products to Firebase"**
3. Clique sur le bouton **"Run workflow"** (à droite)
4. Sélectionne la branch: `claude/firebase-products-population-011CV4gq7P36zPna18n37Wtj`
5. Clique sur **"Run workflow"** (bouton vert)

### Étape 4: Attendre l'upload 🚀

- Le workflow va prendre **5-10 minutes** pour uploader les 2500 produits
- Tu peux suivre la progression en temps réel sur la page GitHub Actions
- Quand tu vois ✅ en vert, c'est terminé!

## 📊 Résultat

Après l'upload, tu auras dans Firebase:
- **2500 produits** dans la collection `products`
- Répartis sur **208 marques** premium
- Toutes les marques de ta liste (Gucci, Dior, Nike, Sephora, IKEA, etc.)
- Produits variés: mode, tech, maison, beauté, sport, luxe, etc.

## ❓ Problèmes ?

Si le workflow échoue:
1. Vérifie que le secret `FIREBASE_SERVICE_ACCOUNT` est bien configuré
2. Vérifie que le JSON est complet (doit commencer par `{` et finir par `}`)
3. Vérifie que Firebase Firestore est activé dans ton projet

## 🔄 Relancer l'upload

Tu peux relancer le workflow autant de fois que nécessaire depuis GitHub Actions!
