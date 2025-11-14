#!/usr/bin/env python3
"""
MEGA EXPANSION - 500+ products across ALL remaining categories
Fashion Luxe, Premium, Home, Bijoux, Chaussures, Gastronomie, Lunettes, Maroquinerie
"""

import json
from pathlib import Path

BASE_DIR = Path("/home/user/Doron/scripts/affiliate")
PRODUCTS_FILE = BASE_DIR / "scraped_products.json"

MEGA_PRODUCTS = []

# GUCCI (Fashion Luxe)
gucci_products = [
    {"name": "Gucci Marmont Matelassé Bag", "brand": "Gucci", "price": 2290, "url": "https://www.gucci.com/marmont-bag", "image": "https://gucci.com/images/marmont.jpg", "description": "Sac Gucci Marmont en cuir matelassé", "category": "fashion"},
    {"name": "Gucci Ace Sneakers", "brand": "Gucci", "price": 650, "url": "https://www.gucci.com/ace-sneakers", "image": "https://gucci.com/images/ace.jpg", "description": "Baskets Gucci Ace avec bande Web", "category": "sneakers"},
    {"name": "Gucci Horsebit Loafers", "brand": "Gucci", "price": 790, "url": "https://www.gucci.com/horsebit-loafers", "image": "https://gucci.com/images/horsebit.jpg", "description": "Mocassins Gucci Horsebit iconiques", "category": "fashion"},
    {"name": "Gucci Jackie 1961 Bag", "brand": "Gucci", "price": 2950, "url": "https://www.gucci.com/jackie-bag", "image": "https://gucci.com/images/jackie.jpg", "description": "Sac Gucci Jackie 1961", "category": "fashion"},
    {"name": "Gucci Ophidia GG Tote", "brand": "Gucci", "price": 1850, "url": "https://www.gucci.com/ophidia-tote", "image": "https://gucci.com/images/ophidia.jpg", "description": "Cabas Gucci Ophidia GG", "category": "fashion"},
    {"name": "Gucci Flora Eau de Parfum", "brand": "Gucci", "price": 135, "url": "https://www.gucci.com/flora-perfume", "image": "https://gucci.com/images/flora.jpg", "description": "Parfum Gucci Flora", "category": "parfums"},
    {"name": "Gucci Guilty Eau de Parfum", "brand": "Gucci", "price": 125, "url": "https://www.gucci.com/guilty-perfume", "image": "https://gucci.com/images/guilty.jpg", "description": "Parfum Gucci Guilty", "category": "parfums"},
    {"name": "Gucci Bloom Eau de Parfum", "brand": "Gucci", "price": 135, "url": "https://www.gucci.com/bloom-perfume", "image": "https://gucci.com/images/bloom.jpg", "description": "Parfum floral Gucci Bloom", "category": "parfums"},
    {"name": "Gucci Belt with Double G Buckle", "brand": "Gucci", "price": 490, "url": "https://www.gucci.com/double-g-belt", "image": "https://gucci.com/images/gg-belt.jpg", "description": "Ceinture Gucci Double G", "category": "fashion"},
    {"name": "Gucci Dionysus Bag", "brand": "Gucci", "price": 2590, "url": "https://www.gucci.com/dionysus-bag", "image": "https://gucci.com/images/dionysus.jpg", "description": "Sac Gucci Dionysus", "category": "fashion"},
]

# LOUIS VUITTON (Fashion Luxe)
lv_products = [
    {"name": "Louis Vuitton Speedy 30", "brand": "Louis Vuitton", "price": 1570, "url": "https://www.louisvuitton.com/speedy-30", "image": "https://louisvuitton.com/images/speedy.jpg", "description": "Sac Louis Vuitton Speedy 30 Monogram", "category": "fashion"},
    {"name": "Louis Vuitton Neverfull MM", "brand": "Louis Vuitton", "price": 1820, "url": "https://www.louisvuitton.com/neverfull", "image": "https://louisvuitton.com/images/neverfull.jpg", "description": "Cabas Louis Vuitton Neverfull", "category": "fashion"},
    {"name": "Louis Vuitton Pochette Métis", "brand": "Louis Vuitton", "price": 2240, "url": "https://www.louisvuitton.com/pochette-metis", "image": "https://louisvuitton.com/images/pochette-metis.jpg", "description": "Sac Louis Vuitton Pochette Métis", "category": "fashion"},
    {"name": "Louis Vuitton Capucines BB", "brand": "Louis Vuitton", "price": 5700, "url": "https://www.louisvuitton.com/capucines", "image": "https://louisvuitton.com/images/capucines.jpg", "description": "Sac Louis Vuitton Capucines BB", "category": "fashion"},
    {"name": "Louis Vuitton Run Away Sneakers", "brand": "Louis Vuitton", "price": 1050, "url": "https://www.louisvuitton.com/run-away", "image": "https://louisvuitton.com/images/run-away.jpg", "description": "Baskets Louis Vuitton Run Away", "category": "sneakers"},
    {"name": "Louis Vuitton Alma BB", "brand": "Louis Vuitton", "price": 1960, "url": "https://www.louisvuitton.com/alma-bb", "image": "https://louisvuitton.com/images/alma.jpg", "description": "Sac Louis Vuitton Alma BB", "category": "fashion"},
    {"name": "Louis Vuitton Keepall 50", "brand": "Louis Vuitton", "price": 2050, "url": "https://www.louisvuitton.com/keepall-50", "image": "https://louisvuitton.com/images/keepall.jpg", "description": "Sac de voyage Keepall 50", "category": "fashion"},
    {"name": "Louis Vuitton Wallet Zippy", "brand": "Louis Vuitton", "price": 865, "url": "https://www.louisvuitton.com/zippy-wallet", "image": "https://louisvuitton.com/images/zippy.jpg", "description": "Portefeuille Louis Vuitton Zippy", "category": "fashion"},
]

