#!/bin/bash

# Script de rebuild iOS propre pour Doron
# Ce script nettoie et reconstruit complètement le projet iOS

echo "🧹 Nettoyage de l'environnement iOS..."

# Nettoyer les Pods
cd ios
rm -rf Pods
rm -rf Podfile.lock
rm -rf .symlinks
rm -rf ~/Library/Developer/Xcode/DerivedData/*
cd ..

# Nettoyer Flutter
echo "🧹 Nettoyage de Flutter..."
flutter clean

# Récupérer les dépendances Flutter
echo "📦 Installation des dépendances Flutter..."
flutter pub get

# Installer les Pods avec mise à jour du repo
echo "📦 Installation des CocoaPods..."
cd ios
pod install --repo-update

# Retour au répertoire racine
cd ..

echo "✅ Nettoyage et réinstallation terminés!"
echo ""
echo "🚀 Vous pouvez maintenant builder avec:"
echo "   flutter build ios --debug"
echo "   ou"
echo "   flutter build ios --release"
