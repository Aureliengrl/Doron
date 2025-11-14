#!/usr/bin/env python3
"""
Script intelligent pour générer de vrais bestsellers via OpenAI API
Pour chaque marque (390 marques), récupère 10 bestsellers avec vraies URLs et images
"""

import json
import time
import sys
from pathlib import Path
from typing import List, Dict, Any
import firebase_admin
from firebase_admin import credentials, firestore
from openai import OpenAI

# Configuration
import os
OPENAI_API_KEY = os.getenv('OPENAI_API_KEY', '')  # À définir dans l'environnement
if not OPENAI_API_KEY:
    print("⚠️  ATTENTION: Clé API OpenAI non définie!")
    print("   Définissez la variable d'environnement OPENAI_API_KEY")
    print("   Exemple: export OPENAI_API_KEY='votre_clé'")

FIREBASE_CRED_PATH = "../serviceAccountKey.json"
OUTPUT_FILE = "real_bestsellers_complete.json"

# Liste complète des 390 marques
BRANDS = [
    'Zara', 'Zara Men', 'Zara Women', 'Zara Home', 'H&M', 'Mango', 'Stradivarius',
    'Bershka', 'Pull & Bear', 'Massimo Dutti', 'Uniqlo', 'COS', 'Arket', 'Weekday',
    '& Other Stories', 'Sézane', 'Sandro', 'Maje', 'Claudie Pierlot', 'ba&sh',
    'The Kooples', 'A.P.C.', 'AMI Paris', 'Isabel Marant', 'Jacquemus', 'Reformation',
    'Ganni', 'Totême', 'Anine Bing', 'The Frankie Shop', 'Acne Studios', 'Lemaire',
    'Officine Générale', 'Maison Margiela', 'Saint Laurent', 'Louis Vuitton', 'Dior',
    'Chanel', 'Gucci', 'Prada', 'Miu Miu', 'Fendi', 'Celine', 'Balenciaga', 'Loewe',
    'Valentino', 'Givenchy', 'Burberry', 'Alexander McQueen', 'Versace', 'Balmain',
    'Bottega Veneta', 'Hermès', 'Alaïa', 'JW Anderson', 'Rick Owens', 'Tom Ford',
    'Golden Goose', 'Off-White', 'Palm Angels', 'Fear of God', 'Rhude', 'Aime Leon Dore',
    'Stone Island', 'C.P. Company', 'Carhartt WIP', 'Stüssy', 'Kith', 'Supreme',
    'Moncler', 'Canada Goose', "Arc'teryx", 'The North Face', 'Patagonia', 'Fusalp',
    'Rossignol', 'On Running', 'HOKA', 'Lululemon', 'Alo Yoga', 'Gymshark', 'Nike',
    'Adidas', 'Jordan', 'New Balance', 'Puma', 'Asics', 'Salomon', 'Veja', 'Autry',
    'Common Projects', 'Axel Arigato', 'Converse', 'Vans', 'Maison Kitsuné', 'Balibaris',
    'Le Slip Français', 'Faguo', 'American Vintage', 'Soeur', 'Sessùn', 'Maison Labiche',
    'De Bonne Facture', 'Le Bon Marché', 'Galeries Lafayette', 'Printemps', 'La Redoute',
    'La Samaritaine', 'Selfridges', 'Harrods', 'El Corte Inglés', 'IKEA', 'Maisons du Monde',
    'H&M Home', 'Habitat', 'Alinéa', 'Made.com', 'Vitra', 'Hay', 'Muuto', 'Ferm Living',
    'Kartell', 'Tom Dixon', 'Alessi', 'Flos', 'Artemide', 'Dyson', 'SMEG', 'KitchenAid',
    'Nespresso', "De'Longhi", 'Moccamaster', 'Le Creuset', 'Staub', 'Riedel',
    'Le Petit Lunetier', 'Ray-Ban', 'Persol', 'Oliver Peoples', 'Warby Parker',
    'Cutler and Gross', 'Linda Farrow', 'Polène', 'Lancel', 'Longchamp', 'Cuyana',
    'Coach', 'MCM', 'Rimowa', 'Tumi', 'Away', 'Samsonite', 'Delsey', 'Briggs & Riley',
    'Montblanc', 'Bellroy', 'Nomad Goods', 'Peak Design', 'Native Union', 'Mujjo',
    'Apple', 'Samsung', 'Google Pixel', 'Dyson Tech', 'Bose', 'Sony', 'JBL', 'Marshall',
    'Bang & Olufsen', 'Bowers & Wilkins', 'Sennheiser', 'Devialet', 'Nothing', 'GoPro',
    'DJI', 'Withings', 'Garmin', 'Kindle', 'PlayStation', 'Xbox', 'Nintendo', 'Logitech G',
    'Razer', 'SteelSeries', 'Secretlab', 'Scuf', 'Bell', 'POC', 'Giro', 'Kask', 'HJC',
    'Shark', 'Eram', 'Jonak', 'Minelli', 'Bocage', 'Dr. Martens', 'Paraboot', 'J.M. Weston',
    "Tod's", "Church's", 'Santoni', 'Hogan', 'Gianvito Rossi', 'Amina Muaddi', 'Aquazzura',
    'Roger Vivier', 'By Far', 'Pandora', 'Swarovski', 'Tiffany & Co.', 'Cartier',
    'Van Cleef & Arpels', 'Bulgari', 'Messika', 'Chaumet', 'Fred', 'Dinh Van', 'Repossi',
    'Aristocrazy', 'Maison Cléo', 'Le Labo', 'Byredo', 'Diptyque', 'Maison Francis Kurkdjian',
    'Kilian Paris', 'Creed', 'Parfums de Marly', 'BDK Parfums', 'DS & Durga',
    'Jo Malone London', 'Aesop', 'Cire Trudon', 'Acqua di Parma', 'Dior Beauty',
    'Chanel Beauty', 'YSL Beauty', 'Lancôme', 'Estée Lauder', 'La Mer', 'La Prairie',
    'Guerlain', 'Shiseido', 'Charlotte Tilbury', 'Armani Beauty', 'Hourglass', 'NARS',
    'Pat McGrath Labs', 'Fenty Beauty', 'Rare Beauty', 'Tatcha', 'Dr. Barbara Sturm',
    'Augustinus Bader', 'SkinCeuticals', 'Drunk Elephant', 'Summer Fridays', 'Sephora',
    'Marionnaud', 'Nocibé', 'LookFantastic', 'Cult Beauty', 'FeelUnique', "Kiehl's",
    'The Ordinary', "Paula's Choice", 'Glossier', 'Rituals', "L'Occitane", 'The Body Shop',
    'Rituals Home', 'Zara Home Parfum', 'Amazon', 'Zalando', 'Asos', 'Farfetch',
    'Net-A-Porter', 'MyTheresa', 'SSENSE', 'MatchesFashion', 'END Clothing', 'Mr Porter',
    'Browns Fashion', 'StockX', 'GOAT', 'Chrono24', 'Back Market', 'Rakuten', 'Cdiscount',
    'Nature & Découvertes', 'Fnac', 'Darty', 'Boulanger', 'Cultura', 'Apple Store',
    'Decathlon', 'Go Sport', 'Courir', 'Foot Locker', 'JD Sports', 'Lush', 'Yves Rocher',
    'KIKO Milano', 'La Maison du Chocolat', 'Pierre Hermé', 'Ladurée', 'Fauchon',
    'Angelina', 'Pierre Marcolini', 'Godiva', 'Venchi', 'Patrick Roger', 'Maison Plisson',
    'Kusmi Tea', 'Mariage Frères', 'Dammann Frères', 'Sephora Collection', 'Diptyque Bougies',
    'Byredo Home', 'Cire Trudon Bougies', 'Vitra Home', 'Hay Design', 'Ferm Living',
    'Muuto Design', 'Alessi Home', 'Tom Dixon Home', 'IKEA Premium', 'Maisons du Monde Cadeaux',
    'Zara Home Déco', 'H&M Home Cadeaux', 'Smeg Electro', 'Dyson Hair', 'Dyson Purifier',
    'Apple Watch', 'iPhone', 'iPad', 'AirPods', 'MacBook', 'Beats by Dre', 'Bose Headphones',
    'Sony XM5', 'Bang & Olufsen Beoplay', 'Devialet Phantom', 'JBL Partybox', 'GoPro Hero 12',
    'DJI Mini 4 Pro', 'Garmin Fenix', 'Withings Scanwatch', 'Kindle Paperwhite',
    'Playstation 5', 'Xbox Series X', 'Nintendo Switch OLED', 'Secretlab Titan Evo',
    'Logitech MX', 'Razer Blackwidow', 'SteelSeries Arctis', 'Sezane Maison',
    'Nature & Découvertes Bien-être', 'Rituals Home Sets', "L'Occitane Coffrets",
    'Kusmi Tea Coffrets', 'Fauchon Coffrets', 'Ladurée Coffrets', 'Le Slip Français Coffrets',
    'Polène Paris', 'Tumi', 'Rimowa', 'Away', 'Montblanc', 'Nomad Goods', 'Native Union',
    'Bellroy', 'Peak Design', 'Muji', 'Monoprix Sélection Cadeaux', 'Printemps Luxe',
    'Galeries Lafayette Luxe', 'Le Bon Marché Sélection', 'La Redoute Intérieurs',
    'Promod', 'Kippa', 'Rhode', 'Tom Ford Beauty', 'Rhode Skin', 'IKEA Cadeaux'
]

