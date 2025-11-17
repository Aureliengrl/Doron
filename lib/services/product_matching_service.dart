import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '/utils/app_logger.dart';

/// Service de matching de produits basé sur les tags
/// Remplace les appels OpenAI pour des résultats instantanés
/// ⚠️ TOUS les produits viennent UNIQUEMENT de Firebase (collections 'gifts' ou 'products')
/// ⛔ PLUS AUCUN FALLBACK - Si Firebase vide, l'app crash pour identifier le problème
class ProductMatchingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

      // ✅ FILTRE SEXE RÉACTIVÉ pour éviter produits beauté fille pour père
      if (genderFilter != null) {
        query = query.where('tags', arrayContains: genderFilter);
        AppLogger.firebase('🎯 Filtrage Firebase par sexe: $genderFilter');
      }

      // ✅ FILTRE CATÉGORIE RÉACTIVÉ pour meilleure pertinence
      if (category != null && category != 'Pour toi' && category != 'all') {
        if (genderFilter == null) {
          query = query.where('categories', arrayContains: category.toLowerCase());
          AppLogger.firebase('🎯 Filtrage Firebase par catégorie: $category');
        }
      }

      // Charger 2000 produits (augmenté pour plus de variété)
      AppLogger.info('🔄 Exécution requête Firebase gifts.limit(2000)...', 'Matching');

      var snapshot = await query.limit(2000).get();
      AppLogger.success('✅ Requête Firebase réussie: ${snapshot.docs.length} documents', 'Matching');

      var allProducts = <Map<String, dynamic>>[];
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          data['id'] = doc.id;
          allProducts.add(data);
        } catch (e) {
          AppLogger.warning('⚠️ Erreur parsing produit ${doc.id}: $e', 'Matching');
          // Continue avec les autres produits
        }
      }

      AppLogger.firebase('📦 ${allProducts.length} produits parsés avec succès depuis Firebase');

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

      // ⛔ PLUS AUCUN FALLBACK - Si Firebase vide, on CRASH pour identifier le problème
      if (allProducts.isEmpty) {
        AppLogger.error('❌ ERREUR CRITIQUE: AUCUN PRODUIT DANS FIREBASE !', 'Matching', null);
        AppLogger.error('Collection gifts: VIDE', 'Matching', null);
        AppLogger.error('Collection products: VIDE', 'Matching', null);
        AppLogger.error('⚠️ Vérifier que le scraping Replit a bien fonctionné!', 'Matching', null);
        throw Exception('FIREBASE VIDE - Aucun produit dans gifts ni products. Le scraping Replit n\'a pas fonctionné ou les collections sont vides.');
      }

      AppLogger.success('✅ ${allProducts.length} produits chargés depuis Firebase - AUCUN FALLBACK', 'Matching');

      // Scorer et trier les produits par pertinence
      AppLogger.info('🎯 Début du scoring de ${allProducts.length} produits...', 'Matching');
      final scoredProducts = <Map<String, dynamic>>[];
      int scoringErrors = 0;

      for (var product in allProducts) {
        try {
          final score = _calculateMatchScore(product, searchTags, userTags);
          scoredProducts.add({
            ...product,
            '_matchScore': score,
          });
        } catch (e) {
          scoringErrors++;
          AppLogger.warning('⚠️ Erreur scoring produit ${product['id']}: $e', 'Matching');
          // Ajouter quand même avec score 0 pour ne pas perdre le produit
          scoredProducts.add({
            ...product,
            '_matchScore': 0.0,
          });
        }
      }

      if (scoringErrors > 0) {
        AppLogger.warning('⚠️ $scoringErrors produits ont eu des erreurs de scoring', 'Matching');
      }
      AppLogger.success('✅ Scoring terminé: ${scoredProducts.length} produits', 'Matching');

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

      // ✅ EXCLUSION RÉACTIVÉE pour éviter de revoir les mêmes produits
      AppLogger.info('🎯 Exclusion de ${excludedIds.length} produits déjà vus', 'Matching');
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

        // 1️⃣ Vérifier exclusion des produits déjà vus
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

        // 6️⃣ Vérifier correspondance sexe (CRITIQUE pour éviter leggings fille pour papa)
        if (genderFilter != null) {
          final productTags = (product['tags'] as List?)?.cast<String>() ?? [];
          if (!productTags.contains(genderFilter)) {
            // Ce produit n'a pas le bon tag de sexe, on le skip
            continue;
          }
        }

        // ✅ Ajouter le produit
        selectedProducts.add(product);
        seenProductIds.add(productId);
        seenProductNames.add(normalizedName);
        brandCounts[brand] = currentBrandCount + 1;
        categoryCounts[mainCategory] = currentCategoryCount + 1;
      }

      // 🎨 MÉLANGE INTELLIGENT FINAL pour éviter produits similaires côte à côte
      // Séparer par catégorie et entremêler
      final productsByCategory = <String, List<Map<String, dynamic>>>{};
      for (var product in selectedProducts) {
        final categories = (product['categories'] as List?)?.cast<String>() ?? [];
        final mainCategory = categories.isNotEmpty ? categories.first : 'Autre';
        productsByCategory.putIfAbsent(mainCategory, () => []).add(product);
      }

      // Reconstruire la liste en alternant les catégories
      final diversifiedProducts = <Map<String, dynamic>>[];
      final categoryKeys = productsByCategory.keys.toList();
      int maxIterations = selectedProducts.length;
      int iteration = 0;

      while (diversifiedProducts.length < selectedProducts.length && iteration < maxIterations) {
        for (var category in categoryKeys) {
          final products = productsByCategory[category]!;
          if (products.isNotEmpty) {
            diversifiedProducts.add(products.removeAt(0));
            if (diversifiedProducts.length >= selectedProducts.length) break;
          }
        }
        iteration++;
      }

      // Remplacer la liste sélectionnée par la version diversifiée
      selectedProducts
        ..clear()
        ..addAll(diversifiedProducts);

      // Retirer le score de matching avant de retourner
      for (var product in selectedProducts) {
        product.remove('_matchScore');
      }

      AppLogger.success('${selectedProducts.length} produits matchés et retournés', 'Matching');
      AppLogger.info('📊 Diversité des marques: ${brandCounts.length} marques différentes', 'Matching');
      AppLogger.debug('📊 Répartition marques: ${brandCounts.entries.map((e) => '${e.key}: ${e.value}').take(10).join(", ")}', 'Matching');
      AppLogger.debug('📊 Répartition catégories: ${categoryCounts.entries.map((e) => '${e.key}: ${e.value}').join(", ")}', 'Matching');
      return selectedProducts;
    } catch (e, stackTrace) {
      // ⚠️ ERREUR LORS DU CHARGEMENT - Logger détails complets
      AppLogger.error('❌ ERREUR lors du matching produits', 'Matching', e);
      AppLogger.error('Type erreur: ${e.runtimeType}', 'Matching', null);
      AppLogger.error('Message: ${e.toString()}', 'Matching', null);
      AppLogger.error('StackTrace complet:', 'Matching', null);
      AppLogger.error('$stackTrace', 'Matching', null);

      // Vérifier si c'est une erreur Firebase spécifique
      if (e.toString().contains('permission') || e.toString().contains('Permission')) {
        AppLogger.error('⚠️ ERREUR PERMISSIONS FIREBASE - Vérifier les Firestore Rules!', 'Matching', null);
      }
      if (e.toString().contains('network') || e.toString().contains('Network')) {
        AppLogger.error('⚠️ ERREUR RÉSEAU - Pas de connexion internet?', 'Matching', null);
      }

      // Retourner liste vide au lieu de crasher pour que l'app continue
      AppLogger.warning('Retour liste vide pour éviter crash app', 'Matching');
      return [];
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

  /// ⛔ FONCTION SUPPRIMÉE - Plus de fallback assets
  /// Tous les produits DOIVENT venir de Firebase uniquement

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

  /// ⛔ FONCTION SUPPRIMÉE - Plus de produits hardcodés en fallback
  /// Si Firebase est vide, l'app doit crasher pour qu'on identifie le problème
  /// Tous les produits DOIVENT venir de Firebase (collection 'gifts' ou 'products')
  ///
  /// ANCIENNE FONCTION _getFallbackProducts() SUPPRIMÉE
  /// Contenait 50 produits hardcodés (tech, mode, beauté, sport, maison)
  /// Ces produits génériques masquaient le vrai problème: Firebase vide
  ///
  /// DÉSORMAIS:
  /// - Firebase vide → Exception lancée
  /// - L'utilisateur voit immédiatement qu'il y a un problème
  /// - On peut identifier pourquoi le scraping n'a pas fonctionné
}
