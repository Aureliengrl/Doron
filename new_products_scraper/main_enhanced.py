#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de Scraping AMÉLIORÉ des Produits pour DORÕN
Version finale avec tags et catégories enrichis
À exécuter sur Replit.com
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
LOG_FILE = "scraping_log.txt"

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
# EXTRACTION DE DONNÉES
# ============================================

def extract_brand_from_url(url):
    """Extrait la marque depuis l'URL"""
    domain = urlparse(url).netloc.lower()

    if 'goldengoose' in domain:
        return 'Golden Goose'
    elif 'zara' in domain:
        return 'Zara'
    elif 'maje' in domain:
        return 'Maje'
    elif 'miumiu' in domain:
        return 'Miu Miu'
    elif 'rhode' in domain:
        return 'Rhode'
    elif 'sephora' in domain:
        return 'Sephora'
    elif 'lululemon' in domain:
        return 'Lululemon'
    else:
        return 'Unknown'

def extract_product_data(driver, url):
    """Extrait les données du produit depuis la page web"""
    try:
        # Charger la page
        driver.get(url)
        time.sleep(random.uniform(3, 5))  # Délai anti-blocage augmenté

        # Parser le HTML
        soup = BeautifulSoup(driver.page_source, 'html.parser')

        # ========== EXTRACTION DU NOM ==========
        name = None
        name_selectors = [
            ('h1', {'class': re.compile(r'product.*title|title.*product', re.I)}),
            ('h1', {'data-testid': 'product-title'}),
            ('h1', {}),
            ('span', {'class': re.compile(r'product.*name|name.*product', re.I)}),
            ('div', {'class': re.compile(r'product.*title', re.I)}),
        ]

        for tag, attrs in name_selectors:
            element = soup.find(tag, attrs)
            if element and element.get_text(strip=True):
                name = element.get_text(strip=True)
                break

        if not name:
            # Fallback: chercher dans meta tags
            meta_title = soup.find('meta', {'property': 'og:title'})
            if meta_title:
                name = meta_title.get('content', '').strip()

        # ========== EXTRACTION DU PRIX ==========
        price = None
        price_selectors = [
            ('span', {'class': re.compile(r'price|prix', re.I)}),
            ('div', {'class': re.compile(r'price|prix', re.I)}),
            ('p', {'class': re.compile(r'price|prix', re.I)}),
            ('span', {'data-testid': 'price'}),
        ]

        for tag, attrs in price_selectors:
            elements = soup.find_all(tag, attrs)
            for element in elements:
                text = element.get_text(strip=True)
                # Chercher un pattern de prix (ex: 29.99, 29,99, €29.99, $29.99)
                price_match = re.search(r'(\d+[.,]\d{2}|\d+)', text)
                if price_match:
                    price_str = price_match.group(1).replace(',', '.')
                    try:
                        price = float(price_str)
                        break
                    except:
                        continue
            if price:
                break

        # ========== EXTRACTION DE L'IMAGE ==========
        image_url = None

        # Méthode 1: Chercher dans meta tags Open Graph
        og_image = soup.find('meta', {'property': 'og:image'})
        if og_image:
            image_url = og_image.get('content', '')

        # Méthode 2: Chercher les images principales du produit
        if not image_url:
            image_selectors = [
                ('img', {'class': re.compile(r'product.*image|main.*image|hero.*image', re.I)}),
                ('img', {'data-testid': 'product-image'}),
                ('img', {'itemprop': 'image'}),
            ]

            for tag, attrs in image_selectors:
                img = soup.find(tag, attrs)
                if img:
                    image_url = img.get('src') or img.get('data-src') or img.get('data-original')
                    if image_url:
                        break

        # Nettoyer l'URL de l'image
        if image_url:
            if image_url.startswith('//'):
                image_url = 'https:' + image_url
            elif image_url.startswith('/'):
                parsed = urlparse(url)
                image_url = f"{parsed.scheme}://{parsed.netloc}{image_url}"

        # ========== EXTRACTION DE LA DESCRIPTION ==========
        description = None
        desc_selectors = [
            ('div', {'class': re.compile(r'description|product.*desc', re.I)}),
            ('p', {'class': re.compile(r'description', re.I)}),
            ('meta', {'name': 'description'}),
            ('meta', {'property': 'og:description'}),
        ]

        for tag, attrs in desc_selectors:
            element = soup.find(tag, attrs)
            if element:
                if tag == 'meta':
                    description = element.get('content', '').strip()
                else:
                    description = element.get_text(strip=True)

                if description and len(description) > 20:
                    description = description[:500]  # Limiter à 500 caractères
                    break

        return {
            'name': name,
            'price': price,
            'image': image_url,
            'description': description
        }

    except Exception as e:
        print(f"    ❌ Erreur extraction: {e}")
        return None

