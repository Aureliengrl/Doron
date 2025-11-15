#!/usr/bin/env node

/**
 * Upload produits via Firebase REST API (sans SDK)
 */

const https = require('https');
const fs = require('fs');

const PROJECT_ID = 'doron-b3011';
const API_KEY = 'AIzaSyAl7Jlzgyet26D3zO4pF56BfznA3k3AiTk';

// Charger les produits
const products = JSON.parse(
  fs.readFileSync('./scripts/affiliate/websearch_real_products.json', 'utf8')
);

console.log(`📦 ${products.length} produits à uploader`);
console.log(`🔥 Project: ${PROJECT_ID}`);
console.log('\n⚠️  IMPORTANT: Tu dois avoir les droits administrateur Firebase pour ce projet\n');

// Pour utiliser l'API REST, tu as besoin d'un token OAuth
// Voici les étapes:
console.log('📋 ÉTAPES POUR UPLOADER VIA CONSOLE FIREBASE:');
console.log('');
console.log('1. Va sur: https://console.firebase.google.com/project/doron-b3011/firestore');
console.log('2. Clique sur "Firestore Database" dans le menu de gauche');
console.log('3. Sélectionne la collection "products"');
console.log('4. Clique sur "..." (menu trois points) puis "Delete collection"');
console.log('5. Confirme la suppression');
console.log('');
console.log('6. Ensuite, tu peux uploader les produits de 2 façons:');
console.log('');
console.log('   OPTION A - Via script Node (nécessite authentification):');
console.log('   - Install: npm install firebase');
console.log('   - Configure Firebase auth avec tes credentials utilisateur');
console.log('');
console.log('   OPTION B - Via l\'app TestFlight (RECOMMANDÉ):');
console.log('   - Je vais créer un lien direct pour télécharger le fichier JSON');
console.log('   - Tu pourras l\'importer manuellement dans Firebase Console');
console.log('');

// Créer un fichier prêt pour import Firebase
const firebaseImport = {};
products.forEach(product => {
  const id = String(product.id);
  const data = {...product};
  delete data.id;
  firebaseImport[id] = data;
});

fs.writeFileSync(
  './firebase-products-import.json',
  JSON.stringify(firebaseImport, null, 2)
);

console.log('✅ Fichier firebase-products-import.json créé!');
console.log('');
console.log('🎯 SOLUTION SIMPLE:');
console.log('');
console.log('1. Télécharge le fichier: firebase-products-import.json');
console.log('2. Va sur Firebase Console: https://console.firebase.google.com/project/doron-b3011/firestore');
console.log('3. Supprime la collection "products" si elle existe');
console.log('4. Utilise l\'outil d\'import Firebase pour uploader le JSON');
console.log('');
console.log('OU utilise le script Firebase Admin avec tes propres credentials:');
console.log('firebase login');
console.log('firebase use doron-b3011');
console.log('');

process.exit(0);
