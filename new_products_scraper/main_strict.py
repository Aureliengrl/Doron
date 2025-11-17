#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de Scraping STRICT des Produits pour DORÕN
Version 2.0 - ULTRA STRICT
- Upload SEULEMENT les produits 100% complets
- Supprime les produits si données manquantes
- 3 tentatives de scraping par produit
"""

import csv
import time
import random
import re
from datetime import datetime
from urllib.parse import urlparse
import firebase_admin
from firebase_admin import credentials, firestore
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from bs4 import BeautifulSoup

# ============================================
# CONFIGURATION
# ============================================

FIREBASE_PROJECT_ID = "doron-b3011"
CSV_FILE = "links.csv"
LOG_FILE = "scraping_strict_log.txt"

# Nombre de tentatives de scraping par produit
MAX_RETRIES = 3

# ============================================
# INITIALISATION FIREBASE
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
        print("\n⚠️ IMPORTANT: Assurez-vous que serviceAccountKey.json est présent!")
        return None

# ============================================
# INITIALISATION SELENIUM
# ============================================

def init_selenium():
    """Initialise Selenium avec Chrome headless"""
    try:
        chrome_options = Options()
        chrome_options.add_argument("--headless")
        chrome_options.add_argument("--no-sandbox")
        chrome_options.add_argument("--disable-dev-shm-usage")
        chrome_options.add_argument("--disable-blink-features=AutomationControlled")
        chrome_options.add_argument("user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")

        driver = webdriver.Chrome(options=chrome_options)
        print("✅ Selenium initialisé avec succès!")
        return driver
    except Exception as e:
        print(f"❌ Erreur initialisation Selenium: {e}")
        return None

# ============================================
# EXTRACTION DE MARQUE
# ============================================

def extract_brand_from_url(url):
    """Extrait la marque depuis l'URL - STRICT"""
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

    # Si la marque n'est pas reconnue, retourner None pour forcer l'échec
    return None

# ============================================
# EXTRACTION DE DONNÉES - ULTRA PRÉCISE
# ============================================

