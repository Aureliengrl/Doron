# 🎯 Comment tester l'application DORÕN ?

Guide ultra-simple pour voir l'application en action ! 🚀

---

## 🏃 Méthode Ultra-Rapide (2 commandes)

Si Flutter est déjà installé sur ton Mac :

```bash
# 1. Va dans le dossier du projet
cd ~/Doron

# 2. Lance le script de test rapide
./test-quick.sh
```

✨ **C'est tout !** L'application va s'ouvrir dans Chrome avec le hot reload activé.

---

## 📦 Méthode Complete (pour déploiement)

Si tu veux compiler l'application en version production :

```bash
# 1. Va dans le dossier du projet
cd ~/Doron

# 2. Lance le script de déploiement
./deploy-web.sh
```

Le script va :
1. Compiler l'application (5 minutes environ)
2. Te demander si tu veux lancer un serveur local
3. Ouvrir l'app sur http://localhost:8000

---

## ❓ Flutter n'est pas installé ?

### Sur Mac :

**Étape 1 : Télécharger Flutter**
```bash
cd ~
git clone https://github.com/flutter/flutter.git -b stable
```

**Étape 2 : Ajouter Flutter au PATH**
```bash
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.zshrc
source ~/.zshrc
```

**Étape 3 : Vérifier l'installation**
```bash
flutter doctor
```

**Étape 4 : Accepter les licences**
```bash
flutter doctor --android-licenses
```

**Étape 5 : Activer le web**
```bash
flutter config --enable-web
```

---

## 🎨 Les 2 modes de test

### Mode 1 : Développement (avec hot reload)
```bash
./test-quick.sh
```
**Avantages :**
- ✅ Lance rapidement (30 secondes)
- ✅ Hot reload : modifie le code et voit les changements instantanément
- ✅ Parfait pour développer

**Commandes utiles pendant l'exécution :**
- `r` → Recharger l'app (hot reload)
- `R` → Redémarrer l'app complètement
- `q` → Quitter

### Mode 2 : Production (build optimisé)
```bash
./deploy-web.sh
```
**Avantages :**
- ✅ Version optimisée et rapide
- ✅ Prête pour le déploiement
- ✅ Fichiers dans `build/web/`

---

## 🧪 Que tester dans l'application ?

Une fois l'app lancée, teste ces fonctionnalités :

### 1. Onboarding (première visite)
- [ ] Les animations fonctionnent
- [ ] Les questions s'affichent correctement
- [ ] Le bouton "Continuer" fonctionne
- [ ] La barre de progression avance

### 2. Authentification
- [ ] Création de compte (email/password)
- [ ] Connexion avec Google
- [ ] Connexion avec Apple
- [ ] Bouton "Continuer sans connexion"

### 3. Liste de cadeaux personnalisés (NOUVEAU ✨)
- [ ] Affichage de 30 cadeaux après connexion
- [ ] Les images des produits chargent
- [ ] Les prix s'affichent
- [ ] Clic sur un produit → ouvre le site de la marque
- [ ] Bouton "Refaire" → génère de nouveaux cadeaux
- [ ] Bouton "Enregistrer" → redirige vers la page Recherche

### 4. Page d'accueil
- [ ] DORÕN est centré dans le header avec l'icône ✨
- [ ] Message de bienvenue sur 2 lignes
- [ ] Boutons de catégories (Pour toi, Tendance, Tech...) plus petits
- [ ] Tire vers le bas → recharge les produits (pull-to-refresh)
- [ ] Minimum 30 produits affichés
- [ ] Clic sur un produit → ouvre le détail
- [ ] Clic sur "Voir sur [Marque]" → ouvre le site

### 5. Navigation
- [ ] Barre de navigation en bas fonctionne
- [ ] Accueil → affiche les produits
- [ ] Favoris → affiche les favoris
- [ ] Recherche → affiche la page recherche
- [ ] Profil → affiche le profil

---

## 🐛 Problèmes courants

### "Command not found: flutter"
**Solution :** Flutter n'est pas installé. Suis les étapes d'installation ci-dessus.

### "Chrome device not found"
**Solution :**
```bash
flutter config --enable-web
flutter devices
```

### L'app ne charge pas
**Solution :** Ouvre la console du navigateur (F12) pour voir les erreurs.

### Erreur avec OpenAI
**Solution :** Vérifie que ta clé API est bien configurée dans le fichier `.env` ou `environment_values/`

---

## 🎯 Checklist avant de commencer

- [ ] J'ai un Mac avec macOS récent
- [ ] J'ai installé Flutter (ou je suis prêt à le faire)
- [ ] Chrome est installé
- [ ] J'ai un terminal ouvert
- [ ] Je suis dans le dossier `~/Doron`

---

## 🚀 Commandes Récap'

```bash
# Test rapide (mode dev)
./test-quick.sh

# Build production
./deploy-web.sh

# Vérifier Flutter
flutter doctor

# Activer le web
flutter config --enable-web

# Voir les devices disponibles
flutter devices
```

---

## 📞 Besoin d'aide ?

Si ça ne fonctionne pas :

1. **Vérifie Flutter** : `flutter doctor`
2. **Nettoie le projet** : `flutter clean && flutter pub get`
3. **Réessaye** : `./test-quick.sh`

---

**C'est parti ! 🎁**

Lance `./test-quick.sh` et tu verras l'application DORÕN avec toutes les nouvelles fonctionnalités ! 🎉
