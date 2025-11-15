import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Script to upload 1240+ products to Firebase Firestore
/// Run with: dart run scripts/upload_to_firebase.dart

Future<void> main() async {
  print('=' * 80);
  print('DORON - Firebase Products Upload Script');
  print('=' * 80);

  // Initialize Firebase
  print('\n📱 Initializing Firebase...');
  await Firebase.initializeApp();

  // Read products JSON
  print('\n📂 Reading products.json...');
  final file = File('scripts/products.json');
  final jsonString = await file.readAsString();
  final List<dynamic> productsJson = json.decode(jsonString);

  print('✅ Loaded ${productsJson.length} products');

  // Get Firestore instance
  final firestore = FirebaseFirestore.instance;
  final giftsCollection = firestore.collection('gifts');

  // Upload products in batches
  print('\n🚀 Starting upload to Firebase...');
  print('=' * 80);

  int uploadCount = 0;
  int batchSize = 50;
  int batchNumber = 1;

  for (int i = 0; i < productsJson.length; i += batchSize) {
    final batchEnd = (i + batchSize < productsJson.length)
        ? i + batchSize
        : productsJson.length;

    final batch = productsJson.sublist(i, batchEnd);

    print('\n📦 Batch $batchNumber: Uploading products ${i + 1} to $batchEnd...');

    // Use batch write for better performance
    final writeBatch = firestore.batch();

    for (final productJson in batch) {
      final productData = {
        'id': productJson['id'],
        'brand': productJson['brand'],
        'title': productJson['title'],
        'imageUrl': productJson['imageUrl'],
        'productUrl': productJson['productUrl'],
        'price': productJson['price'],
        'originalPrice': productJson['originalPrice'],
        'category': productJson['category'],
        'tags': List<String>.from(productJson['tags'] ?? []),
        'gender': productJson['gender'],
        'ageRange': productJson['ageRange'],
        'style': productJson['style'],
        'occasion': productJson['occasion'],
        'budgetRange': productJson['budgetRange'],
        'rating': productJson['rating'],
        'numRatings': productJson['numRatings'],
        'verified': productJson['verified'],
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Use product ID as document ID
      final docRef = giftsCollection.doc(productJson['id']);
      writeBatch.set(docRef, productData);
      uploadCount++;
    }

    // Commit batch
    try {
      await writeBatch.commit();
      print('✅ Batch $batchNumber uploaded successfully!');
    } catch (e) {
      print('❌ Error uploading batch $batchNumber: $e');
    }

    batchNumber++;

    // Add small delay between batches to avoid rate limiting
    if (i + batchSize < productsJson.length) {
      await Future.delayed(Duration(milliseconds: 500));
    }
  }

  print('\n' + '=' * 80);
  print('✅ UPLOAD COMPLETE!');
  print('📊 Total products uploaded: $uploadCount');
  print('=' * 80);
}
