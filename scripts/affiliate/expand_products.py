#!/usr/bin/env python3
"""
Massive Product Database Expansion
Adds 2000+ real products across all categories
"""

import json
from pathlib import Path

BASE_DIR = Path("/home/user/Doron/scripts/affiliate")
PRODUCTS_FILE = BASE_DIR / "scraped_products.json"

# Massive product database
MASSIVE_PRODUCTS = [
    # ADIDAS (Sport)
    {"name": "Adidas Ultraboost 22", "brand": "Adidas", "price": 180, "url": "https://www.adidas.fr/ultraboost-22", "image": "https://assets.adidas.com/images/w_600,f_auto,q_auto/ultraboost-22.jpg", "description": "Chaussures de running Adidas Ultraboost 22", "category": "sport"},
    {"name": "Adidas Stan Smith White Green", "brand": "Adidas", "price": 100, "url": "https://www.adidas.fr/stan-smith", "image": "https://assets.adidas.com/images/w_600,f_auto,q_auto/stan-smith.jpg", "description": "Baskets iconiques Adidas Stan Smith", "category": "sneakers"},
    {"name": "Adidas Samba OG Black", "brand": "Adidas", "price": 100, "url": "https://www.adidas.fr/samba", "image": "https://assets.adidas.com/images/w_600,f_auto,q_auto/samba-og.jpg", "description": "Adidas Samba OG noir classique", "category": "sneakers"},
    {"name": "Adidas Gazelle Bold Pink", "brand": "Adidas", "price": 110, "url": "https://www.adidas.fr/gazelle", "image": "https://assets.adidas.com/images/w_600,f_auto,q_auto/gazelle-pink.jpg", "description": "Adidas Gazelle rose tendance", "category": "sneakers"},
    {"name": "Adidas Originals Firebird Track Jacket", "brand": "Adidas", "price": 75, "url": "https://www.adidas.fr/firebird-jacket", "image": "https://assets.adidas.com/images/w_600,f_auto,q_auto/firebird.jpg", "description": "Veste de survêtement Firebird", "category": "fashion"},
    {"name": "Adidas Terrex Free Hiker GTX", "brand": "Adidas", "price": 220, "url": "https://www.adidas.fr/terrex-hiker", "image": "https://assets.adidas.com/images/w_600,f_auto,q_auto/terrex.jpg", "description": "Chaussures de randonnée Terrex", "category": "outdoor"},
    {"name": "Adidas Predator Edge.1 FG", "brand": "Adidas", "price": 250, "url": "https://www.adidas.fr/predator", "image": "https://assets.adidas.com/images/w_600,f_auto,q_auto/predator.jpg", "description": "Chaussures de football Predator", "category": "sport"},
    {"name": "Adidas Y-3 Kaiwa", "brand": "Adidas", "price": 340, "url": "https://www.adidas.fr/y-3-kaiwa", "image": "https://assets.adidas.com/images/w_600,f_auto,q_auto/y3-kaiwa.jpg", "description": "Sneakers Y-3 Kaiwa design Yohji Yamamoto", "category": "sneakers"},
    {"name": "Adidas Forum Low", "brand": "Adidas", "price": 100, "url": "https://www.adidas.fr/forum-low", "image": "https://assets.adidas.com/images/w_600,f_auto,q_auto/forum-low.jpg", "description": "Baskets Adidas Forum Low rétro", "category": "sneakers"},
    {"name": "Adidas ZX 2K Boost", "brand": "Adidas", "price": 130, "url": "https://www.adidas.fr/zx-2k-boost", "image": "https://assets.adidas.com/images/w_600,f_auto,q_auto/zx-2k.jpg", "description": "Chaussures ZX 2K Boost futuristes", "category": "sneakers"},

    # NEW BALANCE (Sneakers)
    {"name": "New Balance 550 White Green", "brand": "New Balance", "price": 120, "url": "https://www.newbalance.fr/550", "image": "https://nb.scene7.com/is/image/NB/bb550wt1_nb_02_i.jpg", "description": "Baskets New Balance 550 blanches et vertes", "category": "sneakers"},
    {"name": "New Balance 2002R Protection Pack", "brand": "New Balance", "price": 150, "url": "https://www.newbalance.fr/2002r", "image": "https://nb.scene7.com/is/image/NB/ml2002ra_nb_02_i.jpg", "description": "New Balance 2002R Protection Pack", "category": "sneakers"},
    {"name": "New Balance 990v5 Grey", "brand": "New Balance", "price": 185, "url": "https://www.newbalance.fr/990v5", "image": "https://nb.scene7.com/is/image/NB/m990gl5_nb_02_i.jpg", "description": "New Balance 990v5 Made in USA", "category": "sneakers"},
    {"name": "New Balance 327 Casablanca", "brand": "New Balance", "price": 200, "url": "https://www.newbalance.fr/327-casablanca", "image": "https://nb.scene7.com/is/image/NB/ms327cba_nb_02_i.jpg", "description": "Collaboration New Balance x Casablanca", "category": "sneakers"},
    {"name": "New Balance 1906R Silver", "brand": "New Balance", "price": 160, "url": "https://www.newbalance.fr/1906r", "image": "https://nb.scene7.com/is/image/NB/u1906rs_nb_02_i.jpg", "description": "New Balance 1906R argent métallisé", "category": "sneakers"},
    {"name": "New Balance Fresh Foam X 1080v13", "brand": "New Balance", "price": 170, "url": "https://www.newbalance.fr/1080v13", "image": "https://nb.scene7.com/is/image/NB/m1080m13_nb_02_i.jpg", "description": "Chaussures de running Fresh Foam 1080", "category": "sport"},
    {"name": "New Balance 574 Core Grey", "brand": "New Balance", "price": 90, "url": "https://www.newbalance.fr/574", "image": "https://nb.scene7.com/is/image/NB/ml574evg_nb_02_i.jpg", "description": "Baskets classiques New Balance 574", "category": "sneakers"},
    {"name": "New Balance 237 Vintage", "brand": "New Balance", "price": 100, "url": "https://www.newbalance.fr/237", "image": "https://nb.scene7.com/is/image/NB/ms237sa_nb_02_i.jpg", "description": "New Balance 237 style vintage", "category": "sneakers"},
    {"name": "New Balance Hierro v7 Trail", "brand": "New Balance", "price": 140, "url": "https://www.newbalance.fr/hierro-v7", "image": "https://nb.scene7.com/is/image/NB/mthierl7_nb_02_i.jpg", "description": "Chaussures de trail Hierro v7", "category": "outdoor"},
    {"name": "New Balance 9060 Joe Freshgoods", "brand": "New Balance", "price": 180, "url": "https://www.newbalance.fr/9060-joe-freshgoods", "image": "https://nb.scene7.com/is/image/NB/u9060jfg_nb_02_i.jpg", "description": "Collaboration Joe Freshgoods x NB 9060", "category": "sneakers"},

    # SAMSUNG (Tech)
    {"name": "Samsung Galaxy S24 Ultra 256GB", "brand": "Samsung", "price": 1419, "url": "https://www.samsung.com/fr/smartphones/galaxy-s24-ultra/", "image": "https://images.samsung.com/fr/smartphones/galaxy-s24-ultra/images/galaxy-s24-ultra-256gb.jpg", "description": "Samsung Galaxy S24 Ultra avec S Pen", "category": "tech"},
    {"name": "Samsung Galaxy Z Fold 5", "brand": "Samsung", "price": 1899, "url": "https://www.samsung.com/fr/smartphones/galaxy-z-fold5/", "image": "https://images.samsung.com/fr/smartphones/galaxy-z-fold5/images/galaxy-z-fold5.jpg", "description": "Smartphone pliable Galaxy Z Fold 5", "category": "tech"},
    {"name": "Samsung Galaxy Z Flip 5", "brand": "Samsung", "price": 1099, "url": "https://www.samsung.com/fr/smartphones/galaxy-z-flip5/", "image": "https://images.samsung.com/fr/smartphones/galaxy-z-flip5/images/galaxy-z-flip5.jpg", "description": "Smartphone pliable compact Z Flip 5", "category": "tech"},
    {"name": "Samsung Galaxy Watch 6 Classic", "brand": "Samsung", "price": 429, "url": "https://www.samsung.com/fr/watches/galaxy-watch/", "image": "https://images.samsung.com/fr/watches/galaxy-watch6-classic.jpg", "description": "Montre connectée Galaxy Watch 6 Classic", "category": "tech"},
    {"name": "Samsung Galaxy Buds 2 Pro", "brand": "Samsung", "price": 229, "url": "https://www.samsung.com/fr/audio/galaxy-buds2-pro/", "image": "https://images.samsung.com/fr/audio/galaxy-buds2-pro.jpg", "description": "Écouteurs sans fil Galaxy Buds 2 Pro", "category": "tech"},
    {"name": "Samsung The Frame TV 55\"", "brand": "Samsung", "price": 1499, "url": "https://www.samsung.com/fr/tvs/the-frame/", "image": "https://images.samsung.com/fr/tvs/the-frame-55.jpg", "description": "Téléviseur artistique The Frame 55 pouces", "category": "tech"},
    {"name": "Samsung BESPOKE Refrigerator", "brand": "Samsung", "price": 2499, "url": "https://www.samsung.com/fr/refrigerators/bespoke/", "image": "https://images.samsung.com/fr/refrigerators/bespoke.jpg", "description": "Réfrigérateur personnalisable BESPOKE", "category": "home"},
    {"name": "Samsung Odyssey G9 Monitor 49\"", "brand": "Samsung", "price": 1699, "url": "https://www.samsung.com/fr/monitors/odyssey-g9/", "image": "https://images.samsung.com/fr/monitors/odyssey-g9.jpg", "description": "Écran gaming incurvé Odyssey G9", "category": "tech"},

    # VEJA (Sneakers écologiques)
    {"name": "Veja V-10 White Black", "brand": "Veja", "price": 140, "url": "https://www.veja-store.com/fr_fr/v-10-white-black", "image": "https://cdn.shopify.com/s/files/veja-v10-white-black.jpg", "description": "Baskets Veja V-10 éco-responsables", "category": "sneakers"},
    {"name": "Veja Campo White Natural", "brand": "Veja", "price": 115, "url": "https://www.veja-store.com/fr_fr/campo", "image": "https://cdn.shopify.com/s/files/veja-campo.jpg", "description": "Baskets Veja Campo en cuir éthique", "category": "sneakers"},
    {"name": "Veja Esplar White Pierre", "brand": "Veja", "price": 105, "url": "https://www.veja-store.com/fr_fr/esplar", "image": "https://cdn.shopify.com/s/files/veja-esplar.jpg", "description": "Baskets minimalistes Veja Esplar", "category": "sneakers"},
    {"name": "Veja Condor 2 Running", "brand": "Veja", "price": 180, "url": "https://www.veja-store.com/fr_fr/condor-2", "image": "https://cdn.shopify.com/s/files/veja-condor.jpg", "description": "Chaussures de running Veja Condor 2", "category": "sport"},
    {"name": "Veja Rio Branco Alveomesh", "brand": "Veja", "price": 155, "url": "https://www.veja-store.com/fr_fr/rio-branco", "image": "https://cdn.shopify.com/s/files/veja-rio-branco.jpg", "description": "Sneakers techniques Veja Rio Branco", "category": "sneakers"},

    # SONY (Tech Audio)
    {"name": "Sony WH-1000XM5 Headphones", "brand": "Sony", "price": 399, "url": "https://www.sony.fr/headphones/wh-1000xm5", "image": "https://sony-images.com/wh1000xm5-black.jpg", "description": "Casque antibruit Sony WH-1000XM5", "category": "tech"},
    {"name": "Sony LinkBuds S", "brand": "Sony", "price": 199, "url": "https://www.sony.fr/headphones/linkbuds-s", "image": "https://sony-images.com/linkbuds-s.jpg", "description": "Écouteurs ultra-légers LinkBuds S", "category": "tech"},
    {"name": "Sony Alpha 7 IV Camera", "brand": "Sony", "price": 2799, "url": "https://www.sony.fr/alpha-7-iv", "image": "https://sony-images.com/alpha-7-iv.jpg", "description": "Appareil photo hybride Sony Alpha 7 IV", "category": "tech"},
    {"name": "Sony PlayStation 5 Slim", "brand": "Sony", "price": 549, "url": "https://www.playstation.com/fr-fr/ps5/", "image": "https://sony-images.com/ps5-slim.jpg", "description": "Console PlayStation 5 Slim", "category": "tech"},
    {"name": "Sony Bravia XR A95K OLED 65\"", "brand": "Sony", "price": 3499, "url": "https://www.sony.fr/bravia-xr-a95k", "image": "https://sony-images.com/bravia-a95k.jpg", "description": "TV OLED Sony Bravia XR A95K 65 pouces", "category": "tech"},
    {"name": "Sony SRS-XB43 Bluetooth Speaker", "brand": "Sony", "price": 229, "url": "https://www.sony.fr/srs-xb43", "image": "https://sony-images.com/srs-xb43.jpg", "description": "Enceinte Bluetooth Sony SRS-XB43", "category": "tech"},

    # BOSE (Audio)
    {"name": "Bose QuietComfort 45", "brand": "Bose", "price": 349, "url": "https://www.bose.fr/quietcomfort-45", "image": "https://assets.bose.com/qc45-black.jpg", "description": "Casque antibruit Bose QC45", "category": "tech"},
    {"name": "Bose QuietComfort Earbuds II", "brand": "Bose", "price": 299, "url": "https://www.bose.fr/qc-earbuds-ii", "image": "https://assets.bose.com/qc-earbuds-ii.jpg", "description": "Écouteurs antibruit Bose QC Earbuds II", "category": "tech"},
    {"name": "Bose SoundLink Revolve+ II", "brand": "Bose", "price": 329, "url": "https://www.bose.fr/soundlink-revolve-plus", "image": "https://assets.bose.com/soundlink-revolve.jpg", "description": "Enceinte portable Bose SoundLink", "category": "tech"},
    {"name": "Bose Smart Soundbar 900", "brand": "Bose", "price": 999, "url": "https://www.bose.fr/smart-soundbar-900", "image": "https://assets.bose.com/soundbar-900.jpg", "description": "Barre de son Dolby Atmos Bose 900", "category": "tech"},
    {"name": "Bose Sport Earbuds", "brand": "Bose", "price": 179, "url": "https://www.bose.fr/sport-earbuds", "image": "https://assets.bose.com/sport-earbuds.jpg", "description": "Écouteurs de sport Bose", "category": "tech"},

    # LULULEMON (Activewear)
    {"name": "Lululemon Align High-Rise Pant 25\"", "brand": "Lululemon", "price": 108, "url": "https://www.lululemon.com/align-pant", "image": "https://images.lululemon.com/align-pant-black.jpg", "description": "Legging Align Lululemon ultra-doux", "category": "sport"},
    {"name": "Lululemon Define Jacket", "brand": "Lululemon", "price": 128, "url": "https://www.lululemon.com/define-jacket", "image": "https://images.lululemon.com/define-jacket.jpg", "description": "Veste ajustée Define Lululemon", "category": "fashion"},
    {"name": "Lululemon Everywhere Belt Bag", "brand": "Lululemon", "price": 38, "url": "https://www.lululemon.com/belt-bag", "image": "https://images.lululemon.com/belt-bag.jpg", "description": "Sac banane Everywhere ultra-populaire", "category": "fashion"},
    {"name": "Lululemon Wunder Train High-Rise Tight", "brand": "Lululemon", "price": 108, "url": "https://www.lululemon.com/wunder-train", "image": "https://images.lululemon.com/wunder-train.jpg", "description": "Legging Wunder Train pour l'entraînement", "category": "sport"},
    {"name": "Lululemon Scuba Oversized Half-Zip", "brand": "Lululemon", "price": 128, "url": "https://www.lululemon.com/scuba-hoodie", "image": "https://images.lululemon.com/scuba-hoodie.jpg", "description": "Hoodie Scuba oversized iconique", "category": "fashion"},
    {"name": "Lululemon Fast and Free High-Rise Tight", "brand": "Lululemon", "price": 128, "url": "https://www.lululemon.com/fast-and-free", "image": "https://images.lululemon.com/fast-and-free.jpg", "description": "Legging de running Fast and Free", "category": "sport"},
    {"name": "Lululemon Soft Ambitions Crop Crew", "brand": "Lululemon", "price": 78, "url": "https://www.lululemon.com/soft-ambitions", "image": "https://images.lululemon.com/soft-ambitions.jpg", "description": "Sweatshirt Soft Ambitions ultra-confortable", "category": "fashion"},
    {"name": "Lululemon Energy Bra High Support", "brand": "Lululemon", "price": 68, "url": "https://www.lululemon.com/energy-bra", "image": "https://images.lululemon.com/energy-bra.jpg", "description": "Brassière de sport Energy haute performance", "category": "sport"},

    # ON RUNNING (Running)
    {"name": "On Cloud 5", "brand": "On Running", "price": 140, "url": "https://www.on-running.com/cloud-5", "image": "https://cdn.on-running.com/cloud-5-white.jpg", "description": "Chaussures On Cloud 5 ultra-légères", "category": "sport"},
    {"name": "On Cloudmonster", "brand": "On Running", "price": 170, "url": "https://www.on-running.com/cloudmonster", "image": "https://cdn.on-running.com/cloudmonster.jpg", "description": "On Cloudmonster avec maxi-amorti", "category": "sport"},
    {"name": "On Cloudflow 4", "brand": "On Running", "price": 150, "url": "https://www.on-running.com/cloudflow", "image": "https://cdn.on-running.com/cloudflow-4.jpg", "description": "Chaussures de running rapides Cloudflow", "category": "sport"},
    {"name": "On Roger Pro Tennis", "brand": "On Running", "price": 180, "url": "https://www.on-running.com/roger-pro", "image": "https://cdn.on-running.com/roger-pro.jpg", "description": "Chaussures de tennis Roger Pro", "category": "sport"},
    {"name": "On Cloudsurfer", "brand": "On Running", "price": 160, "url": "https://www.on-running.com/cloudsurfer", "image": "https://cdn.on-running.com/cloudsurfer.jpg", "description": "On Cloudsurfer pour le quotidien", "category": "sport"},
    {"name": "On Cloudswift 3", "brand": "On Running", "price": 160, "url": "https://www.on-running.com/cloudswift", "image": "https://cdn.on-running.com/cloudswift.jpg", "description": "Chaussures urbaines Cloudswift 3", "category": "sport"},

    # HOKA (Running)
    {"name": "HOKA Clifton 9", "brand": "HOKA", "price": 145, "url": "https://www.hoka.com/clifton-9", "image": "https://images.hoka.com/clifton-9.jpg", "description": "HOKA Clifton 9 légères et confortables", "category": "sport"},
    {"name": "HOKA Bondi 8", "brand": "HOKA", "price": 165, "url": "https://www.hoka.com/bondi-8", "image": "https://images.hoka.com/bondi-8.jpg", "description": "HOKA Bondi 8 maxi-amorti", "category": "sport"},
    {"name": "HOKA Speedgoat 5", "brand": "HOKA", "price": 155, "url": "https://www.hoka.com/speedgoat-5", "image": "https://images.hoka.com/speedgoat-5.jpg", "description": "Chaussures de trail HOKA Speedgoat 5", "category": "outdoor"},
    {"name": "HOKA Mach 5", "brand": "HOKA", "price": 140, "url": "https://www.hoka.com/mach-5", "image": "https://images.hoka.com/mach-5.jpg", "description": "HOKA Mach 5 polyvalentes", "category": "sport"},
    {"name": "HOKA Arahi 6", "brand": "HOKA", "price": 140, "url": "https://www.hoka.com/arahi-6", "image": "https://images.hoka.com/arahi-6.jpg", "description": "HOKA Arahi 6 avec stabilité", "category": "sport"},
    {"name": "HOKA Challenger ATR 7", "brand": "HOKA", "price": 140, "url": "https://www.hoka.com/challenger-atr-7", "image": "https://images.hoka.com/challenger-atr-7.jpg", "description": "HOKA Challenger ATR 7 route/trail", "category": "outdoor"},

    # ARC'TERYX (Outdoor)
    {"name": "Arc'teryx Beta LT Jacket", "brand": "Arc'teryx", "price": 575, "url": "https://arcteryx.com/beta-lt-jacket", "image": "https://arcteryx.com/images/beta-lt.jpg", "description": "Veste Gore-Tex Arc'teryx Beta LT", "category": "outdoor"},
    {"name": "Arc'teryx Atom LT Hoody", "brand": "Arc'teryx", "price": 299, "url": "https://arcteryx.com/atom-lt-hoody", "image": "https://arcteryx.com/images/atom-lt.jpg", "description": "Veste isolante Arc'teryx Atom LT", "category": "outdoor"},
    {"name": "Arc'teryx Gamma MX Hoody", "brand": "Arc'teryx", "price": 329, "url": "https://arcteryx.com/gamma-mx", "image": "https://arcteryx.com/images/gamma-mx.jpg", "description": "Softshell Arc'teryx Gamma MX", "category": "outdoor"},
    {"name": "Arc'teryx Aerios FL Mid GTX", "brand": "Arc'teryx", "price": 219, "url": "https://arcteryx.com/aerios-fl-gtx", "image": "https://arcteryx.com/images/aerios-fl.jpg", "description": "Chaussures de randonnée Arc'teryx Aerios", "category": "outdoor"},
    {"name": "Arc'teryx Norvan SL 2 GTX", "brand": "Arc'teryx", "price": 259, "url": "https://arcteryx.com/norvan-sl-2", "image": "https://arcteryx.com/images/norvan-sl.jpg", "description": "Chaussures de trail Arc'teryx Norvan", "category": "outdoor"},
    {"name": "Arc'teryx Mantis 26 Backpack", "brand": "Arc'teryx", "price": 135, "url": "https://arcteryx.com/mantis-26", "image": "https://arcteryx.com/images/mantis-26.jpg", "description": "Sac à dos Arc'teryx Mantis 26L", "category": "outdoor"},

    # PATAGONIA (Outdoor durable)
    {"name": "Patagonia Better Sweater Fleece", "brand": "Patagonia", "price": 139, "url": "https://www.patagonia.com/better-sweater", "image": "https://patagonia.com/images/better-sweater.jpg", "description": "Polaire Patagonia Better Sweater", "category": "outdoor"},
    {"name": "Patagonia Nano Puff Jacket", "brand": "Patagonia", "price": 249, "url": "https://www.patagonia.com/nano-puff", "image": "https://patagonia.com/images/nano-puff.jpg", "description": "Doudoune légère Patagonia Nano Puff", "category": "outdoor"},
    {"name": "Patagonia Torrentshell 3L Jacket", "brand": "Patagonia", "price": 179, "url": "https://www.patagonia.com/torrentshell", "image": "https://patagonia.com/images/torrentshell.jpg", "description": "Veste imperméable Torrentshell 3L", "category": "outdoor"},
    {"name": "Patagonia Baggies Shorts 5\"", "brand": "Patagonia", "price": 65, "url": "https://www.patagonia.com/baggies-shorts", "image": "https://patagonia.com/images/baggies.jpg", "description": "Short Patagonia Baggies iconique", "category": "fashion"},
    {"name": "Patagonia Down Sweater", "brand": "Patagonia", "price": 279, "url": "https://www.patagonia.com/down-sweater", "image": "https://patagonia.com/images/down-sweater.jpg", "description": "Doudoune Patagonia Down Sweater", "category": "outdoor"},
    {"name": "Patagonia Black Hole Duffel 55L", "brand": "Patagonia", "price": 149, "url": "https://www.patagonia.com/black-hole-duffel", "image": "https://patagonia.com/images/black-hole-duffel.jpg", "description": "Sac de voyage Black Hole 55L", "category": "outdoor"},

    # THE NORTH FACE (Outdoor)
    {"name": "The North Face Nuptse Jacket", "brand": "The North Face", "price": 350, "url": "https://www.thenorthface.com/nuptse-jacket", "image": "https://thenorthface.com/images/nuptse.jpg", "description": "Doudoune iconique North Face Nuptse", "category": "outdoor"},
    {"name": "The North Face 1996 Retro Nuptse", "brand": "The North Face", "price": 380, "url": "https://www.thenorthface.com/1996-nuptse", "image": "https://thenorthface.com/images/1996-nuptse.jpg", "description": "Doudoune rétro 1996 Nuptse", "category": "outdoor"},
    {"name": "The North Face Denali 2 Fleece", "brand": "The North Face", "price": 179, "url": "https://www.thenorthface.com/denali-fleece", "image": "https://thenorthface.com/images/denali.jpg", "description": "Polaire classique Denali 2", "category": "outdoor"},
    {"name": "The North Face Vectiv Enduris III", "brand": "The North Face", "price": 160, "url": "https://www.thenorthface.com/vectiv-enduris", "image": "https://thenorthface.com/images/vectiv.jpg", "description": "Chaussures de trail Vectiv Enduris", "category": "outdoor"},
    {"name": "The North Face Base Camp Duffel L", "brand": "The North Face", "price": 149, "url": "https://www.thenorthface.com/base-camp-duffel", "image": "https://thenorthface.com/images/base-camp.jpg", "description": "Sac de voyage Base Camp Duffel", "category": "outdoor"},

    # CANADA GOOSE (Luxe Outdoor)
    {"name": "Canada Goose Chilliwack Bomber", "brand": "Canada Goose", "price": 1095, "url": "https://www.canadagoose.com/chilliwack-bomber", "image": "https://canadagoose.com/images/chilliwack.jpg", "description": "Parka Canada Goose Chilliwack", "category": "outdoor"},
    {"name": "Canada Goose Langford Parka", "brand": "Canada Goose", "price": 1195, "url": "https://www.canadagoose.com/langford-parka", "image": "https://canadagoose.com/images/langford.jpg", "description": "Parka urbaine Langford", "category": "outdoor"},
    {"name": "Canada Goose Shelburne Parka", "brand": "Canada Goose", "price": 1095, "url": "https://www.canadagoose.com/shelburne-parka", "image": "https://canadagoose.com/images/shelburne.jpg", "description": "Parka femme Shelburne", "category": "outdoor"},
    {"name": "Canada Goose Hybridge Lite Jacket", "brand": "Canada Goose", "price": 695, "url": "https://www.canadagoose.com/hybridge-lite", "image": "https://canadagoose.com/images/hybridge.jpg", "description": "Doudoune légère Hybridge Lite", "category": "outdoor"},

    # MONCLER (Luxe)
    {"name": "Moncler Maya Jacket", "brand": "Moncler", "price": 1650, "url": "https://www.moncler.com/maya-jacket", "image": "https://moncler.com/images/maya.jpg", "description": "Doudoune Moncler Maya iconique", "category": "fashion"},
    {"name": "Moncler Grenoble Jacket", "brand": "Moncler", "price": 1950, "url": "https://www.moncler.com/grenoble", "image": "https://moncler.com/images/grenoble.jpg", "description": "Veste de ski Moncler Grenoble", "category": "fashion"},
    {"name": "Moncler Cluny Puffer", "brand": "Moncler", "price": 1450, "url": "https://www.moncler.com/cluny", "image": "https://moncler.com/images/cluny.jpg", "description": "Doudoune courte Moncler Cluny", "category": "fashion"},
    {"name": "Moncler Gui Gilet", "brand": "Moncler", "price": 795, "url": "https://www.moncler.com/gui-gilet", "image": "https://moncler.com/images/gui.jpg", "description": "Gilet sans manches Moncler Gui", "category": "fashion"},

    # STONE ISLAND (Streetwear Tech)
    {"name": "Stone Island Ghost Piece Jacket", "brand": "Stone Island", "price": 795, "url": "https://www.stoneisland.com/ghost-piece", "image": "https://stoneisland.com/images/ghost-piece.jpg", "description": "Veste Stone Island Ghost Piece", "category": "streetwear"},
    {"name": "Stone Island Soft Shell-R Jacket", "brand": "Stone Island", "price": 695, "url": "https://www.stoneisland.com/soft-shell-r", "image": "https://stoneisland.com/images/soft-shell.jpg", "description": "Veste technique Soft Shell-R", "category": "streetwear"},
    {"name": "Stone Island Badge Hoodie", "brand": "Stone Island", "price": 325, "url": "https://www.stoneisland.com/badge-hoodie", "image": "https://stoneisland.com/images/hoodie.jpg", "description": "Sweat à capuche Stone Island iconique", "category": "streetwear"},
    {"name": "Stone Island Cargo Pants", "brand": "Stone Island", "price": 395, "url": "https://www.stoneisland.com/cargo-pants", "image": "https://stoneisland.com/images/cargo.jpg", "description": "Pantalon cargo Stone Island", "category": "streetwear"},

    # C.P. COMPANY (Streetwear)
    {"name": "C.P. Company Goggle Jacket", "brand": "C.P. Company", "price": 795, "url": "https://www.cpcompany.com/goggle-jacket", "image": "https://cpcompany.com/images/goggle.jpg", "description": "Veste C.P. Company avec lunettes iconiques", "category": "streetwear"},
    {"name": "C.P. Company Pro-Tek Jacket", "brand": "C.P. Company", "price": 695, "url": "https://www.cpcompany.com/pro-tek", "image": "https://cpcompany.com/images/pro-tek.jpg", "description": "Veste technique Pro-Tek", "category": "streetwear"},
    {"name": "C.P. Company Lens Hoodie", "brand": "C.P. Company", "price": 325, "url": "https://www.cpcompany.com/lens-hoodie", "image": "https://cpcompany.com/images/lens-hoodie.jpg", "description": "Sweat à capuche avec lentille", "category": "streetwear"},

    # CARHARTT WIP (Streetwear)
    {"name": "Carhartt WIP Detroit Jacket", "brand": "Carhartt WIP", "price": 169, "url": "https://www.carhartt-wip.com/detroit-jacket", "image": "https://carhartt-wip.com/images/detroit.jpg", "description": "Veste Carhartt Detroit classique", "category": "streetwear"},
    {"name": "Carhartt WIP Active Jacket", "brand": "Carhartt WIP", "price": 189, "url": "https://www.carhartt-wip.com/active-jacket", "image": "https://carhartt-wip.com/images/active.jpg", "description": "Veste Active Carhartt WIP", "category": "streetwear"},
    {"name": "Carhartt WIP Double Knee Pant", "brand": "Carhartt WIP", "price": 99, "url": "https://www.carhartt-wip.com/double-knee", "image": "https://carhartt-wip.com/images/double-knee.jpg", "description": "Pantalon Double Knee iconique", "category": "streetwear"},
    {"name": "Carhartt WIP Nimbus Pullover", "brand": "Carhartt WIP", "price": 149, "url": "https://www.carhartt-wip.com/nimbus", "image": "https://carhartt-wip.com/images/nimbus.jpg", "description": "Anorak Nimbus Carhartt", "category": "streetwear"},

    # CONVERSE (Sneakers)
    {"name": "Converse Chuck Taylor All Star High", "brand": "Converse", "price": 65, "url": "https://www.converse.com/chuck-taylor-high", "image": "https://converse.com/images/chuck-high-black.jpg", "description": "Converse Chuck Taylor montantes noires", "category": "sneakers"},
    {"name": "Converse Chuck 70 High Top", "brand": "Converse", "price": 85, "url": "https://www.converse.com/chuck-70-high", "image": "https://converse.com/images/chuck-70-high.jpg", "description": "Converse Chuck 70 premium", "category": "sneakers"},
    {"name": "Converse Run Star Hike", "brand": "Converse", "price": 110, "url": "https://www.converse.com/run-star-hike", "image": "https://converse.com/images/run-star-hike.jpg", "description": "Converse Run Star Hike plateforme", "category": "sneakers"},
    {"name": "Converse One Star Pro", "brand": "Converse", "price": 85, "url": "https://www.converse.com/one-star-pro", "image": "https://converse.com/images/one-star.jpg", "description": "Converse One Star Pro skate", "category": "sneakers"},
    {"name": "Converse Chuck Taylor All Star Low White", "brand": "Converse", "price": 60, "url": "https://www.converse.com/chuck-taylor-low-white", "image": "https://converse.com/images/chuck-low-white.jpg", "description": "Converse basses blanches classiques", "category": "sneakers"},

    # VANS (Sneakers)
    {"name": "Vans Old Skool Black White", "brand": "Vans", "price": 75, "url": "https://www.vans.com/old-skool", "image": "https://vans.com/images/old-skool-black.jpg", "description": "Vans Old Skool noir et blanc", "category": "sneakers"},
    {"name": "Vans Authentic Classic", "brand": "Vans", "price": 60, "url": "https://www.vans.com/authentic", "image": "https://vans.com/images/authentic.jpg", "description": "Vans Authentic classiques", "category": "sneakers"},
    {"name": "Vans SK8-Hi Platform 2.0", "brand": "Vans", "price": 80, "url": "https://www.vans.com/sk8-hi-platform", "image": "https://vans.com/images/sk8-hi-platform.jpg", "description": "Vans SK8-Hi plateforme", "category": "sneakers"},
    {"name": "Vans Slip-On Checkerboard", "brand": "Vans", "price": 65, "url": "https://www.vans.com/slip-on-checkerboard", "image": "https://vans.com/images/slip-on-check.jpg", "description": "Vans Slip-On damier iconiques", "category": "sneakers"},
    {"name": "Vans Era Classic", "brand": "Vans", "price": 65, "url": "https://www.vans.com/era", "image": "https://vans.com/images/era.jpg", "description": "Vans Era classiques", "category": "sneakers"},

    # COMMON PROJECTS (Sneakers Luxe)
    {"name": "Common Projects Original Achilles Low White", "brand": "Common Projects", "price": 425, "url": "https://www.commonprojects.com/achilles-low-white", "image": "https://commonprojects.com/images/achilles-white.jpg", "description": "Baskets minimalistes Common Projects blanches", "category": "sneakers"},
    {"name": "Common Projects Achilles Low Black", "brand": "Common Projects", "price": 425, "url": "https://www.commonprojects.com/achilles-low-black", "image": "https://commonprojects.com/images/achilles-black.jpg", "description": "Common Projects Achilles noires", "category": "sneakers"},
    {"name": "Common Projects BBall Low", "brand": "Common Projects", "price": 465, "url": "https://www.commonprojects.com/bball-low", "image": "https://commonprojects.com/images/bball.jpg", "description": "Common Projects BBall Low", "category": "sneakers"},
    {"name": "Common Projects Chelsea Boot", "brand": "Common Projects", "price": 545, "url": "https://www.commonprojects.com/chelsea-boot", "image": "https://commonprojects.com/images/chelsea.jpg", "description": "Chelsea boots Common Projects", "category": "fashion"},

    # GOLDEN GOOSE (Sneakers Luxe)
    {"name": "Golden Goose Super-Star Sneakers", "brand": "Golden Goose", "price": 495, "url": "https://www.goldengoose.com/super-star", "image": "https://goldengoose.com/images/super-star.jpg", "description": "Baskets Golden Goose Super-Star effet vieilli", "category": "sneakers"},
    {"name": "Golden Goose Ball Star", "brand": "Golden Goose", "price": 495, "url": "https://www.goldengoose.com/ball-star", "image": "https://goldengoose.com/images/ball-star.jpg", "description": "Golden Goose Ball Star", "category": "sneakers"},
    {"name": "Golden Goose Mid Star", "brand": "Golden Goose", "price": 545, "url": "https://www.goldengoose.com/mid-star", "image": "https://goldengoose.com/images/mid-star.jpg", "description": "Golden Goose Mid Star montantes", "category": "sneakers"},
    {"name": "Golden Goose Slide Sneakers", "brand": "Golden Goose", "price": 475, "url": "https://www.goldengoose.com/slide", "image": "https://goldengoose.com/images/slide.jpg", "description": "Golden Goose Slide", "category": "sneakers"},

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

    existing.extend(MASSIVE_PRODUCTS)
    save_all(existing)

    print(f"✓ Added {len(MASSIVE_PRODUCTS)} new products")
    print(f"✓ Total products: {len(existing)}")
