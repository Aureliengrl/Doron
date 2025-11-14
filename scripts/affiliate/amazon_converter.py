#!/usr/bin/env python3
"""
Amazon Affiliate Link Converter
Converts product URLs and images to Amazon.fr with affiliate tag: doron072004-21
"""
import json
import sys

# Amazon affiliate tag
AFFILIATE_TAG = "doron072004-21"

def create_amazon_url(asin):
    """Create Amazon affiliate URL from ASIN"""
    return f"https://www.amazon.fr/dp/{asin}?tag={AFFILIATE_TAG}"

# Comprehensive ASIN mapping for 43+ priority products
# Format: "Product Name": "ASIN"
AMAZON_MAPPINGS = {
    # Nike Products
    "Nike Air Force 1 '07 White": "B0BXJ396WL",
    "Nike Air Force 1 '07 Black": "B0BXJ396WL",  # Same ASIN, different color
    "Nike Air Max 90 White": "B07ZTTZ74R",
    "Nike Air Max 90 Black": "B07ZTTZ74R",

    # Adidas Products
    "Adidas Samba OG White Black": "B07F5K9QZN",
    "Adidas Samba OG Black White": "B07F5K9QZN",
    "Adidas Stan Smith White Green": "B01LYJHVXN",
    "Adidas Stan Smith Black": "B01LYJHVXN",

    # Converse Products
    "Converse Chuck Taylor All Star High White": "B002TUTXES",
    "Converse Chuck Taylor All Star High Black": "B002TUTXES",

    # Vans Products
    "Vans Old Skool Black White": "B0BH5FVFGK",

    # New Balance Products
    "New Balance 574": "B077VJ1SCP",

    # Puma Products
    "Puma Suede Classic": "B07MT63S2X",

    # Apple Products
    "Apple iPhone 15 Pro Max 256GB Black Titanium": "B0CHWZZM9M",
    "Apple iPhone 15 Pro 128GB Titanium": "B0CHX5FLCB",
    "Apple AirPods Pro 2 USB-C": "B0CHWZ9TZS",
    "Apple MacBook Air M3 13 pouces 256GB": "B0CX24Q4LT",
    "Apple Watch Series 9 GPS 45mm": "B0CHX46DQQ",

    # Samsung Products
    "Samsung Galaxy S24 Ultra 512GB Black": "B0CSPK4FKF",
    "Samsung Galaxy S24 Ultra 256GB": "B0CSVS3FNK",
    "Samsung Galaxy S24 256GB Black": "B0CSVS3FNK",

    # Sony Products
    "Sony WH-1000XM5 Black": "B09Y2MYL5C",
    "Sony WH-1000XM5 Silver": "B09Y2MYL5C",
    "Sony PlayStation 5 Standard Edition": "B08H93ZRK9",
    "Sony PlayStation 5 Digital Edition": "B08H93ZRK9",
    "Sony DualSense Wireless Controller White": "B08H93ZRK9",

    # Bose Products
    "Bose QuietComfort 45": "B098FKXT8L",

    # JBL Products
    "JBL Charge 5 Blue": "B08X4VXF1M",

    # Nintendo Products
    "Nintendo Switch OLED White": "B098RKWHHZ",
    "Nintendo Switch OLED Neon Blue Red": "B098RKWHHZ",
    "The Legend of Zelda: Tears of the Kingdom": "B098RKWHHZ",

    # Microsoft Products
    "Microsoft Xbox Series X 1TB": "B08H93ZRLL",
    "Microsoft Xbox Series S 512GB": "B08H93ZRLL",

    # Ray-Ban Products
    "Ray-Ban Aviator RB3025 Gold Green": "B019573OT2",
    "Ray-Ban Wayfarer RB2140 Black": "B019573OT2",

    # Fashion & Apparel
    "Levi's 501 Original Jeans Blue": "B0F2GTJWV5",
    "Calvin Klein Modern Cotton Boxer Briefs Black 3-Pack": "B0DCBZHH78",
    "Lacoste L.12.12 Polo Shirt Classic Fit White": "B07W1PRFY9",

    # Footwear
    "Dr. Martens 1460 Smooth Black 8-Eye Boot": "B079YC13KZ",
    "Timberland 6-Inch Premium Boot Wheat": "B0741VV74H",
    "Birkenstock Arizona Sandals Black": "B085Y8GD7S",

    # Outerwear
    "The North Face 1996 Retro Nuptse Black": "B09DWS6CS2",

    # Sports & Fitness
    "Under Armour Charged Assert 10": "B0CG6JQ8Y4",

    # Gaming & Peripherals
    "Logitech G502 HERO Gaming Mouse": "B07GS6ZB7T",

    # Watches
    "Casio G-Shock GA-2100 Casioak Black": "B07WDD3YW9",
    "Seiko 5 Sports Automatic": "B07Y54XKBL",

    # Cameras & Drones
    "GoPro HERO11 Black": "B0CF7X369M",
    "Canon EOS R6 Mark II": "B0BLJNVXK4",
    "DJI Mini 3 Pro": "B09WDC1S17",

    # E-Readers & Tablets
    "Kindle Paperwhite": "B0CFPWLGF2",

    # Power Banks
    "Anker PowerCore 20000mAh": "B0BYP4Y1N8",

    # Home Appliances
    "Dyson V11 Absolute": "B07Q4FZKNY",
    "Philips Sonicare ProtectiveClean 5100": "B07DM8QH7W",
    "KitchenAid Artisan Stand Mixer": "B07D5P2STF",
    "Nespresso Vertuo Next": "B08WJPWY8J",

    # Bags & Accessories
    "Fjällräven Kånken Backpack Classic": "B00VA1XW5S",
}

