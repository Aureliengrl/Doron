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
    List<dynamic>? excludeProductIds, // Pour refresh intelligent
  }) async {
    try {
      print('🎯 Matching produits pour tags: ${userTags.keys.join(", ")}');
      print('📋 User tags complets: $userTags');

      // Convertir les réponses utilisateur en tags de recherche
      final searchTags = _convertUserTagsToSearchTags(userTags);
      print('🏷️ Tags de recherche: $searchTags');

      // 🎯 FILTRAGE FIREBASE PAR SEXE (critère le plus discriminant)
      Query<Map<String, dynamic>> query = _firestore.collection('products');

      final gender = userTags['gender'] ?? userTags['recipientGender'];
      String? genderFilter;
      if (gender != null) {
        final genderStr = gender.toString().toLowerCase();
        if (genderStr.contains('homme') || genderStr.contains('male')) {
          genderFilter = 'homme';
        } else if (genderStr.contains('femme') || genderStr.contains('female')) {
          genderFilter = 'femme';
        }
      }

      // Filtrer par sexe SI disponible (réduit drastiquement le bruit)
      if (genderFilter != null) {
        query = query.where('tags', arrayContains: genderFilter);
        print('🎯 Filtrage Firebase par sexe: $genderFilter');
      }

      // Si une catégorie est spécifiée, filtrer aussi
      if (category != null && category != 'Pour toi' && category != 'all') {
        // Si déjà un filtre sexe, on ne peut pas faire 2 arrayContains
        // On va donc charger plus et filtrer côté client
        if (genderFilter == null) {
          query = query.where('categories', arrayContains: category.toLowerCase());
          print('🎯 Filtrage Firebase par catégorie: $category');
        }
      }

      // Charger 1000 produits (plus large pour avoir de la variété)
      final snapshot = await query.limit(1000).get();
      var allProducts = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      print('📦 ${allProducts.length} produits chargés depuis Firebase');

      // Filtrer par catégorie côté client si nécessaire
      if (category != null && category != 'Pour toi' && category != 'all' && genderFilter != null) {
        final categoryLower = category.toLowerCase();
        allProducts = allProducts.where((product) {
          final categories = (product['categories'] as List?)?.cast<String>() ?? [];
          return categories.any((cat) => cat.toLowerCase() == categoryLower);
        }).toList();
        print('📦 ${allProducts.length} produits après filtre catégorie côté client');
      }

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

      // 🔥 FILTRER PAR SCORE MINIMUM (éliminer produits trop génériques)
      // Seuil : 20 points minimum (au moins un tag majeur doit matcher)
      final relevantProducts = scoredProducts.where((p) => (p['_matchScore'] as double) >= 20.0).toList();

      print('📊 ${relevantProducts.length} produits pertinents (score ≥ 20) sur ${scoredProducts.length}');

      if (relevantProducts.isEmpty) {
        print('⚠️ Aucun produit pertinent trouvé, relaxation du seuil...');
        relevantProducts.addAll(scoredProducts);
      }

      // Trier par score décroissant
      relevantProducts.sort((a, b) => (b['_matchScore'] as double).compareTo(a['_matchScore'] as double));

      // 🎲 SHUFFLE PARTIEL pour diversité (mélanger les produits de score similaire)
      // On garde le top 30% intact, mais on shuffle le reste pour éviter toujours les mêmes
      final topCount = (relevantProducts.length * 0.3).ceil();
      final topProducts = relevantProducts.take(topCount).toList();
      final middleProducts = relevantProducts.skip(topCount).toList();

      // Shuffle les produits du milieu avec seed basé sur timestamp
      final random = Random(DateTime.now().millisecondsSinceEpoch);
      middleProducts.shuffle(random);

      final shuffledProducts = [...topProducts, ...middleProducts];

      // 🎯 DÉDUPLICATION ET DIVERSITÉ DES MARQUES (max 20% d'une même marque)
      final selectedProducts = <Map<String, dynamic>>[];
      final brandCounts = <String, int>{};
      final categoryCounts = <String, int>{}; // Diversité des catégories
      final maxPerBrand = (count * 0.2).ceil(); // 20% max par marque
      final maxPerCategory = (count * 0.3).ceil(); // 30% max par catégorie
      final seenProductIds = <dynamic>{};
      final seenProductNames = <String>{}; // Déduplication par nom normalisé
      final excludedIds = excludeProductIds?.toSet() ?? {};

      print('🔄 Exclusion de ${excludedIds.length} produits déjà vus');

      for (var product in shuffledProducts) {
        if (selectedProducts.length >= count) break;

        final productId = product['id'];
        final brand = product['brand']?.toString() ?? 'Unknown';
        final productName = product['name']?.toString() ?? '';
        final normalizedName = _normalizeProductName(productName);

        // Extraire la catégorie principale
        final categories = (product['categories'] as List?)?.cast<String>() ?? [];
        final mainCategory = categories.isNotEmpty ? categories.first : 'Autre';

        // 1️⃣ Vérifier exclusion (produits déjà vus)
        if (excludedIds.contains(productId)) {
          continue;
        }

        // 2️⃣ Vérifier dédupli par ID
        if (seenProductIds.contains(productId)) {
          continue;
        }

        // 3️⃣ Vérifier dédupli par nom normalisé (doublons visuels)
        if (seenProductNames.contains(normalizedName)) {
          continue;
        }

        // 4️⃣ Vérifier limite par marque (max 20%)
        final currentBrandCount = brandCounts[brand] ?? 0;
        if (currentBrandCount >= maxPerBrand) {
          continue; // Skip, trop de produits de cette marque
        }

        // 5️⃣ Vérifier limite par catégorie (max 30%)
        final currentCategoryCount = categoryCounts[mainCategory] ?? 0;
        if (currentCategoryCount >= maxPerCategory) {
          continue; // Skip, trop de produits de cette catégorie
        }

        // ✅ Ajouter le produit
        selectedProducts.add(product);
        seenProductIds.add(productId);
        seenProductNames.add(normalizedName);
        brandCounts[brand] = currentBrandCount + 1;
        categoryCounts[mainCategory] = currentCategoryCount + 1;
      }

      // Retirer le score de matching avant de retourner
      for (var product in selectedProducts) {
        product.remove('_matchScore');
      }

      print('✅ ${selectedProducts.length} produits matchés et retournés');
      print('📊 Diversité des marques: ${brandCounts.length} marques différentes');
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

    // Centres d'intérêt (normalisés pour meilleur matching)
    final interests = userTags['interests'] ?? userTags['hobbies'];
    if (interests != null) {
      final interestsList = interests is List ? interests : [interests];
      for (var interest in interestsList) {
        final normalized = _normalizeTag(interest.toString());
        tags.add(normalized);
        // Garder aussi l'original pour compatibilité
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
  /// Priorise SEXE et ÂGE (critères principaux pour personnalisation)
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

    // 🎯 PRIORITÉ 1: SEXE (poids très fort - 40 points max)
    final gender = userTags['gender'] ?? userTags['recipientGender'];
    if (gender != null) {
      final genderStr = gender.toString().toLowerCase();
      bool genderMatch = false;

      if (genderStr.contains('homme') || genderStr.contains('male')) {
        genderMatch = allProductTags.any((tag) => tag.toLowerCase() == 'homme');
      } else if (genderStr.contains('femme') || genderStr.contains('female')) {
        genderMatch = allProductTags.any((tag) => tag.toLowerCase() == 'femme');
      }

      if (genderMatch) {
        score += 40.0; // Bonus énorme pour match sexe
      }

      // Bonus pour produits unisexes (plus faible)
      if (allProductTags.any((tag) => tag.toLowerCase() == 'unisexe')) {
        score += 15.0;
      }
    }

    // 🎯 PRIORITÉ 2: ÂGE (poids très fort - 35 points max)
    final age = userTags['age'] ?? userTags['recipientAge'];
    if (age != null) {
      final ageInt = age is int ? age : int.tryParse(age.toString()) ?? 25;
      String ageGroup = '';

      if (ageInt < 18) {
        ageGroup = 'enfant';
      } else if (ageInt < 30) {
        ageGroup = '20-30ans';
      } else if (ageInt < 50) {
        ageGroup = '30-50ans';
      } else {
        ageGroup = '50+';
      }

      // Match exact de la tranche d'âge
      if (allProductTags.any((tag) => tag.toLowerCase() == ageGroup)) {
        score += 35.0; // Bonus énorme pour match âge
      }
    }

    // 🎯 CRITÈRE 3: Centres d'intérêt / Hobbies (20 points max)
    final interests = userTags['interests'] ?? userTags['hobbies'] ?? userTags['recipientHobbies'];
    if (interests != null) {
      final interestsList = interests is List ? interests : [interests];
      for (var interest in interestsList) {
        final normalizedInterest = _normalizeTag(interest.toString());
        // Vérifier match exact ou partiel avec tags normalisés
        final hasMatch = allProductTags.any((tag) {
          final normalizedTag = _normalizeTag(tag);
          return normalizedTag == normalizedInterest ||
                 normalizedTag.contains(normalizedInterest) ||
                 normalizedInterest.contains(normalizedTag);
        });
        if (hasMatch) {
          score += 20.0;
          break; // Un seul bonus par produit pour éviter surpondération
        }
      }
    }

    // 🎯 CRITÈRE 4: Budget (15 points)
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
        score += 15.0;
      }
    }

    // 🎯 CRITÈRE 5: Style / Catégories (10 points)
    final style = userTags['style'];
    if (style != null && allProductTags.any((tag) => tag.toLowerCase() == style.toString().toLowerCase())) {
      score += 10.0;
    }

    // 📈 TENDANCES: Popularité (facteur de 0.3 - max ~30 points pour produit à 99)
    final popularity = product['popularity'] as int? ?? 0;
    score += popularity * 0.3;

    // 🎲 Variation aléatoire légère (pour éviter ordre identique)
    score += Random().nextDouble() * 3.0;

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

  /// Génère des sections thématiques pour la page d'accueil
  /// Retourne une liste de sections avec titre et produits
  static Future<List<Map<String, dynamic>>> getHomeSections({
    required Map<String, dynamic> userTags,
  }) async {
    final sections = <Map<String, dynamic>>[];

    // Extraire sexe et âge de l'utilisateur
    final gender = userTags['gender'] ?? userTags['recipientGender'];
    final age = userTags['age'] ?? userTags['recipientAge'];
    final ageInt = age is int ? age : int.tryParse(age.toString()) ?? 25;

    String genderLabel = 'Unisexe';
    String ageLabel = '';

    if (gender != null) {
      final genderStr = gender.toString().toLowerCase();
      if (genderStr.contains('homme') || genderStr.contains('male')) {
        genderLabel = 'Homme';
      } else if (genderStr.contains('femme') || genderStr.contains('female')) {
        genderLabel = 'Femme';
      }
    }

    if (ageInt < 18) {
      ageLabel = 'Ado';
    } else if (ageInt < 30) {
      ageLabel = '18–25';
    } else if (ageInt < 50) {
      ageLabel = '30–50';
    } else {
      ageLabel = '50+';
    }

    // Section 1: Tendances personnalisées (60% relevance)
    final trendingPersonalizedProducts = await getPersonalizedProducts(
      userTags: userTags,
      count: 10,
    );
    sections.add({
      'title': '🔥 Tendance $genderLabel $ageLabel',
      'subtitle': 'Les must-have du moment pour toi',
      'products': trendingPersonalizedProducts,
      'filter': {'gender': genderLabel, 'age': ageLabel},
    });

    // Section 2: Top Tech (catégorie spécifique)
    final techProducts = await getPersonalizedProducts(
      userTags: {...userTags},
      count: 10,
      category: 'tech',
    );
    sections.add({
      'title': '📱 Top Tech $ageLabel',
      'subtitle': 'Les gadgets qui font la différence',
      'products': techProducts,
      'filter': {'category': 'tech', 'age': ageLabel},
    });

    // Section 3: Beauté/Mode selon le sexe
    if (genderLabel == 'Femme') {
      final beautyProducts = await getPersonalizedProducts(
        userTags: {...userTags},
        count: 10,
        category: 'beauty',
      );
      sections.add({
        'title': '💄 Beauté qui cartonne',
        'subtitle': 'Les produits beauté tendance',
        'products': beautyProducts,
        'filter': {'category': 'beauty'},
      });
    } else if (genderLabel == 'Homme') {
      final fashionProducts = await getPersonalizedProducts(
        userTags: {...userTags},
        count: 10,
        category: 'fashion',
      );
      sections.add({
        'title': '👔 Mode Homme Tendance',
        'subtitle': 'Le style qui fait mouche',
        'products': fashionProducts,
        'filter': {'category': 'fashion'},
      });
    }

    // Section 4: Sport du moment (si pertinent)
    final sportProducts = await getPersonalizedProducts(
      userTags: {...userTags},
      count: 10,
      category: 'sport',
    );
    if (sportProducts.length >= 5) {
      sections.add({
        'title': '⚽ Sport du moment',
        'subtitle': 'Pour rester actif',
        'products': sportProducts,
        'filter': {'category': 'sport'},
      });
    }

    // Section 5: Maison & Déco
    final homeProducts = await getPersonalizedProducts(
      userTags: {...userTags},
      count: 10,
      category: 'home',
    );
    if (homeProducts.length >= 5) {
      sections.add({
        'title': '🏠 Maison Cosy',
        'subtitle': 'Pour un intérieur stylé',
        'products': homeProducts,
        'filter': {'category': 'home'},
      });
    }

    // Section 6: Coups de cœur budget (prix < 50€)
    final budgetTags = {...userTags, 'budget': 'Moins de 50€'};
    final budgetProducts = await getPersonalizedProducts(
      userTags: budgetTags,
      count: 10,
    );
    sections.add({
      'title': '💝 Petits prix, grandes idées',
      'subtitle': 'Moins de 50€',
      'products': budgetProducts,
      'filter': {'maxPrice': 50},
    });

    print('✅ ${sections.length} sections générées pour l\'accueil');
    return sections;
  }

  /// Normalise un tag pour le matching (gère pluriels, synonymes, accents)
  /// Ex: "sports" → "sport", "fitness" → "sport", "beauté" → "beaute"
  static String _normalizeTag(String tag) {
    var normalized = tag
        .toLowerCase()
        .trim()
        // Retirer les accents
        .replaceAll(RegExp(r'[àáâãäå]'), 'a')
        .replaceAll(RegExp(r'[èéêë]'), 'e')
        .replaceAll(RegExp(r'[ìíîï]'), 'i')
        .replaceAll(RegExp(r'[òóôõö]'), 'o')
        .replaceAll(RegExp(r'[ùúûü]'), 'u')
        .replaceAll(RegExp(r'[ýÿ]'), 'y')
        .replaceAll('ç', 'c')
        .replaceAll('ñ', 'n');

    // Dictionnaire de synonymes et mapping pluriel → singulier
    final synonymMap = {
      // Sport & Fitness
      'sports': 'sport',
      'fitness': 'sport',
      'musculation': 'sport',
      'gym': 'sport',
      'running': 'sport',
      'yoga': 'sport',

      // Tech
      'technologie': 'tech',
      'high-tech': 'tech',
      'hightech': 'tech',
      'gadgets': 'tech',
      'gadget': 'tech',

      // Mode
      'mode': 'fashion',
      'vetements': 'fashion',
      'vetement': 'fashion',
      'style': 'fashion',

      // Beauté
      'beaute': 'beauty',
      'cosmetique': 'beauty',
      'cosmetiques': 'beauty',
      'maquillage': 'beauty',
      'soin': 'beauty',
      'soins': 'beauty',

      // Maison
      'maison': 'home',
      'deco': 'home',
      'decoration': 'home',
      'interieur': 'home',

      // Gaming
      'jeux': 'gaming',
      'jeu': 'gaming',
      'gaming': 'gaming',
      'gamer': 'gaming',
      'console': 'gaming',
      'consoles': 'gaming',

      // Lecture
      'lecture': 'book',
      'livres': 'book',
      'livre': 'book',
      'reading': 'book',

      // Musique
      'musique': 'music',
      'audio': 'music',
      'son': 'music',

      // Cuisine
      'cuisine': 'cooking',
      'culinaire': 'cooking',
      'gastronomie': 'cooking',

      // Art
      'art': 'art',
      'artistique': 'art',
      'creation': 'art',
      'creatif': 'art',

      // Voyage
      'voyage': 'travel',
      'voyages': 'travel',
      'aventure': 'travel',
      'aventures': 'travel',
    };

    return synonymMap[normalized] ?? normalized;
  }

  /// Normalise un nom de produit pour détecter les doublons visuels
  /// Retire les espaces, ponctuation, accents, convertit en minuscules
  static String _normalizeProductName(String name) {
    return name
        .toLowerCase()
        .trim()
        // Retirer les accents
        .replaceAll(RegExp(r'[àáâãäå]'), 'a')
        .replaceAll(RegExp(r'[èéêë]'), 'e')
        .replaceAll(RegExp(r'[ìíîï]'), 'i')
        .replaceAll(RegExp(r'[òóôõö]'), 'o')
        .replaceAll(RegExp(r'[ùúûü]'), 'u')
        .replaceAll(RegExp(r'[ýÿ]'), 'y')
        .replaceAll('ç', 'c')
        .replaceAll('ñ', 'n')
        // Retirer les caractères spéciaux et espaces multiples
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
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
