#!/usr/bin/env python3
"""
Script principal: Récupère les produits d'affiliation et les upload dans Firestore

Usage:
    python main.py                    # Récupère tout et upload
    python main.py --source amazon    # Seulement Amazon
    python main.py --source awin      # Seulement Awin
    python main.py --source cj        # Seulement CJ
    python main.py --dry-run          # Test sans upload
    python main.py --clear            # Vide la collection avant upload
"""
import argparse
import json
from datetime import datetime
from config import validate_config
from amazon_fetcher import AmazonFetcher
from awin_fetcher import AwinFetcher
from cj_fetcher import CJFetcher
from doron_transformer import DoronTransformer
from firestore_uploader import FirestoreUploader

def main():
    parser = argparse.ArgumentParser(description='Synchronise les produits d\'affiliation vers Firestore')
    parser.add_argument('--source', choices=['amazon', 'awin', 'cj', 'all'], default='all',
                      help='Source à synchroniser (défaut: all)')
    parser.add_argument('--max-per-brand', type=int, default=10,
                      help='Nombre max de produits par marque (défaut: 10)')
    parser.add_argument('--dry-run', action='store_true',
                      help='Test sans upload vers Firestore')
    parser.add_argument('--clear', action='store_true',
                      help='Vide la collection avant upload')
    parser.add_argument('--save-json', type=str,
                      help='Sauvegarde les produits dans un fichier JSON')

    args = parser.parse_args()

    print("=" * 70)
    print("🎁 DORON - Synchronisation produits d'affiliation")
    print("=" * 70)
    print(f"\nDate: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"Source: {args.source}")
    print(f"Max produits/marque: {args.max_per_brand}")
    print(f"Mode: {'DRY RUN' if args.dry_run else 'UPLOAD'}")
    print()

    # Valider la configuration
    missing = validate_config()
    if missing and not args.dry_run:
        print("❌ Configuration incomplète. Clés manquantes:")
        for key in missing:
            print(f"  • {key}")
        print("\nRemplis le fichier .env et réessaye.")
        return

    # Récupération des produits
    all_products = []

    if args.source in ['amazon', 'all']:
        try:
            fetcher = AmazonFetcher()
            products = fetcher.fetch_all_brands(args.max_per_brand)
            all_products.extend(products)
        except Exception as e:
            print(f"❌ Erreur Amazon: {e}\n")

    if args.source in ['awin', 'all']:
        try:
            fetcher = AwinFetcher()
            products = fetcher.fetch_all_brands(args.max_per_brand)
            all_products.extend(products)
        except Exception as e:
            print(f"❌ Erreur Awin: {e}\n")

    if args.source in ['cj', 'all']:
        try:
            fetcher = CJFetcher()
            products = fetcher.fetch_all_brands(args.max_per_brand)
            all_products.extend(products)
        except Exception as e:
            print(f"❌ Erreur CJ: {e}\n")

    print("=" * 70)
    print(f"📦 Total produits récupérés: {len(all_products)}")
    print("=" * 70)
    print()

    if not all_products:
        print("❌ Aucun produit récupéré. Vérifie ta configuration.")
        return

    # Transformation vers schéma Doron
    print("🔄 Transformation vers schéma Doron...\n")
    transformer = DoronTransformer()
    doron_products = transformer.transform_batch(all_products, start_id=1)

    print(f"✅ {len(doron_products)} produits transformés\n")

    # Sauvegarder en JSON si demandé
    if args.save_json:
        with open(args.save_json, 'w', encoding='utf-8') as f:
            json.dump(doron_products, f, ensure_ascii=False, indent=2)
        print(f"💾 Produits sauvegardés dans {args.save_json}\n")

    # Upload vers Firestore
    if not args.dry_run:
        uploader = FirestoreUploader()

        if args.clear:
            uploader.clear_collection()

        success, errors = uploader.upload_products(doron_products)

        print("\n" + "=" * 70)
        print("📊 RÉSUMÉ FINAL")
        print("=" * 70)
        print(f"  • Produits récupérés: {len(all_products)}")
        print(f"  • Produits transformés: {len(doron_products)}")
        print(f"  • Uploadés avec succès: {success}")
        print(f"  • Erreurs: {errors}")
        print("=" * 70)

        # Afficher les stats Firestore
        uploader.get_collection_stats()

    else:
        print("\n🧪 DRY RUN - Aucun upload effectué")
        print("\nExemple de produit transformé:")
        if doron_products:
            print(json.dumps(doron_products[0], indent=2, ensure_ascii=False))

if __name__ == "__main__":
    main()
