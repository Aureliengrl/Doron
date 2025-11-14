#!/usr/bin/env node

/**
 * Script pour uploader les 379 VRAIS produits directement dans Firebase Firestore
 */

const admin = require('firebase-admin');
const fs = require('fs');

async function uploadProducts() {
  console.log('🔥 CONNEXION À FIREBASE...');

  try {
    // Initialiser Firebase Admin
    const serviceAccount = require('./serviceAccountKey.json');

    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      projectId: 'doron-b3011'
    });

    console.log('✅ Firebase Admin SDK initialisé');
  } catch (error) {
    console.error('❌ Erreur initialisation Firebase:', error.message);
    return;
  }

  const db = admin.firestore();

  console.log('\n📦 CHARGEMENT DES PRODUITS RÉELS...');

  // Charger les produits depuis le fichier
  const products = JSON.parse(
    fs.readFileSync('./scripts/affiliate/websearch_real_products.json', 'utf8')
  );

  console.log(`✅ ${products.length} produits chargés depuis websearch_real_products.json`);

  console.log('\n🗑️  SUPPRESSION DES ANCIENS PRODUITS...');

  // Supprimer tous les anciens produits
  let deletedCount = 0;
  let batch = db.batch();
  let batchCount = 0;

  try {
    const snapshot = await db.collection('products').get();

    for (const doc of snapshot.docs) {
      batch.delete(doc.ref);
      batchCount++;
      deletedCount++;

      // Firestore limite à 500 opérations par batch
      if (batchCount >= 500) {
        await batch.commit();
        console.log(`   Supprimé ${deletedCount} produits...`);
        batch = db.batch();
        batchCount = 0;
        await new Promise(resolve => setTimeout(resolve, 500));
      }
    }

    // Commit le dernier batch
    if (batchCount > 0) {
      await batch.commit();
    }

    console.log(`✅ ${deletedCount} anciens produits supprimés`);
  } catch (error) {
    console.error('⚠️  Erreur suppression:', error.message);
  }

  console.log('\n📤 UPLOAD DES NOUVEAUX PRODUITS RÉELS...');

  // Uploader les nouveaux produits
  let uploadedCount = 0;
  batch = db.batch();
  batchCount = 0;

  for (const product of products) {
    // Créer une référence avec l'ID du produit
    const productId = String(product.id);
    const docRef = db.collection('products').doc(productId);

    // Préparer les données (enlever l'ID car il sera dans le document ID)
    const productData = { ...product };
    delete productData.id;

    // Ajouter au batch
    batch.set(docRef, productData);
    batchCount++;
    uploadedCount++;

    // Commit tous les 500 produits
    if (batchCount >= 500) {
      await batch.commit();
      console.log(`   ✅ Uploadé ${uploadedCount}/${products.length} produits...`);
      batch = db.batch();
      batchCount = 0;
      await new Promise(resolve => setTimeout(resolve, 500));
    }
  }

  // Commit le dernier batch
  if (batchCount > 0) {
    await batch.commit();
  }

  console.log(`\n✅ ${uploadedCount} produits RÉELS uploadés dans Firebase!`);

  console.log('\n📊 VÉRIFICATION...');

  // Vérifier quelques produits
  const sampleSnapshot = await db.collection('products').limit(5).get();

  console.log('\n🎁 Exemples de produits dans Firebase:');
  sampleSnapshot.forEach(doc => {
    const data = doc.data();
    console.log(`   • ${data.name} - ${data.brand}`);
    console.log(`     Image: ${(data.image || '').substring(0, 80)}...`);
  });

  console.log('\n🎉 UPLOAD TERMINÉ!');
  console.log('🚀 Les produits RÉELS sont maintenant dans Firebase!');
  console.log('📱 Tu peux maintenant rafraîchir ton app TestFlight pour voir les vrais produits!');

  process.exit(0);
}

// Exécuter
uploadProducts().catch(error => {
  console.error('❌ Erreur fatale:', error);
  process.exit(1);
});
