#!/usr/bin/env python3
"""
Script de nettoyage Firebase : Supprime les produits incomplets
Garde uniquement les produits avec TOUTES les infos nécessaires
"""

import json
import firebase_admin
from firebase_admin import credentials, firestore
from pathlib import Path

# Configuration
SERVICE_ACCOUNT = Path(__file__).parent.parent / "serviceAccountKey.json"

# Champs REQUIS pour qu'un produit soit considéré comme valide
REQUIRED_FIELDS = [
    'product_title',
    'product_price',
    'product_url',
    'product_photo',
    'platform'
]

def is_product_valid(product_data: dict) -> tuple[bool, list]:
    """
    Vérifie si un produit a toutes les infos nécessaires
    Retourne (is_valid, missing_fields)
    """
    missing_fields = []

    for field in REQUIRED_FIELDS:
        value = product_data.get(field)

        # Vérifier que le champ existe ET n'est pas vide
        if not value or (isinstance(value, str) and value.strip() == ''):
            missing_fields.append(field)

    # Vérifications supplémentaires
    # Le prix doit être un nombre positif
    if 'product_price' in product_data:
        try:
            price = float(product_data['product_price'])
            if price <= 0:
                missing_fields.append('product_price (invalid: <= 0)')
        except (ValueError, TypeError):
            missing_fields.append('product_price (invalid format)')

    # L'URL doit commencer par http:// ou https://
    if 'product_url' in product_data:
        url = str(product_data.get('product_url', ''))
        if not url.startswith('http://') and not url.startswith('https://'):
            missing_fields.append('product_url (invalid URL)')

    # L'image doit être une URL
    if 'product_photo' in product_data:
        photo = str(product_data.get('product_photo', ''))
        if not photo.startswith('http://') and not photo.startswith('https://'):
            missing_fields.append('product_photo (invalid URL)')

    is_valid = len(missing_fields) == 0
    return is_valid, missing_fields


def clean_firebase_products():
    print("=" * 80)
    print("🧹 NETTOYAGE DES PRODUITS FIREBASE")
    print("=" * 80)

    # Initialiser Firebase
    print("\n🔧 Connexion à Firebase...")
    try:
        cred = credentials.Certificate(str(SERVICE_ACCOUNT))
        firebase_admin.initialize_app(cred)
        print("   ✅ Connecté à Firebase\n")
    except Exception as e:
        print(f"   ❌ Erreur: {e}\n")
        return

    db = firestore.client()
    products_ref = db.collection('products')

    # Lire TOUS les produits
    print("📖 Lecture de tous les produits...")
    all_products = []

    try:
        docs = products_ref.stream()
        for doc in docs:
            all_products.append({
                'id': doc.id,
                'data': doc.to_dict()
            })

        print(f"   ✅ {len(all_products)} produits trouvés\n")
    except Exception as e:
        print(f"   ❌ Erreur lors de la lecture: {e}\n")
        return

    if len(all_products) == 0:
        print("⚠️  Aucun produit dans Firebase. Rien à nettoyer.")
        return

    # Analyser les produits
    print("🔍 Analyse des produits...")
    print("=" * 80)

    valid_products = []
    invalid_products = []

    for product in all_products:
        is_valid, missing_fields = is_product_valid(product['data'])

        if is_valid:
            valid_products.append(product)
        else:
            invalid_products.append({
                'id': product['id'],
                'data': product['data'],
                'missing_fields': missing_fields
            })

    print(f"\n✅ Produits VALIDES: {len(valid_products)}")
    print(f"❌ Produits INVALIDES: {len(invalid_products)}\n")

    if len(invalid_products) == 0:
        print("🎉 Tous les produits sont valides ! Aucun nettoyage nécessaire.")
        return

    # Afficher des exemples de produits invalides
    print("📋 Exemples de produits invalides (max 10):")
    print("-" * 80)

    for i, product in enumerate(invalid_products[:10]):
        title = product['data'].get('product_title', 'Sans titre')
        platform = product['data'].get('platform', 'Sans marque')
        print(f"\n{i+1}. {platform} - {title}")
        print(f"   Champs manquants: {', '.join(product['missing_fields'])}")

    if len(invalid_products) > 10:
        print(f"\n... et {len(invalid_products) - 10} autres produits invalides")

    print("\n" + "=" * 80)

    # Demander confirmation
    print(f"\n⚠️  ATTENTION: Vous allez supprimer {len(invalid_products)} produits invalides")
    print("   Les produits valides seront conservés.")

    # Mode automatique pour le script
    confirmation = input("\nContinuer? (oui/non): ").lower().strip()

    if confirmation not in ['oui', 'yes', 'y', 'o']:
        print("\n❌ Annulé par l'utilisateur")
        return

    # Supprimer les produits invalides
    print(f"\n🗑️  Suppression de {len(invalid_products)} produits invalides...")

    deleted_count = 0
    batch_size = 500

    for i in range(0, len(invalid_products), batch_size):
        batch_products = invalid_products[i:i + batch_size]
        batch = db.batch()

        for product in batch_products:
            doc_ref = products_ref.document(product['id'])
            batch.delete(doc_ref)

        batch.commit()
        deleted_count += len(batch_products)
        print(f"   {deleted_count}/{len(invalid_products)} supprimés...")

    print(f"   ✅ {deleted_count} produits supprimés\n")

    # Résumé final
    print("=" * 80)
    print("✅ NETTOYAGE TERMINÉ!")
    print(f"   Produits GARDÉS: {len(valid_products)}")
    print(f"   Produits SUPPRIMÉS: {deleted_count}")
    print("=" * 80)

    print("\n💡 Prochaines étapes:")
    print("   1. Ouvrez Firebase Console")
    print("   2. Vérifiez la collection 'products'")
    print("   3. Testez votre app!")


if __name__ == "__main__":
    try:
        clean_firebase_products()
    except KeyboardInterrupt:
        print("\n\n⚠️  Annulé par l'utilisateur")
    except Exception as e:
        print(f"\n❌ ERREUR: {e}")
        import traceback
        traceback.print_exc()
