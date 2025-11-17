"""
Configuration des sites e-commerce avec sélecteurs CSS optimisés
Chaque site a des sélecteurs spécifiques pour extraire les données produits
"""

# Configuration Firebase
FIREBASE_CREDENTIALS = "firebase_credentials.json"
FIREBASE_COLLECTION = "products"

# Paramètres de scraping
MAX_RETRIES = 3
RETRY_DELAY = 2  # secondes
REQUEST_TIMEOUT = 15  # secondes
USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

# Configuration des sites à scraper
SITES_CONFIG = {
    "amazon": {
        "name": "Amazon",
        "base_url": "https://www.amazon.fr",
        "selectors": {
            "product_card": "div[data-component-type='s-search-result']",
            "title": "h2.a-size-mini span",
            "price": [
                "span.a-price span.a-offscreen",
                "span.a-price-whole",
                "span[data-a-color='price'] span.a-offscreen"
            ],
            "image": [
                "img.s-image",
                "div.s-product-image-container img"
            ],
            "url": "h2 a.a-link-normal",
            "rating": "span.a-icon-alt",
            "category": "span.a-badge-text"
        },
        "search_params": {
            "k": "{query}",  # keyword
            "ref": "nb_sb_noss"
        }
    },

    "cdiscount": {
        "name": "Cdiscount",
        "base_url": "https://www.cdiscount.com",
        "selectors": {
            "product_card": "div.prdtBIL",
            "title": "a.prdtBTitle",
            "price": [
                "span.price",
                "div.prdtPrce span"
            ],
            "image": [
                "img.prdtBImg",
                "div.prdtBILTbl img"
            ],
            "url": "a.prdtBTitle",
            "rating": "div.stars span",
            "category": "span.prdtBrand"
        },
        "search_params": {
            "q": "{query}"
        }
    },

    "fnac": {
        "name": "Fnac",
        "base_url": "https://www.fnac.com",
        "selectors": {
            "product_card": "article.Article-itemGroup",
            "title": "p.Article-title a",
            "price": [
                "div.Article-price span.price",
                "div.price-box span.f-priceBox-price"
            ],
            "image": [
                "img.Article-img",
                "div.Article-thumbnail img"
            ],
            "url": "a.Article-itemLink",
            "rating": "div.f-rating span",
            "category": "span.Article-category"
        },
        "search_params": {
            "q": "{query}"
        }
    },

    "darty": {
        "name": "Darty",
        "base_url": "https://www.darty.com",
        "selectors": {
            "product_card": "div.product_item",
            "title": "a.product_name",
            "price": [
                "span.product_price",
                "div.price span"
            ],
            "image": [
                "img.product_img",
                "div.product_visual img"
            ],
            "url": "a.product_link",
            "rating": "div.rating span",
            "category": "span.product_category"
        },
        "search_params": {
            "q": "{query}"
        }
    },

    "boulanger": {
        "name": "Boulanger",
        "base_url": "https://www.boulanger.com",
        "selectors": {
            "product_card": "div.product-card",
            "title": "h3.product-title a",
            "price": [
                "span.price-value",
                "div.product-price span.price"
            ],
            "image": [
                "img.product-image",
                "div.product-visual img"
            ],
            "url": "a.product-link",
            "rating": "div.product-rating span",
            "category": "span.product-brand"
        },
        "search_params": {
            "q": "{query}"
        }
    }
}

# Validation stricte - tous ces champs DOIVENT être présents
REQUIRED_FIELDS = [
    "title",
    "price",
    "image",
    "url",
    "site"
]

# Champs optionnels
OPTIONAL_FIELDS = [
    "rating",
    "category",
    "description"
]

# Règles de validation
VALIDATION_RULES = {
    "title": {
        "min_length": 5,
        "max_length": 500,
        "required": True
    },
    "price": {
        "min_value": 0.01,
        "max_value": 999999.99,
        "required": True,
        "type": "float"
    },
    "image": {
        "min_length": 10,
        "required": True,
        "must_start_with": ["http://", "https://", "//"]
    },
    "url": {
        "min_length": 10,
        "required": True,
        "must_start_with": ["http://", "https://"]
    }
}

# Log files
SCRAPING_LOG_FILE = "scraping_strict_log.txt"
CLEANUP_LOG_FILE = "cleanup_log.txt"
