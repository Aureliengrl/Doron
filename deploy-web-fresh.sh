#!/bin/bash

echo "🧹 Nettoyage complet..."
flutter clean

echo ""
echo "📦 Récupération des dépendances..."
flutter pub get

echo ""
echo "🔨 Build de la version web en production..."
flutter build web --release

echo ""
echo "✅ Build terminé !"
echo ""
echo "🌐 Lancement du serveur web sur http://localhost:8080"
echo ""
echo "⚠️  IMPORTANT: Pour voir la NOUVELLE version :"
echo "   1. Ouvre http://localhost:8080 dans Chrome"
echo "   2. Appuie sur Ctrl+Shift+R (ou Cmd+Shift+R sur Mac)"
echo "   3. Ou ouvre en navigation privée (Ctrl+Shift+N)"
echo ""
echo "🛑 Pour arrêter le serveur : Ctrl+C"
echo ""

cd build/web
python3 -m http.server 8080
