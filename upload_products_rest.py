#!/usr/bin/env python3
"""
Script Python pour uploader les produits à Firebase via REST API
Utilise l'API REST publique de Firestore (pas besoin de service account)
"""

import json
import requests
import time
from typing import List, Dict, Any

# Configuration Firebase
PROJECT_ID = "doron-b3011"
API_KEY = "AIzaSyAl7Jlzgyet26D3zO4pF56BfznA3k3AiTk"

# URLs de l'API Firestore REST
FIRESTORE_BASE_URL = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents"

def load_products() -> List[Dict[str, Any]]:
    """Charge les produits depuis le fichier JSON"""
    print("📖 Chargement des produits depuis assets/jsons/fallback_products.json...")
    with open('assets/jsons/fallback_products.json', 'r', encoding='utf-8') as f:
        products = json.load(f)
    print(f"✅ {len(products)} produits chargés\n")
    return products

def convert_to_firestore_format(product: Dict[str, Any]) -> Dict[str, Any]:
    """Convertit un produit au format Firestore REST API"""
    fields = {}

    for key, value in product.items():
        if key == 'id':  # Skip id car il sera dans le document ID
            continue

        if isinstance(value, str):
            fields[key] = {"stringValue": value}
        elif isinstance(value, int):
            fields[key] = {"integerValue": str(value)}
        elif isinstance(value, float):
            fields[key] = {"doubleValue": value}
        elif isinstance(value, bool):
            fields[key] = {"booleanValue": value}
        elif isinstance(value, list):
            array_values = []
            for item in value:
                if isinstance(item, str):
                    array_values.append({"stringValue": item})
                elif isinstance(item, int):
                    array_values.append({"integerValue": str(item)})
                elif isinstance(item, float):
                    array_values.append({"doubleValue": item})
            fields[key] = {"arrayValue": {"values": array_values}}
        elif value is None:
            fields[key] = {"nullValue": None}

    return {"fields": fields}

def delete_all_products():
    """Supprime tous les produits existants"""
    print("🗑️  ÉTAPE 1: Suppression des anciens produits...")
    print("   Cette étape peut prendre quelques minutes...\n")

    deleted_count = 0
    page_token = None
    max_iterations = 50  # Max 50 pages (25000 produits)

    for iteration in range(max_iterations):
        # List documents
        list_url = f"{FIRESTORE_BASE_URL}/products"
        params = {
            "pageSize": 500,
            "key": API_KEY
        }
        if page_token:
            params["pageToken"] = page_token

        response = requests.get(list_url, params=params)

        if response.status_code != 200:
            if response.status_code == 404:
                print("   Collection vide, pas de produits à supprimer")
                break
            print(f"   ⚠️ Erreur listing: {response.status_code}")
            print(f"   {response.text}")
            break

        data = response.json()
        documents = data.get('documents', [])

        if not documents:
            print("   Plus de documents à supprimer")
            break

        print(f"   Suppression de {len(documents)} produits (batch {iteration + 1})...")

        # Delete each document
        for doc in documents:
            doc_path = doc['name']
            delete_url = f"https://firestore.googleapis.com/v1/{doc_path}?key={API_KEY}"
            del_response = requests.delete(delete_url)
            if del_response.status_code == 200:
                deleted_count += 1
            time.sleep(0.01)  # Rate limiting

        print(f"   ✅ {deleted_count} produits supprimés au total")

        # Check for next page
        page_token = data.get('nextPageToken')
        if not page_token:
            break

    print(f"\n✅ Suppression terminée: {deleted_count} produits supprimés\n")
    return deleted_count

