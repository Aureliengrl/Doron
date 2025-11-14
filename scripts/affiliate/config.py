#!/usr/bin/env python3
"""
Configuration pour les APIs d'affiliation
"""
import os
from dotenv import load_dotenv

load_dotenv()

# Amazon Associates
AMAZON_CONFIG = {
    "access_key": os.getenv("AMAZON_ACCESS_KEY"),
    "secret_key": os.getenv("AMAZON_SECRET_KEY"),
    "partner_tag": os.getenv("AMAZON_PARTNER_TAG"),
    "host": os.getenv("AMAZON_HOST", "webservices.amazon.fr"),
    "region": os.getenv("AMAZON_REGION", "eu-west-1")
}

# Awin
AWIN_CONFIG = {
    "api_token": os.getenv("AWIN_API_TOKEN"),
    "publisher_id": os.getenv("AWIN_PUBLISHER_ID"),
    "base_url": "https://productdata.awin.com"
}

# CJ Affiliate
CJ_CONFIG = {
    "api_token": os.getenv("CJ_API_TOKEN"),
    "website_id": os.getenv("CJ_WEBSITE_ID"),
    "base_url": "https://product-search.api.cj.com"
}

# Firebase
FIREBASE_CONFIG = {
    "service_account_path": os.getenv("FIREBASE_SERVICE_ACCOUNT_PATH", "../android/app/google-services.json")
}

# Liste des marques à récupérer par plateforme
BRANDS = {
    "amazon": [
        "Apple", "Samsung", "Sony", "Bose", "JBL", "Marshall", "Beats",
        "Nintendo", "PlayStation", "Xbox", "Razer",
        "Nike", "Adidas", "Puma", "New Balance", "Converse", "Vans",
        "Dyson", "KitchenAid", "Nespresso", "Le Creuset",
        "The Ordinary", "La Roche-Posay", "CeraVe", "Lush",
        "Pandora", "Swarovski", "Fossil",
        "Lego", "Kindle"
    ],
    "awin": [
        "Zara", "H&M", "Mango", "ASOS", "Zalando",
        "Sandro", "Maje", "Claudie Pierlot", "ba&sh",
        "Sephora", "Marionnaud",
        "IKEA", "Maisons du Monde"
    ],
    "cj": [
        "Nike", "Adidas", "Under Armour",
        "Sephora", "Ulta Beauty",
        "Macy's", "Nordstrom"
    ]
}

# Mapping catégories vers tags Doron
CATEGORY_MAPPING = {
    # Tech
    "Electronics": {"categories": ["tech"], "tags": ["tech"]},
    "Computers": {"categories": ["tech"], "tags": ["tech"]},
    "Cell Phones": {"categories": ["tech"], "tags": ["tech"]},
    "Audio": {"categories": ["tech"], "tags": ["tech"]},

    # Fashion
    "Clothing": {"categories": ["mode-fast-fashion"], "tags": ["fashion"]},
    "Shoes": {"categories": ["chaussures"], "tags": ["fashion"]},
    "Accessories": {"categories": ["maroquinerie"], "tags": ["fashion"]},
    "Bags": {"categories": ["bagages"], "tags": ["fashion"]},

    # Sport
    "Sports": {"categories": ["sport"], "tags": ["sports"]},
    "Outdoor": {"categories": ["sport"], "tags": ["sports"]},

    # Beauté
    "Beauty": {"categories": ["beaute"], "tags": ["beauty"]},
    "Skincare": {"categories": ["beaute"], "tags": ["beauty"]},
    "Fragrance": {"categories": ["parfums"], "tags": ["beauty"]},

    # Maison
    "Home": {"categories": ["electromenager"], "tags": ["home"]},
    "Kitchen": {"categories": ["electromenager"], "tags": ["home"]},

    # Gaming
    "Video Games": {"categories": ["gaming"], "tags": ["tech"]},

    # Bijoux
    "Jewelry": {"categories": ["bijoux"], "tags": ["fashion"]},
}

def validate_config():
    """Vérifie que toutes les clés API sont configurées"""
    missing = []

    if not AMAZON_CONFIG["access_key"]:
        missing.append("AMAZON_ACCESS_KEY")
    if not AMAZON_CONFIG["secret_key"]:
        missing.append("AMAZON_SECRET_KEY")
    if not AMAZON_CONFIG["partner_tag"]:
        missing.append("AMAZON_PARTNER_TAG")

    if not AWIN_CONFIG["api_token"]:
        missing.append("AWIN_API_TOKEN")
    if not AWIN_CONFIG["publisher_id"]:
        missing.append("AWIN_PUBLISHER_ID")

    if not CJ_CONFIG["api_token"]:
        missing.append("CJ_API_TOKEN")
    if not CJ_CONFIG["website_id"]:
        missing.append("CJ_WEBSITE_ID")

    return missing
