#!/usr/bin/env node

/**
 * Générateur intelligent de produits à partir des URLs
 * Parse les URLs pour extraire le maximum d'informations
 * et crée des produits complets dans Firebase
 */

const admin = require('firebase-admin');
const fs = require('fs');

// Liste de tous les liens de produits
const PRODUCT_URLS = [
  // Golden Goose
  'https://www.goldengoose.com/fr/fr/true-star-pour-femme-en-cuir-velours-noir-avec-cristaux-swarovski-et--toile-en-cuir-noir-cod-GWF00922.F007982.90100.html',
  'https://www.goldengoose.com/fr/fr/mini-star-bag-femme-en-cuir-lam--argent--avec--toile-ton-sur-ton-cod-GWA00228.A000335.70140.html',
  'https://www.goldengoose.com/fr/fr/top-pour-femme-en-tulle-noir-avec-motif-floral-en-sequins-noirs-cod-GWP02661.P002320.90100.html',
  'https://www.goldengoose.com/fr/fr/super-star-ltd-pour-femme-en-cuir-velours-rouge-avec--toile-paillettes-argent-es-et-contrefort-en-cuir-lam--cod-GWF00101.F007867.40399.html',
  'https://www.goldengoose.com/fr/fr/chemise-oversize-pour-femme-en-coton-blanc-avec-d-tail-pliss--et-boutons-bijoux-cod-GWP02599.P002323.10359.html',
  'https://www.goldengoose.com/fr/fr/t-shirt-unisexe-en-jersey-de-coton-noir-avec-logo-brod--cod-GUP01873.P002362.90498.html',
  'https://www.goldengoose.com/fr/fr/veste-oversize-pour-femme-en-serg--de-coton-noir-avec-broderie-florale-en-sequins-cod-GWP02571.P002311.90100.html',
  'https://www.goldengoose.com/fr/fr/bomber-pour-femme-en-cuir-nappa-bordeaux-fonc--avec-broderie-florale-cod-GWP02560.P002300.40249.html',
  'https://www.goldengoose.com/fr/fr/v-star-ltd-homme-en-toile-noire-avec--toile-et-contrefort-gris-froid-cod-GMF00129.F003088.90184.html',
  'https://www.goldengoose.com/fr/fr/star-bag-en-cuir-brillant-noir-avec--toile-ton-sur-ton-cod-GWA00375.A000438.90100.html',
  'https://www.goldengoose.com/fr/fr/true-star-pour-femme-en-daim-couleur-tabac-avec--toile-blanche-et-contrefort-platine-cod-GWF00922.F007393.55667.html',
  'https://www.goldengoose.com/fr/fr/sweat-shirt-unisexe-star-avec-capuche-en-coton-gris-chin--cod-GUP02710.P002411.60665.html',
  'https://www.goldengoose.com/fr/fr/veste-bomber-pour-homme-en-cuir-nappa-bordeaux-cod-GMP02531.P002301.40249.html',
  'https://www.goldengoose.com/fr/fr/t-shirt-pour-homme-avec-imprim--sur-la-poitrine-et-dans-le-dos-l%E2%80%99effet-us--cod-GMP01220.P002140.82432.html',
  'https://www.goldengoose.com/fr/fr/t-shirt-homme-gris-anthracite-l%E2%80%99effet-us--cod-GMP01220.P000671.60318.html',
  'https://www.goldengoose.com/fr/fr/pantalon-chino-homme-en-coton-noir-cod-GMP01190.P000786.90100.html',
  'https://www.goldengoose.com/fr/fr/ball-star-wishes-pour-homme-en-cuir-nappa-blanc-avec--toile-et-contrefort-bleuet-cod-GMF00117.F005822.10793.html',
  'https://www.goldengoose.com/fr/fr/ball-star-pour-homme-en-daim-vert-avec--toile-et-contrefort-en-cuir-blanc-cod-GMF00117.F007204.35924.html',
  'https://www.goldengoose.com/fr/fr/ball-star-en-cuir-nappa-avec--toile-et-contrefort-en-daim-gris-cod-GMF00117.F005179.11663.html',
  'https://www.goldengoose.com/fr/fr/super-star-homme-avec-contrefort-noir-et-lettrage-avec-clous-en-m-tal-cod-GMF00102.F000318.10220.html',
  'https://www.goldengoose.com/fr/fr/super-star-en-cuir-nappa-avec--toile-et-contrefort-en-daim-gris-cod-GMF00101.F006019.11887.html',
  'https://www.goldengoose.com/fr/fr/super-star-ltd-en-daim-vert-militaire-avec--toile-s-rigraphi-e-cod-GMF00399.F003422.35800.html',
  'https://www.goldengoose.com/fr/fr/running-sole-en-nylon-bleu-avec--toile-imprim-e-blanche-cod-GMF00215.F004035.50749.html',
  'https://www.goldengoose.com/fr/fr/marathon-pour-homme-avec-tige-en-nylon-ripstop-argent--et--toile-noire-cod-GMF00684.F005667.60246.html',
  'https://www.goldengoose.com/fr/fr/super-star-ltd-pour-femme-paillettes-cerise-avec--toile-en-cuir-velours-cerise-cod-GWF00101.F007930.40519.html',
  'https://www.goldengoose.com/fr/fr/jean-pour-femme-en-denim-bordeaux-avec-cristaux-d-grad-s-cod-GWP00844.P002407.40249.html',
  'https://www.goldengoose.com/fr/fr/24-7-bag-north-south-en-cuir-us--de-couleur-noire-avec-anses-r-glables-cod-GWA00632.A000671.90100.html',
  'https://www.goldengoose.com/fr/fr/ceinture-en-cuir-marron-avec-cabochons-floraux-dor-s-et-empi-cements-en-ambre-cod-GWA00779.A000774.55312.html',
  'https://www.goldengoose.com/fr/fr/lunettes-de-soleil-mod-le-aviateur-avec-monture-or-rose-et-verres-couleur-miel-cod-GUA00670.A000653.65207.html',
  'https://www.goldengoose.com/fr/fr/casquette-de-baseball-en-coton-gris-l%E2%80%99effet-us--cod-GUP01038.P002198.60100.html',

  // Zara
  'https://www.zara.com/fr/fr/sweat-a-capuche-effet-neoprene-p01437360.html',
  'https://www.zara.com/fr/fr/veste-rembourree-100-plumes-deperlante-p03411510.html',
  'https://www.zara.com/fr/fr/sweat-a-capuche-basique-p00761370.html',
  'https://www.zara.com/fr/fr/jean-flare-fit-p00840353.html',
  'https://www.zara.com/fr/fr/veste-en-cuir-a-poches-p05388205.html',
  'https://www.zara.com/fr/fr/pantalon-de-jogging-coupe-ample-p00761440.html',
  'https://www.zara.com/fr/fr/blouson-technique-combine-polaire-p03918420.html',
  'https://www.zara.com/fr/fr/mocassins-en-cuir-casual-p12613520.html',
  'https://www.zara.com/fr/fr/jean-coupe-droite-p08062330.html',
  'https://www.zara.com/fr/fr/blouson-coupe-boxy-effet-neoprene-p06318335.html',
  'https://www.zara.com/fr/fr/sweat-effet-neoprene-plis-capuche-p06318309.html',
  'https://www.zara.com/fr/fr/pantalon-de-charpentier-a-imprime-abstrait-p05862301.html',
  'https://www.zara.com/fr/fr/veste-technique-a-capuche-p04695500.html',
  'https://www.zara.com/fr/fr/blouson-en-cuir-avec-ceinture-edition-limitee-p05479703.html',
  'https://www.zara.com/fr/fr/mocassins-en-cuir-a-masque-p12608620.html',
  'https://www.zara.com/fr/fr/manteau-100%C2%A0-laine-a-chevrons-p02949400.html',
  'https://www.zara.com/fr/fr/chaussures-habillees-p12400520.html',
  'https://www.zara.com/fr/fr/pull-a-col-zippe-p05755350.html',
  'https://www.zara.com/fr/fr/pull-en-maille-interlock-a-pinces-p03641872.html',
  'https://www.zara.com/fr/fr/veste-boucle-contraste-p02298457.html',
  'https://www.zara.com/fr/fr/t-shirt-gossip-girl--manches-courtes-p06050047.html',
  'https://www.zara.com/fr/fr/gilet-doux-boutons-p05039222.html',
  'https://www.zara.com/fr/fr/veste-bomber-effet-daim-p04344655.html',
  'https://www.zara.com/fr/fr/pantalon-molleton-evase-p04174817.html',
  'https://www.zara.com/fr/fr/jeu-de-backgammon-en-bois-p48320052.html',
  'https://www.zara.com/fr/fr/calendrier-de-table-manuel-p48365043.html',
  'https://www.zara.com/fr/fr/horloge-a-clapets-p46677060.html',
  'https://www.zara.com/fr/fr/vase-terre-cuite-p41306046.html',
  'https://www.zara.com/fr/fr/cadre-photo-contour-fin-argente-p46319045.html',
  'https://www.zara.com/fr/fr/boite-a-bijoux-bois-miroir-p47169452.html',
  'https://www.zara.com/fr/fr/cadre-photo-metal-ondes-p44320045.html',
  'https://www.zara.com/fr/fr/balai-en-fer-pour-cheminee-p43304043.html',
  'https://www.zara.com/fr/fr/vase-ceramique-texturee-p48372046.html',
  'https://www.zara.com/fr/fr/vase-ceramique-effet-rugueux-p47321043.html',
  'https://www.zara.com/fr/fr/table-base-conique-p47384072.html',
  'https://www.zara.com/fr/fr/table-basse-sapin-de-noel-p47386072.html',

  // Maje
  'https://fr.maje.com/fr/p/minijupe-en-fausse-fourrure-leopard/MFPJU01519_K039.html',
  'https://fr.maje.com/fr/p/bottes-santiags-en-cuir/MFACH00801_G005.html',
  'https://fr.maje.com/fr/p/manteau-court-double-face/MFPBL00794_0609.html',
  'https://fr.maje.com/fr/p/jean-large-avec-poches-plaquees/MFPJE00762_0103.html',

  // Miu Miu
  'https://www.miumiu.com/fr/fr/p/pochette-en-velours/5NE851_068_F0011',
  'https://www.miumiu.com/fr/fr/p/mini-sac-wander-en-velours-matelasse/5BP078_2EOM_F0011_V_OON',
  'https://www.miumiu.com/fr/fr/p/veste-en-cuir-suede-cire/MPV990_18BT_F0002_S_OOO',
  'https://www.miumiu.com/fr/fr/p/pochette-en-cuir-nappa-matelasse/5BF130_AN88_F0002_V_OLO',
  'https://www.miumiu.com/fr/fr/p/cardigan-a-capuche-en-cachemire/MMF00T_18YX_F0MZQ_S_OOO',
  'https://www.miumiu.com/fr/fr/p/mini-jupe-en-cuir-suede-cire/MPD836_1421_F0005_S_OOO',

  // Rhode
  'https://www.rhodeskin.com/pages/the-birthday-set',
  'https://www.rhodeskin.com/products/the-scented-peptide-lip-tint-set',
  'https://www.rhodeskin.com/products/the-oversized-rhode-kit',
  'https://www.rhodeskin.com/products/lip-case',
  'https://www.rhodeskin.com/products/glazing-milk',
  'https://www.rhodeskin.com/products/the-travel-set',
  'https://www.rhodeskin.com/products/pocket-blush-tan-line',

  // Sephora
  'https://www.sephora.fr/p/coffret-miss-dior---eau-de-parfum-et-lait-pour-le-corps--edition-limitee-P1000210763.html',
  'https://www.sephora.fr/p/hydration-set-holiday--25--P10062651.html',
  'https://www.sephora.fr/p/airwrap-i.d.-P1000211006.html',
  'https://www.sephora.fr/p/meilleur-combo-levres---light-nude---duo-crayon-et-encre-a-levres-740805.html',
  'https://www.sephora.fr/p/libre---coffret-eau-de-parfum-femme-P1000210608.html',
  'https://www.sephora.fr/p/ethereal-eyes%E2%84%A2-eyeshadow-palette--nature%E2%80%8B---palette-de-fards-a-paupieres-P1000210835.html',
  'https://www.sephora.fr/p/1-million-%E2%80%93-coffret-eau-de-toilette-P1000209734.html',
  'https://www.sephora.fr/p/lip-butter-balm---vanilla-beige-P10021822.html',
  'https://www.sephora.fr/p/gel-creme-hydratant-P10043556.html',
  'https://www.sephora.fr/p/8hr-colorful-lip-liner---crayon-a-levres-sans-transfert-P10061924.html',
  'https://www.sephora.fr/p/soft-pinch-luminous-powder-blush---blush-poudre-P10057746.html',
  'https://www.sephora.fr/p/maxi-kit-de-masques---20-masques-soin-de-la-tete-aux-pieds-P10062531.html',
  'https://www.sephora.fr/p/glaze-craze-tinted-lip-serum---serum-teinte-pour-les-levres-P10061780.html',
  'https://www.sephora.fr/p/star-power-brightening-trio---trio-hydratant-777783.html',
  'https://www.sephora.fr/p/coconut-mania---coffret-de-masques-visage-et-corps-P10061942.html',
  'https://www.sephora.fr/p/airbrush-flawless-setting-spray-matte---spray-fixateur-mat-P1000209496.html',
  'https://www.sephora.fr/p/pillow-talk-duo-set---set-pour-les-levres-P10025810.html',
  'https://www.sephora.fr/p/airbrush-flawless-finish---poudre-matifiante-P1000209087.html',
  'https://www.sephora.fr/p/rock--n--kohl---crayon-yeux-P1000207894.html',
  'https://www.sephora.fr/p/unreal-skin-sheer-glow-tint---stick-fond-de-teint-hydratant-P10059185.html',
  'https://www.sephora.fr/p/exagger-eyes-smokey-eye-kit---coffret-maquillage-779529.html',
  'https://www.sephora.fr/p/powder-et-sculpt-brush---pinceau-visage-453917.html',

  // Lululemon
  'https://www.lululemon.fr/fr-fr/p/nulu-paisley-lace-back-yoga-bra-light-support%2C-b%2Fc-cup/prod20009011.html',
  'https://www.lululemon.fr/fr-fr/p/veste-define-nulu/prod11020158.html',
  'https://www.lululemon.fr/fr-fr/p/bouteille-transparente-back-to-life-950%C2%A0ml/prod11710520.html',
  'https://www.lululemon.fr/fr-fr/p/le-tapis-5%C2%A0mm-en-caoutchouc-certifie-fsc%E2%84%A2/prod10990033.html',
  'https://www.lululemon.fr/fr-fr/p/short-pace-breaker-non-double-18%C2%A0cm/prod11400112.html',
  'https://www.lululemon.fr/fr-fr/p/haut-manches-longues-metal-vent-tech-nouvelle-version/prod11710149.html',
  'https://www.lululemon.fr/fr-fr/p/gants-de-course-fast-and-free-en-molleton-pour-hommes/prod11530385.html',
  'https://www.lululemon.fr/fr-fr/p/back-to-life-sport-bottle-24oz-straw-lid-jewelled/prod20005367.html',
  'https://www.lululemon.fr/fr-fr/p/bouteille-d%E2%80%99eau-back-to-life-1%2C8%C2%A0l/prod11380291.html',
];

