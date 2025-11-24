/**
 * Script de correction des tags Firebase pour l'app Doron
 *
 * UTILISATION SUR REPLIT:
 * 1. Créer un nouveau Repl Node.js
 * 2. Copier ce fichier
 * 3. Installer les dépendances: npm install firebase-admin
 * 4. Ajouter votre fichier serviceAccountKey.json dans Secrets
 * 5. Exécuter: node fix_firebase_tags.js
 *
 * Ce script ajoute automatiquement les tags manquants à tous les produits:
 * - gender_homme / gender_femme / gender_mixte
 * - cat_tech / cat_mode / cat_beaute / etc.
 * - budget_0_50 / budget_50_100 / etc.
 * - age_adulte / age_jeune / etc.
 */

const admin = require('firebase-admin');

// Configuration Firebase - MODIFIER SELON VOTRE PROJET
// Sur Replit, mettez votre serviceAccountKey.json dans les Secrets
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Statistiques
let stats = {
  total: 0,
  updated: 0,
  errors: 0,
  byTag: {
    gender: 0,
    category: 0,
    budget: 0,
    age: 0
  }
};

/**
 * Détecte le genre d'un produit basé sur son nom et description
 */
function detectGender(productName, productDescription) {
  const text = `${productName} ${productDescription}`.toLowerCase();

  // Mots-clés TRÈS SPÉCIFIQUES pour FEMME
  const feminineKeywords = [
    'robe', 'jupe', 'lingerie', 'soutien-gorge', 'culotte femme',
    'collant', 'maquillage', 'rouge à lèvres', 'mascara', 'vernis',
    'sac à main', 'femme', 'pour elle', 'féminin', 'talons'
  ];

  // Mots-clés TRÈS SPÉCIFIQUES pour HOMME
  const masculineKeywords = [
    'cravate', 'rasoir électrique', 'tondeuse barbe', 'after shave',
    'costume homme', 'homme', 'pour lui', 'masculin', 'barbe'
  ];

  const isFeminine = feminineKeywords.some(kw => text.includes(kw));
  const isMasculine = masculineKeywords.some(kw => text.includes(kw));

  if (isFeminine && !isMasculine) {
    return 'gender_femme';
  } else if (isMasculine && !isFeminine) {
    return 'gender_homme';
  } else {
    return 'gender_mixte'; // Par défaut: universel
  }
}

/**
 * Détecte la catégorie d'un produit
 */
function detectCategory(productName, productDescription) {
  const text = `${productName} ${productDescription}`.toLowerCase();

  const categoryKeywords = {
    'cat_tech': [
      'tech', 'électronique', 'gadget', 'usb', 'bluetooth', 'écouteurs',
      'casque', 'smartphone', 'tablette', 'ordinateur', 'souris', 'clavier',
      'cable', 'chargeur', 'powerbank', 'enceinte', 'speaker'
    ],
    'cat_mode': [
      'vêtement', 't-shirt', 'pull', 'sweat', 'pantalon', 'jean',
      'chaussure', 'basket', 'sneaker', 'mode', 'fashion', 'hoodie',
      'chemise', 'polo', 'short', 'robe', 'jupe'
    ],
    'cat_beaute': [
      'beauté', 'maquillage', 'parfum', 'crème', 'soin', 'cosmétique',
      'huile', 'sérum', 'shampoing', 'après-shampoing', 'gel douche',
      'lotion', 'masque', 'gommage'
    ],
    'cat_maison': [
      'maison', 'déco', 'décoration', 'coussin', 'lampe', 'bougie',
      'vase', 'cadre', 'plante', 'tapis', 'rideau', 'horloge'
    ],
    'cat_sport': [
      'sport', 'fitness', 'yoga', 'running', 'musculation', 'gym',
      'training', 'basket', 'football', 'vélo', 'natation', 'tennis',
      'haltère', 'tapis de sport'
    ],
    'cat_food': [
      'cuisine', 'gastronomie', 'chocolat', 'thé', 'café', 'vin',
      'gourmet', 'food', 'bouteille', 'confiserie', 'biscuit',
      'alcool', 'whisky', 'champagne'
    ],
    'cat_livre': [
      'livre', 'roman', 'bd', 'manga', 'lecture', 'bouquin', 'polar'
    ],
    'cat_jeux': [
      'jeu', 'jouet', 'puzzle', 'board game', 'société', 'carte',
      'lego', 'playmobil'
    ]
  };

  for (const [categoryTag, keywords] of Object.entries(categoryKeywords)) {
    if (keywords.some(kw => text.includes(kw))) {
      return categoryTag;
    }
  }

  return 'cat_tendances'; // Par défaut
}

/**
 * Calcule le tag de budget basé sur le prix
 */
function getBudgetTag(price) {
  if (price < 50) return 'budget_0_50';
  if (price < 100) return 'budget_50_100';
  if (price < 200) return 'budget_100_200';
  if (price < 500) return 'budget_200_500';
  return 'budget_500_plus';
}

/**
 * Détecte le tag d'âge
 */
function detectAge(productName, productDescription) {
  const text = `${productName} ${productDescription}`.toLowerCase();

  if (text.includes('enfant') || text.includes('bébé') || text.includes('kid')) {
    return 'age_enfant';
  } else if (text.includes('ado') || text.includes('teenager')) {
    return 'age_jeune';
  } else if (text.includes('senior') || text.includes('retraite')) {
    return 'age_senior';
  }

  return 'age_adulte'; // Par défaut
}