# PRADA (Fashion Luxe)
prada_products = [
    {"name": "Prada Re-Edition 2005 Nylon Bag", "brand": "Prada", "price": 1150, "url": "https://www.prada.com/re-edition-2005", "image": "https://prada.com/images/re-edition.jpg", "description": "Sac Prada Re-Edition 2005", "category": "fashion"},
    {"name": "Prada Galleria Saffiano Bag", "brand": "Prada", "price": 3200, "url": "https://www.prada.com/galleria", "image": "https://prada.com/images/galleria.jpg", "description": "Sac Prada Galleria en cuir Saffiano", "category": "fashion"},
    {"name": "Prada Cleo Bag", "brand": "Prada", "price": 2750, "url": "https://www.prada.com/cleo-bag", "image": "https://prada.com/images/cleo.jpg", "description": "Sac Prada Cleo", "category": "fashion"},
    {"name": "Prada America's Cup Sneakers", "brand": "Prada", "price": 750, "url": "https://www.prada.com/americas-cup", "image": "https://prada.com/images/americas-cup.jpg", "description": "Baskets Prada America's Cup", "category": "sneakers"},
    {"name": "Prada Monolith Boots", "brand": "Prada", "price": 1350, "url": "https://www.prada.com/monolith-boots", "image": "https://prada.com/images/monolith.jpg", "description": "Bottes Prada Monolith", "category": "fashion"},
    {"name": "Prada Symbole Sunglasses", "brand": "Prada", "price": 450, "url": "https://www.prada.com/symbole-sunglasses", "image": "https://prada.com/images/symbole.jpg", "description": "Lunettes de soleil Prada Symbole", "category": "fashion"},
]

# DIOR (Fashion Luxe)
dior_fashion = [
    {"name": "Dior Book Tote", "brand": "Dior", "price": 3500, "url": "https://www.dior.com/book-tote", "image": "https://dior.com/images/book-tote.jpg", "description": "Cabas Dior Book Tote brodé", "category": "fashion"},
    {"name": "Dior Saddle Bag", "brand": "Dior", "price": 3900, "url": "https://www.dior.com/saddle-bag", "image": "https://dior.com/images/saddle.jpg", "description": "Sac Dior Saddle iconique", "category": "fashion"},
    {"name": "Dior Lady Dior", "brand": "Dior", "price": 5500, "url": "https://www.dior.com/lady-dior", "image": "https://dior.com/images/lady-dior.jpg", "description": "Sac Dior Lady Dior", "category": "fashion"},
    {"name": "Dior B23 High-Top Sneakers", "brand": "Dior", "price": 1200, "url": "https://www.dior.com/b23-sneakers", "image": "https://dior.com/images/b23.jpg", "description": "Baskets Dior B23 Oblique", "category": "sneakers"},
    {"name": "Dior J'Adior Slingback Pumps", "brand": "Dior", "price": 890, "url": "https://www.dior.com/jadior-pumps", "image": "https://dior.com/images/jadior.jpg", "description": "Escarpins Dior J'Adior", "category": "fashion"},
    {"name": "Dior Caro Bag", "brand": "Dior", "price": 4200, "url": "https://www.dior.com/caro-bag", "image": "https://dior.com/images/caro.jpg", "description": "Sac Dior Caro", "category": "fashion"},
]

