#!/usr/bin/env python3
"""
Script de scraping STRICT avec validation à 100%
- Refuse TOUT produit incomplet (sans prix, sans image, etc.)
- 3 tentatives avant abandon
- Logging détaillé de chaque étape
- Sélecteurs CSS optimisés par site
- Upload uniquement des produits 100% valides dans Firebase
"""

import re
import time
import logging
from datetime import datetime
from typing import Dict, List, Optional, Any
from urllib.parse import urljoin, urlparse

import requests
from bs4 import BeautifulSoup
import firebase_admin
from firebase_admin import credentials, firestore

import config

# Configuration du logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(config.SCRAPING_LOG_FILE, encoding='utf-8'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


class ProductValidator:
    """Validateur strict de produits"""

    @staticmethod
    def validate_field(field_name: str, value: Any) -> tuple[bool, Optional[str]]:
        """
        Valide un champ selon les règles définies dans config.VALIDATION_RULES
        Returns: (is_valid, error_message)
        """
        if field_name not in config.VALIDATION_RULES:
            return True, None

        rules = config.VALIDATION_RULES[field_name]

        # Vérification required
        if rules.get("required") and not value:
            return False, f"Champ requis manquant: {field_name}"

        # Si le champ n'est pas required et est vide, c'est OK
        if not value and not rules.get("required"):
            return True, None

        # Validation du type
        if "type" in rules:
            if rules["type"] == "float":
                try:
                    value = float(value)
                except (ValueError, TypeError):
                    return False, f"{field_name}: impossible de convertir en float"

        # Validation de la longueur minimale
        if "min_length" in rules and len(str(value)) < rules["min_length"]:
            return False, f"{field_name}: longueur minimale {rules['min_length']} non atteinte"

        # Validation de la longueur maximale
        if "max_length" in rules and len(str(value)) > rules["max_length"]:
            return False, f"{field_name}: longueur maximale {rules['max_length']} dépassée"

        # Validation de la valeur minimale
        if "min_value" in rules:
            try:
                if float(value) < rules["min_value"]:
                    return False, f"{field_name}: valeur minimale {rules['min_value']} non atteinte"
            except (ValueError, TypeError):
                return False, f"{field_name}: valeur numérique invalide"

        # Validation de la valeur maximale
        if "max_value" in rules:
            try:
                if float(value) > rules["max_value"]:
                    return False, f"{field_name}: valeur maximale {rules['max_value']} dépassée"
            except (ValueError, TypeError):
                return False, f"{field_name}: valeur numérique invalide"

        # Validation des préfixes autorisés
        if "must_start_with" in rules:
            value_str = str(value)
            if not any(value_str.startswith(prefix) for prefix in rules["must_start_with"]):
                return False, f"{field_name}: doit commencer par {rules['must_start_with']}"

        return True, None

    @staticmethod
    def validate_product(product: Dict[str, Any]) -> tuple[bool, List[str]]:
        """
        Validation STRICTE d'un produit
        Returns: (is_valid, list_of_errors)
        """
        errors = []

        # Vérifier que tous les champs requis sont présents
        for field in config.REQUIRED_FIELDS:
            if field not in product or not product[field]:
                errors.append(f"Champ requis manquant: {field}")

        # Valider chaque champ selon les règles
        for field_name, value in product.items():
            is_valid, error = ProductValidator.validate_field(field_name, value)
            if not is_valid:
                errors.append(error)

        return len(errors) == 0, errors


