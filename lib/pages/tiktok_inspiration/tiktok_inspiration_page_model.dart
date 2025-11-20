import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/product_matching_service.dart';
import '/services/firebase_data_service.dart';
import '/services/product_url_service.dart';
import '/utils/app_logger.dart';

/// Model pour la page TikTok Inspiration (BÊTA)
class TikTokInspirationPageModel extends ChangeNotifier {
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  String _errorDetails = '';

  int _currentProductIndex = 0;
  int _currentPhotoIndex = 0;

  // Liked products (pour l'affichage du coeur)
  Set<String> likedProductTitles = {};

  // Getters
  List<Map<String, dynamic>> get products => _products;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  String get errorDetails => _errorDetails;
  int get currentProductIndex => _currentProductIndex;
  int get currentPhotoIndex => _currentPhotoIndex;

  /// Charge les produits via ProductMatchingService (Firebase-first)
  /// Précharge 20 produits pour l'expérience TikTok avec scroll vertical
  Future<void> loadProducts() async {
    print('🎬 TikTok Inspiration: Début loadProducts()');
    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    _errorDetails = '';
    notifyListeners();

    try {
      // Charger les tags du profil utilisateur
      print('🏷️ TikTok Inspiration: Chargement des tags utilisateur...');
      final userProfileTags = await FirebaseDataService.loadUserProfileTags();
      print('🏷️ TikTok Inspiration: Tags chargés: $userProfileTags');

      // ⚠️ FALLBACK: Si pas de tags, créer des tags par défaut pour mode découverte
      final tagsToUse = userProfileTags ?? {
        'interests': ['découverte', 'variété'],
        'style': 'Moderne',
      };

      print('🎯 TikTok Inspiration: Tags utilisés pour matching: $tagsToUse');

      // Charger les IDs des produits déjà vus
      final prefs = await SharedPreferences.getInstance();
      var seenProductIds = prefs.getStringList('seen_inspiration_product_ids')
          ?.map((s) => int.tryParse(s) ?? 0).toList() ?? [];

      print('📋 TikTok Inspiration: ${seenProductIds.length} produits déjà vus');

      // 🔄 Si trop de produits ont été vus (>50), réinitialiser complètement
      if (seenProductIds.length > 50) {
        print('♻️ TikTok Inspiration: RESET COMPLET des produits vus (${seenProductIds.length} > 50)');
        await prefs.remove('seen_inspiration_product_ids');
        seenProductIds = [];
      }

      AppLogger.info('🎬 Chargement TikTok Inspiration (exclusion de ${seenProductIds.length} produits déjà vus)', 'TikTok');

      // 🧪 TEST: Vérifier que Firebase a bien des produits
      try {
        print('🧪 TikTok Inspiration: Test direct Firebase...');
        final testSnapshot = await FirebaseFirestore.instance
            .collection('gifts')
            .limit(5)
            .get();
        print('🧪 Firebase gifts: ${testSnapshot.docs.length} produits trouvés directement');
        if (testSnapshot.docs.isEmpty) {
          print('❌ ERREUR CRITIQUE: Firebase collection "gifts" est VIDE !');
        }
      } catch (e) {
        print('❌ Erreur test Firebase: $e');
      }

      // 🎯 Générer les produits via ProductMatchingService
      // Prefetch 30 produits pour un scroll fluide (on en affichera 20 à la fois)
      print('🔄 TikTok Inspiration: Appel ProductMatchingService (mode discovery)...');

      // Si trop de produits exclus, on ignore la liste d'exclusion pour forcer du contenu
      final effectiveExcludeIds = seenProductIds.length > 30 ? [] : seenProductIds;
      if (seenProductIds.length > 30 && effectiveExcludeIds.isEmpty) {
        print('⚠️ TikTok Inspiration: Trop de produits exclus (${seenProductIds.length}), on ignore les exclusions');
      }

      final rawProducts = await ProductMatchingService.getPersonalizedProducts(
        userTags: tagsToUse,
        count: 30,
        excludeProductIds: effectiveExcludeIds,
        filteringMode: "discovery", // Mode DISCOVERY: Très souple, variété maximale
      );

      print('✅ TikTok Inspiration: ProductMatchingService retourné ${rawProducts.length} produits');

      if (rawProducts.isEmpty) {
        print('⚠️ TikTok Inspiration: Aucun produit retourné');
        print('⚠️ Tags utilisés: $tagsToUse');
        print('⚠️ IDs exclus: ${effectiveExcludeIds.length}');
        print('⚠️ Cela indique soit que Firebase est vide, soit un problème de filtrage');

        _errorMessage = '📦 Aucun produit disponible';
        _errorDetails = 'Impossible de charger les produits.\n\nVérifie ta connexion ou reviens plus tard.';
        _hasError = true;
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Convertir au format TikTok et ajouter URLs intelligentes
      final products = rawProducts.take(20).map((product) {
        // ✅ ProductMatchingService a déjà normalisé le champ 'image'
        final imageUrl = product['image'] as String? ?? 'https://via.placeholder.com/400x400/8A2BE2/FFFFFF?text=🎁';

        print('✅ TikTok Inspiration: "${product['name']}" - Image: ${imageUrl.substring(0, imageUrl.length > 60 ? 60 : imageUrl.length)}...');

        return {
          'id': product['id'],
          'name': product['name'] ?? 'Produit',
          'brand': product['brand'] ?? '',
          'price': product['price'] ?? 0,
          'image': imageUrl,
          'url': ProductUrlService.generateProductUrl(product),
          'source': product['source'] ?? 'Amazon',
          'categories': product['categories'] ?? [],
          'match': ((product['_matchScore'] ?? 0.0) as double).toInt().clamp(0, 100),
        };
      }).toList();

      // Mettre à jour le cache des produits vus
      final newSeenIds = seenProductIds.map((id) => id.toString()).toList();
      for (var product in products) {
        final id = product['id'];
        if (id != null) {
          final idStr = id.toString();
          if (!newSeenIds.contains(idStr)) {
            newSeenIds.add(idStr);
          }
        }
      }
      // Limiter à 200 derniers produits vus
      if (newSeenIds.length > 200) {
        newSeenIds.removeRange(0, newSeenIds.length - 200);
      }
      await prefs.setStringList('seen_inspiration_product_ids', newSeenIds);

      _products = products;
      _isLoading = false;
      _hasError = false;
      notifyListeners();

      print('✅ TikTok Inspiration: État final - ${_products.length} produits, isLoading: $_isLoading, hasError: $_hasError');
      AppLogger.success('TikTok Inspiration: ${products.length} produits chargés (Firebase + matching local)', 'TikTok');
    } catch (e) {
      AppLogger.error('Erreur chargement TikTok Inspiration', 'TikTok', e);

      // Parser l'erreur pour extraire des détails utiles
      String errorDetails = e.toString();

      // Analyser le type d'erreur
      if (errorDetails.contains('SocketException') || errorDetails.contains('Network')) {
        _errorMessage = '📡 Pas de connexion';
        _errorDetails = 'Vérifie ta connexion internet et réessaye.';
      } else if (errorDetails.contains('firebase') || errorDetails.contains('Firestore')) {
        _errorMessage = '🔥 Erreur Firebase';
        _errorDetails = 'Impossible de charger les produits. Réessaye plus tard.';
      } else if (errorDetails.contains('Aucun produit')) {
        _errorMessage = '📦 Pas de nouveaux produits';
        _errorDetails = 'Tous les produits disponibles ont déjà été vus. Reviens plus tard !';
      } else {
        _errorMessage = 'Erreur de chargement';
        _errorDetails = 'Une erreur est survenue lors du chargement des produits.';
      }

      _hasError = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Met à jour l'index du produit actuel
  void setCurrentProductIndex(int index) {
    _currentProductIndex = index;
    _currentPhotoIndex = 0; // Reset photo index quand on change de produit
    notifyListeners();
  }

  /// Met à jour l'index de la photo actuelle
  void setCurrentPhotoIndex(int index) {
    _currentPhotoIndex = index;
    notifyListeners();
  }

  /// Obtient les photos du produit actuel
  List<String> getCurrentProductPhotos() {
    if (_products.isEmpty || _currentProductIndex >= _products.length) {
      return [];
    }

    final product = _products[_currentProductIndex];
    final mainImage = product['image'] as String? ?? '';

    // Pour l'instant, on n'a qu'une seule photo par produit
    // Dans le futur, OpenAI pourrait retourner plusieurs photos
    if (mainImage.isEmpty) {
      return [];
    }

    return [mainImage];
  }

  @override
  void dispose() {
    super.dispose();
  }
}