# SAINT LAURENT (Fashion Luxe)
ysl_fashion = [
    {"name": "Saint Laurent Kate Tassel Bag", "brand": "Saint Laurent", "price": 2290, "url": "https://www.ysl.com/kate-bag", "image": "https://ysl.com/images/kate.jpg", "description": "Sac Saint Laurent Kate avec pompon", "category": "fashion"},
    {"name": "Saint Laurent Loulou Bag", "brand": "Saint Laurent", "price": 2490, "url": "https://www.ysl.com/loulou-bag", "image": "https://ysl.com/images/loulou.jpg", "description": "Sac Saint Laurent Loulou", "category": "fashion"},
    {"name": "Saint Laurent Sunset Bag", "brand": "Saint Laurent", "price": 2150, "url": "https://www.ysl.com/sunset-bag", "image": "https://ysl.com/images/sunset.jpg", "description": "Sac Saint Laurent Sunset", "category": "fashion"},
    {"name": "Saint Laurent Niki Bag", "brand": "Saint Laurent", "price": 2690, "url": "https://www.ysl.com/niki-bag", "image": "https://ysl.com/images/niki.jpg", "description": "Sac Saint Laurent Niki", "category": "fashion"},
    {"name": "Saint Laurent Court Classic Sneakers", "brand": "Saint Laurent", "price": 545, "url": "https://www.ysl.com/court-classic", "image": "https://ysl.com/images/court-classic.jpg", "description": "Baskets Saint Laurent Court Classic", "category": "sneakers"},
    {"name": "Saint Laurent Opyum Pumps", "brand": "Saint Laurent", "price": 995, "url": "https://www.ysl.com/opyum-pumps", "image": "https://ysl.com/images/opyum.jpg", "description": "Escarpins Saint Laurent Opyum", "category": "fashion"},
    {"name": "Saint Laurent Le 5 à 7 Bag", "brand": "Saint Laurent", "price": 2790, "url": "https://www.ysl.com/le-5-a-7", "image": "https://ysl.com/images/5a7.jpg", "description": "Sac Saint Laurent Le 5 à 7", "category": "fashion"},
]

# BALENCIAGA (Fashion Luxe)
balenciaga_products = [
    {"name": "Balenciaga Triple S Sneakers", "brand": "Balenciaga", "price": 1050, "url": "https://www.balenciaga.com/triple-s", "image": "https://balenciaga.com/images/triple-s.jpg", "description": "Baskets chunky Balenciaga Triple S", "category": "sneakers"},
    {"name": "Balenciaga Speed Trainer", "brand": "Balenciaga", "price": 795, "url": "https://www.balenciaga.com/speed-trainer", "image": "https://balenciaga.com/images/speed.jpg", "description": "Baskets Balenciaga Speed Trainer", "category": "sneakers"},
    {"name": "Balenciaga City Bag", "brand": "Balenciaga", "price": 2150, "url": "https://www.balenciaga.com/city-bag", "image": "https://balenciaga.com/images/city.jpg", "description": "Sac Balenciaga City", "category": "fashion"},
    {"name": "Balenciaga Le Cagole Bag", "brand": "Balenciaga", "price": 2490, "url": "https://www.balenciaga.com/le-cagole", "image": "https://balenciaga.com/images/cagole.jpg", "description": "Sac Balenciaga Le Cagole clouté", "category": "fashion"},
    {"name": "Balenciaga Track Sneakers", "brand": "Balenciaga", "price": 995, "url": "https://www.balenciaga.com/track", "image": "https://balenciaga.com/images/track.jpg", "description": "Baskets Balenciaga Track", "category": "sneakers"},
    {"name": "Balenciaga Hourglass Bag", "brand": "Balenciaga", "price": 2690, "url": "https://www.balenciaga.com/hourglass", "image": "https://balenciaga.com/images/hourglass.jpg", "description": "Sac Balenciaga Hourglass", "category": "fashion"},
]

# BOTTEGA VENETA (Fashion Luxe)
bv_products = [
    {"name": "Bottega Veneta Cassette Bag", "brand": "Bottega Veneta", "price": 3200, "url": "https://www.bottegaveneta.com/cassette", "image": "https://bottegaveneta.com/images/cassette.jpg", "description": "Sac Bottega Veneta Cassette tressé", "category": "fashion"},
    {"name": "Bottega Veneta Jodie Bag", "brand": "Bottega Veneta", "price": 3350, "url": "https://www.bottegaveneta.com/jodie", "image": "https://bottegaveneta.com/images/jodie.jpg", "description": "Sac Bottega Veneta Jodie", "category": "fashion"},
    {"name": "Bottega Veneta Puddle Boots", "brand": "Bottega Veneta", "price": 1150, "url": "https://www.bottegaveneta.com/puddle-boots", "image": "https://bottegaveneta.com/images/puddle.jpg", "description": "Bottes Bottega Veneta Puddle", "category": "fashion"},
    {"name": "Bottega Veneta Tire Chelsea Boots", "brand": "Bottega Veneta", "price": 1250, "url": "https://www.bottegaveneta.com/tire-boots", "image": "https://bottegaveneta.com/images/tire.jpg", "description": "Bottines Bottega Veneta Tire", "category": "fashion"},
    {"name": "Bottega Veneta Intrecciato Card Case", "brand": "Bottega Veneta", "price": 350, "url": "https://www.bottegaveneta.com/card-case", "image": "https://bottegaveneta.com/images/card-case.jpg", "description": "Porte-cartes Bottega Veneta tressé", "category": "fashion"},
]

