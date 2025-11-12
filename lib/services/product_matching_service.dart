import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Service de matching de produits basé sur les tags
/// Remplace les appels OpenAI pour des résultats instantanés
class ProductMatchingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static List<Map<String, dynamic>>? _cachedFallbackProducts;

  /// Génère des produits personnalisés en matchant les tags utilisateur avec la base de produits
  static Future<List<Map<String, dynamic>>> getPersonalizedProducts({
    required Map<String, dynamic> userTags,
    int count = 50,
    String? category,
  }) async {
    try {
      print('🎯 Matching produits pour tags: ${userTags.keys.join(", ")}');

      // Convertir les réponses utilisateur en tags de recherche
      final searchTags = _convertUserTagsToSearchTags(userTags);
      print('🏷️ Tags de recherche: $searchTags');

      // Récupérer tous les produits (ou filtrer par catégorie)
      Query<Map<String, dynamic>> query = _firestore.collection('products');

      // Si une catégorie est spécifiée, filtrer
      if (category != null && category != 'Pour toi' && category != 'all') {
        query = query.where('categories', arrayContains: category.toLowerCase());
      }

      final snapshot = await query.limit(500).get();
      final allProducts = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      print('📦 ${allProducts.length} produits chargés depuis Firebase');

      if (allProducts.isEmpty) {
        print('⚠️ Firebase vide, chargement depuis assets...');
        allProducts.addAll(await _loadFallbackProducts());
        print('📦 ${allProducts.length} produits chargés depuis assets');
      }

      if (allProducts.isEmpty) {
        print('⚠️ Assets vides aussi, utiliser des produits hardcodés');
        return _getFallbackProducts(count);
      }

      // Scorer et trier les produits par pertinence
      final scoredProducts = allProducts.map((product) {
        final score = _calculateMatchScore(product, searchTags, userTags);
        return {
          ...product,
          '_matchScore': score,
        };
      }).toList();

      // Trier par score décroissant
      scoredProducts.sort((a, b) => (b['_matchScore'] as double).compareTo(a['_matchScore'] as double));

      // Prendre les N meilleurs + ajouter un peu de randomisation pour varier
      final topProducts = scoredProducts.take(count * 2).toList();
      topProducts.shuffle(Random(DateTime.now().millisecondsSinceEpoch));

      final selectedProducts = topProducts.take(count).toList();

      // Retirer le score de matching avant de retourner
      for (var product in selectedProducts) {
        product.remove('_matchScore');
      }

      print('✅ ${selectedProducts.length} produits matchés et retournés');
      return selectedProducts;
    } catch (e) {
      print('❌ Erreur matching produits: $e');
      // En cas d'erreur, retourner des produits par défaut
      return _getFallbackProducts(count);
    }
  }

  /// Convertit les tags utilisateur en tags de recherche
  static Set<String> _convertUserTagsToSearchTags(Map<String, dynamic> userTags) {
    final tags = <String>{};

    // Âge
    final age = userTags['age'] ?? userTags['recipientAge'];
    if (age != null) {
      final ageInt = age is int ? age : int.tryParse(age.toString()) ?? 25;
      if (ageInt < 18) {
        tags.addAll(['enfant', 'jeune', 'ado']);
      } else if (ageInt < 30) {
        tags.addAll(['jeune-adulte', '20-30ans', 'moderne']);
      } else if (ageInt < 50) {
        tags.addAll(['adulte', '30-50ans']);
      } else {
        tags.addAll(['senior', '50+']);
      }
    }

    // Genre
    final gender = userTags['gender'] ?? userTags['recipientGender'];
    if (gender != null) {
      final genderStr = gender.toString().toLowerCase();
      if (genderStr.contains('homme') || genderStr.contains('male')) {
        tags.add('homme');
      } else if (genderStr.contains('femme') || genderStr.contains('female')) {
        tags.add('femme');
      } else {
        tags.add('unisexe');
      }
    }

    // Centres d'intérêt
    final interests = userTags['interests'] ?? userTags['hobbies'];
    if (interests != null) {
      final interestsList = interests is List ? interests : [interests];
      for (var interest in interestsList) {
        tags.add(interest.toString().toLowerCase());
      }
    }

    // Style
    final style = userTags['style'];
    if (style != null) {
      tags.add(style.toString().toLowerCase());
    }

    // Types de cadeaux
    final giftTypes = userTags['giftTypes'];
    if (giftTypes != null) {
      final typesList = giftTypes is List ? giftTypes : [giftTypes];
      for (var type in typesList) {
        tags.add(type.toString().toLowerCase());
      }
    }

    // Budget
    final budget = userTags['budget'];
    if (budget != null) {
      final budgetStr = budget.toString().toLowerCase();
      if (budgetStr.contains('50') || budgetStr.contains('moins')) {
        tags.add('budget_0-50');
      } else if (budgetStr.contains('100')) {
        tags.add('budget_50-100');
      } else if (budgetStr.contains('200')) {
        tags.add('budget_100-200');
      } else {
        tags.add('budget_200+');
      }
    }

    // Relation
    final relation = userTags['relation'] ?? userTags['recipient'];
    if (relation != null) {
      tags.add(relation.toString().toLowerCase());
    }

    return tags;
  }

  /// Calcule le score de matching entre un produit et les tags recherchés
  static double _calculateMatchScore(
    Map<String, dynamic> product,
    Set<String> searchTags,
    Map<String, dynamic> userTags,
  ) {
    double score = 0.0;

    // Tags du produit
    final productTags = (product['tags'] as List?)?.cast<String>() ?? [];
    final productCategories = (product['categories'] as List?)?.cast<String>() ?? [];
    final allProductTags = {...productTags, ...productCategories};

    // Matching exact des tags (poids fort)
    for (var searchTag in searchTags) {
      for (var productTag in allProductTags) {
        if (productTag.toLowerCase().contains(searchTag) || searchTag.contains(productTag.toLowerCase())) {
          score += 10.0;
        }
      }
    }

    // Matching du budget
    final budget = userTags['budget'];
    final price = product['price'];
    if (budget != null && price != null) {
      final priceValue = price is int ? price : (price is double ? price.toInt() : 0);
      final budgetStr = budget.toString().toLowerCase();

      bool budgetMatch = false;
      if (budgetStr.contains('50') && priceValue <= 50) budgetMatch = true;
      if (budgetStr.contains('100') && priceValue >= 50 && priceValue <= 100) budgetMatch = true;
      if (budgetStr.contains('200') && priceValue >= 100 && priceValue <= 200) budgetMatch = true;

      if (budgetMatch) {
        score += 15.0; // Le budget est très important
      }
    }

    // Bonus pour les produits populaires
    final popularity = product['popularity'] as int? ?? 0;
    score += popularity * 0.5;

    // Bonus aléatoire léger pour varier
    score += Random().nextDouble() * 2.0;

    return score;
  }

  /// Charge les produits depuis le fichier JSON des assets
  static Future<List<Map<String, dynamic>>> _loadFallbackProducts() async {
    if (_cachedFallbackProducts != null) {
      return _cachedFallbackProducts!;
    }

    try {
      final jsonString = await rootBundle.loadString('assets/jsons/fallback_products.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _cachedFallbackProducts = jsonList.cast<Map<String, dynamic>>();
      return _cachedFallbackProducts!;
    } catch (e) {
      print('❌ Erreur chargement assets: $e');
      return [];
    }
  }

  /// Produits de secours hardcodés en cas d'erreur totale
  static List<Map<String, dynamic>> _getFallbackProducts(int count) {
    final fallbackProducts = [
      {
        'id': 1,
        'name': 'Écouteurs sans fil Premium',
        'brand': 'TechSound',
        'price': 79,
        'description': 'Écouteurs Bluetooth avec réduction de bruit active',
        'image': 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=400',
        'url': 'https://www.amazon.fr/s?k=écouteurs+sans+fil',
        'source': 'Amazon',
        'tags': ['tech', 'audio', 'moderne'],
        'categories': ['tech'],
      },
      {
        'id': 2,
        'name': 'Coffret de soins visage bio',
        'brand': 'NatureBelle',
        'price': 45,
        'description': 'Coffret complet de soins naturels pour le visage',
        'image': 'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=400',
        'url': 'https://www.sephora.fr',
        'source': 'Sephora',
        'tags': ['beauté', 'bio', 'soin'],
        'categories': ['beauty'],
      },
      {
        'id': 3,
        'name': 'Montre connectée Sport',
        'brand': 'FitTime',
        'price': 129,
        'description': 'Montre intelligente avec suivi d\'activité',
        'image': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400',
        'url': 'https://www.amazon.fr/s?k=montre+connectée',
        'source': 'Amazon',
        'tags': ['tech', 'sport', 'fitness'],
        'categories': ['tech'],
      },
    ];

    // Répéter pour atteindre le nombre demandé
    final result = <Map<String, dynamic>>[];
    while (result.length < count) {
      result.addAll(fallbackProducts.map((p) => Map<String, dynamic>.from(p)));
    }

    return result.take(count).toList();
  }
}
