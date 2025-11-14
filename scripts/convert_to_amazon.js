#!/usr/bin/env node

/**
 * Récupère les mêmes produits mais avec images et URLs Amazon
 * Tag partenaire: doron072004-21
 */

const fs = require('fs');

// Charger les produits actuels
const currentProducts = JSON.parse(
  fs.readFileSync('./assets/jsons/fallback_products.json', 'utf8')
);

console.log(`📦 ${currentProducts.length} produits à convertir vers Amazon`);

// Format de recherche Amazon
function getAmazonSearchUrl(brand, productName) {
  const query = encodeURIComponent(`${brand} ${productName}`);
  return `https://www.amazon.fr/s?k=${query}`;
}

// Format URL avec tag partenaire
function getAmazonProductUrl(asin) {
  return `https://www.amazon.fr/dp/${asin}?tag=doron072004-21`;
}

// Format image Amazon
function getAmazonImageUrl(asin) {
  // Format standard des images Amazon
  return `https://m.media-amazon.com/images/I/${asin}._AC_SL1500_.jpg`;
}

console.log('\n🔍 EXEMPLE DE CONVERSIONS:');
console.log('─────────────────────────────────────────────────────────');

// Afficher quelques exemples
const examples = currentProducts.slice(0, 5);

examples.forEach(product => {
  const searchUrl = getAmazonSearchUrl(product.brand, product.name);
  console.log(`\n📦 ${product.name}`);
  console.log(`   Marque: ${product.brand}`);
  console.log(`   Prix: ${product.price}€`);
  console.log(`   Recherche Amazon: ${searchUrl.substring(0, 80)}...`);
});

console.log('\n\n📋 INSTRUCTIONS POUR RÉCUPÉRER LES DONNÉES AMAZON:');
console.log('═════════════════════════════════════════════════════════════════\n');

console.log('MÉTHODE 1 - Utiliser Amazon Product Advertising API (Recommandé):');
console.log('──────────────────────────────────────────────────────────────────');
console.log('1. Va sur: https://affiliate-program.amazon.fr/');
console.log('2. Inscris-toi au programme partenaire (si pas déjà fait)');
console.log('3. Demande accès à l\'API Product Advertising');
console.log('4. Récupère tes clés API (Access Key + Secret Key)');
console.log('5. Utilise ces clés pour chercher les produits\n');

console.log('MÉTHODE 2 - Recherche manuelle Amazon (Plus simple mais manuel):');
console.log('──────────────────────────────────────────────────────────────────');
console.log('Pour chaque produit:');
console.log('1. Cherche sur Amazon.fr: "Nike Air Force 1 White"');
console.log('2. Récupère l\'ASIN du produit (code à 10 caractères dans l\'URL)');
console.log('3. Image: https://m.media-amazon.com/images/I/[ASIN]._AC_SL1500_.jpg');
console.log('4. URL: https://www.amazon.fr/dp/[ASIN]?tag=doron072004-21\n');

console.log('MÉTHODE 3 - Script automatique avec WebSearch (Je peux faire):');
console.log('──────────────────────────────────────────────────────────────────');
console.log('Je peux créer un agent qui utilise WebSearch pour:');
console.log('1. Chercher chaque produit sur Amazon.fr');
console.log('2. Extraire l\'ASIN automatiquement');
console.log('3. Générer les URLs avec ton tag');
console.log('4. Créer le nouveau fallback_products.json\n');

// Créer un fichier template pour les ASINs
const asinTemplate = currentProducts.map((product, index) => ({
  id: product.id,
  name: product.name,
  brand: product.brand,
  price: product.price,
  amazonSearchUrl: getAmazonSearchUrl(product.brand, product.name),
  asin: '', // À remplir
  // Les autres champs seront générés automatiquement une fois l'ASIN rempli
}));

fs.writeFileSync(
  './amazon_asin_template.json',
  JSON.stringify(asinTemplate, null, 2)
);

console.log('✅ Fichier template créé: amazon_asin_template.json');
console.log('   Ce fichier contient les URLs de recherche Amazon pour chaque produit\n');

console.log('🎯 PROCHAINE ÉTAPE:');
console.log('═════════════════════════════════════════════════════════════════');
console.log('Quelle méthode préfères-tu?');
console.log('1. API Amazon (nécessite inscription)');
console.log('2. Agent automatique avec WebSearch (je le fais pour toi)');
console.log('3. Manuel (tu remplis les ASINs)\n');

process.exit(0);
