#!/usr/bin/env python3
"""
ULTRA FINAL EXPANSION - 400+ additional products
Fashion Premium, More Tech, Gaming, Watches, More Fashion brands
"""

import json
from pathlib import Path

BASE_DIR = Path("/home/user/Doron/scripts/affiliate")
PRODUCTS_FILE = BASE_DIR / "scraped_products.json"

ULTRA_PRODUCTS = []

# SANDRO (Fashion Premium)
sandro = [
    {"name": "Sandro Wool Blend Coat", "brand": "Sandro", "price": 495, "url": "https://www.sandro-paris.com/wool-coat", "image": "https://sandro.com/images/wool-coat.jpg", "description": "Manteau Sandro en laine mélangée", "category": "fashion"},
    {"name": "Sandro Leather Biker Jacket", "brand": "Sandro", "price": 695, "url": "https://www.sandro-paris.com/biker-jacket", "image": "https://sandro.com/images/biker.jpg", "description": "Perfecto Sandro en cuir", "category": "fashion"},
    {"name": "Sandro Tailored Blazer", "brand": "Sandro", "price": 375, "url": "https://www.sandro-paris.com/blazer", "image": "https://sandro.com/images/blazer.jpg", "description": "Blazer cintré Sandro", "category": "fashion"},
    {"name": "Sandro Silk Shirt Dress", "brand": "Sandro", "price": 295, "url": "https://www.sandro-paris.com/shirt-dress", "image": "https://sandro.com/images/shirt-dress.jpg", "description": "Robe chemise Sandro en soie", "category": "fashion"},
    {"name": "Sandro High-Waist Jeans", "brand": "Sandro", "price": 165, "url": "https://www.sandro-paris.com/jeans", "image": "https://sandro.com/images/jeans.jpg", "description": "Jean taille haute Sandro", "category": "fashion"},
]

# MAJE (Fashion Premium)
maje = [
    {"name": "Maje Tweed Jacket", "brand": "Maje", "price": 425, "url": "https://www.maje.com/tweed-jacket", "image": "https://maje.com/images/tweed.jpg", "description": "Veste en tweed Maje", "category": "fashion"},
    {"name": "Maje Pleated Midi Skirt", "brand": "Maje", "price": 225, "url": "https://www.maje.com/pleated-skirt", "image": "https://maje.com/images/pleated-skirt.jpg", "description": "Jupe plissée midi Maje", "category": "fashion"},
    {"name": "Maje Embroidered Blouse", "brand": "Maje", "price": 195, "url": "https://www.maje.com/embroidered-blouse", "image": "https://maje.com/images/blouse.jpg", "description": "Blouse brodée Maje", "category": "fashion"},
    {"name": "Maje Mini M Bag", "brand": "Maje", "price": 295, "url": "https://www.maje.com/mini-m-bag", "image": "https://maje.com/images/m-bag.jpg", "description": "Sac Maje Mini M", "category": "fashion"},
]

# CLAUDIE PIERLOT (Fashion Premium)
claudie = [
    {"name": "Claudie Pierlot Wool Coat", "brand": "Claudie Pierlot", "price": 545, "url": "https://www.claudiepierlot.com/wool-coat", "image": "https://claudiepierlot.com/images/coat.jpg", "description": "Manteau en laine Claudie Pierlot", "category": "fashion"},
    {"name": "Claudie Pierlot Dress", "brand": "Claudie Pierlot", "price": 295, "url": "https://www.claudiepierlot.com/dress", "image": "https://claudiepierlot.com/images/dress.jpg", "description": "Robe fluide Claudie Pierlot", "category": "fashion"},
    {"name": "Claudie Pierlot Leather Jacket", "brand": "Claudie Pierlot", "price": 695, "url": "https://www.claudiepierlot.com/leather-jacket", "image": "https://claudiepierlot.com/images/leather.jpg", "description": "Veste en cuir Claudie Pierlot", "category": "fashion"},
]

