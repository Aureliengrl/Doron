import 'package:flutter/material.dart';
import '/services/product_matching_service.dart';
import '/services/firebase_data_service.dart';

/// Model SIMPLIFIÉ pour Mode Inspiration (TikTok style)
/// Utilise EXACTEMENT les mêmes produits que "Pour toi" sur la page d'accueil
class TikTokInspirationPageModel extends ChangeNotifier {
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentIndex = 0;

  // Favoris
  Set<String> likedProductTitles = {};

  // Getters
  List<Map<String, dynamic>> get products => _products;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  int get currentIndex => _currentIndex;

  /// Charge les produits - MÊME SOURCE que "Pour toi"
  Future<void> loadProducts() async {
    print('🎬 [INSPIRATION] Début chargement produits...');

    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      // Charger les tags utilisateur (comme la page d'accueil)
      final userTags = await FirebaseDataService.loadUserProfileTags() ?? {};
      print('🎬 [INSPIRATION] Tags utilisateur: $userTags');

      // Charger les produits via ProductMatchingService (MÊME que "Pour toi")
      final rawProducts = await ProductMatchingService.getPersonalizedProducts(
        userTags: userTags,
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
      final validProducts = <Map<String, dynamic>>[];

      for (final product in rawProducts) {
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
          print('⚠️ [INSPIRATION] Produit sans image ignoré: ${product['name']}');
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

        validProducts.add({
          'id': product['id']?.toString() ?? '',
          'name': product['name']?.toString() ?? 'Produit',
          'brand': product['brand']?.toString() ?? '',
          'price': price,
          'image': imageUrl,
          'url': product['url']?.toString() ?? '',
          'source': product['source']?.toString() ?? 'Amazon',
          'match': matchScore,
        });

        // Limiter à 20 produits max
        if (validProducts.length >= 20) break;
      }

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

  /// Change l'index courant (après swipe)
  void setCurrentIndex(int index) {
    if (index >= 0 && index < _products.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

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
