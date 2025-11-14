#!/usr/bin/env python3
"""
Upload vers Firebase Firestore via API REST
Plus fiable que le SDK Firebase admin
"""

import json
import requests
from pathlib import Path
from google.oauth2 import service_account
from google.auth.transport.requests import Request

# Configuration
SERVICE_ACCOUNT_PATH = Path(__file__).parent / "../serviceAccountKey.json"
PROJECT_ID = "doron-b3011"
DATABASE_ID = "(default)"
PRODUCTS_FILE = Path(__file__).parent / "realistic_bestsellers_complete.json"

def get_access_token():
    """Obtenir un token d'accès OAuth2"""
    credentials = service_account.Credentials.from_service_account_file(
        str(SERVICE_ACCOUNT_PATH),
        scopes=["https://www.googleapis.com/auth/datastore"]
    )
    credentials.refresh(Request())
    return credentials.token

def delete_all_products(access_token):
    """Supprimer tous les produits existants"""
    print("🗑️  Suppression des anciens produits...")

    # URL pour query
    base_url = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/{DATABASE_ID}/documents:runQuery"

    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json"
    }

    # Query pour obtenir tous les produits
    query = {
        "structuredQuery": {
            "from": [{"collectionId": "products"}],
            "limit": 500
        }
    }

    deleted_count = 0
    while True:
        response = requests.post(base_url, headers=headers, json=query)

        if response.status_code != 200:
            print(f"   Erreur lors de la récupération: {response.status_code}")
            break

        results = response.json()
        if not results:
            break

        # Supprimer chaque document
        for result in results:
            if 'document' in result:
                doc_name = result['document']['name']
                delete_url = f"https://firestore.googleapis.com/v1/{doc_name}"
                del_response = requests.delete(delete_url, headers=headers)

                if del_response.status_code in [200, 204]:
                    deleted_count += 1
                    if deleted_count % 100 == 0:
                        print(f"   {deleted_count} produits supprimés...")

        if len(results) < 500:
            break

    print(f"   ✅ {deleted_count} produits supprimés")
    return deleted_count

def upload_products(access_token):
    """Uploader les produits vers Firestore"""
    print(f"\n📤 Upload des produits...")

    # Charger les produits
    with open(PRODUCTS_FILE, 'r', encoding='utf-8') as f:
        data = json.load(f)

    products = data['products']
    print(f"   {len(products)} produits à uploader")

    base_url = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/{DATABASE_ID}/documents/products"

    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json"
    }

    uploaded = 0
    errors = 0

    for idx, product in enumerate(products):
        # Convertir le produit au format Firestore
        firestore_doc = {
            "fields": {}
        }

        for key, value in product.items():
            if isinstance(value, str):
                firestore_doc["fields"][key] = {"stringValue": value}
            elif isinstance(value, (int, float)):
                firestore_doc["fields"][key] = {"doubleValue": float(value)}
            elif isinstance(value, list):
                firestore_doc["fields"][key] = {
                    "arrayValue": {
                        "values": [{"stringValue": str(v)} for v in value]
                    }
                }
            elif isinstance(value, bool):
                firestore_doc["fields"][key] = {"booleanValue": value}

        # Upload
        response = requests.post(base_url, headers=headers, json=firestore_doc)

        if response.status_code in [200, 201]:
            uploaded += 1
            if uploaded % 100 == 0:
                print(f"      {uploaded}/{len(products)} produits uploadés...")
        else:
            errors += 1
            if errors <= 5:  # Afficher seulement les 5 premières erreurs
                print(f"      Erreur pour {product.get('product_title', 'Unknown')}: {response.status_code}")

    print(f"\n   ✅ {uploaded} produits uploadés avec succès")
    if errors > 0:
        print(f"   ⚠️  {errors} erreurs")

    return uploaded, errors

def main():
    print("=" * 80)
    print("🔥 UPLOAD FIREBASE VIA REST API")
    print("=" * 80)

    try:
        # Obtenir le token
        print("\n🔑 Authentification...")
        token = get_access_token()
        print("   ✅ Token obtenu")

        # Supprimer les anciens produits
        delete_all_products(token)

        # Uploader les nouveaux produits
        uploaded, errors = upload_products(token)

        print("\n" + "=" * 80)
        print("✨ TERMINÉ!")
        print(f"   {uploaded} produits uploadés")
        print("=" * 80)

    except Exception as e:
        print(f"\n❌ Erreur: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()