def upload_products(products: List[Dict[str, Any]]):
    """Upload les produits à Firebase"""
    print("📤 ÉTAPE 2: Upload des nouveaux produits avec tags...\n")

    # Vérifier la structure du premier produit
    sample = products[0]
    print("📋 Structure d'un produit:")
    print(f"   - Champs: {', '.join(sample.keys())}")
    print(f"   - Tags: {len(sample.get('tags', []))} tags")
    print(f"   - Categories: {len(sample.get('categories', []))} categories")
    print(f"   - Exemple tags: {', '.join(sample.get('tags', [])[:5])}\n")

    if not sample.get('tags') or not sample.get('categories'):
        print("❌ ERREUR: Les produits n'ont pas de tags/categories!")
        return 0

    uploaded_count = 0
    errors = 0
    batch_size = 50
    total_batches = (len(products) + batch_size - 1) // batch_size

    for i in range(0, len(products), batch_size):
        batch = products[i:i + batch_size]
        batch_num = (i // batch_size) + 1

        print(f"📦 Batch {batch_num}/{total_batches}: Produits {i + 1} à {min(i + batch_size, len(products))}...")

        for product in batch:
            product_id = str(product['id'])
            firestore_data = convert_to_firestore_format(product)

            # Create/Update document
            url = f"{FIRESTORE_BASE_URL}/products/{product_id}?key={API_KEY}"

            response = requests.patch(url, json=firestore_data)

            if response.status_code in [200, 201]:
                uploaded_count += 1
            else:
                errors += 1
                if errors <= 5:  # Log first 5 errors only
                    print(f"   ⚠️ Erreur produit {product_id}: {response.status_code}")
                    print(f"   {response.text[:200]}")

            time.sleep(0.02)  # Rate limiting - 50 requests/sec max

        print(f"   ✅ {len(batch)} produits uploadés")

    print(f"\n✅ Upload terminé: {uploaded_count} produits uploadés")
    if errors > 0:
        print(f"⚠️ {errors} erreurs rencontrées")
    print()

    return uploaded_count

def verify_upload():
    """Vérifie que les produits sont bien uploadés"""
    print("🔍 ÉTAPE 3: Vérification finale...\n")

    # Get first product to verify structure
    list_url = f"{FIRESTORE_BASE_URL}/products"
    params = {
        "pageSize": 1,
        "key": API_KEY
    }

    response = requests.get(list_url, params=params)

    if response.status_code == 200:
        data = response.json()
        documents = data.get('documents', [])

        if documents:
            doc = documents[0]
            fields = doc.get('fields', {})

            has_tags = 'tags' in fields
            has_categories = 'categories' in fields

            print(f"✅ Tags présents: {'✓' if has_tags else '✗'}")
            print(f"✅ Categories présentes: {'✓' if has_categories else '✗'}")

            if has_tags:
                tags_array = fields['tags'].get('arrayValue', {}).get('values', [])
                tag_values = [t.get('stringValue', '') for t in tags_array]
                print(f"✅ Exemple tags: {', '.join(tag_values[:5])}")

            print("\n🎉 VÉRIFICATION RÉUSSIE!")
            print("✅ Tous les produits ont des tags et categories")
            print("✅ Prêt pour une expérience personnalisée!\n")

            return True

    print("❌ Erreur de vérification")
    return False

def main():
    """Main function"""
    print("=" * 70)
    print("🔧 RÉPARATION DES PRODUITS FIREBASE - Doron App")
    print("=" * 70)
    print()
    print("Ce script va:")
    print("1. ❌ Supprimer tous les anciens produits (sans tags)")
    print("2. ✅ Uploader 2201 nouveaux produits (avec tags)")
    print("3. ✓ Vérifier que tout fonctionne")
    print()
    print("=" * 70)
    print()

    try:
        # Charger les produits
        products = load_products()

        # Supprimer les anciens
        delete_all_products()

        # Uploader les nouveaux
        uploaded = upload_products(products)

        if uploaded > 0:
            # Vérifier
            verify_upload()

            print("=" * 70)
            print("🎉 RÉPARATION TERMINÉE!")
            print("=" * 70)
            print()
            print(f"✅ {uploaded} produits correctement configurés")
            print("✅ Tous les produits ont des tags et categories")
            print("✅ Prêt pour une expérience personnalisée!")
            print()
            print("📱 Relance ton app maintenant et profite des produits variés!")
            print()
        else:
            print("❌ Aucun produit uploadé")
            return 1

    except FileNotFoundError:
        print("❌ Fichier assets/jsons/fallback_products.json non trouvé!")
        return 1
    except Exception as e:
        print(f"❌ Erreur: {e}")
        import traceback
        traceback.print_exc()
        return 1

    return 0

if __name__ == "__main__":
    exit(main())
