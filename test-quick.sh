#!/bin/bash

# Script de test rapide - Lance l'application en mode dev avec hot reload

echo "🎁 DORÕN - Test Rapide (Mode Dev)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Vérifier que Flutter est installé
if ! command -v flutter &> /dev/null; then
    echo "❌ Erreur: Flutter n'est pas installé"
    echo "📥 Installez Flutter depuis: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Activer le web
echo "🌐 Configuration du support web..."
flutter config --enable-web

# Installer les dépendances si nécessaire
if [ ! -d ".dart_tool" ]; then
    echo "📦 Installation des dépendances..."
    flutter pub get
fi

echo ""
echo "🚀 Lancement de l'application en mode développement..."
echo ""
echo "💡 Fonctionnalités du mode dev :"
echo "   - Hot reload (r pour recharger)"
echo "   - Hot restart (R pour redémarrer)"
echo "   - Quit (q pour quitter)"
echo ""
echo "🌐 L'application va s'ouvrir dans Chrome..."
echo ""

# Lancer l'app en mode dev
flutter run -d chrome

echo ""
echo "✨ Session terminée !"
