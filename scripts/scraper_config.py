"""
Configuration for the massive product scraping system
This file contains all brand information, categories, and scraping strategies
"""

# Brand categories and their associated tags
BRAND_CATEGORIES = {
    # Fast Fashion & Affordable
    "zara": {"category": "mode", "tags": ["tendance", "moderne", "accessible"], "gender": "mixte", "budget": "€€"},
    "zara_men": {"category": "mode", "tags": ["homme", "tendance", "moderne"], "gender": "homme", "budget": "€€"},
    "zara_women": {"category": "mode", "tags": ["femme", "tendance", "élégant"], "gender": "femme", "budget": "€€"},
    "zara_home": {"category": "déco", "tags": ["maison", "moderne", "design"], "gender": "mixte", "budget": "€€"},
    "h&m": {"category": "mode", "tags": ["tendance", "jeune", "accessible"], "gender": "mixte", "budget": "€"},
    "mango": {"category": "mode", "tags": ["élégant", "femme", "tendance"], "gender": "femme", "budget": "€€"},
    "stradivarius": {"category": "mode", "tags": ["jeune", "tendance", "décontracté"], "gender": "femme", "budget": "€"},
    "bershka": {"category": "mode", "tags": ["jeune", "street", "tendance"], "gender": "mixte", "budget": "€"},
    "pull&bear": {"category": "mode", "tags": ["décontracté", "jeune", "sport"], "gender": "mixte", "budget": "€"},
    "massimo_dutti": {"category": "mode", "tags": ["élégant", "raffiné", "professionnel"], "gender": "mixte", "budget": "€€€"},
    "uniqlo": {"category": "mode", "tags": ["basique", "qualité", "minimaliste"], "gender": "mixte", "budget": "€€"},
    "cos": {"category": "mode", "tags": ["minimaliste", "design", "moderne"], "gender": "mixte", "budget": "€€€"},
    "arket": {"category": "mode", "tags": ["durable", "minimaliste", "nordique"], "gender": "mixte", "budget": "€€€"},

    # French Contemporary
    "sezane": {"category": "mode", "tags": ["parisien", "chic", "femme"], "gender": "femme", "budget": "€€€"},
    "sandro": {"category": "mode", "tags": ["parisien", "élégant", "raffiné"], "gender": "mixte", "budget": "€€€€"},
    "maje": {"category": "mode", "tags": ["parisien", "femme", "élégant"], "gender": "femme", "budget": "€€€€"},
    "claudie_pierlot": {"category": "mode", "tags": ["parisien", "féminin", "raffiné"], "gender": "femme", "budget": "€€€€"},
    "ba&sh": {"category": "mode", "tags": ["bohème", "chic", "femme"], "gender": "femme", "budget": "€€€€"},
    "the_kooples": {"category": "mode", "tags": ["rock", "chic", "moderne"], "gender": "mixte", "budget": "€€€€"},
    "apc": {"category": "mode", "tags": ["minimaliste", "parisien", "qualité"], "gender": "mixte", "budget": "€€€€"},
    "ami_paris": {"category": "mode", "tags": ["décontracté", "chic", "parisien"], "gender": "homme", "budget": "€€€€"},

    # Luxury & Designer
    "louis_vuitton": {"category": "luxe", "tags": ["luxe", "prestige", "maroquinerie"], "gender": "mixte", "budget": "€€€€€"},
    "dior": {"category": "luxe", "tags": ["luxe", "élégance", "prestige"], "gender": "mixte", "budget": "€€€€€"},
    "chanel": {"category": "luxe", "tags": ["luxe", "iconique", "prestige"], "gender": "femme", "budget": "€€€€€"},
    "gucci": {"category": "luxe", "tags": ["luxe", "italien", "mode"], "gender": "mixte", "budget": "€€€€€"},
    "hermes": {"category": "luxe", "tags": ["luxe", "maroquinerie", "prestige"], "gender": "mixte", "budget": "€€€€€"},

    # Beauty & Cosmetics
    "sephora": {"category": "beauté", "tags": ["maquillage", "soin", "beauté"], "gender": "mixte", "budget": "€€€"},
    "marionnaud": {"category": "beauté", "tags": ["parfum", "beauté", "soin"], "gender": "mixte", "budget": "€€"},
    "loccitane": {"category": "beauté", "tags": ["naturel", "provence", "soin"], "gender": "mixte", "budget": "€€€"},
    "rituals": {"category": "beauté", "tags": ["bien-être", "luxe", "spa"], "gender": "mixte", "budget": "€€€"},

    # Home & Decoration
    "ikea": {"category": "déco", "tags": ["maison", "moderne", "accessible"], "gender": "mixte", "budget": "€€"},
    "maisons_du_monde": {"category": "déco", "tags": ["décoration", "bohème", "maison"], "gender": "mixte", "budget": "€€€"},
    "habitat": {"category": "déco", "tags": ["design", "moderne", "maison"], "gender": "mixte", "budget": "€€€"},
    "hay": {"category": "déco", "tags": ["design", "scandinave", "moderne"], "gender": "mixte", "budget": "€€€€"},

    # Tech & Electronics
    "apple": {"category": "tech", "tags": ["technologie", "innovation", "premium"], "gender": "mixte", "budget": "€€€€€"},
    "samsung": {"category": "tech", "tags": ["technologie", "innovation", "électronique"], "gender": "mixte", "budget": "€€€€"},
    "bose": {"category": "tech", "tags": ["audio", "qualité", "technologie"], "gender": "mixte", "budget": "€€€€"},
    "sony": {"category": "tech", "tags": ["électronique", "audio", "gaming"], "gender": "mixte", "budget": "€€€€"},
    "dyson": {"category": "tech", "tags": ["innovation", "design", "maison"], "gender": "mixte", "budget": "€€€€€"},

    # Sports & Outdoor
    "nike": {"category": "sport", "tags": ["sport", "streetwear", "performance"], "gender": "mixte", "budget": "€€€"},
    "adidas": {"category": "sport", "tags": ["sport", "streetwear", "lifestyle"], "gender": "mixte", "budget": "€€€"},
    "lululemon": {"category": "sport", "tags": ["yoga", "wellness", "premium"], "gender": "mixte", "budget": "€€€€"},
    "patagonia": {"category": "sport", "tags": ["outdoor", "durable", "nature"], "gender": "mixte", "budget": "€€€€"},
    "north_face": {"category": "sport", "tags": ["outdoor", "montagne", "performance"], "gender": "mixte", "budget": "€€€€"},

    # Jewelry & Accessories
    "pandora": {"category": "bijoux", "tags": ["bijoux", "féminin", "personnalisable"], "gender": "femme", "budget": "€€€"},
    "swarovski": {"category": "bijoux", "tags": ["cristal", "bijoux", "élégant"], "gender": "femme", "budget": "€€€€"},

    # Food & Gourmet
    "pierre_herme": {"category": "gourmand", "tags": ["pâtisserie", "luxe", "gastronomie"], "gender": "mixte", "budget": "€€€€"},
    "laduree": {"category": "gourmand", "tags": ["macarons", "pâtisserie", "parisien"], "gender": "mixte", "budget": "€€€€"},
    "kusmi_tea": {"category": "gourmand", "tags": ["thé", "bien-être", "cadeau"], "gender": "mixte", "budget": "€€€"},
}

# Age range mappings
AGE_RANGES = {
    "enfant": "0-12",
    "ado": "13-17",
    "jeune": "18-25",
    "adulte": "26-45",
    "senior": "46+"
}

# Style categories
STYLES = [
    "classique", "moderne", "bohème", "streetwear", "élégant",
    "décontracté", "minimaliste", "vintage", "sport", "luxe"
]

# Occasion tags
OCCASIONS = [
    "anniversaire", "noël", "saint-valentin", "fête des mères",
    "fête des pères", "mariage", "pendaison de crémaillère", "quotidien"
]

# Gender mappings
GENDERS = {
    "homme": ["homme", "masculin", "men"],
    "femme": ["femme", "féminin", "women", "woman"],
    "mixte": ["unisexe", "mixte", "tous"]
}