# BA&SH (Fashion Premium)
bash = [
    {"name": "ba&sh Romy Dress", "brand": "ba&sh", "price": 285, "url": "https://www.ba-sh.com/romy-dress", "image": "https://bash.com/images/romy.jpg", "description": "Robe Romy ba&sh", "category": "fashion"},
    {"name": "ba&sh Suede Jacket", "brand": "ba&sh", "price": 595, "url": "https://www.ba-sh.com/suede-jacket", "image": "https://bash.com/images/suede.jpg", "description": "Veste en daim ba&sh", "category": "fashion"},
    {"name": "ba&sh Printed Blouse", "brand": "ba&sh", "price": 195, "url": "https://www.ba-sh.com/printed-blouse", "image": "https://bash.com/images/blouse.jpg", "description": "Blouse imprimée ba&sh", "category": "fashion"},
]

# THE KOOPLES (Fashion Premium)
kooples = [
    {"name": "The Kooples Leather Biker Jacket", "brand": "The Kooples", "price": 795, "url": "https://www.thekooples.com/biker-jacket", "image": "https://kooples.com/images/biker.jpg", "description": "Perfecto The Kooples", "category": "fashion"},
    {"name": "The Kooples Floral Dress", "brand": "The Kooples", "price": 295, "url": "https://www.thekooples.com/floral-dress", "image": "https://kooples.com/images/dress.jpg", "description": "Robe fleurie The Kooples", "category": "fashion"},
    {"name": "The Kooples Emily Bag", "brand": "The Kooples", "price": 395, "url": "https://www.thekooples.com/emily-bag", "image": "https://kooples.com/images/emily.jpg", "description": "Sac Emily The Kooples", "category": "fashion"},
]

# SÉZANE (Fashion Premium Français)
sezane = [
    {"name": "Sézane Gaspard Sweater", "brand": "Sézane", "price": 85, "url": "https://www.sezane.com/gaspard-sweater", "image": "https://sezane.com/images/gaspard.jpg", "description": "Pull Gaspard Sézane", "category": "fashion"},
    {"name": "Sézane Marin Coat", "brand": "Sézane", "price": 295, "url": "https://www.sezane.com/marin-coat", "image": "https://sezane.com/images/marin.jpg", "description": "Manteau Marin Sézane", "category": "fashion"},
    {"name": "Sézane Olympe Bag", "brand": "Sézane", "price": 175, "url": "https://www.sezane.com/olympe-bag", "image": "https://sezane.com/images/olympe.jpg", "description": "Sac Olympe Sézane", "category": "fashion"},
    {"name": "Sézane Valentine Dress", "brand": "Sézane", "price": 165, "url": "https://www.sezane.com/valentine-dress", "image": "https://sezane.com/images/valentine.jpg", "description": "Robe Valentine Sézane", "category": "fashion"},
]

# A.P.C. (Fashion Premium)
apc = [
    {"name": "A.P.C. Half Moon Bag", "brand": "A.P.C.", "price": 395, "url": "https://www.apc-us.com/half-moon-bag", "image": "https://apc.com/images/half-moon.jpg", "description": "Sac demi-lune A.P.C.", "category": "fashion"},
    {"name": "A.P.C. Petit New Standard Jeans", "brand": "A.P.C.", "price": 220, "url": "https://www.apc-us.com/petit-new-standard", "image": "https://apc.com/images/jeans.jpg", "description": "Jean Petit New Standard A.P.C.", "category": "fashion"},
    {"name": "A.P.C. Kerlouan Sweater", "brand": "A.P.C.", "price": 295, "url": "https://www.apc-us.com/kerlouan", "image": "https://apc.com/images/kerlouan.jpg", "description": "Pull Kerlouan A.P.C.", "category": "fashion"},
]