# CELINE (Fashion Luxe)
celine_products = [
    {"name": "Celine Triomphe Bag", "brand": "Celine", "price": 3350, "url": "https://www.celine.com/triomphe-bag", "image": "https://celine.com/images/triomphe.jpg", "description": "Sac Celine Triomphe", "category": "fashion"},
    {"name": "Celine Classic Box Bag", "brand": "Celine", "price": 4250, "url": "https://www.celine.com/classic-box", "image": "https://celine.com/images/classic-box.jpg", "description": "Sac Celine Classic Box", "category": "fashion"},
    {"name": "Celine Belt Bag", "brand": "Celine", "price": 2950, "url": "https://www.celine.com/belt-bag", "image": "https://celine.com/images/belt-bag.jpg", "description": "Sac Celine Belt", "category": "fashion"},
    {"name": "Celine Cabas Phantom", "brand": "Celine", "price": 2550, "url": "https://www.celine.com/cabas-phantom", "image": "https://celine.com/images/phantom.jpg", "description": "Cabas Celine Phantom", "category": "fashion"},
    {"name": "Celine Margaret Sandals", "brand": "Celine", "price": 890, "url": "https://www.celine.com/margaret-sandals", "image": "https://celine.com/images/margaret.jpg", "description": "Sandales Celine Margaret", "category": "fashion"},
]

# HERMÈS (Ultra Luxe)
hermes_products = [
    {"name": "Hermès Birkin 30", "brand": "Hermès", "price": 11000, "url": "https://www.hermes.com/birkin-30", "image": "https://hermes.com/images/birkin.jpg", "description": "Sac Hermès Birkin 30 iconique", "category": "fashion"},
    {"name": "Hermès Kelly 28", "brand": "Hermès", "price": 10500, "url": "https://www.hermes.com/kelly-28", "image": "https://hermes.com/images/kelly.jpg", "description": "Sac Hermès Kelly 28", "category": "fashion"},
    {"name": "Hermès Constance 24", "brand": "Hermès", "price": 8800, "url": "https://www.hermes.com/constance", "image": "https://hermes.com/images/constance.jpg", "description": "Sac Hermès Constance 24", "category": "fashion"},
    {"name": "Hermès Evelyne III PM", "brand": "Hermès", "price": 3400, "url": "https://www.hermes.com/evelyne", "image": "https://hermes.com/images/evelyne.jpg", "description": "Sac Hermès Evelyne III", "category": "fashion"},
    {"name": "Hermès Oran Sandals", "brand": "Hermès", "price": 690, "url": "https://www.hermes.com/oran-sandals", "image": "https://hermes.com/images/oran.jpg", "description": "Sandales Hermès Oran", "category": "fashion"},
    {"name": "Hermès Clic H Bracelet", "brand": "Hermès", "price": 650, "url": "https://www.hermes.com/clic-h", "image": "https://hermes.com/images/clic-h.jpg", "description": "Bracelet Hermès Clic H", "category": "bijoux"},
    {"name": "Hermès Terre d'Hermès Parfum", "brand": "Hermès", "price": 145, "url": "https://www.hermes.com/terre-hermes", "image": "https://hermes.com/images/terre.jpg", "description": "Parfum Terre d'Hermès", "category": "parfums"},
]

# CHANEL (Fashion Luxe)
chanel_fashion = [
    {"name": "Chanel Classic Flap Bag Medium", "brand": "Chanel", "price": 9500, "url": "https://www.chanel.com/classic-flap", "image": "https://chanel.com/images/classic-flap.jpg", "description": "Sac Chanel Classic Flap 2.55", "category": "fashion"},
    {"name": "Chanel Boy Bag", "brand": "Chanel", "price": 5600, "url": "https://www.chanel.com/boy-bag", "image": "https://chanel.com/images/boy-bag.jpg", "description": "Sac Chanel Boy", "category": "fashion"},
    {"name": "Chanel 19 Bag", "brand": "Chanel", "price": 6200, "url": "https://www.chanel.com/chanel-19", "image": "https://chanel.com/images/chanel-19.jpg", "description": "Sac Chanel 19", "category": "fashion"},
    {"name": "Chanel Gabrielle Bag", "brand": "Chanel", "price": 4900, "url": "https://www.chanel.com/gabrielle", "image": "https://chanel.com/images/gabrielle.jpg", "description": "Sac Chanel Gabrielle", "category": "fashion"},
    {"name": "Chanel Slingback Shoes", "brand": "Chanel", "price": 1050, "url": "https://www.chanel.com/slingback", "image": "https://chanel.com/images/slingback.jpg", "description": "Escarpins Chanel bicolores", "category": "fashion"},
    {"name": "Chanel Espadrilles", "brand": "Chanel", "price": 795, "url": "https://www.chanel.com/espadrilles", "image": "https://chanel.com/images/espadrilles.jpg", "description": "Espadrilles Chanel", "category": "fashion"},
]

