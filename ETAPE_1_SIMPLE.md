# 🚨 ÉTAPE 1 SIMPLIFIÉE - Déployer les Règles Firestore

## 🎯 OBJECTIF
Autoriser ton app à lire/écrire les produits dans Firebase

## ⏱️ DURÉE : 3 minutes

---

## 📱 INSTRUCTIONS ÉTAPE PAR ÉTAPE

### 1. Ouvre Firebase Console
👉 Clique sur ce lien : https://console.firebase.google.com

### 2. Connecte-toi
- Utilise ton compte Google

### 3. Sélectionne ton projet
- Clique sur le projet **`doron-b3011`**
- (Tu devrais le voir dans la liste)

### 4. Va dans Firestore Database
- Dans le menu de gauche, clique sur **"Firestore Database"**
- OU clique sur **"Build"** → **"Firestore Database"**

### 5. Clique sur l'onglet "Règles" (Rules)
- En haut de la page, tu verras plusieurs onglets
- Clique sur **"Règles"** (ou **"Rules"** si en anglais)

### 6. Tu verras un éditeur de texte avec du code
- Il y a déjà du texte à l'intérieur
- **SÉLECTIONNE TOUT LE TEXTE** (Cmd+A sur Mac, Ctrl+A sur PC)

### 7. COPIE LE TEXTE CI-DESSOUS
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /Users/{document} {
      allow create: if request.auth.uid == document;
      allow read: if request.auth.uid == document;
      allow write: if request.auth.uid == document;
      allow delete: if request.auth.uid == document;
    }

    match /Favourites/{document} {
      allow create: if true;
      allow read: if true;
      allow write: if false;
      allow delete: if true;
    }

    match /QAs/{document} {
      allow create: if true;
      allow read: if true;
      allow write: if false;
      allow delete: if false;
    }

    match /GiftSuggestionChat/{document} {
      allow create: if true;
      allow read: if true;
      allow write: if false;
      allow delete: if true;
    }

    match /products/{document} {
      allow create: if true;
      allow read: if true;
      allow write: if true;
      allow delete: if true;
    }
  }
}
```

### 8. COLLE LE TEXTE dans l'éditeur
- **SUPPRIME** tout l'ancien texte
- **COLLE** le nouveau texte que tu viens de copier
- L'éditeur devrait maintenant afficher exactement le texte ci-dessus

### 9. Clique sur "Publier" (ou "Publish")
- En haut à droite de l'éditeur
- Bouton bleu qui dit **"Publier"** ou **"Publish"**

### 10. Confirme
- Une popup peut apparaître
- Clique sur **"Publier"** ou **"Publish"** pour confirmer

---

## ✅ C'EST FAIT !

Tu devrais voir un message de confirmation vert qui dit :
- "Règles publiées" ou "Rules published"

---

## 🎯 CE QUE TU VIENS DE FAIRE

Tu as autorisé Firebase à :
- ✅ **Lire** les produits (pour l'app)
- ✅ **Écrire** les produits (pour l'upload)
- ✅ **Créer** les produits (pour l'upload)
- ✅ **Supprimer** les produits (pour nettoyer les anciens)

---

## ➡️ APRÈS

Une fois que c'est fait, passe à **ÉTAPE 2** : Uploader les produits

Je vais te créer un guide simplifié pour l'ÉTAPE 2 aussi !

---

## ❓ BESOIN D'AIDE ?

**Si tu ne trouves pas ton projet** :
- Vérifie que tu es connecté avec le bon compte Google
- Le projet s'appelle exactement : `doron-b3011`

**Si tu ne vois pas "Firestore Database"** :
- Regarde dans le menu de gauche
- Ou clique sur "Build" puis "Firestore Database"

**Si le bouton "Publier" est grisé** :
- Assure-toi d'avoir bien collé le nouveau texte
- Vérifie qu'il n'y a pas d'erreur (ligne rouge dans l'éditeur)
