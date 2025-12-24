#!/usr/bin/env node

/**
 * Script de scraping RÉEL des produits
 * Va sur chaque URL et extrait les VRAIES données
 */

const https = require('https');
const http = require('http');
const { URL } = require('url');
const admin = require('firebase-admin');
const fs = require('fs');

// Liste de tous les liens
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

  // Zara (quelques exemples pour commencer)
  'https://www.zara.com/fr/fr/sweat-a-capuche-effet-neoprene-p01437360.html',
  'https://www.zara.com/fr/fr/veste-rembourree-100-plumes-deperlante-p03411510.html',
  'https://www.zara.com/fr/fr/jean-flare-fit-p00840353.html',

  // Sephora (quelques exemples)
  'https://www.sephora.fr/p/coffret-miss-dior---eau-de-parfum-et-lait-pour-le-corps--edition-limitee-P1000210763.html',
  'https://www.sephora.fr/p/hydration-set-holiday--25--P10062651.html',
];

/**
 * Fetch une URL avec gestion des redirections et headers réalistes
 */
function fetchUrl(url, maxRedirects = 5) {
  return new Promise((resolve, reject) => {
    const parsedUrl = new URL(url);
    const isHttps = parsedUrl.protocol === 'https:';
    const client = isHttps ? https : http;

    const options = {
      hostname: parsedUrl.hostname,
      port: parsedUrl.port || (isHttps ? 443 : 80),
      path: parsedUrl.pathname + parsedUrl.search,
      method: 'GET',
      headers: {

// LISTE COMPLÈTE de TOUTES les URLs (114 produits)
const PRODUCT_URLS = [
  // Golden Goose (30 produits)
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

  // Zara (36 produits)
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

  // Maje (4 produits)
  'https://fr.maje.com/fr/p/minijupe-en-fausse-fourrure-leopard/MFPJU01519_K039.html',
  'https://fr.maje.com/fr/p/bottes-santiags-en-cuir/MFACH00801_G005.html',
  'https://fr.maje.com/fr/p/manteau-court-double-face/MFPBL00794_0609.html',
  'https://fr.maje.com/fr/p/jean-large-avec-poches-plaquees/MFPJE00762_0103.html',

  // Miu Miu (6 produits)
  'https://www.miumiu.com/fr/fr/p/pochette-en-velours/5NE851_068_F0011',
  'https://www.miumiu.com/fr/fr/p/mini-sac-wander-en-velours-matelasse/5BP078_2EOM_F0011_V_OON',
  'https://www.miumiu.com/fr/fr/p/veste-en-cuir-suede-cire/MPV990_18BT_F0002_S_OOO',
  'https://www.miumiu.com/fr/fr/p/pochette-en-cuir-nappa-matelasse/5BF130_AN88_F0002_V_OLO',
  'https://www.miumiu.com/fr/fr/p/cardigan-a-capuche-en-cachemire/MMF00T_18YX_F0MZQ_S_OOO',
  'https://www.miumiu.com/fr/fr/p/mini-jupe-en-cuir-suede-cire/MPD836_1421_F0005_S_OOO',

  // Rhode (7 produits)
  'https://www.rhodeskin.com/pages/the-birthday-set',
  'https://www.rhodeskin.com/products/the-scented-peptide-lip-tint-set',
  'https://www.rhodeskin.com/products/the-oversized-rhode-kit',
  'https://www.rhodeskin.com/products/lip-case',
  'https://www.rhodeskin.com/products/glazing-milk',
  'https://www.rhodeskin.com/products/the-travel-set',
  'https://www.rhodeskin.com/products/pocket-blush-tan-line',

  // Sephora (22 produits)
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

  // Lululemon (9 produits)
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
// Liste de tous les liens
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

  // Zara (quelques exemples pour commencer)
  'https://www.zara.com/fr/fr/sweat-a-capuche-effet-neoprene-p01437360.html',
  'https://www.zara.com/fr/fr/veste-rembourree-100-plumes-deperlante-p03411510.html',
  'https://www.zara.com/fr/fr/jean-flare-fit-p00840353.html',

  // Sephora (quelques exemples)
  'https://www.sephora.fr/p/coffret-miss-dior---eau-de-parfum-et-lait-pour-le-corps--edition-limitee-P1000210763.html',
  'https://www.sephora.fr/p/hydration-set-holiday--25--P10062651.html',
];

/**
 * Fetch une URL avec gestion des redirections et headers réalistes
 */
function fetchUrl(url, maxRedirects = 5) {
  return new Promise((resolve, reject) => {
    const parsedUrl = new URL(url);
    const isHttps = parsedUrl.protocol === 'https:';
    const client = isHttps ? https : http;

    const options = {
      hostname: parsedUrl.hostname,
      port: parsedUrl.port || (isHttps ? 443 : 80),
      path: parsedUrl.pathname + parsedUrl.search,
      method: 'GET',
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7',
        'Accept-Encoding': 'gzip, deflate, br',
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': '1',
        'Cache-Control': 'max-age=0',
      },
    };

    const req = client.request(options, (res) => {
      // Gérer les redirections
      if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
        if (maxRedirects === 0) {
          reject(new Error('Too many redirects'));
          return;
        }

        const redirectUrl = new URL(res.headers.location, url).href;
        console.log(`  ↪ Redirection vers: ${redirectUrl}`);

        fetchUrl(redirectUrl, maxRedirects - 1)
          .then(resolve)
          .catch(reject);
        return;
      }

      if (res.statusCode !== 200) {
        reject(new Error(`HTTP ${res.statusCode}`));
        return;
      }

      let data = '';
      res.setEncoding('utf8');
      res.on('data', chunk => data += chunk);
      res.on('end', () => resolve(data));
    });

    req.on('error', reject);
    req.setTimeout(15000, () => {
      req.destroy();
      reject(new Error('Timeout'));
    });

    req.end();
  });
}

/**
 * Extrait le prix depuis le HTML
 */
function extractPrice(html) {
  const patterns = [
    /<meta\s+property="og:price:amount"\s+content="([^"]+)"/i,
    /<meta\s+property="product:price:amount"\s+content="([^"]+)"/i,
    /"price"\s*:\s*"?([0-9]+\.?[0-9]*)"?/i,
    /€\s*([0-9]+[.,][0-9]{2})/,
    /([0-9]+[.,][0-9]{2})\s*€/,
    /<span[^>]*class="[^"]*price[^"]*"[^>]*>.*?([0-9]+[.,][0-9]{2})/i,
  ];

  for (const pattern of patterns) {
    const match = html.match(pattern);
    if (match && match[1]) {
      return parseFloat(match[1].replace(',', '.'));
    }
  }

  return null;
}

