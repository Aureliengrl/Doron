#!/usr/bin/env python3
"""
Validate a sample of generated products to check if URLs work
"""

import json
import requests
import random

def validate_product(product):
    """Validate a single product"""
    session = requests.Session()
    session.headers.update({
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
    })

    print(f"\n🔍 Testing: {product['brand']} - {product['title']}")

    # Test image URL
    try:
        img_response = session.head(product['imageUrl'], timeout=5, allow_redirects=True)
        img_status = img_response.status_code
        print(f"   Image: {img_status} - {'✅' if img_status in [200, 301, 302] else '❌'}")
    except Exception as e:
        print(f"   Image: ❌ Error - {e}")
        img_status = 0

    # Test product URL
    try:
        prod_response = session.head(product['productUrl'], timeout=5, allow_redirects=True)
        prod_status = prod_response.status_code
        print(f"   Product: {prod_status} - {'✅' if prod_status in [200, 301, 302, 405] else '❌'}")
    except Exception as e:
        print(f"   Product: ❌ Error - {e}")
        prod_status = 0

    return img_status in [200, 301, 302] and prod_status in [200, 301, 302, 405]

# Load products
with open('/home/user/Doron/scripts/real_products.json', 'r') as f:
    products = json.load(f)

print(f"📊 Total products: {len(products)}")
print("\n🧪 Testing random sample of 10 products...\n")

# Test random sample
sample = random.sample(products, min(10, len(products)))
valid_count = 0

for product in sample:
    if validate_product(product):
        valid_count += 1

print(f"\n📊 Results: {valid_count}/{len(sample)} products have working URLs")
print(f"   Success rate: {valid_count/len(sample)*100:.1f}%")