def extract_product_data_strict(driver, url, attempt=1):
    """Extrait les données du produit avec sélecteurs ultra-précis par site"""
    try:
        print(f"      🔍 Tentative {attempt}/{MAX_RETRIES}")

        # Charger la page
        driver.get(url)
        time.sleep(random.uniform(4, 7))  # Délai anti-blocage

        # Parser le HTML
        soup = BeautifulSoup(driver.page_source, 'html.parser')
        domain = urlparse(url).netloc.lower()

        # ========== EXTRACTION DU NOM ==========
        name = None
        name_selectors = []

        # Sélecteurs spécifiques par site (prioritaires)
        if 'messika' in domain:
            name_selectors = [
                ('h1', {'class': 'product-name'}),
                ('h1', {'class': 'title'}),
                ('meta', {'property': 'og:title'}),
            ]
        elif 'backmarket' in domain:
            name_selectors = [
                ('h1', {'data-qa': 'product-title'}),
                ('h1', {'class': re.compile(r'title', re.I)}),
                ('meta', {'property': 'og:title'}),
            ]
        elif 'boulanger' in domain:
            name_selectors = [
                ('h1', {'class': 'product-title'}),
                ('h1', {'itemprop': 'name'}),
                ('meta', {'property': 'og:title'}),
            ]
        elif 'fnac' in domain:
            name_selectors = [
                ('h1', {'class': 'f-productHeader-Title'}),
                ('h1', {'data-testid': 'product-title'}),
                ('meta', {'property': 'og:title'}),
            ]
        elif 'galerieslafayette' in domain or 'printemps' in domain:
            name_selectors = [
                ('h1', {'class': 'ProductName'}),
                ('h1', {'class': re.compile(r'product.*name', re.I)}),
                ('meta', {'property': 'og:title'}),
            ]
        elif 'ikea' in domain:
            name_selectors = [
                ('h1', {'class': 'pip-header-section__title'}),
                ('span', {'class': 'pip-header-section__title--big'}),
                ('meta', {'property': 'og:title'}),
            ]
        elif 'maisonmargiela' in domain:
            name_selectors = [
                ('h1', {'class': 'product-name'}),
                ('span', {'class': 'base'}),
                ('meta', {'property': 'og:title'}),
            ]
        elif 'aloyoga' in domain:
            name_selectors = [
                ('h1', {'class': 'product-name'}),
                ('h1', {'data-testid': 'product-title'}),
                ('meta', {'property': 'og:title'}),
            ]
        elif 'zagbijoux' in domain:
            name_selectors = [
                ('h1', {'class': 'product-title'}),
                ('h1', {'itemprop': 'name'}),
                ('meta', {'property': 'og:title'}),
            ]
        elif 'moonnude' in domain:
            name_selectors = [
                ('h1', {'class': 'product-title'}),
                ('meta', {'property': 'og:title'}),
            ]
        elif 'rimowa' in domain:
            name_selectors = [
                ('h1', {'class': 'product-name'}),
                ('meta', {'property': 'og:title'}),
            ]
        else:
            # Sélecteurs génériques
            name_selectors = [
                ('meta', {'property': 'og:title'}),
                ('meta', {'name': 'twitter:title'}),
                ('h1', {'class': re.compile(r'product.*title|title.*product|product.*name', re.I)}),
                ('h1', {'data-testid': re.compile(r'product.*title|title', re.I)}),
                ('h1', {'itemprop': 'name'}),
                ('h1', {}),
            ]

        for tag, attrs in name_selectors:
            element = soup.find(tag, attrs)
            if element:
                if tag == 'meta':
                    name = element.get('content', '').strip()
                else:
                    name = element.get_text(strip=True)

                # Nettoyer le nom
                if name:
                    # Retirer les caractères spéciaux en trop
                    name = re.sub(r'\s+', ' ', name)
                    name = name.strip()

                    # Vérifier que le nom est valide (plus de 3 caractères)
                    if len(name) > 3:
                        break
                    else:
                        name = None

        # ========== EXTRACTION DU PRIX ==========
        price = None
        price_selectors = []

        if 'messika' in domain:
            price_selectors = [
                ('span', {'class': 'price'}),
                ('div', {'class': 'product-price'}),
                ('meta', {'property': 'product:price:amount'}),
            ]
        elif 'backmarket' in domain:
            price_selectors = [
                ('div', {'data-qa': 'price'}),
                ('span', {'class': re.compile(r'price', re.I)}),
                ('meta', {'property': 'og:price:amount'}),
            ]
        elif 'boulanger' in domain:
            price_selectors = [
                ('span', {'class': 'price'}),
                ('div', {'class': 'product-price'}),
                ('meta', {'property': 'product:price:amount'}),
            ]
        elif 'fnac' in domain:
            price_selectors = [
                ('div', {'class': 'f-priceBox-price'}),
                ('span', {'class': re.compile(r'price', re.I)}),
                ('meta', {'property': 'product:price:amount'}),
            ]
        elif 'galerieslafayette' in domain or 'printemps' in domain:
            price_selectors = [
                ('span', {'class': 'ProductPrice'}),
                ('div', {'class': re.compile(r'price', re.I)}),
                ('meta', {'property': 'product:price:amount'}),
            ]
        elif 'ikea' in domain:
            price_selectors = [
                ('span', {'class': 'pip-temp-price__integer'}),
                ('span', {'class': re.compile(r'price', re.I)}),
                ('meta', {'property': 'product:price:amount'}),
            ]
        else:
            price_selectors = [
                ('meta', {'property': 'og:price:amount'}),
                ('meta', {'property': 'product:price:amount'}),
                ('span', {'class': re.compile(r'price|prix', re.I)}),
                ('div', {'class': re.compile(r'price|prix', re.I)}),
                ('p', {'class': re.compile(r'price|prix', re.I)}),
                ('span', {'itemprop': 'price'}),
            ]

        for tag, attrs in price_selectors:
            elements = soup.find_all(tag, attrs) if tag != 'meta' else [soup.find(tag, attrs)]

            for element in elements:
                if not element:
                    continue

                if tag == 'meta':
                    text = element.get('content', '')
                else:
                    text = element.get_text(strip=True)

                # Chercher un pattern de prix robuste
                # Pattern avec centimes: 29.99, 29,99, 1 299,99, 1.299,99
                price_match = re.search(r'(\d{1,3}(?:[\s.,]?\d{3})*)[.,](\d{2})', text)
                if price_match:
                    price_str = price_match.group(0)
                    # Nettoyer: retirer espaces, remplacer virgule par point
                    price_str = price_str.replace(' ', '').replace(',', '.')
                    # Si format 1.299.99, garder seulement le dernier point
                    if price_str.count('.') > 1:
                        parts = price_str.split('.')
                        price_str = ''.join(parts[:-1]) + '.' + parts[-1]

                    try:
                        price = float(price_str)
                        if price > 0:
                            break
                    except:
                        continue

                # Pattern sans centimes
                if not price:
                    price_match = re.search(r'(\d{1,3}(?:[\s.,]?\d{3})*)', text)
                    if price_match:
                        price_str = price_match.group(1).replace(' ', '').replace(',', '')
                        try:
                            price = float(price_str)
                            if price > 0:
                                break
                        except:
                            continue

            if price and price > 0:
                break

        # ========== EXTRACTION DE L'IMAGE ==========
        image_url = None

        # Méthode 1: Meta tags (prioritaire)
        meta_image_tags = [
            ('meta', {'property': 'og:image'}),
            ('meta', {'name': 'twitter:image'}),
            ('meta', {'itemprop': 'image'}),
        ]

        for tag, attrs in meta_image_tags:
            element = soup.find(tag, attrs)
            if element:
                img_candidate = element.get('content', '')
                if img_candidate and img_candidate.startswith('http'):
                    # Vérifier que c'est une vraie image (pas un placeholder)
                    if not any(word in img_candidate.lower() for word in ['placeholder', 'default', 'noimage', 'blank']):
                        image_url = img_candidate
                        break

        # Méthode 2: Images du produit principal
        if not image_url:
            img_selectors = [
                ('img', {'class': re.compile(r'product.*image|main.*image|hero.*image|gallery.*image', re.I)}),
                ('img', {'data-testid': re.compile(r'product.*image|main.*image', re.I)}),
                ('img', {'itemprop': 'image'}),
                ('img', {'id': re.compile(r'product.*image|main.*image', re.I)}),
                ('img', {'alt': re.compile(r'product|main', re.I)}),
            ]

            for tag, attrs in img_selectors:
                img = soup.find(tag, attrs)
                if img:
                    img_candidate = img.get('src') or img.get('data-src') or img.get('data-original') or img.get('data-lazy') or img.get('srcset')

                    if img_candidate:
                        # Si c'est un srcset, prendre la première URL
                        if 'srcset' in str(img_candidate):
                            img_candidate = img_candidate.split(',')[0].split(' ')[0]

                        # Nettoyer l'URL
                        if img_candidate.startswith('//'):
                            img_candidate = 'https:' + img_candidate
                        elif img_candidate.startswith('/'):
                            parsed = urlparse(url)
                            img_candidate = f"{parsed.scheme}://{parsed.netloc}{img_candidate}"

                        # Vérifier que c'est une vraie image
                        if img_candidate.startswith('http') and not any(word in img_candidate.lower() for word in ['placeholder', 'default', 'noimage', 'blank']):
                            image_url = img_candidate
                            break

        # ========== EXTRACTION DE LA DESCRIPTION ==========
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
        print(f"      ❌ Erreur extraction (tentative {attempt}): {e}")
        return None

