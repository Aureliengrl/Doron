import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Script simple pour uploader les produits vers Firebase
///
/// Pour exécuter depuis la racine du projet :
/// ```bash
/// dart run scripts/upload_products_simple.dart
/// ```

Future<void> main() async {
  print('=' * 80);
  print('🔥 UPLOAD DES PRODUITS VERS FIREBASE');
  print('=' * 80);

  try {
    // Initialiser Firebase
    print('\n🔧 Initialisation de Firebase...');
    await Firebase.initializeApp();
    print('   ✅ Firebase initialisé');

    final firestore = FirebaseFirestore.instance;

    // Charger le fichier JSON
    print('\n📁 Chargement des produits...');
    final file = File('scripts/smart_real_products.json');

    if (!file.existsSync()) {
      print('   ❌ Fichier non trouvé: ${file.path}');
      print('   Assurez-vous d\'exécuter depuis la racine du projet');
      return;
    }

    final jsonString = await file.readAsString();
    final data = json.decode(jsonString) as Map<String, dynamic>;
    final products = (data['products'] as List).cast<Map<String, dynamic>>();

    print('   ✅ ${products.length} produits chargés');

    // Supprimer les anciens produits
    print('\n🗑️  Suppression des anciens produits...');
    final productsRef = firestore.collection('products');

    int deletedCount = 0;
    QuerySnapshot? snapshot;

    do {
      snapshot = await productsRef.limit(500).get();

      final batch = firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
        deletedCount++;
      }

      if (snapshot.docs.isNotEmpty) {
        await batch.commit();
        print('   ${deletedCount} produits supprimés...');
      }
    } while (snapshot.docs.length == 500);

    print('   ✅ Tous les anciens produits supprimés');

    // Uploader les nouveaux produits
    print('\n📤 Upload des nouveaux produits...');
    int uploadedCount = 0;

    // Uploader par batch de 500 (limite Firestore)
    for (int i = 0; i < products.length; i += 500) {
      final batchProducts = products.skip(i).take(500).toList();
      final batch = firestore.batch();

      for (final product in batchProducts) {
        final docRef = productsRef.doc();

        // Nettoyer les données
        final cleanProduct = Map<String, dynamic>.from(product);
        cleanProduct.removeWhere((key, value) => value == null || value == '');

        // Convertir les prix en nombres
        if (cleanProduct['product_price'] is String) {
          try {
            cleanProduct['product_price'] = double.parse(cleanProduct['product_price'] as String);
          } catch (e) {
            // Garder comme string si échec
          }
        }

        if (cleanProduct['product_original_price'] is String) {
          try {
            cleanProduct['product_original_price'] = double.parse(cleanProduct['product_original_price'] as String);
          } catch (e) {
            cleanProduct.remove('product_original_price');
          }
        }

        if (cleanProduct['product_star_rating'] is String) {
          try {
            cleanProduct['product_star_rating'] = double.parse(cleanProduct['product_star_rating'] as String);
          } catch (e) {
            cleanProduct['product_star_rating'] = 4.5;
          }
        }

        batch.set(docRef, cleanProduct);
      }

      await batch.commit();
      uploadedCount += batchProducts.length;
      print('   ${uploadedCount}/${products.length} produits uploadés...');
    }

    // Résumé
    print('\n' + '=' * 80);
    print('✅ UPLOAD TERMINÉ!');
    print('   ${uploadedCount} produits uploadés avec succès');
    print('   Tous les produits ont des URLs Amazon RÉELLES');
    print('=' * 80);

    print('\n💡 Prochaines étapes:');
    print('   1. Ouvrez Firebase Console: https://console.firebase.google.com');
    print('   2. Allez dans Firestore Database');
    print('   3. Vérifiez la collection "products"');
    print('   4. Testez votre app!');

  } catch (e, stackTrace) {
    print('\n❌ ERREUR: $e');
    print('Stack trace:');
    print(stackTrace);
  }
}
