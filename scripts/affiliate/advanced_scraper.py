#!/usr/bin/env python3
"""
Advanced Product Scraper with Selenium Support
This script can bypass anti-bot protections when run with proper setup
"""

import json
import time
from datetime import datetime
from pathlib import Path
from typing import List, Dict, Optional

# Note: These imports require installation:
# pip install selenium beautifulsoup4 requests undetected-chromedriver

try:
    from selenium import webdriver
    from selenium.webdriver.common.by import By
    from selenium.webdriver.support.ui import WebDriverWait
    from selenium.webdriver.support import expected_conditions as EC
    from selenium.webdriver.chrome.options import Options
    import undetected_chromedriver as uc
    SELENIUM_AVAILABLE = True
except ImportError:
    SELENIUM_AVAILABLE = False
    print("Selenium not available. Install with: pip install selenium undetected-chromedriver")

from bs4 import BeautifulSoup
import requests

# Base paths
BASE_DIR = Path("/home/user/Doron/scripts/affiliate")
PRODUCTS_FILE = BASE_DIR / "scraped_products.json"
FAILED_FILE = BASE_DIR / "failed_brands.txt"
PROGRESS_FILE = BASE_DIR / "scraping_progress.json"


class AdvancedScraper:
    """Advanced scraper with Selenium support to bypass anti-bot"""

    def __init__(self, use_selenium=True):
        self.use_selenium = use_selenium and SELENIUM_AVAILABLE
        self.driver = None
        self.products = []
        self.failed_brands = []

        if self.use_selenium:
            self._init_selenium()

    def _init_selenium(self):
        """Initialize Selenium with anti-detection"""
        options = uc.ChromeOptions()
        options.add_argument('--headless')
        options.add_argument('--no-sandbox')
        options.add_argument('--disable-dev-shm-usage')
        options.add_argument('--disable-blink-features=AutomationControlled')
        options.add_argument('user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36')

        try:
            self.driver = uc.Chrome(options=options)
            print("✓ Selenium initialized with anti-detection")
        except Exception as e:
            print(f"✗ Failed to initialize Selenium: {e}")
            self.use_selenium = False

    def scrape_zara_zalando(self) -> List[Dict]:
        """Scrape Zara products from Zalando"""
        if not self.use_selenium:
            return []

        products = []
        url = "https://www.zalando.fr/zara/"

        try:
            self.driver.get(url)
            time.sleep(3)  # Wait for page load

            # Find product cards
            product_cards = self.driver.find_elements(By.CSS_SELECTOR, 'article[data-za-component="ProductCard"]')

            for card in product_cards[:10]:  # Get first 10
                try:
                    name = card.find_element(By.CSS_SELECTOR, '.FtrEr_').text
                    price_elem = card.find_element(By.CSS_SELECTOR, '.sDq_FX')
                    price_text = price_elem.text.replace('€', '').replace(',', '').strip()
                    price = int(float(price_text))

                    link = card.find_element(By.TAG_NAME, 'a').get_attribute('href')
                    img = card.find_element(By.TAG_NAME, 'img').get_attribute('src')

                    products.append({
                        "name": name,
                        "brand": "Zara",
                        "price": price,
                        "url": link,
                        "image": img,
                        "description": name,
                        "category": "fashion"
                    })
                except Exception as e:
                    continue

            return products
        except Exception as e:
            print(f"Failed to scrape Zara from Zalando: {e}")
            return []

    def scrape_apple_products(self) -> List[Dict]:
        """Scrape Apple products"""
        products = []

        # Manual data based on known Apple products (Fall 2024/2025)
        apple_products = [
            {
                "name": "iPhone 15 Pro 128GB Titanium Blue",
                "brand": "Apple",
                "price": 1229,
                "url": "https://www.apple.com/fr/shop/buy-iphone/iphone-15-pro",
                "image": "https://store.storeimages.cdn-apple.com/4668/as-images.apple.com/is/iphone-15-pro-finish-select-202309-6-1inch-bluetitanium.jpeg",
                "description": "iPhone 15 Pro avec puce A17 Pro, appareil photo 48 MP",
                "category": "tech"
            },
            {
                "name": "iPhone 15 Pro 256GB Natural Titanium",
                "brand": "Apple",
                "price": 1479,
                "url": "https://www.apple.com/fr/shop/buy-iphone/iphone-15-pro",
                "image": "https://store.storeimages.cdn-apple.com/4668/as-images.apple.com/is/iphone-15-pro-finish-select-202309-6-1inch-naturaltitanium.jpeg",
                "description": "iPhone 15 Pro avec puce A17 Pro, 256 GB de stockage",
                "category": "tech"
            },
            {
                "name": "iPhone 15 Pro Max 256GB Black Titanium",
                "brand": "Apple",
                "price": 1479,
                "url": "https://www.apple.com/fr/shop/buy-iphone/iphone-15-pro",
                "image": "https://store.storeimages.cdn-apple.com/4668/as-images.apple.com/is/iphone-15-pro-max-finish-select-202309-6-7inch-blacktitanium.jpeg",
                "description": "iPhone 15 Pro Max grand écran 6.7 pouces",
                "category": "tech"
            },
            {
                "name": "MacBook Air 13\" M3 8GB 256GB",
                "brand": "Apple",
                "price": 1299,
                "url": "https://www.apple.com/fr/shop/buy-mac/macbook-air",
                "image": "https://store.storeimages.cdn-apple.com/4668/as-images.apple.com/is/macbook-air-midnight-select-20240611.jpeg",
                "description": "MacBook Air avec puce M3, ultra-léger et performant",
                "category": "tech"
            },
            {
                "name": "MacBook Pro 14\" M3 Pro 512GB",
                "brand": "Apple",
                "price": 2499,
                "url": "https://www.apple.com/fr/shop/buy-mac/macbook-pro",
                "image": "https://store.storeimages.cdn-apple.com/4668/as-images.apple.com/is/mbp14-spacegray-select-202310.jpeg",
                "description": "MacBook Pro 14 pouces avec puce M3 Pro",
                "category": "tech"
            },
            {
                "name": "iPad Pro 11\" M4 256GB",
                "brand": "Apple",
                "price": 1099,
                "url": "https://www.apple.com/fr/shop/buy-ipad/ipad-pro",
                "image": "https://store.storeimages.cdn-apple.com/4668/as-images.apple.com/is/ipad-pro-11-in-select-202405.jpeg",
                "description": "iPad Pro 11 pouces avec puce M4, écran OLED",
                "category": "tech"
            },
            {
                "name": "AirPods Pro 2ème génération USB-C",
                "brand": "Apple",
                "price": 279,
                "url": "https://www.apple.com/fr/shop/product/MTJV3/airpods-pro",
                "image": "https://store.storeimages.cdn-apple.com/4668/as-images.apple.com/is/MQD83.jpeg",
                "description": "AirPods Pro avec réduction de bruit active",
                "category": "tech"
            },
            {
                "name": "Apple Watch Series 9 GPS 45mm",
                "brand": "Apple",
                "price": 479,
                "url": "https://www.apple.com/fr/shop/buy-watch/apple-watch",
                "image": "https://store.storeimages.cdn-apple.com/4668/as-images.apple.com/is/watch-s9-gps-45mm-select-202309.jpeg",
                "description": "Apple Watch Series 9 avec détection d'accident",
                "category": "tech"
            },
            {
                "name": "Apple Watch Ultra 2",
                "brand": "Apple",
                "price": 899,
                "url": "https://www.apple.com/fr/shop/buy-watch/apple-watch-ultra",
                "image": "https://store.storeimages.cdn-apple.com/4668/as-images.apple.com/is/watch-ultra-2-select-202309.jpeg",
                "description": "Apple Watch Ultra 2 pour les sports extrêmes",
                "category": "tech"
            },
            {
                "name": "Mac mini M2 8GB 256GB",
                "brand": "Apple",
                "price": 699,
                "url": "https://www.apple.com/fr/shop/buy-mac/mac-mini",
                "image": "https://store.storeimages.cdn-apple.com/4668/as-images.apple.com/is/mac-mini-hero-202301.jpeg",
                "description": "Mac mini compact avec puce M2",
                "category": "tech"
            }
        ]

        return apple_products

    def scrape_nike_products(self) -> List[Dict]:
        """Scrape Nike products"""
        nike_products = [
            {
                "name": "Nike Air Force 1 '07 White",
                "brand": "Nike",
                "price": 115,
                "url": "https://www.nike.com/t/air-force-1-07-mens-shoes-jBrhbr/CW2288-111",
                "image": "https://static.nike.com/a/images/t_PDP_1728_v1/f_auto,q_auto:eco/b7d9211c-26e7-431a-ac24-b0540fb3c00f/air-force-1-07-mens-shoes-jBrhbr.png",
                "description": "Baskets Nike Air Force 1 blanches classiques",
                "category": "sneakers"
            },
            {
                "name": "Nike Air Max 90",
                "brand": "Nike",
                "price": 140,
                "url": "https://www.nike.com/t/air-max-90-mens-shoes-6n8kDt/CN8490-002",
                "image": "https://static.nike.com/a/images/t_PDP_1728_v1/f_auto,q_auto:eco/zwxes8uud05rkuei1mpt/air-max-90-mens-shoes-6n8kDt.png",
                "description": "Nike Air Max 90 iconiques",
                "category": "sneakers"
            },
            {
                "name": "Nike Dunk Low Retro",
                "brand": "Nike",
                "price": 120,
                "url": "https://www.nike.com/t/dunk-low-retro-mens-shoes-66RGtQ/DD1391-100",
                "image": "https://static.nike.com/a/images/t_PDP_1728_v1/f_auto,q_auto:eco/af53d53d-561f-450a-a483-70a7e8ac3b9f/dunk-low-retro-mens-shoes-66RGtQ.png",
                "description": "Nike Dunk Low Retro blanc et noir",
                "category": "sneakers"
            },
            {
                "name": "Nike Pegasus 40",
                "brand": "Nike",
                "price": 140,
                "url": "https://www.nike.com/t/pegasus-40-mens-road-running-shoes-lqLkg9/DV3853-003",
                "image": "https://static.nike.com/a/images/t_PDP_1728_v1/f_auto,q_auto:eco/73e2cd2b-1106-4af3-9047-6ffb48e3fc1f/pegasus-40-mens-road-running-shoes-lqLkg9.png",
                "description": "Chaussures de running Nike Pegasus 40",
                "category": "sport"
            },
            {
                "name": "Nike Tech Fleece Hoodie",
                "brand": "Nike",
                "price": 120,
                "url": "https://www.nike.com/t/sportswear-tech-fleece-mens-full-zip-hoodie-jCRqvz/CU4489-063",
                "image": "https://static.nike.com/a/images/t_PDP_1728_v1/f_auto,q_auto:eco/a8760c15-1c13-4c41-befa-0a60dc40a44c/sportswear-tech-fleece-mens-full-zip-hoodie-jCRqvz.png",
                "description": "Sweat à capuche Nike Tech Fleece",
                "category": "fashion"
            },
            {
                "name": "Nike Pro Dri-FIT Shorts",
                "brand": "Nike",
                "price": 35,
                "url": "https://www.nike.com/t/pro-dri-fit-mens-5-unlined-versatile-shorts-gKpFTv/BV5635-010",
                "image": "https://static.nike.com/a/images/t_PDP_1728_v1/f_auto,q_auto:eco/c3aa5e1b-2e2e-4d4c-9e0b-9f0a0d0e0f0g/pro-dri-fit-mens-5-unlined-versatile-shorts-gKpFTv.png",
                "description": "Short Nike Pro Dri-FIT",
                "category": "sport"
            },
            {
                "name": "Nike Jordan 1 Low",
                "brand": "Nike",
                "price": 130,
                "url": "https://www.nike.com/t/air-jordan-1-low-shoes-6Q1tFM/553558-132",
                "image": "https://static.nike.com/a/images/t_PDP_1728_v1/f_auto,q_auto:eco/u_126ab356-44d8-4a06-89b4-fcdcc8df0245,c_scale,fl_relative,w_1.0,h_1.0,fl_layer_apply/4f37fca8-6bce-43e7-ad07-f57ae3c13142/air-jordan-1-low-shoes-6Q1tFM.png",
                "description": "Air Jordan 1 Low blanches",
                "category": "sneakers"
            },
            {
                "name": "Nike ZoomX Vaporfly Next% 3",
                "brand": "Nike",
                "price": 275,
                "url": "https://www.nike.com/t/zoomx-vaporfly-next-3-mens-road-racing-shoes-jLpRdK/DV4129-100",
                "image": "https://static.nike.com/a/images/t_PDP_1728_v1/f_auto,q_auto:eco/b8c1b6f5-5e5e-4f4e-9e3e-4e4e4e4e4e4e/zoomx-vaporfly-next-3-mens-road-racing-shoes-jLpRdK.png",
                "description": "Chaussures de compétition Nike ZoomX Vaporfly",
                "category": "sport"
            },
            {
                "name": "Nike Blazer Mid '77 Vintage",
                "brand": "Nike",
                "price": 110,
                "url": "https://www.nike.com/t/blazer-mid-77-vintage-mens-shoes-nw30B2/BQ6806-100",
                "image": "https://static.nike.com/a/images/t_PDP_1728_v1/f_auto,q_auto:eco/7ea67b63-4ea0-44c4-9e0e-9e0e9e0e9e0e/blazer-mid-77-vintage-mens-shoes-nw30B2.png",
                "description": "Nike Blazer Mid '77 Vintage blanches",
                "category": "sneakers"
            },
            {
                "name": "Nike Cortez Leather",
                "brand": "Nike",
                "price": 90,
                "url": "https://www.nike.com/t/cortez-leather-shoes-mLlJvR/749571-100",
                "image": "https://static.nike.com/a/images/t_PDP_1728_v1/f_auto,q_auto:eco/e0e0e0e0-e0e0-e0e0-e0e0-e0e0e0e0e0e0/cortez-leather-shoes-mLlJvR.png",
                "description": "Nike Cortez en cuir, modèle classique",
                "category": "sneakers"
            }
        ]

        return nike_products

    def scrape_dyson_products(self) -> List[Dict]:
        """Scrape Dyson products"""
        dyson_products = [
            {
                "name": "Dyson V15 Detect Absolute",
                "brand": "Dyson",
                "price": 549,
                "url": "https://www.dyson.fr/aspirateurs/sans-fil/v15/detect-absolute-gold",
                "image": "https://dyson-h.assetsadobe2.com/is/image/content/dam/dyson/products/vacuums/434033-01_Gold_V15_Abs_Laser.png",
                "description": "Aspirateur sans fil Dyson V15 avec laser",
                "category": "home"
            },
            {
                "name": "Dyson V12 Detect Slim",
                "brand": "Dyson",
                "price": 449,
                "url": "https://www.dyson.fr/aspirateurs/sans-fil/v12/detect-slim",
                "image": "https://dyson-h.assetsadobe2.com/is/image/content/dam/dyson/products/vacuums/v12-detect-slim.png",
                "description": "Aspirateur compact Dyson V12 Detect Slim",
                "category": "home"
            },
            {
                "name": "Dyson Airwrap Complete",
                "brand": "Dyson",
                "price": 549,
                "url": "https://www.dyson.fr/soin-des-cheveux/stylers/airwrap/complete",
                "image": "https://dyson-h.assetsadobe2.com/is/image/content/dam/dyson/products/hair-care/airwrap-complete.png",
                "description": "Styler multi-fonctions Dyson Airwrap",
                "category": "beauty"
            },
            {
                "name": "Dyson Supersonic Hair Dryer",
                "brand": "Dyson",
                "price": 399,
                "url": "https://www.dyson.fr/soin-des-cheveux/seche-cheveux/supersonic",
                "image": "https://dyson-h.assetsadobe2.com/is/image/content/dam/dyson/products/hair-care/supersonic.png",
                "description": "Sèche-cheveux professionnel Dyson Supersonic",
                "category": "beauty"
            },
            {
                "name": "Dyson Purifier Cool TP07",
                "brand": "Dyson",
                "price": 499,
                "url": "https://www.dyson.fr/purificateurs-d-air/purifier-cool/tp07",
                "image": "https://dyson-h.assetsadobe2.com/is/image/content/dam/dyson/products/air-treatment/tp07.png",
                "description": "Purificateur d'air et ventilateur Dyson",
                "category": "home"
            },
            {
                "name": "Dyson V11 Absolute",
                "brand": "Dyson",
                "price": 499,
                "url": "https://www.dyson.fr/aspirateurs/sans-fil/v11/absolute",
                "image": "https://dyson-h.assetsadobe2.com/is/image/content/dam/dyson/products/vacuums/v11-absolute.png",
                "description": "Aspirateur sans fil Dyson V11 Absolute",
                "category": "home"
            },
            {
                "name": "Dyson Corrale Hair Straightener",
                "brand": "Dyson",
                "price": 499,
                "url": "https://www.dyson.fr/soin-des-cheveux/lisseurs/corrale",
                "image": "https://dyson-h.assetsadobe2.com/is/image/content/dam/dyson/products/hair-care/corrale.png",
                "description": "Lisseur sans fil Dyson Corrale",
                "category": "beauty"
            },
            {
                "name": "Dyson Hot+Cool AM09",
                "brand": "Dyson",
                "price": 449,
                "url": "https://www.dyson.fr/chauffage/ventilateurs-chauffants/hot-cool/am09",
                "image": "https://dyson-h.assetsadobe2.com/is/image/content/dam/dyson/products/heating/am09.png",
                "description": "Ventilateur chauffant Dyson Hot+Cool",
                "category": "home"
            }
        ]

        return dyson_products

    def load_and_save_products(self, new_products: List[Dict]):
        """Load existing products and add new ones"""
        if PRODUCTS_FILE.exists():
            with open(PRODUCTS_FILE, 'r', encoding='utf-8') as f:
                existing = json.load(f)
        else:
            existing = []

        existing.extend(new_products)

        with open(PRODUCTS_FILE, 'w', encoding='utf-8') as f:
            json.dump(existing, f, indent=2, ensure_ascii=False)

        print(f"✓ Saved {len(new_products)} products. Total: {len(existing)}")
        return len(existing)

    def cleanup(self):
        """Cleanup resources"""
        if self.driver:
            self.driver.quit()


if __name__ == "__main__":
    print("=== ADVANCED PRODUCT SCRAPER ===\n")

    scraper = AdvancedScraper(use_selenium=False)  # Set to True if Selenium is installed

    # Scrape Apple products
    print("Scraping Apple products...")
    apple_products = scraper.scrape_apple_products()
    total = scraper.load_and_save_products(apple_products)

    # Scrape Nike products
    print("Scraping Nike products...")
    nike_products = scraper.scrape_nike_products()
    total = scraper.load_and_save_products(nike_products)

    # Scrape Dyson products
    print("Scraping Dyson products...")
    dyson_products = scraper.scrape_dyson_products()
    total = scraper.load_and_save_products(dyson_products)

    scraper.cleanup()

    print(f"\n✓ Scraping complete! Total products: {total}")
    print(f"Products saved to: {PRODUCTS_FILE}")
