#!/usr/bin/env python3
"""
Script de nettoyage Firebase
- Analyse tous les produits dans Firebase
- Identifie les produits incomplets (sans prix, sans image, etc.)
- Supprime les produits invalides
- Génère un rapport détaillé
"""

import logging
from datetime import datetime
from typing import Dict, List, Tuple

import firebase_admin
from firebase_admin import credentials, firestore

import config
from main_strict import ProductValidator

# Configuration du logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(config.CLEANUP_LOG_FILE, encoding='utf-8'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


class FirebaseCleaner:
    """Nettoyeur de base de données Firebase"""

    def __init__(self):
        """Initialise le cleaner et Firebase"""
        # Initialiser Firebase
        cred = credentials.Certificate(config.FIREBASE_CREDENTIALS)
        try:
            firebase_admin.initialize_app(cred)
            logger.info("✅ Firebase initialisé avec succès")
        except ValueError:
            # App déjà initialisée
            logger.info("ℹ️ Firebase déjà initialisé")

        self.db = firestore.client()

        # Statistiques
        self.stats = {
            "total_analyzed": 0,
            "valid": 0,
            "invalid": 0,
            "deleted": 0,
            "errors": 0,
            "validation_errors": {}
        }

    def analyze_products(self) -> Tuple[List[Dict], List[Dict]]:
        """
        Analyse tous les produits dans Firebase
        Returns: (liste_produits_valides, liste_produits_invalides)
        """
        logger.info(f"\n{'='*80}")
        logger.info("🔍 ANALYSE DES PRODUITS FIREBASE")
        logger.info(f"{'='*80}\n")

        collection = self.db.collection(config.FIREBASE_COLLECTION)
        docs = collection.stream()

        valid_products = []
        invalid_products = []

        for doc in docs:
            self.stats["total_analyzed"] += 1
            product = doc.to_dict()
            product['_doc_id'] = doc.id

            logger.info(f"\n--- Produit {self.stats['total_analyzed']}: {doc.id} ---")

            # Afficher le titre si disponible
            if 'title' in product:
                logger.info(f"📝 Titre: {product['title'][:60]}...")

            # Valider le produit
            is_valid, errors = ProductValidator.validate_product(product)

            if is_valid:
                logger.info("✅ PRODUIT VALIDE")
                valid_products.append(product)
                self.stats["valid"] += 1
            else:
                logger.warning("❌ PRODUIT INVALIDE:")
                for error in errors:
                    logger.warning(f"   - {error}")
                    # Compter les erreurs de validation
                    if error not in self.stats["validation_errors"]:
                        self.stats["validation_errors"][error] = 0
                    self.stats["validation_errors"][error] += 1

                invalid_products.append(product)
                self.stats["invalid"] += 1

        logger.info(f"\n{'='*80}")
        logger.info(f"✅ Produits valides:   {len(valid_products)}")
        logger.info(f"❌ Produits invalides: {len(invalid_products)}")
        logger.info(f"{'='*80}\n")

        return valid_products, invalid_products

    def delete_invalid_products(self, invalid_products: List[Dict], confirm: bool = True) -> int:
        """
        Supprime les produits invalides de Firebase
        Returns: nombre de produits supprimés
        """
        if not invalid_products:
            logger.info("ℹ️ Aucun produit invalide à supprimer")
            return 0

        logger.info(f"\n{'='*80}")
        logger.info(f"🗑️ SUPPRESSION DES PRODUITS INVALIDES")
        logger.info(f"{'='*80}\n")

        if confirm:
            logger.info(f"⚠️ {len(invalid_products)} produits vont être supprimés")
            response = input("Confirmer la suppression? (oui/non): ")
            if response.lower() not in ['oui', 'o', 'yes', 'y']:
                logger.info("❌ Suppression annulée")
                return 0

        collection = self.db.collection(config.FIREBASE_COLLECTION)
        deleted_count = 0

        for idx, product in enumerate(invalid_products, 1):
            try:
                doc_id = product.get('_doc_id')
                if not doc_id:
                    logger.warning(f"⚠️ Produit sans ID, impossible de supprimer")
                    continue

                title = product.get('title', 'Sans titre')[:50]
                logger.info(f"🗑️ Suppression {idx}/{len(invalid_products)}: {title}...")

                # Supprimer le document
                collection.document(doc_id).delete()

                logger.info(f"✅ Supprimé: {doc_id}")
                deleted_count += 1
                self.stats["deleted"] += 1

            except Exception as e:
                logger.error(f"❌ Erreur de suppression: {str(e)}")
                self.stats["errors"] += 1

        logger.info(f"\n✅ {deleted_count}/{len(invalid_products)} produits supprimés")
        return deleted_count

    def generate_report(self, valid_products: List[Dict], invalid_products: List[Dict]):
        """Génère un rapport détaillé"""
        logger.info(f"\n{'='*80}")
        logger.info("📊 RAPPORT DE NETTOYAGE")
        logger.info(f"{'='*80}")
        logger.info(f"Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        logger.info(f"\n📈 STATISTIQUES GLOBALES")
        logger.info(f"  Total analysés:      {self.stats['total_analyzed']}")
        logger.info(f"  ✅ Valides:          {self.stats['valid']} ({self.stats['valid']/max(self.stats['total_analyzed'], 1)*100:.1f}%)")
        logger.info(f"  ❌ Invalides:        {self.stats['invalid']} ({self.stats['invalid']/max(self.stats['total_analyzed'], 1)*100:.1f}%)")
        logger.info(f"  🗑️ Supprimés:        {self.stats['deleted']}")
        logger.info(f"  ⚠️ Erreurs:          {self.stats['errors']}")

        if self.stats["validation_errors"]:
            logger.info(f"\n{'='*80}")
            logger.info("📋 ERREURS DE VALIDATION")
            logger.info(f"{'='*80}")
            for error, count in sorted(
                self.stats["validation_errors"].items(),
                key=lambda x: x[1],
                reverse=True
            ):
                percentage = count / max(self.stats['invalid'], 1) * 100
                logger.info(f"  • {error}: {count} ({percentage:.1f}%)")

        # Analyse par site
        if valid_products:
            logger.info(f"\n{'='*80}")
            logger.info("📊 PRODUITS VALIDES PAR SITE")
            logger.info(f"{'='*80}")
            sites = {}
            for product in valid_products:
                site = product.get('site', 'Inconnu')
                sites[site] = sites.get(site, 0) + 1

            for site, count in sorted(sites.items(), key=lambda x: x[1], reverse=True):
                logger.info(f"  • {site}: {count}")

        if invalid_products:
            logger.info(f"\n{'='*80}")
            logger.info("📊 PRODUITS INVALIDES PAR SITE")
            logger.info(f"{'='*80}")
            sites = {}
            for product in invalid_products:
                site = product.get('site', 'Inconnu')
                sites[site] = sites.get(site, 0) + 1

            for site, count in sorted(sites.items(), key=lambda x: x[1], reverse=True):
                logger.info(f"  • {site}: {count}")

        logger.info(f"\n{'='*80}\n")

    def print_sample_invalid(self, invalid_products: List[Dict], limit: int = 5):
        """Affiche un échantillon de produits invalides"""
        if not invalid_products:
            return

        logger.info(f"\n{'='*80}")
        logger.info(f"📋 ÉCHANTILLON DE PRODUITS INVALIDES (max {limit})")
        logger.info(f"{'='*80}\n")

        for idx, product in enumerate(invalid_products[:limit], 1):
            logger.info(f"\n--- Produit {idx} ---")
            logger.info(f"ID: {product.get('_doc_id', 'N/A')}")
            logger.info(f"Site: {product.get('site', 'N/A')}")
            logger.info(f"Titre: {product.get('title', 'N/A')[:60]}")
            logger.info(f"Prix: {product.get('price', 'MANQUANT')}")
            logger.info(f"Image: {product.get('image', 'MANQUANT')[:60] if product.get('image') else 'MANQUANT'}")
            logger.info(f"URL: {product.get('url', 'MANQUANT')[:60] if product.get('url') else 'MANQUANT'}")

            # Afficher les erreurs de validation
            is_valid, errors = ProductValidator.validate_product(product)
            if errors:
                logger.info("Erreurs:")
                for error in errors:
                    logger.info(f"  ❌ {error}")


def main():
    """Fonction principale"""
    logger.info("🚀 DÉMARRAGE DU NETTOYAGE FIREBASE\n")

    cleaner = FirebaseCleaner()

    # Analyser tous les produits
    valid_products, invalid_products = cleaner.analyze_products()

    # Afficher un échantillon de produits invalides
    cleaner.print_sample_invalid(invalid_products, limit=10)

    # Générer le rapport
    cleaner.generate_report(valid_products, invalid_products)

    # Demander confirmation pour la suppression
    if invalid_products:
        logger.info(f"\n⚠️ {len(invalid_products)} produits invalides détectés")
        delete = cleaner.delete_invalid_products(invalid_products, confirm=True)
        logger.info(f"\n✅ {delete} produits supprimés")
    else:
        logger.info("\n🎉 Aucun produit invalide trouvé! Base de données propre!")

    logger.info("\n✅ NETTOYAGE TERMINÉ\n")


if __name__ == "__main__":
    main()