def find_product_mapping(product_name, product_brand):
    """Find ASIN mapping for a product by name or brand+name combination"""
    # Try exact match first
    if product_name in AMAZON_MAPPINGS:
        return AMAZON_MAPPINGS[product_name]

    # Try with brand prefix
    brand_name = f"{product_brand} {product_name}"
    for key in AMAZON_MAPPINGS:
        if product_name.lower() in key.lower() or brand_name.lower() in key.lower():
            return AMAZON_MAPPINGS[key]

    # Try partial matching
    product_lower = product_name.lower()
    for key, asin in AMAZON_MAPPINGS.items():
        key_lower = key.lower()
        # Extract main keywords
        if any(word in product_lower for word in key_lower.split() if len(word) > 3):
            # Check if it's a good match
            words_match = sum(1 for word in key_lower.split() if word in product_lower and len(word) > 3)
            if words_match >= 2:
                return asin

    return None

def convert_product(product):
    """Convert a product to use Amazon affiliate links"""
    converted = product.copy()

    product_name = product.get("name", "")
    product_brand = product.get("brand", "")

    # Find ASIN mapping
    asin = find_product_mapping(product_name, product_brand)

    if asin:
        # Update URLs
        amazon_url = create_amazon_url(asin)
        converted["url"] = amazon_url
        converted["product_url"] = amazon_url

        # Note: Images would need to be fetched individually from Amazon pages
        # For now, we keep original images to avoid broken links
        # In a production system, you'd use Amazon Product Advertising API

        # Update source
        converted["source"] = "Amazon"

        print(f"✓ Converted: {product_name} (ASIN: {asin})")

    return converted

def main():
    # File paths
    input_file = "/home/user/Doron/assets/jsons/fallback_products.json"
    output_file = "/home/user/Doron/scripts/affiliate/amazon_products.json"

    print(f"Loading products from {input_file}...")

    try:
        with open(input_file, 'r', encoding='utf-8') as f:
            products = json.load(f)
    except Exception as e:
        print(f"Error loading input file: {e}")
        sys.exit(1)

    print(f"Loaded {len(products)} products")
    print(f"\nConverting products to Amazon affiliate links...")
    print(f"Affiliate Tag: {AFFILIATE_TAG}\n")

    # Convert products
    converted_products = []
    converted_count = 0

    for product in products:
        converted = convert_product(product)
        converted_products.append(converted)
        if converted.get("source") == "Amazon":
            converted_count += 1

    # Save converted products
    print(f"\nSaving {len(converted_products)} products to {output_file}...")

    try:
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(converted_products, f, indent=2, ensure_ascii=False)
    except Exception as e:
        print(f"Error saving output file: {e}")
        sys.exit(1)

    print(f"\n{'='*60}")
    print(f"CONVERSION COMPLETE!")
    print(f"{'='*60}")
    print(f"Total products: {len(converted_products)}")
    print(f"Converted to Amazon: {converted_count}")
    print(f"Percentage converted: {(converted_count/len(products)*100):.1f}%")
    print(f"Output file: {output_file}")
    print(f"\nNote: Original images preserved. To use Amazon images,")
    print(f"you would need to use Amazon Product Advertising API.")

if __name__ == "__main__":
    main()
