#!/usr/bin/env python3
"""
Upload direct vers Firebase Firestore
Utilise les credentials du projet
"""

import json
import firebase_admin
from firebase_admin import credentials, firestore
from pathlib import Path

# Configuration
SERVICE_ACCOUNT = Path(__file__).parent.parent / "serviceAccountKey.json"
PRODUCTS_FILE = Path(__file__).parent / "smart_real_products.json"

def upload_to_firebase():
    print("=" * 80)
    print("🔥 UPLOAD VERS FIREBASE FIRESTORE")
    print("=" * 80)

    # Charger les produits
    print("\n📁 Chargement des produits...")
    with open(PRODUCTS_FILE, 'r', encoding='utf-8') as f:
        data = json.load(f)

    products = data['products']
    print(f"   ✅ {len(products)} produits chargés\n")

    # Initialiser Firebase
    print("🔧 Initialisation de Firebase...")
    try:
        cred = credentials.Certificate(str(SERVICE_ACCOUNT))
        firebase_admin.initialize_app(cred)
        print("   ✅ Firebase initialisé\n")
    except Exception as e:
        print(f"   ❌ Erreur: {e}\n")
        return

    db = firestore.client()

    # Supprimer les anciens produits
    print("🗑️  Suppression des anciens produits...")
    products_ref = db.collection('products')

    deleted = 0
    batch_size = 500

    while True:
        docs = products_ref.limit(batch_size).stream()
        batch = db.batch()
        count = 0

        for doc in docs:
            batch.delete(doc.reference)
            count += 1
            deleted += 1

        if count > 0:
            batch.commit()
            print(f"   {deleted} produits supprimés...")

        if count < batch_size:
            break

    print(f"   ✅ Tous les anciens produits supprimés\n")

    # Uploader les nouveaux produits
    print(f"📤 Upload de {len(products)} nouveaux produits...")

    uploaded = 0
    batch = db.batch()
    batch_count = 0

    for idx, product in enumerate(products):
        doc_ref = products_ref.document()

        # Nettoyer les données
        clean_product = {}
        for key, value in product.items():
            if value is not None and value != '':
                clean_product[key] = value

        # Convertir les prix en nombres si possible
        if 'product_price' in clean_product:
            try:
                clean_product['product_price'] = float(clean_product['product_price'])
            except:
                pass

        if 'product_original_price' in clean_product:
            try:
                clean_product['product_original_price'] = float(clean_product['product_original_price'])
            except:
                del clean_product['product_original_price']

        if 'product_star_rating' in clean_product:
            try:
                clean_product['product_star_rating'] = float(clean_product['product_star_rating'])
            except:
                clean_product['product_star_rating'] = 4.5

        batch.set(doc_ref, clean_product)
        batch_count += 1

        # Commit tous les 500 documents (limite Firestore)
        if batch_count >= 500:
            batch.commit()
            uploaded += batch_count
            print(f"   {uploaded}/{len(products)} produits uploadés...")
            batch = db.batch()
            batch_count = 0

    # Commit le dernier batch
    if batch_count > 0:
        batch.commit()
        uploaded += batch_count

    print(f"   ✅ {uploaded} produits uploadés!\n")

    print("=" * 80)
    print("✅ UPLOAD TERMINÉ!")
    print(f"   {uploaded} produits dans Firebase")
    print("=" * 80)

if __name__ == "__main__":
    upload_to_firebase()
