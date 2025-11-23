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
  bool _isLoading = true; // ✅ DÉMARRER EN LOADING pour garantir un loader initial
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
      // Charger les tags du profil utilisateur (comme home_pinterest)
      final userProfileTags = await FirebaseDataService.loadUserProfileTags();

      // ✅ TOUJOURS utiliser les tags, même vides (ProductMatchingService gère ça)
      final tagsToUse = userProfileTags ?? {};

      print('📋 TikTok Inspiration: Tags utilisés pour matching: $tagsToUse');

      // Charger les IDs des produits déjà vus
      final prefs = await SharedPreferences.getInstance();
      final seenProductIds = prefs.getStringList('seen_inspiration_product_ids')
          ?.map((s) => int.tryParse(s) ?? 0).toList() ?? [];

      print('📋 TikTok Inspiration: ${seenProductIds.length} produits déjà vus');

      // 🎯 Générer les produits via ProductMatchingService (Firebase-first)
      print('🔄 TikTok Inspiration: Appel ProductMatchingService...');

      final rawProducts = await ProductMatchingService.getPersonalizedProducts(
        userTags: tagsToUse,
        count: 30, // Prefetch 30 pour scroll fluide
        excludeProductIds: seenProductIds,
        filteringMode: "discovery", // Mode DISCOVERY: Très souple, variété maximale
      );

      print('✅ TikTok Inspiration: ProductMatchingService retourné ${rawProducts.length} produits');

      if (rawProducts.isEmpty) {
        _errorMessage = '📦 Aucune inspiration pour le moment';
        _errorDetails = 'Reviens plus tard pour découvrir de nouveaux produits !';
        _hasError = true;
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Convertir au format TikTok et ajouter URLs intelligentes
      final products = rawProducts.take(20).map((product) {
        // ✅ FIX: Conversion sécurisée du score (peut être int ou double)
        final matchScore = product['_matchScore'];
        final matchScoreDouble = matchScore is int
            ? matchScore.toDouble()
            : (matchScore as double? ?? 0.0);

        return {
          'id': product['id'],
          'name': product['name'] ?? 'Produit',
          'brand': product['brand'] ?? '',
          'price': product['price'] ?? 0,
          'image': product['image'] ?? product['imageUrl'] ?? '',
          'url': ProductUrlService.generateProductUrl(product),
          'source': product['source'] ?? 'Amazon',
          'categories': product['categories'] ?? [],
          'match': matchScoreDouble.toInt().clamp(0, 100),
        };
      }).toList();

      print('📦 ${products.length} produits convertis pour affichage');

      // Mettre à jour le cache des produits vus
      final newSeenIds = <String>[...seenProductIds.map((id) => id.toString())];
      for (var product in products) {
        final productId = product['id']?.toString() ?? '';
        if (productId.isNotEmpty && !newSeenIds.contains(productId)) {
          newSeenIds.add(productId);
        }
      }
      // Limiter à 200 derniers produits vus
      if (newSeenIds.length > 200) {
        newSeenIds.removeRange(0, newSeenIds.length - 200);
      }
      await prefs.setStringList('seen_inspiration_product_ids', newSeenIds);
      print('💾 ${newSeenIds.length} produits dans le cache (${products.length} nouveaux ajoutés)');

      _products = products;
      _isLoading = false;
      _hasError = false;
      notifyListeners();

      print('✅ TikTok Inspiration: ${_products.length} produits chargés avec succès');
      AppLogger.success('TikTok Inspiration: ${products.length} produits chargés', 'TikTok');
    } catch (e) {
      print('❌ Erreur chargement TikTok Inspiration: $e');
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
      } else {
        _errorMessage = '⚠️ Erreur de chargement';
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
