import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '/utils/app_logger.dart';

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
      AppLogger.info('🎯 Matching produits pour tags: ${userTags.keys.join(", ")}', 'Matching');
      AppLogger.debug('📋 User tags complets: $userTags', 'Matching');
      AppLogger.info('🚫 Exclusion de ${excludeProductIds?.length ?? 0} produits', 'Matching');

      // Convertir les réponses utilisateur en tags de recherche
      final searchTags = _convertUserTagsToSearchTags(userTags);
      AppLogger.debug('🏷️ Tags de recherche: $searchTags', 'Matching');

      // 🎯 FILTRAGE FIREBASE PAR SEXE (critère le plus discriminant)
      // Utiliser la collection 'gifts' (nouvelle) avec fallback vers 'products' (ancienne)
      Query<Map<String, dynamic>> query = _firestore.collection('gifts');
      AppLogger.firebase('🎁 Chargement depuis collection Firebase: gifts');

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

      // 🔥 DÉSACTIVER TEMPORAIREMENT LE FILTRE SEXE POUR DEBUG
      // Le filtre peut être trop restrictif si les tags ne sont pas bons
      // if (genderFilter != null) {
      //   query = query.where('tags', arrayContains: genderFilter);
      //   AppLogger.firebase('🎯 Filtrage Firebase par sexe: $genderFilter');
      // }
      AppLogger.warning('⚠️ FILTRE SEXE DÉSACTIVÉ POUR DEBUG - Chargement de TOUS les produits Firebase', 'Matching');

      // 🔥 DÉSACTIVER AUSSI LE FILTRE CATÉGORIE POUR DEBUG
      // if (category != null && category != 'Pour toi' && category != 'all') {
      //   if (genderFilter == null) {
      //     query = query.where('categories', arrayContains: category.toLowerCase());
      //     AppLogger.firebase('🎯 Filtrage Firebase par catégorie: $category');
      //   }
      // }
      AppLogger.warning('⚠️ FILTRE CATÉGORIE AUSSI DÉSACTIVÉ - Chargement brut complet', 'Matching');

      // Charger 2000 produits (augmenté pour plus de variété)
      var snapshot = await query.limit(2000).get();
      var allProducts = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      AppLogger.firebase('📦 ${allProducts.length} produits chargés depuis Firebase');

      // 🔍 DEBUG CRITIQUE: Afficher les 3 premiers produits pour vérifier structure
      if (allProducts.isNotEmpty) {
        AppLogger.debug('🔍 SAMPLE PRODUIT 1: ${allProducts.first}', 'Matching');
        if (allProducts.length > 1) {
          AppLogger.debug('🔍 SAMPLE PRODUIT 2: ${allProducts[1]}', 'Matching');
        }
      } else {
        AppLogger.error('⚠️ COLLECTION GIFTS EST VIDE - Aucun produit trouvé !', 'Matching', null);
      }

      // 🔥 RETRY SANS FILTRE si Firebase retourne 0 (le filtre sexe peut être trop restrictif)
      if (allProducts.isEmpty && genderFilter != null) {
        AppLogger.warning('Aucun produit avec filtre sexe, retry SANS filtre...', 'Matching');
        query = _firestore.collection('gifts');
        snapshot = await query.limit(2000).get();
        allProducts = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
        AppLogger.firebase('📦 ${allProducts.length} produits chargés depuis Firebase gifts SANS filtre');
      }

      // 🔄 FALLBACK vers collection 'products' si 'gifts' est vide
      if (allProducts.isEmpty) {
        AppLogger.warning('Collection gifts vide, fallback vers products...', 'Matching');
        query = _firestore.collection('products');
        snapshot = await query.limit(2000).get();
        allProducts = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
        AppLogger.firebase('📦 ${allProducts.length} produits chargés depuis Firebase products (fallback)');
      }

      // Filtrer par catégorie côté client si nécessaire
      if (category != null && category != 'Pour toi' && category != 'all' && genderFilter != null) {
        final categoryLower = category.toLowerCase();
        allProducts = allProducts.where((product) {
          final categories = (product['categories'] as List?)?.cast<String>() ?? [];
          return categories.any((cat) => cat.toLowerCase() == categoryLower);
        }).toList();
        AppLogger.info('📦 ${allProducts.length} produits après filtre catégorie côté client', 'Matching');
      }

      if (allProducts.isEmpty) {
        AppLogger.warning('Firebase vide, chargement depuis assets (fallback_products.json)...', 'Matching');
        allProducts.addAll(await _loadFallbackProducts());
        AppLogger.info('📦 ${allProducts.length} produits chargés depuis assets/jsons/fallback_products.json', 'Matching');
      }

      if (allProducts.isEmpty) {
        AppLogger.warning('Assets vides aussi, utiliser des produits hardcodés (3 produits répétés)', 'Matching');
        return _getFallbackProducts(count);
      }

      AppLogger.info('✨ SOURCE DES PRODUITS: ${allProducts.length} produits disponibles pour le scoring', 'Matching');

      // Scorer et trier les produits par pertinence
      final scoredProducts = allProducts.map((product) {
        final score = _calculateMatchScore(product, searchTags, userTags);
        return {
          ...product,
          '_matchScore': score,
        };
      }).toList();

      // 🎯 PAS DE SEUIL MINIMUM - On prend les meilleurs produits peu importe leur score
      // Cela garantit qu'on a toujours des produits variés même si le matching n'est pas parfait
      AppLogger.info('📊 ${scoredProducts.length} produits disponibles pour sélection', 'Matching');

      // Trier par score décroissant pour avoir les meilleurs en premier
      scoredProducts.sort((a, b) => (b['_matchScore'] as double).compareTo(a['_matchScore'] as double));

      // Garder tous les produits (pas de filtrage par score)
      var relevantProducts = scoredProducts;

      // 🎲 SHUFFLE PARTIEL AMÉLIORÉ pour VRAIMENT éviter les mêmes produits
      // On garde le top 20% intact (meilleurs scores), mais on shuffle 80% restants
      final topCount = (relevantProducts.length * 0.2).ceil();
      final topProducts = relevantProducts.take(topCount).toList();
      final middleProducts = relevantProducts.skip(topCount).toList();

      // Shuffle les produits du milieu avec seed basé sur timestamp + microsecond pour plus de variation
      final random = Random(DateTime.now().microsecondsSinceEpoch);
      middleProducts.shuffle(random);

      // 🎯 SHUFFLE TOTAL pour vraiment varier (on mélange même le top pour plus de variété)
      final shuffledProducts = [...topProducts, ...middleProducts];
      shuffledProducts.shuffle(random);

      AppLogger.debug('🎲 Shuffle effectué: top ${topCount} produits + ${middleProducts.length} produits mélangés', 'Matching');

      // 🎯 DÉDUPLICATION ET DIVERSITÉ DES MARQUES (max 20% d'une même marque)
      final selectedProducts = <Map<String, dynamic>>[];
      final brandCounts = <String, int>{};
      final categoryCounts = <String, int>{}; // Diversité des catégories
      final maxPerBrand = (count * 0.2).ceil(); // 20% max par marque
      final maxPerCategory = (count * 0.3).ceil(); // 30% max par catégorie
      final seenProductIds = <dynamic>{};
      final seenProductNames = <String>{}; // Déduplication par nom normalisé
      final excludedIds = excludeProductIds?.toSet() ?? {};

      // ⚠️ DÉSACTIVER TEMPORAIREMENT LE CACHE pour garantir de la variété
      // Le cache peut exclure TOUS les produits disponibles
      AppLogger.info('🔄 Exclusion désactivée pour garantir variété (${excludedIds.length} produits ignorés)', 'Matching');
      AppLogger.debug('🎯 Max par marque: $maxPerBrand produits (20%)', 'Matching');
      AppLogger.debug('🎯 Max par catégorie: $maxPerCategory produits (30%)', 'Matching');

      for (var product in shuffledProducts) {
        if (selectedProducts.length >= count) break;

        final productId = product['id'];
        final brand = product['brand']?.toString() ?? 'Unknown';
        final productName = product['name']?.toString() ?? '';
        final normalizedName = _normalizeProductName(productName);

        // Extraire la catégorie principale
        final categories = (product['categories'] as List?)?.cast<String>() ?? [];
        final mainCategory = categories.isNotEmpty ? categories.first : 'Autre';

        // 1️⃣ Vérifier exclusion (DÉSACTIVÉ pour garantir variété)
        // if (excludedIds.contains(productId)) {
        //   continue;
        // }

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

      AppLogger.success('${selectedProducts.length} produits matchés et retournés', 'Matching');
      AppLogger.info('📊 Diversité des marques: ${brandCounts.length} marques différentes', 'Matching');
      AppLogger.debug('📊 Répartition marques: ${brandCounts.entries.map((e) => '${e.key}: ${e.value}').take(10).join(", ")}', 'Matching');
      AppLogger.debug('📊 Répartition catégories: ${categoryCounts.entries.map((e) => '${e.key}: ${e.value}').join(", ")}', 'Matching');
      return selectedProducts;
    } catch (e) {
      AppLogger.error('Erreur matching produits', 'Matching', e);
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
    // Retourner cache si disponible
    final cached = _cachedFallbackProducts;
    if (cached != null) {
      return cached;
    }

    try {
      final jsonString = await rootBundle.loadString('assets/jsons/fallback_products.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _cachedFallbackProducts = jsonList.cast<Map<String, dynamic>>();
      return _cachedFallbackProducts ?? []; // Protection supplémentaire
    } catch (e) {
      AppLogger.error('Erreur chargement assets', 'Matching', e);
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

    AppLogger.success('${sections.length} sections générées pour l\'accueil', 'Matching');
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
      // TECH (10 produits)
      {'id': 1, 'name': 'AirPods Pro 2ème génération', 'brand': 'Apple', 'price': 279, 'description': 'Écouteurs sans fil avec réduction de bruit active', 'image': 'https://images.unsplash.com/photo-1606841837239-c5a1a4a07af7?w=400', 'url': 'https://www.apple.com/fr/airpods-pro', 'source': 'Apple', 'tags': ['tech', 'audio', 'homme', 'femme'], 'categories': ['tech']},
      {'id': 2, 'name': 'iPad Air', 'brand': 'Apple', 'price': 699, 'description': 'Tablette puissante pour le travail et les loisirs', 'image': 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=400', 'url': 'https://www.apple.com/fr/ipad-air', 'source': 'Apple', 'tags': ['tech', 'tablet', 'homme', 'femme'], 'categories': ['tech']},
      {'id': 3, 'name': 'Enceinte Bluetooth Marshall Emberton', 'brand': 'Marshall', 'price': 169, 'description': 'Enceinte portable au son puissant', 'image': 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=400', 'url': 'https://www.marshallheadphones.com', 'source': 'Marshall', 'tags': ['tech', 'audio', 'musique', 'homme', 'femme'], 'categories': ['tech']},
      {'id': 4, 'name': 'Dyson Airwrap', 'brand': 'Dyson', 'price': 499, 'description': 'Coiffeur multifonction intelligent', 'image': 'https://images.unsplash.com/photo-1522338140262-f46f5913618a?w=400', 'url': 'https://www.dyson.fr', 'source': 'Dyson', 'tags': ['tech', 'beauté', 'femme'], 'categories': ['beauty']},
      {'id': 5, 'name': 'Montre connectée Garmin Fenix', 'brand': 'Garmin', 'price': 599, 'description': 'Montre GPS multisport premium', 'image': 'https://images.unsplash.com/photo-1579586337278-3befd40fd17a?w=400', 'url': 'https://www.garmin.com/fr-FR', 'source': 'Garmin', 'tags': ['tech', 'sport', 'homme', 'femme'], 'categories': ['tech']},
      {'id': 6, 'name': 'Kindle Paperwhite', 'brand': 'Amazon', 'price': 149, 'description': 'Liseuse numérique avec écran haute résolution', 'image': 'https://images.unsplash.com/photo-1513475382585-d06e58bcb0e0?w=400', 'url': 'https://www.amazon.fr/kindle', 'source': 'Amazon', 'tags': ['tech', 'lecture', 'homme', 'femme'], 'categories': ['tech']},
      {'id': 7, 'name': 'Casque Sony WH-1000XM5', 'brand': 'Sony', 'price': 399, 'description': 'Casque audio avec meilleure réduction de bruit', 'image': 'https://images.unsplash.com/photo-1546435770-a3e426bf472b?w=400', 'url': 'https://www.sony.fr', 'source': 'Sony', 'tags': ['tech', 'audio', 'homme', 'femme'], 'categories': ['tech']},
      {'id': 8, 'name': 'GoPro Hero 12', 'brand': 'GoPro', 'price': 449, 'description': 'Caméra d\'action ultra performante', 'image': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', 'url': 'https://gopro.com/fr', 'source': 'GoPro', 'tags': ['tech', 'sport', 'aventure', 'homme', 'femme'], 'categories': ['tech']},
      {'id': 9, 'name': 'Instant Pot Duo', 'brand': 'Instant Pot', 'price': 129, 'description': 'Autocuiseur électrique multifonction', 'image': 'https://images.unsplash.com/photo-1556911220-bff31c812dba?w=400', 'url': 'https://www.instantpot.com', 'source': 'Amazon', 'tags': ['tech', 'cuisine', 'homme', 'femme'], 'categories': ['home']},
      {'id': 10, 'name': 'Ring Video Doorbell', 'brand': 'Ring', 'price': 99, 'description': 'Sonnette vidéo connectée', 'image': 'https://images.unsplash.com/photo-1558002038-1055907df827?w=400', 'url': 'https://www.ring.com', 'source': 'Amazon', 'tags': ['tech', 'maison', 'sécurité', 'homme', 'femme'], 'categories': ['home']},

      // MODE FEMME (10 produits)
      {'id': 11, 'name': 'Sac Polène Numéro Un Mini', 'brand': 'Polène', 'price': 390, 'description': 'Sac à main en cuir français', 'image': 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=400', 'url': 'https://www.polene-paris.com', 'source': 'Polène', 'tags': ['mode', 'luxe', 'femme'], 'categories': ['fashion']},
      {'id': 12, 'name': 'Pull cachemire Sézane', 'brand': 'Sézane', 'price': 135, 'description': 'Pull doux et élégant', 'image': 'https://images.unsplash.com/photo-1576871337632-b9aef4c17ab9?w=400', 'url': 'https://www.sezane.com', 'source': 'Sézane', 'tags': ['mode', 'élégant', 'femme'], 'categories': ['fashion']},
      {'id': 13, 'name': 'Escarpins Repetto', 'brand': 'Repetto', 'price': 395, 'description': 'Ballerines iconiques françaises', 'image': 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=400', 'url': 'https://www.repetto.com', 'source': 'Repetto', 'tags': ['mode', 'chaussures', 'femme'], 'categories': ['fashion']},
      {'id': 14, 'name': 'Robe Sandro midi', 'brand': 'Sandro', 'price': 295, 'description': 'Robe élégante pour toutes occasions', 'image': 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400', 'url': 'https://www.sandro-paris.com', 'source': 'Sandro', 'tags': ['mode', 'élégant', 'femme'], 'categories': ['fashion']},
      {'id': 15, 'name': 'Écharpe en soie Hermès', 'brand': 'Hermès', 'price': 450, 'description': 'Carré de soie iconique', 'image': 'https://images.unsplash.com/photo-1601924994987-69e26d50dc26?w=400', 'url': 'https://www.hermes.com', 'source': 'Hermès', 'tags': ['mode', 'luxe', 'accessoire', 'femme'], 'categories': ['fashion']},
      {'id': 16, 'name': 'Jean Levi\'s 501', 'brand': 'Levi\'s', 'price': 110, 'description': 'Jean iconique coupe droite', 'image': 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=400', 'url': 'https://www.levi.com', 'source': 'Levi\'s', 'tags': ['mode', 'casual', 'femme'], 'categories': ['fashion']},
      {'id': 17, 'name': 'Baskets Veja V-10', 'brand': 'Veja', 'price': 150, 'description': 'Sneakers écoresponsables', 'image': 'https://images.unsplash.com/photo-1600185365926-3a2ce3cdb9eb?w=400', 'url': 'https://www.veja-store.com', 'source': 'Veja', 'tags': ['mode', 'sport', 'éco', 'femme'], 'categories': ['fashion']},
      {'id': 18, 'name': 'Manteau & Other Stories', 'brand': '& Other Stories', 'price': 249, 'description': 'Manteau en laine élégant', 'image': 'https://images.unsplash.com/photo-1539533113208-f6df8cc8b543?w=400', 'url': 'https://www.stories.com', 'source': '& Other Stories', 'tags': ['mode', 'élégant', 'femme'], 'categories': ['fashion']},
      {'id': 19, 'name': 'Bijoux Messika', 'brand': 'Messika', 'price': 890, 'description': 'Collier diamant délicat', 'image': 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=400', 'url': 'https://www.messika.com', 'source': 'Messika', 'tags': ['mode', 'luxe', 'bijoux', 'femme'], 'categories': ['fashion']},
      {'id': 20, 'name': 'Lunettes Ray-Ban Aviator', 'brand': 'Ray-Ban', 'price': 169, 'description': 'Lunettes de soleil iconiques', 'image': 'https://images.unsplash.com/photo-1511499767150-a48a237f0083?w=400', 'url': 'https://www.ray-ban.com', 'source': 'Ray-Ban', 'tags': ['mode', 'accessoire', 'femme', 'homme'], 'categories': ['fashion']},

      // BEAUTÉ (10 produits)
      {'id': 21, 'name': 'Coffret Sephora Favorites', 'brand': 'Sephora', 'price': 65, 'description': 'Sélection des best-sellers beauté', 'image': 'https://images.unsplash.com/photo-1596755389378-c31d21fd1273?w=400', 'url': 'https://www.sephora.fr', 'source': 'Sephora', 'tags': ['beauté', 'soin', 'femme'], 'categories': ['beauty']},
      {'id': 22, 'name': 'Crème La Mer', 'brand': 'La Mer', 'price': 395, 'description': 'Crème hydratante de luxe', 'image': 'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=400', 'url': 'https://www.cremedelamer.fr', 'source': 'La Mer', 'tags': ['beauté', 'luxe', 'soin', 'femme'], 'categories': ['beauty']},
      {'id': 23, 'name': 'Parfum Diptyque Baies', 'brand': 'Diptyque', 'price': 68, 'description': 'Bougie parfumée iconique', 'image': 'https://images.unsplash.com/photo-1602874801007-3e6a0f1c9f8f?w=400', 'url': 'https://www.diptyqueparis.com', 'source': 'Diptyque', 'tags': ['beauté', 'parfum', 'maison', 'femme', 'homme'], 'categories': ['beauty']},
      {'id': 24, 'name': 'Palette Naked Urban Decay', 'brand': 'Urban Decay', 'price': 54, 'description': 'Palette de fards à paupières', 'image': 'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?w=400', 'url': 'https://www.urbandecay.fr', 'source': 'Sephora', 'tags': ['beauté', 'maquillage', 'femme'], 'categories': ['beauty']},
      {'id': 25, 'name': 'Rituals The Ritual of Sakura', 'brand': 'Rituals', 'price': 35, 'description': 'Coffret bain relaxant', 'image': 'https://images.unsplash.com/photo-1608248543803-ba4f8c70ae0b?w=400', 'url': 'https://www.rituals.com', 'source': 'Rituals', 'tags': ['beauté', 'bien-être', 'femme'], 'categories': ['beauty']},
      {'id': 26, 'name': 'Sérum The Ordinary', 'brand': 'The Ordinary', 'price': 18, 'description': 'Sérum anti-âge efficace', 'image': 'https://images.unsplash.com/photo-1620916297754-5c5c4928b983?w=400', 'url': 'https://www.sephora.fr', 'source': 'Sephora', 'tags': ['beauté', 'soin', 'femme'], 'categories': ['beauty']},
      {'id': 27, 'name': 'Brosse Tangle Teezer', 'brand': 'Tangle Teezer', 'price': 15, 'description': 'Brosse démêlante révolutionnaire', 'image': 'https://images.unsplash.com/photo-1522338140262-f46f5913618a?w=400', 'url': 'https://www.sephora.fr', 'source': 'Sephora', 'tags': ['beauté', 'cheveux', 'femme'], 'categories': ['beauty']},
      {'id': 28, 'name': 'Rouge à lèvres MAC', 'brand': 'MAC', 'price': 24, 'description': 'Rouge à lèvres mat longue tenue', 'image': 'https://images.unsplash.com/photo-1586495777744-4413f21062fa?w=400', 'url': 'https://www.maccosmetics.fr', 'source': 'MAC', 'tags': ['beauté', 'maquillage', 'femme'], 'categories': ['beauty']},
      {'id': 29, 'name': 'Coffret Aesop', 'brand': 'Aesop', 'price': 85, 'description': 'Trio de soins pour les mains', 'image': 'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=400', 'url': 'https://www.aesop.com', 'source': 'Aesop', 'tags': ['beauté', 'soin', 'luxe', 'femme', 'homme'], 'categories': ['beauty']},
      {'id': 30, 'name': 'Lush Bombes de bain', 'brand': 'Lush', 'price': 28, 'description': 'Set de bombes de bain colorées', 'image': 'https://images.unsplash.com/photo-1608248597279-f99d160bfcbc?w=400', 'url': 'https://www.lush.fr', 'source': 'Lush', 'tags': ['beauté', 'bien-être', 'femme'], 'categories': ['beauty']},

      // SPORT (10 produits)
      {'id': 31, 'name': 'Leggings Lululemon Align', 'brand': 'Lululemon', 'price': 108, 'description': 'Leggings de yoga ultra confortables', 'image': 'https://images.unsplash.com/photo-1506629082955-511b1aa562c8?w=400', 'url': 'https://www.lululemon.fr', 'source': 'Lululemon', 'tags': ['sport', 'yoga', 'femme'], 'categories': ['sports']},
      {'id': 32, 'name': 'Nike Air Max 90', 'brand': 'Nike', 'price': 140, 'description': 'Sneakers iconiques confortables', 'image': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400', 'url': 'https://www.nike.com/fr', 'source': 'Nike', 'tags': ['sport', 'mode', 'homme', 'femme'], 'categories': ['sports']},
      {'id': 33, 'name': 'Tapis de yoga Manduka', 'brand': 'Manduka', 'price': 129, 'description': 'Tapis de yoga professionnel', 'image': 'https://images.unsplash.com/photo-1601925260368-ae2f83cf8b7f?w=400', 'url': 'https://www.manduka.com', 'source': 'Manduka', 'tags': ['sport', 'yoga', 'bien-être', 'femme', 'homme'], 'categories': ['sports']},
      {'id': 34, 'name': 'Vélo d\'appartement Peloton', 'brand': 'Peloton', 'price': 1495, 'description': 'Vélo connecté avec cours en direct', 'image': 'https://images.unsplash.com/photo-1517649763962-0c623066013b?w=400', 'url': 'https://www.onepeloton.fr', 'source': 'Peloton', 'tags': ['sport', 'tech', 'fitness', 'homme', 'femme'], 'categories': ['sports']},
      {'id': 35, 'name': 'Gourde Stanley', 'brand': 'Stanley', 'price': 45, 'description': 'Gourde isotherme tendance', 'image': 'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=400', 'url': 'https://www.stanley1913.com', 'source': 'Stanley', 'tags': ['sport', 'accessoire', 'homme', 'femme'], 'categories': ['sports']},
      {'id': 36, 'name': 'Sac de sport Adidas', 'brand': 'Adidas', 'price': 49, 'description': 'Sac de sport spacieux', 'image': 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400', 'url': 'https://www.adidas.fr', 'source': 'Adidas', 'tags': ['sport', 'accessoire', 'homme', 'femme'], 'categories': ['sports']},
      {'id': 37, 'name': 'Raquette de tennis Wilson', 'brand': 'Wilson', 'price': 189, 'description': 'Raquette pour joueurs intermédiaires', 'image': 'https://images.unsplash.com/photo-1622163642998-1ea32b0bbc67?w=400', 'url': 'https://www.wilson.com', 'source': 'Decathlon', 'tags': ['sport', 'tennis', 'homme', 'femme'], 'categories': ['sports']},
      {'id': 38, 'name': 'Haltères réglables', 'brand': 'Bowflex', 'price': 399, 'description': 'Set d\'haltères ajustables', 'image': 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=400', 'url': 'https://www.bowflex.com', 'source': 'Amazon', 'tags': ['sport', 'fitness', 'maison', 'homme', 'femme'], 'categories': ['sports']},
      {'id': 39, 'name': 'Chaussures running On Cloud', 'brand': 'On', 'price': 149, 'description': 'Chaussures de course légères', 'image': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400', 'url': 'https://www.on-running.com', 'source': 'On', 'tags': ['sport', 'running', 'homme', 'femme'], 'categories': ['sports']},
      {'id': 40, 'name': 'Montre Garmin Forerunner', 'brand': 'Garmin', 'price': 249, 'description': 'Montre GPS pour coureurs', 'image': 'https://images.unsplash.com/photo-1508685096489-7aacd43bd3b1?w=400', 'url': 'https://www.garmin.com', 'source': 'Garmin', 'tags': ['sport', 'tech', 'running', 'homme', 'femme'], 'categories': ['sports']},

      // MAISON (10 produits)
      {'id': 41, 'name': 'Bougie Diptyque', 'brand': 'Diptyque', 'price': 68, 'description': 'Bougie parfumée de luxe', 'image': 'https://images.unsplash.com/photo-1602874801007-3e6a0f1c9f8f?w=400', 'url': 'https://www.diptyqueparis.com', 'source': 'Diptyque', 'tags': ['maison', 'luxe', 'déco', 'homme', 'femme'], 'categories': ['home']},
      {'id': 42, 'name': 'Plaid Zara Home', 'brand': 'Zara Home', 'price': 49, 'description': 'Plaid doux en laine', 'image': 'https://images.unsplash.com/photo-1584100936595-c0654b55a2e2?w=400', 'url': 'https://www.zarahome.com', 'source': 'Zara Home', 'tags': ['maison', 'cocooning', 'homme', 'femme'], 'categories': ['home']},
      {'id': 43, 'name': 'Diffuseur Muji', 'brand': 'Muji', 'price': 39, 'description': 'Diffuseur d\'huiles essentielles', 'image': 'https://images.unsplash.com/photo-1585128903991-829e55b36ca9?w=400', 'url': 'https://www.muji.eu', 'source': 'Muji', 'tags': ['maison', 'bien-être', 'homme', 'femme'], 'categories': ['home']},
      {'id': 44, 'name': 'Vaisselle blanc Ikea', 'brand': 'IKEA', 'price': 29, 'description': 'Service de table minimaliste', 'image': 'https://images.unsplash.com/photo-1610701596007-11502861dcfa?w=400', 'url': 'https://www.ikea.com', 'source': 'IKEA', 'tags': ['maison', 'cuisine', 'homme', 'femme'], 'categories': ['home']},
      {'id': 45, 'name': 'Coussins Maisons du Monde', 'brand': 'Maisons du Monde', 'price': 35, 'description': 'Set de coussins décoratifs', 'image': 'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=400', 'url': 'https://www.maisonsdumonde.com', 'source': 'Maisons du Monde', 'tags': ['maison', 'déco', 'homme', 'femme'], 'categories': ['home']},
      {'id': 46, 'name': 'Machine Nespresso', 'brand': 'Nespresso', 'price': 199, 'description': 'Machine à café élégante', 'image': 'https://images.unsplash.com/photo-1517668808822-9ebb02f2a0e6?w=400', 'url': 'https://www.nespresso.com', 'source': 'Nespresso', 'tags': ['maison', 'café', 'homme', 'femme'], 'categories': ['home']},
      {'id': 47, 'name': 'Plantes d\'intérieur', 'brand': 'Truffaut', 'price': 45, 'description': 'Trio de plantes faciles', 'image': 'https://images.unsplash.com/photo-1463936575829-25148e1db1b8?w=400', 'url': 'https://www.truffaut.com', 'source': 'Truffaut', 'tags': ['maison', 'plantes', 'déco', 'homme', 'femme'], 'categories': ['home']},
      {'id': 48, 'name': 'Batterie de cuisine Le Creuset', 'brand': 'Le Creuset', 'price': 349, 'description': 'Cocotte en fonte émaillée', 'image': 'https://images.unsplash.com/photo-1584990347449-39b0e5a39e0d?w=400', 'url': 'https://www.lecreuset.fr', 'source': 'Le Creuset', 'tags': ['maison', 'cuisine', 'homme', 'femme'], 'categories': ['home']},
      {'id': 49, 'name': 'Lampe Kartell', 'brand': 'Kartell', 'price': 189, 'description': 'Lampe design iconique', 'image': 'https://images.unsplash.com/photo-1524484485831-a92ffc0de03f?w=400', 'url': 'https://www.kartell.com', 'source': 'Kartell', 'tags': ['maison', 'design', 'déco', 'homme', 'femme'], 'categories': ['home']},
      {'id': 50, 'name': 'Aspirateur Dyson V15', 'brand': 'Dyson', 'price': 649, 'description': 'Aspirateur sans fil puissant', 'image': 'https://images.unsplash.com/photo-1558317374-067fb5f30001?w=400', 'url': 'https://www.dyson.fr', 'source': 'Dyson', 'tags': ['maison', 'tech', 'homme', 'femme'], 'categories': ['home']},
    ];

    return fallbackProducts.take(count).toList();
  }
}
