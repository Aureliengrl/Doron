#!/usr/bin/env python3
"""
Transforme les produits scrapés vers le schéma Doron et upload vers Firestore
"""
import json
import sys
import re

# Ajouter le chemin pour importer doron_transformer
sys.path.insert(0, '/home/user/Doron/scripts/affiliate')

from doron_transformer import DoronTransformer

def main():
    print("=" * 70)
    print("🔄 TRANSFORMATION VERS SCHÉMA DORON")
    print("=" * 70)
    print()

    # Charger les produits scrapés
    print("📂 Chargement des produits scrap és...")
    with open('/home/user/Doron/scripts/affiliate/scraped_products.json', 'r', encoding='utf-8') as f:
        scraped_products = json.load(f)

    print(f"✅ {len(scraped_products)} produits chargés\n")

    # Transformer
    print("🔄 Transformation vers schéma Doron avec génération de tags...\n")
    transformer = DoronTransformer()

    doron_products = []
    for i, product in enumerate(scraped_products):
        # Ajouter source
        product['source'] = 'scraped'

        # Transformer
        doron_product = transformer.transform_product(product, i + 1)
        doron_products.append(doron_product)

        if (i + 1) % 50 == 0:
            print(f"  ✓ {i + 1}/{len(scraped_products)} produits transformés...")

    print(f"\n✅ {len(doron_products)} produits transformés\n")

    # Statistiques
    print("=" * 70)
    print("📊 STATISTIQUES")
    print("=" * 70)

    # Par catégorie
    categories = {}
    for p in doron_products:
        for cat in p['categories']:
            categories[cat] = categories.get(cat, 0) + 1

    print("\n📂 Par catégorie:")
    for cat, count in sorted(categories.items(), key=lambda x: x[1], reverse=True):
        print(f"  • {cat}: {count} produits")

    # Par marque (top 20)
    brands = {}
    for p in doron_products:
        brands[p['brand']] = brands.get(p['brand'], 0) + 1

    print("\n🏷️ Top 20 marques:")
    for brand, count in sorted(brands.items(), key=lambda x: x[1], reverse=True)[:20]:
        print(f"  • {brand}: {count} produits")

    # Distribution des prix
    prices = [p['price'] for p in doron_products]
    print(f"\n💰 Prix:")
    print(f"  • Min: {min(prices)}€")
    print(f"  • Max: {max(prices)}€")
    print(f"  • Moyen: {sum(prices)//len(prices)}€")

    # Distribution des tags
    all_tags = {}
    for p in doron_products:
        for tag in p['tags']:
            all_tags[tag] = all_tags.get(tag, 0) + 1

    print(f"\n🏷️ Tags les plus utilisés:")
    for tag, count in sorted(all_tags.items(), key=lambda x: x[1], reverse=True)[:15]:
        print(f"  • {tag}: {count} produits")

    # Sauvegarder
    print("\n" + "=" * 70)
    print("💾 SAUVEGARDE")
    print("=" * 70)

    output_file = '/home/user/Doron/scripts/affiliate/doron_products.json'
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(doron_products, f, ensure_ascii=False, indent=2)

    print(f"\n✅ Produits Doron sauvegardés dans: {output_file}")

    # Exemple de produit
    print("\n" + "=" * 70)
    print("📄 EXEMPLE DE PRODUIT TRANSFORMÉ")
    print("=" * 70)
    print(json.dumps(doron_products[0], indent=2, ensure_ascii=False))

    print("\n" + "=" * 70)
    print("✅ TRANSFORMATION TERMINÉE")
    print("=" * 70)
    print(f"\nProduits prêts pour Firestore: {len(doron_products)}")
    print(f"Fichier: {output_file}\n")

if __name__ == "__main__":
    main()
