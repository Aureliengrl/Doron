# 🎁 DORÕN - Guide de Déploiement Web

Ce guide vous explique comment compiler et tester l'application DORÕN sur le web.

---

## 📋 Prérequis

Avant de commencer, assurez-vous d'avoir installé :

1. **Flutter SDK** (version 3.0+)
   - 📥 Télécharger : https://flutter.dev/docs/get-started/install
   - ✅ Vérifier l'installation : `flutter doctor`

2. **Chrome** (pour tester l'application web)
   - Flutter web fonctionne mieux avec Chrome

---

## 🚀 Méthode 1 : Script automatique (RECOMMANDÉ)

C'est la méthode la plus simple !

### Étape 1 : Rendre le script exécutable
```bash
chmod +x deploy-web.sh
```

### Étape 2 : Lancer le script
```bash
./deploy-web.sh
```

Le script va :
1. ✅ Vérifier que Flutter est installé
2. 🧹 Nettoyer les builds précédents
3. 📦 Installer les dépendances
4. 🔨 Compiler l'application pour le web
5. 🌐 Lancer un serveur web local (optionnel)

### Étape 3 : Tester l'application
- Ouvrez votre navigateur à l'adresse : **http://localhost:8000**
- L'application DORÕN devrait s'afficher ! 🎉

---

## 🛠️ Méthode 2 : Manuelle

Si vous préférez tout faire manuellement :

### 1. Nettoyer le projet
```bash
flutter clean
```

### 2. Installer les dépendances
```bash
flutter pub get
```

### 3. Compiler pour le web
```bash
flutter build web --release
```

⏳ **Note** : Cela peut prendre 3-5 minutes la première fois.

### 4. Tester localement

**Option A : Avec Python 3**
```bash
cd build/web
python3 -m http.server 8000
```
Puis ouvrez : http://localhost:8000

**Option B : Avec Python 2**
```bash
cd build/web
python -m SimpleHTTPServer 8000
```
Puis ouvrez : http://localhost:8000

**Option C : Avec Node.js (si installé)**
```bash
npx serve build/web
```

**Option D : Directement dans le navigateur**
```bash
open build/web/index.html
# ou
google-chrome build/web/index.html
```

---

## 🔧 Mode Développement (avec hot reload)

Si vous voulez développer et voir les changements en temps réel :

```bash
flutter run -d chrome
```

Ou pour sélectionner Chrome manuellement :
```bash
flutter run
# Puis choisir "Chrome" dans la liste des devices
```

---

## 📱 Tester sur différents navigateurs

### Chrome (recommandé)
```bash
flutter run -d chrome
```

### Edge
```bash
flutter run -d edge
```

### Firefox ou Safari
Ouvrez manuellement `build/web/index.html` dans le navigateur

---

## 🐛 Résolution des problèmes

### Erreur : "Flutter not found"
**Solution** : Installez Flutter depuis https://flutter.dev/docs/get-started/install

### Erreur : "Chrome device not found"
**Solution** :
```bash
flutter config --enable-web
flutter devices
```

### Erreur : "Missing dependencies"
**Solution** :
```bash
flutter pub get
flutter clean
flutter build web --release
```

### L'application ne charge pas
**Solution** : Vérifiez la console du navigateur (F12) pour voir les erreurs

### Erreur : "API key not found"
**Solution** : Vérifiez que le fichier `.env` ou `environment_values/` contient bien votre clé API OpenAI

---

## 📦 Déploiement en production

Une fois que tout fonctionne localement, vous pouvez déployer sur :

### Option 1 : Firebase Hosting (gratuit)
```bash
# Installer Firebase CLI
npm install -g firebase-tools

# Se connecter
firebase login

# Initialiser Firebase
firebase init hosting

# Déployer
firebase deploy
```

### Option 2 : Netlify (gratuit)
1. Créez un compte sur https://netlify.com
2. Glissez-déposez le dossier `build/web/`
3. Votre app est en ligne ! 🎉

### Option 3 : Vercel (gratuit)
```bash
npm install -g vercel
vercel build/web
```

### Option 4 : GitHub Pages (gratuit)
1. Copiez le contenu de `build/web/` dans une branche `gh-pages`
2. Activez GitHub Pages dans les paramètres du repo

---

## 📊 Structure des fichiers générés

Après le build, vous aurez :

```
build/web/
├── index.html          # Point d'entrée
├── main.dart.js       # Code compilé
├── flutter.js         # Flutter engine
├── assets/            # Images, fonts, etc.
└── canvaskit/         # Rendu graphique
```

---

## 💡 Astuces

1. **Build plus rapide en développement** :
   ```bash
   flutter build web --profile
   ```

2. **Build avec source maps (pour debug)** :
   ```bash
   flutter build web --source-maps
   ```

3. **Vérifier la taille du build** :
   ```bash
   du -sh build/web/
   ```

4. **Tester sur mobile** :
   - Lancez le serveur local
   - Trouvez votre IP : `ifconfig` ou `ipconfig`
   - Ouvrez `http://[votre-ip]:8000` sur votre mobile

---

## 🎯 Checklist avant de tester

- [ ] Flutter est installé (`flutter --version`)
- [ ] Les dépendances sont installées (`flutter pub get`)
- [ ] L'application compile sans erreur (`flutter build web`)
- [ ] Un serveur web est lancé (ou fichier ouvert directement)
- [ ] Chrome/navigateur moderne est ouvert
- [ ] La clé API OpenAI est configurée (pour les suggestions IA)

---

## 🆘 Besoin d'aide ?

- 📚 Documentation Flutter Web : https://flutter.dev/web
- 💬 Discord Flutter : https://discord.gg/flutter
- 🐛 Issues GitHub : https://github.com/Aureliengrl/Doron/issues

---

**Bon test ! 🚀**

Si tout fonctionne, vous devriez voir l'onboarding de DORÕN avec toutes les nouvelles fonctionnalités !