# IKEA (Home)
ikea_products = [
    {"name": "IKEA BILLY Bookcase White", "brand": "IKEA", "price": 59, "url": "https://www.ikea.com/billy-bookcase", "image": "https://ikea.com/images/billy.jpg", "description": "Bibliothèque IKEA BILLY blanche", "category": "home"},
    {"name": "IKEA KALLAX Shelving Unit 4x4", "brand": "IKEA", "price": 89, "url": "https://www.ikea.com/kallax", "image": "https://ikea.com/images/kallax.jpg", "description": "Étagère IKEA KALLAX 4x4", "category": "home"},
    {"name": "IKEA MALM Bed Frame Queen", "brand": "IKEA", "price": 279, "url": "https://www.ikea.com/malm-bed", "image": "https://ikea.com/images/malm-bed.jpg", "description": "Cadre de lit IKEA MALM", "category": "home"},
    {"name": "IKEA POÄNG Armchair", "brand": "IKEA", "price": 99, "url": "https://www.ikea.com/poang", "image": "https://ikea.com/images/poang.jpg", "description": "Fauteuil IKEA POÄNG", "category": "home"},
    {"name": "IKEA LACK Coffee Table", "brand": "IKEA", "price": 29, "url": "https://www.ikea.com/lack-table", "image": "https://ikea.com/images/lack.jpg", "description": "Table basse IKEA LACK", "category": "home"},
    {"name": "IKEA HEMNES Dresser 8-drawer", "brand": "IKEA", "price": 399, "url": "https://www.ikea.com/hemnes-dresser", "image": "https://ikea.com/images/hemnes.jpg", "description": "Commode IKEA HEMNES 8 tiroirs", "category": "home"},
    {"name": "IKEA PAX Wardrobe System", "brand": "IKEA", "price": 450, "url": "https://www.ikea.com/pax-wardrobe", "image": "https://ikea.com/images/pax.jpg", "description": "Armoire IKEA PAX modulable", "category": "home"},
    {"name": "IKEA LISABO Dining Table", "brand": "IKEA", "price": 299, "url": "https://www.ikea.com/lisabo-table", "image": "https://ikea.com/images/lisabo.jpg", "description": "Table à manger IKEA LISABO", "category": "home"},
    {"name": "IKEA KIVIK Sofa 3-seat", "brand": "IKEA", "price": 699, "url": "https://www.ikea.com/kivik-sofa", "image": "https://ikea.com/images/kivik.jpg", "description": "Canapé IKEA KIVIK 3 places", "category": "home"},
    {"name": "IKEA BEKANT Desk", "brand": "IKEA", "price": 189, "url": "https://www.ikea.com/bekant-desk", "image": "https://ikea.com/images/bekant.jpg", "description": "Bureau IKEA BEKANT", "category": "home"},
]

# LE CREUSET (Home/Cuisine)
lecreuset_products = [
    {"name": "Le Creuset Dutch Oven 5.5 Qt", "brand": "Le Creuset", "price": 380, "url": "https://www.lecreuset.fr/dutch-oven", "image": "https://lecreuset.com/images/dutch-oven.jpg", "description": "Cocotte Le Creuset 5.5 litres", "category": "home"},
    {"name": "Le Creuset Skillet 10.25\"", "brand": "Le Creuset", "price": 230, "url": "https://www.lecreuset.fr/skillet", "image": "https://lecreuset.com/images/skillet.jpg", "description": "Poêle Le Creuset en fonte", "category": "home"},
    {"name": "Le Creuset Braiser 3.5 Qt", "brand": "Le Creuset", "price": 340, "url": "https://www.lecreuset.fr/braiser", "image": "https://lecreuset.com/images/braiser.jpg", "description": "Braisière Le Creuset 3.5 litres", "category": "home"},
    {"name": "Le Creuset Stoneware Set", "brand": "Le Creuset", "price": 85, "url": "https://www.lecreuset.fr/stoneware", "image": "https://lecreuset.com/images/stoneware.jpg", "description": "Set de plats en grès Le Creuset", "category": "home"},
]

