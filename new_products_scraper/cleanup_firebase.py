#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de Nettoyage Firebase pour DORÕN
Vérifie tous les produits et supprime ceux qui sont incomplets
Version: 1.0
"""

import time
import random
import re
from datetime import datetime
from urllib.parse import urlparse
import firebase_admin
from firebase_admin import credentials, firestore
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from bs4 import BeautifulSoup

# ============================================
# CONFIGURATION
# ============================================

FIREBASE_PROJECT_ID = "doron-b3011"
LOG_FILE = "cleanup_log.txt"

# Champs obligatoires pour qu'un produit soit valide
REQUIRED_FIELDS = {
    'name': lambda x: x and len(str(x).strip()) > 0,
    'brand': lambda x: x and len(str(x).strip()) > 0 and x != 'Unknown',
    'price': lambda x: x and (isinstance(x, (int, float)) and x > 0 or (isinstance(x, str) and float(x) > 0)),
    'image': lambda x: x and len(str(x).strip()) > 0 and str(x).startswith('http'),
    'url': lambda x: x and len(str(x).strip()) > 0 and str(x).startswith('http'),
}

# ============================================
# INITIALISATION
# ============================================

def init_firebase():
    """Initialise Firebase Admin SDK"""
    try:
        cred = credentials.Certificate('serviceAccountKey.json')
        firebase_admin.initialize_app(cred)
        db = firestore.client()
        print("✅ Firebase initialisé avec succès!")
        return db
    except Exception as e:
        print(f"❌ Erreur initialisation Firebase: {e}")
        return None

def init_selenium():
    """Initialise Selenium avec Chrome headless"""
    try:
        chrome_options = Options()
        chrome_options.add_argument("--headless")
        chrome_options.add_argument("--no-sandbox")
        chrome_options.add_argument("--disable-dev-shm-usage")
        chrome_options.add_argument("--disable-blink-features=AutomationControlled")
        chrome_options.add_argument("user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")

        driver = webdriver.Chrome(options=chrome_options)
        print("✅ Selenium initialisé avec succès!")
        return driver
    except Exception as e:
        print(f"❌ Erreur initialisation Selenium: {e}")
        return None

# ============================================
# VALIDATION DE PRODUITS
# ============================================

def validate_product(product_data, doc_id):
    """Vérifie si un produit a tous les champs requis"""
    missing_fields = []

    for field, validator in REQUIRED_FIELDS.items():
        value = product_data.get(field)
        if not validator(value):
            missing_fields.append(field)

    return len(missing_fields) == 0, missing_fields

# ============================================
# EXTRACTION DE DONNÉES AMÉLIORÉE
# ============================================

def extract_brand_from_url(url):
    """Extrait la marque depuis l'URL"""
    domain = urlparse(url).netloc.lower()

    brand_mapping = {
        'goldengoose': 'Golden Goose',
        'zara': 'Zara',
        'maje': 'Maje',
        'miumiu': 'Miu Miu',
        'rhode': 'Rhode',
        'sephora': 'Sephora',
        'lululemon': 'Lululemon',
        'messika': 'Messika',
        'backmarket': 'Back Market',
        'boulanger': 'Boulanger',
        'fnac': 'Fnac',
        'galerieslafayette': 'Galeries Lafayette',
        'ikea': 'Ikea',
        'maisonmargiela': 'Maison Margiela',
        'aloyoga': 'Alo Yoga',
        'zagbijoux': 'Zag Bijoux',
        'printemps': 'Printemps',
        'moonnude': 'Moon Nude',
        'rimowa': 'Rimowa',
    }

    for key, brand in brand_mapping.items():
        if key in domain:
            return brand

    return 'Unknown'

