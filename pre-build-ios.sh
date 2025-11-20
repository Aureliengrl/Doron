#!/bin/bash

# Script de pré-build pour CI/CD (Codemagic, etc.)
# À exécuter avant flutter build ios

set -e

echo "🔧 Pré-build iOS : Nettoyage des fichiers de cache CocoaPods..."

# Aller dans le dossier iOS
cd ios

# Supprimer le Podfile.lock qui peut contenir des références obsolètes
if [ -f "Podfile.lock" ]; then
    echo "🗑️  Suppression de Podfile.lock..."
    rm -f Podfile.lock
fi

# Supprimer le dossier Pods s'il existe
if [ -d "Pods" ]; then
    echo "🗑️  Suppression du dossier Pods..."
    rm -rf Pods
fi

# Supprimer .symlinks
if [ -d ".symlinks" ]; then
    echo "🗑️  Suppression de .symlinks..."
    rm -rf .symlinks
fi

# Nettoyer le cache CocoaPods pour éviter les conflits de version
echo "🗑️  Nettoyage du cache CocoaPods..."
pod cache clean --all 2>/dev/null || true

# Retour au répertoire racine
cd ..

echo "✅ Pré-build terminé! Le build peut maintenant continuer normalement."