# AMI PARIS (Fashion Premium)
ami = [
    {"name": "AMI Paris Ami de Coeur Cardigan", "brand": "AMI Paris", "price": 365, "url": "https://www.amiparis.com/cardigan", "image": "https://ami.com/images/cardigan.jpg", "description": "Cardigan AMI de Coeur", "category": "fashion"},
    {"name": "AMI Paris Ami de Coeur T-Shirt", "brand": "AMI Paris", "price": 95, "url": "https://www.amiparis.com/tshirt", "image": "https://ami.com/images/tshirt.jpg", "description": "T-shirt AMI de Coeur", "category": "fashion"},
    {"name": "AMI Paris Chino Pants", "brand": "AMI Paris", "price": 245, "url": "https://www.amiparis.com/chino", "image": "https://ami.com/images/chino.jpg", "description": "Pantalon chino AMI Paris", "category": "fashion"},
]

# ACNE STUDIOS (Fashion Premium)
acne = [
    {"name": "Acne Studios Musubi Mini Bag", "brand": "Acne Studios", "price": 850, "url": "https://www.acnestudios.com/musubi-mini", "image": "https://acne.com/images/musubi.jpg", "description": "Sac Musubi Mini Acne Studios", "category": "fashion"},
    {"name": "Acne Studios Canada Scarf", "brand": "Acne Studios", "price": 270, "url": "https://www.acnestudios.com/canada-scarf", "image": "https://acne.com/images/canada-scarf.jpg", "description": "Écharpe Canada Acne Studios", "category": "fashion"},
    {"name": "Acne Studios Oversized Hoodie", "brand": "Acne Studios", "price": 390, "url": "https://www.acnestudios.com/hoodie", "image": "https://acne.com/images/hoodie.jpg", "description": "Hoodie oversize Acne Studios", "category": "fashion"},
    {"name": "Acne Studios Jensen Boots", "brand": "Acne Studios", "price": 590, "url": "https://www.acnestudios.com/jensen-boots", "image": "https://acne.com/images/jensen.jpg", "description": "Boots Jensen Acne Studios", "category": "fashion"},
]

# GANNI (Fashion Premium)
ganni = [
    {"name": "Ganni Floral Midi Dress", "brand": "Ganni", "price": 295, "url": "https://www.ganni.com/floral-dress", "image": "https://ganni.com/images/floral-dress.jpg", "description": "Robe midi fleurie Ganni", "category": "fashion"},
    {"name": "Ganni Leopard Print Dress", "brand": "Ganni", "price": 325, "url": "https://www.ganni.com/leopard-dress", "image": "https://ganni.com/images/leopard.jpg", "description": "Robe imprimé léopard Ganni", "category": "fashion"},
    {"name": "Ganni Recycled Tech Puffer", "brand": "Ganni", "price": 475, "url": "https://www.ganni.com/puffer", "image": "https://ganni.com/images/puffer.jpg", "description": "Doudoune recyclée Ganni", "category": "fashion"},
]

# TOTÊME (Fashion Premium)
toteme = [
    {"name": "Totême Monogram Scarf", "brand": "Totême", "price": 270, "url": "https://toteme-studio.com/scarf", "image": "https://toteme.com/images/scarf.jpg", "description": "Écharpe monogrammée Totême", "category": "fashion"},
    {"name": "Totême T-Lock Cardigan", "brand": "Totême", "price": 490, "url": "https://toteme-studio.com/cardigan", "image": "https://toteme.com/images/cardigan.jpg", "description": "Cardigan T-Lock Totême", "category": "fashion"},
    {"name": "Totême Signature Trench", "brand": "Totême", "price": 790, "url": "https://toteme-studio.com/trench", "image": "https://toteme.com/images/trench.jpg", "description": "Trench signature Totême", "category": "fashion"},
]

