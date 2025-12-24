#!/usr/bin/env node

/**
 * Script pour réparer les produits Firebase
 * 1. Supprime tous les anciens produits (sans tags)
 * 2. Upload les nouveaux produits (avec tags)
 */

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Demander les credentials Firebase
const readline = require('readline').createInterface({
  input: process.stdin,
  output: process.stdout
});

console.log('🔧 RÉPARATION DES PRODUITS FIREBASE\n');
console.log('Ce script va:');
console.log('1. ❌ Supprimer tous les anciens produits (sans tags)');
console.log('2. ✅ Uploader 2201 nouveaux produits (avec tags)\n');

async function main() {
  // Lire les credentials depuis l'input ou fichier
  let serviceAccount;

  // Chercher un fichier de credentials
  const possiblePaths = [
    './doron-c9816-firebase-adminsdk-7fbel-6d06f4f2ac.json',
    './serviceAccountKey.json',
    './firebase-key.json'
  ];

  for (const filePath of possiblePaths) {
    if (fs.existsSync(filePath)) {
      console.log(`✅ Credentials trouvés: ${filePath}\n`);
      serviceAccount = require(path.resolve(filePath));
      break;
    }
  }

  if (!serviceAccount) {
    console.log('❌ Aucun fichier de credentials Firebase trouvé.');
    console.log('📋 Crée un fichier serviceAccountKey.json avec tes credentials Firebase\n');

    readline.question('Veux-tu coller tes credentials Firebase JSON ici? (y/n): ', async (answer) => {
      if (answer.toLowerCase() === 'y') {
        console.log('\n📝 Colle ton JSON Firebase (Ctrl+D quand terminé):');

        let jsonInput = '';
        process.stdin.on('data', (chunk) => {
          jsonInput += chunk;
        });

        process.stdin.on('end', async () => {
          try {
            serviceAccount = JSON.parse(jsonInput);
            await runFix(serviceAccount);
          } catch (e) {
            console.error('❌ JSON invalide:', e.message);
            process.exit(1);
          }
        });
      } else {
        console.log('❌ Annulé. Place tes credentials dans serviceAccountKey.json');
        process.exit(1);
      }
    });

    return;
  }

  await runFix(serviceAccount);
}

async function runFix(serviceAccount) {
  // Initialiser Firebase
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });

  const db = admin.firestore();

  // ÉTAPE 1: Supprimer tous les anciens produits
  console.log('🗑️  ÉTAPE 1: Suppression des anciens produits...\n');

  let deletedCount = 0;
  let hasMore = true;

  while (hasMore) {
    const snapshot = await db.collection('products').limit(500).get();

    if (snapshot.empty) {
      hasMore = false;
      break;
    }

    console.log(`   Suppression de ${snapshot.size} produits...`);

    const batch = db.batch();
    snapshot.docs.forEach(doc => {
      batch.delete(doc.ref);
    });

    await batch.commit();
    deletedCount += snapshot.size;

    console.log(`   ✅ ${deletedCount} produits supprimés`);
  }

  console.log(`\n✅ Suppression terminée: ${deletedCount} produits supprimés\n`);

  // ÉTAPE 2: Uploader les nouveaux produits
  console.log('📤 ÉTAPE 2: Upload des nouveaux produits avec tags...\n');

  const jsonPath = path.join(__dirname, 'assets/jsons/fallback_products.json');

  if (!fs.existsSync(jsonPath)) {
    console.error('❌ Fichier fallback_products.json non trouvé!');
    console.error('   Chemin attendu:', jsonPath);
    process.exit(1);
  }

  const jsonData = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));
  console.log(`✅ ${jsonData.length} produits chargés depuis fallback_products.json\n`);

  // Vérifier la structure du premier produit
  const sampleProduct = jsonData[0];
  console.log('📋 Structure d\'un produit:');
  console.log(`   - Champs: ${Object.keys(sampleProduct).join(', ')}`);
  console.log(`   - Tags: ${sampleProduct.tags ? sampleProduct.tags.length : 0} tags`);
  console.log(`   - Categories: ${sampleProduct.categories ? sampleProduct.categories.length : 0} categories\n`);

  if (!sampleProduct.tags || !sampleProduct.categories) {
    console.error('❌ ERREUR: Les produits n\'ont pas de tags/categories!');
    process.exit(1);
  }

  // Upload par batch de 500
  const batchSize = 500;
  let uploadedCount = 0;

  for (let i = 0; i < jsonData.length; i += batchSize) {
    const batch = db.batch();
    const endIndex = Math.min(i + batchSize, jsonData.length);
    const currentBatch = jsonData.slice(i, endIndex);

    console.log(`📦 Batch ${Math.floor(i / batchSize) + 1}/${Math.ceil(jsonData.length / batchSize)}: Produits ${i + 1} à ${endIndex}...`);

    for (const product of currentBatch) {
      // Utiliser l'ID du produit comme document ID
      const docRef = db.collection('products').doc(product.id.toString());

      // Préparer les données
      const data = { ...product };
      delete data.id; // L'ID sera dans le document ID

      // Assurer que les arrays sont bien présents
      if (!data.tags) data.tags = [];
      if (!data.categories) data.categories = [];

      batch.set(docRef, data);
      uploadedCount++;
    }

    // Commit le batch
    await batch.commit();
    console.log(`   ✅ ${currentBatch.length} produits uploadés`);
  }

  console.log(`\n✅ Upload terminé: ${uploadedCount} produits uploadés\n`);

  // VÉRIFICATION FINALE
  console.log('🔍 Vérification finale...\n');

  const finalSnapshot = await db.collection('products').count().get();
  console.log(`✅ Total produits dans Firebase: ${finalSnapshot.data().count}`);

  // Vérifier un produit avec tags
  const sampleDoc = await db.collection('products').limit(1).get();
  if (!sampleDoc.empty) {
    const sampleData = sampleDoc.docs[0].data();
    console.log(`✅ Tags présents: ${sampleData.tags ? '✓' : '✗'}`);
    console.log(`✅ Categories présentes: ${sampleData.categories ? '✓' : '✗'}`);
    console.log(`✅ Exemple tags: ${sampleData.tags ? sampleData.tags.slice(0, 3).join(', ') : 'N/A'}`);
  }

  console.log('\n🎉 RÉPARATION TERMINÉE! Tes produits sont maintenant correctement configurés.\n');
  console.log('📱 Tu peux maintenant relancer ton app et voir tous les produits variés!\n');

  process.exit(0);
}

main().catch(err => {
  console.error('❌ Erreur:', err);
  process.exit(1);
});