# ============================================
# GÉNÉRATION DE TAGS AMÉLIORÉE
# ============================================

def generate_tags(product_data, brand):
    """Génère automatiquement les tags basés sur les données du produit"""
    tags = []
    name = (product_data.get('name') or '').lower()
    description = (product_data.get('description') or '').lower()
    price = product_data.get('price') or 0

    full_text = f"{name} {description}"

    # ========== GENRE ==========
    if any(word in full_text for word in ['femme', 'woman', 'women', 'her', 'elle', 'féminin', 'female', 'pour femme']):
        tags.append('femme')
    if any(word in full_text for word in ['homme', 'man', 'men', 'his', 'lui', 'masculin', 'male', 'pour homme']):
        tags.append('homme')
    if any(word in full_text for word in ['unisex', 'mixte', 'all', 'unisexe']):
        tags.extend(['femme', 'homme'])

    # Si aucun genre détecté, essayer de deviner par la marque/type de produit
    if not any(g in tags for g in ['femme', 'homme']):
        if brand in ['Miu Miu', 'Maje']:
            tags.append('femme')
        elif brand == 'Golden Goose':
            # Golden Goose est mixte, ajouter selon le contexte
            if any(word in full_text for word in ['mini', 'petite', 'slim']):
                tags.append('femme')
            else:
                tags.extend(['femme', 'homme'])

    # ========== CATÉGORIES DE PRODUITS ==========
    # Chaussures
    if any(word in full_text for word in ['sneakers', 'baskets', 'running', 'trainer']):
        tags.extend(['chaussures', 'sneakers', 'sportif'])
    elif any(word in full_text for word in ['boots', 'bottes', 'bottines', 'santiags']):
        tags.extend(['chaussures', 'boots'])
    elif any(word in full_text for word in ['mocassins', 'loafers', 'chaussures']):
        tags.append('chaussures')

    # Vêtements
    if any(word in full_text for word in ['pull', 'sweater', 'cardigan', 'gilet']):
        tags.extend(['vetements', 'pull'])
    elif any(word in full_text for word in ['veste', 'jacket', 'blouson', 'bomber', 'manteau', 'coat']):
        tags.extend(['vetements', 'veste'])
    elif any(word in full_text for word in ['jean', 'denim', 'jeans', 'pantalon', 'pants']):
        tags.extend(['vetements', 'pantalon'])
    elif any(word in full_text for word in ['t-shirt', 'tee', 'top', 'chemise', 'shirt', 'blouse']):
        tags.extend(['vetements', 'haut'])
    elif any(word in full_text for word in ['sweat', 'hoodie', 'capuche']):
        tags.extend(['vetements', 'sweat'])
    elif any(word in full_text for word in ['jupe', 'skirt', 'robe', 'dress']):
        tags.extend(['vetements', 'robe'])

    # Accessoires
    if any(word in full_text for word in ['sac', 'bag', 'purse', 'handbag', 'tote', 'pochette']):
        tags.extend(['accessoires', 'sac'])
    elif any(word in full_text for word in ['ceinture', 'belt']):
        tags.extend(['accessoires', 'ceinture'])
    elif any(word in full_text for word in ['lunettes', 'sunglasses', 'glasses']):
        tags.extend(['accessoires', 'lunettes'])
    elif any(word in full_text for word in ['casquette', 'cap', 'chapeau', 'hat', 'bonnet']):
        tags.extend(['accessoires', 'couvre-chef'])

    # Beauté & Cosmétiques
    if any(word in full_text for word in ['parfum', 'fragrance', 'perfume', 'eau de toilette', 'eau de parfum']):
        tags.extend(['beaute', 'parfum'])
    elif any(word in full_text for word in ['lipstick', 'rouge', 'levres', 'lip', 'gloss', 'baume']):
        tags.extend(['beaute', 'maquillage', 'levres'])
    elif any(word in full_text for word in ['eyeshadow', 'palette', 'fard', 'yeux', 'mascara', 'eyeliner']):
        tags.extend(['beaute', 'maquillage', 'yeux'])
    elif any(word in full_text for word in ['foundation', 'fond de teint', 'blush', 'poudre', 'powder']):
        tags.extend(['beaute', 'maquillage', 'teint'])
    elif any(word in full_text for word in ['serum', 'cream', 'creme', 'moisturizer', 'hydratant', 'soin']):
        tags.extend(['beaute', 'skincare', 'soin'])
    elif any(word in full_text for word in ['masque', 'mask', 'peeling', 'gommage']):
        tags.extend(['beaute', 'skincare', 'masque'])

    # Sport & Fitness
    if any(word in full_text for word in ['yoga', 'legging', 'brassiere', 'bra', 'athletic', 'sport']):
        tags.extend(['sport', 'fitness'])
    elif any(word in full_text for word in ['running', 'jogging', 'course']):
        tags.extend(['sport', 'running'])

    # Décoration (si on trouve des produits maison)
    if any(word in full_text for word in ['vase', 'table', 'cadre', 'horloge', 'decoration', 'maison']):
        tags.extend(['maison', 'decoration'])

    # ========== BUDGET ==========
    if price < 50:
        tags.extend(['budget_petit', 'abordable'])
    elif price < 150:
        tags.extend(['budget_moyen', 'accessible'])
    elif price < 400:
        tags.extend(['budget_luxe', 'premium'])
    else:
        tags.extend(['budget_premium', 'luxe'])

    # ========== STYLE & AMBIANCE ==========
    if any(word in full_text for word in ['sport', 'athletic', 'running', 'yoga', 'fitness', 'gym', 'performance']):
        tags.append('sportif')
    if any(word in full_text for word in ['casual', 'décontracté', 'relaxed', 'everyday', 'quotidien']):
        tags.append('casual')
    if any(word in full_text for word in ['elegant', 'élégant', 'chic', 'formal', 'sophistique']):
        tags.append('elegant')
    if any(word in full_text for word in ['luxe', 'luxury', 'premium', 'haute', 'couture']):
        tags.append('luxe')
    if any(word in full_text for word in ['vintage', 'retro', 'classic', 'classique', 'intemporel']):
        tags.append('vintage')
    if any(word in full_text for word in ['modern', 'moderne', 'contemporary', 'tendance', 'trend']):
        tags.append('moderne')
    if any(word in full_text for word in ['streetwear', 'urban', 'street', 'urbain']):
        tags.append('streetwear')

    # ========== OCCASIONS ==========
    if any(word in full_text for word in ['travail', 'work', 'office', 'business', 'professional', 'bureau']):
        tags.append('travail')
    if any(word in full_text for word in ['soirée', 'party', 'evening', 'cocktail', 'gala', 'fete']):
        tags.append('soiree')
    if any(word in full_text for word in ['quotidien', 'daily', 'everyday', 'tous les jours']):
        tags.append('quotidien')

    # ========== MATIÈRES ==========
    if any(word in full_text for word in ['cuir', 'leather', 'nappa', 'suede', 'daim']):
        tags.append('cuir')
    if any(word in full_text for word in ['coton', 'cotton']):
        tags.append('coton')
    if any(word in full_text for word in ['laine', 'wool', 'cachemire', 'cashmere']):
        tags.append('laine')
    if any(word in full_text for word in ['velours', 'velvet', 'velour']):
        tags.append('velours')

    # ========== ÂGE CIBLE ==========
    tags.append('20-30ans')  # Par défaut
    if price > 300 or brand in ['Miu Miu', 'Golden Goose']:
        tags.append('30-50ans')
    if any(word in full_text for word in ['tendance', 'trend', 'jeune', 'young']):
        if '30-50ans' not in tags:
            tags.append('18-25ans')

    # ========== TAGS SPÉCIFIQUES PAR MARQUE ==========
    if brand == 'Golden Goose':
        tags.extend(['luxe', 'italien', 'sneakers', 'streetwear', 'designer'])
    elif brand == 'Zara':
        tags.extend(['tendance', 'accessible', 'mode', 'fast-fashion'])
    elif brand == 'Sephora':
        tags.extend(['beaute', 'maquillage', 'cosmetics'])
    elif brand == 'Rhode':
        tags.extend(['beaute', 'skincare', 'soin', 'naturel'])
    elif brand == 'Lululemon':
        tags.extend(['sportif', 'yoga', 'qualite', 'performance', 'fitness'])
    elif brand == 'Miu Miu':
        tags.extend(['luxe', 'haute_couture', 'italien', 'designer', 'premium'])
    elif brand == 'Maje':
        tags.extend(['mode', 'francais', 'elegant', 'contemporain'])

    # ========== SAISONS ==========
    if any(word in full_text for word in ['hiver', 'winter', 'chaud', 'warm', 'laine', 'wool']):
        tags.append('hiver')
    if any(word in full_text for word in ['ete', 'summer', 'leger', 'light']):
        tags.append('ete')

    # Éliminer les doublons et retourner
    return list(set(tags))

