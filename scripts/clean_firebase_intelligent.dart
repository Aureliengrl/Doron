import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Script de nettoyage intelligent Firebase
/// Supprime UNIQUEMENT les produits incomplets (manque infos)
///
/// Pour exécuter:
/// ```bash
/// dart run scripts/clean_firebase_intelligent.dart
/// ```

// Champs REQUIS pour qu'un produit soit considéré comme VALIDE
const REQUIRED_FIELDS = [
  'product_title',
  'product_price',
  'product_url',
  'product_photo',
  'platform',
];

/// Vérifie si un produit est valide
bool isProductValid(Map<String, dynamic> productData) {
  final List<String> missingFields = [];

  // Vérifier chaque champ requis
  for (final field in REQUIRED_FIELDS) {
    final value = productData[field];

    // Le champ doit exister ET ne pas être vide
    if (value == null || (value is String && value.trim().isEmpty)) {
      missingFields.add(field);
    }
  }

  // Vérifications supplémentaires

  // 1. Le prix doit être un nombre positif
  if (productData.containsKey('product_price')) {
    try {
      final price = double.parse(productData['product_price'].toString());
      if (price <= 0) {
        missingFields.add('product_price (invalid: <= 0)');
      }
    } catch (e) {
      missingFields.add('product_price (invalid format)');
    }
  }

  // 2. L'URL doit commencer par http:// ou https://
  if (productData.containsKey('product_url')) {
    final url = productData['product_url'].toString();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      missingFields.add('product_url (invalid URL)');
    }
  }

  // 3. L'image doit être une URL
  if (productData.containsKey('product_photo')) {
    final photo = productData['product_photo'].toString();
    if (!photo.startsWith('http://') && !photo.startsWith('https://')) {
      missingFields.add('product_photo (invalid URL)');
    }
  }

  // Si des champs manquent, afficher les détails
  if (missingFields.isNotEmpty) {
    final title = productData['product_title'] ?? 'Sans titre';
    final platform = productData['platform'] ?? 'Sans marque';
    print('   ❌ INVALIDE: $platform - $title');
    print('      Champs manquants: ${missingFields.join(", ")}');
  }

  return missingFields.isEmpty;
}

Future<void> main() async {
  print('=' * 80);
  print('🧹 NETTOYAGE INTELLIGENT DE FIREBASE');
  print('=' * 80);

  // Initialiser Firebase
  print('\n🔧 Connexion à Firebase...');
  try {
    await Firebase.initializeApp();
    print('   ✅ Connecté à Firebase\n');
  } catch (e) {
    print('   ❌ Erreur: $e\n');
    exit(1);
  }

  final firestore = FirebaseFirestore.instance;
  final productsRef = firestore.collection('products');

  // Lire TOUS les produits
  print('📖 Lecture de tous les produits Firebase...');

  List<Map<String, dynamic>> allProducts = [];

  try {
    final snapshot = await productsRef.get();

    for (final doc in snapshot.docs) {
      allProducts.add({
        'id': doc.id,
        'data': doc.data(),
      });
    }

    print('   ✅ ${allProducts.length} produits trouvés\n');
  } catch (e) {
    print('   ❌ Erreur lors de la lecture: $e\n');
    exit(1);
  }

  if (allProducts.isEmpty) {
    print('⚠️  Firebase est VIDE. Aucun produit à nettoyer.');
    print('\n💡 Solution: Uploadez des produits avec:');
    print('   dart run scripts/upload_products_simple.dart');
    exit(0);
  }

  // Analyser les produits
  print('🔍 Analyse des produits...');
  print('=' * 80);

  final List<Map<String, dynamic>> validProducts = [];
  final List<Map<String, dynamic>> invalidProducts = [];

  for (final product in allProducts) {
    if (isProductValid(product['data'])) {
      validProducts.add(product);
    } else {
      invalidProducts.add(product);
    }
  }

  print('\n' + '=' * 80);
  print('📊 RÉSULTATS');
  print('=' * 80);
  print('✅ Produits VALIDES: ${validProducts.length}');
  print('❌ Produits INVALIDES: ${invalidProducts.length}');
  print('📦 TOTAL: ${allProducts.length}\n');

  if (invalidProducts.isEmpty) {
    print('🎉 Tous les produits sont valides ! Aucun nettoyage nécessaire.');
    exit(0);
  }

  // Afficher quelques exemples de produits invalides
  if (invalidProducts.isNotEmpty) {
    print('📋 Exemples de produits invalides (max 5):');
    print('-' * 80);

    for (var i = 0; i < invalidProducts.length && i < 5; i++) {
      final product = invalidProducts[i];
      final title = product['data']['product_title'] ?? 'Sans titre';
      final platform = product['data']['platform'] ?? 'Sans marque';
      print('   ${i + 1}. $platform - $title');
    }

    if (invalidProducts.length > 5) {
      print('   ... et ${invalidProducts.length - 5} autres produits invalides');
    }
    print();
  }

  // Demander confirmation
  print('⚠️  ATTENTION: Vous allez supprimer ${invalidProducts.length} produits invalides');
  print('   Les ${validProducts.length} produits valides seront conservés.\n');

  stdout.write('Continuer? (oui/non): ');
  final confirmation = stdin.readLineSync()?.toLowerCase().trim();

  if (confirmation != 'oui' && confirmation != 'yes' && confirmation != 'y' && confirmation != 'o') {
    print('\n❌ Annulé par l\'utilisateur');
    exit(0);
  }

  // Supprimer les produits invalides
  print('\n🗑️  Suppression de ${invalidProducts.length} produits invalides...');

  int deletedCount = 0;
  final int batchSize = 500;

  for (var i = 0; i < invalidProducts.length; i += batchSize) {
    final batchProducts = invalidProducts.skip(i).take(batchSize).toList();
    final batch = firestore.batch();

    for (final product in batchProducts) {
      final docRef = productsRef.doc(product['id']);
      batch.delete(docRef);
    }

    await batch.commit();
    deletedCount += batchProducts.length;
    print('   ${deletedCount}/${invalidProducts.length} supprimés...');
  }

  print('   ✅ $deletedCount produits supprimés\n');

  // Résumé final
  print('=' * 80);
  print('✅ NETTOYAGE TERMINÉ!');
  print('=' * 80);
  print('📊 Produits GARDÉS: ${validProducts.length}');
  print('🗑️  Produits SUPPRIMÉS: $deletedCount');
  print('=' * 80);

  print('\n💡 Prochaines étapes:');
  print('   1. Ouvrez Firebase Console: https://console.firebase.google.com');
  print('   2. Vérifiez la collection "products"');
  print('   3. Testez votre app (mode Inspirations devrait fonctionner)');

  if (validProducts.length < 50) {
    print('\n⚠️  ATTENTION: Seulement ${validProducts.length} produits valides.');
    print('   Pour une meilleure expérience, uploadez plus de produits:');
    print('   dart run scripts/upload_products_simple.dart');
  }
}