class BestsellerGenerator:
    def __init__(self):
        self.client = OpenAI(api_key=OPENAI_API_KEY)
        self.all_products = []
        self.processed_brands = 0

    def get_bestsellers_for_brand(self, brand: str, retry: int = 3) -> List[Dict[str, Any]]:
        """Récupère 10 bestsellers pour une marque via OpenAI"""

        prompt = f"""Tu es un expert en e-commerce et retail. Je veux que tu me donnes EXACTEMENT 10 bestsellers réels et populaires de la marque "{brand}".

IMPORTANT:
- Donne des produits QUI EXISTENT VRAIMENT et sont vendus actuellement
- Pour chaque produit, fournis:
  * product_title: Nom exact du produit (ex: "Nike Air Max 90")
  * product_price: Prix en euros (nombre uniquement, ex: 129.99)
  * product_url: URL RÉELLE vers la page du produit sur le site officiel de la marque ou un revendeur fiable (Amazon, Zalando, etc.)
  * product_photo: URL RÉELLE d'une image du produit (essaie de trouver une URL directe vers l'image)
  * tags: Liste de 3-5 tags pertinents (ex: ["mode", "chaussures", "sport", "streetwear"])
  * gender: "homme", "femme", "unisexe" ou "enfant"
  * category: catégorie principale (ex: "vêtements", "chaussures", "accessoires", "tech", "beauté", "maison")

Réponds UNIQUEMENT avec un JSON valide au format:
{{
  "products": [
    {{
      "product_title": "...",
      "product_price": "...",
      "product_url": "https://...",
      "product_photo": "https://...",
      "tags": ["tag1", "tag2", "tag3"],
      "gender": "...",
      "category": "..."
    }}
  ]
}}

NE GÉNÈRE PAS d'URLs fictives. Utilise de vraies URLs de produits.
Si tu ne peux pas trouver 10 produits avec de vraies URLs, donne-en autant que possible avec de vraies données."""

        for attempt in range(retry):
            try:
                print(f"  Tentative {attempt + 1}/{retry} pour {brand}...")

                response = self.client.chat.completions.create(
                    model="gpt-4o-mini",  # Modèle plus rapide et moins cher
                    messages=[
                        {"role": "system", "content": "Tu es un expert en e-commerce. Tu fournis des données de produits réels avec de vraies URLs."},
                        {"role": "user", "content": prompt}
                    ],
                    temperature=0.7,
                    max_tokens=2000
                )

                content = response.choices[0].message.content.strip()

                # Extraire le JSON du contenu (parfois il y a du texte avant/après)
                if "```json" in content:
                    content = content.split("```json")[1].split("```")[0].strip()
                elif "```" in content:
                    content = content.split("```")[1].split("```")[0].strip()

                data = json.loads(content)
                products = data.get("products", [])

                if not products:
                    print(f"  ⚠️  Aucun produit retourné pour {brand}")
                    continue

                # Ajouter la marque à chaque produit
                for product in products:
                    product["platform"] = brand
                    product["product_star_rating"] = "4.5"  # Rating par défaut
                    product["product_num_ratings"] = 1000  # Nombre de ratings par défaut

                    # S'assurer que tous les champs sont présents
                    if not product.get("tags"):
                        product["tags"] = ["cadeau"]
                    if not product.get("gender"):
                        product["gender"] = "unisexe"
                    if not product.get("category"):
                        product["category"] = "autres"

                print(f"  ✅ {len(products)} produits récupérés pour {brand}")
                return products

            except json.JSONDecodeError as e:
                print(f"  ❌ Erreur JSON pour {brand}: {e}")
                if attempt == retry - 1:
                    print(f"  Content reçu: {content[:200]}...")
                time.sleep(2)

            except Exception as e:
                print(f"  ❌ Erreur pour {brand}: {e}")
                if attempt < retry - 1:
                    time.sleep(2)

        print(f"  ⚠️  Impossible de récupérer les produits pour {brand} après {retry} tentatives")
        return []

    def generate_all_bestsellers(self, start_from: int = 0, max_brands: int = None):
        """Génère les bestsellers pour toutes les marques"""

        brands_to_process = BRANDS[start_from:start_from + max_brands] if max_brands else BRANDS[start_from:]
        total_brands = len(brands_to_process)

        print(f"\n🚀 Démarrage de la génération pour {total_brands} marques")
        print(f"   Marques {start_from + 1} à {start_from + total_brands} sur {len(BRANDS)}\n")

        for idx, brand in enumerate(brands_to_process, 1):
            print(f"\n[{idx}/{total_brands}] 🏷️  Traitement de: {brand}")

            products = self.get_bestsellers_for_brand(brand)

            if products:
                self.all_products.extend(products)
                self.processed_brands += 1

                # Sauvegarder tous les 10 marques
                if idx % 10 == 0:
                    self.save_progress()
                    print(f"\n💾 Sauvegarde intermédiaire: {len(self.all_products)} produits")

            # Rate limiting: pause pour éviter de surcharger l'API
            if idx < total_brands:
                time.sleep(1)  # 1 seconde entre chaque appel

        print(f"\n✅ Génération terminée!")
        print(f"   {self.processed_brands} marques traitées")
        print(f"   {len(self.all_products)} produits générés")

        self.save_progress()

    def save_progress(self):
        """Sauvegarde les produits générés"""
        output_path = Path(__file__).parent / OUTPUT_FILE

        data = {
            "total_products": len(self.all_products),
            "total_brands": self.processed_brands,
            "generated_at": time.strftime("%Y-%m-%d %H:%M:%S"),
            "products": self.all_products
        }

        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)

        print(f"   💾 Sauvegardé dans: {output_path}")

    def upload_to_firebase(self):
        """Upload les produits vers Firebase"""

        print("\n🔥 Upload vers Firebase...")

        try:
            # Initialiser Firebase
            cred_path = Path(__file__).parent / FIREBASE_CRED_PATH
            cred = credentials.Certificate(str(cred_path))

            if not firebase_admin._apps:
                firebase_admin.initialize_app(cred)

            db = firestore.client()

            # Supprimer les anciens produits
            print("   🗑️  Suppression des anciens produits...")
            products_ref = db.collection('products')
            batch_size = 500

            while True:
                docs = products_ref.limit(batch_size).stream()
                deleted = 0

                for doc in docs:
                    doc.reference.delete()
                    deleted += 1

                if deleted < batch_size:
                    break

            print(f"   ✅ Anciens produits supprimés")

            # Uploader les nouveaux produits par batch
            print(f"   📤 Upload de {len(self.all_products)} produits...")

            batch = db.batch()
            batch_count = 0

            for idx, product in enumerate(self.all_products):
                doc_ref = products_ref.document()
                batch.set(doc_ref, product)
                batch_count += 1

                # Commit tous les 500 produits (limite Firestore)
                if batch_count >= 500:
                    batch.commit()
                    print(f"      Uploaded {idx + 1}/{len(self.all_products)} produits...")
                    batch = db.batch()
                    batch_count = 0

            # Commit le dernier batch
            if batch_count > 0:
                batch.commit()

            print(f"   ✅ {len(self.all_products)} produits uploadés vers Firebase!")

        except Exception as e:
            print(f"   ❌ Erreur lors de l'upload Firebase: {e}")
            raise


def main():
    """Point d'entrée principal"""

    print("=" * 80)
    print("🎁 GÉNÉRATEUR DE BESTSELLERS RÉELS VIA OPENAI")
    print("=" * 80)

    # Paramètres
    start_from = int(sys.argv[1]) if len(sys.argv) > 1 else 0
    max_brands = int(sys.argv[2]) if len(sys.argv) > 2 else None
    upload_firebase = "--upload" in sys.argv or "-u" in sys.argv

    generator = BestsellerGenerator()

    # Générer les bestsellers
    generator.generate_all_bestsellers(start_from=start_from, max_brands=max_brands)

    # Upload vers Firebase si demandé
    if upload_firebase:
        generator.upload_to_firebase()
    else:
        print(f"\n💡 Pour uploader vers Firebase, relancez avec: python {sys.argv[0]} --upload")

    print("\n✨ Terminé!")


if __name__ == "__main__":
    main()
