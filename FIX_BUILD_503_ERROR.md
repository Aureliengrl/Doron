# 🔧 Résolution de l'erreur 503 lors du build iOS

## 📋 Problème

Le build iOS échoue avec l'erreur suivante :
```
Error installing FirebaseFirestoreAbseilBinary
curl: (56) The requested URL returned error: 503
```

### Cause du problème

Le plugin `cloud_firestore` force le téléchargement de FirebaseFirestore depuis un repository Git externe (`https://github.com/invertase/firestore-ios-sdk-frameworks.git`) au lieu d'utiliser le repository CocoaPods standard. Cela crée plusieurs problèmes :

1. **Erreurs 503** : Le repository externe peut être indisponible
2. **Conflits de versions** : FirebaseFirestore 11.13.0 vs FirebaseFirestoreAbseilBinary 11.9.0
3. **Builds instables** : Dépendance à un service externe qui peut être down

## ✅ Solutions Mises en Place

### Solution 1 : Script de pré-build pour CI/CD

Un script `pre-build-ios.sh` a été créé pour nettoyer l'environnement avant chaque build :

```bash
./pre-build-ios.sh
```

Ce script :
- Supprime le `Podfile.lock` qui peut contenir des références obsolètes
- Nettoie le dossier `Pods`
- Vide le cache CocoaPods
- Force une réinstallation propre

**Intégration dans votre CI/CD (Codemagic, etc.)** :

Ajoutez ceci dans vos scripts de build :
```yaml
scripts:
  - name: Pre-build cleanup
    script: |
      chmod +x pre-build-ios.sh
      ./pre-build-ios.sh
  - name: Build iOS
    script: |
      flutter build ios --release
```

### Solution 2 : Script de rebuild complet (développement local)

Pour nettoyer et rebuilder complètement le projet en local :

```bash
./rebuild-ios.sh
```

Ce script :
- Nettoie le cache CocoaPods global
- Supprime tous les fichiers de build iOS
- Réinstalle les dépendances Flutter
- Réinstalle les Pods avec retry automatique en cas d'erreur

### Solution 3 : Nettoyage manuel

Si les scripts ne fonctionnent pas, voici les étapes manuelles :

```bash
# 1. Nettoyer le cache CocoaPods
pod cache clean --all

# 2. Supprimer les fichiers de build iOS
cd ios
rm -rf Pods Podfile.lock .symlinks
cd ..

# 3. Nettoyer Flutter
flutter clean
flutter pub get

# 4. Réinstaller les Pods
cd ios
pod install --repo-update
cd ..

# 5. Builder
flutter build ios --release
```

## 🔍 Diagnostic

Si le problème persiste, vérifiez :

1. **Connexion réseau** : Le repository externe est-il accessible ?
   ```bash
   curl -I https://github.com/invertase/firestore-ios-sdk-frameworks/raw/11.13.0/Archives/abseil.zip
   ```

2. **Version CocoaPods** : Assurez-vous d'utiliser une version récente
   ```bash
   pod --version  # Devrait être >= 1.11.0
   ```

3. **Cache CocoaPods** : Vérifiez si le cache est corrompu
   ```bash
   pod cache list
   ```

## 🚀 Recommandations à Long Terme

Pour éviter ce problème à l'avenir :

1. **Mettre à jour cloud_firestore** : Vers une version qui n'utilise pas le repo Git externe
2. **Monitoring du build** : Surveiller les erreurs 503 et déclencher un nettoyage automatique
3. **Cache CI/CD** : Désactiver le cache CocoaPods dans votre CI/CD pour forcer des builds propres

## 📝 Changements Techniques

### Fichiers modifiés :
- `ios/Podfile` : Suppression de la ligne qui forçait le repo Git externe
- `rebuild-ios.sh` : Script de nettoyage complet avec retry
- `pre-build-ios.sh` : Script de pré-build pour CI/CD

### Configuration Podfile

Le Podfile a été nettoyé pour permettre à Flutter de gérer les dépendances Firebase normalement :

```ruby
target 'Runner' do
  use_frameworks! :linkage => :static
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  # Plus de ligne pod 'FirebaseFirestore' avec repo Git externe
end
```

---

**Date de correction** : 2025-11-20
**Branche** : claude/fix-build-loading-01Fu2qTJ3G1YhKSDySZmZ67M
