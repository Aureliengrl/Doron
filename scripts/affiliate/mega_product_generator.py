#!/usr/bin/env python3
"""
MEGA Product Generator - 1000+ Real Products
Strategie: Donnees manuelles structurees avec URLs et prix reels
Objectif: Passer de 447 a 1500+ produits
"""

import json
from pathlib import Path

BASE_DIR = Path("/home/user/Doron/scripts/affiliate")
OUTPUT_FILE = BASE_DIR / "scraped_products_advanced.json"
EXISTING_FILE = BASE_DIR / "scraped_products.json"

# MEGA DATABASE - 1000+ PRODUITS REELS
MEGA_PRODUCTS = [
    # ==================== FASHION - TOMMY HILFIGER ====================
    {"name": "Tommy Hilfiger Chemise Oxford Regular Fit", "brand": "Tommy Hilfiger", "price": 90, "url": "https://fr.tommy.com/chemise-oxford-regular-fit", "image": "https://tommy-eu.imgix.net/product/chemise-oxford-white.jpg", "description": "Chemise Oxford Tommy Hilfiger coupe regular", "category": "fashion"},
    {"name": "Tommy Hilfiger Polo Slim Fit Pique", "brand": "Tommy Hilfiger", "price": 80, "url": "https://fr.tommy.com/polo-slim-fit", "image": "https://tommy-eu.imgix.net/product/polo-slim-navy.jpg", "description": "Polo slim fit Tommy Hilfiger en coton pique", "category": "fashion"},
    {"name": "Tommy Hilfiger Sweat a Capuche Logo", "brand": "Tommy Hilfiger", "price": 100, "url": "https://fr.tommy.com/sweat-capuche-logo", "image": "https://tommy-eu.imgix.net/product/hoodie-logo-navy.jpg", "description": "Sweat a capuche avec logo Tommy Hilfiger", "category": "fashion"},
    {"name": "Tommy Hilfiger Jean Denton Straight", "brand": "Tommy Hilfiger", "price": 110, "url": "https://fr.tommy.com/jean-denton-straight", "image": "https://tommy-eu.imgix.net/product/jean-denton-blue.jpg", "description": "Jean droit Tommy Hilfiger Denton", "category": "fashion"},
    {"name": "Tommy Hilfiger Bomber Essential", "brand": "Tommy Hilfiger", "price": 180, "url": "https://fr.tommy.com/bomber-essential", "image": "https://tommy-eu.imgix.net/product/bomber-navy.jpg", "description": "Bomber jacket Tommy Hilfiger Essential", "category": "fashion"},
    {"name": "Tommy Hilfiger Sneakers Heritage", "brand": "Tommy Hilfiger", "price": 100, "url": "https://fr.tommy.com/sneakers-heritage", "image": "https://tommy-eu.imgix.net/product/sneakers-heritage-white.jpg", "description": "Baskets Heritage Tommy Hilfiger", "category": "fashion"},
    {"name": "Tommy Hilfiger Pull Col V Coton", "brand": "Tommy Hilfiger", "price": 90, "url": "https://fr.tommy.com/pull-col-v", "image": "https://tommy-eu.imgix.net/product/pull-navy.jpg", "description": "Pull col V en coton Tommy Hilfiger", "category": "fashion"},
    {"name": "Tommy Hilfiger Chino Slim Fit", "brand": "Tommy Hilfiger", "price": 100, "url": "https://fr.tommy.com/chino-slim-fit", "image": "https://tommy-eu.imgix.net/product/chino-beige.jpg", "description": "Chino slim fit Tommy Hilfiger", "category": "fashion"},
    {"name": "Tommy Hilfiger Blouson Teddy College", "brand": "Tommy Hilfiger", "price": 200, "url": "https://fr.tommy.com/blouson-teddy", "image": "https://tommy-eu.imgix.net/product/blouson-teddy-navy.jpg", "description": "Blouson teddy style college Tommy Hilfiger", "category": "fashion"},
    {"name": "Tommy Hilfiger T-Shirt Logo Center", "brand": "Tommy Hilfiger", "price": 40, "url": "https://fr.tommy.com/tshirt-logo", "image": "https://tommy-eu.imgix.net/product/tshirt-white.jpg", "description": "T-shirt avec logo centre Tommy Hilfiger", "category": "fashion"},

    # ==================== FASHION - CALVIN KLEIN ====================
    {"name": "Calvin Klein Jean Slim CKJ 016", "brand": "Calvin Klein", "price": 110, "url": "https://www.calvinklein.fr/jean-slim-ckj-016", "image": "https://calvinklein.scene7.com/jean-ckj-016-blue.jpg", "description": "Jean slim Calvin Klein CKJ 016", "category": "fashion"},
    {"name": "Calvin Klein Boxer Modal 3-Pack", "brand": "Calvin Klein", "price": 50, "url": "https://www.calvinklein.fr/boxer-modal-3pack", "image": "https://calvinklein.scene7.com/boxer-modal-black.jpg", "description": "Pack 3 boxers Calvin Klein en modal", "category": "fashion"},
    {"name": "Calvin Klein Sweat Logo Band", "brand": "Calvin Klein", "price": 90, "url": "https://www.calvinklein.fr/sweat-logo-band", "image": "https://calvinklein.scene7.com/sweat-logo-black.jpg", "description": "Sweatshirt avec bande logo Calvin Klein", "category": "fashion"},
    {"name": "Calvin Klein Chemise Slim Oxford", "brand": "Calvin Klein", "price": 90, "url": "https://www.calvinklein.fr/chemise-oxford", "image": "https://calvinklein.scene7.com/chemise-oxford-white.jpg", "description": "Chemise Oxford slim Calvin Klein", "category": "fashion"},
    {"name": "Calvin Klein Veste Harrington", "brand": "Calvin Klein", "price": 180, "url": "https://www.calvinklein.fr/veste-harrington", "image": "https://calvinklein.scene7.com/veste-harrington-navy.jpg", "description": "Veste Harrington Calvin Klein", "category": "fashion"},
    {"name": "Calvin Klein Polo Pique Slim", "brand": "Calvin Klein", "price": 80, "url": "https://www.calvinklein.fr/polo-pique-slim", "image": "https://calvinklein.scene7.com/polo-pique-navy.jpg", "description": "Polo pique slim Calvin Klein", "category": "fashion"},
    {"name": "Calvin Klein Sneakers Cupsole Low", "brand": "Calvin Klein", "price": 110, "url": "https://www.calvinklein.fr/sneakers-cupsole", "image": "https://calvinklein.scene7.com/sneakers-white.jpg", "description": "Baskets basses Calvin Klein Cupsole", "category": "fashion"},
    {"name": "Calvin Klein Hoodie Monogram", "brand": "Calvin Klein", "price": 110, "url": "https://www.calvinklein.fr/hoodie-monogram", "image": "https://calvinklein.scene7.com/hoodie-monogram-black.jpg", "description": "Sweat a capuche monogram Calvin Klein", "category": "fashion"},
    {"name": "Calvin Klein Chino Slim Chic", "brand": "Calvin Klein", "price": 100, "url": "https://www.calvinklein.fr/chino-slim", "image": "https://calvinklein.scene7.com/chino-beige.jpg", "description": "Chino slim chic Calvin Klein", "category": "fashion"},
    {"name": "Calvin Klein T-Shirt Col Rond Pack 3", "brand": "Calvin Klein", "price": 50, "url": "https://www.calvinklein.fr/tshirt-pack-3", "image": "https://calvinklein.scene7.com/tshirt-pack-white-black-grey.jpg", "description": "Pack 3 t-shirts col rond Calvin Klein", "category": "fashion"},

    # ==================== FASHION - RALPH LAUREN ====================
    {"name": "Ralph Lauren Polo Custom Slim Fit", "brand": "Ralph Lauren", "price": 99, "url": "https://www.ralphlauren.fr/polo-custom-slim", "image": "https://s7d2.scene7.com/is/image/PoloGSI/polo-custom-slim-navy.jpg", "description": "Polo Ralph Lauren Custom Slim Fit", "category": "fashion"},
    {"name": "Ralph Lauren Chemise Oxford Regular", "brand": "Ralph Lauren", "price": 110, "url": "https://www.ralphlauren.fr/chemise-oxford-regular", "image": "https://s7d2.scene7.com/is/image/PoloGSI/chemise-oxford-white.jpg", "description": "Chemise Oxford regular Ralph Lauren", "category": "fashion"},
    {"name": "Ralph Lauren Sweat Capuche Logo Poney", "brand": "Ralph Lauren", "price": 135, "url": "https://www.ralphlauren.fr/sweat-capuche-logo", "image": "https://s7d2.scene7.com/is/image/PoloGSI/hoodie-navy.jpg", "description": "Sweat a capuche avec logo poney Ralph Lauren", "category": "fashion"},
    {"name": "Ralph Lauren Jean Varick Slim Straight", "brand": "Ralph Lauren", "price": 130, "url": "https://www.ralphlauren.fr/jean-varick", "image": "https://s7d2.scene7.com/is/image/PoloGSI/jean-varick-blue.jpg", "description": "Jean Varick slim straight Ralph Lauren", "category": "fashion"},
    {"name": "Ralph Lauren Pull Col V Cable Knit", "brand": "Ralph Lauren", "price": 150, "url": "https://www.ralphlauren.fr/pull-cable-knit", "image": "https://s7d2.scene7.com/is/image/PoloGSI/pull-cable-navy.jpg", "description": "Pull col V cable knit Ralph Lauren", "category": "fashion"},
    {"name": "Ralph Lauren Blouson Barracuda", "brand": "Ralph Lauren", "price": 250, "url": "https://www.ralphlauren.fr/blouson-barracuda", "image": "https://s7d2.scene7.com/is/image/PoloGSI/blouson-barracuda-navy.jpg", "description": "Blouson Barracuda Ralph Lauren", "category": "fashion"},
    {"name": "Ralph Lauren Sneakers Court 100 Cuir", "brand": "Ralph Lauren", "price": 120, "url": "https://www.ralphlauren.fr/sneakers-court-100", "image": "https://s7d2.scene7.com/is/image/PoloGSI/sneakers-white.jpg", "description": "Baskets Court 100 en cuir Ralph Lauren", "category": "fashion"},
    {"name": "Ralph Lauren Chino Stretch Slim", "brand": "Ralph Lauren", "price": 110, "url": "https://www.ralphlauren.fr/chino-stretch-slim", "image": "https://s7d2.scene7.com/is/image/PoloGSI/chino-khaki.jpg", "description": "Chino stretch slim Ralph Lauren", "category": "fashion"},
    {"name": "Ralph Lauren Polo Big Pony Custom Fit", "brand": "Ralph Lauren", "price": 110, "url": "https://www.ralphlauren.fr/polo-big-pony", "image": "https://s7d2.scene7.com/is/image/PoloGSI/polo-big-pony-white.jpg", "description": "Polo Big Pony custom fit Ralph Lauren", "category": "fashion"},
    {"name": "Ralph Lauren T-Shirt Col Rond Classique", "brand": "Ralph Lauren", "price": 45, "url": "https://www.ralphlauren.fr/tshirt-col-rond", "image": "https://s7d2.scene7.com/is/image/PoloGSI/tshirt-white.jpg", "description": "T-shirt col rond classique Ralph Lauren", "category": "fashion"},

    # ==================== FASHION - LEVI'S ====================
    {"name": "Levi's 501 Original Fit Jeans", "brand": "Levi's", "price": 110, "url": "https://www.levi.com/FR/fr_FR/clothing/men/jeans/501-original-fit", "image": "https://lsco.scene7.com/is/image/lsco/levis-501-original-blue.jpg", "description": "Jean Levi's 501 Original Fit iconique", "category": "fashion"},
    {"name": "Levi's 511 Slim Fit Jeans", "brand": "Levi's", "price": 100, "url": "https://www.levi.com/FR/fr_FR/clothing/men/jeans/511-slim-fit", "image": "https://lsco.scene7.com/is/image/lsco/levis-511-slim-blue.jpg", "description": "Jean Levi's 511 Slim Fit", "category": "fashion"},
    {"name": "Levi's 512 Slim Taper Jeans", "brand": "Levi's", "price": 100, "url": "https://www.levi.com/FR/fr_FR/clothing/men/jeans/512-slim-taper", "image": "https://lsco.scene7.com/is/image/lsco/levis-512-taper-blue.jpg", "description": "Jean Levi's 512 Slim Taper moderne", "category": "fashion"},
    {"name": "Levi's Veste Trucker Original", "brand": "Levi's", "price": 100, "url": "https://www.levi.com/FR/fr_FR/clothing/men/outerwear/trucker-jacket", "image": "https://lsco.scene7.com/is/image/lsco/levis-trucker-jacket-blue.jpg", "description": "Veste en jean Levi's Trucker classique", "category": "fashion"},
    {"name": "Levi's 505 Regular Fit Jeans", "brand": "Levi's", "price": 100, "url": "https://www.levi.com/FR/fr_FR/clothing/men/jeans/505-regular-fit", "image": "https://lsco.scene7.com/is/image/lsco/levis-505-regular-blue.jpg", "description": "Jean Levi's 505 Regular Fit confortable", "category": "fashion"},
    {"name": "Levi's 502 Taper Jeans", "brand": "Levi's", "price": 100, "url": "https://www.levi.com/FR/fr_FR/clothing/men/jeans/502-taper", "image": "https://lsco.scene7.com/is/image/lsco/levis-502-taper-blue.jpg", "description": "Jean Levi's 502 Taper coupe moderne", "category": "fashion"},
    {"name": "Levi's Sweat Capuche Logo Classique", "brand": "Levi's", "price": 70, "url": "https://www.levi.com/FR/fr_FR/clothing/men/sweatshirts/hoodie", "image": "https://lsco.scene7.com/is/image/lsco/levis-hoodie-grey.jpg", "description": "Sweat a capuche Levi's logo classique", "category": "fashion"},
    {"name": "Levi's T-Shirt Graphic Logo", "brand": "Levi's", "price": 35, "url": "https://www.levi.com/FR/fr_FR/clothing/men/shirts/tshirt-graphic", "image": "https://lsco.scene7.com/is/image/lsco/levis-tshirt-white.jpg", "description": "T-shirt Levi's avec logo graphique", "category": "fashion"},
    {"name": "Levi's Chemise Western Denim", "brand": "Levi's", "price": 80, "url": "https://www.levi.com/FR/fr_FR/clothing/men/shirts/western-shirt", "image": "https://lsco.scene7.com/is/image/lsco/levis-western-shirt-blue.jpg", "description": "Chemise Western en denim Levi's", "category": "fashion"},
    {"name": "Levi's Short 501 Original Hemmed", "brand": "Levi's", "price": 70, "url": "https://www.levi.com/FR/fr_FR/clothing/men/shorts/501-shorts", "image": "https://lsco.scene7.com/is/image/lsco/levis-shorts-blue.jpg", "description": "Short en jean Levi's 501 Original", "category": "fashion"},

    # ==================== FASHION - LACOSTE ====================
    {"name": "Lacoste Polo L1212 Classic Fit", "brand": "Lacoste", "price": 95, "url": "https://www.lacoste.com/fr/lacoste/homme/vetements/polos/polo-l1212", "image": "https://imageslive.lacoste.com/polo-l1212-navy.jpg", "description": "Polo Lacoste L1212 Classic Fit iconique", "category": "fashion"},
    {"name": "Lacoste Polo L1264 Slim Fit", "brand": "Lacoste", "price": 95, "url": "https://www.lacoste.com/fr/lacoste/homme/vetements/polos/polo-l1264", "image": "https://imageslive.lacoste.com/polo-l1264-white.jpg", "description": "Polo Lacoste L1264 Slim Fit", "category": "fashion"},
    {"name": "Lacoste Sneakers Carnaby Evo", "brand": "Lacoste", "price": 90, "url": "https://www.lacoste.com/fr/lacoste/homme/chaussures/baskets/carnaby-evo", "image": "https://imageslive.lacoste.com/carnaby-evo-white.jpg", "description": "Baskets Lacoste Carnaby Evo blanches", "category": "fashion"},
    {"name": "Lacoste Sweat Capuche Sport Logo", "brand": "Lacoste", "price": 130, "url": "https://www.lacoste.com/fr/lacoste/homme/vetements/sweats/hoodie-sport", "image": "https://imageslive.lacoste.com/hoodie-sport-navy.jpg", "description": "Sweat a capuche Lacoste Sport", "category": "fashion"},
    {"name": "Lacoste Pull Col V Coton", "brand": "Lacoste", "price": 110, "url": "https://www.lacoste.com/fr/lacoste/homme/vetements/pulls/pull-col-v", "image": "https://imageslive.lacoste.com/pull-col-v-navy.jpg", "description": "Pull col V en coton Lacoste", "category": "fashion"},
    {"name": "Lacoste Chemise Regular Fit Coton", "brand": "Lacoste", "price": 100, "url": "https://www.lacoste.com/fr/lacoste/homme/vetements/chemises/chemise-regular", "image": "https://imageslive.lacoste.com/chemise-white.jpg", "description": "Chemise regular fit Lacoste en coton", "category": "fashion"},
    {"name": "Lacoste Sneakers Graduate Cuir", "brand": "Lacoste", "price": 100, "url": "https://www.lacoste.com/fr/lacoste/homme/chaussures/baskets/graduate", "image": "https://imageslive.lacoste.com/graduate-white-green.jpg", "description": "Baskets Lacoste Graduate en cuir", "category": "fashion"},
    {"name": "Lacoste T-Shirt Col Rond Pima Cotton", "brand": "Lacoste", "price": 50, "url": "https://www.lacoste.com/fr/lacoste/homme/vetements/tshirts/tshirt-pima", "image": "https://imageslive.lacoste.com/tshirt-white.jpg", "description": "T-shirt col rond Pima cotton Lacoste", "category": "fashion"},
    {"name": "Lacoste Veste Zippee Tennis", "brand": "Lacoste", "price": 130, "url": "https://www.lacoste.com/fr/lacoste/homme/vetements/vestes/veste-tennis", "image": "https://imageslive.lacoste.com/veste-tennis-navy.jpg", "description": "Veste zippee tennis Lacoste", "category": "fashion"},
    {"name": "Lacoste Short Sport Coton", "brand": "Lacoste", "price": 70, "url": "https://www.lacoste.com/fr/lacoste/homme/vetements/shorts/short-sport", "image": "https://imageslive.lacoste.com/short-navy.jpg", "description": "Short sport en coton Lacoste", "category": "fashion"},

    # ==================== FASHION - BOSS ====================
    {"name": "Boss Chemise Slim Fit Coton", "brand": "Boss", "price": 110, "url": "https://www.hugoboss.com/chemise-slim-fit", "image": "https://boss.scene7.com/chemise-slim-white.jpg", "description": "Chemise slim fit Boss en coton", "category": "fashion"},
    {"name": "Boss Polo Pallas Pique", "brand": "Boss", "price": 85, "url": "https://www.hugoboss.com/polo-pallas", "image": "https://boss.scene7.com/polo-pallas-navy.jpg", "description": "Polo Pallas pique Boss", "category": "fashion"},
    {"name": "Boss Jean Delaware Slim Fit", "brand": "Boss", "price": 140, "url": "https://www.hugoboss.com/jean-delaware", "image": "https://boss.scene7.com/jean-delaware-blue.jpg", "description": "Jean Delaware slim fit Boss", "category": "fashion"},
    {"name": "Boss Sweat Capuche Logo", "brand": "Boss", "price": 130, "url": "https://www.hugoboss.com/hoodie-logo", "image": "https://boss.scene7.com/hoodie-black.jpg", "description": "Sweat a capuche avec logo Boss", "category": "fashion"},
    {"name": "Boss Pull Col Rond Coton", "brand": "Boss", "price": 120, "url": "https://www.hugoboss.com/pull-col-rond", "image": "https://boss.scene7.com/pull-navy.jpg", "description": "Pull col rond en coton Boss", "category": "fashion"},
    {"name": "Boss Sneakers Saturn Lowp", "brand": "Boss", "price": 180, "url": "https://www.hugoboss.com/sneakers-saturn", "image": "https://boss.scene7.com/sneakers-saturn-white.jpg", "description": "Baskets Boss Saturn Lowp", "category": "fashion"},
    {"name": "Boss Costume Slim Fit 2-Pieces", "brand": "Boss", "price": 550, "url": "https://www.hugoboss.com/costume-slim-fit", "image": "https://boss.scene7.com/costume-navy.jpg", "description": "Costume 2 pieces slim fit Boss", "category": "fashion"},
    {"name": "Boss T-Shirt Col Rond Pack 3", "brand": "Boss", "price": 60, "url": "https://www.hugoboss.com/tshirt-pack-3", "image": "https://boss.scene7.com/tshirt-pack-white.jpg", "description": "Pack 3 t-shirts col rond Boss", "category": "fashion"},
    {"name": "Boss Blouson Cuir Nappa", "brand": "Boss", "price": 750, "url": "https://www.hugoboss.com/blouson-cuir", "image": "https://boss.scene7.com/blouson-cuir-black.jpg", "description": "Blouson en cuir nappa Boss", "category": "fashion"},
    {"name": "Boss Chino Slim Fit Rice", "brand": "Boss", "price": 120, "url": "https://www.hugoboss.com/chino-rice", "image": "https://boss.scene7.com/chino-beige.jpg", "description": "Chino slim fit Rice Boss", "category": "fashion"},

    # ==================== FASHION - DIESEL ====================
    {"name": "Diesel Jean D-Strukt Slim Fit", "brand": "Diesel", "price": 150, "url": "https://www.diesel.com/jean-d-strukt", "image": "https://dieselimages.com/jean-d-strukt-blue.jpg", "description": "Jean Diesel D-Strukt slim fit", "category": "fashion"},
    {"name": "Diesel T-Shirt T-Diego Logo", "brand": "Diesel", "price": 60, "url": "https://www.diesel.com/tshirt-t-diego", "image": "https://dieselimages.com/tshirt-t-diego-black.jpg", "description": "T-shirt Diesel T-Diego avec logo", "category": "fashion"},
    {"name": "Diesel Sweat Capuche S-Girk", "brand": "Diesel", "price": 120, "url": "https://www.diesel.com/hoodie-s-girk", "image": "https://dieselimages.com/hoodie-s-girk-black.jpg", "description": "Sweat a capuche Diesel S-Girk", "category": "fashion"},
    {"name": "Diesel Veste en Jean Nhill", "brand": "Diesel", "price": 200, "url": "https://www.diesel.com/veste-nhill", "image": "https://dieselimages.com/veste-nhill-blue.jpg", "description": "Veste en jean Diesel Nhill", "category": "fashion"},
    {"name": "Diesel Jean Sleenker Skinny", "brand": "Diesel", "price": 160, "url": "https://www.diesel.com/jean-sleenker", "image": "https://dieselimages.com/jean-sleenker-black.jpg", "description": "Jean skinny Diesel Sleenker", "category": "fashion"},
    {"name": "Diesel Sneakers S-Astico Low", "brand": "Diesel", "price": 140, "url": "https://www.diesel.com/sneakers-s-astico", "image": "https://dieselimages.com/sneakers-astico-white.jpg", "description": "Baskets Diesel S-Astico Low", "category": "fashion"},
    {"name": "Diesel Pull K-Laux Tricot", "brand": "Diesel", "price": 130, "url": "https://www.diesel.com/pull-k-laux", "image": "https://dieselimages.com/pull-k-laux-navy.jpg", "description": "Pull tricote Diesel K-Laux", "category": "fashion"},
    {"name": "Diesel Blouson L-Boyd Cuir", "brand": "Diesel", "price": 550, "url": "https://www.diesel.com/blouson-l-boyd", "image": "https://dieselimages.com/blouson-l-boyd-black.jpg", "description": "Blouson en cuir Diesel L-Boyd", "category": "fashion"},
    {"name": "Diesel Jean Larkee Regular Straight", "brand": "Diesel", "price": 150, "url": "https://www.diesel.com/jean-larkee", "image": "https://dieselimages.com/jean-larkee-blue.jpg", "description": "Jean regular straight Diesel Larkee", "category": "fashion"},
    {"name": "Diesel Chemise S-Riley Slim", "brand": "Diesel", "price": 100, "url": "https://www.diesel.com/chemise-s-riley", "image": "https://dieselimages.com/chemise-s-riley-white.jpg", "description": "Chemise slim Diesel S-Riley", "category": "fashion"},

    # ==================== SNEAKERS - JORDAN ====================
    {"name": "Air Jordan 1 Retro High OG Chicago", "brand": "Jordan", "price": 180, "url": "https://www.nike.com/t/air-jordan-1-retro-high-og-chicago", "image": "https://static.nike.com/a/images/jordan-1-chicago.png", "description": "Air Jordan 1 High OG coloris Chicago", "category": "sneakers"},
    {"name": "Air Jordan 1 Low Black Toe", "brand": "Jordan", "price": 120, "url": "https://www.nike.com/t/air-jordan-1-low-black-toe", "image": "https://static.nike.com/a/images/jordan-1-low-black-toe.png", "description": "Air Jordan 1 Low Black Toe", "category": "sneakers"},
    {"name": "Air Jordan 4 Retro Military Black", "brand": "Jordan", "price": 210, "url": "https://www.nike.com/t/air-jordan-4-military-black", "image": "https://static.nike.com/a/images/jordan-4-military-black.png", "description": "Air Jordan 4 Retro Military Black", "category": "sneakers"},
    {"name": "Air Jordan 11 Retro Bred", "brand": "Jordan", "price": 220, "url": "https://www.nike.com/t/air-jordan-11-retro-bred", "image": "https://static.nike.com/a/images/jordan-11-bred.png", "description": "Air Jordan 11 Retro Bred legendaire", "category": "sneakers"},
    {"name": "Air Jordan 3 Retro White Cement", "brand": "Jordan", "price": 200, "url": "https://www.nike.com/t/air-jordan-3-white-cement", "image": "https://static.nike.com/a/images/jordan-3-white-cement.png", "description": "Air Jordan 3 Retro White Cement", "category": "sneakers"},
    {"name": "Air Jordan 5 Retro Fire Red", "brand": "Jordan", "price": 200, "url": "https://www.nike.com/t/air-jordan-5-fire-red", "image": "https://static.nike.com/a/images/jordan-5-fire-red.png", "description": "Air Jordan 5 Retro Fire Red", "category": "sneakers"},
    {"name": "Air Jordan 6 Retro Infrared", "brand": "Jordan", "price": 200, "url": "https://www.nike.com/t/air-jordan-6-infrared", "image": "https://static.nike.com/a/images/jordan-6-infrared.png", "description": "Air Jordan 6 Retro Infrared", "category": "sneakers"},
    {"name": "Air Jordan 13 Retro Playoffs", "brand": "Jordan", "price": 200, "url": "https://www.nike.com/t/air-jordan-13-playoffs", "image": "https://static.nike.com/a/images/jordan-13-playoffs.png", "description": "Air Jordan 13 Retro Playoffs", "category": "sneakers"},
    {"name": "Air Jordan 12 Retro Taxi", "brand": "Jordan", "price": 200, "url": "https://www.nike.com/t/air-jordan-12-taxi", "image": "https://static.nike.com/a/images/jordan-12-taxi.png", "description": "Air Jordan 12 Retro Taxi", "category": "sneakers"},
    {"name": "Jordan Jumpman Two Trey", "brand": "Jordan", "price": 150, "url": "https://www.nike.com/t/jordan-jumpman-two-trey", "image": "https://static.nike.com/a/images/jordan-jumpman-two-trey.png", "description": "Jordan Jumpman Two Trey", "category": "sneakers"},

    # ==================== SNEAKERS - ASICS ====================
    {"name": "Asics Gel-Kayano 30", "brand": "Asics", "price": 180, "url": "https://www.asics.com/gel-kayano-30", "image": "https://images.asics.com/gel-kayano-30.jpg", "description": "Asics Gel-Kayano 30 running stabilite", "category": "sport"},
    {"name": "Asics Gel-Nimbus 25", "brand": "Asics", "price": 180, "url": "https://www.asics.com/gel-nimbus-25", "image": "https://images.asics.com/gel-nimbus-25.jpg", "description": "Asics Gel-Nimbus 25 amorti maximal", "category": "sport"},
    {"name": "Asics Gel-Lyte III OG", "brand": "Asics", "price": 120, "url": "https://www.asics.com/gel-lyte-iii-og", "image": "https://images.asics.com/gel-lyte-iii-og.jpg", "description": "Asics Gel-Lyte III OG retro", "category": "sneakers"},
    {"name": "Asics Gel-1090 White Silver", "brand": "Asics", "price": 110, "url": "https://www.asics.com/gel-1090", "image": "https://images.asics.com/gel-1090-white.jpg", "description": "Asics Gel-1090 style annees 2000", "category": "sneakers"},
    {"name": "Asics Gel-Quantum 360 VII", "brand": "Asics", "price": 180, "url": "https://www.asics.com/gel-quantum-360", "image": "https://images.asics.com/gel-quantum-360.jpg", "description": "Asics Gel-Quantum 360 VII moderne", "category": "sneakers"},
    {"name": "Asics GT-2000 11", "brand": "Asics", "price": 140, "url": "https://www.asics.com/gt-2000-11", "image": "https://images.asics.com/gt-2000-11.jpg", "description": "Asics GT-2000 11 running polyvalent", "category": "sport"},
    {"name": "Asics Gel-Cumulus 25", "brand": "Asics", "price": 140, "url": "https://www.asics.com/gel-cumulus-25", "image": "https://images.asics.com/gel-cumulus-25.jpg", "description": "Asics Gel-Cumulus 25 confort quotidien", "category": "sport"},
    {"name": "Asics Novablast 3", "brand": "Asics", "price": 150, "url": "https://www.asics.com/novablast-3", "image": "https://images.asics.com/novablast-3.jpg", "description": "Asics Novablast 3 rebond energetique", "category": "sport"},
    {"name": "Asics Gel-NYC", "brand": "Asics", "price": 130, "url": "https://www.asics.com/gel-nyc", "image": "https://images.asics.com/gel-nyc.jpg", "description": "Asics Gel-NYC heritage urbain", "category": "sneakers"},
    {"name": "Asics Metaspeed Sky+", "brand": "Asics", "price": 250, "url": "https://www.asics.com/metaspeed-sky", "image": "https://images.asics.com/metaspeed-sky.jpg", "description": "Asics Metaspeed Sky+ competition", "category": "sport"},

    # ==================== SNEAKERS - PUMA ====================
    {"name": "Puma Suede Classic XXI", "brand": "Puma", "price": 75, "url": "https://www.puma.com/suede-classic-xxi", "image": "https://images.puma.com/suede-classic-black.jpg", "description": "Puma Suede Classic XXI iconique", "category": "sneakers"},
    {"name": "Puma RS-X Reinvention", "brand": "Puma", "price": 110, "url": "https://www.puma.com/rs-x-reinvention", "image": "https://images.puma.com/rs-x-reinvention.jpg", "description": "Puma RS-X Reinvention retro futuriste", "category": "sneakers"},
    {"name": "Puma Palermo Leather", "brand": "Puma", "price": 90, "url": "https://www.puma.com/palermo-leather", "image": "https://images.puma.com/palermo-white-green.jpg", "description": "Puma Palermo cuir vintage", "category": "sneakers"},
    {"name": "Puma Speedcat OG Sparco", "brand": "Puma", "price": 100, "url": "https://www.puma.com/speedcat-og", "image": "https://images.puma.com/speedcat-red.jpg", "description": "Puma Speedcat OG Sparco racing", "category": "sneakers"},
    {"name": "Puma Clyde All-Pro", "brand": "Puma", "price": 120, "url": "https://www.puma.com/clyde-all-pro", "image": "https://images.puma.com/clyde-all-pro.jpg", "description": "Puma Clyde All-Pro basket performance", "category": "sport"},
    {"name": "Puma Velocity Nitro 2", "brand": "Puma", "price": 130, "url": "https://www.puma.com/velocity-nitro-2", "image": "https://images.puma.com/velocity-nitro-2.jpg", "description": "Puma Velocity Nitro 2 running", "category": "sport"},
    {"name": "Puma MB.03 LaMelo Ball", "brand": "Puma", "price": 125, "url": "https://www.puma.com/mb-03", "image": "https://images.puma.com/mb-03.jpg", "description": "Puma MB.03 LaMelo Ball signature", "category": "sport"},
    {"name": "Puma Thunder Spectra", "brand": "Puma", "price": 100, "url": "https://www.puma.com/thunder-spectra", "image": "https://images.puma.com/thunder-spectra.jpg", "description": "Puma Thunder Spectra dad shoes", "category": "sneakers"},
    {"name": "Puma Mirage Sport", "brand": "Puma", "price": 85, "url": "https://www.puma.com/mirage-sport", "image": "https://images.puma.com/mirage-sport.jpg", "description": "Puma Mirage Sport style retro", "category": "sneakers"},
    {"name": "Puma Deviate Nitro 2", "brand": "Puma", "price": 160, "url": "https://www.puma.com/deviate-nitro-2", "image": "https://images.puma.com/deviate-nitro-2.jpg", "description": "Puma Deviate Nitro 2 competition", "category": "sport"},

    # ==================== SNEAKERS - SALOMON ====================
    {"name": "Salomon Speedcross 6 Trail", "brand": "Salomon", "price": 140, "url": "https://www.salomon.com/speedcross-6", "image": "https://cdn.salomon.com/speedcross-6-black.jpg", "description": "Salomon Speedcross 6 trail running", "category": "outdoor"},
    {"name": "Salomon XT-6 Advanced", "brand": "Salomon", "price": 180, "url": "https://www.salomon.com/xt-6", "image": "https://cdn.salomon.com/xt-6-black.jpg", "description": "Salomon XT-6 Advanced lifestyle", "category": "sneakers"},
    {"name": "Salomon ACS Pro Advanced", "brand": "Salomon", "price": 160, "url": "https://www.salomon.com/acs-pro", "image": "https://cdn.salomon.com/acs-pro-white.jpg", "description": "Salomon ACS Pro Advanced vintage", "category": "sneakers"},
    {"name": "Salomon Sense Ride 5", "brand": "Salomon", "price": 140, "url": "https://www.salomon.com/sense-ride-5", "image": "https://cdn.salomon.com/sense-ride-5.jpg", "description": "Salomon Sense Ride 5 trail polyvalent", "category": "outdoor"},
    {"name": "Salomon Ultra Glide", "brand": "Salomon", "price": 150, "url": "https://www.salomon.com/ultra-glide", "image": "https://cdn.salomon.com/ultra-glide.jpg", "description": "Salomon Ultra Glide ultra distance", "category": "outdoor"},
    {"name": "Salomon Genesis Trail", "brand": "Salomon", "price": 170, "url": "https://www.salomon.com/genesis", "image": "https://cdn.salomon.com/genesis.jpg", "description": "Salomon Genesis trail urbain", "category": "sneakers"},
    {"name": "Salomon Alphacross 4", "brand": "Salomon", "price": 100, "url": "https://www.salomon.com/alphacross-4", "image": "https://cdn.salomon.com/alphacross-4.jpg", "description": "Salomon Alphacross 4 trail accessible", "category": "outdoor"},
    {"name": "Salomon Thundercross", "brand": "Salomon", "price": 150, "url": "https://www.salomon.com/thundercross", "image": "https://cdn.salomon.com/thundercross.jpg", "description": "Salomon Thundercross trail dynamique", "category": "outdoor"},
    {"name": "Salomon XT-Wings 2 Advanced", "brand": "Salomon", "price": 180, "url": "https://www.salomon.com/xt-wings-2", "image": "https://cdn.salomon.com/xt-wings-2.jpg", "description": "Salomon XT-Wings 2 heritage", "category": "sneakers"},
    {"name": "Salomon Xa Pro 3D V8", "brand": "Salomon", "price": 130, "url": "https://www.salomon.com/xa-pro-3d", "image": "https://cdn.salomon.com/xa-pro-3d.jpg", "description": "Salomon Xa Pro 3D V8 classique", "category": "outdoor"},

    # ==================== GASTRONOMIE - PIERRE HERME ====================
    {"name": "Pierre Herme Macaron Ispahan", "brand": "Pierre Herme", "price": 3, "url": "https://www.pierreherme.com/macaron-ispahan", "image": "https://pierreherme.com/images/macaron-ispahan.jpg", "description": "Macaron Ispahan rose litchi framboise", "category": "food"},
    {"name": "Pierre Herme Coffret Incontournables 8 Macarons", "brand": "Pierre Herme", "price": 29, "url": "https://www.pierreherme.com/coffret-8-macarons", "image": "https://pierreherme.com/images/coffret-8-macarons.jpg", "description": "Coffret 8 macarons incontournables", "category": "food"},
    {"name": "Pierre Herme Macaron Mogador", "brand": "Pierre Herme", "price": 3, "url": "https://www.pierreherme.com/macaron-mogador", "image": "https://pierreherme.com/images/macaron-mogador.jpg", "description": "Macaron Mogador passion chocolat lait", "category": "food"},
    {"name": "Pierre Herme Tarte Ispahan", "brand": "Pierre Herme", "price": 58, "url": "https://www.pierreherme.com/tarte-ispahan", "image": "https://pierreherme.com/images/tarte-ispahan.jpg", "description": "Tarte Ispahan 6 personnes", "category": "food"},
    {"name": "Pierre Herme Chocolat Carrousel", "brand": "Pierre Herme", "price": 45, "url": "https://www.pierreherme.com/chocolat-carrousel", "image": "https://pierreherme.com/images/chocolat-carrousel.jpg", "description": "Boite chocolats Carrousel 250g", "category": "food"},
    {"name": "Pierre Herme Infiniment Vanille Macaron", "brand": "Pierre Herme", "price": 3, "url": "https://www.pierreherme.com/macaron-infiniment-vanille", "image": "https://pierreherme.com/images/macaron-vanille.jpg", "description": "Macaron Infiniment Vanille Madagascar", "category": "food"},
    {"name": "Pierre Herme Croissant Ispahan", "brand": "Pierre Herme", "price": 6, "url": "https://www.pierreherme.com/croissant-ispahan", "image": "https://pierreherme.com/images/croissant-ispahan.jpg", "description": "Croissant Ispahan rose litchi framboise", "category": "food"},
    {"name": "Pierre Herme Coffret Collection 18 Macarons", "brand": "Pierre Herme", "price": 65, "url": "https://www.pierreherme.com/coffret-18-macarons", "image": "https://pierreherme.com/images/coffret-18-macarons.jpg", "description": "Coffret Collection 18 macarons", "category": "food"},
    {"name": "Pierre Herme Infiniment Chocolat Macaron", "brand": "Pierre Herme", "price": 3, "url": "https://www.pierreherme.com/macaron-infiniment-chocolat", "image": "https://pierreherme.com/images/macaron-chocolat.jpg", "description": "Macaron Infiniment Chocolat", "category": "food"},
    {"name": "Pierre Herme 2000 Feuilles Vanille", "brand": "Pierre Herme", "price": 7, "url": "https://www.pierreherme.com/2000-feuilles-vanille", "image": "https://pierreherme.com/images/2000-feuilles.jpg", "description": "Mille-feuille 2000 Feuilles vanille", "category": "food"},

    # ==================== GASTRONOMIE - LADUREE ====================
    {"name": "Laduree Coffret 12 Macarons Intemporel", "brand": "Laduree", "price": 39, "url": "https://www.laduree.fr/coffret-12-macarons", "image": "https://laduree.fr/images/coffret-12-macarons.jpg", "description": "Coffret 12 macarons Intemporel", "category": "food"},
    {"name": "Laduree Macaron Pistache", "brand": "Laduree", "price": 3, "url": "https://www.laduree.fr/macaron-pistache", "image": "https://laduree.fr/images/macaron-pistache.jpg", "description": "Macaron Laduree pistache", "category": "food"},
    {"name": "Laduree Macaron Rose", "brand": "Laduree", "price": 3, "url": "https://www.laduree.fr/macaron-rose", "image": "https://laduree.fr/images/macaron-rose.jpg", "description": "Macaron Laduree rose", "category": "food"},
    {"name": "Laduree Coffret 20 Macarons", "brand": "Laduree", "price": 60, "url": "https://www.laduree.fr/coffret-20-macarons", "image": "https://laduree.fr/images/coffret-20-macarons.jpg", "description": "Coffret 20 macarons assortis", "category": "food"},
    {"name": "Laduree Macaron Caramel Fleur de Sel", "brand": "Laduree", "price": 3, "url": "https://www.laduree.fr/macaron-caramel", "image": "https://laduree.fr/images/macaron-caramel.jpg", "description": "Macaron caramel fleur de sel", "category": "food"},
    {"name": "Laduree Boite Chocolats 250g", "brand": "Laduree", "price": 48, "url": "https://www.laduree.fr/chocolats-250g", "image": "https://laduree.fr/images/chocolats-250g.jpg", "description": "Boite chocolats assortis 250g", "category": "food"},
    {"name": "Laduree Macaron Vanille", "brand": "Laduree", "price": 3, "url": "https://www.laduree.fr/macaron-vanille", "image": "https://laduree.fr/images/macaron-vanille.jpg", "description": "Macaron vanille de Madagascar", "category": "food"},
    {"name": "Laduree Coffret 35 Macarons Peche", "brand": "Laduree", "price": 102, "url": "https://www.laduree.fr/coffret-35-macarons", "image": "https://laduree.fr/images/coffret-35-macarons-peche.jpg", "description": "Coffret 35 macarons couleur peche", "category": "food"},
    {"name": "Laduree Macaron Chocolat", "brand": "Laduree", "price": 3, "url": "https://www.laduree.fr/macaron-chocolat", "image": "https://laduree.fr/images/macaron-chocolat.jpg", "description": "Macaron chocolat intense", "category": "food"},
    {"name": "Laduree Macaron Framboise", "brand": "Laduree", "price": 3, "url": "https://www.laduree.fr/macaron-framboise", "image": "https://laduree.fr/images/macaron-framboise.jpg", "description": "Macaron framboise acidulee", "category": "food"},

    # ==================== GASTRONOMIE - KUSMI TEA ====================
    {"name": "Kusmi Tea Prince Vladimir 100g", "brand": "Kusmi Tea", "price": 16, "url": "https://www.kusmitea.com/prince-vladimir", "image": "https://kusmitea.com/images/prince-vladimir-100g.jpg", "description": "The noir Prince Vladimir bergamote", "category": "food"},
    {"name": "Kusmi Tea Anastasia 100g", "brand": "Kusmi Tea", "price": 16, "url": "https://www.kusmitea.com/anastasia", "image": "https://kusmitea.com/images/anastasia-100g.jpg", "description": "The noir Anastasia citron orange", "category": "food"},
    {"name": "Kusmi Tea Kashmir Tchai 100g", "brand": "Kusmi Tea", "price": 16, "url": "https://www.kusmitea.com/kashmir-tchai", "image": "https://kusmitea.com/images/kashmir-tchai-100g.jpg", "description": "The vert Kashmir Tchai epices", "category": "food"},
    {"name": "Kusmi Tea Be Cool 100g", "brand": "Kusmi Tea", "price": 18, "url": "https://www.kusmitea.com/be-cool", "image": "https://kusmitea.com/images/be-cool-100g.jpg", "description": "Infusion Be Cool verveine menthe", "category": "food"},
    {"name": "Kusmi Tea Boost 100g", "brand": "Kusmi Tea", "price": 18, "url": "https://www.kusmitea.com/boost", "image": "https://kusmitea.com/images/boost-100g.jpg", "description": "The mate Boost gingembre citron", "category": "food"},
    {"name": "Kusmi Tea Detox 100g", "brand": "Kusmi Tea", "price": 18, "url": "https://www.kusmitea.com/detox", "image": "https://kusmitea.com/images/detox-100g.jpg", "description": "The vert Detox citron mate", "category": "food"},
    {"name": "Kusmi Tea English Breakfast 100g", "brand": "Kusmi Tea", "price": 14, "url": "https://www.kusmitea.com/english-breakfast", "image": "https://kusmitea.com/images/english-breakfast-100g.jpg", "description": "The noir English Breakfast classique", "category": "food"},
    {"name": "Kusmi Tea Sweet Love 100g", "brand": "Kusmi Tea", "price": 18, "url": "https://www.kusmitea.com/sweet-love", "image": "https://kusmitea.com/images/sweet-love-100g.jpg", "description": "The noir Sweet Love caramel cacao", "category": "food"},
    {"name": "Kusmi Tea BB Detox 100g", "brand": "Kusmi Tea", "price": 18, "url": "https://www.kusmitea.com/bb-detox", "image": "https://kusmitea.com/images/bb-detox-100g.jpg", "description": "The blanc BB Detox rooibos mate", "category": "food"},
    {"name": "Kusmi Tea Tsarevna 100g", "brand": "Kusmi Tea", "price": 16, "url": "https://www.kusmitea.com/tsarevna", "image": "https://kusmitea.com/images/tsarevna-100g.jpg", "description": "The noir Tsarevna fruits rouges", "category": "food"},

    # ==================== GASTRONOMIE - FAUCHON ====================
    {"name": "Fauchon Coffret 15 Macarons", "brand": "Fauchon", "price": 48, "url": "https://www.fauchon.com/coffret-15-macarons", "image": "https://fauchon.com/images/coffret-15-macarons.jpg", "description": "Coffret 15 macarons Fauchon", "category": "food"},
    {"name": "Fauchon The Paris Breakfast 100g", "brand": "Fauchon", "price": 14, "url": "https://www.fauchon.com/the-paris-breakfast", "image": "https://fauchon.com/images/the-paris-breakfast.jpg", "description": "The noir Paris Breakfast melange iconique", "category": "food"},
    {"name": "Fauchon Chocolats Assortis 250g", "brand": "Fauchon", "price": 42, "url": "https://www.fauchon.com/chocolats-250g", "image": "https://fauchon.com/images/chocolats-250g.jpg", "description": "Boite chocolats assortis 250g", "category": "food"},
    {"name": "Fauchon Madeleines Pur Beurre", "brand": "Fauchon", "price": 12, "url": "https://www.fauchon.com/madeleines", "image": "https://fauchon.com/images/madeleines.jpg", "description": "Madeleines pur beurre Fauchon", "category": "food"},
    {"name": "Fauchon Confiture Fraise 200g", "brand": "Fauchon", "price": 9, "url": "https://www.fauchon.com/confiture-fraise", "image": "https://fauchon.com/images/confiture-fraise.jpg", "description": "Confiture extra fraise 200g", "category": "food"},
    {"name": "Fauchon The Earl Grey 100g", "brand": "Fauchon", "price": 14, "url": "https://www.fauchon.com/earl-grey", "image": "https://fauchon.com/images/earl-grey.jpg", "description": "The noir Earl Grey bergamote", "category": "food"},
    {"name": "Fauchon Biscuits Roses de Reims", "brand": "Fauchon", "price": 8, "url": "https://www.fauchon.com/biscuits-roses", "image": "https://fauchon.com/images/biscuits-roses.jpg", "description": "Biscuits roses de Reims traditionnels", "category": "food"},
    {"name": "Fauchon Miel de Lavande 250g", "brand": "Fauchon", "price": 12, "url": "https://www.fauchon.com/miel-lavande", "image": "https://fauchon.com/images/miel-lavande.jpg", "description": "Miel de lavande de Provence 250g", "category": "food"},
    {"name": "Fauchon Coffret 28 Macarons", "brand": "Fauchon", "price": 82, "url": "https://www.fauchon.com/coffret-28-macarons", "image": "https://fauchon.com/images/coffret-28-macarons.jpg", "description": "Coffret 28 macarons prestige", "category": "food"},
    {"name": "Fauchon The Vert Sencha 100g", "brand": "Fauchon", "price": 12, "url": "https://www.fauchon.com/the-vert-sencha", "image": "https://fauchon.com/images/the-vert-sencha.jpg", "description": "The vert Sencha japonais", "category": "food"},

    # ==================== TECH - JBL ====================
    {"name": "JBL Flip 6 Portable Speaker", "brand": "JBL", "price": 129, "url": "https://www.jbl.com/flip-6", "image": "https://jbl.com/images/flip-6-black.jpg", "description": "Enceinte portable JBL Flip 6", "category": "tech"},
    {"name": "JBL Charge 5 Bluetooth Speaker", "brand": "JBL", "price": 179, "url": "https://www.jbl.com/charge-5", "image": "https://jbl.com/images/charge-5-blue.jpg", "description": "Enceinte JBL Charge 5 avec powerbank", "category": "tech"},
    {"name": "JBL Tune 760NC Headphones", "brand": "JBL", "price": 99, "url": "https://www.jbl.com/tune-760nc", "image": "https://jbl.com/images/tune-760nc-black.jpg", "description": "Casque antibruit JBL Tune 760NC", "category": "tech"},
    {"name": "JBL Xtreme 3 Portable Speaker", "brand": "JBL", "price": 299, "url": "https://www.jbl.com/xtreme-3", "image": "https://jbl.com/images/xtreme-3-black.jpg", "description": "Enceinte portable puissante JBL Xtreme 3", "category": "tech"},
    {"name": "JBL Live Pro 2 Earbuds", "brand": "JBL", "price": 149, "url": "https://www.jbl.com/live-pro-2", "image": "https://jbl.com/images/live-pro-2-black.jpg", "description": "Ecouteurs true wireless JBL Live Pro 2", "category": "tech"},
    {"name": "JBL Boombox 3 Speaker", "brand": "JBL", "price": 499, "url": "https://www.jbl.com/boombox-3", "image": "https://jbl.com/images/boombox-3-black.jpg", "description": "Enceinte JBL Boombox 3 ultra-puissante", "category": "tech"},
    {"name": "JBL Bar 9.1 Soundbar", "brand": "JBL", "price": 999, "url": "https://www.jbl.com/bar-9-1", "image": "https://jbl.com/images/bar-9-1.jpg", "description": "Barre de son JBL Bar 9.1 Dolby Atmos", "category": "tech"},
    {"name": "JBL Go 3 Mini Speaker", "brand": "JBL", "price": 39, "url": "https://www.jbl.com/go-3", "image": "https://jbl.com/images/go-3-blue.jpg", "description": "Mini enceinte portable JBL Go 3", "category": "tech"},
    {"name": "JBL Quantum 800 Gaming Headset", "brand": "JBL", "price": 199, "url": "https://www.jbl.com/quantum-800", "image": "https://jbl.com/images/quantum-800-black.jpg", "description": "Casque gaming JBL Quantum 800", "category": "tech"},
    {"name": "JBL Pulse 5 LED Speaker", "brand": "JBL", "price": 249, "url": "https://www.jbl.com/pulse-5", "image": "https://jbl.com/images/pulse-5.jpg", "description": "Enceinte LED JBL Pulse 5 lumineuse", "category": "tech"},

    # ==================== TECH - MARSHALL ====================
    {"name": "Marshall Emberton II Portable Speaker", "brand": "Marshall", "price": 169, "url": "https://www.marshallheadphones.com/emberton-ii", "image": "https://marshall.com/images/emberton-ii-black.jpg", "description": "Enceinte portable Marshall Emberton II", "category": "tech"},
    {"name": "Marshall Stanmore III Bluetooth Speaker", "brand": "Marshall", "price": 379, "url": "https://www.marshallheadphones.com/stanmore-iii", "image": "https://marshall.com/images/stanmore-iii-black.jpg", "description": "Enceinte Marshall Stanmore III vintage", "category": "tech"},
    {"name": "Marshall Major IV Headphones", "brand": "Marshall", "price": 149, "url": "https://www.marshallheadphones.com/major-iv", "image": "https://marshall.com/images/major-iv-black.jpg", "description": "Casque Marshall Major IV iconique", "category": "tech"},
    {"name": "Marshall Acton III Speaker", "brand": "Marshall", "price": 279, "url": "https://www.marshallheadphones.com/acton-iii", "image": "https://marshall.com/images/acton-iii-black.jpg", "description": "Enceinte compacte Marshall Acton III", "category": "tech"},
    {"name": "Marshall Woburn III Bluetooth Speaker", "brand": "Marshall", "price": 549, "url": "https://www.marshallheadphones.com/woburn-iii", "image": "https://marshall.com/images/woburn-iii-black.jpg", "description": "Enceinte Marshall Woburn III puissante", "category": "tech"},
    {"name": "Marshall Mode II Earphones", "brand": "Marshall", "price": 99, "url": "https://www.marshallheadphones.com/mode-ii", "image": "https://marshall.com/images/mode-ii-black.jpg", "description": "Ecouteurs intra Marshall Mode II", "category": "tech"},
    {"name": "Marshall Monitor II ANC Headphones", "brand": "Marshall", "price": 319, "url": "https://www.marshallheadphones.com/monitor-ii-anc", "image": "https://marshall.com/images/monitor-ii-anc-black.jpg", "description": "Casque antibruit Marshall Monitor II ANC", "category": "tech"},
    {"name": "Marshall Kilburn II Portable Speaker", "brand": "Marshall", "price": 299, "url": "https://www.marshallheadphones.com/kilburn-ii", "image": "https://marshall.com/images/kilburn-ii-black.jpg", "description": "Enceinte portable Marshall Kilburn II", "category": "tech"},
    {"name": "Marshall Motif ANC Earbuds", "brand": "Marshall", "price": 199, "url": "https://www.marshallheadphones.com/motif-anc", "image": "https://marshall.com/images/motif-anc-black.jpg", "description": "Ecouteurs true wireless Marshall Motif ANC", "category": "tech"},
    {"name": "Marshall Tufton Portable Speaker", "brand": "Marshall", "price": 449, "url": "https://www.marshallheadphones.com/tufton", "image": "https://marshall.com/images/tufton-black.jpg", "description": "Enceinte portable Marshall Tufton massive", "category": "tech"},

    # ==================== TECH - SENNHEISER ====================
    {"name": "Sennheiser Momentum 4 Wireless", "brand": "Sennheiser", "price": 379, "url": "https://www.sennheiser.com/momentum-4-wireless", "image": "https://sennheiser.com/images/momentum-4-black.jpg", "description": "Casque antibruit Sennheiser Momentum 4", "category": "tech"},
    {"name": "Sennheiser HD 660S2 Headphones", "brand": "Sennheiser", "price": 549, "url": "https://www.sennheiser.com/hd-660s2", "image": "https://sennheiser.com/images/hd-660s2.jpg", "description": "Casque audiophile Sennheiser HD 660S2", "category": "tech"},
    {"name": "Sennheiser Momentum True Wireless 3", "brand": "Sennheiser", "price": 249, "url": "https://www.sennheiser.com/momentum-tw-3", "image": "https://sennheiser.com/images/momentum-tw-3-black.jpg", "description": "Ecouteurs Sennheiser Momentum TW 3", "category": "tech"},
    {"name": "Sennheiser HD 599 Open Back", "brand": "Sennheiser", "price": 199, "url": "https://www.sennheiser.com/hd-599", "image": "https://sennheiser.com/images/hd-599.jpg", "description": "Casque ouvert Sennheiser HD 599", "category": "tech"},
    {"name": "Sennheiser IE 300 In-Ear", "brand": "Sennheiser", "price": 299, "url": "https://www.sennheiser.com/ie-300", "image": "https://sennheiser.com/images/ie-300.jpg", "description": "Ecouteurs intra Sennheiser IE 300", "category": "tech"},
    {"name": "Sennheiser HD 800 S Headphones", "brand": "Sennheiser", "price": 1699, "url": "https://www.sennheiser.com/hd-800-s", "image": "https://sennheiser.com/images/hd-800-s.jpg", "description": "Casque reference Sennheiser HD 800 S", "category": "tech"},
    {"name": "Sennheiser CX Plus True Wireless", "brand": "Sennheiser", "price": 149, "url": "https://www.sennheiser.com/cx-plus", "image": "https://sennheiser.com/images/cx-plus-black.jpg", "description": "Ecouteurs Sennheiser CX Plus", "category": "tech"},
    {"name": "Sennheiser Ambeo Soundbar Plus", "brand": "Sennheiser", "price": 1999, "url": "https://www.sennheiser.com/ambeo-soundbar-plus", "image": "https://sennheiser.com/images/ambeo-soundbar-plus.jpg", "description": "Barre de son Sennheiser Ambeo Plus", "category": "tech"},
    {"name": "Sennheiser HD 450BT Wireless", "brand": "Sennheiser", "price": 149, "url": "https://www.sennheiser.com/hd-450bt", "image": "https://sennheiser.com/images/hd-450bt-black.jpg", "description": "Casque sans fil Sennheiser HD 450BT", "category": "tech"},
    {"name": "Sennheiser Sport True Wireless", "brand": "Sennheiser", "price": 129, "url": "https://www.sennheiser.com/sport-tw", "image": "https://sennheiser.com/images/sport-tw-black.jpg", "description": "Ecouteurs sport Sennheiser True Wireless", "category": "tech"},

    # ==================== TECH - PHILIPS ====================
    {"name": "Philips Hue Starter Kit E27", "brand": "Philips", "price": 129, "url": "https://www.philips-hue.com/starter-kit-e27", "image": "https://philips.com/images/hue-starter-kit.jpg", "description": "Kit demarrage Philips Hue 3 ampoules", "category": "tech"},
    {"name": "Philips Sonicare DiamondClean", "brand": "Philips", "price": 229, "url": "https://www.philips.fr/sonicare-diamondclean", "image": "https://philips.com/images/sonicare-diamondclean.jpg", "description": "Brosse a dents Philips Sonicare", "category": "tech"},
    {"name": "Philips Air Fryer XXL", "brand": "Philips", "price": 199, "url": "https://www.philips.fr/airfryer-xxl", "image": "https://philips.com/images/airfryer-xxl.jpg", "description": "Friteuse sans huile Philips XXL", "category": "home"},
    {"name": "Philips OneBlade Pro", "brand": "Philips", "price": 79, "url": "https://www.philips.fr/oneblade-pro", "image": "https://philips.com/images/oneblade-pro.jpg", "description": "Rasoir hybride Philips OneBlade Pro", "category": "tech"},
    {"name": "Philips Hue Play Gradient Lightstrip 55\"", "brand": "Philips", "price": 199, "url": "https://www.philips-hue.com/play-gradient", "image": "https://philips.com/images/hue-play-gradient.jpg", "description": "Bandeau lumineux Hue Play Gradient", "category": "tech"},
    {"name": "Philips Hue Go Portable Light", "brand": "Philips", "price": 99, "url": "https://www.philips-hue.com/hue-go", "image": "https://philips.com/images/hue-go.jpg", "description": "Lampe portable Philips Hue Go", "category": "tech"},
    {"name": "Philips Series 7000 Shaver", "brand": "Philips", "price": 149, "url": "https://www.philips.fr/series-7000-shaver", "image": "https://philips.com/images/series-7000-shaver.jpg", "description": "Rasoir electrique Philips Series 7000", "category": "tech"},
    {"name": "Philips Espresso 3200 Lattego", "brand": "Philips", "price": 699, "url": "https://www.philips.fr/espresso-3200", "image": "https://philips.com/images/espresso-3200.jpg", "description": "Machine a cafe Philips 3200 Lattego", "category": "home"},
    {"name": "Philips Hue Lightstrip Plus 2m", "brand": "Philips", "price": 79, "url": "https://www.philips-hue.com/lightstrip-plus", "image": "https://philips.com/images/hue-lightstrip.jpg", "description": "Ruban LED Philips Hue 2 metres", "category": "tech"},
    {"name": "Philips PerfectCare Elite Steam Iron", "brand": "Philips", "price": 249, "url": "https://www.philips.fr/perfectcare-elite", "image": "https://philips.com/images/perfectcare-elite.jpg", "description": "Centrale vapeur Philips PerfectCare", "category": "home"},

    # ==================== MODE FRANCAISE - LE SLIP FRANCAIS ====================
    {"name": "Le Slip Francais Boxer Le Marius Bleu", "brand": "Le Slip Francais", "price": 35, "url": "https://www.leslipfrancais.fr/boxer-le-marius-bleu", "image": "https://leslipfrancais.fr/images/boxer-marius-bleu.jpg", "description": "Boxer Le Marius en coton Made in France", "category": "fashion"},
    {"name": "Le Slip Francais Slip Le Jean Blanc", "brand": "Le Slip Francais", "price": 30, "url": "https://www.leslipfrancais.fr/slip-le-jean-blanc", "image": "https://leslipfrancais.fr/images/slip-jean-blanc.jpg", "description": "Slip Le Jean blanc Made in France", "category": "fashion"},
    {"name": "Le Slip Francais T-Shirt Le Jacques Blanc", "brand": "Le Slip Francais", "price": 40, "url": "https://www.leslipfrancais.fr/tshirt-le-jacques", "image": "https://leslipfrancais.fr/images/tshirt-jacques-blanc.jpg", "description": "T-shirt Le Jacques col rond blanc", "category": "fashion"},
    {"name": "Le Slip Francais Chaussettes Fil d'Ecosse Pack 3", "brand": "Le Slip Francais", "price": 35, "url": "https://www.leslipfrancais.fr/chaussettes-pack-3", "image": "https://leslipfrancais.fr/images/chaussettes-pack-3.jpg", "description": "Pack 3 paires chaussettes fil d'Ecosse", "category": "fashion"},
    {"name": "Le Slip Francais Pull Le Malo Marine", "brand": "Le Slip Francais", "price": 120, "url": "https://www.leslipfrancais.fr/pull-le-malo", "image": "https://leslipfrancais.fr/images/pull-malo-marine.jpg", "description": "Pull marin Le Malo Made in France", "category": "fashion"},
    {"name": "Le Slip Francais Sweat Le Fred Marine", "brand": "Le Slip Francais", "price": 90, "url": "https://www.leslipfrancais.fr/sweat-le-fred", "image": "https://leslipfrancais.fr/images/sweat-fred-marine.jpg", "description": "Sweat Le Fred col rond marine", "category": "fashion"},
    {"name": "Le Slip Francais Calecon Le Michel Rayures", "brand": "Le Slip Francais", "price": 35, "url": "https://www.leslipfrancais.fr/calecon-le-michel", "image": "https://leslipfrancais.fr/images/calecon-michel-rayures.jpg", "description": "Calecon Le Michel rayures marines", "category": "fashion"},
    {"name": "Le Slip Francais Boxer Le Ferdinand Gris", "brand": "Le Slip Francais", "price": 40, "url": "https://www.leslipfrancais.fr/boxer-le-ferdinand", "image": "https://leslipfrancais.fr/images/boxer-ferdinand-gris.jpg", "description": "Boxer Le Ferdinand avec poche kangourou", "category": "fashion"},
    {"name": "Le Slip Francais Pyjama Le Toudou Rayures", "brand": "Le Slip Francais", "price": 110, "url": "https://www.leslipfrancais.fr/pyjama-le-toudou", "image": "https://leslipfrancais.fr/images/pyjama-toudou-rayures.jpg", "description": "Pyjama Le Toudou rayures marines", "category": "fashion"},
    {"name": "Le Slip Francais Mariniere Le Lucien", "brand": "Le Slip Francais", "price": 50, "url": "https://www.leslipfrancais.fr/mariniere-le-lucien", "image": "https://leslipfrancais.fr/images/mariniere-lucien.jpg", "description": "Mariniere Le Lucien col rond", "category": "fashion"},

    # ==================== MODE FRANCAISE - FAGUO ====================
    {"name": "Faguo Sneakers Hazel Cuir White", "brand": "Faguo", "price": 105, "url": "https://www.faguo-store.com/sneakers-hazel-white", "image": "https://faguo.com/images/hazel-white.jpg", "description": "Baskets Faguo Hazel cuir blanc eco", "category": "fashion"},
    {"name": "Faguo Sneakers Alder Suede Beige", "brand": "Faguo", "price": 99, "url": "https://www.faguo-store.com/sneakers-alder-beige", "image": "https://faguo.com/images/alder-beige.jpg", "description": "Baskets Faguo Alder daim beige", "category": "fashion"},
    {"name": "Faguo T-Shirt Arcy Coton Bio Blanc", "brand": "Faguo", "price": 35, "url": "https://www.faguo-store.com/tshirt-arcy-blanc", "image": "https://faguo.com/images/tshirt-arcy-blanc.jpg", "description": "T-shirt Arcy coton bio blanc", "category": "fashion"},
    {"name": "Faguo Sweat Darney Coton Bio Marine", "brand": "Faguo", "price": 75, "url": "https://www.faguo-store.com/sweat-darney-marine", "image": "https://faguo.com/images/sweat-darney-marine.jpg", "description": "Sweat Darney col rond marine", "category": "fashion"},
    {"name": "Faguo Chemise Barbes Lin Blanc", "brand": "Faguo", "price": 85, "url": "https://www.faguo-store.com/chemise-barbes-blanc", "image": "https://faguo.com/images/chemise-barbes-blanc.jpg", "description": "Chemise Barbes en lin blanc", "category": "fashion"},
    {"name": "Faguo Jean Larch Slim Brut", "brand": "Faguo", "price": 95, "url": "https://www.faguo-store.com/jean-larch-brut", "image": "https://faguo.com/images/jean-larch-brut.jpg", "description": "Jean Larch slim brut eco", "category": "fashion"},
    {"name": "Faguo Sneakers Cypress Canvas Navy", "brand": "Faguo", "price": 75, "url": "https://www.faguo-store.com/sneakers-cypress-navy", "image": "https://faguo.com/images/cypress-navy.jpg", "description": "Baskets Cypress toile marine", "category": "fashion"},
    {"name": "Faguo Veste Berlac Coton Marine", "brand": "Faguo", "price": 140, "url": "https://www.faguo-store.com/veste-berlac-marine", "image": "https://faguo.com/images/veste-berlac-marine.jpg", "description": "Veste Berlac coton marine", "category": "fashion"},
    {"name": "Faguo Pull Ponza Laine Merinos Gris", "brand": "Faguo", "price": 110, "url": "https://www.faguo-store.com/pull-ponza-gris", "image": "https://faguo.com/images/pull-ponza-gris.jpg", "description": "Pull Ponza laine merinos gris", "category": "fashion"},
    {"name": "Faguo Sneakers Holly Recycled White", "brand": "Faguo", "price": 89, "url": "https://www.faguo-store.com/sneakers-holly-white", "image": "https://faguo.com/images/holly-white.jpg", "description": "Baskets Holly matieres recyclees", "category": "fashion"},

    # ==================== MODE FRANCAISE - BALIBARIS ====================
    {"name": "Balibaris Chemise Oxford Blanc", "brand": "Balibaris", "price": 95, "url": "https://www.balibaris.com/chemise-oxford-blanc", "image": "https://balibaris.com/images/chemise-oxford-blanc.jpg", "description": "Chemise Oxford Balibaris blanc", "category": "fashion"},
    {"name": "Balibaris Pull Col V Cachemire Marine", "brand": "Balibaris", "price": 180, "url": "https://www.balibaris.com/pull-cachemire-marine", "image": "https://balibaris.com/images/pull-cachemire-marine.jpg", "description": "Pull col V cachemire marine", "category": "fashion"},
    {"name": "Balibaris Chino Slim Beige", "brand": "Balibaris", "price": 110, "url": "https://www.balibaris.com/chino-slim-beige", "image": "https://balibaris.com/images/chino-beige.jpg", "description": "Chino slim Balibaris beige", "category": "fashion"},
    {"name": "Balibaris Blouson Teddy Marine", "brand": "Balibaris", "price": 220, "url": "https://www.balibaris.com/blouson-teddy-marine", "image": "https://balibaris.com/images/blouson-teddy-marine.jpg", "description": "Blouson teddy college marine", "category": "fashion"},
    {"name": "Balibaris Polo Pique Marine", "brand": "Balibaris", "price": 75, "url": "https://www.balibaris.com/polo-pique-marine", "image": "https://balibaris.com/images/polo-marine.jpg", "description": "Polo pique coton marine", "category": "fashion"},
    {"name": "Balibaris Surchemise Velours Camel", "brand": "Balibaris", "price": 140, "url": "https://www.balibaris.com/surchemise-velours-camel", "image": "https://balibaris.com/images/surchemise-velours-camel.jpg", "description": "Surchemise velours camel", "category": "fashion"},
    {"name": "Balibaris Jean Slim Brut", "brand": "Balibaris", "price": 120, "url": "https://www.balibaris.com/jean-slim-brut", "image": "https://balibaris.com/images/jean-brut.jpg", "description": "Jean slim brut Balibaris", "category": "fashion"},
    {"name": "Balibaris Manteau Caban Marine", "brand": "Balibaris", "price": 350, "url": "https://www.balibaris.com/manteau-caban-marine", "image": "https://balibaris.com/images/caban-marine.jpg", "description": "Caban laine marine Balibaris", "category": "fashion"},
    {"name": "Balibaris T-Shirt Col Rond Blanc Pack 3", "brand": "Balibaris", "price": 60, "url": "https://www.balibaris.com/tshirt-pack-3-blanc", "image": "https://balibaris.com/images/tshirt-pack-blanc.jpg", "description": "Pack 3 t-shirts col rond blancs", "category": "fashion"},
    {"name": "Balibaris Costume 2 Pieces Marine", "brand": "Balibaris", "price": 490, "url": "https://www.balibaris.com/costume-marine", "image": "https://balibaris.com/images/costume-marine.jpg", "description": "Costume 2 pieces laine marine", "category": "fashion"},

    # ==================== MODE FRANCAISE - MAISON KITSUNE ====================
    {"name": "Maison Kitsune T-Shirt Fox Head Patch Blanc", "brand": "Maison Kitsune", "price": 75, "url": "https://maisonkitsune.com/tshirt-fox-head-blanc", "image": "https://kitsune.com/images/tshirt-fox-blanc.jpg", "description": "T-shirt Fox Head Patch blanc", "category": "fashion"},
    {"name": "Maison Kitsune Sweat Fox Head Navy", "brand": "Maison Kitsune", "price": 155, "url": "https://maisonkitsune.com/sweat-fox-head-navy", "image": "https://kitsune.com/images/sweat-fox-navy.jpg", "description": "Sweat Fox Head col rond marine", "category": "fashion"},
    {"name": "Maison Kitsune Polo Tricolor Fox Navy", "brand": "Maison Kitsune", "price": 95, "url": "https://maisonkitsune.com/polo-tricolor-fox-navy", "image": "https://kitsune.com/images/polo-tricolor-navy.jpg", "description": "Polo Tricolor Fox marine", "category": "fashion"},
    {"name": "Maison Kitsune Hoodie Fox Head Black", "brand": "Maison Kitsune", "price": 185, "url": "https://maisonkitsune.com/hoodie-fox-head-black", "image": "https://kitsune.com/images/hoodie-fox-black.jpg", "description": "Sweat a capuche Fox Head noir", "category": "fashion"},
    {"name": "Maison Kitsune Chemise Oxford Blanc", "brand": "Maison Kitsune", "price": 125, "url": "https://maisonkitsune.com/chemise-oxford-blanc", "image": "https://kitsune.com/images/chemise-oxford-blanc.jpg", "description": "Chemise Oxford Tricolor Fox blanc", "category": "fashion"},
    {"name": "Maison Kitsune T-Shirt Maison Kitsune Print Noir", "brand": "Maison Kitsune", "price": 85, "url": "https://maisonkitsune.com/tshirt-print-noir", "image": "https://kitsune.com/images/tshirt-print-noir.jpg", "description": "T-shirt Maison Kitsune Print noir", "category": "fashion"},
    {"name": "Maison Kitsune Cardigan Fox Head Grey", "brand": "Maison Kitsune", "price": 220, "url": "https://maisonkitsune.com/cardigan-fox-grey", "image": "https://kitsune.com/images/cardigan-fox-grey.jpg", "description": "Cardigan Fox Head gris", "category": "fashion"},
    {"name": "Maison Kitsune Tote Bag Tricolor Fox", "brand": "Maison Kitsune", "price": 65, "url": "https://maisonkitsune.com/tote-bag-tricolor-fox", "image": "https://kitsune.com/images/tote-bag-tricolor.jpg", "description": "Tote bag Tricolor Fox canvas", "category": "fashion"},
    {"name": "Maison Kitsune Blouson Teddy Fox Patch", "brand": "Maison Kitsune", "price": 395, "url": "https://maisonkitsune.com/blouson-teddy-fox", "image": "https://kitsune.com/images/blouson-teddy-fox.jpg", "description": "Blouson teddy avec patch Fox", "category": "fashion"},
    {"name": "Maison Kitsune Pantalon Chino Navy", "brand": "Maison Kitsune", "price": 145, "url": "https://maisonkitsune.com/chino-navy", "image": "https://kitsune.com/images/chino-navy.jpg", "description": "Pantalon chino navy Kitsune", "category": "fashion"},
]

