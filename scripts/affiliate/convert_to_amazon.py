#!/usr/bin/env python3
"""
Script to convert products to Amazon affiliate links
"""
import json
import re

# Amazon affiliate tag
AFFILIATE_TAG = "doron072004-21"

def create_amazon_url(asin):
    """Create Amazon affiliate URL from ASIN"""
    return f"https://www.amazon.fr/dp/{asin}?tag={AFFILIATE_TAG}"

def create_amazon_image_url(image_id):
    """Create Amazon CDN image URL"""
    return f"https://m.media-amazon.com/images/I/{image_id}._AC_SL1500_.jpg"

def extract_asin_from_url(url):
    """Extract ASIN from Amazon URL"""
    # Pattern: /dp/ASIN or /gp/product/ASIN
    match = re.search(r'/dp/([A-Z0-9]{10})', url)
    if match:
        return match.group(1)
    match = re.search(r'/gp/product/([A-Z0-9]{10})', url)
    if match:
        return match.group(1)
    return None

# Manual mapping for priority products found via WebSearch
AMAZON_MAPPINGS = {
    # Nike products
    "Nike Air Force 1 '07 White": {
        "asin": "B0BXJ396WL",
        "image_id": None  # Will need to fetch
    },
    # Apple products
    "AirPods Pro (2nd generation)": {
        "asin": "B0CHWZ9TZS",
        "image_id": None
    },
    # Samsung products
    "Samsung Galaxy S24 Ultra": {
        "asin": "B0CSVS3FNK",
        "image_id": None
    },
    # Sony products
    "Sony WH-1000XM5": {
        "asin": "B09Y2MYL5C",
        "image_id": None
    }
}

def convert_product(product):
    """Convert a product to use Amazon affiliate links"""
    converted = product.copy()

    # Check if we have a manual mapping
    product_name = product.get("name", "")

    if product_name in AMAZON_MAPPINGS:
        mapping = AMAZON_MAPPINGS[product_name]
        asin = mapping["asin"]

        # Update URLs
        converted["url"] = create_amazon_url(asin)
        converted["product_url"] = create_amazon_url(asin)

        # Update image if we have it
        if mapping.get("image_id"):
            image_url = create_amazon_image_url(mapping["image_id"])
            converted["image"] = image_url
            converted["product_photo"] = image_url

        converted["source"] = "Amazon"

    return converted

def main():
    # Load products
    input_file = "/home/user/Doron/assets/jsons/fallback_products.json"
    output_file = "/home/user/Doron/scripts/affiliate/amazon_products.json"

    with open(input_file, 'r', encoding='utf-8') as f:
        products = json.load(f)

    print(f"Loaded {len(products)} products")

    # Convert products
    converted_products = [convert_product(p) for p in products]

    # Save converted products
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(converted_products, f, indent=2, ensure_ascii=False)

    print(f"Saved {len(converted_products)} products to {output_file}")

    # Count how many were converted
    amazon_count = sum(1 for p in converted_products if p.get("source") == "Amazon")
    print(f"Converted {amazon_count} products to Amazon links")

if __name__ == "__main__":
    main()