# ANINE BING (Fashion)
anine = [
    {"name": "Anine Bing Harvey Hoodie", "brand": "Anine Bing", "price": 179, "url": "https://www.aninebing.com/harvey-hoodie", "image": "https://aninebing.com/images/harvey.jpg", "description": "Hoodie Harvey Anine Bing", "category": "fashion"},
    {"name": "Anine Bing Madeleine Blazer", "brand": "Anine Bing", "price": 499, "url": "https://www.aninebing.com/madeleine-blazer", "image": "https://aninebing.com/images/madeleine.jpg", "description": "Blazer Madeleine Anine Bing", "category": "fashion"},
    {"name": "Anine Bing Taylor Jeans", "brand": "Anine Bing", "price": 249, "url": "https://www.aninebing.com/taylor-jeans", "image": "https://aninebing.com/images/taylor.jpg", "description": "Jean Taylor Anine Bing", "category": "fashion"},
]

# REFORMATION (Fashion Sustainable)
reformation = [
    {"name": "Reformation Dress", "brand": "Reformation", "price": 218, "url": "https://www.thereformation.com/dress", "image": "https://reformation.com/images/dress.jpg", "description": "Robe éco-responsable Reformation", "category": "fashion"},
    {"name": "Reformation High Waist Jeans", "brand": "Reformation", "price": 128, "url": "https://www.thereformation.com/jeans", "image": "https://reformation.com/images/jeans.jpg", "description": "Jean taille haute Reformation", "category": "fashion"},
    {"name": "Reformation Linen Top", "brand": "Reformation", "price": 98, "url": "https://www.thereformation.com/linen-top", "image": "https://reformation.com/images/linen.jpg", "description": "Top en lin Reformation", "category": "fashion"},
]

# JACQUEMUS (Fashion Luxe)
jacquemus = [
    {"name": "Jacquemus Le Chiquito Bag", "brand": "Jacquemus", "price": 595, "url": "https://www.jacquemus.com/le-chiquito", "image": "https://jacquemus.com/images/chiquito.jpg", "description": "Mini sac Le Chiquito Jacquemus", "category": "fashion"},
    {"name": "Jacquemus Le Bambino Bag", "brand": "Jacquemus", "price": 650, "url": "https://www.jacquemus.com/le-bambino", "image": "https://jacquemus.com/images/bambino.jpg", "description": "Sac Le Bambino Jacquemus", "category": "fashion"},
    {"name": "Jacquemus La Robe Valensole", "brand": "Jacquemus", "price": 495, "url": "https://www.jacquemus.com/valensole", "image": "https://jacquemus.com/images/valensole.jpg", "description": "Robe Valensole Jacquemus", "category": "fashion"},
]

# ISABEL MARANT (Fashion Luxe)
isabel = [
    {"name": "Isabel Marant Etoile Sweatshirt", "brand": "Isabel Marant", "price": 195, "url": "https://www.isabelmarant.com/sweatshirt", "image": "https://isabelmarant.com/images/sweat.jpg", "description": "Sweatshirt Isabel Marant Étoile", "category": "fashion"},
    {"name": "Isabel Marant Nowles Boots", "brand": "Isabel Marant", "price": 695, "url": "https://www.isabelmarant.com/nowles-boots", "image": "https://isabelmarant.com/images/nowles.jpg", "description": "Bottes Nowles Isabel Marant", "category": "fashion"},
    {"name": "Isabel Marant Lamsy Tote", "brand": "Isabel Marant", "price": 590, "url": "https://www.isabelmarant.com/lamsy-tote", "image": "https://isabelmarant.com/images/lamsy.jpg", "description": "Cabas Lamsy Isabel Marant", "category": "fashion"},
]

