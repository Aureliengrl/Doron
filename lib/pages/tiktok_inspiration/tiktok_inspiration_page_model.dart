import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    _errorDetails = '';
    notifyListeners();

    try {
      // Charger les tags du profil utilisateur
      final userProfileTags = await FirebaseDataService.loadUserProfileTags();

      // Charger les IDs des produits déjà vus
      final prefs = await SharedPreferences.getInstance();
      final seenProductIds = prefs.getStringList('seen_inspiration_product_ids')
          ?.map((s) => int.tryParse(s) ?? 0).toList() ?? [];

      AppLogger.info('🎬 Chargement TikTok Inspiration (exclusion de ${seenProductIds.length} produits déjà vus)', 'TikTok');

      // 🎯 Générer les produits via ProductMatchingService
      // Prefetch 30 produits pour un scroll fluide (on en affichera 20 à la fois)
      final rawProducts = await ProductMatchingService.getPersonalizedProducts(
        userTags: userProfileTags ?? {},
        count: 30,
        excludeProductIds: seenProductIds,
        strictFiltering: false, // Mode SOUPLE pour Inspirations (variété et découverte)
      );

      if (rawProducts.isEmpty) {
        _errorMessage = '📦 Pas de nouveaux produits';
        _errorDetails = 'Tous les produits disponibles ont déjà été vus. Reviens plus tard !';
        _hasError = true;
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Convertir au format TikTok et ajouter URLs intelligentes
      final products = rawProducts.take(20).map((product) {
        // 🔍 Chercher l'image dans tous les champs possibles
        final imageUrl = product['image'] as String? ??
                         product['imageUrl'] as String? ??
                         product['photo'] as String? ??
                         product['img'] as String? ??
                         product['product_photo'] as String? ??
                         '';

        // 🐛 DEBUG: Logger si l'image est vide
        if (imageUrl.isEmpty) {
          print('⚠️ TikTok Inspiration: Image vide pour "${product['name']}"');
          print('   Champs disponibles: ${product.keys.toList()}');
        } else {
          print('✅ TikTok Inspiration: Image OK pour "${product['name']}"');
          print('   Image URL: ${imageUrl.substring(0, imageUrl.length > 60 ? 60 : imageUrl.length)}...');
        }

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