# ============================================
# VALIDATION STRICTE
# ============================================

def validate_product_strict(product_data, brand):
    """Valide qu'un produit a TOUS les champs obligatoires - MODE STRICT"""
    errors = []

    # Nom obligatoire (minimum 3 caractères)
    if not product_data.get('name') or len(str(product_data['name']).strip()) < 3:
        errors.append("Nom manquant ou trop court")

    # Marque obligatoire et reconnue
    if not brand or brand == 'Unknown':
        errors.append("Marque inconnue ou non reconnue")

    # Prix obligatoire (> 0)
    price = product_data.get('price')
    if not price or not isinstance(price, (int, float)) or price <= 0:
        errors.append("Prix manquant ou invalide")

    # Image obligatoire (URL valide)
    image = product_data.get('image')
    if not image or not str(image).startswith('http'):
        errors.append("Image manquante ou URL invalide")

    return len(errors) == 0, errors

# ============================================
# GÉNÉRATION DE TAGS & CATÉGORIES (IDENTIQUE)
# ============================================

def generate_tags(product_data, brand):
    """Génère automatiquement les tags basés sur les données du produit"""
    tags = []
    name = (product_data.get('name') or '').lower()
    description = (product_data.get('description') or '').lower()
    price = product_data.get('price') or 0

    full_text = f"{name} {description}"

    # Genre
    if any(word in full_text for word in ['femme', 'woman', 'women', 'her', 'elle', 'féminin', 'female', 'pour femme']):
        tags.append('femme')
    if any(word in full_text for word in ['homme', 'man', 'men', 'his', 'lui', 'masculin', 'male', 'pour homme']):
        tags.append('homme')
    if any(word in full_text for word in ['unisex', 'mixte', 'all', 'unisexe']):
        tags.extend(['femme', 'homme'])

    # Catégories de produits
    if any(word in full_text for word in ['sneakers', 'baskets', 'running', 'trainer', 'chaussures', 'shoes', 'boots', 'bottes', 'mocassins']):
        tags.extend(['chaussures', 'mode'])
    if any(word in full_text for word in ['pull', 'sweater', 'sweat', 'veste', 'jacket', 'jean', 't-shirt', 'chemise', 'robe', 'dress', 'pantalon']):
        tags.extend(['vetements', 'mode'])
    if any(word in full_text for word in ['sac', 'bag', 'ceinture', 'belt', 'lunettes', 'sunglasses', 'bijoux', 'bracelet', 'collier', 'bague']):
        tags.extend(['accessoires'])
    if any(word in full_text for word in ['parfum', 'fragrance', 'maquillage', 'makeup', 'skincare', 'soin', 'beaute', 'beauty', 'creme', 'serum']):
        tags.extend(['beaute'])
    if any(word in full_text for word in ['yoga', 'sport', 'fitness', 'athletic', 'running', 'legging', 'brassiere']):
        tags.extend(['sport', 'fitness'])
    if any(word in full_text for word in ['iphone', 'macbook', 'ipad', 'samsung', 'console', 'playstation', 'laptop', 'ordinateur', 'casque', 'airpods', 'ecouteurs']):
        tags.extend(['tech', 'electronique'])
    if any(word in full_text for word in ['meuble', 'decoration', 'maison', 'home', 'vase', 'table', 'chaise']):
        tags.extend(['maison', 'decoration'])
    if any(word in full_text for word in ['valise', 'luggage', 'bagage', 'suitcase', 'travel', 'voyage']):
        tags.extend(['accessoires', 'voyage'])

    # Budget
    if price < 50:
        tags.extend(['budget_petit', 'abordable'])
    elif price < 150:
        tags.extend(['budget_moyen', 'accessible'])
    elif price < 400:
        tags.extend(['budget_luxe', 'premium'])
    else:
        tags.extend(['budget_premium', 'luxe'])

    # Style
    if any(word in full_text for word in ['luxe', 'luxury', 'premium', 'designer']):
        tags.append('luxe')
    if any(word in full_text for word in ['elegant', 'élégant', 'chic']):
        tags.append('elegant')
    if any(word in full_text for word in ['casual', 'décontracté']):
        tags.append('casual')
    if any(word in full_text for word in ['sportif', 'sport', 'athletic']):
        tags.append('sportif')
    if any(word in full_text for word in ['moderne', 'modern', 'tendance']):
        tags.append('moderne')

    # Tags spécifiques par marque
    brand_tags = {
        'Messika': ['luxe', 'bijoux', 'diamant', 'joaillerie', 'premium', 'francais'],
        'Back Market': ['tech', 'reconditionne', 'ecologique', 'electronique', 'durable'],
        'Boulanger': ['tech', 'electronique', 'maison'],
        'Fnac': ['tech', 'culture', 'multimedia', 'electronique'],
        'Galeries Lafayette': ['luxe', 'mode', 'premium', 'parisien'],
        'Ikea': ['maison', 'decoration', 'design', 'scandinave', 'abordable'],
        'Maison Margiela': ['luxe', 'haute_couture', 'designer', 'avant-garde', 'premium'],
        'Alo Yoga': ['sport', 'yoga', 'wellness', 'fitness', 'athleisure'],
        'Zag Bijoux': ['bijoux', 'accessoires', 'tendance', 'francais'],
        'Printemps': ['mode', 'luxe', 'parisien'],
        'Moon Nude': ['beaute', 'accessoires', 'makeup'],
        'Rimowa': ['luxe', 'voyage', 'premium', 'allemand', 'design'],
        'Golden Goose': ['luxe', 'italien', 'sneakers', 'streetwear', 'designer'],
        'Zara': ['tendance', 'accessible', 'mode', 'fast-fashion'],
        'Sephora': ['beaute', 'maquillage', 'cosmetics'],
        'Lululemon': ['sportif', 'yoga', 'qualite', 'performance', 'fitness'],
        'Miu Miu': ['luxe', 'haute_couture', 'italien', 'designer', 'premium'],
        'Maje': ['mode', 'francais', 'elegant', 'contemporain'],
    }

    if brand in brand_tags:
        tags.extend(brand_tags[brand])

    # Âge cible
    tags.append('20-30ans')
    if price > 300:
        tags.append('30-50ans')

    return list(set(tags))

