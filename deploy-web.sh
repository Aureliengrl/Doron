#!/bin/bash

# Script de déploiement Web pour l'application DORÕN
# Ce script compile l'application Flutter pour le web et la lance dans le navigateur

set -e

echo "🎁 DORÕN - Déploiement Web"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Vérifier que Flutter est installé
if ! command -v flutter &> /dev/null; then
    echo "❌ Erreur: Flutter n'est pas installé"
    echo "📥 Installez Flutter depuis: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter détecté: $(flutter --version | head -1)"
echo ""

# Nettoyer les builds précédents
echo "🧹 Nettoyage des builds précédents..."
rm -rf build/web
flutter clean

# Récupérer les dépendances
echo ""
echo "📦 Installation des dépendances..."
flutter pub get

# Build pour le web
echo ""
echo "🔨 Compilation de l'application pour le web..."
echo "⏳ Cela peut prendre quelques minutes..."
flutter build web --release

# Vérifier que le build a réussi
if [ ! -d "build/web" ]; then
    echo "❌ Erreur: Le build a échoué"
    exit 1
fi

echo ""
echo "✅ Build réussi !"
echo ""

# Demander si l'utilisateur veut lancer un serveur local
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌐 Serveur Web Local"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Voulez-vous lancer un serveur web local pour tester ? (o/n)"
read -r response

if [[ "$response" =~ ^([oO][uU][iI]|[oO])$ ]]; then
    echo ""
    echo "🚀 Démarrage du serveur web local..."
    echo ""

    # Vérifier si Python est installé (pour serveur simple)
    if command -v python3 &> /dev/null; then
        echo "📍 URL: http://localhost:8000"
        echo ""
        echo "💡 Appuyez sur Ctrl+C pour arrêter le serveur"
        echo ""
        cd build/web
        python3 -m http.server 8000
    elif command -v python &> /dev/null; then
        echo "📍 URL: http://localhost:8000"
        echo ""
        echo "💡 Appuyez sur Ctrl+C pour arrêter le serveur"
        echo ""
        cd build/web
        python -m SimpleHTTPServer 8000
    else
        echo "⚠️  Python n'est pas installé"
        echo "📂 Les fichiers sont disponibles dans: build/web/"
        echo "💡 Ouvrez manuellement le fichier build/web/index.html dans votre navigateur"
    fi
else
    echo ""
    echo "✅ Build terminé !"
    echo ""
    echo "📂 Les fichiers sont disponibles dans: build/web/"
    echo ""
    echo "🌐 Pour tester l'application :"
    echo "   1. Ouvrez build/web/index.html dans votre navigateur"
    echo "   2. Ou lancez un serveur web dans le dossier build/web/"
    echo ""
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ Déploiement terminé !"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