/**
 * Extrait le nom du produit depuis le HTML
 */
function extractProductName(html) {
  const patterns = [
    /<meta\s+property="og:title"\s+content="([^"]+)"/i,
    /<meta\s+name="twitter:title"\s+content="([^"]+)"/i,
    /<title>([^<]+)<\/title>/i,
    /<h1[^>]*>([^<]+)<\/h1>/i,
    /"name"\s*:\s*"([^"]+)"/i,
  ];

  for (const pattern of patterns) {
    const match = html.match(pattern);
    if (match && match[1]) {
      let name = match[1].trim();
      // Nettoyer le nom
      name = name.replace(/\s*\|\s*.*$/, ''); // Enlever "| Site Name"
      name = name.replace(/\s*-\s*.*$/, ''); // Enlever "- Site Name"
      return name.substring(0, 200); // Limiter la longueur
    }
  }

  return null;
}

/**
 * Extrait l'URL de l'image depuis le HTML
 */
function extractImageUrl(html) {
  const patterns = [
    /<meta\s+property="og:image"\s+content="([^"]+)"/i,
    /<meta\s+name="twitter:image"\s+content="([^"]+)"/i,
    /<img[^>]+class="[^"]*product[^"]*"[^>]+src="([^"]+)"/i,
    /"image"\s*:\s*"([^"]+)"/i,
  ];

  for (const pattern of patterns) {
    const match = html.match(pattern);
    if (match && match[1]) {
      let imageUrl = match[1];
      // Nettoyer l'URL de l'image
      if (imageUrl.startsWith('//')) {
        imageUrl = 'https:' + imageUrl;
      } else if (imageUrl.startsWith('/')) {
        // URL relative, à compléter plus tard
        return imageUrl;
      }
      return imageUrl;
    }
  }

  return null;
}