def generate_categories(product_data, brand):
    """Génère les catégories du produit"""
    categories = []
    name = (product_data.get('name') or '').lower()
    description = (product_data.get('description') or '').lower()
    full_text = f"{name} {description}"

    # Catégories principales
    if any(word in full_text for word in ['sneakers', 'chaussures', 'shoes', 'boots', 'sandales', 'mocassins', 'baskets']):
        categories.append('chaussures')
    if any(word in full_text for word in ['sac', 'bag', 'purse', 'handbag', 'tote', 'pochette', 'ceinture', 'lunettes', 'bijoux', 'bracelet', 'collier', 'bague', 'valise', 'luggage']):
        categories.append('accessoires')
    if any(word in full_text for word in ['pull', 'sweater', 'sweat', 'hoodie', 'top', 'shirt', 'veste', 'jacket', 'jean', 'pantalon', 'robe', 'dress']):
        categories.append('vetements')
    if any(word in full_text for word in ['parfum', 'fragrance', 'perfume']):
        categories.append('parfums')
    if any(word in full_text for word in ['maquillage', 'makeup', 'lipstick', 'mascara', 'foundation', 'palette']):
        categories.append('maquillage')
    if any(word in full_text for word in ['skincare', 'soin', 'cream', 'serum', 'moisturizer']):
        categories.append('beaute')
    if any(word in full_text for word in ['sport', 'yoga', 'legging', 'brassiere', 'athletic', 'fitness']):
        categories.append('sport')
    if any(word in full_text for word in ['iphone', 'macbook', 'ipad', 'samsung', 'console', 'playstation', 'ordinateur', 'laptop', 'casque', 'airpods', 'tech', 'electronique']):
        categories.append('tech')
    if any(word in full_text for word in ['vase', 'table', 'cadre', 'decoration', 'maison', 'meuble']):
        categories.append('maison')

    # Fallback par marque
    if not categories:
        if brand in ['Sephora', 'Rhode', 'Moon Nude']:
            categories.append('beaute')
        elif brand in ['Lululemon', 'Alo Yoga']:
            categories.append('sport')
        elif brand in ['Messika', 'Zag Bijoux']:
            categories.append('accessoires')
        elif brand in ['Back Market', 'Boulanger', 'Fnac']:
            categories.append('tech')
        elif brand == 'Ikea':
            categories.append('maison')
        elif brand == 'Rimowa':
            categories.append('accessoires')
        else:
            categories.append('mode')

    return categories

