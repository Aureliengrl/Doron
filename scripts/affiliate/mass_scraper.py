#!/usr/bin/env python3
"""
Mass Product Scraper for ~300 Brands
Scrapes real products with official images from brands and retailers
"""

import json
import time
import requests
from datetime import datetime
from typing import List, Dict, Optional
from pathlib import Path
import re

# Base paths
BASE_DIR = Path("/home/user/Doron/scripts/affiliate")
PRODUCTS_FILE = BASE_DIR / "scraped_products.json"
FAILED_FILE = BASE_DIR / "failed_brands.txt"
PROGRESS_FILE = BASE_DIR / "scraping_progress.json"

# Comprehensive brand database with official sites and fallback retailers
BRANDS_DATABASE = {
    # FASHION FAST-FASHION
    "Fashion Fast-Fashion": {
        "Zara": {"site": "https://www.zara.com", "fallbacks": ["zalando.fr", "asos.com"]},
        "Zara Men": {"site": "https://www.zara.com/fr/en/man-mkt1029.html", "fallbacks": ["zalando.fr"]},
        "Zara Women": {"site": "https://www.zara.com/fr/en/woman-mkt1001.html", "fallbacks": ["zalando.fr"]},
        "H&M": {"site": "https://www2.hm.com", "fallbacks": ["zalando.fr", "asos.com"]},
        "Mango": {"site": "https://shop.mango.com", "fallbacks": ["zalando.fr", "asos.com"]},
        "Stradivarius": {"site": "https://www.stradivarius.com", "fallbacks": ["zalando.fr"]},
        "Bershka": {"site": "https://www.bershka.com", "fallbacks": ["zalando.fr"]},
        "Pull & Bear": {"site": "https://www.pullandbear.com", "fallbacks": ["zalando.fr"]},
        "Massimo Dutti": {"site": "https://www.massimodutti.com", "fallbacks": ["zalando.fr"]},
        "Uniqlo": {"site": "https://www.uniqlo.com", "fallbacks": ["zalando.fr"]},
        "COS": {"site": "https://www.cosstores.com", "fallbacks": ["zalando.fr"]},
        "Arket": {"site": "https://www.arket.com", "fallbacks": ["zalando.fr"]},
        "Weekday": {"site": "https://www.weekday.com", "fallbacks": ["zalando.fr", "asos.com"]},
        "& Other Stories": {"site": "https://www.stories.com", "fallbacks": ["zalando.fr"]},
    },

    # FASHION PREMIUM
    "Fashion Premium": {
        "Sézane": {"site": "https://www.sezane.com", "fallbacks": ["24s.com"]},
        "Sandro": {"site": "https://www.sandro-paris.com", "fallbacks": ["zalando.fr", "farfetch.com"]},
        "Maje": {"site": "https://www.maje.com", "fallbacks": ["zalando.fr", "farfetch.com"]},
        "Claudie Pierlot": {"site": "https://www.claudiepierlot.com", "fallbacks": ["zalando.fr", "farfetch.com"]},
        "ba&sh": {"site": "https://www.ba-sh.com", "fallbacks": ["farfetch.com"]},
        "The Kooples": {"site": "https://www.thekooples.com", "fallbacks": ["farfetch.com", "zalando.fr"]},
        "A.P.C.": {"site": "https://www.apc-us.com", "fallbacks": ["farfetch.com", "mrporter.com"]},
        "AMI Paris": {"site": "https://www.amiparis.com", "fallbacks": ["farfetch.com", "mrporter.com"]},
        "Isabel Marant": {"site": "https://www.isabelmarant.com", "fallbacks": ["farfetch.com", "net-a-porter.com"]},
        "Jacquemus": {"site": "https://www.jacquemus.com", "fallbacks": ["farfetch.com", "ssense.com"]},
        "Reformation": {"site": "https://www.thereformation.com", "fallbacks": ["farfetch.com"]},
        "Ganni": {"site": "https://www.ganni.com", "fallbacks": ["farfetch.com", "net-a-porter.com"]},
        "Totême": {"site": "https://toteme-studio.com", "fallbacks": ["farfetch.com", "net-a-porter.com"]},
        "Anine Bing": {"site": "https://www.aninebing.com", "fallbacks": ["farfetch.com"]},
        "The Frankie Shop": {"site": "https://thefrankieshop.com", "fallbacks": ["farfetch.com"]},
        "Acne Studios": {"site": "https://www.acnestudios.com", "fallbacks": ["farfetch.com", "ssense.com"]},
        "Lemaire": {"site": "https://www.lemaire.fr", "fallbacks": ["farfetch.com", "ssense.com"]},
        "Officine Générale": {"site": "https://www.officinegenerale.com", "fallbacks": ["mrporter.com"]},
    },

    # FASHION LUXE
    "Fashion Luxe": {
        "Maison Margiela": {"site": "https://www.maisonmargiela.com", "fallbacks": ["farfetch.com", "ssense.com"]},
        "Saint Laurent": {"site": "https://www.ysl.com", "fallbacks": ["farfetch.com", "net-a-porter.com"]},
        "Louis Vuitton": {"site": "https://www.louisvuitton.com", "fallbacks": ["farfetch.com"]},
        "Dior": {"site": "https://www.dior.com", "fallbacks": ["farfetch.com"]},
        "Chanel": {"site": "https://www.chanel.com", "fallbacks": ["farfetch.com"]},
        "Gucci": {"site": "https://www.gucci.com", "fallbacks": ["farfetch.com", "net-a-porter.com"]},
        "Prada": {"site": "https://www.prada.com", "fallbacks": ["farfetch.com", "net-a-porter.com"]},
        "Miu Miu": {"site": "https://www.miumiu.com", "fallbacks": ["farfetch.com", "net-a-porter.com"]},
        "Fendi": {"site": "https://www.fendi.com", "fallbacks": ["farfetch.com", "net-a-porter.com"]},
        "Celine": {"site": "https://www.celine.com", "fallbacks": ["farfetch.com"]},
        "Balenciaga": {"site": "https://www.balenciaga.com", "fallbacks": ["farfetch.com", "ssense.com"]},
        "Loewe": {"site": "https://www.loewe.com", "fallbacks": ["farfetch.com", "net-a-porter.com"]},
        "Valentino": {"site": "https://www.valentino.com", "fallbacks": ["farfetch.com", "net-a-porter.com"]},
        "Givenchy": {"site": "https://www.givenchy.com", "fallbacks": ["farfetch.com"]},
        "Burberry": {"site": "https://www.burberry.com", "fallbacks": ["farfetch.com", "net-a-porter.com"]},
        "Alexander McQueen": {"site": "https://www.alexandermcqueen.com", "fallbacks": ["farfetch.com"]},
        "Versace": {"site": "https://www.versace.com", "fallbacks": ["farfetch.com"]},
        "Balmain": {"site": "https://www.balmain.com", "fallbacks": ["farfetch.com"]},
        "Bottega Veneta": {"site": "https://www.bottegaveneta.com", "fallbacks": ["farfetch.com", "net-a-porter.com"]},
        "Hermès": {"site": "https://www.hermes.com", "fallbacks": ["farfetch.com"]},
        "Alaïa": {"site": "https://www.alaia.fr", "fallbacks": ["farfetch.com", "net-a-porter.com"]},
        "JW Anderson": {"site": "https://www.j-w-anderson.com", "fallbacks": ["farfetch.com", "ssense.com"]},
        "Rick Owens": {"site": "https://www.rickowens.eu", "fallbacks": ["farfetch.com", "ssense.com"]},
        "Tom Ford": {"site": "https://www.tomford.com", "fallbacks": ["farfetch.com"]},
    },

    # STREETWEAR
    "Streetwear": {
        "Golden Goose": {"site": "https://www.goldengoose.com", "fallbacks": ["farfetch.com"]},
        "Off-White": {"site": "https://www.off---white.com", "fallbacks": ["farfetch.com", "ssense.com"]},
        "Palm Angels": {"site": "https://www.palmangels.com", "fallbacks": ["farfetch.com", "ssense.com"]},
        "Fear of God": {"site": "https://fearofgod.com", "fallbacks": ["ssense.com"]},
        "Rhude": {"site": "https://rhude.com", "fallbacks": ["farfetch.com", "ssense.com"]},
        "Aime Leon Dore": {"site": "https://www.aimeleondore.com", "fallbacks": []},
        "Stone Island": {"site": "https://www.stoneisland.com", "fallbacks": ["farfetch.com", "end.com"]},
        "C.P. Company": {"site": "https://www.cpcompany.com", "fallbacks": ["farfetch.com", "end.com"]},
        "Carhartt WIP": {"site": "https://www.carhartt-wip.com", "fallbacks": ["end.com"]},
        "Stüssy": {"site": "https://www.stussy.com", "fallbacks": ["end.com", "ssense.com"]},
        "Kith": {"site": "https://kith.com", "fallbacks": ["stockx.com"]},
        "Supreme": {"site": "https://www.supremenewyork.com", "fallbacks": ["stockx.com", "goat.com"]},
    },

    # SPORT/OUTDOOR
    "Sport/Outdoor": {
        "Moncler": {"site": "https://www.moncler.com", "fallbacks": ["farfetch.com"]},
        "Canada Goose": {"site": "https://www.canadagoose.com", "fallbacks": ["farfetch.com"]},
        "Arc'teryx": {"site": "https://arcteryx.com", "fallbacks": ["backcountry.com"]},
        "The North Face": {"site": "https://www.thenorthface.com", "fallbacks": ["zalando.fr"]},
        "Patagonia": {"site": "https://www.patagonia.com", "fallbacks": ["backcountry.com"]},
        "Fusalp": {"site": "https://www.fusalp.com", "fallbacks": ["farfetch.com"]},
        "Rossignol": {"site": "https://www.rossignol.com", "fallbacks": []},
        "On Running": {"site": "https://www.on-running.com", "fallbacks": ["zalando.fr"]},
        "HOKA": {"site": "https://www.hoka.com", "fallbacks": ["zalando.fr"]},
        "Lululemon": {"site": "https://www.lululemon.com", "fallbacks": []},
        "Alo Yoga": {"site": "https://www.aloyoga.com", "fallbacks": []},
        "Gymshark": {"site": "https://www.gymshark.com", "fallbacks": []},
        "Nike": {"site": "https://www.nike.com", "fallbacks": ["zalando.fr", "asos.com"]},
        "Adidas": {"site": "https://www.adidas.com", "fallbacks": ["zalando.fr", "asos.com"]},
        "Jordan": {"site": "https://www.nike.com/jordan", "fallbacks": ["stockx.com"]},
        "New Balance": {"site": "https://www.newbalance.com", "fallbacks": ["zalando.fr"]},
        "Puma": {"site": "https://www.puma.com", "fallbacks": ["zalando.fr"]},
        "Asics": {"site": "https://www.asics.com", "fallbacks": ["zalando.fr"]},
        "Salomon": {"site": "https://www.salomon.com", "fallbacks": ["zalando.fr"]},
        "Veja": {"site": "https://www.veja-store.com", "fallbacks": ["zalando.fr"]},
        "Autry": {"site": "https://www.autry-usa.com", "fallbacks": ["farfetch.com"]},
    },

    # SNEAKERS
    "Sneakers": {
        "Common Projects": {"site": "https://www.commonprojects.com", "fallbacks": ["farfetch.com", "mrporter.com"]},
        "Axel Arigato": {"site": "https://axelarigato.com", "fallbacks": ["farfetch.com"]},
        "Converse": {"site": "https://www.converse.com", "fallbacks": ["zalando.fr"]},
        "Vans": {"site": "https://www.vans.com", "fallbacks": ["zalando.fr", "asos.com"]},
    },

    # TECH
    "Tech": {
        "Apple": {"site": "https://www.apple.com", "fallbacks": ["amazon.fr", "fnac.com"]},
        "Samsung": {"site": "https://www.samsung.com", "fallbacks": ["amazon.fr", "fnac.com"]},
        "Google Pixel": {"site": "https://store.google.com", "fallbacks": ["amazon.fr"]},
        "Dyson": {"site": "https://www.dyson.fr", "fallbacks": ["amazon.fr", "darty.com"]},
        "Bose": {"site": "https://www.bose.fr", "fallbacks": ["amazon.fr", "fnac.com"]},
        "Sony": {"site": "https://www.sony.fr", "fallbacks": ["amazon.fr", "fnac.com"]},
        "JBL": {"site": "https://www.jbl.com", "fallbacks": ["amazon.fr"]},
        "Marshall": {"site": "https://www.marshallheadphones.com", "fallbacks": ["amazon.fr"]},
        "Bang & Olufsen": {"site": "https://www.bang-olufsen.com", "fallbacks": ["amazon.fr"]},
        "Bowers & Wilkins": {"site": "https://www.bowerswilkins.com", "fallbacks": ["amazon.fr"]},
        "Sennheiser": {"site": "https://www.sennheiser.com", "fallbacks": ["amazon.fr"]},
        "Devialet": {"site": "https://www.devialet.com", "fallbacks": ["amazon.fr"]},
        "Nothing": {"site": "https://www.nothing.tech", "fallbacks": ["amazon.fr"]},
        "GoPro": {"site": "https://gopro.com", "fallbacks": ["amazon.fr"]},
        "DJI": {"site": "https://www.dji.com", "fallbacks": ["amazon.fr"]},
        "Withings": {"site": "https://www.withings.com", "fallbacks": ["amazon.fr"]},
        "Garmin": {"site": "https://www.garmin.com", "fallbacks": ["amazon.fr"]},
        "Kindle": {"site": "https://www.amazon.fr/kindle", "fallbacks": ["amazon.fr"]},
        "PlayStation": {"site": "https://www.playstation.com", "fallbacks": ["amazon.fr", "fnac.com"]},
        "Xbox": {"site": "https://www.xbox.com", "fallbacks": ["amazon.fr", "fnac.com"]},
        "Nintendo": {"site": "https://www.nintendo.com", "fallbacks": ["amazon.fr", "fnac.com"]},
        "Logitech G": {"site": "https://www.logitechg.com", "fallbacks": ["amazon.fr"]},
        "Razer": {"site": "https://www.razer.com", "fallbacks": ["amazon.fr"]},
        "SteelSeries": {"site": "https://steelseries.com", "fallbacks": ["amazon.fr"]},
        "Secretlab": {"site": "https://secretlab.eu", "fallbacks": []},
        "Scuf": {"site": "https://scufgaming.com", "fallbacks": ["amazon.fr"]},
    },

    # BEAUTÉ
    "Beauty": {
        "Dior Beauty": {"site": "https://www.dior.com/beauty", "fallbacks": ["sephora.fr", "nocibe.fr"]},
        "Chanel Beauty": {"site": "https://www.chanel.com/beauty", "fallbacks": ["sephora.fr"]},
        "YSL Beauty": {"site": "https://www.yslbeauty.com", "fallbacks": ["sephora.fr", "nocibe.fr"]},
        "Lancôme": {"site": "https://www.lancome.fr", "fallbacks": ["sephora.fr", "nocibe.fr"]},
        "Estée Lauder": {"site": "https://www.esteelauder.fr", "fallbacks": ["sephora.fr"]},
        "La Mer": {"site": "https://www.lamer.fr", "fallbacks": ["sephora.fr"]},
        "La Prairie": {"site": "https://www.laprairie.com", "fallbacks": ["sephora.fr"]},
        "Guerlain": {"site": "https://www.guerlain.com", "fallbacks": ["sephora.fr"]},
        "Shiseido": {"site": "https://www.shiseido.fr", "fallbacks": ["sephora.fr"]},
        "Charlotte Tilbury": {"site": "https://www.charlottetilbury.com", "fallbacks": ["sephora.fr"]},
        "Armani Beauty": {"site": "https://www.armanibeauty.com", "fallbacks": ["sephora.fr"]},
        "Hourglass": {"site": "https://www.hourglasscosmetics.com", "fallbacks": ["sephora.fr"]},
        "NARS": {"site": "https://www.narscosmetics.fr", "fallbacks": ["sephora.fr"]},
        "Pat McGrath Labs": {"site": "https://www.patmcgrath.com", "fallbacks": ["sephora.fr"]},
        "Fenty Beauty": {"site": "https://fentybeauty.com", "fallbacks": ["sephora.fr"]},
        "Rare Beauty": {"site": "https://rarebeauty.com", "fallbacks": ["sephora.fr"]},
        "Tatcha": {"site": "https://www.tatcha.com", "fallbacks": ["sephora.fr"]},
        "Dr. Barbara Sturm": {"site": "https://www.drsturm.com", "fallbacks": ["sephora.fr"]},
        "Augustinus Bader": {"site": "https://augustinusbader.com", "fallbacks": ["sephora.fr"]},
        "SkinCeuticals": {"site": "https://www.skinceuticals.fr", "fallbacks": ["lookfantastic.fr"]},
        "Drunk Elephant": {"site": "https://www.drunkelephant.com", "fallbacks": ["sephora.fr"]},
        "Summer Fridays": {"site": "https://summerfridays.com", "fallbacks": ["sephora.fr"]},
        "Kiehl's": {"site": "https://www.kiehls.fr", "fallbacks": ["sephora.fr"]},
        "The Ordinary": {"site": "https://www.theordinary.com", "fallbacks": ["sephora.fr"]},
        "Paula's Choice": {"site": "https://www.paulaschoice.fr", "fallbacks": ["lookfantastic.fr"]},
        "Glossier": {"site": "https://www.glossier.com", "fallbacks": []},
        "Rituals": {"site": "https://www.rituals.com", "fallbacks": []},
        "L'Occitane": {"site": "https://www.loccitane.com", "fallbacks": []},
        "The Body Shop": {"site": "https://www.thebodyshop.com", "fallbacks": []},
        "Lush": {"site": "https://www.lush.com", "fallbacks": []},
        "Yves Rocher": {"site": "https://www.yves-rocher.fr", "fallbacks": []},
        "KIKO Milano": {"site": "https://www.kikocosmetics.com", "fallbacks": []},
    },

    # PARFUMS
    "Parfums": {
        "Le Labo": {"site": "https://www.lelabofragrances.com", "fallbacks": ["sephora.fr"]},
        "Byredo": {"site": "https://www.byredo.com", "fallbacks": ["sephora.fr"]},
        "Diptyque": {"site": "https://www.diptyqueparis.com", "fallbacks": ["sephora.fr"]},
        "Maison Francis Kurkdjian": {"site": "https://www.franciskurkdjian.com", "fallbacks": ["sephora.fr"]},
        "Kilian Paris": {"site": "https://www.bykilian.com", "fallbacks": ["sephora.fr"]},
        "Creed": {"site": "https://www.creedfragrances.com", "fallbacks": ["nocibe.fr"]},
        "Parfums de Marly": {"site": "https://www.parfums-de-marly.com", "fallbacks": ["sephora.fr"]},
        "BDK Parfums": {"site": "https://bdkparfums.com", "fallbacks": ["sephora.fr"]},
        "DS & Durga": {"site": "https://www.dsanddurga.com", "fallbacks": ["sephora.fr"]},
        "Jo Malone London": {"site": "https://www.jomalone.fr", "fallbacks": ["sephora.fr"]},
        "Aesop": {"site": "https://www.aesop.com", "fallbacks": []},
        "Cire Trudon": {"site": "https://www.ciretrudon.com", "fallbacks": []},
        "Acqua di Parma": {"site": "https://www.acquadiparma.com", "fallbacks": ["sephora.fr"]},
    },

    # HOME/DÉCO
    "Home/Déco": {
        "IKEA": {"site": "https://www.ikea.com", "fallbacks": []},
        "Maisons du Monde": {"site": "https://www.maisonsdumonde.com", "fallbacks": []},
        "H&M Home": {"site": "https://www2.hm.com/fr_fr/home.html", "fallbacks": []},
        "Zara Home": {"site": "https://www.zarahome.com", "fallbacks": []},
        "Habitat": {"site": "https://www.habitat.fr", "fallbacks": []},
        "Alinéa": {"site": "https://www.alinea.com", "fallbacks": []},
        "Made.com": {"site": "https://www.made.com", "fallbacks": []},
        "Vitra": {"site": "https://www.vitra.com", "fallbacks": []},
        "Hay": {"site": "https://www.hay.com", "fallbacks": []},
        "Muuto": {"site": "https://www.muuto.com", "fallbacks": []},
        "Ferm Living": {"site": "https://fermliving.com", "fallbacks": []},
        "Kartell": {"site": "https://www.kartell.com", "fallbacks": []},
        "Tom Dixon": {"site": "https://www.tomdixon.net", "fallbacks": []},
        "Alessi": {"site": "https://www.alessi.com", "fallbacks": ["amazon.fr"]},
        "Flos": {"site": "https://www.flos.com", "fallbacks": []},
        "Artemide": {"site": "https://www.artemide.com", "fallbacks": []},
    },

    # ÉLECTROMÉNAGER
    "Électroménager": {
        "Dyson": {"site": "https://www.dyson.fr", "fallbacks": ["amazon.fr"]},
        "SMEG": {"site": "https://www.smeg.com", "fallbacks": ["amazon.fr"]},
        "KitchenAid": {"site": "https://www.kitchenaid.fr", "fallbacks": ["amazon.fr"]},
        "Nespresso": {"site": "https://www.nespresso.com", "fallbacks": ["amazon.fr"]},
        "De'Longhi": {"site": "https://www.delonghi.com", "fallbacks": ["amazon.fr"]},
        "Moccamaster": {"site": "https://www.moccamaster.com", "fallbacks": ["amazon.fr"]},
        "Le Creuset": {"site": "https://www.lecreuset.fr", "fallbacks": ["amazon.fr"]},
        "Staub": {"site": "https://www.staub.fr", "fallbacks": ["amazon.fr"]},
        "Riedel": {"site": "https://www.riedel.com", "fallbacks": ["amazon.fr"]},
    },

    # LUNETTES
    "Lunettes": {
        "Le Petit Lunetier": {"site": "https://www.lepetitlunetier.com", "fallbacks": []},
        "Ray-Ban": {"site": "https://www.ray-ban.com", "fallbacks": ["amazon.fr"]},
        "Persol": {"site": "https://www.persol.com", "fallbacks": ["amazon.fr"]},
        "Oliver Peoples": {"site": "https://www.oliverpeoples.com", "fallbacks": ["farfetch.com"]},
        "Warby Parker": {"site": "https://www.warbyparker.com", "fallbacks": []},
        "Cutler and Gross": {"site": "https://www.cutlerandgross.com", "fallbacks": ["farfetch.com"]},
        "Linda Farrow": {"site": "https://www.lindafarrow.com", "fallbacks": ["farfetch.com"]},
    },

    # MAROQUINERIE/BAGAGES
    "Maroquinerie/Bagages": {
        "Polène": {"site": "https://eng.polene-paris.com", "fallbacks": []},
        "Lancel": {"site": "https://www.lancel.com", "fallbacks": []},
        "Longchamp": {"site": "https://www.longchamp.com", "fallbacks": ["farfetch.com"]},
        "Cuyana": {"site": "https://www.cuyana.com", "fallbacks": []},
        "Coach": {"site": "https://www.coach.com", "fallbacks": ["farfetch.com"]},
        "MCM": {"site": "https://www.mcmworldwide.com", "fallbacks": ["farfetch.com"]},
        "Rimowa": {"site": "https://www.rimowa.com", "fallbacks": ["farfetch.com"]},
        "Tumi": {"site": "https://www.tumi.com", "fallbacks": ["amazon.fr"]},
        "Away": {"site": "https://www.awaytravel.com", "fallbacks": []},
        "Samsonite": {"site": "https://www.samsonite.com", "fallbacks": ["amazon.fr"]},
        "Delsey": {"site": "https://www.delsey.com", "fallbacks": ["amazon.fr"]},
        "Briggs & Riley": {"site": "https://www.briggs-riley.com", "fallbacks": []},
        "Montblanc": {"site": "https://www.montblanc.com", "fallbacks": ["farfetch.com"]},
        "Bellroy": {"site": "https://bellroy.com", "fallbacks": ["amazon.fr"]},
        "Nomad Goods": {"site": "https://nomadgoods.com", "fallbacks": ["amazon.fr"]},
        "Peak Design": {"site": "https://www.peakdesign.com", "fallbacks": ["amazon.fr"]},
        "Native Union": {"site": "https://www.nativeunion.com", "fallbacks": ["amazon.fr"]},
        "Mujjo": {"site": "https://www.mujjo.com", "fallbacks": ["amazon.fr"]},
    },

    # CHAUSSURES
    "Chaussures": {
        "Eram": {"site": "https://www.eram.fr", "fallbacks": []},
        "Jonak": {"site": "https://www.jonak.fr", "fallbacks": []},
        "Minelli": {"site": "https://www.minelli.fr", "fallbacks": []},
        "Bocage": {"site": "https://www.bocage.fr", "fallbacks": []},
        "Dr. Martens": {"site": "https://www.drmartens.com", "fallbacks": ["zalando.fr"]},
        "Paraboot": {"site": "https://www.paraboot.com", "fallbacks": []},
        "J.M. Weston": {"site": "https://www.jmweston.com", "fallbacks": []},
        "Tod's": {"site": "https://www.tods.com", "fallbacks": ["farfetch.com"]},
        "Church's": {"site": "https://www.church-footwear.com", "fallbacks": ["farfetch.com"]},
        "Santoni": {"site": "https://www.santonishoes.com", "fallbacks": ["farfetch.com"]},
        "Hogan": {"site": "https://www.hogan.com", "fallbacks": ["farfetch.com"]},
        "Gianvito Rossi": {"site": "https://www.gianvitorossi.com", "fallbacks": ["farfetch.com", "net-a-porter.com"]},
        "Amina Muaddi": {"site": "https://www.aminamuaddi.com", "fallbacks": ["farfetch.com", "net-a-porter.com"]},
        "Aquazzura": {"site": "https://www.aquazzura.com", "fallbacks": ["farfetch.com", "net-a-porter.com"]},
        "Roger Vivier": {"site": "https://www.rogervivier.com", "fallbacks": ["farfetch.com"]},
        "By Far": {"site": "https://www.by-far.com", "fallbacks": ["farfetch.com"]},
    },

    # BIJOUX
    "Bijoux": {
        "Pandora": {"site": "https://www.pandora.net", "fallbacks": []},
        "Swarovski": {"site": "https://www.swarovski.com", "fallbacks": []},
        "Tiffany & Co.": {"site": "https://www.tiffany.com", "fallbacks": []},
        "Cartier": {"site": "https://www.cartier.com", "fallbacks": []},
        "Van Cleef & Arpels": {"site": "https://www.vancleefarpels.com", "fallbacks": []},
        "Bulgari": {"site": "https://www.bulgari.com", "fallbacks": []},
        "Messika": {"site": "https://www.messika.com", "fallbacks": []},
        "Chaumet": {"site": "https://www.chaumet.com", "fallbacks": []},
        "Fred": {"site": "https://www.fred.com", "fallbacks": []},
        "Dinh Van": {"site": "https://www.dinhvan.com", "fallbacks": []},
        "Repossi": {"site": "https://www.repossi.com", "fallbacks": ["farfetch.com"]},
        "Aristocrazy": {"site": "https://www.aristocrazy.com", "fallbacks": []},
        "Maison Cléo": {"site": "https://maisoncleo.com", "fallbacks": []},
    },

    # GASTRONOMIE
    "Gastronomie": {
        "La Maison du Chocolat": {"site": "https://www.lamaisonduchocolat.fr", "fallbacks": []},
        "Pierre Hermé": {"site": "https://www.pierreherme.com", "fallbacks": []},
        "Ladurée": {"site": "https://www.laduree.fr", "fallbacks": []},
        "Fauchon": {"site": "https://www.fauchon.com", "fallbacks": []},
        "Angelina": {"site": "https://www.angelina-paris.fr", "fallbacks": []},
        "Pierre Marcolini": {"site": "https://eu.marcolini.com", "fallbacks": []},
        "Godiva": {"site": "https://www.godiva.com", "fallbacks": []},
        "Venchi": {"site": "https://www.venchi.com", "fallbacks": []},
        "Patrick Roger": {"site": "https://www.patrickroger.com", "fallbacks": []},
        "Maison Plisson": {"site": "https://www.maisonplisson.com", "fallbacks": []},
        "Kusmi Tea": {"site": "https://www.kusmitea.com", "fallbacks": []},
        "Mariage Frères": {"site": "https://www.mariagefreres.com", "fallbacks": []},
        "Dammann Frères": {"site": "https://www.dammann.fr", "fallbacks": []},
    },
}