def generate_categories(product_data, brand):
    """Génère les catégories du produit"""
    categories = []
    name = (product_data.get('name') or '').lower()
    description = (product_data.get('description') or '').lower()

    full_text = f"{name} {description}"

    # CATÉGORIES PRINCIPALES
    if any(word in full_text for word in ['sneakers', 'chaussures', 'shoes', 'boots', 'sandales', 'mocassins', 'baskets']):
        categories.append('chaussures')

    if any(word in full_text for word in ['sac', 'bag', 'purse', 'handbag', 'tote', 'pochette']):
        categories.append('accessoires')

    if any(word in full_text for word in ['pull', 'sweater', 'sweat', 'hoodie', 'cardigan', 'gilet',
                                            'top', 'shirt', 'chemise', 'blouse', 't-shirt',
                                            'veste', 'jacket', 'blouson', 'manteau', 'coat',
                                            'jean', 'pantalon', 'pants', 'jupe', 'robe', 'dress']):
        categories.append('vetements')

    if any(word in full_text for word in ['parfum', 'fragrance', 'perfume', 'eau de toilette', 'eau de parfum']):
        categories.append('parfums')

    if any(word in full_text for word in ['maquillage', 'makeup', 'lipstick', 'mascara', 'foundation',
                                            'eyeshadow', 'palette', 'blush', 'rouge', 'levres']):
        categories.append('maquillage')

    if any(word in full_text for word in ['skincare', 'soin', 'cream', 'serum', 'moisturizer',
                                            'hydratant', 'masque', 'peeling']):
        categories.append('beaute')

    if any(word in full_text for word in ['sport', 'yoga', 'legging', 'brassiere', 'athletic', 'fitness', 'running']):
        categories.append('sport')

    if any(word in full_text for word in ['vase', 'table', 'cadre', 'horloge', 'decoration', 'maison']):
        categories.append('maison')

    # Catégories basées sur la marque si rien n'a été détecté
    if not categories:
        if brand in ['Sephora', 'Rhode']:
            categories.append('beaute')
        elif brand == 'Lululemon':
            categories.append('sport')
        elif brand in ['Golden Goose', 'Zara', 'Maje', 'Miu Miu']:
            categories.append('mode')
        else:
            categories.append('mode')  # Fallback par défaut

    return categories