/**
 * Traite un produit et ajoute les tags manquants
 */
async function processProduct(doc) {
  try {
    const data = doc.data();
    const productName = data.name || '';
    const productDescription = data.description || '';
    const price = typeof data.price === 'number' ? data.price : parseInt(data.price || '0');
    const currentTags = Array.isArray(data.tags) ? data.tags : [];
    const currentCategories = Array.isArray(data.categories) ? data.categories : [];

    const newTags = new Set(currentTags);
    const newCategories = new Set(currentCategories);
    let modified = false;

    // 1. TAG DE GENRE (CRITIQUE)
    if (!currentTags.some(t => t.startsWith('gender_'))) {
      const genderTag = detectGender(productName, productDescription);
      newTags.add(genderTag);
      modified = true;
      stats.byTag.gender++;
      console.log(`  👤 "${productName}" → ${genderTag}`);
    }

    // 2. TAG DE CATÉGORIE
    if (!currentTags.some(t => t.startsWith('cat_'))) {
      const categoryTag = detectCategory(productName, productDescription);
      newTags.add(categoryTag);
      newCategories.add(categoryTag.replace('cat_', '').charAt(0).toUpperCase() + categoryTag.replace('cat_', '').slice(1));
      modified = true;
      stats.byTag.category++;
      console.log(`  📁 "${productName}" → ${categoryTag}`);
    }

    // 3. TAG DE BUDGET
    if (!currentTags.some(t => t.startsWith('budget_')) && price > 0) {
      const budgetTag = getBudgetTag(price);
      newTags.add(budgetTag);
      modified = true;
      stats.byTag.budget++;
      console.log(`  💰 "${productName}" → ${budgetTag} (${price}€)`);
    }

    // 4. TAG D'ÂGE
    if (!currentTags.some(t => t.startsWith('age_'))) {
      const ageTag = detectAge(productName, productDescription);
      newTags.add(ageTag);
      modified = true;
      stats.byTag.age++;
    }

    // Mettre à jour le document si modifié
    if (modified) {
      await doc.ref.update({
        tags: Array.from(newTags),
        categories: Array.from(newCategories)
      });
      stats.updated++;
      return true;
    }

    return false;
  } catch (error) {
    console.error(`❌ Erreur sur produit ${doc.id}:`, error.message);
    stats.errors++;
    return false;
  }
}

/**
 * Fonction principale
 */
async function main() {
  console.log('🔧 Script de correction des tags Firebase');
  console.log('=========================================\n');

  try {
    // Charger tous les produits
    console.log('📦 Chargement des produits depuis Firebase...');
    const snapshot = await db.collection('gifts').get();
    stats.total = snapshot.size;
    console.log(`✅ ${stats.total} produits chargés\n`);

    if (snapshot.empty) {
      console.log('❌ Aucun produit dans la collection "gifts" !');
      process.exit(1);
    }

    // Afficher un échantillon AVANT
    const firstDoc = snapshot.docs[0];
    const firstData = firstDoc.data();
    console.log('📋 ÉCHANTILLON AVANT MODIFICATION:');
    console.log(`  Produit: ${firstData.name}`);
    console.log(`  Tags actuels: ${JSON.stringify(firstData.tags)}`);
    console.log(`  Prix: ${firstData.price}€\n`);

    // Traiter tous les produits
    console.log('🔄 Traitement des produits...\n');
    let processed = 0;

    for (const doc of snapshot.docs) {
      await processProduct(doc);
      processed++;

      // Afficher la progression tous les 10 produits
      if (processed % 10 === 0) {
        console.log(`   Progress: ${processed}/${stats.total} produits traités...`);
      }
    }

    // Résumé final
    console.log('\n✅ TERMINÉ !');
    console.log('═══════════════════════════════════════');
    console.log(`📊 Total produits: ${stats.total}`);
    console.log(`✅ Produits mis à jour: ${stats.updated}`);
    console.log(`❌ Erreurs: ${stats.errors}`);
    console.log('\n📈 Tags ajoutés par type:');
    console.log(`  👤 Genre: ${stats.byTag.gender}`);
    console.log(`  📁 Catégorie: ${stats.byTag.category}`);
    console.log(`  💰 Budget: ${stats.byTag.budget}`);
    console.log(`  🎂 Âge: ${stats.byTag.age}`);

    // Afficher un échantillon APRÈS
    const updatedSnapshot = await db.collection('gifts').limit(1).get();
    if (!updatedSnapshot.empty) {
      const updatedData = updatedSnapshot.docs[0].data();
      console.log('\n📋 ÉCHANTILLON APRÈS MODIFICATION:');
      console.log(`  Produit: ${updatedData.name}`);
      console.log(`  Tags: ${JSON.stringify(updatedData.tags)}`);
      console.log(`  Catégories: ${JSON.stringify(updatedData.categories)}`);
    }

    console.log('\n✨ Votre base Firebase est maintenant prête !');
    console.log('   Testez l\'app: ajoutez une personne et vérifiez les résultats.');

  } catch (error) {
    console.error('\n❌ ERREUR CRITIQUE:', error);
    process.exit(1);
  }

  process.exit(0);
}

// Lancer le script
main();