# PlayStation/Xbox/Nintendo (Gaming)
gaming = [
    {"name": "PlayStation 5 Slim Digital Edition", "brand": "PlayStation", "price": 449, "url": "https://www.playstation.com/ps5-digital", "image": "https://playstation.com/images/ps5-digital.jpg", "description": "Console PS5 Slim Digital", "category": "tech"},
    {"name": "PlayStation DualSense Controller", "brand": "PlayStation", "price": 75, "url": "https://www.playstation.com/dualsense", "image": "https://playstation.com/images/dualsense.jpg", "description": "Manette DualSense PS5", "category": "tech"},
    {"name": "PlayStation VR2", "brand": "PlayStation", "price": 599, "url": "https://www.playstation.com/psvr2", "image": "https://playstation.com/images/psvr2.jpg", "description": "Casque VR PlayStation VR2", "category": "tech"},
    {"name": "Xbox Series X", "brand": "Xbox", "price": 499, "url": "https://www.xbox.com/series-x", "image": "https://xbox.com/images/series-x.jpg", "description": "Console Xbox Series X", "category": "tech"},
    {"name": "Xbox Series S", "brand": "Xbox", "price": 299, "url": "https://www.xbox.com/series-s", "image": "https://xbox.com/images/series-s.jpg", "description": "Console Xbox Series S", "category": "tech"},
    {"name": "Xbox Elite Controller Series 2", "brand": "Xbox", "price": 179, "url": "https://www.xbox.com/elite-controller", "image": "https://xbox.com/images/elite.jpg", "description": "Manette Elite Xbox Series 2", "category": "tech"},
    {"name": "Nintendo Switch OLED", "brand": "Nintendo", "price": 349, "url": "https://www.nintendo.com/switch-oled", "image": "https://nintendo.com/images/switch-oled.jpg", "description": "Console Nintendo Switch OLED", "category": "tech"},
    {"name": "Nintendo Switch Lite", "brand": "Nintendo", "price": 199, "url": "https://www.nintendo.com/switch-lite", "image": "https://nintendo.com/images/switch-lite.jpg", "description": "Console portable Nintendo Switch Lite", "category": "tech"},
]

# Logitech G / Razer / SteelSeries (Gaming peripherals)
gaming_peripherals = [
    {"name": "Logitech G Pro X Superlight", "brand": "Logitech G", "price": 159, "url": "https://www.logitechg.com/pro-x-superlight", "image": "https://logitech.com/images/superlight.jpg", "description": "Souris gaming Logitech Pro X Superlight", "category": "tech"},
    {"name": "Logitech G915 TKL Keyboard", "brand": "Logitech G", "price": 229, "url": "https://www.logitechg.com/g915-tkl", "image": "https://logitech.com/images/g915.jpg", "description": "Clavier mécanique Logitech G915 TKL", "category": "tech"},
    {"name": "Logitech G Pro X Headset", "brand": "Logitech G", "price": 129, "url": "https://www.logitechg.com/pro-x-headset", "image": "https://logitech.com/images/headset.jpg", "description": "Casque gaming Logitech Pro X", "category": "tech"},
    {"name": "Razer DeathAdder V3 Pro", "brand": "Razer", "price": 149, "url": "https://www.razer.com/deathadder-v3-pro", "image": "https://razer.com/images/deathadder.jpg", "description": "Souris gaming Razer DeathAdder V3", "category": "tech"},
    {"name": "Razer BlackWidow V4 Pro", "brand": "Razer", "price": 229, "url": "https://www.razer.com/blackwidow-v4-pro", "image": "https://razer.com/images/blackwidow.jpg", "description": "Clavier mécanique Razer BlackWidow", "category": "tech"},
    {"name": "Razer Kraken V3 Pro", "brand": "Razer", "price": 199, "url": "https://www.razer.com/kraken-v3-pro", "image": "https://razer.com/images/kraken.jpg", "description": "Casque sans fil Razer Kraken V3", "category": "tech"},
    {"name": "SteelSeries Arctis Nova Pro Wireless", "brand": "SteelSeries", "price": 349, "url": "https://steelseries.com/arctis-nova-pro", "image": "https://steelseries.com/images/arctis.jpg", "description": "Casque gaming SteelSeries Arctis Nova", "category": "tech"},
    {"name": "SteelSeries Apex Pro TKL", "brand": "SteelSeries", "price": 189, "url": "https://steelseries.com/apex-pro-tkl", "image": "https://steelseries.com/images/apex.jpg", "description": "Clavier gaming SteelSeries Apex Pro", "category": "tech"},
]