/**
 * Extrait la description depuis le HTML
 */
function extractDescription(html) {
  const patterns = [
    /<meta\s+property="og:description"\s+content="([^"]+)"/i,
    /<meta\s+name="description"\s+content="([^"]+)"/i,
    /"description"\s*:\s*"([^"]+)"/i,
  ];

  for (const pattern of patterns) {
    const match = html.match(pattern);
    if (match && match[1]) {
      return match[1].substring(0, 300);
    }
  }

  return null;
}

/**
 * Scrape une URL de produit
 */
async function scrapeProduct(url, index, total) {
  console.log(`\n[${index + 1}/${total}] 🔍 Scraping: ${url.substring(0, 80)}...`);

  try {
    // Attendre un délai aléatoire pour éviter d'être bloqué
    const delay = 1000 + Math.random() * 2000;
    await new Promise(resolve => setTimeout(resolve, delay));

    // Fetch le HTML
    const html = await fetchUrl(url);
    console.log(`  ✅ HTML récupéré (${Math.round(html.length / 1024)}KB)`);

    // Extraire les données
    const name = extractProductName(html);
    const price = extractPrice(html);
    let imageUrl = extractImageUrl(html);

    // Compléter l'URL de l'image si elle est relative
    if (imageUrl && imageUrl.startsWith('/')) {
      const urlObj = new URL(url);
      imageUrl = `${urlObj.protocol}//${urlObj.hostname}${imageUrl}`;
    }

    const description = extractDescription(html);

    // Détecter la marque depuis l'URL
    const brand = getBrandFromUrl(url);

    // Vérifier que nous avons au moins le nom et le prix
    if (!name || !price) {
      console.log(`  ⚠️  Données incomplètes:`);
      console.log(`     Nom: ${name || 'NON TROUVÉ'}`);
      console.log(`     Prix: ${price || 'NON TROUVÉ'}€`);
      console.log(`     Image: ${imageUrl ? 'OK' : 'NON TROUVÉE'}`);
      return null;
    }

    console.log(`  ✅ ${name.substring(0, 60)}...`);
    console.log(`  💰 Prix: ${price}€`);
    console.log(`  🖼️  Image: ${imageUrl ? 'OK' : 'NON TROUVÉE'}`);

    return {
      name,
      price,
      url,
      image: imageUrl || '',
      description: description || `Produit ${brand} de qualité`,
      brand,
    };

  } catch (error) {
    console.log(`  ❌ Erreur: ${error.message}`);
    return null;
  }
}

/**
 * Détermine la marque depuis l'URL
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
 * Génère des tags automatiques
 */