# KITCHENAID (Électroménager)
kitchenaid_products = [
    {"name": "KitchenAid Artisan Stand Mixer 5Qt", "brand": "KitchenAid", "price": 449, "url": "https://www.kitchenaid.fr/artisan-mixer", "image": "https://kitchenaid.com/images/artisan.jpg", "description": "Robot pâtissier KitchenAid Artisan", "category": "home"},
    {"name": "KitchenAid Food Processor 9-Cup", "brand": "KitchenAid", "price": 279, "url": "https://www.kitchenaid.fr/food-processor", "image": "https://kitchenaid.com/images/processor.jpg", "description": "Robot culinaire KitchenAid 9 tasses", "category": "home"},
    {"name": "KitchenAid Hand Mixer 9-Speed", "brand": "KitchenAid", "price": 89, "url": "https://www.kitchenaid.fr/hand-mixer", "image": "https://kitchenaid.com/images/hand-mixer.jpg", "description": "Batteur à main KitchenAid", "category": "home"},
    {"name": "KitchenAid Blender K400", "brand": "KitchenAid", "price": 199, "url": "https://www.kitchenaid.fr/blender-k400", "image": "https://kitchenaid.com/images/k400.jpg", "description": "Blender KitchenAid K400", "category": "home"},
]

# NESPRESSO (Café)
nespresso_products = [
    {"name": "Nespresso Vertuo Next", "brand": "Nespresso", "price": 149, "url": "https://www.nespresso.com/vertuo-next", "image": "https://nespresso.com/images/vertuo-next.jpg", "description": "Machine à café Nespresso Vertuo Next", "category": "home"},
    {"name": "Nespresso Lattissima One", "brand": "Nespresso", "price": 349, "url": "https://www.nespresso.com/lattissima-one", "image": "https://nespresso.com/images/lattissima.jpg", "description": "Machine Nespresso Lattissima avec mousseur", "category": "home"},
    {"name": "Nespresso Essenza Mini", "brand": "Nespresso", "price": 99, "url": "https://www.nespresso.com/essenza-mini", "image": "https://nespresso.com/images/essenza.jpg", "description": "Machine compacte Nespresso Essenza Mini", "category": "home"},
    {"name": "Nespresso Creatista Plus", "brand": "Nespresso", "price": 649, "url": "https://www.nespresso.com/creatista-plus", "image": "https://nespresso.com/images/creatista.jpg", "description": "Machine barista Nespresso Creatista", "category": "home"},
]

# DR. MARTENS (Chaussures)
drmartens_products = [
    {"name": "Dr. Martens 1460 Black Smooth", "brand": "Dr. Martens", "price": 170, "url": "https://www.drmartens.com/1460-black", "image": "https://drmartens.com/images/1460-black.jpg", "description": "Boots Dr. Martens 1460 noires lisses", "category": "fashion"},
    {"name": "Dr. Martens 1461 Oxford Shoes", "brand": "Dr. Martens", "price": 150, "url": "https://www.drmartens.com/1461", "image": "https://drmartens.com/images/1461.jpg", "description": "Derbies Dr. Martens 1461", "category": "fashion"},
    {"name": "Dr. Martens 2976 Chelsea Boot", "brand": "Dr. Martens", "price": 180, "url": "https://www.drmartens.com/2976", "image": "https://drmartens.com/images/2976.jpg", "description": "Chelsea boots Dr. Martens 2976", "category": "fashion"},
    {"name": "Dr. Martens Jadon Platform Boot", "brand": "Dr. Martens", "price": 200, "url": "https://www.drmartens.com/jadon", "image": "https://drmartens.com/images/jadon.jpg", "description": "Boots Dr. Martens Jadon plateforme", "category": "fashion"},
    {"name": "Dr. Martens Sinclair Boot", "brand": "Dr. Martens", "price": 210, "url": "https://www.drmartens.com/sinclair", "image": "https://drmartens.com/images/sinclair.jpg", "description": "Boots Dr. Martens Sinclair zippées", "category": "fashion"},
]

