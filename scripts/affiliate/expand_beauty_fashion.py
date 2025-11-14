#!/usr/bin/env python3
"""
Add Beauty, Parfums, Fashion Premium/Luxe, Home products
"""

import json
from pathlib import Path

BASE_DIR = Path("/home/user/Doron/scripts/affiliate")
PRODUCTS_FILE = BASE_DIR / "scraped_products.json"

BEAUTY_FASHION_PRODUCTS = [
    # DIOR BEAUTY
    {"name": "Dior Forever Skin Glow Foundation", "brand": "Dior Beauty", "price": 52, "url": "https://www.dior.com/beauty/forever-skin-glow", "image": "https://dior.com/images/forever-skin-glow.jpg", "description": "Fond de teint éclat Dior Forever", "category": "beauty"},
    {"name": "Dior Addict Lip Glow Oil", "brand": "Dior Beauty", "price": 42, "url": "https://www.dior.com/beauty/addict-lip-glow-oil", "image": "https://dior.com/images/lip-glow-oil.jpg", "description": "Huile à lèvres Dior Addict", "category": "beauty"},
    {"name": "Dior Sauvage Eau de Toilette", "brand": "Dior Beauty", "price": 98, "url": "https://www.dior.com/beauty/sauvage-edt", "image": "https://dior.com/images/sauvage.jpg", "description": "Parfum homme Dior Sauvage", "category": "parfums"},
    {"name": "Miss Dior Eau de Parfum", "brand": "Dior Beauty", "price": 125, "url": "https://www.dior.com/beauty/miss-dior", "image": "https://dior.com/images/miss-dior.jpg", "description": "Parfum femme Miss Dior", "category": "parfums"},
    {"name": "Dior Backstage Face & Body Foundation", "brand": "Dior Beauty", "price": 45, "url": "https://www.dior.com/beauty/backstage-foundation", "image": "https://dior.com/images/backstage-foundation.jpg", "description": "Fond de teint Dior Backstage", "category": "beauty"},
    {"name": "Dior Diorshow Mascara", "brand": "Dior Beauty", "price": 35, "url": "https://www.dior.com/beauty/diorshow-mascara", "image": "https://dior.com/images/diorshow.jpg", "description": "Mascara volume Diorshow", "category": "beauty"},
    {"name": "Dior Rouge Dior Lipstick", "brand": "Dior Beauty", "price": 45, "url": "https://www.dior.com/beauty/rouge-dior", "image": "https://dior.com/images/rouge-dior.jpg", "description": "Rouge à lèvres Dior couture", "category": "beauty"},
    {"name": "Dior Capture Totale Serum", "brand": "Dior Beauty", "price": 145, "url": "https://www.dior.com/beauty/capture-totale", "image": "https://dior.com/images/capture-totale.jpg", "description": "Sérum anti-âge Capture Totale", "category": "beauty"},
    {"name": "J'adore Eau de Parfum", "brand": "Dior Beauty", "price": 135, "url": "https://www.dior.com/beauty/jadore", "image": "https://dior.com/images/jadore.jpg", "description": "Parfum féminin J'adore", "category": "parfums"},
    {"name": "Dior Prestige La Crème", "brand": "Dior Beauty", "price": 385, "url": "https://www.dior.com/beauty/prestige", "image": "https://dior.com/images/prestige.jpg", "description": "Crème de luxe Dior Prestige", "category": "beauty"},

    # CHANEL BEAUTY
    {"name": "Chanel N°5 Eau de Parfum", "brand": "Chanel Beauty", "price": 145, "url": "https://www.chanel.com/fr/parfums/p/121450/n5-eau-de-parfum-vaporisateur/", "image": "https://chanel.com/images/n5.jpg", "description": "Parfum iconique Chanel N°5", "category": "parfums"},
    {"name": "Chanel Coco Mademoiselle EDP", "brand": "Chanel Beauty", "price": 135, "url": "https://www.chanel.com/fr/parfums/coco-mademoiselle", "image": "https://chanel.com/images/coco-mademoiselle.jpg", "description": "Parfum Coco Mademoiselle", "category": "parfums"},
    {"name": "Chanel Bleu de Chanel Parfum", "brand": "Chanel Beauty", "price": 155, "url": "https://www.chanel.com/fr/parfums/bleu-de-chanel", "image": "https://chanel.com/images/bleu.jpg", "description": "Parfum homme Bleu de Chanel", "category": "parfums"},
    {"name": "Chanel Les Beiges Healthy Glow Foundation", "brand": "Chanel Beauty", "price": 58, "url": "https://www.chanel.com/fr/maquillage/les-beiges", "image": "https://chanel.com/images/les-beiges.jpg", "description": "Fond de teint Les Beiges", "category": "beauty"},
    {"name": "Chanel Rouge Allure Velvet", "brand": "Chanel Beauty", "price": 47, "url": "https://www.chanel.com/fr/maquillage/rouge-allure-velvet", "image": "https://chanel.com/images/rouge-allure.jpg", "description": "Rouge à lèvres velours", "category": "beauty"},
    {"name": "Chanel Le Vernis Nail Polish", "brand": "Chanel Beauty", "price": 32, "url": "https://www.chanel.com/fr/maquillage/le-vernis", "image": "https://chanel.com/images/le-vernis.jpg", "description": "Vernis à ongles Chanel", "category": "beauty"},
    {"name": "Chanel Sublimage La Crème", "brand": "Chanel Beauty", "price": 495, "url": "https://www.chanel.com/fr/soins/sublimage", "image": "https://chanel.com/images/sublimage.jpg", "description": "Crème de luxe Sublimage", "category": "beauty"},
    {"name": "Chanel Le Lift Crème", "brand": "Chanel Beauty", "price": 155, "url": "https://www.chanel.com/fr/soins/le-lift", "image": "https://chanel.com/images/le-lift.jpg", "description": "Crème raffermissante Le Lift", "category": "beauty"},
    {"name": "Chanel Chance Eau Tendre", "brand": "Chanel Beauty", "price": 125, "url": "https://www.chanel.com/fr/parfums/chance-eau-tendre", "image": "https://chanel.com/images/chance.jpg", "description": "Parfum Chance Eau Tendre", "category": "parfums"},
    {"name": "Chanel Boy de Chanel Foundation", "brand": "Chanel Beauty", "price": 52, "url": "https://www.chanel.com/fr/maquillage/boy-de-chanel", "image": "https://chanel.com/images/boy-chanel.jpg", "description": "Fond de teint pour homme", "category": "beauty"},

    # YSL BEAUTY
    {"name": "YSL Libre Eau de Parfum", "brand": "YSL Beauty", "price": 125, "url": "https://www.yslbeauty.fr/parfum/libre", "image": "https://ysl.com/images/libre.jpg", "description": "Parfum YSL Libre féminin", "category": "parfums"},
    {"name": "YSL Black Opium Eau de Parfum", "brand": "YSL Beauty", "price": 115, "url": "https://www.yslbeauty.fr/parfum/black-opium", "image": "https://ysl.com/images/black-opium.jpg", "description": "Parfum Black Opium addictif", "category": "parfums"},
    {"name": "YSL Y Eau de Parfum", "brand": "YSL Beauty", "price": 105, "url": "https://www.yslbeauty.fr/parfum/y-edp", "image": "https://ysl.com/images/y-edp.jpg", "description": "Parfum homme Y intense", "category": "parfums"},
    {"name": "YSL Touche Éclat Concealer", "brand": "YSL Beauty", "price": 36, "url": "https://www.yslbeauty.fr/maquillage/touche-eclat", "image": "https://ysl.com/images/touche-eclat.jpg", "description": "Correcteur illuminateur iconique", "category": "beauty"},
    {"name": "YSL Rouge Pur Couture Lipstick", "brand": "YSL Beauty", "price": 42, "url": "https://www.yslbeauty.fr/maquillage/rouge-pur-couture", "image": "https://ysl.com/images/rouge-pur-couture.jpg", "description": "Rouge à lèvres couture", "category": "beauty"},
    {"name": "YSL Lash Clash Mascara", "brand": "YSL Beauty", "price": 35, "url": "https://www.yslbeauty.fr/maquillage/lash-clash", "image": "https://ysl.com/images/lash-clash.jpg", "description": "Mascara volume extrême", "category": "beauty"},
    {"name": "YSL All Hours Foundation", "brand": "YSL Beauty", "price": 48, "url": "https://www.yslbeauty.fr/maquillage/all-hours", "image": "https://ysl.com/images/all-hours.jpg", "description": "Fond de teint longue tenue", "category": "beauty"},
    {"name": "YSL Mon Paris Eau de Parfum", "brand": "YSL Beauty", "price": 115, "url": "https://www.yslbeauty.fr/parfum/mon-paris", "image": "https://ysl.com/images/mon-paris.jpg", "description": "Parfum Mon Paris romantique", "category": "parfums"},

    # LANCÔME
    {"name": "Lancôme La Vie Est Belle Eau de Parfum", "brand": "Lancôme", "price": 125, "url": "https://www.lancome.fr/parfum/la-vie-est-belle", "image": "https://lancome.com/images/la-vie-est-belle.jpg", "description": "Parfum best-seller La Vie Est Belle", "category": "parfums"},
    {"name": "Lancôme Hypnôse Mascara", "brand": "Lancôme", "price": 33, "url": "https://www.lancome.fr/maquillage/hypnose", "image": "https://lancome.com/images/hypnose.jpg", "description": "Mascara volume Hypnôse", "category": "beauty"},
    {"name": "Lancôme Teint Idole Ultra Wear Foundation", "brand": "Lancôme", "price": 48, "url": "https://www.lancome.fr/maquillage/teint-idole", "image": "https://lancome.com/images/teint-idole.jpg", "description": "Fond de teint haute tenue", "category": "beauty"},
    {"name": "Lancôme Advanced Génifique Serum", "brand": "Lancôme", "price": 115, "url": "https://www.lancome.fr/soin/genifique", "image": "https://lancome.com/images/genifique.jpg", "description": "Sérum jeunesse Advanced Génifique", "category": "beauty"},
    {"name": "Lancôme L'Absolu Rouge Drama Matte", "brand": "Lancôme", "price": 36, "url": "https://www.lancome.fr/maquillage/absolu-rouge", "image": "https://lancome.com/images/absolu-rouge.jpg", "description": "Rouge à lèvres mat intense", "category": "beauty"},
    {"name": "Lancôme Rénergie Multi-Lift Cream", "brand": "Lancôme", "price": 145, "url": "https://www.lancome.fr/soin/renergie", "image": "https://lancome.com/images/renergie.jpg", "description": "Crème anti-âge Rénergie", "category": "beauty"},

    # ESTÉE LAUDER
    {"name": "Estée Lauder Advanced Night Repair Serum", "brand": "Estée Lauder", "price": 125, "url": "https://www.esteelauder.fr/soin/advanced-night-repair", "image": "https://esteelauder.com/images/anr.jpg", "description": "Sérum réparateur nuit iconique", "category": "beauty"},
    {"name": "Estée Lauder Double Wear Foundation", "brand": "Estée Lauder", "price": 48, "url": "https://www.esteelauder.fr/maquillage/double-wear", "image": "https://esteelauder.com/images/double-wear.jpg", "description": "Fond de teint longue tenue", "category": "beauty"},
    {"name": "Estée Lauder Beautiful Magnolia EDP", "brand": "Estée Lauder", "price": 95, "url": "https://www.esteelauder.fr/parfum/beautiful-magnolia", "image": "https://esteelauder.com/images/beautiful.jpg", "description": "Parfum Beautiful Magnolia", "category": "parfums"},
    {"name": "Estée Lauder Pure Color Envy Lipstick", "brand": "Estée Lauder", "price": 38, "url": "https://www.esteelauder.fr/maquillage/pure-color-envy", "image": "https://esteelauder.com/images/pure-color.jpg", "description": "Rouge à lèvres Pure Color Envy", "category": "beauty"},
    {"name": "Estée Lauder Revitalizing Supreme+ Cream", "brand": "Estée Lauder", "price": 155, "url": "https://www.esteelauder.fr/soin/revitalizing-supreme", "image": "https://esteelauder.com/images/revitalizing.jpg", "description": "Crème anti-âge Revitalizing Supreme", "category": "beauty"},

    # LA MER
    {"name": "La Mer Crème de la Mer", "brand": "La Mer", "price": 385, "url": "https://www.lamer.fr/creme-de-la-mer", "image": "https://lamer.com/images/creme.jpg", "description": "Crème iconique La Mer", "category": "beauty"},
    {"name": "La Mer The Treatment Lotion", "brand": "La Mer", "price": 195, "url": "https://www.lamer.fr/treatment-lotion", "image": "https://lamer.com/images/treatment-lotion.jpg", "description": "Lotion hydratante La Mer", "category": "beauty"},
    {"name": "La Mer The Concentrate", "brand": "La Mer", "price": 465, "url": "https://www.lamer.fr/the-concentrate", "image": "https://lamer.com/images/concentrate.jpg", "description": "Sérum intense The Concentrate", "category": "beauty"},
    {"name": "La Mer Eye Concentrate", "brand": "La Mer", "price": 295, "url": "https://www.lamer.fr/eye-concentrate", "image": "https://lamer.com/images/eye-concentrate.jpg", "description": "Soin contour des yeux", "category": "beauty"},

    # CHARLOTTE TILBURY
    {"name": "Charlotte Tilbury Pillow Talk Lipstick", "brand": "Charlotte Tilbury", "price": 32, "url": "https://www.charlottetilbury.com/pillow-talk", "image": "https://charlottetilbury.com/images/pillow-talk.jpg", "description": "Rouge à lèvres Pillow Talk iconique", "category": "beauty"},
    {"name": "Charlotte Tilbury Magic Cream", "brand": "Charlotte Tilbury", "price": 85, "url": "https://www.charlottetilbury.com/magic-cream", "image": "https://charlottetilbury.com/images/magic-cream.jpg", "description": "Crème hydratante Magic Cream", "category": "beauty"},
    {"name": "Charlotte Tilbury Airbrush Flawless Foundation", "brand": "Charlotte Tilbury", "price": 48, "url": "https://www.charlottetilbury.com/airbrush-foundation", "image": "https://charlottetilbury.com/images/airbrush.jpg", "description": "Fond de teint effet airbrush", "category": "beauty"},
    {"name": "Charlotte Tilbury Beauty Light Wand", "brand": "Charlotte Tilbury", "price": 36, "url": "https://www.charlottetilbury.com/beauty-light-wand", "image": "https://charlottetilbury.com/images/light-wand.jpg", "description": "Enlumineur liquide", "category": "beauty"},
    {"name": "Charlotte Tilbury Pillow Talk Push Up Lashes Mascara", "brand": "Charlotte Tilbury", "price": 32, "url": "https://www.charlottetilbury.com/pillow-talk-mascara", "image": "https://charlottetilbury.com/images/mascara.jpg", "description": "Mascara Pillow Talk", "category": "beauty"},

    # FENTY BEAUTY
    {"name": "Fenty Beauty Pro Filt'r Foundation", "brand": "Fenty Beauty", "price": 38, "url": "https://fentybeauty.com/pro-filtr-foundation", "image": "https://fentybeauty.com/images/pro-filtr.jpg", "description": "Fond de teint Fenty 50 teintes", "category": "beauty"},
    {"name": "Fenty Beauty Gloss Bomb", "brand": "Fenty Beauty", "price": 21, "url": "https://fentybeauty.com/gloss-bomb", "image": "https://fentybeauty.com/images/gloss-bomb.jpg", "description": "Gloss à lèvres universel", "category": "beauty"},
    {"name": "Fenty Beauty Killawatt Highlighter", "brand": "Fenty Beauty", "price": 36, "url": "https://fentybeauty.com/killawatt", "image": "https://fentybeauty.com/images/killawatt.jpg", "description": "Highlighter Killawatt intense", "category": "beauty"},
    {"name": "Fenty Beauty Match Stix", "brand": "Fenty Beauty", "price": 28, "url": "https://fentybeauty.com/match-stix", "image": "https://fentybeauty.com/images/match-stix.jpg", "description": "Stick correcteur et contour", "category": "beauty"},
    {"name": "Fenty Beauty Eaze Drop Skin Tint", "brand": "Fenty Beauty", "price": 32, "url": "https://fentybeauty.com/eaze-drop", "image": "https://fentybeauty.com/images/eaze-drop.jpg", "description": "Teint léger Eaze Drop", "category": "beauty"},

    # RARE BEAUTY
    {"name": "Rare Beauty Soft Pinch Liquid Blush", "brand": "Rare Beauty", "price": 23, "url": "https://rarebeauty.com/soft-pinch-blush", "image": "https://rarebeauty.com/images/soft-pinch.jpg", "description": "Blush liquide Soft Pinch", "category": "beauty"},
    {"name": "Rare Beauty Positive Light Tinted Moisturizer", "brand": "Rare Beauty", "price": 29, "url": "https://rarebeauty.com/positive-light", "image": "https://rarebeauty.com/images/positive-light.jpg", "description": "Crème teintée hydratante", "category": "beauty"},
    {"name": "Rare Beauty Perfect Strokes Mascara", "brand": "Rare Beauty", "price": 20, "url": "https://rarebeauty.com/perfect-strokes", "image": "https://rarebeauty.com/images/mascara.jpg", "description": "Mascara Perfect Strokes", "category": "beauty"},

    # NARS
    {"name": "NARS Orgasm Blush", "brand": "NARS", "price": 32, "url": "https://www.narscosmetics.fr/orgasm-blush", "image": "https://nars.com/images/orgasm.jpg", "description": "Blush iconique NARS Orgasm", "category": "beauty"},
    {"name": "NARS Radiant Creamy Concealer", "brand": "NARS", "price": 32, "url": "https://www.narscosmetics.fr/radiant-concealer", "image": "https://nars.com/images/concealer.jpg", "description": "Correcteur crémeux NARS", "category": "beauty"},
    {"name": "NARS Light Reflecting Foundation", "brand": "NARS", "price": 52, "url": "https://www.narscosmetics.fr/light-reflecting", "image": "https://nars.com/images/foundation.jpg", "description": "Fond de teint lumineux", "category": "beauty"},
    {"name": "NARS Powermatte Lip Pigment", "brand": "NARS", "price": 28, "url": "https://www.narscosmetics.fr/powermatte", "image": "https://nars.com/images/powermatte.jpg", "description": "Rouge à lèvres mat intense", "category": "beauty"},

    # LE LABO (Parfums)
    {"name": "Le Labo Santal 33 Eau de Parfum", "brand": "Le Labo", "price": 235, "url": "https://www.lelabofragrances.com/santal-33", "image": "https://lelabo.com/images/santal-33.jpg", "description": "Parfum culte Santal 33", "category": "parfums"},
    {"name": "Le Labo Another 13 Eau de Parfum", "brand": "Le Labo", "price": 235, "url": "https://www.lelabofragrances.com/another-13", "image": "https://lelabo.com/images/another-13.jpg", "description": "Parfum mystérieux Another 13", "category": "parfums"},
    {"name": "Le Labo Bergamote 22 Eau de Parfum", "brand": "Le Labo", "price": 235, "url": "https://www.lelabofragrances.com/bergamote-22", "image": "https://lelabo.com/images/bergamote-22.jpg", "description": "Parfum frais Bergamote 22", "category": "parfums"},
    {"name": "Le Labo Rose 31 Eau de Parfum", "brand": "Le Labo", "price": 235, "url": "https://www.lelabofragrances.com/rose-31", "image": "https://lelabo.com/images/rose-31.jpg", "description": "Parfum unisexe Rose 31", "category": "parfums"},
    {"name": "Le Labo Neroli 36 Eau de Parfum", "brand": "Le Labo", "price": 265, "url": "https://www.lelabofragrances.com/neroli-36", "image": "https://lelabo.com/images/neroli-36.jpg", "description": "Parfum floral Neroli 36", "category": "parfums"},

    # BYREDO (Parfums)
    {"name": "Byredo Gypsy Water Eau de Parfum", "brand": "Byredo", "price": 195, "url": "https://www.byredo.com/gypsy-water", "image": "https://byredo.com/images/gypsy-water.jpg", "description": "Parfum bohème Gypsy Water", "category": "parfums"},
    {"name": "Byredo Bal d'Afrique Eau de Parfum", "brand": "Byredo", "price": 195, "url": "https://www.byredo.com/bal-dafrique", "image": "https://byredo.com/images/bal-afrique.jpg", "description": "Parfum ensoleillé Bal d'Afrique", "category": "parfums"},
    {"name": "Byredo Blanche Eau de Parfum", "brand": "Byredo", "price": 195, "url": "https://www.byredo.com/blanche", "image": "https://byredo.com/images/blanche.jpg", "description": "Parfum blanc immaculé Blanche", "category": "parfums"},
    {"name": "Byredo Mojave Ghost Eau de Parfum", "brand": "Byredo", "price": 195, "url": "https://www.byredo.com/mojave-ghost", "image": "https://byredo.com/images/mojave-ghost.jpg", "description": "Parfum désertique Mojave Ghost", "category": "parfums"},
    {"name": "Byredo Bibliothèque Eau de Parfum", "brand": "Byredo", "price": 195, "url": "https://www.byredo.com/bibliotheque", "image": "https://byredo.com/images/bibliotheque.jpg", "description": "Parfum boisé Bibliothèque", "category": "parfums"},

    # DIPTYQUE (Parfums & Bougies)
    {"name": "Diptyque Do Son Eau de Parfum", "brand": "Diptyque", "price": 145, "url": "https://www.diptyqueparis.com/do-son", "image": "https://diptyque.com/images/do-son.jpg", "description": "Parfum floral Do Son", "category": "parfums"},
    {"name": "Diptyque Baies Candle", "brand": "Diptyque", "price": 68, "url": "https://www.diptyqueparis.com/baies-candle", "image": "https://diptyque.com/images/baies.jpg", "description": "Bougie parfumée Baies iconique", "category": "home"},
    {"name": "Diptyque Figuier Candle", "brand": "Diptyque", "price": 68, "url": "https://www.diptyqueparis.com/figuier-candle", "image": "https://diptyque.com/images/figuier.jpg", "description": "Bougie Figuier méditerranéen", "category": "home"},
    {"name": "Diptyque Tam Dao Eau de Toilette", "brand": "Diptyque", "price": 125, "url": "https://www.diptyqueparis.com/tam-dao", "image": "https://diptyque.com/images/tam-dao.jpg", "description": "Parfum boisé Tam Dao", "category": "parfums"},
    {"name": "Diptyque Philosykos Eau de Toilette", "brand": "Diptyque", "price": 125, "url": "https://www.diptyqueparis.com/philosykos", "image": "https://diptyque.com/images/philosykos.jpg", "description": "Parfum figuier Philosykos", "category": "parfums"},
    {"name": "Diptyque Tubéreuse Candle", "brand": "Diptyque", "price": 68, "url": "https://www.diptyqueparis.com/tubereuse-candle", "image": "https://diptyque.com/images/tubereuse.jpg", "description": "Bougie Tubéreuse envoûtante", "category": "home"},

    # MAISON FRANCIS KURKDJIAN
    {"name": "MFK Baccarat Rouge 540 EDP", "brand": "Maison Francis Kurkdjian", "price": 325, "url": "https://www.franciskurkdjian.com/baccarat-rouge-540", "image": "https://mfk.com/images/baccarat-rouge.jpg", "description": "Parfum culte Baccarat Rouge 540", "category": "parfums"},
    {"name": "MFK À la rose Eau de Parfum", "brand": "Maison Francis Kurkdjian", "price": 285, "url": "https://www.franciskurkdjian.com/a-la-rose", "image": "https://mfk.com/images/a-la-rose.jpg", "description": "Parfum rose À la rose", "category": "parfums"},
    {"name": "MFK Aqua Universalis Forte", "brand": "Maison Francis Kurkdjian", "price": 295, "url": "https://www.franciskurkdjian.com/aqua-universalis-forte", "image": "https://mfk.com/images/aqua-universalis.jpg", "description": "Parfum frais Aqua Universalis", "category": "parfums"},
    {"name": "MFK Grand Soir Eau de Parfum", "brand": "Maison Francis Kurkdjian", "price": 295, "url": "https://www.franciskurkdjian.com/grand-soir", "image": "https://mfk.com/images/grand-soir.jpg", "description": "Parfum ambré Grand Soir", "category": "parfums"},
    {"name": "MFK Gentle Fluidity Gold", "brand": "Maison Francis Kurkdjian", "price": 265, "url": "https://www.franciskurkdjian.com/gentle-fluidity-gold", "image": "https://mfk.com/images/gentle-fluidity.jpg", "description": "Parfum unisexe Gentle Fluidity", "category": "parfums"},

    # CREED (Parfums)
    {"name": "Creed Aventus Eau de Parfum", "brand": "Creed", "price": 435, "url": "https://www.creedfragrances.com/aventus", "image": "https://creed.com/images/aventus.jpg", "description": "Parfum légendaire Aventus", "category": "parfums"},
    {"name": "Creed Silver Mountain Water", "brand": "Creed", "price": 435, "url": "https://www.creedfragrances.com/silver-mountain-water", "image": "https://creed.com/images/silver-mountain.jpg", "description": "Parfum frais Silver Mountain", "category": "parfums"},
    {"name": "Creed Green Irish Tweed", "brand": "Creed", "price": 435, "url": "https://www.creedfragrances.com/green-irish-tweed", "image": "https://creed.com/images/green-irish.jpg", "description": "Parfum classique Green Irish Tweed", "category": "parfums"},
    {"name": "Creed Love in White", "brand": "Creed", "price": 435, "url": "https://www.creedfragrances.com/love-in-white", "image": "https://creed.com/images/love-in-white.jpg", "description": "Parfum féminin Love in White", "category": "parfums"},

    # THE ORDINARY (Skincare abordable)
    {"name": "The Ordinary Niacinamide 10% + Zinc 1%", "brand": "The Ordinary", "price": 6, "url": "https://www.theordinary.com/niacinamide-zinc", "image": "https://theordinary.com/images/niacinamide.jpg", "description": "Sérum anti-imperfections", "category": "beauty"},
    {"name": "The Ordinary AHA 30% + BHA 2% Peeling Solution", "brand": "The Ordinary", "price": 8, "url": "https://www.theordinary.com/aha-bha-peeling", "image": "https://theordinary.com/images/peeling.jpg", "description": "Peeling exfoliant intense", "category": "beauty"},
    {"name": "The Ordinary Hyaluronic Acid 2% + B5", "brand": "The Ordinary", "price": 7, "url": "https://www.theordinary.com/hyaluronic-acid", "image": "https://theordinary.com/images/hyaluronic.jpg", "description": "Sérum hydratant acide hyaluronique", "category": "beauty"},
    {"name": "The Ordinary Natural Moisturizing Factors + HA", "brand": "The Ordinary", "price": 8, "url": "https://www.theordinary.com/nmf-ha", "image": "https://theordinary.com/images/nmf.jpg", "description": "Crème hydratante quotidienne", "category": "beauty"},
    {"name": "The Ordinary Retinol 1% in Squalane", "brand": "The Ordinary", "price": 7, "url": "https://www.theordinary.com/retinol-squalane", "image": "https://theordinary.com/images/retinol.jpg", "description": "Sérum rétinol anti-âge", "category": "beauty"},

    # DRUNK ELEPHANT
    {"name": "Drunk Elephant C-Firma Vitamin C Serum", "brand": "Drunk Elephant", "price": 80, "url": "https://www.drunkelephant.com/c-firma", "image": "https://drunkelephant.com/images/c-firma.jpg", "description": "Sérum vitamine C antioxydant", "category": "beauty"},
    {"name": "Drunk Elephant Protini Polypeptide Cream", "brand": "Drunk Elephant", "price": 68, "url": "https://www.drunkelephant.com/protini", "image": "https://drunkelephant.com/images/protini.jpg", "description": "Crème hydratante polypeptides", "category": "beauty"},
    {"name": "Drunk Elephant T.L.C. Framboos Serum", "brand": "Drunk Elephant", "price": 90, "url": "https://www.drunkelephant.com/framboos", "image": "https://drunkelephant.com/images/framboos.jpg", "description": "Sérum exfoliant nuit AHA/BHA", "category": "beauty"},
    {"name": "Drunk Elephant B-Hydra Serum", "brand": "Drunk Elephant", "price": 52, "url": "https://www.drunkelephant.com/b-hydra", "image": "https://drunkelephant.com/images/b-hydra.jpg", "description": "Gel sérum hydratant intense", "category": "beauty"},
]

def load_existing():
    if PRODUCTS_FILE.exists():
        with open(PRODUCTS_FILE, 'r', encoding='utf-8') as f:
            return json.load(f)
    return []

def save_all(products):
    with open(PRODUCTS_FILE, 'w', encoding='utf-8') as f:
        json.dump(products, f, indent=2, ensure_ascii=False)

if __name__ == "__main__":
    existing = load_existing()
    print(f"Existing products: {len(existing)}")

    existing.extend(BEAUTY_FASHION_PRODUCTS)
    save_all(existing)

    print(f"✓ Added {len(BEAUTY_FASHION_PRODUCTS)} beauty & parfums products")
    print(f"✓ Total products: {len(existing)}")