# ============================================
# UPLOAD FIREBASE
# ============================================

def upload_to_firebase(db, product):
    """Upload un produit dans Firebase Firestore"""
    try:
        doc_ref = db.collection('gifts').document()
        doc_ref.set(product)
        print(f"      ✅ Uploadé dans Firebase (ID: {doc_ref.id})")
        return True, doc_ref.id
    except Exception as e:
        print(f"      ❌ Erreur upload Firebase: {e}")
        return False, None

# ============================================
# FONCTION PRINCIPALE - MODE STRICT
# ============================================

def scrape_and_upload_strict():
    """Fonction principale de scraping - MODE ULTRA STRICT"""

    print("=" * 70)
    print("🕷️  SCRAPING STRICT DES PRODUITS DORÕN")
    print("   ⚠️  MODE STRICT: Seuls les produits 100% complets seront uploadés")
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

    # Lire les URLs depuis le CSV
    try:
        with open(CSV_FILE, 'r', encoding='utf-8') as f:
            reader = csv.reader(f)
            urls = [row[0] for row in reader if row and row[0].startswith('http')]
    except Exception as e:
        print(f"❌ Erreur lecture CSV: {e}")
        return

    print(f"📋 {len(urls)} URLs à scraper\n")

    # Ouvrir le fichier de log
    with open(LOG_FILE, 'w', encoding='utf-8') as log:
        log.write(f"{'='*70}\n")
        log.write(f"SCRAPING STRICT DÉMARRÉ: {datetime.now()}\n")
        log.write(f"{'='*70}\n\n")

        success_count = 0
        fail_count = 0
        rejected_incomplete = 0

        # Scraper chaque URL
        for index, url in enumerate(urls, 1):
            print(f"\n[{index}/{len(urls)}] 🔍 Scraping: {url}")
            log.write(f"\n[{index}/{len(urls)}] URL: {url}\n")

            # Extraire la marque
            brand = extract_brand_from_url(url)
            if not brand:
                print(f"   ❌ MARQUE NON RECONNUE - SKIP")
                log.write(f"   ❌ REJETÉ: Marque non reconnue\n")
                fail_count += 1
                continue

            print(f"   🏷️  Marque: {brand}")
            log.write(f"   Marque: {brand}\n")

            # Tenter le scraping (avec retry)
            product_data = None
            for attempt in range(1, MAX_RETRIES + 1):
                product_data = extract_product_data_strict(driver, url, attempt)

                if product_data:
                    # Valider le produit
                    is_valid, errors = validate_product_strict(product_data, brand)

                    if is_valid:
                        break  # Succès!
                    else:
                        print(f"      ⚠️  Produit incomplet: {', '.join(errors)}")
                        log.write(f"      ⚠️ Tentative {attempt} - Incomplet: {', '.join(errors)}\n")

                        if attempt < MAX_RETRIES:
                            print(f"      🔄 Nouvelle tentative...")
                            time.sleep(random.uniform(3, 5))
                        else:
                            product_data = None  # Échec après toutes les tentatives

                else:
                    if attempt < MAX_RETRIES:
                        print(f"      🔄 Nouvelle tentative...")
                        time.sleep(random.uniform(3, 5))

            # Vérifier le résultat final
            if not product_data:
                print(f"   ❌ ÉCHEC après {MAX_RETRIES} tentatives - SKIP")
                log.write(f"   ❌ REJETÉ: Échec après {MAX_RETRIES} tentatives\n")
                fail_count += 1
                continue

            # Validation finale
            is_valid, errors = validate_product_strict(product_data, brand)
            if not is_valid:
                print(f"   ❌ PRODUIT INCOMPLET - REJETÉ")
                print(f"      Raisons: {', '.join(errors)}")
                log.write(f"   ❌ REJETÉ: {', '.join(errors)}\n")
                rejected_incomplete += 1
                fail_count += 1
                continue

            # Produit valide - Afficher les données
            print(f"   ✅ {product_data['name']}")
            print(f"   💰 Prix: {product_data['price']}€")
            print(f"   🖼️  Image: {product_data['image'][:60]}...")
            log.write(f"   ✅ Nom: {product_data['name']}\n")
            log.write(f"   💰 Prix: {product_data['price']}€\n")
            log.write(f"   🖼️ Image: {product_data['image']}\n")

            # Générer tags et catégories
            tags = generate_tags(product_data, brand)
            categories = generate_categories(product_data, brand)

            print(f"   🏷️  Tags ({len(tags)}): {', '.join(tags[:8])}...")
            print(f"   📂 Catégories: {', '.join(categories)}")
            log.write(f"   🏷️ Tags ({len(tags)}): {', '.join(tags)}\n")
            log.write(f"   📂 Catégories: {', '.join(categories)}\n")

            # Créer l'objet produit complet
            product = {
                'name': product_data['name'],
                'brand': brand,
                'price': product_data['price'],
                'url': url,
                'image': product_data['image'],
                'description': product_data.get('description') or f"Produit {brand} de qualité supérieure.",
                'categories': categories,
                'tags': tags,
                'active': True,
                'source': 'strict_scraping',
                'created_at': firestore.SERVER_TIMESTAMP,
                'popularity': random.randint(60, 95),
                # Compatibilité ancien schema
                'product_photo': product_data['image'],
                'product_title': product_data['name'],
                'product_url': url,
                'product_price': str(product_data['price']),
            }

            # Upload dans Firebase
            success, doc_id = upload_to_firebase(db, product)
            if success:
                success_count += 1
                log.write(f"   ✅ UPLOADÉ (ID: {doc_id})\n")
            else:
                fail_count += 1
                log.write(f"   ❌ ÉCHEC UPLOAD\n")

            # Pause anti-blocage
            delay = random.uniform(4, 7)
            print(f"   ⏳ Pause {delay:.1f}s...")
            time.sleep(delay)

        # Résumé final
        print("\n")
        print("=" * 70)
        print("📊 RÉSULTATS FINAUX (MODE STRICT):")
        print(f"   ✅ Produits scrapés et uploadés: {success_count}")
        print(f"   ❌ Échecs totaux: {fail_count}")
        print(f"   🚫 Produits rejetés (incomplets): {rejected_incomplete}")
        if success_count + fail_count > 0:
            print(f"   📈 Taux de réussite: {(success_count/(success_count+fail_count)*100):.1f}%")
        print("=" * 70)

        log.write(f"\n\n{'='*70}\n")
        log.write(f"RÉSUMÉ:\n")
        log.write(f"   ✅ Succès: {success_count}\n")
        log.write(f"   ❌ Échecs: {fail_count}\n")
        log.write(f"   🚫 Rejetés (incomplets): {rejected_incomplete}\n")
        if success_count + fail_count > 0:
            log.write(f"   📈 Taux: {(success_count/(success_count+fail_count)*100):.1f}%\n")
        log.write(f"{'='*70}\n")

    # Fermer le navigateur
    driver.quit()
    print("\n🎉 SCRAPING TERMINÉ!")
    print(f"📝 Logs sauvegardés dans: {LOG_FILE}")
    print(f"\n💡 Conseil: Utilisez cleanup_firebase.py pour nettoyer les produits incomplets existants")

# ============================================
# POINT D'ENTRÉE
# ============================================

if __name__ == "__main__":
    scrape_and_upload_strict()