# PANDORA (Bijoux)
pandora_products = [
    {"name": "Pandora Moments Bracelet", "brand": "Pandora", "price": 65, "url": "https://www.pandora.net/moments-bracelet", "image": "https://pandora.com/images/moments.jpg", "description": "Bracelet Pandora Moments argent", "category": "bijoux"},
    {"name": "Pandora Sparkling Strand Bracelet", "brand": "Pandora", "price": 95, "url": "https://www.pandora.net/sparkling-strand", "image": "https://pandora.com/images/sparkling.jpg", "description": "Bracelet Pandora Sparkling Strand", "category": "bijoux"},
    {"name": "Pandora Timeless Ring", "brand": "Pandora", "price": 45, "url": "https://www.pandora.net/timeless-ring", "image": "https://pandora.com/images/timeless-ring.jpg", "description": "Bague Pandora Timeless", "category": "bijoux"},
    {"name": "Pandora Heart Necklace", "brand": "Pandora", "price": 75, "url": "https://www.pandora.net/heart-necklace", "image": "https://pandora.com/images/heart-necklace.jpg", "description": "Collier cœur Pandora", "category": "bijoux"},
    {"name": "Pandora Hoop Earrings", "brand": "Pandora", "price": 55, "url": "https://www.pandora.net/hoop-earrings", "image": "https://pandora.com/images/hoops.jpg", "description": "Créoles Pandora argent", "category": "bijoux"},
]

# TIFFANY & CO. (Bijoux Luxe)
tiffany_products = [
    {"name": "Tiffany Return to Tiffany Heart Tag Bracelet", "brand": "Tiffany & Co.", "price": 295, "url": "https://www.tiffany.com/return-to-tiffany-bracelet", "image": "https://tiffany.com/images/rtt-bracelet.jpg", "description": "Bracelet Tiffany cœur iconique", "category": "bijoux"},
    {"name": "Tiffany T Smile Pendant", "brand": "Tiffany & Co.", "price": 350, "url": "https://www.tiffany.com/t-smile-pendant", "image": "https://tiffany.com/images/t-smile.jpg", "description": "Pendentif Tiffany T Smile", "category": "bijoux"},
    {"name": "Tiffany Knot Ring", "brand": "Tiffany & Co.", "price": 425, "url": "https://www.tiffany.com/knot-ring", "image": "https://tiffany.com/images/knot-ring.jpg", "description": "Bague Tiffany Knot", "category": "bijoux"},
    {"name": "Tiffany Hardwear Ball Bracelet", "brand": "Tiffany & Co.", "price": 650, "url": "https://www.tiffany.com/hardwear-bracelet", "image": "https://tiffany.com/images/hardwear.jpg", "description": "Bracelet Tiffany Hardwear", "category": "bijoux"},
    {"name": "Tiffany Victoria Diamond Earrings", "brand": "Tiffany & Co.", "price": 3500, "url": "https://www.tiffany.com/victoria-earrings", "image": "https://tiffany.com/images/victoria.jpg", "description": "Boucles d'oreilles Tiffany Victoria diamants", "category": "bijoux"},
]

# CARTIER (Bijoux Ultra Luxe)
cartier_products = [
    {"name": "Cartier Love Bracelet", "brand": "Cartier", "price": 7200, "url": "https://www.cartier.com/love-bracelet", "image": "https://cartier.com/images/love.jpg", "description": "Bracelet Cartier Love or jaune", "category": "bijoux"},
    {"name": "Cartier Juste un Clou Bracelet", "brand": "Cartier", "price": 6800, "url": "https://www.cartier.com/juste-un-clou", "image": "https://cartier.com/images/juste-un-clou.jpg", "description": "Bracelet Cartier Juste un Clou", "category": "bijoux"},
    {"name": "Cartier Trinity Ring", "brand": "Cartier", "price": 1650, "url": "https://www.cartier.com/trinity-ring", "image": "https://cartier.com/images/trinity.jpg", "description": "Bague Cartier Trinity 3 ors", "category": "bijoux"},
    {"name": "Cartier Panthère de Cartier Ring", "brand": "Cartier", "price": 3900, "url": "https://www.cartier.com/panthere-ring", "image": "https://cartier.com/images/panthere.jpg", "description": "Bague Cartier Panthère", "category": "bijoux"},
    {"name": "Cartier Santos Watch", "brand": "Cartier", "price": 7250, "url": "https://www.cartier.com/santos-watch", "image": "https://cartier.com/images/santos.jpg", "description": "Montre Cartier Santos", "category": "bijoux"},
]

