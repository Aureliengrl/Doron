import 'package:flutter/material.dart';
import '/services/product_matching_service.dart';
import '/services/firebase_data_service.dart';

/// Model SIMPLIFIÉ pour Mode Inspiration (TikTok style)
/// Utilise EXACTEMENT les mêmes produits que "Pour toi" sur la page d'accueil
/// ✨ INFINITE SCROLL: Recharge automatiquement quand on arrive en bas
class TikTokInspirationPageModel extends ChangeNotifier {
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  bool _isLoadingMore = false; // Pour le chargement en scroll infini
  bool _hasError = false;
  String _errorMessage = '';
  int _currentIndex = 0;

  // Favoris
  Set<String> likedProductTitles = {};

  // Pour le scroll infini: garder trace des IDs déjà vus
  final Set<String> _seenProductIds = {};

  // Tags utilisateur (cache pour ne pas recharger)
  Map<String, dynamic>? _cachedUserTags;

  // Getters
  List<Map<String, dynamic>> get products => _products;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  int get currentIndex => _currentIndex;

  /// Charge les produits - MÊME SOURCE que "Pour toi"
  Future<void> loadProducts() async {
    print('🎬 [INSPIRATION] Début chargement produits...');

    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    _seenProductIds.clear(); // Reset pour nouveau chargement
    notifyListeners();

    try {
      // Charger les tags utilisateur (comme la page d'accueil)
      _cachedUserTags = await FirebaseDataService.loadUserProfileTags() ?? {};
      print('🎬 [INSPIRATION] Tags utilisateur: $_cachedUserTags');

      // Charger les produits via ProductMatchingService (MÊME que "Pour toi")
      final rawProducts = await ProductMatchingService.getPersonalizedProducts(
        userTags: _cachedUserTags!,
        count: 30,
        filteringMode: "discovery",
      );

      print('🎬 [INSPIRATION] ${rawProducts.length} produits bruts reçus');

      if (rawProducts.isEmpty) {
        _hasError = true;
        _errorMessage = 'Aucun produit disponible';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Convertir et filtrer les produits avec images valides
      final validProducts = _processRawProducts(rawProducts, maxCount: 20);

      print('🎬 [INSPIRATION] ${validProducts.length} produits valides');

      if (validProducts.isEmpty) {
        _hasError = true;
        _errorMessage = 'Aucun produit avec image disponible';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _products = validProducts;
      _currentIndex = 0;
      _isLoading = false;
      _hasError = false;
      notifyListeners();

      print('✅ [INSPIRATION] Chargement terminé: ${_products.length} produits');

    } catch (e, stack) {
      print('❌ [INSPIRATION] Erreur: $e');
      print('Stack: ${stack.toString().split('\n').take(5).join('\n')}');

      _hasError = true;
      _errorMessage = 'Erreur de chargement: ${e.toString().substring(0, e.toString().length > 100 ? 100 : e.toString().length)}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✨ INFINITE SCROLL: Charge plus de produits et les ajoute à la liste
  Future<void> loadMoreProducts() async {
    // Ne pas recharger si déjà en cours
    if (_isLoadingMore || _isLoading) {
      print('⏳ [INSPIRATION] Chargement déjà en cours, ignoré');
      return;
    }

    print('♾️ [INSPIRATION] Chargement de plus de produits (infinite scroll)...');

    _isLoadingMore = true;
    notifyListeners();

    try {
      // Utiliser les tags en cache ou les recharger
      final userTags = _cachedUserTags ?? await FirebaseDataService.loadUserProfileTags() ?? {};

      // Charger de nouveaux produits en excluant ceux déjà vus
      final rawProducts = await ProductMatchingService.getPersonalizedProducts(
        userTags: userTags,
        count: 30,
        filteringMode: "discovery",
        excludeProductIds: _seenProductIds.toList(),
      );

      print('♾️ [INSPIRATION] ${rawProducts.length} nouveaux produits bruts reçus');

      if (rawProducts.isEmpty) {
        // Si plus de produits, on reset les IDs vus pour recommencer
        print('♾️ [INSPIRATION] Plus de nouveaux produits, reset du cycle...');
        _seenProductIds.clear();

        // Recharger sans exclusion
        final refreshedProducts = await ProductMatchingService.getPersonalizedProducts(
          userTags: userTags,
          count: 30,
          filteringMode: "discovery",
        );

        final validProducts = _processRawProducts(refreshedProducts, maxCount: 20);

        if (validProducts.isNotEmpty) {
          _products.addAll(validProducts);
          print('♾️ [INSPIRATION] ${validProducts.length} produits ajoutés (cycle restart)');
        }
      } else {
        // Ajouter les nouveaux produits
        final validProducts = _processRawProducts(rawProducts, maxCount: 20);

        if (validProducts.isNotEmpty) {
          _products.addAll(validProducts);
          print('♾️ [INSPIRATION] ${validProducts.length} nouveaux produits ajoutés');
        }
      }

      _isLoadingMore = false;
      notifyListeners();

      print('✅ [INSPIRATION] Total produits maintenant: ${_products.length}');

    } catch (e, stack) {
      print('❌ [INSPIRATION] Erreur loadMore: $e');
      print('Stack: ${stack.toString().split('\n').take(3).join('\n')}');
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Convertit les produits bruts en produits validés avec images
  List<Map<String, dynamic>> _processRawProducts(
    List<Map<String, dynamic>> rawProducts, {
    int maxCount = 20,
  }) {
    final validProducts = <Map<String, dynamic>>[];

    for (final product in rawProducts) {
      final productId = product['id']?.toString() ?? '';

      // Skip si déjà vu
      if (productId.isNotEmpty && _seenProductIds.contains(productId)) {
        continue;
      }

      // Extraire l'image de façon sécurisée
      String imageUrl = '';
      for (final key in ['image', 'imageUrl', 'photo', 'productPhoto', 'product_photo']) {
        final value = product[key];
        if (value != null && value.toString().isNotEmpty && value.toString().startsWith('http')) {
          imageUrl = value.toString();
          break;
        }
      }

      // Ne garder que les produits avec image valide
      if (imageUrl.isEmpty) {
        continue;
      }

      // Conversion sécurisée du prix
      int price = 0;
      final priceRaw = product['price'];
      if (priceRaw is int) {
        price = priceRaw;
      } else if (priceRaw is double) {
        price = priceRaw.toInt();
      } else if (priceRaw is String) {
        price = int.tryParse(priceRaw.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      }

      // Conversion sécurisée du match score
      int matchScore = 85;
      final matchRaw = product['_matchScore'];
      if (matchRaw is int) {
        matchScore = matchRaw.clamp(0, 100);
      } else if (matchRaw is double) {
        matchScore = matchRaw.toInt().clamp(0, 100);
      }

      final validProduct = {
        'id': productId,
        'name': product['name']?.toString() ?? 'Produit',
        'brand': product['brand']?.toString() ?? '',
        'price': price,
        'image': imageUrl,
        'url': product['url']?.toString() ?? '',
        'source': product['source']?.toString() ?? 'Amazon',
        'match': matchScore,
      };

      validProducts.add(validProduct);

      // Marquer comme vu
      if (productId.isNotEmpty) {
        _seenProductIds.add(productId);
      }

      // Limiter
      if (validProducts.length >= maxCount) break;
    }

    return validProducts;
  }

  /// Change l'index courant (après swipe)
  /// ✨ INFINITE SCROLL: Déclenche le chargement de plus de produits quand on approche de la fin
  void setCurrentIndex(int index) {
    if (index >= 0 && index < _products.length) {
      _currentIndex = index;
      notifyListeners();

      // ✨ INFINITE SCROLL: Charger plus quand on est à 3 produits de la fin
      final remainingProducts = _products.length - index - 1;
      if (remainingProducts <= 3 && !_isLoadingMore && !_isLoading) {
        print('♾️ [INSPIRATION] Proche de la fin ($remainingProducts restants), chargement automatique...');
        loadMoreProducts();
      }
    }
  }

  /// Vérifie si on est proche de la fin (pour afficher un indicateur)
  bool get isNearEnd => _products.length - _currentIndex <= 5;

  /// Obtient le produit à un index donné de façon sécurisée
  Map<String, dynamic>? getProductAt(int index) {
    if (index >= 0 && index < _products.length) {
      return _products[index];
    }
    return null;
  }

  @override
  void dispose() {
    _products.clear();
    super.dispose();
  }
}