class ScraperStrict:
    """Scraper strict avec validation à 100%"""

    def __init__(self):
        """Initialise le scraper et Firebase"""
        # Initialiser Firebase
        cred = credentials.Certificate(config.FIREBASE_CREDENTIALS)
        try:
            firebase_admin.initialize_app(cred)
            logger.info("✅ Firebase initialisé avec succès")
        except ValueError:
            # App déjà initialisée
            logger.info("ℹ️ Firebase déjà initialisé")

        self.db = firestore.client()
        self.session = requests.Session()
        self.session.headers.update({'User-Agent': config.USER_AGENT})

        # Statistiques
        self.stats = {
            "total_scanned": 0,
            "accepted": 0,
            "rejected": 0,
            "uploaded": 0,
            "errors": 0,
            "rejection_reasons": {}
        }

    def fetch_page(self, url: str, max_retries: int = config.MAX_RETRIES) -> Optional[str]:
        """
        Fetch une page avec retry automatique
        Returns: HTML content ou None si échec
        """
        for attempt in range(max_retries):
            try:
                logger.info(f"📡 Tentative {attempt + 1}/{max_retries}: {url}")
                response = self.session.get(
                    url,
                    timeout=config.REQUEST_TIMEOUT,
                    allow_redirects=True
                )
                response.raise_for_status()
                logger.info(f"✅ Page récupérée avec succès (statut {response.status_code})")
                return response.text

            except requests.exceptions.RequestException as e:
                logger.warning(f"⚠️ Tentative {attempt + 1} échouée: {str(e)}")
                if attempt < max_retries - 1:
                    time.sleep(config.RETRY_DELAY * (attempt + 1))
                else:
                    logger.error(f"❌ Échec après {max_retries} tentatives")
                    self.stats["errors"] += 1

        return None

    def extract_text(self, element, selectors: List[str] | str) -> Optional[str]:
        """
        Extrait du texte en essayant plusieurs sélecteurs
        Returns: texte nettoyé ou None
        """
        if isinstance(selectors, str):
            selectors = [selectors]

        for selector in selectors:
            try:
                found = element.select_one(selector)
                if found:
                    text = found.get_text(strip=True)
                    if text:
                        return text
            except Exception as e:
                logger.debug(f"Sélecteur {selector} échoué: {e}")

        return None

    def extract_attribute(self, element, selectors: List[str] | str, attribute: str) -> Optional[str]:
        """
        Extrait un attribut en essayant plusieurs sélecteurs
        Returns: valeur de l'attribut ou None
        """
        if isinstance(selectors, str):
            selectors = [selectors]

        for selector in selectors:
            try:
                found = element.select_one(selector)
                if found and found.has_attr(attribute):
                    value = found[attribute]
                    if value:
                        return value
            except Exception as e:
                logger.debug(f"Sélecteur {selector} échoué: {e}")

        return None

    def parse_price(self, price_str: str) -> Optional[float]:
        """
        Parse une chaîne de prix et retourne un float
        Supporte: "19,99 €", "19.99", "$19.99", etc.
        """
        if not price_str:
            return None

        # Nettoyer la chaîne
        price_str = price_str.replace('\xa0', ' ').strip()

        # Extraire les nombres
        match = re.search(r'(\d+)[,.]?(\d*)', price_str.replace(' ', ''))
        if match:
            try:
                integer_part = match.group(1)
                decimal_part = match.group(2) or '00'
                # Limiter les décimales à 2 chiffres
                decimal_part = decimal_part[:2].ljust(2, '0')
                price = float(f"{integer_part}.{decimal_part}")
                return price
            except ValueError:
                return None

        return None

    def normalize_url(self, url: str, base_url: str) -> str:
        """Normalise une URL relative en absolue"""
        if not url:
            return ""

        # Si l'URL commence par //, ajouter https:
        if url.startswith('//'):
            url = 'https:' + url

        # Si c'est une URL relative, la rendre absolue
        if not url.startswith('http'):
            url = urljoin(base_url, url)

        return url

    def scrape_site(self, site_key: str, query: str, max_products: int = 50) -> List[Dict[str, Any]]:
        """
        Scrape un site spécifique
        Returns: liste de produits validés
        """
        if site_key not in config.SITES_CONFIG:
            logger.error(f"❌ Site inconnu: {site_key}")
            return []

        site_config = config.SITES_CONFIG[site_key]
        logger.info(f"\n{'='*80}")
        logger.info(f"🎯 SCRAPING: {site_config['name']}")
        logger.info(f"🔍 Recherche: {query}")
        logger.info(f"{'='*80}\n")

        # Construire l'URL de recherche
        search_url = site_config['base_url'] + "/search?"
        params = []
        for key, value in site_config['search_params'].items():
            params.append(f"{key}={value.format(query=query)}")
        search_url += "&".join(params)

        # Fetch la page
        html = self.fetch_page(search_url)
        if not html:
            logger.error(f"❌ Impossible de récupérer la page: {search_url}")
            return []

        # Parser le HTML
        soup = BeautifulSoup(html, 'html.parser')
        selectors = site_config['selectors']

        # Trouver tous les produits
        product_cards = soup.select(selectors['product_card'])
        logger.info(f"📦 {len(product_cards)} produits trouvés sur la page")

        valid_products = []

        for idx, card in enumerate(product_cards[:max_products], 1):
            self.stats["total_scanned"] += 1
            logger.info(f"\n--- Produit {idx}/{min(len(product_cards), max_products)} ---")

            # Extraire les données
            product = {
                "site": site_config['name'],
                "site_key": site_key,
                "scraped_at": datetime.now().isoformat()
            }

            # Titre
            title = self.extract_text(card, selectors['title'])
            if title:
                product['title'] = title
                logger.info(f"📝 Titre: {title[:60]}...")
            else:
                logger.warning("⚠️ Titre manquant")

            # Prix
            price_str = self.extract_text(card, selectors['price'])
            if price_str:
                price = self.parse_price(price_str)
                if price:
                    product['price'] = price
                    logger.info(f"💰 Prix: {price} €")
                else:
                    logger.warning(f"⚠️ Prix invalide: {price_str}")
            else:
                logger.warning("⚠️ Prix manquant")

            # Image
            image_url = self.extract_attribute(card, selectors['image'], 'src')
            if not image_url:
                image_url = self.extract_attribute(card, selectors['image'], 'data-src')

            if image_url:
                image_url = self.normalize_url(image_url, site_config['base_url'])
                product['image'] = image_url
                logger.info(f"🖼️ Image: {image_url[:60]}...")
            else:
                logger.warning("⚠️ Image manquante")

            # URL
            url = self.extract_attribute(card, selectors['url'], 'href')
            if url:
                url = self.normalize_url(url, site_config['base_url'])
                product['url'] = url
                logger.info(f"🔗 URL: {url[:60]}...")
            else:
                logger.warning("⚠️ URL manquante")

            # Champs optionnels
            if 'rating' in selectors:
                rating = self.extract_text(card, selectors['rating'])
                if rating:
                    product['rating'] = rating

            if 'category' in selectors:
                category = self.extract_text(card, selectors['category'])
                if category:
                    product['category'] = category

            # VALIDATION STRICTE
            is_valid, errors = ProductValidator.validate_product(product)

            if is_valid:
                logger.info("✅ PRODUIT ACCEPTÉ - Validation 100% réussie")
                valid_products.append(product)
                self.stats["accepted"] += 1
            else:
                logger.error("❌ PRODUIT REJETÉ - Validation échouée:")
                for error in errors:
                    logger.error(f"   - {error}")
                    # Compter les raisons de rejet
                    if error not in self.stats["rejection_reasons"]:
                        self.stats["rejection_reasons"][error] = 0
                    self.stats["rejection_reasons"][error] += 1
                self.stats["rejected"] += 1

        logger.info(f"\n✅ {len(valid_products)} produits validés sur {len(product_cards)} scannés")
        return valid_products

    def upload_to_firebase(self, products: List[Dict[str, Any]]) -> int:
        """
        Upload les produits validés dans Firebase
        Returns: nombre de produits uploadés avec succès
        """
        if not products:
            logger.warning("⚠️ Aucun produit à uploader")
            return 0

        logger.info(f"\n{'='*80}")
        logger.info(f"📤 UPLOAD FIREBASE: {len(products)} produits")
        logger.info(f"{'='*80}\n")

        uploaded_count = 0
        collection = self.db.collection(config.FIREBASE_COLLECTION)

        for idx, product in enumerate(products, 1):
            try:
                # Générer un ID unique basé sur l'URL
                doc_id = f"{product['site_key']}_{hash(product['url'])}"

                logger.info(f"📤 Upload {idx}/{len(products)}: {product['title'][:50]}...")

                # Upload dans Firebase
                collection.document(doc_id).set(product)

                logger.info(f"✅ Uploadé avec succès (ID: {doc_id})")
                uploaded_count += 1
                self.stats["uploaded"] += 1

            except Exception as e:
                logger.error(f"❌ Erreur d'upload: {str(e)}")
                self.stats["errors"] += 1

        logger.info(f"\n✅ {uploaded_count}/{len(products)} produits uploadés avec succès")
        return uploaded_count

    def print_stats(self):
        """Affiche les statistiques finales"""
        logger.info(f"\n{'='*80}")
        logger.info("📊 STATISTIQUES FINALES")
        logger.info(f"{'='*80}")
        logger.info(f"Total scannés:     {self.stats['total_scanned']}")
        logger.info(f"✅ Acceptés:       {self.stats['accepted']}")
        logger.info(f"❌ Rejetés:        {self.stats['rejected']}")
        logger.info(f"📤 Uploadés:       {self.stats['uploaded']}")
        logger.info(f"⚠️ Erreurs:        {self.stats['errors']}")

        if self.stats['rejection_reasons']:
            logger.info(f"\n{'='*80}")
            logger.info("📋 RAISONS DE REJET")
            logger.info(f"{'='*80}")
            for reason, count in sorted(
                self.stats['rejection_reasons'].items(),
                key=lambda x: x[1],
                reverse=True
            ):
                logger.info(f"  • {reason}: {count}")

        logger.info(f"{'='*80}\n")


def main():
    """Fonction principale"""
    logger.info("🚀 DÉMARRAGE DU SCRAPER STRICT\n")

    scraper = ScraperStrict()

    # Sites à scraper
    sites_to_scrape = ["amazon", "cdiscount", "fnac"]
    queries = ["smartphone", "laptop", "casque audio"]

    all_products = []

    for site_key in sites_to_scrape:
        for query in queries:
            try:
                products = scraper.scrape_site(site_key, query, max_products=20)
                all_products.extend(products)

                # Pause entre les requêtes
                time.sleep(2)

            except Exception as e:
                logger.error(f"❌ Erreur lors du scraping de {site_key}: {str(e)}")
                scraper.stats["errors"] += 1

    # Upload tous les produits validés
    if all_products:
        scraper.upload_to_firebase(all_products)

    # Afficher les statistiques
    scraper.print_stats()

    logger.info("✅ SCRAPING TERMINÉ\n")


if __name__ == "__main__":
    main()
