#!/usr/bin/env python3
"""
Transforme les produits d'affiliation vers le schéma Doron
"""
import re
from config import CATEGORY_MAPPING

class DoronTransformer:

    def transform_product(self, product, product_id):
        """Transforme un produit vers le schéma Doron"""

        # Schéma Doron
        doron_product = {
            "id": product_id,
            "name": self._clean_name(product["name"]),
            "brand": product["brand"],
            "price": product["price"],
            "url": product["url"],
            "image": product["image"],
            "description": self._clean_description(product.get("description", "")),
            "categories": self._get_categories(product),
            "tags": self._generate_tags(product),
            "popularity": self._calculate_popularity(product),
            "source": product["source"]  # amazon, awin, cj
        }

        return doron_product

    def _clean_name(self, name):
        """Nettoie le nom du produit"""
        # Limite à 100 caractères
        name = name[:100]
        # Retire les caractères spéciaux excessifs
        name = re.sub(r'\s+', ' ', name)
        return name.strip()

    def _clean_description(self, description):
        """Nettoie la description"""
        if not description:
            return ""
        # Limite à 200 caractères
        description = description[:200]
        # Retire les caractères spéciaux
        description = re.sub(r'\s+', ' ', description)
        return description.strip()

    def _get_categories(self, product):
        """Détermine les catégories Doron"""
        category = product.get("category", "")

        # Recherche dans le mapping
        for key, value in CATEGORY_MAPPING.items():
            if key.lower() in category.lower():
                return value["categories"]

        # Catégorie par défaut basée sur la marque
        brand = product["brand"].lower()

        if brand in ["apple", "samsung", "sony", "bose", "jbl"]:
            return ["tech"]
        elif brand in ["nike", "adidas", "puma", "new balance"]:
            return ["sport"]
        elif brand in ["zara", "h&m", "mango", "sandro", "maje"]:
            return ["mode-fast-fashion"]
        elif brand in ["dyson", "kitchenaid", "nespresso"]:
            return ["electromenager"]
        elif brand in ["the ordinary", "la roche-posay", "cerave"]:
            return ["beaute"]
        else:
            return ["tech"]  # Défaut

    def _generate_tags(self, product):
        """Génère les tags automatiquement"""
        tags = []

        price = product["price"]
        category = product.get("category", "").lower()
        name = product["name"].lower()

        # 1. Tags de genre
        if any(word in category or word in name for word in ["women", "femme", "woman", "her"]):
            tags.append("femme")
        elif any(word in category or word in name for word in ["men", "homme", "man", "his"]):
            tags.append("homme")
        else:
            # Par défaut mixte
            tags.extend(["homme", "femme"])

        # 2. Tags d'âge basés sur le prix
        if price < 50:
            tags.append("20-30ans")
        elif price < 200:
            tags.extend(["20-30ans", "30-50ans"])
        else:
            tags.extend(["30-50ans", "50+"])

        # 3. Tags de budget
        if price < 50:
            tags.append("budget_0-50")
        elif price < 100:
            tags.append("budget_50-100")
        elif price < 200:
            tags.append("budget_100-200")
        else:
            tags.append("budget_200+")

        # 4. Tags de catégorie
        category_tags = self._get_category_tags(product)
        tags.extend(category_tags)

        # 5. Tags de style basés sur le nom
        style_tags = self._detect_style(name)
        tags.extend(style_tags)

        # Retirer les doublons
        return list(set(tags))

    def _get_category_tags(self, product):
        """Extrait les tags de catégorie"""
        category = product.get("category", "")

        for key, value in CATEGORY_MAPPING.items():
            if key.lower() in category.lower():
                return value["tags"]

        # Par défaut basé sur la marque
        brand = product["brand"].lower()

        if brand in ["apple", "samsung", "sony", "bose", "jbl", "nintendo", "playstation"]:
            return ["tech"]
        elif brand in ["nike", "adidas", "puma", "new balance"]:
            return ["sports"]
        elif brand in ["zara", "h&m", "mango", "sandro", "maje"]:
            return ["fashion"]
        elif brand in ["the ordinary", "la roche-posay", "cerave", "lush"]:
            return ["beauty"]
        elif brand in ["dyson", "kitchenaid", "nespresso"]:
            return ["home"]
        else:
            return []

    def _detect_style(self, name):
        """Détecte le style à partir du nom"""
        styles = []

        # Style casual
        if any(word in name for word in ["casual", "basic", "everyday", "t-shirt", "jean"]):
            styles.append("casual")

        # Style sport
        if any(word in name for word in ["sport", "running", "training", "fitness", "gym"]):
            styles.append("sport")

        # Style élégant
        if any(word in name for word in ["elegant", "chic", "blazer", "dress", "robe", "costume"]):
            styles.append("elegant")

        # Style tech
        if any(word in name for word in ["wireless", "bluetooth", "smart", "pro", "gaming"]):
            styles.append("tech")

        return styles

    def _calculate_popularity(self, product):
        """Calcule le score de popularité"""
        # Score de base
        score = 75

        # Bonus selon la source (Amazon = plus fiable)
        if product["source"] == "amazon":
            score += 15
        elif product["source"] == "awin":
            score += 10
        elif product["source"] == "cj":
            score += 10

        # Bonus selon le prix (produits moyens = plus populaires)
        price = product["price"]
        if 50 <= price <= 150:
            score += 10
        elif price < 50:
            score += 5

        return min(score, 100)

    def transform_batch(self, products, start_id=1):
        """Transforme un lot de produits"""
        transformed = []

        for i, product in enumerate(products):
            try:
                doron_product = self.transform_product(product, start_id + i)
                transformed.append(doron_product)
            except Exception as e:
                print(f"⚠️ Erreur transformation: {e}")
                continue

        return transformed

if __name__ == "__main__":
    # Test
    transformer = DoronTransformer()

    test_product = {
        "source": "amazon",
        "name": "Apple iPhone 15 Pro 128GB",
        "brand": "Apple",
        "price": 1229,
        "url": "https://amazon.fr/dp/B0CHX3TW6F",
        "image": "https://m.media-amazon.com/images/I/81SigpJN1KL.jpg",
        "description": "iPhone 15 Pro avec puce A17 Pro",
        "category": "Electronics"
    }

    result = transformer.transform_product(test_product, 1)
    print(result)
