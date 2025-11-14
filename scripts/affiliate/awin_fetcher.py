#!/usr/bin/env python3
"""
Récupère les produits depuis Awin Product API
"""
import requests
import time
from config import AWIN_CONFIG, BRANDS

class AwinFetcher:
    def __init__(self):
        self.api_token = AWIN_CONFIG["api_token"]
        self.publisher_id = AWIN_CONFIG["publisher_id"]
        self.base_url = AWIN_CONFIG["base_url"]
        self.headers = {
            "Authorization": f"Bearer {self.api_token}",
            "Content-Type": "application/json"
        }

    def fetch_products_by_advertiser(self, advertiser_name, max_products=10):
        """Récupère les produits d'un annonceur Awin"""
        print(f"🔍 Recherche produits {advertiser_name} sur Awin...")

        try:
            # Recherche par nom d'annonceur
            url = f"{self.base_url}/products"
            params = {
                "advertiserId": self._get_advertiser_id(advertiser_name),
                "limit": max_products,
                "publisherId": self.publisher_id
            }

            response = requests.get(url, headers=self.headers, params=params, timeout=30)

            if response.status_code == 200:
                data = response.json()
                results = []

                for item in data.get("products", []):
                    try:
                        product = {
                            "source": "awin",
                            "product_id": item.get("product_id"),
                            "name": item.get("product_name"),
                            "brand": advertiser_name,
                            "url": item.get("merchant_deep_link"),
                            "image": item.get("merchant_image_url") or item.get("aw_image_url"),
                            "price": self._extract_price(item),
                            "description": item.get("description", f"Produit {advertiser_name}"),
                            "category": item.get("category_name", "Fashion")
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
                print(f"  ❌ Erreur API Awin: {response.status_code}")
                return []

        except Exception as e:
            print(f"  ❌ Erreur Awin pour {advertiser_name}: {e}")
            return []

    def _get_advertiser_id(self, advertiser_name):
        """
        Mapping des noms de marques vers leurs IDs Awin
        Tu devras remplir ces IDs après avoir candidaté aux programmes
        """
        advertiser_ids = {
            "Zara": "XXXXX",  # À remplir après inscription
            "H&M": "XXXXX",
            "Mango": "XXXXX",
            "ASOS": "3306",  # Exemple réel
            "Zalando": "15008",  # Exemple réel
            "Sandro": "XXXXX",
            "Maje": "XXXXX",
            "Claudie Pierlot": "XXXXX",
            "ba&sh": "XXXXX",
            "Sephora": "XXXXX",
            "Marionnaud": "XXXXX",
            "IKEA": "XXXXX",
            "Maisons du Monde": "XXXXX"
        }
        return advertiser_ids.get(advertiser_name, "XXXXX")

    def _extract_price(self, item):
        """Extrait le prix"""
        try:
            price_str = item.get("search_price", "0")
            # Convertit "29.99 EUR" ou "29.99" en int
            price = float(price_str.split()[0])
            return int(price)
        except:
            return None

    def fetch_all_brands(self, max_products_per_brand=10):
        """Récupère les produits de toutes les marques Awin"""
        all_products = []

        print(f"\n👗 AWIN: Récupération de {len(BRANDS['awin'])} marques\n")

        for brand in BRANDS["awin"]:
            products = self.fetch_products_by_advertiser(brand, max_products_per_brand)
            all_products.extend(products)
            print(f"  → {len(products)} produits récupérés\n")

        print(f"✅ Awin: {len(all_products)} produits au total\n")
        return all_products

if __name__ == "__main__":
    fetcher = AwinFetcher()
    products = fetcher.fetch_all_brands(max_products_per_brand=5)
    print(f"\nTotal: {len(products)} produits")