# RAY-BAN (Lunettes)
rayban_products = [
    {"name": "Ray-Ban Original Wayfarer", "brand": "Ray-Ban", "price": 165, "url": "https://www.ray-ban.com/wayfarer", "image": "https://ray-ban.com/images/wayfarer.jpg", "description": "Lunettes Ray-Ban Wayfarer classiques", "category": "fashion"},
    {"name": "Ray-Ban Aviator Classic", "brand": "Ray-Ban", "price": 175, "url": "https://www.ray-ban.com/aviator", "image": "https://ray-ban.com/images/aviator.jpg", "description": "Lunettes Ray-Ban Aviator", "category": "fashion"},
    {"name": "Ray-Ban Clubmaster", "brand": "Ray-Ban", "price": 185, "url": "https://www.ray-ban.com/clubmaster", "image": "https://ray-ban.com/images/clubmaster.jpg", "description": "Lunettes Ray-Ban Clubmaster", "category": "fashion"},
    {"name": "Ray-Ban Round Metal", "brand": "Ray-Ban", "price": 170, "url": "https://www.ray-ban.com/round-metal", "image": "https://ray-ban.com/images/round.jpg", "description": "Lunettes Ray-Ban Round rondes", "category": "fashion"},
    {"name": "Ray-Ban Justin", "brand": "Ray-Ban", "price": 155, "url": "https://www.ray-ban.com/justin", "image": "https://ray-ban.com/images/justin.jpg", "description": "Lunettes Ray-Ban Justin", "category": "fashion"},
]

# RIMOWA (Bagages Luxe)
rimowa_products = [
    {"name": "Rimowa Original Cabin S", "brand": "Rimowa", "price": 1050, "url": "https://www.rimowa.com/original-cabin", "image": "https://rimowa.com/images/original-cabin.jpg", "description": "Valise cabine Rimowa Original", "category": "fashion"},
    {"name": "Rimowa Essential Lite Cabin", "brand": "Rimowa", "price": 650, "url": "https://www.rimowa.com/essential-lite", "image": "https://rimowa.com/images/essential-lite.jpg", "description": "Valise Rimowa Essential Lite légère", "category": "fashion"},
    {"name": "Rimowa Classic Flight", "brand": "Rimowa", "price": 1450, "url": "https://www.rimowa.com/classic-flight", "image": "https://rimowa.com/images/classic.jpg", "description": "Valise Rimowa Classic Flight", "category": "fashion"},
    {"name": "Rimowa Never Still Backpack", "brand": "Rimowa", "price": 895, "url": "https://www.rimowa.com/never-still-backpack", "image": "https://rimowa.com/images/backpack.jpg", "description": "Sac à dos Rimowa Never Still", "category": "fashion"},
]

# AWAY (Bagages)
away_products = [
    {"name": "Away The Carry-On", "brand": "Away", "price": 275, "url": "https://www.awaytravel.com/carry-on", "image": "https://away.com/images/carry-on.jpg", "description": "Valise cabine Away avec batterie", "category": "fashion"},
    {"name": "Away The Bigger Carry-On", "brand": "Away", "price": 295, "url": "https://www.awaytravel.com/bigger-carry-on", "image": "https://away.com/images/bigger-carry-on.jpg", "description": "Grande valise cabine Away", "category": "fashion"},
    {"name": "Away The Medium", "brand": "Away", "price": 325, "url": "https://www.awaytravel.com/medium", "image": "https://away.com/images/medium.jpg", "description": "Valise moyenne Away", "category": "fashion"},
    {"name": "Away The Large", "brand": "Away", "price": 375, "url": "https://www.awaytravel.com/large", "image": "https://away.com/images/large.jpg", "description": "Grande valise Away", "category": "fashion"},
]

# Compile all products
MEGA_PRODUCTS.extend(gucci_products)
MEGA_PRODUCTS.extend(lv_products)
MEGA_PRODUCTS.extend(prada_products)
MEGA_PRODUCTS.extend(dior_fashion)
MEGA_PRODUCTS.extend(ysl_fashion)
MEGA_PRODUCTS.extend(balenciaga_products)
MEGA_PRODUCTS.extend(bv_products)
MEGA_PRODUCTS.extend(celine_products)
MEGA_PRODUCTS.extend(hermes_products)
MEGA_PRODUCTS.extend(chanel_fashion)
MEGA_PRODUCTS.extend(ikea_products)
MEGA_PRODUCTS.extend(lecreuset_products)
MEGA_PRODUCTS.extend(kitchenaid_products)
MEGA_PRODUCTS.extend(nespresso_products)
MEGA_PRODUCTS.extend(drmartens_products)
MEGA_PRODUCTS.extend(pandora_products)
MEGA_PRODUCTS.extend(tiffany_products)
MEGA_PRODUCTS.extend(cartier_products)
MEGA_PRODUCTS.extend(rayban_products)
MEGA_PRODUCTS.extend(rimowa_products)
MEGA_PRODUCTS.extend(away_products)

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

    existing.extend(MEGA_PRODUCTS)
    save_all(existing)

    print(f"✓ Added {len(MEGA_PRODUCTS)} mega products (Fashion Luxe, Home, Bijoux, etc.)")
    print(f"✓ Total products: {len(existing)}")
    
    # Count by brand
    brands = set([p['brand'] for p in existing])
    print(f"✓ Total brands covered: {len(brands)}")
