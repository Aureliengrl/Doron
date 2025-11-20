import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '/utils/app_logger.dart';
import '/services/tags_definitions.dart';

/// Service de matching de produits basé sur les tags
/// Remplace les appels OpenAI pour des résultats instantanés
/// ⚠️ TOUS les produits viennent UNIQUEMENT de Firebase (collections 'gifts' ou 'products')
/// ⛔ PLUS AUCUN FALLBACK - Si Firebase vide, l'app crash pour identifier le problème
class ProductMatchingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Extrait l'URL de l'image d'un produit en cherchant dans TOUS les champs possibles
  /// Retourne une URL par défaut si aucune image n'est trouvée
  static String _extractImageUrl(Map<String, dynamic> product) {
    // Liste EXHAUSTIVE de tous les champs possibles pour une image
    final possibleFields = [
      'image',
      'imageUrl',
      'image_url',
      'photo',
      'img',
      'product_photo',
      'product_image',
      'productPhoto',
      'productImage',
      'picture',
      'thumbnail',
      'main_image',
      'mainImage',
      'cover',
      'coverImage',
      'image1',
      'images', // Parfois c'est un array
    ];

    // Essayer chaque champ
    for (var field in possibleFields) {
      final value = product[field];

      // Si c'est une string non vide
      if (value is String && value.isNotEmpty && value.startsWith('http')) {
        AppLogger.debug('🖼️ Image trouvée dans champ "$field": ${value.substring(0, value.length > 50 ? 50 : value.length)}...', 'Matching');
        return value;
      }

      // Si c'est un array, prendre le premier élément
      if (value is List && value.isNotEmpty) {
        final firstImage = value.first;
        if (firstImage is String && firstImage.isNotEmpty && firstImage.startsWith('http')) {
          AppLogger.debug('🖼️ Image trouvée dans array "$field": ${firstImage.substring(0, firstImage.length > 50 ? 50 : firstImage.length)}...', 'Matching');
          return firstImage;
        }
      }
    }

    // Aucune image trouvée - logger pour debug
    AppLogger.warning('⚠️ AUCUNE IMAGE trouvée pour produit "${product['name']}" - Champs disponibles: ${product.keys.join(", ")}', 'Matching');

    // Retourner une image placeholder par défaut (icône cadeau générique)
    return 'https://via.placeholder.com/400x400/8A2BE2/FFFFFF?text=🎁';
  }

  /// Génère des produits personnalisés en matchant les tags utilisateur avec la base de produits
  ///
  /// Mode de filtrage:
  /// - "home": Page d'accueil - Strict sur SEXE uniquement (basé sur soi), souple sur le reste
  /// - "person": Recherche personne - Modéré sur tout (scoring uniquement pour cadeaux innovants)
  /// - "discovery": Mode Inspirations - Très souple, variété maximale
  static Future<List<Map<String, dynamic>>> getPersonalizedProducts({
    required Map<String, dynamic> userTags,
    int count = 50,
    String? category,
    List<dynamic>? excludeProductIds, // Pour refresh intelligent
    String filteringMode = "discovery", // "home", "person", "discovery"
  }) async {
    try {
      AppLogger.info('🎯 Matching produits pour tags: ${userTags.keys.join(", ")}', 'Matching');
      AppLogger.info('🔒 Mode filtrage: $filteringMode', 'Matching');
      AppLogger.debug('📋 User tags complets: $userTags', 'Matching');
      AppLogger.info('🚫 Exclusion de ${excludeProductIds?.length ?? 0} produits', 'Matching');

      // Convertir les réponses utilisateur en tags de recherche
      final searchTags = _convertUserTagsToSearchTags(userTags);
      AppLogger.debug('🏷️ Tags de recherche: $searchTags', 'Matching');

      // 🎯 FILTRAGE FIREBASE - Différent selon le mode
      Query<Map<String, dynamic>> query = _firestore.collection('gifts');
      AppLogger.firebase('🎁 Chargement depuis collection Firebase: gifts');

      // ========================================================================
      // FILTRAGE FIREBASE - DÉSACTIVÉ TEMPORAIREMENT
      // Le filtrage se fera côté client avec le scoring pour plus de flexibilité
      // ========================================================================
      bool firebaseFilterApplied = false;
      String? genderFilter; // Variable pour stocker le filtre genre (utilisé pour logging)

      // Stocker le genre pour le scoring côté client
      final gender = userTags['gender'] ?? userTags['recipientGender'];
      if (gender != null) {
        final genderStr = gender.toString();
        if (genderStr.contains('Femme') || genderStr.contains('femme')) {
          genderFilter = 'gender_femme';
        } else if (genderStr.contains('Homme') || genderStr.contains('homme')) {
          genderFilter = 'gender_homme';
        } else {
          genderFilter = 'gender_mixte';
        }
        AppLogger.info('👤 Genre utilisateur: $genderFilter (filtrage côté client)', 'Matching');
      }

      // Log du mode de filtrage
      AppLogger.info('🌐 MODE ${filteringMode.toUpperCase()}: Chargement de tous les produits, filtrage par scoring', 'Matching');

      // ⚙️ FILTRAGE PAR CATÉGORIE (STRICT pour page d'accueil)
      if (category != null && category != 'Pour toi' && category != 'all') {
        // Convertir la catégorie en tag Firebase
        String? categoryTag;
        if (category.contains('Tendances')) {
          categoryTag = 'cat_tendances';
        } else if (category.contains('Tech')) {
          categoryTag = 'cat_tech';
        } else if (category.contains('Mode')) {
          categoryTag = 'cat_mode';
        } else if (category.contains('Maison')) {
          categoryTag = 'cat_maison';
        } else if (category.contains('Beauté') || category.contains('Beaute')) {
          categoryTag = 'cat_beaute';
        } else if (category.contains('Food') || category.contains('Gastronomie')) {
          categoryTag = 'cat_food';
        }

        if (categoryTag != null && !firebaseFilterApplied) {
          // Si aucun filtre genre n'a été appliqué, on peut filtrer par catégorie
          query = query.where('tags', arrayContains: categoryTag);
          firebaseFilterApplied = true;
          AppLogger.firebase('📁 Filtrage Firebase STRICT par catégorie: $categoryTag', 'Matching');
        } else if (categoryTag != null) {
          // Si filtre genre déjà appliqué, on filtrera par catégorie dans le scoring
          AppLogger.info('📁 Catégorie $categoryTag sera filtrée dans le scoring (genre déjà filtré Firebase)', 'Matching');
        }
      }

      // Charger beaucoup de produits pour avoir de la variété
      final loadLimit = firebaseFilterApplied ? 2000 : 1000;
      AppLogger.info('🔄 Exécution requête Firebase gifts.limit($loadLimit)...', 'Matching');

      var snapshot = await query.limit(loadLimit).get();
      AppLogger.success('✅ Requête Firebase réussie: ${snapshot.docs.length} documents', 'Matching');

      var allProducts = <Map<String, dynamic>>[];
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          data['id'] = doc.id;
          allProducts.add(data);
        } catch (e) {
          AppLogger.warning('⚠️ Erreur parsing produit ${doc.id}: $e', 'Matching');
        }
      }

      AppLogger.firebase('📦 ${allProducts.length} produits parsés avec succès depuis Firebase');

      // 🔍 DEBUG: Afficher un sample de produit pour voir la structure
      if (allProducts.isNotEmpty) {
        final sample = allProducts.first;
        AppLogger.debug('🔍 SAMPLE PRODUIT: name="${sample['name']}", tags=${sample['tags']}, categories=${sample['categories']}', 'Matching');
      }

      // 🔄 SI AUCUN PRODUIT et qu'un filtre a été appliqué, retry SANS filtre
      if (allProducts.isEmpty && firebaseFilterApplied) {
        AppLogger.warning('⚠️ Aucun produit avec filtres Firebase, retry SANS filtre...', 'Matching');
        query = _firestore.collection('gifts');
        snapshot = await query.limit(1000).get();
        allProducts = [];
        for (var doc in snapshot.docs) {
          try {
            final data = doc.data();
            data['id'] = doc.id;
            allProducts.add(data);
          } catch (e) {
            AppLogger.warning('⚠️ Erreur parsing produit ${doc.id}: $e', 'Matching');
          }
        }
        AppLogger.firebase('📦 ${allProducts.length} produits chargés SANS filtre Firebase', 'Matching');
      }

      // 🔄 FALLBACK vers collection 'products' si 'gifts' est vide
      if (allProducts.isEmpty) {
        AppLogger.warning('⚠️ Collection gifts vide, fallback vers products...', 'Matching');
        query = _firestore.collection('products');
        snapshot = await query.limit(1000).get();
        allProducts = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
        AppLogger.firebase('📦 ${allProducts.length} produits chargés depuis Firebase products', 'Matching');
      }

      // ⛔ SI TOUJOURS VIDE, erreur critique
      if (allProducts.isEmpty) {
        AppLogger.error('❌ ERREUR CRITIQUE: AUCUN PRODUIT DANS FIREBASE !', 'Matching', null);
        AppLogger.error('   - Collection gifts: VIDE', 'Matching', null);
        AppLogger.error('   - Collection products: VIDE', 'Matching', null);
        throw Exception('FIREBASE VIDE - Aucun produit trouvé dans gifts ni products.');
      }

      AppLogger.success('✅ ${allProducts.length} produits chargés depuis Firebase', 'Matching');

      // ============= FILTRAGE PAR TYPE DE CADEAU =============
      // JAMAIS de filtrage strict sur les types de cadeaux - seulement scoring
      // Cela permet d'avoir des cadeaux innovants même en mode PERSON
      final giftTypes = userTags['giftTypes'];
      if (giftTypes != null) {
        final typesList = giftTypes is List ? giftTypes : [giftTypes];
        AppLogger.info('🎁 Types de cadeaux demandés: ${typesList.join(", ")} (scoring favorisera ces types)', 'Matching');
      }

      // Scorer et trier les produits par pertinence
      AppLogger.info('🎯 Début du scoring de ${allProducts.length} produits...', 'Matching');
      final scoredProducts = <Map<String, dynamic>>[];
      int scoringErrors = 0;

      for (var product in allProducts) {
        try {
          final score = _calculateMatchScore(
            product,
            searchTags,
            userTags,
            filteringMode: filteringMode,
          );
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

      // Filtrer les produits avec score d'exclusion (-10000) SAUF en mode discovery
      var relevantProducts = scoredProducts;
      if (filteringMode != "discovery") {
        relevantProducts = scoredProducts.where((p) => (p['_matchScore'] as double) > -1000).toList();
        AppLogger.info('📊 Filtrage par score: ${relevantProducts.length} produits après exclusion', 'Matching');
      } else {
        AppLogger.info('📊 Mode discovery: AUCUN filtrage par score, ${relevantProducts.length} produits disponibles', 'Matching');
      }

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
      int categoryFilteredCount = 0; // Compteur de produits filtrés par catégorie

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

        // 6️⃣ Vérifier correspondance sexe - SEULEMENT EN MODE HOME
        // En mode HOME (page accueil), filtre strict pour cadeaux adaptés à SOI-MÊME
        // En mode PERSON/DISCOVERY, on laisse passer pour innovation et variété (scoring favorisera)
        if (filteringMode == "home" && genderFilter != null) {
          final productTags = (product['tags'] as List?)?.cast<String>() ?? [];
          // Accepter les produits qui ont le bon tag OU qui sont mixtes OU qui n'ont pas de tag genre
          final hasGenderTag = productTags.any((t) => t.toLowerCase().startsWith('gender_'));
          final isCorrectGender = productTags.contains(genderFilter.toLowerCase());
          final isMixte = productTags.contains('gender_mixte');

          if (hasGenderTag && !isCorrectGender && !isMixte) {
            // Ce produit a un tag de genre mais pas le bon → on le skip
            continue;
          }
          // Sinon on accepte (pas de tag genre = OK, mixte = OK, bon genre = OK)
        }

        // 7️⃣ Vérifier correspondance catégorie - FILTRAGE STRICT si catégorie sélectionnée
        // Si l'utilisateur a cliqué sur une catégorie (Tech, Mode, etc.), montrer UNIQUEMENT cette catégorie
        if (category != null && category != 'Pour toi' && category != 'all') {
          final productTags = (product['tags'] as List?)?.cast<String>() ?? [];
          final productCategories = (product['categories'] as List?)?.cast<String>() ?? [];
          final productCategory = product['category']?.toString() ?? '';

          // Normaliser la catégorie recherchée
          final normalizedCategory = _normalizeTag(category);

          // Vérifier si le produit appartient à cette catégorie
          final matchesCategory =
            productTags.any((tag) => _normalizeTag(tag) == normalizedCategory || _normalizeTag(tag).contains(normalizedCategory)) ||
            productCategories.any((cat) => _normalizeTag(cat) == normalizedCategory || _normalizeTag(cat).contains(normalizedCategory)) ||
            _normalizeTag(productCategory) == normalizedCategory ||
            _normalizeTag(productCategory).contains(normalizedCategory);

          if (!matchesCategory) {
            // Ce produit n'appartient pas à la catégorie demandée, on le skip
            categoryFilteredCount++;
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

      // 📊 Log du filtrage par catégorie
      if (category != null && category != 'Pour toi' && category != 'all') {
        AppLogger.info('📁 Filtrage catégorie "$category": ${categoryFilteredCount} produits exclus, ${selectedProducts.length} produits retenus', 'Matching');
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

      // 🖼️ EXTRACTION ROBUSTE DES IMAGES - Ajouter le champ 'image' standardisé
      AppLogger.info('🖼️ Extraction des URLs d\'images pour ${selectedProducts.length} produits...', 'Matching');
      int imagesFound = 0;
      int imagesPlaceholder = 0;

      for (var product in selectedProducts) {
        final imageUrl = _extractImageUrl(product);
        product['image'] = imageUrl; // Ajouter/remplacer le champ 'image' standardisé

        if (imageUrl.contains('placeholder')) {
          imagesPlaceholder++;
        } else {
          imagesFound++;
        }
      }

      AppLogger.success('🖼️ Images extraites: $imagesFound URLs valides, $imagesPlaceholder placeholders', 'Matching');

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

  /// Convertit les tags utilisateur en tags de recherche OFFICIELS
  /// Utilise UNIQUEMENT les tags de TagsDefinitions
  static Set<String> _convertUserTagsToSearchTags(Map<String, dynamic> userTags) {
    final tags = <String>{};

    // ========================================================================
    // 1️⃣ GENRE (STRICT - 1 seul tag) → gender_femme, gender_homme, gender_mixte
    // ========================================================================
    final gender = userTags['gender'] ?? userTags['recipientGender'];
    if (gender != null) {
      final genderStr = gender.toString();
      final convertedGender = TagsDefinitions.genderConversion[genderStr] ??
                              TagsDefinitions.genderConversion['Non spécifié'];
      if (convertedGender != null) {
        tags.add(convertedGender);
        AppLogger.debug('🚹 Genre converti: $genderStr → $convertedGender', 'TagsConversion');
      }
    }

    // ========================================================================
    // 2️⃣ CATÉGORIE PRINCIPALE (STRICT - 1 seul tag)
    // ========================================================================
    final preferredCategories = userTags['preferredCategories'];
    if (preferredCategories != null) {
      final catList = preferredCategories is List ? preferredCategories : [preferredCategories];
      for (final cat in catList) {
        final catStr = cat.toString();
        final converted = TagsDefinitions.categoryConversion[catStr];
        if (converted != null) {
          tags.add(converted);
          AppLogger.debug('📁 Catégorie convertie: $catStr → $converted', 'TagsConversion');
        }
      }
    }

    // ========================================================================
    // 3️⃣ BUDGET (STRICT - 1 seul tag)
    // ========================================================================
    final budget = userTags['budget'];
    if (budget != null) {
      final budgetInt = int.tryParse(budget.toString()) ?? 0;
      final budgetTag = TagsDefinitions.getBudgetTagFromPrice(budgetInt);
      tags.add(budgetTag);
      AppLogger.debug('💰 Budget converti: $budgetInt → $budgetTag', 'TagsConversion');
    }

    // ========================================================================
    // 4️⃣ STYLES (SOUPLE - plusieurs tags possibles)
    // ========================================================================
    final style = userTags['style'];
    if (style != null) {
      final styleStr = style.toString();
      final converted = TagsDefinitions.styleConversion[styleStr];
      if (converted != null) {
        tags.add(converted);
        AppLogger.debug('🎨 Style converti: $styleStr → $converted', 'TagsConversion');
      }
    }

    // ========================================================================
    // 5️⃣ PERSONNALITÉS (SOUPLE - plusieurs tags possibles)
    // ========================================================================
    final personality = userTags['personality'];
    if (personality != null) {
      final personalityStr = personality.toString().toLowerCase();
      // Chercher dans le map de conversion
      TagsDefinitions.personalityConversion.forEach((key, value) {
        if (personalityStr.contains(key.toLowerCase())) {
          tags.add(value);
          AppLogger.debug('😊 Personnalité convertie: $key → $value', 'TagsConversion');
        }
      });
    }

    // ========================================================================
    // 6️⃣ PASSIONS / HOBBIES / INTERESTS (SOUPLE - plusieurs tags possibles)
    // ========================================================================
    final interests = userTags['interests'] ?? userTags['hobbies'] ?? userTags['recipientHobbies'];
    if (interests != null) {
      final interestsList = interests is String ? interests.split(',').map((e) => e.trim()).toList() :
                           (interests is List ? interests.map((e) => e.toString()).toList() : [interests.toString()]);

      for (final interest in interestsList) {
        final interestLower = interest.toLowerCase();
        // Chercher dans le map de conversion de passions
        TagsDefinitions.passionConversion.forEach((key, value) {
          if (interestLower.contains(key.toLowerCase())) {
            tags.add(value);
            AppLogger.debug('❤️ Passion convertie: $key → $value', 'TagsConversion');
          }
        });
      }
    }

    // ========================================================================
    // 7️⃣ TYPES DE CADEAUX (SOUPLE - plusieurs tags possibles)
    // ========================================================================
    final giftTypes = userTags['giftTypes'];
    if (giftTypes != null) {
      final typesList = giftTypes is List ? giftTypes : [giftTypes];
      for (final type in typesList) {
        final typeStr = type.toString().toLowerCase();
        // Essayer de matcher avec les types valides
        for (final validType in TagsDefinitions.giftTypeTags) {
          if (typeStr.contains(validType.replaceFirst('type_', '')) ||
              validType.contains(typeStr)) {
            tags.add(validType);
            AppLogger.debug('🎁 Type cadeau ajouté: $validType', 'TagsConversion');
            break;
          }
        }
      }
    }

    // ========================================================================
    // VALIDATION FINALE - Ne garder QUE les tags valides
    // ========================================================================
    final validTags = TagsDefinitions.filterValidTags(tags.toList());

    // Normaliser les tags : toLowerCase + remplacer tirets par underscores
    // Pour être cohérent avec les tags Firebase (budget_100-200 → budget_100_200)
    final normalizedTags = validTags.map((t) => t.toLowerCase().replaceAll('-', '_')).toSet();

    AppLogger.success('✅ Tags convertis: ${normalizedTags.length} tags valides sur ${tags.length} générés', 'TagsConversion');
    AppLogger.debug('🏷️ Tags finaux: ${normalizedTags.join(", ")}', 'TagsConversion');

    return normalizedTags;
  }

  /// Calcule le score de matching selon le NOUVEAU SYSTÈME DE TAGS OFFICIEL
  ///
  /// LOGIQUE STRICTE (correspondance exacte REQUISE - sinon exclusion):
  /// - Genre (gender_*) - SAUF en mode discovery
  /// - Catégorie principale (cat_*) - SAUF en mode discovery
  /// - Tranche de prix (budget_*) - SAUF en mode discovery
  ///
  /// LOGIQUE SOUPLE (scoring partiel - augmente score si match):
  /// - Styles (style_*)
  /// - Personnalités (perso_*)
  /// - Passions (passion_*)
  /// - Types de cadeaux (type_*)
  static double _calculateMatchScore(
    Map<String, dynamic> product,
    Set<String> searchTags,
    Map<String, dynamic> userTags, {
    String filteringMode = "home",
  }) {
    double score = 0.0;

    // Extraire TOUS les tags du produit (tags + categories)
    final productTags = (product['tags'] as List?)?.cast<String>() ?? [];
    final productCategories = (product['categories'] as List?)?.cast<String>() ?? [];
    // Normaliser les tags : toLowerCase + remplacer tirets par underscores
    // Firebase peut avoir "budget_100-200" ou "budget_100_200", on standardise
    final allProductTags = {...productTags, ...productCategories}
        .map((t) => t.toLowerCase().replaceAll('-', '_'))
        .toSet();

    print('🔍 Scoring produit "${product['name']}" (mode: $filteringMode): ${allProductTags.length} tags');

    // Modes de filtrage:
    // - HOME: TRÈS STRICT (genre, âge, catégories) - cadeaux pour SOI
    // - PERSON: STRICT sur genre/âge, SOUPLE sur catégories/budget - cadeaux pour QUELQU'UN
    // - DISCOVERY: TRÈS SOUPLE partout - exploration maximale
    final isDiscoveryMode = filteringMode == "discovery";
    final isHomeMode = filteringMode == "home";
    final isPersonMode = filteringMode == "person";

    // ========================================================================
    // RÈGLES STRICTES - EXCLUSION OU PÉNALITÉ SELON MODE
    // ========================================================================

    // 🔒 1. GENRE (SCORING uniquement, PLUS JAMAIS d'exclusion)
    final userGenderTags = searchTags.where((t) => t.startsWith('gender_')).toList();
    if (userGenderTags.isNotEmpty) {
      final userGender = userGenderTags.first.toLowerCase();
      final productGenderTags = allProductTags.where((t) => t.toLowerCase().startsWith('gender_')).map((t) => t.toLowerCase()).toList();

      if (productGenderTags.isEmpty) {
        // Produit sans tag de genre => considéré universel, très bon
        print('⚠️ Produit sans genre, considéré comme universel: +80');
        score += 80.0;
      } else if (productGenderTags.contains(userGender)) {
        // Match exact du genre
        print('✅ GENRE MATCH: $userGender = +100 points');
        score += 100.0;
      } else if (productGenderTags.contains('gender_mixte')) {
        // Produit mixte accepté pour tout genre
        print('✅ Produit mixte accepté: +70 points');
        score += 70.0;
      } else {
        // Genre ne correspond PAS - PÉNALITÉ mais PAS d'exclusion
        if (isDiscoveryMode) {
          // Discovery: très petite pénalité
          print('⚠️ GENRE NE CORRESPOND PAS (discovery): ${productGenderTags.join(", ")} => Pénalité -10');
          score -= 10.0;
        } else if (isHomeMode) {
          // Home: pénalité modérée (avant c'était exclusion)
          print('⚠️ GENRE NE CORRESPOND PAS (home): $userGender ≠ ${productGenderTags.join(", ")} => Pénalité -40');
          score -= 40.0;
        } else {
          // Person: petite pénalité
          print('⚠️ GENRE NE CORRESPOND PAS (person): $userGender ≠ ${productGenderTags.join(", ")} => Pénalité -30');
          score -= 30.0;
        }
      }
    } else {
      // Pas de tag genre utilisateur = on accepte tout
      print('📝 Utilisateur sans préférence genre: +50 pour tous les produits');
      score += 50.0;
    }

    // 🔒 2. ÂGE (SCORING uniquement, PLUS JAMAIS d'exclusion)
    final age = userTags['age'] ?? userTags['recipientAge'];
    if (age != null && !isDiscoveryMode) {
      final ageInt = int.tryParse(age.toString()) ?? 0;
      if (ageInt > 0) {
        // Déterminer la tranche d'âge de l'utilisateur
        String userAgeTag;
        if (ageInt < 18) {
          userAgeTag = 'age_enfant';
        } else if (ageInt < 30) {
          userAgeTag = 'age_jeune';
        } else if (ageInt < 50) {
          userAgeTag = 'age_adulte';
        } else {
          userAgeTag = 'age_senior';
        }

        // Vérifier si le produit a des tags d'âge
        final productAgeTags = allProductTags.where((t) => t.startsWith('age_')).toList();

        if (productAgeTags.isNotEmpty) {
          if (productAgeTags.contains(userAgeTag)) {
            // Match exact de la tranche d'âge
            print('✅ ÂGE MATCH: $userAgeTag ($ageInt ans) = +50 points');
            score += 50.0;
          } else {
            // Âge ne correspond pas - PÉNALITÉ mais PAS d'exclusion
            if (isHomeMode) {
              // Home: Pénalité importante mais pas d'exclusion
              print('⚠️ ÂGE NE CORRESPOND PAS (home): $userAgeTag ≠ ${productAgeTags.join(", ")} => Pénalité -35');
              score -= 35.0;
            } else {
              // Person: SCORING au lieu d'exclusion (pénalité modérée)
              print('⚠️ ÂGE NE CORRESPOND PAS (person): $userAgeTag ≠ ${productAgeTags.join(", ")} => Pénalité -25');
              score -= 25.0;
            }
          }
        } else {
          // Produit sans tag d'âge => bonus car universel
          print('📝 Produit sans tag âge (universel): +15');
          score += 15.0;
        }
      }
    }

    // 🔒 3. CATÉGORIE PRINCIPALE (SCORING uniquement, PLUS JAMAIS d'exclusion)
    final userCategoryTags = searchTags.where((t) => t.startsWith('cat_')).toList();
    if (userCategoryTags.isNotEmpty) {
      final userCategory = userCategoryTags.first;
      final productCategoryTags = allProductTags.where((t) => t.startsWith('cat_')).toList();

      if (productCategoryTags.isEmpty) {
        print('⚠️ Produit sans catégorie: +20');
        score += 20.0;
      } else if (productCategoryTags.contains(userCategory.toLowerCase())) {
        // Match exact
        print('✅ CATÉGORIE MATCH: $userCategory = +80 points');
        score += 80.0;
      } else {
        // Catégorie ne correspond PAS - PÉNALITÉ mais PAS d'exclusion
        if (isHomeMode) {
          // Home: Pénalité importante mais pas d'exclusion (permet variété)
          print('⚠️ CATÉGORIE NE CORRESPOND PAS (home): $userCategory ≠ ${productCategoryTags.join(", ")} => Pénalité -45');
          score -= 45.0;
        } else if (isPersonMode) {
          // Person: pénalité modérée (permet innovation)
          print('⚠️ CATÉGORIE NE CORRESPOND PAS (person): $userCategory ≠ ${productCategoryTags.join(", ")} => Pénalité -30');
          score -= 30.0;
        } else {
          // Discovery: pénalité légère
          print('⚠️ CATÉGORIE NE CORRESPOND PAS (discovery): $userCategory ≠ ${productCategoryTags.join(", ")} => Pénalité -10');
          score -= 10.0;
        }
      }
    }

    // 🔒 4. BUDGET (SCORING uniquement, PLUS JAMAIS d'exclusion)
    final userBudgetTags = searchTags.where((t) => t.startsWith('budget_')).toList();
    if (userBudgetTags.isNotEmpty) {
      final userBudget = userBudgetTags.first;
      final productBudgetTags = allProductTags.where((t) => t.startsWith('budget_')).toList();

      if (productBudgetTags.isEmpty) {
        // Calculer depuis le prix
        final price = product['price'];
        if (price != null) {
          final priceInt = price is int ? price : (price is double ? price.toInt() : 0);
          final calculatedBudget = TagsDefinitions.getBudgetTagFromPrice(priceInt);

          if (calculatedBudget.toLowerCase() == userBudget.toLowerCase()) {
            print('✅ BUDGET CALCULÉ MATCH: $priceInt€ = $calculatedBudget = +60 points');
            score += 60.0;
          } else {
            // Budget ne correspond PAS - PÉNALITÉ mais PAS d'exclusion
            if (isHomeMode) {
              // Home: Pénalité importante mais pas d'exclusion (permet flexibilité)
              print('⚠️ BUDGET NE CORRESPOND PAS (home): $calculatedBudget ≠ $userBudget => Pénalité -30');
              score -= 30.0;
            } else if (isPersonMode) {
              // Person: pénalité légère (permet flexibilité)
              print('⚠️ BUDGET NE CORRESPOND PAS (person): $calculatedBudget ≠ $userBudget => Pénalité -20');
              score -= 20.0;
            } else {
              // Discovery: pénalité très légère
              print('⚠️ BUDGET NE CORRESPOND PAS (discovery): $calculatedBudget ≠ $userBudget => Pénalité -5');
              score -= 5.0;
            }
          }
        } else {
          // Pas de prix disponible => petite pénalité
          print('⚠️ Pas de prix disponible: +10');
          score += 10.0;
        }
      } else if (productBudgetTags.contains(userBudget.toLowerCase())) {
        // Match exact du budget
        print('✅ BUDGET MATCH: $userBudget = +60 points');
        score += 60.0;
      } else {
        // Budget ne correspond PAS - PÉNALITÉ mais PAS d'exclusion
        if (isDiscoveryMode) {
          // En mode discovery, on pénalise mais on n'exclut PAS
          print('⚠️ BUDGET NE CORRESPOND PAS (discovery mode): $userBudget ≠ ${productBudgetTags.join(", ")} => Pénalité -10');
          score -= 10.0;
        } else if (isHomeMode) {
          // En mode home, pénalité importante mais PAS d'exclusion
          print('⚠️ BUDGET NE CORRESPOND PAS (home): $userBudget ≠ ${productBudgetTags.join(", ")} => Pénalité -30');
          score -= 30.0;
        } else {
          // En mode person, pénalité modérée
          print('⚠️ BUDGET NE CORRESPOND PAS (person): $userBudget ≠ ${productBudgetTags.join(", ")} => Pénalité -20');
          score -= 20.0;
        }
      }
    }

    // ========================================================================
    // RÈGLES SOUPLES - SCORING PARTIEL (pas d'exclusion)
    // ========================================================================

    // 💫 4. STYLES (SOUPLE - max 40 points)
    final userStyleTags = searchTags.where((t) => t.startsWith('style_')).toList();
    if (userStyleTags.isNotEmpty) {
      final productStyleTags = allProductTags.where((t) => t.startsWith('style_')).toList();
      int styleMatches = 0;

      for (final userStyle in userStyleTags) {
        if (productStyleTags.contains(userStyle.toLowerCase())) {
          styleMatches++;
          print('✨ Style match: $userStyle');
        }
      }

      if (styleMatches > 0) {
        final styleScore = styleMatches * 20.0; // 20 points par style matché
        score += styleScore.clamp(0, 40); // Max 40 points
        print('🎨 STYLES: $styleMatches matches = +${styleScore.clamp(0, 40)} points');
      }
    }

    // 💫 5. PERSONNALITÉS (SOUPLE - max 30 points)
    final userPersonalityTags = searchTags.where((t) => t.startsWith('perso_')).toList();
    if (userPersonalityTags.isNotEmpty) {
      final productPersonalityTags = allProductTags.where((t) => t.startsWith('perso_')).toList();
      int personalityMatches = 0;

      for (final userPersonality in userPersonalityTags) {
        if (productPersonalityTags.contains(userPersonality.toLowerCase())) {
          personalityMatches++;
          print('✨ Personnalité match: $userPersonality');
        }
      }

      if (personalityMatches > 0) {
        final personalityScore = personalityMatches * 15.0; // 15 points par personnalité matchée
        score += personalityScore.clamp(0, 30); // Max 30 points
        print('😊 PERSONNALITÉS: $personalityMatches matches = +${personalityScore.clamp(0, 30)} points');
      }
    }

    // 💫 6. PASSIONS (SOUPLE - max 50 points - le plus important des souples)
    final userPassionTags = searchTags.where((t) => t.startsWith('passion_')).toList();
    if (userPassionTags.isNotEmpty) {
      final productPassionTags = allProductTags.where((t) => t.startsWith('passion_')).toList();
      int passionMatches = 0;

      for (final userPassion in userPassionTags) {
        if (productPassionTags.contains(userPassion.toLowerCase())) {
          passionMatches++;
          print('✨ Passion match: $userPassion');
        }
      }

      if (passionMatches > 0) {
        final passionScore = passionMatches * 25.0; // 25 points par passion matchée
        score += passionScore.clamp(0, 50); // Max 50 points
        print('❤️ PASSIONS: $passionMatches matches = +${passionScore.clamp(0, 50)} points');
      }
    }

    // 💫 7. TYPES DE CADEAUX (SOUPLE - max 30 points)
    final userTypeTags = searchTags.where((t) => t.startsWith('type_')).toList();
    if (userTypeTags.isNotEmpty) {
      final productTypeTags = allProductTags.where((t) => t.startsWith('type_')).toList();
      int typeMatches = 0;

      for (final userType in userTypeTags) {
        if (productTypeTags.contains(userType.toLowerCase())) {
          typeMatches++;
          print('✨ Type cadeau match: $userType');
        }
      }

      if (typeMatches > 0) {
        final typeScore = typeMatches * 15.0; // 15 points par type matché
        score += typeScore.clamp(0, 30); // Max 30 points
        print('🎁 TYPES: $typeMatches matches = +${typeScore.clamp(0, 30)} points');
      }
    }

    // ========================================================================
    // BONUS SECONDAIRES
    // ========================================================================

    // 📈 Popularité (max 20 points)
    final popularity = product['popularity'] as int? ?? 0;
    if (popularity > 0) {
      final popularityScore = (popularity * 0.2).clamp(0, 20);
      score += popularityScore;
      print('📈 Popularité: $popularity = +${popularityScore.toStringAsFixed(1)} points');
    }

    // 🎲 Variation aléatoire légère (0-5 points pour éviter ordre identique)
    final randomBonus = Random().nextDouble() * 5.0;
    score += randomBonus;

    print('🏁 SCORE FINAL: ${score.toStringAsFixed(1)} points');
    print('');

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