class ProductScraper:
    """Handles product scraping with fallback strategies"""

    def __init__(self):
        self.products = []
        self.failed_brands = []
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
        })

    def load_existing_products(self):
        """Load existing scraped products"""
        if PRODUCTS_FILE.exists():
            with open(PRODUCTS_FILE, 'r', encoding='utf-8') as f:
                self.products = json.load(f)
        return len(self.products)

    def save_products(self):
        """Save products to JSON file"""
        with open(PRODUCTS_FILE, 'w', encoding='utf-8') as f:
            json.dump(self.products, f, indent=2, ensure_ascii=False)

    def log_failed_brand(self, brand: str, reason: str):
        """Log failed brand"""
        timestamp = datetime.now().isoformat()
        with open(FAILED_FILE, 'a', encoding='utf-8') as f:
            f.write(f"{brand} | {reason} | {timestamp}\n")
        self.failed_brands.append(brand)

    def update_progress(self, completed: List[str], pending: List[str]):
        """Update scraping progress"""
        progress = {
            "total_brands": len(completed) + len(pending),
            "completed_brands": completed,
            "failed_brands": self.failed_brands,
            "pending_brands": pending,
            "total_products": len(self.products),
            "last_updated": datetime.now().isoformat()
        }
        with open(PROGRESS_FILE, 'w', encoding='utf-8') as f:
            json.dump(progress, f, indent=2, ensure_ascii=False)

    def add_product(self, product: Dict):
        """Add a product to the list"""
        self.products.append(product)
        self.save_products()

    def scrape_brand_manual(self, brand: str, category: str, urls: Dict) -> int:
        """
        Manual scraping strategy (placeholder - will be filled with WebSearch/WebFetch results)
        Returns number of products scraped
        """
        print(f"Scraping {brand} in category {category}...")
        # This will be filled by manual WebSearch/WebFetch operations
        return 0


def get_all_brands() -> List[tuple]:
    """Get all brands as (category, brand, urls) tuples"""
    all_brands = []
    for category, brands in BRANDS_DATABASE.items():
        for brand, urls in brands.items():
            all_brands.append((category, brand, urls))
    return all_brands


if __name__ == "__main__":
    scraper = ProductScraper()
    existing = scraper.load_existing_products()

    print(f"=== MASS PRODUCT SCRAPER ===")
    print(f"Existing products: {existing}")
    print(f"Total brands to scrape: {sum(len(brands) for brands in BRANDS_DATABASE.values())}")
    print(f"\nThis script will be used in combination with WebSearch/WebFetch for scraping.")
    print(f"Products will be saved to: {PRODUCTS_FILE}")
    print(f"Failed brands will be logged to: {FAILED_FILE}")
