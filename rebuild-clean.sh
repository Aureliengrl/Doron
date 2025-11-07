#!/bin/bash

echo "🧹 Nettoyage complet du cache Flutter..."

# Nettoyer les caches
rm -rf .dart_tool
rm -rf build
rm -rf .flutter-plugins
rm -rf .flutter-plugins-dependencies

echo "✅ Cache nettoyé !"
echo ""
echo "📦 Installation des dépendances..."

# Activer web si ce n'est pas déjà fait
flutter config --enable-web > /dev/null 2>&1

# Récupérer les dépendances
flutter pub get

echo "✅ Dépendances installées !"
echo ""
echo "🚀 Lancement de l'application sur Chrome..."
echo ""

# Lancer l'application
flutter run -d chrome --web-browser-flag "--disable-web-security"
