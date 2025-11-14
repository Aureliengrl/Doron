#!/usr/bin/env python3
"""
Upload les produits transformés vers Firestore
"""
import firebase_admin
from firebase_admin import credentials, firestore
from config import FIREBASE_CONFIG
import json

class FirestoreUploader:
    def __init__(self):
        # Initialiser Firebase Admin SDK
        if not firebase_admin._apps:
            cred = credentials.Certificate(FIREBASE_CONFIG["service_account_path"])
            firebase_admin.initialize_app(cred)

        self.db = firestore.client()
        self.collection_name = "products"

    def upload_products(self, products, batch_size=500):
        """Upload les produits vers Firestore par batch"""
        print(f"\n📤 Upload de {len(products)} produits vers Firestore...\n")

        total_uploaded = 0
        total_errors = 0

        # Firestore permet max 500 opérations par batch
        for i in range(0, len(products), batch_size):
            batch = self.db.batch()
            batch_products = products[i:i + batch_size]

            for product in batch_products:
                try:
                    # Créer la référence du document (utilise l'ID du produit)
                    doc_ref = self.db.collection(self.collection_name).document(str(product["id"]))

                    # Préparer les données (retirer 'source' si tu ne veux pas le stocker)
                    product_data = {k: v for k, v in product.items() if k != "source"}

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

        print(f"\n✅ Upload terminé:")
        print(f"  • Succès: {total_uploaded} produits")
        print(f"  • Erreurs: {total_errors} produits")

        return total_uploaded, total_errors

    def clear_collection(self):
        """Vide la collection products (utilise avec précaution!)"""
        print(f"\n⚠️ Suppression de tous les produits de '{self.collection_name}'...")

        docs = self.db.collection(self.collection_name).stream()
        deleted = 0

        batch = self.db.batch()
        for doc in docs:
            batch.delete(doc.reference)
            deleted += 1

            if deleted % 500 == 0:
                batch.commit()
                batch = self.db.batch()
                print(f"  • {deleted} produits supprimés...")

        batch.commit()
        print(f"✅ {deleted} produits supprimés au total\n")
        return deleted

    def get_collection_stats(self):
        """Affiche les stats de la collection"""
        docs = self.db.collection(self.collection_name).stream()

        count = 0
        brands = {}
        sources = {}

        for doc in docs:
            count += 1
            data = doc.to_dict()

            brand = data.get("brand", "Unknown")
            brands[brand] = brands.get(brand, 0) + 1

            source = data.get("source", "Unknown")
            sources[source] = sources.get(source, 0) + 1

        print(f"\n📊 Stats Firestore '{self.collection_name}':")
        print(f"  • Total produits: {count}")
        print(f"\n  • Par marque:")
        for brand, count in sorted(brands.items(), key=lambda x: x[1], reverse=True)[:10]:
            print(f"    - {brand}: {count}")

        print(f"\n  • Par source:")
        for source, count in sources.items():
            print(f"    - {source}: {count}")
        print()

if __name__ == "__main__":
    uploader = FirestoreUploader()
    uploader.get_collection_stats()