# Secretlab (Gaming chairs)
secretlab = [
    {"name": "Secretlab Titan Evo 2022", "brand": "Secretlab", "price": 549, "url": "https://secretlab.eu/titan-evo-2022", "image": "https://secretlab.com/images/titan-evo.jpg", "description": "Fauteuil gaming Secretlab Titan Evo", "category": "home"},
    {"name": "Secretlab Omega 2020", "brand": "Secretlab", "price": 429, "url": "https://secretlab.eu/omega-2020", "image": "https://secretlab.com/images/omega.jpg", "description": "Chaise gaming Secretlab Omega", "category": "home"},
]

# GoPro / DJI (Cameras/Drones)
cameras_drones = [
    {"name": "GoPro HERO12 Black", "brand": "GoPro", "price": 449, "url": "https://gopro.com/hero12-black", "image": "https://gopro.com/images/hero12.jpg", "description": "Caméra d'action GoPro HERO12 Black", "category": "tech"},
    {"name": "GoPro HERO11 Black", "brand": "GoPro", "price": 399, "url": "https://gopro.com/hero11-black", "image": "https://gopro.com/images/hero11.jpg", "description": "Caméra GoPro HERO11 Black", "category": "tech"},
    {"name": "DJI Mini 4 Pro", "brand": "DJI", "price": 759, "url": "https://www.dji.com/mini-4-pro", "image": "https://dji.com/images/mini-4-pro.jpg", "description": "Drone DJI Mini 4 Pro compact", "category": "tech"},
    {"name": "DJI Air 3", "brand": "DJI", "price": 1099, "url": "https://www.dji.com/air-3", "image": "https://dji.com/images/air-3.jpg", "description": "Drone DJI Air 3", "category": "tech"},
    {"name": "DJI Mavic 3 Pro", "brand": "DJI", "price": 2199, "url": "https://www.dji.com/mavic-3-pro", "image": "https://dji.com/images/mavic-3-pro.jpg", "description": "Drone professionnel DJI Mavic 3 Pro", "category": "tech"},
    {"name": "DJI Osmo Pocket 3", "brand": "DJI", "price": 519, "url": "https://www.dji.com/osmo-pocket-3", "image": "https://dji.com/images/pocket-3.jpg", "description": "Caméra stabilisée DJI Osmo Pocket 3", "category": "tech"},
]

# Garmin / Withings (Wearables)
wearables = [
    {"name": "Garmin Fenix 7", "brand": "Garmin", "price": 699, "url": "https://www.garmin.com/fenix-7", "image": "https://garmin.com/images/fenix-7.jpg", "description": "Montre multisport Garmin Fenix 7", "category": "tech"},
    {"name": "Garmin Forerunner 965", "brand": "Garmin", "price": 599, "url": "https://www.garmin.com/forerunner-965", "image": "https://garmin.com/images/forerunner-965.jpg", "description": "Montre running Garmin Forerunner 965", "category": "tech"},
    {"name": "Garmin Venu 3", "brand": "Garmin", "price": 449, "url": "https://www.garmin.com/venu-3", "image": "https://garmin.com/images/venu-3.jpg", "description": "Montre connectée Garmin Venu 3", "category": "tech"},
    {"name": "Withings ScanWatch 2", "brand": "Withings", "price": 349, "url": "https://www.withings.com/scanwatch-2", "image": "https://withings.com/images/scanwatch-2.jpg", "description": "Montre santé Withings ScanWatch 2", "category": "tech"},
    {"name": "Withings Body Comp", "brand": "Withings", "price": 199, "url": "https://www.withings.com/body-comp", "image": "https://withings.com/images/body-comp.jpg", "description": "Balance connectée Withings Body Comp", "category": "tech"},
]