def scrape_product_enhanced(driver, url):
    """Scrape un produit avec des sélecteurs améliorés par site"""
    try:
        driver.get(url)
        time.sleep(random.uniform(4, 7))

        soup = BeautifulSoup(driver.page_source, 'html.parser')
        domain = urlparse(url).netloc.lower()

        # ========== NOM DU PRODUIT ==========
        name = None
        name_selectors = [
            # Meta tags (prioritaires)
            ('meta', {'property': 'og:title'}),
            ('meta', {'name': 'twitter:title'}),
            # Sélecteurs génériques
            ('h1', {'class': re.compile(r'product.*title|title.*product|product.*name', re.I)}),
            ('h1', {'data-testid': re.compile(r'product.*title|title', re.I)}),
            ('h1', {'itemprop': 'name'}),
            ('h1', {}),
            ('span', {'class': re.compile(r'product.*name', re.I)}),
        ]

        # Sélecteurs spécifiques par site
        if 'fnac' in domain:
            name_selectors.insert(0, ('h1', {'class': 'f-productHeader-Title'}))
        elif 'boulanger' in domain:
            name_selectors.insert(0, ('h1', {'class': 'product-title'}))
        elif 'galerieslafayette' in domain or 'printemps' in domain:
            name_selectors.insert(0, ('h1', {'class': 'ProductName'}))
        elif 'backmarket' in domain:
            name_selectors.insert(0, ('h1', {'data-qa': 'product-title'}))
        elif 'ikea' in domain:
            name_selectors.insert(0, ('h1', {'class': 'pip-header-section__title'}))

        for tag, attrs in name_selectors:
            element = soup.find(tag, attrs)
            if element:
                if tag == 'meta':
                    name = element.get('content', '').strip()
                else:
                    name = element.get_text(strip=True)
                if name and len(name) > 2:
                    break

        # ========== PRIX ==========
        price = None
        price_selectors = [
            ('meta', {'property': 'og:price:amount'}),
            ('meta', {'property': 'product:price:amount'}),
            ('span', {'class': re.compile(r'price|prix', re.I)}),
            ('div', {'class': re.compile(r'price|prix', re.I)}),
            ('p', {'class': re.compile(r'price|prix', re.I)}),
            ('span', {'data-testid': 'price'}),
            ('span', {'itemprop': 'price'}),
        ]

        # Sélecteurs spécifiques par site
        if 'fnac' in domain:
            price_selectors.insert(0, ('div', {'class': 'f-priceBox-price'}))
        elif 'boulanger' in domain:
            price_selectors.insert(0, ('span', {'class': 'price'}))
        elif 'galerieslafayette' in domain or 'printemps' in domain:
            price_selectors.insert(0, ('span', {'class': 'ProductPrice'}))
        elif 'backmarket' in domain:
            price_selectors.insert(0, ('div', {'data-qa': 'price'}))

        for tag, attrs in price_selectors:
            elements = soup.find_all(tag, attrs) if tag != 'meta' else [soup.find(tag, attrs)]
            for element in elements:
                if not element:
                    continue

                if tag == 'meta':
                    text = element.get('content', '')
                else:
                    text = element.get_text(strip=True)

                # Chercher un pattern de prix
                price_match = re.search(r'(\d+[\s,.]?\d*)[.,](\d{2})', text)
                if price_match:
                    price_str = price_match.group(0).replace(',', '.').replace(' ', '')
                    try:
                        price = float(price_str)
                        break
                    except:
                        continue

                # Pattern sans centimes
                if not price:
                    price_match = re.search(r'(\d+)', text)
                    if price_match:
                        try:
                            price = float(price_match.group(1))
                            break
                        except:
                            continue

            if price and price > 0:
                break

        # ========== IMAGE ==========
        image_url = None

        # Méthode 1: Meta tags
        image_selectors = [
            ('meta', {'property': 'og:image'}),
            ('meta', {'name': 'twitter:image'}),
            ('meta', {'itemprop': 'image'}),
        ]

        for tag, attrs in image_selectors:
            element = soup.find(tag, attrs)
            if element:
                image_url = element.get('content', '')
                if image_url and image_url.startswith('http'):
                    break

        # Méthode 2: Images du produit
        if not image_url:
            img_selectors = [
                ('img', {'class': re.compile(r'product.*image|main.*image|hero.*image', re.I)}),
                ('img', {'data-testid': re.compile(r'product.*image|image', re.I)}),
                ('img', {'itemprop': 'image'}),
                ('img', {'id': re.compile(r'product.*image|main.*image', re.I)}),
            ]

            for tag, attrs in img_selectors:
                img = soup.find(tag, attrs)
                if img:
                    image_url = img.get('src') or img.get('data-src') or img.get('data-original') or img.get('data-lazy')
                    if image_url:
                        # Nettoyer l'URL
                        if image_url.startswith('//'):
                            image_url = 'https:' + image_url
                        elif image_url.startswith('/'):
                            parsed = urlparse(url)
                            image_url = f"{parsed.scheme}://{parsed.netloc}{image_url}"

                        if image_url.startswith('http'):
                            break

        # ========== DESCRIPTION ==========
        description = None
        desc_selectors = [
            ('meta', {'property': 'og:description'}),
            ('meta', {'name': 'description'}),
            ('div', {'class': re.compile(r'description|product.*desc', re.I)}),
            ('p', {'class': re.compile(r'description', re.I)}),
        ]

        for tag, attrs in desc_selectors:
            element = soup.find(tag, attrs)
            if element:
                if tag == 'meta':
                    description = element.get('content', '').strip()
                else:
                    description = element.get_text(strip=True)

                if description and len(description) > 20:
                    description = description[:500]
                    break

        return {
            'name': name,
            'price': price,
            'image': image_url,
            'description': description
        }

    except Exception as e:
        print(f"      ❌ Erreur scraping: {e}")
        return None

