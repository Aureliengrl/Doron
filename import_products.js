/**
 * Script pour importer les produits d'exemple dans Firebase Firestore
 *
 * Prérequis:
 * 1. npm install firebase-admin
 * 2. Télécharger la clé de service Firebase (serviceAccountKey.json)
 * 3. Placer serviceAccountKey.json dans le même dossier
 *
 * Usage:
 * node import_products.js
 */

const admin = require('firebase-admin');
const fs = require('fs');

// Initialiser Firebase Admin
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Charger les produits d'exemple
const exemples = JSON.parse(fs.readFileSync('EXEMPLES_PRODUITS_FIREBASE.json', 'utf8'));

async function importProducts() {
  console.log('🔄 Début de l\'importation des produits...\n');

  let successCount = 0;
  let errorCount = 0;

  for (const exemple of exemples.exemples) {
    try {
      const productData = exemple.data;
      const productId = productData.id;

      // Supprimer l'ID des données (sera utilisé comme clé de document)
      delete productData.id;

      // Importer dans Firestore
      await db.collection('gifts').doc(productId).set(productData);

      console.log(`✅ ${exemple.nom}`);
      console.log(`   ID: ${productId}`);
      console.log(`   Tags: ${productData.tags.length} tags`);
      console.log(`   Prix: ${productData.price}€\n`);

      successCount++;
    } catch (error) {
      console.error(`❌ Erreur pour ${exemple.nom}:`, error.message);
      errorCount++;
    }
  }

  console.log('\n═══════════════════════════════════════');
  console.log('📊 RÉSUMÉ DE L\'IMPORTATION');
  console.log('═══════════════════════════════════════');
  console.log(`✅ Produits importés: ${successCount}`);
  console.log(`❌ Erreurs: ${errorCount}`);
  console.log(`📦 Total: ${exemples.exemples.length}\n`);

  if (errorCount === 0) {
    console.log('🎉 Tous les produits ont été importés avec succès!\n');
    console.log('🔍 Vérification dans Firebase Console:');
    console.log('   1. Va sur https://console.firebase.google.com');
    console.log('   2. Sélectionne ton projet: doron-b3011');
    console.log('   3. Va dans Firestore Database');
    console.log('   4. Ouvre la collection "gifts"');
    console.log('   5. Tu devrais voir 10 produits\n');
  }

  process.exit(errorCount === 0 ? 0 : 1);
}

// Lancer l'importation
importProducts().catch(error => {
  console.error('❌ Erreur fatale:', error);
  process.exit(1);
});