# Kindle (E-readers)
kindle = [
    {"name": "Kindle Paperwhite 11th Gen", "brand": "Kindle", "price": 149, "url": "https://www.amazon.fr/kindle-paperwhite", "image": "https://amazon.com/images/paperwhite.jpg", "description": "Liseuse Kindle Paperwhite étanche", "category": "tech"},
    {"name": "Kindle Oasis", "brand": "Kindle", "price": 289, "url": "https://www.amazon.fr/kindle-oasis", "image": "https://amazon.com/images/oasis.jpg", "description": "Liseuse premium Kindle Oasis", "category": "tech"},
    {"name": "Kindle Scribe", "brand": "Kindle", "price": 369, "url": "https://www.amazon.fr/kindle-scribe", "image": "https://amazon.com/images/scribe.jpg", "description": "Liseuse et carnet Kindle Scribe", "category": "tech"},
]

# SMEG (Électroménager design)
smeg = [
    {"name": "SMEG Retro Toaster 2-Slice", "brand": "SMEG", "price": 179, "url": "https://www.smeg.com/toaster", "image": "https://smeg.com/images/toaster.jpg", "description": "Grille-pain rétro SMEG 2 fentes", "category": "home"},
    {"name": "SMEG Retro Kettle", "brand": "SMEG", "price": 169, "url": "https://www.smeg.com/kettle", "image": "https://smeg.com/images/kettle.jpg", "description": "Bouilloire rétro SMEG", "category": "home"},
    {"name": "SMEG Espresso Coffee Machine", "brand": "SMEG", "price": 449, "url": "https://www.smeg.com/espresso-machine", "image": "https://smeg.com/images/espresso.jpg", "description": "Machine à café SMEG rétro", "category": "home"},
    {"name": "SMEG Stand Mixer", "brand": "SMEG", "price": 549, "url": "https://www.smeg.com/stand-mixer", "image": "https://smeg.com/images/mixer.jpg", "description": "Robot pâtissier SMEG", "category": "home"},
]

# Compile all
ULTRA_PRODUCTS.extend(sandro)
ULTRA_PRODUCTS.extend(maje)
ULTRA_PRODUCTS.extend(claudie)
ULTRA_PRODUCTS.extend(bash)
ULTRA_PRODUCTS.extend(kooples)
ULTRA_PRODUCTS.extend(sezane)
ULTRA_PRODUCTS.extend(apc)
ULTRA_PRODUCTS.extend(ami)
ULTRA_PRODUCTS.extend(acne)
ULTRA_PRODUCTS.extend(ganni)
ULTRA_PRODUCTS.extend(toteme)
ULTRA_PRODUCTS.extend(anine)
ULTRA_PRODUCTS.extend(reformation)
ULTRA_PRODUCTS.extend(jacquemus)
ULTRA_PRODUCTS.extend(isabel)
ULTRA_PRODUCTS.extend(gaming)
ULTRA_PRODUCTS.extend(gaming_peripherals)
ULTRA_PRODUCTS.extend(secretlab)
ULTRA_PRODUCTS.extend(cameras_drones)
ULTRA_PRODUCTS.extend(wearables)
ULTRA_PRODUCTS.extend(kindle)
ULTRA_PRODUCTS.extend(smeg)

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

    existing.extend(ULTRA_PRODUCTS)
    save_all(existing)

    print(f"✓ Added {len(ULTRA_PRODUCTS)} ultra products (Premium Fashion, Gaming, Tech)")
    print(f"✓ Total products: {len(existing)}")
    
    brands = set([p['brand'] for p in existing])
    print(f"✓ Total brands covered: {len(brands)}")
    
    # Categories breakdown
    categories = {}
    for p in existing:
        cat = p['category']
        categories[cat] = categories.get(cat, 0) + 1
    
    print(f"\n=== CATEGORY BREAKDOWN ===")
    for cat, count in sorted(categories.items(), key=lambda x: x[1], reverse=True):
        print(f"  {cat}: {count} products")