# ============================================
# FONCTION PRINCIPALE DE NETTOYAGE
# ============================================

def cleanup_firebase():
    """Nettoie Firebase: supprime ou complète les produits incomplets"""

    print("=" * 70)
    print("🧹 NETTOYAGE FIREBASE - PRODUITS INCOMPLETS")
    print("=" * 70)
    print()

    # Initialiser Firebase
    db = init_firebase()
    if not db:
        print("❌ Impossible de continuer sans Firebase!")
        return

    # Initialiser Selenium
    driver = init_selenium()
    if not driver:
        print("❌ Impossible de continuer sans Selenium!")
        return

    # Ouvrir le fichier de log
    with open(LOG_FILE, 'w', encoding='utf-8') as log:
        log.write(f"{'='*70}\n")
        log.write(f"NETTOYAGE FIREBASE DÉMARRÉ: {datetime.now()}\n")
        log.write(f"{'='*70}\n\n")

        # Récupérer tous les produits
        print("📥 Récupération de tous les produits Firebase...")
        gifts_ref = db.collection('gifts')
        all_products = gifts_ref.stream()

        products_list = list(all_products)
        total_products = len(products_list)

        print(f"📊 {total_products} produits trouvés dans Firebase\n")
        log.write(f"Total de produits: {total_products}\n\n")

        valid_count = 0
        incomplete_count = 0
        fixed_count = 0
        deleted_count = 0

        # Analyser chaque produit
        for index, doc in enumerate(products_list, 1):
            doc_id = doc.id
            product_data = doc.to_dict()

            print(f"\n[{index}/{total_products}] 🔍 Analyse: {doc_id}")
            log.write(f"\n[{index}/{total_products}] Document ID: {doc_id}\n")

            # Afficher les infos du produit
            product_name = product_data.get('name', 'Sans nom')
            product_url = product_data.get('url', 'Pas d\'URL')

            print(f"   📝 Nom: {product_name[:50]}...")
            log.write(f"   Nom: {product_name}\n")
            log.write(f"   URL: {product_url}\n")

            # Valider le produit
            is_valid, missing_fields = validate_product(product_data, doc_id)

            if is_valid:
                print(f"   ✅ Produit VALIDE (tous les champs présents)")
                log.write(f"   ✅ VALIDE\n")
                valid_count += 1
                continue

            # Produit incomplet
            print(f"   ⚠️  Produit INCOMPLET - Champs manquants: {', '.join(missing_fields)}")
            log.write(f"   ⚠️ INCOMPLET - Champs manquants: {', '.join(missing_fields)}\n")
            incomplete_count += 1

            # Afficher les valeurs actuelles
            for field in missing_fields:
                current_value = product_data.get(field, 'NULL')
                print(f"      - {field}: {current_value}")
                log.write(f"      - {field}: {current_value}\n")

            # Essayer de re-scraper si on a une URL
            product_url = product_data.get('url')
            if not product_url or not product_url.startswith('http'):
                print(f"   ❌ Pas d'URL valide - SUPPRESSION")
                log.write(f"   ❌ SUPPRESSION (pas d'URL)\n")

                try:
                    db.collection('gifts').document(doc_id).delete()
                    deleted_count += 1
                    print(f"   🗑️  Produit supprimé de Firebase")
                    log.write(f"   🗑️ SUPPRIMÉ\n")
                except Exception as e:
                    print(f"   ❌ Erreur suppression: {e}")
                    log.write(f"   ❌ Erreur suppression: {e}\n")

                continue

            # Tenter le re-scraping
            print(f"   🔄 Tentative de re-scraping...")
            log.write(f"   🔄 Re-scraping...\n")

            new_data = scrape_product_enhanced(driver, product_url)

            if not new_data:
                print(f"   ❌ Re-scraping échoué - SUPPRESSION")
                log.write(f"   ❌ SUPPRESSION (re-scraping échoué)\n")

                try:
                    db.collection('gifts').document(doc_id).delete()
                    deleted_count += 1
                    print(f"   🗑️  Produit supprimé de Firebase")
                    log.write(f"   🗑️ SUPPRIMÉ\n")
                except Exception as e:
                    print(f"   ❌ Erreur suppression: {e}")
                    log.write(f"   ❌ Erreur suppression: {e}\n")

                continue

            # Mettre à jour les champs manquants
            updated_data = {}
            all_fixed = True

            for field in missing_fields:
                if field == 'name' and new_data.get('name'):
                    updated_data['name'] = new_data['name']
                    updated_data['product_title'] = new_data['name']
                elif field == 'price' and new_data.get('price'):
                    updated_data['price'] = new_data['price']
                    updated_data['product_price'] = str(new_data['price'])
                elif field == 'image' and new_data.get('image'):
                    updated_data['image'] = new_data['image']
                    updated_data['product_photo'] = new_data['image']
                elif field == 'brand':
                    brand = extract_brand_from_url(product_url)
                    if brand != 'Unknown':
                        updated_data['brand'] = brand
                    else:
                        all_fixed = False
                else:
                    all_fixed = False

            # Vérifier si tous les champs ont été fixés
            if not all_fixed or len(updated_data) < len(missing_fields):
                print(f"   ❌ Impossible de récupérer tous les champs - SUPPRESSION")
                log.write(f"   ❌ SUPPRESSION (données incomplètes)\n")

                try:
                    db.collection('gifts').document(doc_id).delete()
                    deleted_count += 1
                    print(f"   🗑️  Produit supprimé de Firebase")
                    log.write(f"   🗑️ SUPPRIMÉ\n")
                except Exception as e:
                    print(f"   ❌ Erreur suppression: {e}")
                    log.write(f"   ❌ Erreur suppression: {e}\n")

                continue

            # Mettre à jour le produit dans Firebase
            try:
                db.collection('gifts').document(doc_id).update(updated_data)
                fixed_count += 1
                print(f"   ✅ Produit CORRIGÉ et mis à jour")
                log.write(f"   ✅ CORRIGÉ - Champs mis à jour: {', '.join(updated_data.keys())}\n")

                for field, value in updated_data.items():
                    if field in missing_fields:
                        print(f"      ✓ {field}: {str(value)[:60]}")
                        log.write(f"      ✓ {field}: {str(value)[:100]}\n")

            except Exception as e:
                print(f"   ❌ Erreur mise à jour: {e}")
                log.write(f"   ❌ Erreur mise à jour: {e}\n")

            # Pause anti-blocage
            time.sleep(random.uniform(2, 4))

        # Résumé final
        print("\n")
        print("=" * 70)
        print("📊 RÉSULTATS DU NETTOYAGE:")
        print(f"   📦 Total de produits analysés: {total_products}")
        print(f"   ✅ Produits valides: {valid_count}")
        print(f"   ⚠️  Produits incomplets trouvés: {incomplete_count}")
        print(f"   🔧 Produits corrigés: {fixed_count}")
        print(f"   🗑️  Produits supprimés: {deleted_count}")
        print(f"   📈 Taux de produits valides: {((valid_count + fixed_count) / total_products * 100):.1f}%")
        print("=" * 70)

        log.write(f"\n\n{'='*70}\n")
        log.write(f"RÉSUMÉ FINAL:\n")
        log.write(f"   Total analysés: {total_products}\n")
        log.write(f"   Valides: {valid_count}\n")
        log.write(f"   Incomplets: {incomplete_count}\n")
        log.write(f"   Corrigés: {fixed_count}\n")
        log.write(f"   Supprimés: {deleted_count}\n")
        log.write(f"   Taux de validité: {((valid_count + fixed_count) / total_products * 100):.1f}%\n")
        log.write(f"{'='*70}\n")

    # Fermer le navigateur
    driver.quit()
    print(f"\n🎉 NETTOYAGE TERMINÉ!")
    print(f"📝 Logs sauvegardés dans: {LOG_FILE}")

# ============================================
# POINT D'ENTRÉE
# ============================================

if __name__ == "__main__":
    cleanup_firebase()
