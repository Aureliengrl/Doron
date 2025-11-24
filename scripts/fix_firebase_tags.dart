import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';

/// Script pour corriger les tags des produits Firebase
///
/// Problème : Les produits n'ont pas les bons tags pour le système de scoring
/// Solution : Ajouter automatiquement les tags manquants basés sur :
///   - Le nom du produit
///   - La catégorie
///   - Le prix
///   - Les mots-clés dans la description

void main() async {
  print('🔧 Script de correction des tags Firebase');
  print('=========================================\n');

  // Initialiser Firebase
  await Firebase.initializeApp();
  final firestore = FirebaseFirestore.instance;

  // Lire tous les produits de la collection 'gifts'
  print('📦 Chargement des produits depuis Firebase...');
  final snapshot = await firestore.collection('gifts').get();
  print('✅ ${snapshot.docs.length} produits chargés\n');

  if (snapshot.docs.isEmpty) {
    print('❌ Aucun produit dans Firebase !');
    return;
  }

  // Afficher un échantillon AVANT modification
  print('📋 ÉCHANTILLON AVANT MODIFICATION:');
  final sample = snapshot.docs.first.data();
  print('  Produit: ${sample['name']}');
  print('  Tags actuels: ${sample['tags']}');
  print('  Categories: ${sample['categories']}');
  print('  Prix: ${sample['price']}€\n');

  int updated = 0;
  int errors = 0;

  // Mettre à jour chaque produit
  for (var doc in snapshot.docs) {
    try {
      final data = doc.data();
      final productName = (data['name'] ?? '').toString().toLowerCase();
      final productDescription = (data['description'] ?? '').toString().toLowerCase();
      final price = data['price'] is int ? data['price'] : (int.tryParse(data['price']?.toString() ?? '0') ?? 0);
      final currentTags = (data['tags'] as List?)?.cast<String>() ?? [];
      final currentCategories = (data['categories'] as List?)?.cast<String>() ?? [];

      // Créer un set de tags à ajouter
      final newTags = <String>{...currentTags};
      final newCategories = <String>{...currentCategories};

      // ============================================
      // 1. TAGS DE GENRE (CRITIQUE pour le filtrage)
      // ============================================
      final hasGenderTag = currentTags.any((t) => t.startsWith('gender_'));

      if (!hasGenderTag) {
        // Détecter le genre depuis le nom/description

        // Mots-clés TRÈS SPÉCIFIQUES pour FEMME
        final feminineKeywords = [
          'robe', 'jupe', 'lingerie', 'soutien-gorge', 'culotte femme',
          'collant', 'maquillage', 'rouge à lèvres', 'mascara', 'vernis',
          'sac à main', 'femme', 'pour elle', 'féminin'
        ];

        // Mots-clés TRÈS SPÉCIFIQUES pour HOMME
        final masculineKeywords = [
          'cravate', 'rasoir électrique', 'tondeuse barbe', 'after shave',
          'costume homme', 'homme', 'pour lui', 'masculin', 'monsieur'
        ];

        final isFeminine = feminineKeywords.any((kw) =>
          productName.contains(kw) || productDescription.contains(kw));
        final isMasculine = masculineKeywords.any((kw) =>
          productName.contains(kw) || productDescription.contains(kw));

        if (isFeminine && !isMasculine) {
          newTags.add('gender_femme');
          print('  👩 ${data['name']} → gender_femme');
        } else if (isMasculine && !isFeminine) {
          newTags.add('gender_homme');
          print('  👨 ${data['name']} → gender_homme');
        } else {
          // Par défaut : MIXTE (universel)
          newTags.add('gender_mixte');
          print('  👥 ${data['name']} → gender_mixte');
        }
      }

      // ============================================
      // 2. TAGS DE CATÉGORIE
      // ============================================
      final hasCategoryTag = currentTags.any((t) => t.startsWith('cat_'));

      if (!hasCategoryTag) {
        // Détecter la catégorie depuis le nom/description
        final categoryKeywords = {
          'cat_tech': ['tech', 'électronique', 'gadget', 'usb', 'bluetooth', 'écouteurs', 'casque', 'smartphone', 'tablette', 'ordinateur'],
          'cat_mode': ['vêtement', 't-shirt', 'pull', 'pantalon', 'jean', 'chaussure', 'basket', 'mode', 'fashion'],
          'cat_beaute': ['beauté', 'maquillage', 'parfum', 'crème', 'soin', 'cosmétique', 'huile'],
          'cat_maison': ['maison', 'déco', 'décoration', 'coussin', 'lampe', 'bougie', 'vase', 'cadre'],
          'cat_sport': ['sport', 'fitness', 'yoga', 'running', 'musculation', 'gym', 'training'],
          'cat_food': ['cuisine', 'gastronomie', 'chocolat', 'thé', 'café', 'vin', 'gourmet'],
          'cat_livre': ['livre', 'roman', 'bd', 'manga', 'lecture', 'bouquin'],
          'cat_jeux': ['jeu', 'jouet', 'puzzle', 'board game', 'société', 'carte'],
        };

        for (var entry in categoryKeywords.entries) {
          final categoryTag = entry.key;
          final keywords = entry.value;

          if (keywords.any((kw) => productName.contains(kw) || productDescription.contains(kw))) {
            newTags.add(categoryTag);
            newCategories.add(categoryTag.replaceFirst('cat_', '').capitalize());
            print('  📁 ${data['name']} → $categoryTag');
            break; // Une seule catégorie principale
          }
        }

        // Si aucune catégorie détectée, mettre "cat_tendances" par défaut
        if (!newTags.any((t) => t.startsWith('cat_'))) {
          newTags.add('cat_tendances');
          newCategories.add('Tendances');
        }
      }

      // ============================================
      // 3. TAGS DE BUDGET
      // ============================================
      final hasBudgetTag = currentTags.any((t) => t.startsWith('budget_'));

      if (!hasBudgetTag && price > 0) {
        String budgetTag;
        if (price < 50) {
          budgetTag = 'budget_0_50';
        } else if (price < 100) {
          budgetTag = 'budget_50_100';
        } else if (price < 200) {
          budgetTag = 'budget_100_200';
        } else if (price < 500) {
          budgetTag = 'budget_200_500';
        } else {
          budgetTag = 'budget_500_plus';
        }
        newTags.add(budgetTag);
        print('  💰 ${data['name']} → $budgetTag (${price}€)');
      }

      // ============================================
      // 4. TAGS D'ÂGE (basé sur la catégorie)
      // ============================================
      final hasAgeTag = currentTags.any((t) => t.startsWith('age_'));

      if (!hasAgeTag) {
        // Par défaut : adulte (18-50 ans)
        // Sauf pour certaines catégories spécifiques
        if (productName.contains('enfant') || productName.contains('bébé') || productName.contains('kid')) {
          newTags.add('age_enfant');
        } else if (productName.contains('ado') || productName.contains('teenager')) {
          newTags.add('age_jeune');
        } else if (productName.contains('senior') || productName.contains('retraite')) {
          newTags.add('age_senior');
        } else {
          // Par défaut : adulte (la majorité des produits)
          newTags.add('age_adulte');
        }
      }

      // ============================================
      // METTRE À JOUR LE DOCUMENT
      // ============================================
      if (newTags.length > currentTags.length || newCategories.length > currentCategories.length) {
        await doc.reference.update({
          'tags': newTags.toList(),
          'categories': newCategories.toList(),
        });
        updated++;
      }

    } catch (e) {
      print('❌ Erreur sur ${doc.id}: $e');
      errors++;
    }
  }

  print('\n✅ TERMINÉ!');
  print('  - Produits mis à jour: $updated');
  print('  - Erreurs: $errors');
  print('  - Total: ${snapshot.docs.length}');

  // Afficher un échantillon APRÈS modification
  print('\n📋 ÉCHANTILLON APRÈS MODIFICATION:');
  final updatedSnapshot = await firestore.collection('gifts').limit(1).get();
  if (updatedSnapshot.docs.isNotEmpty) {
    final updatedSample = updatedSnapshot.docs.first.data();
    print('  Produit: ${updatedSample['name']}');
    print('  Tags: ${updatedSample['tags']}');
    print('  Categories: ${updatedSample['categories']}');
  }

  exit(0);
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
