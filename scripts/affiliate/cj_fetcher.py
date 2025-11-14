#!/usr/bin/env python3
"""
Récupère les produits depuis CJ Affiliate Product Catalog API
"""
import requests
import time
from config import CJ_CONFIG, BRANDS

class CJFetcher:
    def __init__(self):
        self.api_token = CJ_CONFIG["api_token"]
        self.website_id = CJ_CONFIG["website_id"]
        self.base_url = CJ_CONFIG["base_url"]
        self.headers = {
            "Authorization": f"Bearer {self.api_token}",
            "Content-Type": "application/json"
        }

    def fetch_products_by_advertiser(self, advertiser_name, max_products=10):
        """Récupère les produits d'un annonceur CJ"""
        print(f"🔍 Recherche produits {advertiser_name} sur CJ Affiliate...")

        try:
            url = f"{self.base_url}/v2/product-search"
            params = {
                "advertiser-ids": self._get_advertiser_id(advertiser_name),
                "records-per-page": max_products,
                "website-id": self.website_id,
                "keywords": advertiser_name
            }

            response = requests.get(url, headers=self.headers, params=params, timeout=30)

            if response.status_code == 200:
                data = response.json()
                results = []

                for item in data.get("products", []):
                    try:
                        product = {
                            "source": "cj",
                            "product_id": item.get("catalog-id"),
                            "name": item.get("name"),
                            "brand": advertiser_name,
                            "url": item.get("buy-url"),
                            "image": item.get("image-url"),
                            "price": self._extract_price(item),
                            "description": item.get("description", f"Produit {advertiser_name}"),
                            "category": item.get("category", "Fashion")
                        }

                        if product["image"] and product["price"]:
                            results.append(product)
                            print(f"  ✓ {product['name'][:50]}... - {product['price']}€")

                    except Exception as e:
                        print(f"  ⚠️ Erreur produit: {e}")
                        continue

                time.sleep(1)  # Rate limiting
                return results

            else:
                print(f"  ❌ Erreur API CJ: {response.status_code}")
                return []

        except Exception as e:
            print(f"  ❌ Erreur CJ pour {advertiser_name}: {e}")
            return []

    def _get_advertiser_id(self, advertiser_name):
        """
        Mapping des noms de marques vers leurs IDs CJ
        Tu devras remplir ces IDs après avoir candidaté aux programmes
        """
        advertiser_ids = {
            "Nike": "XXXXX",  # À remplir après inscription
            "Adidas": "XXXXX",
            "Under Armour": "XXXXX",
            "Sephora": "XXXXX",
            "Ulta Beauty": "XXXXX",
            "Macy's": "XXXXX",
            "Nordstrom": "XXXXX"
        }
        return advertiser_ids.get(advertiser_name, "XXXXX")

    def _extract_price(self, item):
        """Extrait le prix"""
        try:
            price = item.get("price", {}).get("amount")
            if price:
                return int(float(price))
        except:
            pass
        return None

    def fetch_all_brands(self, max_products_per_brand=10):
        """Récupère les produits de toutes les marques CJ"""
        all_products = []

        print(f"\n💼 CJ AFFILIATE: Récupération de {len(BRANDS['cj'])} marques\n")

        for brand in BRANDS["cj"]:
            products = self.fetch_products_by_advertiser(brand, max_products_per_brand)
            all_products.extend(products)
            print(f"  → {len(products)} produits récupérés\n")

        print(f"✅ CJ: {len(all_products)} produits au total\n")
        return all_products

if __name__ == "__main__":
    fetcher = CJFetcher()
    products = fetcher.fetch_all_brands(max_products_per_brand=5)
    print(f"\nTotal: {len(products)} produits")