/**
 * Prix moyens par marque et type de produit
 */
const PRICE_RANGES = {
  'Golden Goose': {
    'sneaker': [400, 600],
    'bag': [500, 800],
    'clothing': [200, 400],
    'accessory': [150, 300]
  },
  'Zara': {
    'sneaker': [40, 80],
    'bag': [30, 60],
    'clothing': [30, 100],
    'accessory': [15, 40],
    'home': [20, 150]
  },
  'Maje': {
    'sneaker': [150, 250],
    'bag': [200, 350],
    'clothing': [100, 300],
    'accessory': [80, 150]
  },
  'Miu Miu': {
    'sneaker': [700, 1200],
    'bag': [1200, 2500],
    'clothing': [800, 2000],
    'accessory': [400, 800]
  },
  'Rhode': {
    'skincare': [25, 50],
    'makeup': [20, 45],
    'set': [40, 80]
  },
  'Sephora': {
    'skincare': [20, 100],
    'makeup': [15, 80],
    'set': [30, 200],
    'fragrance': [50, 150]
  },
  'Lululemon': {
    'clothing': [60, 150],
    'accessory': [20, 50],
    'yoga': [50, 100]
  }
};

/**
 * Images par marque (placeholder réalistes)
 */
const BRAND_IMAGES = {
  'Golden Goose': 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=800&h=800&fit=crop',
  'Zara': 'https://images.unsplash.com/photo-1445205170230-053b83016050?w=800&h=800&fit=crop',
  'Maje': 'https://images.unsplash.com/photo-1515372039744-b8f02a3ae446?w=800&h=800&fit=crop',
  'Miu Miu': 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=800&h=800&fit=crop',
  'Rhode': 'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=800&h=800&fit=crop',
  'Sephora': 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=800&h=800&fit=crop',
  'Lululemon': 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800&h=800&fit=crop'
};

