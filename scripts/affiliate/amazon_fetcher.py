#!/usr/bin/env python3
"""
Récupère les produits depuis Amazon Product Advertising API
"""
import time
from amazon.paapi import AmazonAPI
from config import AMAZON_CONFIG, BRANDS

class AmazonFetcher:
    def __init__(self):
        self.api = AmazonAPI(
            access_key=AMAZON_CONFIG["access_key"],
            secret_key=AMAZON_CONFIG["secret_key"],
            partner_tag=AMAZON_CONFIG["partner_tag"],
            country=AMAZON_CONFIG["region"]
        )

    def fetch_products_by_brand(self, brand, max_products=10):
        """Récupère les bestsellers d'une marque"""
        print(f"🔍 Recherche produits {brand} sur Amazon...")

        try:
            # Recherche par mot-clé (brand name)
            products = self.api.search_items(
                keywords=brand,
                item_count=max_products,
                resources=[
                    "Images.Primary.Large",
                    "ItemInfo.Title",
                    "ItemInfo.Features",
                    "Offers.Listings.Price",
                    "ItemInfo.ProductInfo",
                    "ItemInfo.Classifications"
                ]
            )

            results = []

            if products and products.items:
                for item in products.items:
                    try:
                        # Extraire les données
                        product = {
                            "source": "amazon",
                            "asin": item.asin,
                            "name": item.item_info.title.display_value if item.item_info.title else brand,
                            "brand": brand,
                            "url": item.detail_page_url,
                            "image": item.images.primary.large.url if item.images and item.images.primary else None,
                            "price": self._extract_price(item),
                            "description": self._extract_description(item),
                            "category": self._extract_category(item)
                        }

                        # Vérifier que l'image existe
                        if product["image"] and product["price"]:
                            results.append(product)
                            print(f"  ✓ {product['name'][:50]}... - {product['price']}€")

                    except Exception as e:
                        print(f"  ⚠️ Erreur produit: {e}")
                        continue

            time.sleep(1)  # Rate limiting
            return results

        except Exception as e:
            print(f"  ❌ Erreur Amazon API pour {brand}: {e}")
            return []

    def _extract_price(self, item):
        """Extrait le prix"""
        try:
            if item.offers and item.offers.listings:
                price = item.offers.listings[0].price
                if price and price.amount:
                    return int(price.amount)
        except:
            pass
        return None

    def _extract_description(self, item):
        """Extrait la description"""
        try:
            if item.item_info.features:
                return " ".join(item.item_info.features.display_values[:2])
        except:
            pass
        return f"Produit authentique {item.item_info.title.display_value if item.item_info.title else ''}"

    def _extract_category(self, item):
        """Extrait la catégorie"""
        try:
            if item.item_info.classifications:
                binding = item.item_info.classifications.binding
                if binding:
                    return binding.display_value
        except:
            pass
        return "Electronics"

    def fetch_all_brands(self, max_products_per_brand=10):
        """Récupère les produits de toutes les marques Amazon"""
        all_products = []

        print(f"\n🛒 AMAZON: Récupération de {len(BRANDS['amazon'])} marques\n")

        for brand in BRANDS["amazon"]:
            products = self.fetch_products_by_brand(brand, max_products_per_brand)
            all_products.extend(products)
            print(f"  → {len(products)} produits récupérés\n")

        print(f"✅ Amazon: {len(all_products)} produits au total\n")
        return all_products

if __name__ == "__main__":
    fetcher = AmazonFetcher()
    products = fetcher.fetch_all_brands(max_products_per_brand=5)
    print(f"\nTotal: {len(products)} produits")
