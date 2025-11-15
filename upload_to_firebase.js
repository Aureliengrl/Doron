const admin = require('firebase-admin');
const fs = require('fs');

// Initialize Firebase Admin
const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function uploadProducts() {
  console.log('📦 Loading products from JSON...');
  const data = JSON.parse(fs.readFileSync('products_all_brands.json', 'utf8'));
  const products = data.products;

  console.log(`✅ Loaded ${products.length} products`);
  console.log('🚀 Starting upload to Firebase Firestore...');

  const batchSize = 500; // Firestore batch limit
  let uploaded = 0;

  for (let i = 0; i < products.length; i += batchSize) {
    const batch = db.batch();
    const chunk = products.slice(i, i + batchSize);

    chunk.forEach((product) => {
      const docRef = db.collection('products').doc();
      batch.set(docRef, {
        product_title: product.product_title || '',
        product_price: product.product_price || '',
        product_original_price: product.product_original_price || '',
        product_star_rating: product.product_star_rating || '',
        product_num_ratings: parseInt(product.product_num_ratings) || 0,
        product_url: product.product_url || '',
        product_photo: product.product_photo || '',
        platform: product.platform || ''
      });
    });

    try {
      await batch.commit();
      uploaded += chunk.length;
      console.log(`✅ Uploaded ${uploaded}/${products.length} products (${Math.round(uploaded/products.length*100)}%)`);
    } catch (error) {
      console.error(`❌ Error uploading batch ${i}-${i + batchSize}:`, error);
      throw error;
    }

    // Add small delay to avoid rate limiting
    if (i + batchSize < products.length) {
      await new Promise(resolve => setTimeout(resolve, 1000));
    }
  }

  console.log(`🎉 Successfully uploaded ${uploaded} products to Firebase!`);
}

uploadProducts()
  .then(() => {
    console.log('✅ Upload complete!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('❌ Upload failed:', error);
    process.exit(1);
  });