/**
 * Extrait la marque depuis l'URL
 */
function getBrandFromUrl(url) {
  if (url.includes('goldengoose.com')) return 'Golden Goose';
  if (url.includes('zara.com')) return 'Zara';
  if (url.includes('maje.com')) return 'Maje';
  if (url.includes('miumiu.com')) return 'Miu Miu';
  if (url.includes('rhodeskin.com')) return 'Rhode';
  if (url.includes('sephora.fr')) return 'Sephora';
  if (url.includes('lululemon.fr')) return 'Lululemon';
  return 'Unknown';
}

/**
 * Parse le nom du produit depuis l'URL
 */
function parseProductName(url, brand) {
  let productName = '';

  if (brand === 'Golden Goose') {
    // Exemple: true-star-pour-femme-en-cuir-velours-noir-avec-cristaux-swarovski-et--toile-en-cuir-noir
    const match = url.match(/\/([a-z0-9-]+)-cod-/i);
    if (match) {
      productName = match[1]
        .replace(/-/g, ' ')
        .replace(/  +/g, ' ')
        .replace(/\b\w/g, l => l.toUpperCase());
    }
  } else if (brand === 'Zara') {
    // Exemple: sweat-a-capuche-effet-neoprene
    const match = url.match(/\/([a-z0-9-]+)-p\d+/i);
    if (match) {
      productName = match[1]
        .replace(/-/g, ' ')
        .replace(/\b\w/g, l => l.toUpperCase());
    }
  } else if (brand === 'Maje') {
    // Exemple: minijupe-en-fausse-fourrure-leopard
    const match = url.match(/\/p\/([a-z0-9-]+)\//i);
    if (match) {
      productName = match[1]
        .replace(/-/g, ' ')
        .replace(/\b\w/g, l => l.toUpperCase());
    }
  } else if (brand === 'Miu Miu') {
    // Exemple: pochette-en-velours
    const match = url.match(/\/p\/([a-z0-9-]+)\//i);
    if (match) {
      productName = match[1]
        .replace(/-/g, ' ')
        .replace(/\b\w/g, l => l.toUpperCase());
    }
  } else if (brand === 'Rhode') {
    // Exemple: the-birthday-set
    const match = url.match(/\/([a-z0-9-]+)$/i);
    if (match) {
      productName = match[1]
        .replace(/-/g, ' ')
        .replace(/\b\w/g, l => l.toUpperCase());
    }
  } else if (brand === 'Sephora') {
    // Exemple: coffret-miss-dior---eau-de-parfum-et-lait-pour-le-corps--edition-limitee
    const match = url.match(/\/p\/([^-]+(?:-[^-]+)*?)---?/i) || url.match(/\/p\/([a-z0-9-]+)-P\d+/i);
    if (match) {
      productName = match[1]
        .replace(/-/g, ' ')
        .replace(/\b\w/g, l => l.toUpperCase());
    }
  } else if (brand === 'Lululemon') {
    // Exemple: nulu-paisley-lace-back-yoga-bra-light-support
    const match = url.match(/\/p\/([^/]+)\//i);
    if (match) {
      productName = match[1]
        .replace(/%2C/g, ',')
        .replace(/%C2%A0/g, ' ')
        .replace(/-/g, ' ')
        .replace(/\b\w/g, l => l.toUpperCase());
    }
  }

  return productName || 'Produit ' + brand;
}

/**
 * Détermine le type de produit
 */
function getProductType(productName, brand) {
  const nameLower = productName.toLowerCase();

  if (nameLower.includes('star') || nameLower.includes('sneaker') || nameLower.includes('basket') || nameLower.includes('ball') || nameLower.includes('running') || nameLower.includes('marathon') || nameLower.includes('bottes') || nameLower.includes('mocassin') || nameLower.includes('chaussures')) {
    return 'sneaker';
  }
  if (nameLower.includes('bag') || nameLower.includes('sac') || nameLower.includes('pochette')) {
    return 'bag';
  }
  if (nameLower.includes('parfum') || nameLower.includes('fragrance') || nameLower.includes('eau de')) {
    return 'fragrance';
  }
  if (nameLower.includes('set') || nameLower.includes('kit') || nameLower.includes('coffret')) {
    return 'set';
  }
  if (nameLower.includes('skincare') || nameLower.includes('hydrat') || nameLower.includes('creme') || nameLower.includes('serum') || nameLower.includes('milk')) {
    return 'skincare';
  }
  if (nameLower.includes('makeup') || nameLower.includes('maquillage') || nameLower.includes('lip') || nameLower.includes('blush') || nameLower.includes('palette') || nameLower.includes('crayon')) {
    return 'makeup';
  }
  if (nameLower.includes('vase') || nameLower.includes('cadre') || nameLower.includes('table') || nameLower.includes('horloge') || nameLower.includes('deco') || nameLower.includes('backgammon')) {
    return 'home';
  }
  if (nameLower.includes('yoga') || nameLower.includes('sport') || nameLower.includes('fitness') || nameLower.includes('tapis')) {
    return 'yoga';
  }
  if (nameLower.includes('ceinture') || nameLower.includes('lunettes') || nameLower.includes('casquette') || nameLower.includes('gants') || nameLower.includes('bouteille')) {
    return 'accessory';
  }

  return 'clothing';
}

/**
 * Génère un prix réaliste
 */
function generatePrice(brand, productType) {
  const ranges = PRICE_RANGES[brand];
  if (!ranges) return 99;

  const range = ranges[productType] || ranges['clothing'] || [50, 150];
  const [min, max] = range;

  return Math.floor(Math.random() * (max - min) + min);
}

/**
 * Génère des tags automatiques
 */
function generateTags(brand, productName, price, productType) {
  const tags = [];
  const nameLower = productName.toLowerCase();

  // Tags de genre
  if (nameLower.includes('femme') || nameLower.includes('woman') || nameLower.includes('bra') || nameLower.includes('jupe')) {
    tags.push('femme');
  } else if (nameLower.includes('homme') || nameLower.includes('man') || nameLower.includes('men')) {
    tags.push('homme');
  } else {
    tags.push('unisexe');
  }

  // Tags de catégorie
  if (productType === 'sneaker') {
    tags.push('chaussures', 'sneakers');
  } else if (productType === 'bag') {
    tags.push('accessoires', 'sacs');
  } else if (productType === 'fragrance') {
    tags.push('beaute', 'parfum');
  } else if (productType === 'skincare') {
    tags.push('beaute', 'soins');
  } else if (productType === 'makeup') {
    tags.push('beaute', 'maquillage');
  } else if (productType === 'home') {
    tags.push('deco', 'maison');
  } else if (productType === 'yoga') {
    tags.push('sport', 'yoga', 'fitness');
  } else if (productType === 'clothing') {
    tags.push('mode', 'vetements');
  } else if (productType === 'accessory') {
    tags.push('accessoires');
  }

  // Tags de prix
  if (price < 50) {
    tags.push('budget_moins50');
  } else if (price < 100) {
    tags.push('budget_50-100');
  } else if (price < 200) {
    tags.push('budget_100-200');
  } else if (price < 500) {
    tags.push('budget_200-500');
  } else {
    tags.push('budget_luxe');
  }

  // Tags de style
  if (brand === 'Golden Goose') {
    tags.push('luxe', 'italien', 'streetwear');
  } else if (brand === 'Zara') {
    tags.push('tendance', 'accessible');
  } else if (brand === 'Maje' || brand === 'Miu Miu') {
    tags.push('luxe', 'feminine');
  } else if (brand === 'Rhode') {
    tags.push('beaute', 'naturel', 'clean-beauty');
  } else if (brand === 'Sephora') {
    tags.push('beaute');
  } else if (brand === 'Lululemon') {
    tags.push('sport', 'premium', 'athleisure');
  }

  // Tags d'âge
  if (brand === 'Zara' || nameLower.includes('streetwear')) {
    tags.push('20-30ans');
  } else if (brand === 'Miu Miu' || brand === 'Golden Goose') {
    tags.push('20-30ans', '30-50ans');
  } else {
    tags.push('30-50ans');
  }

  // Tags d'occasion
  if (nameLower.includes('birthday') || nameLower.includes('coffret') || nameLower.includes('set')) {
    tags.push('anniversaire', 'cadeau');
  }
  if (brand === 'Sephora' || brand === 'Rhode') {
    tags.push('fete-des-meres', 'saint-valentin');
  }
  if (productType === 'home') {
    tags.push('pendaison-cremaillere', 'noel');
  }

  return [...new Set(tags)]; // Supprimer les doublons
}

/**
 * Génère des catégories
 */
function generateCategories(productType) {
  const categoryMap = {
    'sneaker': ['mode', 'chaussures'],
    'bag': ['mode', 'accessoires'],
    'fragrance': ['beaute', 'parfum'],
    'skincare': ['beaute', 'soins'],
    'makeup': ['beaute', 'maquillage'],
    'home': ['deco', 'maison'],
    'yoga': ['sport', 'fitness'],
    'clothing': ['mode'],
    'accessory': ['accessoires'],
    'set': ['beaute', 'coffrets']
  };

  return categoryMap[productType] || ['autre'];
}

/**
 * Génère une description
 */
function generateDescription(brand, productName, productType) {
  const descriptions = {
    'Golden Goose': {
      'sneaker': `Sneakers ${brand} en cuir de qualité supérieure. Design iconique et confort exceptionnel.`,
      'bag': `Sac ${brand} en cuir italien. Élégance et praticité au quotidien.`,
      'clothing': `Vêtement ${brand} de haute qualité. Style décontracté chic.`,
      'accessory': `Accessoire ${brand} au design raffiné. Finitions soignées.`
    },
    'Zara': {
      'sneaker': `Chaussures Zara tendance. Style urbain et moderne.`,
      'clothing': `Pièce Zara de la dernière collection. Coupe moderne et confortable.`,
      'home': `Accessoire déco Zara Home. Design contemporain pour votre intérieur.`,
      'accessory': `Accessoire Zara au style actuel. Parfait pour compléter votre look.`
    },
    'Maje': {
      'clothing': `Vêtement Maje au style parisien élégant. Coupe flatteuse et féminine.`,
      'accessory': `Accessoire Maje raffiné. Touche d'élégance française.`
    },
    'Miu Miu': {
      'bag': `Sac Miu Miu de luxe. Craftsmanship italien d'exception.`,
      'clothing': `Pièce Miu Miu haute couture. Design avant-gardiste.`,
      'accessory': `Accessoire Miu Miu luxueux. Élégance intemporelle.`
    },
    'Rhode': {
      'skincare': `Soin Rhode pour une peau éclatante. Formule clean et efficace.`,
      'set': `Coffret Rhode pour une routine beauté complète. Incontournable.`
    },
    'Sephora': {
      'fragrance': `Parfum disponible chez Sephora. Fragrance envoûtante.`,
      'skincare': `Soin visage Sephora. Résultats visibles.`,
      'makeup': `Produit de maquillage Sephora. Tenue longue durée.`,
      'set': `Coffret beauté Sephora. Idée cadeau parfaite.`
    },
    'Lululemon': {
      'clothing': `Vêtement Lululemon haute performance. Confort et style pour le sport.`,
      'yoga': `Accessoire Lululemon pour yoga et fitness. Qualité premium.`,
      'accessory': `Accessoire Lululemon pratique. Design fonctionnel.`
    }
  };

  const brandDescriptions = descriptions[brand] || {};
  return brandDescriptions[productType] || `Produit ${brand} de qualité. ${productName}.`;
}

/**
 * Fonction principale
 */
async function main() {
  console.log('🚀 GÉNÉRATION INTELLIGENTE DES PRODUITS\n');
  console.log(`📋 ${PRODUCT_URLS.length} produits à générer\n`);

  // Initialiser Firebase
  console.log('🔥 Connexion à Firebase...');
  try {
    const serviceAccount = require('./serviceAccountKey.json');
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      projectId: 'doron-b3011'
    });
    console.log('✅ Firebase initialisé\n');
  } catch (error) {
    console.error('❌ Erreur Firebase:', error.message);
    process.exit(1);
  }

  const db = admin.firestore();

  // Générer tous les produits
  const products = [];

  for (let i = 0; i < PRODUCT_URLS.length; i++) {
    const url = PRODUCT_URLS[i];
    const brand = getBrandFromUrl(url);
    const productName = parseProductName(url, brand);
    const productType = getProductType(productName, brand);
    const price = generatePrice(brand, productType);
    const tags = generateTags(brand, productName, price, productType);
    const categories = generateCategories(productType);
    const description = generateDescription(brand, productName, productType);
    const image = BRAND_IMAGES[brand] || 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800&h=800&fit=crop';

    const product = {
      name: productName,
      brand: brand,
      price: price,
      url: url,
      image: image,
      product_photo: image,
      product_title: productName,
      product_url: url,
      product_price: String(price),
      description: description,
      categories: categories,
      tags: tags,
      popularity: 75,
      source: 'smart_parser',
      created_at: new Date().toISOString()
    };

    products.push(product);

    console.log(`✅ [${i + 1}/${PRODUCT_URLS.length}] ${brand} - ${productName.substring(0, 50)}... (${price}€)`);
  }

  console.log(`\n📊 RÉSULTATS:`);
  console.log(`   ✅ ${products.length} produits générés\n`);

  // Sauvegarder dans un fichier JSON
  fs.writeFileSync('./generated-products.json', JSON.stringify(products, null, 2));
  console.log(`💾 Produits sauvegardés dans generated-products.json\n`);

  // Upload dans Firebase
  console.log(`📤 Upload dans Firebase...`);

  let batch = db.batch();
  let batchCount = 0;
  let uploadedCount = 0;

  for (const product of products) {
    const docRef = db.collection('products').doc();
    batch.set(docRef, product);
    batchCount++;
    uploadedCount++;

    if (batchCount >= 500) {
      await batch.commit();
      console.log(`   ✅ ${uploadedCount}/${products.length} uploadés...`);
      batch = db.batch();
      batchCount = 0;
      await new Promise(resolve => setTimeout(resolve, 500));
    }
  }

  if (batchCount > 0) {
    await batch.commit();
  }

  console.log(`\n✅ ${uploadedCount} produits uploadés dans Firebase!`);

  console.log(`\n🎉 GÉNÉRATION ET UPLOAD TERMINÉS!`);
  console.log(`📱 Les produits sont maintenant disponibles dans l'app!`);

  process.exit(0);
}

// Exécuter
main().catch(error => {
  console.error('❌ Erreur fatale:', error);
  process.exit(1);
});
