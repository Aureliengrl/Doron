#!/usr/bin/env python3
"""
Upload les produits Doron vers Firestore
"""
import json
import sys

# Vérifier si firebase-admin est disponible
try:
    import firebase_admin
    from firebase_admin import credentials, firestore
    FIREBASE_AVAILABLE = True
except ImportError:
    FIREBASE_AVAILABLE = False
    print("⚠️ firebase-admin non installé. Installation...")

def upload_to_firestore():
    """Upload les produits vers Firestore"""

    if not FIREBASE_AVAILABLE:
        print("❌ Firebase Admin SDK non disponible")
        print("📝 Install avec: pip3 install firebase-admin")
        return False

    print("=" * 70)
    print("📤 UPLOAD VERS FIRESTORE")
    print("=" * 70)
    print()

    # Charger les produits Doron
    print("📂 Chargement des produits...")
    with open('/home/user/Doron/scripts/affiliate/doron_products.json', 'r', encoding='utf-8') as f:
        products = json.load(f)

    print(f"✅ {len(products)} produits chargés\n")

    # Initialiser Firebase
    print("🔑 Initialisation Firebase...")

    try:
        # Vérifier si déjà initialisé
        if not firebase_admin._apps:
            # Chercher le fichier google-services.json
            service_account_path = '/home/user/Doron/android/app/google-services.json'

            cred = credentials.Certificate(service_account_path)
            firebase_admin.initialize_app(cred)
            print("✅ Firebase initialisé\n")
        else:
            print("✅ Firebase déjà initialisé\n")

        db = firestore.client()

    except Exception as e:
        print(f"❌ Erreur initialisation Firebase: {e}")
        print("\n💡 Assure-toi que google-services.json existe dans android/app/")
        return False

    # Upload par batch
    print("📤 Upload des produits vers Firestore...")
    print(f"Collection: 'products'\n")

    collection_name = "products"
    batch_size = 500  # Firestore max = 500
    total_uploaded = 0
    total_errors = 0

    for i in range(0, len(products), batch_size):
        batch = db.batch()
        batch_products = products[i:i + batch_size]

        for product in batch_products:
            try:
                # Retirer 'source' si présent (pas besoin dans Firestore)
                product_data = {k: v for k, v in product.items() if k != 'source'}

                # Créer la référence du document
                doc_ref = db.collection(collection_name).document(str(product['id']))

                # Ajouter au batch
                batch.set(doc_ref, product_data, merge=True)

            except Exception as e:
                print(f"⚠️ Erreur préparation produit {product.get('id')}: {e}")
                total_errors += 1
                continue

        try:
            # Commit le batch
            batch.commit()
            total_uploaded += len(batch_products)
            print(f"  ✓ Batch {i//batch_size + 1}: {len(batch_products)} produits uploadés")

        except Exception as e:
            print(f"  ❌ Erreur upload batch {i//batch_size + 1}: {e}")
            total_errors += len(batch_products)

    # Résumé
    print("\n" + "=" * 70)
    print("✅ UPLOAD TERMINÉ")
    print("=" * 70)
    print(f"\n  • Produits uploadés: {total_uploaded}")
    print(f"  • Erreurs: {total_errors}")
    print(f"  • Collection: {collection_name}")
    print()

    # Stats Firestore
    print("=" * 70)
    print("📊 VÉRIFICATION FIRESTORE")
    print("=" * 70)
    print()

    try:
        docs = db.collection(collection_name).stream()

        count = 0
        brands = {}

        for doc in docs:
            count += 1
            data = doc.to_dict()
            brand = data.get('brand', 'Unknown')
            brands[brand] = brands.get(brand, 0) + 1

        print(f"📦 Total produits dans Firestore: {count}")
        print(f"\n🏷️ Top 10 marques:")
        for brand, cnt in sorted(brands.items(), key=lambda x: x[1], reverse=True)[:10]:
            print(f"  • {brand}: {cnt} produits")
        print()

    except Exception as e:
        print(f"⚠️ Erreur lecture stats: {e}\n")

    return True

if __name__ == "__main__":
    # Installer firebase-admin si nécessaire
    if not FIREBASE_AVAILABLE:
        import subprocess
        try:
            subprocess.run(['pip3', 'install', 'firebase-admin', '--user'], check=True)
            print("✅ firebase-admin installé! Relance le script.\n")
            sys.exit(0)
        except:
            print("❌ Impossible d'installer firebase-admin")
            sys.exit(1)

    success = upload_to_firestore()
    sys.exit(0 if success else 1)
