import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Script Flutter pour gérer les produits Firebase
/// Utilise les credentials Firebase déjà configurés dans l'app
class FirebaseProductsManager {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Supprime tous les produits de Firebase
  static Future<void> deleteAllProducts() async {
    print('🗑️  Suppression de tous les produits...\n');

    try {
      // Compter les produits
      final countQuery = await _firestore.collection('products').count().get();
      final totalCount = countQuery.count ?? 0;

      if (totalCount == 0) {
        print('✅ Aucun produit à supprimer');
        return;
      }

      print('   Produits à supprimer: $totalCount\n');

      int deletedCount = 0;
      const batchSize = 500;

      while (true) {
        // Récupérer un batch
        final snapshot = await _firestore
            .collection('products')
            .limit(batchSize)
            .get();

        if (snapshot.docs.isEmpty) break;

        // Créer un batch de suppression
        final batch = _firestore.batch();
        for (var doc in snapshot.docs) {
          batch.delete(doc.reference);
        }

        // Commit
        await batch.commit();
        deletedCount += snapshot.docs.length;

        print('   ✅ $deletedCount/$totalCount produits supprimés...');

        // Petit délai
        await Future.delayed(const Duration(milliseconds: 200));
      }

      print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('✅ SUPPRESSION TERMINÉE!');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('   Total supprimé: $deletedCount produits\n');
    } catch (e) {
      print('❌ Erreur: $e');
      rethrow;
    }
  }

  /// Upload tous les produits depuis fallback_products.json
  static Future<void> uploadAllProducts() async {
    print('🚀 Démarrage de l\'upload des produits...\n');

    try {
      // Lire le fichier JSON
      print('📖 Lecture du fichier...');
      final jsonString = await rootBundle.loadString('assets/jsons/fallback_products.json');
      final List<dynamic> products = json.decode(jsonString);

      print('✅ ${products.length} produits chargés\n');

      // Vérifier si la collection existe
      final snapshot = await _firestore.collection('products').limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        print('⚠️  La collection "products" existe déjà');
        print('   Les nouveaux produits seront ajoutés/mis à jour\n');
      }

      // Upload par batch
      const batchSize = 500;
      int uploadedCount = 0;
      int errorCount = 0;

      print('📤 Upload des produits...');
      print('   Batch size: $batchSize produits\n');

      for (int i = 0; i < products.length; i += batchSize) {
        final batch = _firestore.batch();
        final endIndex = (i + batchSize < products.length) ? i + batchSize : products.length;
        final currentBatch = products.sublist(i, endIndex);

        print('📦 Batch ${(i ~/ batchSize) + 1}: Produits ${i + 1} à $endIndex...');

        for (var product in currentBatch) {
          try {
            final productMap = product as Map<String, dynamic>;
            final docRef = _firestore.collection('products').doc(productMap['id'].toString());

            // Retirer l'ID du map (il sera dans le document ID)
            final data = Map<String, dynamic>.from(productMap);
            data.remove('id');

            // Assurer que les arrays sont corrects
            if (!data.containsKey('tags')) data['tags'] = [];
            if (!data.containsKey('categories')) data['categories'] = [];

            batch.set(docRef, data);
            uploadedCount++;
          } catch (e) {
            print('   ⚠️  Erreur produit ${product['id']}: $e');
            errorCount++;
          }
        }

        // Commit le batch
        try {
          await batch.commit();
          print('   ✅ Batch ${(i ~/ batchSize) + 1} uploadé (${currentBatch.length} produits)');

          // Délai pour éviter de surcharger Firebase
          if (endIndex < products.length) {
            await Future.delayed(const Duration(milliseconds: 500));
          }
        } catch (e) {
          print('   ❌ Erreur upload batch ${(i ~/ batchSize) + 1}: $e');
          errorCount += currentBatch.length;
        }
      }

      print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('✅ UPLOAD TERMINÉ!');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📊 Statistiques:');
      print('   - Produits uploadés: $uploadedCount');
      print('   - Erreurs: $errorCount');
      print('   - Total: ${products.length} produits');

      // Vérification finale
      print('\n🔍 Vérification finale...');
      final finalCount = await _firestore.collection('products').count().get();
      print('   Collection "products" contient: ${finalCount.count} documents');

      // Test avec filtre
      print('\n🧪 Test de requête avec filtre sexe...');
      final maleQuery = await _firestore
          .collection('products')
          .where('tags', arrayContains: 'homme')
          .limit(10)
          .get();
      print('   - Produits avec tag "homme": ${maleQuery.docs.length} trouvés');

      final femaleQuery = await _firestore
          .collection('products')
          .where('tags', arrayContains: 'femme')
          .limit(10)
          .get();
      print('   - Produits avec tag "femme": ${femaleQuery.docs.length} trouvés');

      print('\n✨ Firebase est maintenant peuplé!');
      print('   L\'app devrait afficher des produits variés.\n');
    } catch (e) {
      print('❌ Erreur fatale: $e');
      rethrow;
    }
  }

  /// Menu interactif pour choisir l'opération
  static Future<void> runInteractive() async {
    print('\n═══════════════════════════════════════════════════════');
    print('     GESTION DES PRODUITS FIREBASE');
    print('═══════════════════════════════════════════════════════\n');
    print('Que veux-tu faire ?\n');
    print('1. Supprimer tous les produits');
    print('2. Uploader les nouveaux produits');
    print('3. Supprimer ET re-uploader (recommandé)');
    print('4. Quitter\n');

    stdout.write('Choix (1-4): ');
    final choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        await deleteAllProducts();
        break;
      case '2':
        await uploadAllProducts();
        break;
      case '3':
        await deleteAllProducts();
        print('\n⏸️  Pause de 2 secondes...\n');
        await Future.delayed(const Duration(seconds: 2));
        await uploadAllProducts();
        break;
      case '4':
        print('👋 À bientôt!');
        break;
      default:
        print('❌ Choix invalide');
    }
  }
}
