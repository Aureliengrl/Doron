#!/bin/bash

# Script de rebuild iOS propre pour Doron
# Ce script nettoie et reconstruit complètement le projet iOS

set -e  # Exit on error

echo "🧹 Nettoyage complet de l'environnement iOS..."

# Nettoyer le cache CocoaPods global
echo "🗑️  Nettoyage du cache CocoaPods..."
pod cache clean --all 2>/dev/null || true

# Nettoyer les Pods
cd ios
rm -rf Pods
rm -rf Podfile.lock
rm -rf .symlinks
rm -rf ~/Library/Developer/Xcode/DerivedData/* 2>/dev/null || true

# Deintegrate CocoaPods si installé
pod deintegrate 2>/dev/null || true

cd ..

# Nettoyer Flutter
echo "🧹 Nettoyage de Flutter..."
flutter clean

# Récupérer les dépendances Flutter
echo "📦 Installation des dépendances Flutter..."
flutter pub get

# Installer les Pods avec mise à jour du repo
echo "📦 Installation des CocoaPods (cela peut prendre quelques minutes)..."
cd ios

# Mettre à jour les repos CocoaPods
pod repo update

# Installer les pods avec retry en cas d'erreur réseau
MAX_RETRIES=3
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    echo "Tentative d'installation des pods ($((RETRY_COUNT + 1))/$MAX_RETRIES)..."

    if pod install --repo-update; then
        echo "✅ Pods installés avec succès!"
        break
    else
        RETRY_COUNT=$((RETRY_COUNT + 1))
        if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
            echo "⚠️  Erreur d'installation, nouvelle tentative dans 5 secondes..."
            sleep 5
        else
            echo "❌ Échec de l'installation après $MAX_RETRIES tentatives"
            exit 1
        fi
    fi
done

# Retour au répertoire racine
cd ..

echo ""
echo "✅ Nettoyage et réinstallation terminés!"
echo ""
echo "🚀 Vous pouvez maintenant builder avec:"
echo "   flutter build ios --debug"
echo "   ou"
echo "   flutter build ios --release"
