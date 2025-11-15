#!/usr/bin/env node

/**
 * Prépare les produits générés pour l'upload dans Firebase Gifts collection
 * Ajoute le champ 'active' et formate correctement les données
 */

const fs = require('fs');
const admin = require('firebase-admin');

async function main() {
  console.log('📦 PRÉPARATION DES PRODUITS POUR FIREBASE GIFTS\n');

  // Charger les produits générés
  const products = JSON.parse(fs.readFileSync('./generated-products.json', 'utf8'));
  console.log(`✅ ${products.length} produits chargés\n`);

  // Formater chaque produit pour la collection Gifts
  const giftsData = products.map((product, index) => {
    return {
      name: product.name,
      brand: product.brand,
      price: product.price,
      url: product.url,
      image: product.image,
      product_photo: product.product_photo,
      product_title: product.product_title,
      product_url: product.product_url,
      product_price: product.product_price,
      description: product.description,
      categories: product.categories,
      tags: product.tags,
      popularity: product.popularity,
      source: product.source,
      active: true, // IMPORTANT : marquer tous les produits comme actifs
      created_at: product.created_at
    };
  });

  // Sauvegarder dans un nouveau fichier
  fs.writeFileSync('./gifts-ready-for-upload.json', JSON.stringify(giftsData, null, 2));
  console.log(`💾 Produits formatés sauvegardés dans gifts-ready-for-upload.json\n`);

  // Essayer d'uploader dans Firebase
  console.log('🔥 Tentative d\'upload dans Firebase...\n');

  try {
    const serviceAccount = require('./serviceAccountKey.json');
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      projectId: 'doron-b3011'
    });

    const db = admin.firestore();

    let batch = db.batch();
    let batchCount = 0;
    let uploadedCount = 0;

    for (const gift of giftsData) {
      const docRef = db.collection('gifts').doc();
      batch.set(docRef, gift);
      batchCount++;
      uploadedCount++;

      if (batchCount >= 500) {
        await batch.commit();
        console.log(`   ✅ ${uploadedCount}/${giftsData.length} uploadés...`);
        batch = db.batch();
        batchCount = 0;
        await new Promise(resolve => setTimeout(resolve, 500));
      }
    }

    if (batchCount > 0) {
      await batch.commit();
    }

    console.log(`\n✅ ${uploadedCount} cadeaux uploadés dans Firebase Gifts collection!`);
    console.log(`\n🎉 UPLOAD TERMINÉ!`);

  } catch (error) {
    console.log(`❌ Erreur Firebase: ${error.message}`);
    console.log(`\n💡 Les produits sont prêts dans gifts-ready-for-upload.json`);
    console.log(`   Tu peux les uploader manuellement via la console Firebase.\n`);
  }

  process.exit(0);
}

main().catch(error => {
  console.error('❌ Erreur:', error);
  process.exit(1);
});