# ============================================
# UPLOAD FIREBASE
# ============================================

def upload_to_firebase(db, product):
    """Upload un produit dans Firebase Firestore"""
    try:
        doc_ref = db.collection('gifts').document()
        doc_ref.set(product)
        print(f"    ✅ Uploadé dans Firebase (ID: {doc_ref.id})")
        return True
    except Exception as e:
        print(f"    ❌ Erreur upload Firebase: {e}")
        return False

# ============================================
# FONCTION PRINCIPALE
# ============================================

def scrape_and_upload():
    """Fonction principale de scraping et upload"""

    print("=" * 60)
    print("🕷️  SCRAPING AMÉLIORÉ DES PRODUITS DORÕN")
    print("=" * 60)
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
    with open(LOG_FILE, 'a', encoding='utf-8') as log:
        log.write(f"\n\n{'='*60}\n")
        log.write(f"SCRAPING DÉMARRÉ: {datetime.now()}\n")
        log.write(f"{'='*60}\n\n")

        success_count = 0
        fail_count = 0

        # Scraper chaque URL
        for index, url in enumerate(urls, 1):
            print(f"\n[{index}/{len(urls)}] 🔍 Scraping: {url}")
            log.write(f"\n[{index}/{len(urls)}] URL: {url}\n")

            # Extraire la marque
            brand = extract_brand_from_url(url)
            print(f"    🏷️  Marque: {brand}")

            # Scraper les données
            product_data = extract_product_data(driver, url)

            if not product_data:
                print(f"    ❌ Échec extraction")
                log.write(f"    ❌ ÉCHEC: Impossible d'extraire les données\n")
                fail_count += 1
                continue

            # Vérifier que les données essentielles sont présentes
            if not product_data.get('name'):
                print(f"    ⚠️  Nom manquant - SKIP")
                log.write(f"    ❌ ÉCHEC: Nom manquant\n")
                fail_count += 1
                continue

            print(f"    ✅ {product_data['name']}")

            if product_data.get('price'):
                print(f"    💰 Prix: {product_data['price']}€")
            else:
                print(f"    ⚠️  Prix non trouvé")

            if product_data.get('image'):
                print(f"    🖼️  Image: OK")
            else:
                print(f"    ⚠️  Image non trouvée")

            # Générer tags et catégories
            tags = generate_tags(product_data, brand)
            categories = generate_categories(product_data, brand)

            print(f"    🏷️  Tags ({len(tags)}): {', '.join(tags[:8])}...")
            print(f"    📂 Catégories: {', '.join(categories)}")

            # Créer l'objet produit complet
            product = {
                'name': product_data['name'],
                'brand': brand,
                'price': product_data.get('price') or 0,
                'url': url,
                'image': product_data.get('image') or '',
                'description': product_data.get('description') or f"Produit {brand} de qualité supérieure.",
                'categories': categories,
                'tags': tags,
                'active': True,
                'source': 'enhanced_scraping',
                'created_at': firestore.SERVER_TIMESTAMP,
                'popularity': random.randint(50, 90),
                # Champs compatibles avec ancien schema
                'product_photo': product_data.get('image') or '',
                'product_title': product_data['name'],
                'product_url': url,
                'product_price': str(product_data.get('price') or 0),
            }

            # Logger les données
            log.write(f"    ✅ Nom: {product['name']}\n")
            log.write(f"    💰 Prix: {product['price']}€\n")
            log.write(f"    🖼️ Image: {product['image'][:80]}...\n")
            log.write(f"    🏷️ Tags ({len(tags)}): {', '.join(tags)}\n")
            log.write(f"    📂 Catégories: {', '.join(categories)}\n")

            # Upload dans Firebase
            if upload_to_firebase(db, product):
                success_count += 1
                log.write(f"    ✅ UPLOADÉ DANS FIREBASE\n")
            else:
                fail_count += 1
                log.write(f"    ❌ ÉCHEC UPLOAD FIREBASE\n")

            # Délai anti-blocage aléatoire
            delay = random.uniform(3, 6)
            print(f"    ⏳ Pause {delay:.1f}s...")
            time.sleep(delay)

        # Résumé final
        print("\n")
        print("=" * 60)
        print("📊 RÉSULTATS FINAUX:")
        print(f"   ✅ {success_count} produits scrapés et uploadés avec succès")
        print(f"   ❌ {fail_count} échecs")
        print(f"   📈 Taux de réussite: {(success_count/(success_count+fail_count)*100):.1f}%")
        print("=" * 60)

        log.write(f"\n\n{'='*60}\n")
        log.write(f"RÉSUMÉ:\n")
        log.write(f"   ✅ Succès: {success_count}\n")
        log.write(f"   ❌ Échecs: {fail_count}\n")
        log.write(f"   📈 Taux: {(success_count/(success_count+fail_count)*100):.1f}%\n")
        log.write(f"{'='*60}\n")

    # Fermer le navigateur
    driver.quit()
    print("\n🎉 SCRAPING TERMINÉ!")
    print(f"📝 Logs sauvegardés dans: {LOG_FILE}")

# ============================================
# POINT D'ENTRÉE
# ============================================

if __name__ == "__main__":
    scrape_and_upload()