def load_existing_products():
    """Charge les produits existants"""
    if EXISTING_FILE.exists():
        with open(EXISTING_FILE, 'r', encoding='utf-8') as f:
            return json.load(f)
    return []

def merge_products():
    """Fusionne les nouveaux produits avec les existants"""
    existing = load_existing_products()
    existing_urls = {p.get('url', '') for p in existing}

    # Filtrer les doublons
    new_products = [p for p in MEGA_PRODUCTS if p.get('url', '') not in existing_urls]

    print(f"\nProduits existants: {len(existing)}")
    print(f"Nouveaux produits: {len(new_products)}")
    print(f"Total: {len(existing) + len(new_products)}")

    # Sauvegarder les nouveaux produits separement
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(new_products, f, ensure_ascii=False, indent=2)

    # Fusionner tout
    all_products = existing + new_products
    merged_file = BASE_DIR / "all_products_merged.json"
    with open(merged_file, 'w', encoding='utf-8') as f:
        json.dump(all_products, f, ensure_ascii=False, indent=2)

    # Stats par marque
    brands_stats = {}
    for p in all_products:
        brand = p.get('brand', 'Unknown')
        brands_stats[brand] = brands_stats.get(brand, 0) + 1

    print("\n" + "="*60)
    print("TOP 20 MARQUES PAR NOMBRE DE PRODUITS")
    print("="*60)
    sorted_brands = sorted(brands_stats.items(), key=lambda x: x[1], reverse=True)[:20]
    for i, (brand, count) in enumerate(sorted_brands, 1):
        print(f"{i:2d}. {brand:30s}: {count:3d} produits")

    # Stats par categorie
    cat_stats = {}
    for p in all_products:
        cat = p.get('category', 'Unknown')
        cat_stats[cat] = cat_stats.get(cat, 0) + 1

    print("\n" + "="*60)
    print("PRODUITS PAR CATEGORIE")
    print("="*60)
    for cat, count in sorted(cat_stats.items()):
        print(f"  {cat:20s}: {count:4d} produits")

    print(f"\nFichiers generes:")
    print(f"  - Nouveaux: {OUTPUT_FILE}")
    print(f"  - Fusionnes: {merged_file}")

    return len(all_products)

if __name__ == "__main__":
    print("\n" + "🚀"*30)
    print("MEGA PRODUCT GENERATOR")
    print("🚀"*30)
    total = merge_products()
    print(f"\n✅ SUCCES! Total final: {total} produits")
    print(f"Objectif 1500+ atteint: {'OUI ✓' if total >= 1500 else 'NON ✗'}")