function generateTags(brand, productName, price) {
  const tags = [];
  const nameLower = productName.toLowerCase();

  // Tags de genre
  if (nameLower.includes('femme') || nameLower.includes('woman')) {
    tags.push('femme');
  } else if (nameLower.includes('homme') || nameLower.includes('man') || nameLower.includes('men')) {
    tags.push('homme');
  } else {
    tags.push('unisexe');
  }

  // Tags de catégorie
  if (nameLower.includes('chaussure') || nameLower.includes('sneaker') || nameLower.includes('basket')) {
    tags.push('chaussures', 'mode');
  } else if (nameLower.includes('sac') || nameLower.includes('bag')) {
    tags.push('accessoires', 'mode');
  } else if (nameLower.includes('parfum') || nameLower.includes('fragrance')) {
    tags.push('beaute', 'parfum');
  } else if (nameLower.includes('veste') || nameLower.includes('manteau') || nameLower.includes('blouson')) {
    tags.push('mode', 'vetements');
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

  // Tags de marque
  if (brand === 'Golden Goose') {
    tags.push('luxe', 'italien', 'streetwear');
  } else if (brand === 'Zara') {
    tags.push('tendance', 'accessible');
  }

  tags.push('20-30ans', '30-50ans');

  return [...new Set(tags)];
}

/**
 * Génère des catégories
 */
function generateCategories(productName) {
  const nameLower = productName.toLowerCase();

  if (nameLower.includes('chaussure') || nameLower.includes('sneaker')) {
    return ['mode', 'chaussures'];
  } else if (nameLower.includes('sac') || nameLower.includes('bag')) {
    return ['mode', 'accessoires'];
  } else if (nameLower.includes('parfum')) {
    return ['beaute', 'parfum'];
  } else if (nameLower.includes('veste') || nameLower.includes('jean')) {
    return ['mode'];
  }

  return ['mode'];
}

/**
 * Fonction principale
 */
async function main() {
  console.log('🚀 SCRAPING RÉEL DES PRODUITS\n');
  console.log(`📋 ${PRODUCT_URLS.length} URLs à scraper\n`);
  console.log('⚠️  Ce processus peut prendre plusieurs minutes...\n');

  const scrapedProducts = [];
  const failedUrls = [];

  // Scraper chaque URL
  for (let i = 0; i < PRODUCT_URLS.length; i++) {
    const url = PRODUCT_URLS[i];
    const productData = await scrapeProduct(url, i, PRODUCT_URLS.length);

    if (productData) {
      // Ajouter tags et catégories
      const product = {
        ...productData,
        product_photo: productData.image,
        product_title: productData.name,
        product_url: productData.url,
        product_price: String(productData.price),
        categories: generateCategories(productData.name),
        tags: generateTags(productData.brand, productData.name, productData.price),
        popularity: 75,
        active: true,
        source: 'real_scraping',
        created_at: new Date().toISOString(),
      };

      scrapedProducts.push(product);
    } else {
      failedUrls.push(url);
    }
  }

  console.log(`\n\n📊 RÉSULTATS FINAUX:`);
  console.log(`   ✅ ${scrapedProducts.length} produits scrapés avec succès`);
  console.log(`   ❌ ${failedUrls.length} échecs`);

  if (failedUrls.length > 0) {
    console.log(`\n⚠️  URLs échouées:`);
    failedUrls.forEach((url, i) => {
      console.log(`   ${i + 1}. ${url.substring(0, 80)}...`);
    });
  }

  // Sauvegarder les résultats
  const filename = './real-scraped-products.json';
  fs.writeFileSync(filename, JSON.stringify(scrapedProducts, null, 2));
  console.log(`\n💾 Produits sauvegardés dans: ${filename}`);

  // Essayer d'uploader dans Firebase
  if (scrapedProducts.length > 0) {
    console.log(`\n🔥 Upload dans Firebase...`);

    try {
      const serviceAccount = require('./serviceAccountKey.json');
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        projectId: 'doron-b3011'
      });

      const db = admin.firestore();
      let batch = db.batch();
      let batchCount = 0;

      for (const product of scrapedProducts) {
        const docRef = db.collection('gifts').doc();
        batch.set(docRef, product);
        batchCount++;

        if (batchCount >= 500) {
          await batch.commit();
          console.log(`   ✅ ${batchCount} produits uploadés...`);
          batch = db.batch();
          batchCount = 0;
        }
      }

      if (batchCount > 0) {
        await batch.commit();
      }

      console.log(`✅ ${scrapedProducts.length} produits uploadés dans Firebase!`);
    } catch (error) {
      console.log(`⚠️  Upload Firebase impossible: ${error.message}`);
      console.log(`   Les produits sont sauvegardés dans ${filename}`);
    }
  }

  console.log(`\n🎉 SCRAPING TERMINÉ!`);
  process.exit(0);
}

// Exécuter
main().catch(error => {
  console.error('❌ Erreur fatale:', error);
  process.exit(1);
});
