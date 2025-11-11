import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/services/openai_home_service.dart';
import '/services/firebase_data_service.dart';

/// Model pour la page TikTok Inspiration (BÊTA)
class TikTokInspirationPageModel extends ChangeNotifier {
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  String _errorDetails = '';

  int _currentProductIndex = 0;
  int _currentPhotoIndex = 0;

  // Getters
  List<Map<String, dynamic>> get products => _products;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  String get errorDetails => _errorDetails;
  int get currentProductIndex => _currentProductIndex;
  int get currentPhotoIndex => _currentPhotoIndex;

  /// Charge les produits via OpenAI Home Service
  Future<void> loadProducts() async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      // Charger le profil utilisateur
      final userProfile = await FirebaseDataService.loadOnboardingAnswers();

      // Charger les produits déjà vus
      final prefs = await SharedPreferences.getInstance();
      final seenProductsJson = prefs.getStringList('seen_home_products_Tout') ?? [];

      // Ajouter variation pour diversité
      final profileWithVariation = {
        ...?userProfile,
        '_refresh_timestamp': DateTime.now().millisecondsSinceEpoch,
        '_variation_seed': DateTime.now().microsecond,
        '_seen_products': seenProductsJson,
        '_page': 0,
      };

      // Générer 20 produits pour l'expérience TikTok
      final products = await OpenAIHomeService.generateHomeProducts(
        category: 'Tout',
        userProfile: profileWithVariation,
        count: 20,
      );

      // Mettre à jour le cache
      final newSeenProducts = [...seenProductsJson];
      for (var product in products) {
        final productName = '${product['brand']}_${product['name']}';
        if (!newSeenProducts.contains(productName)) {
          newSeenProducts.add(productName);
        }
      }
      if (newSeenProducts.length > 200) {
        newSeenProducts.removeRange(0, newSeenProducts.length - 200);
      }
      await prefs.setStringList('seen_home_products_Tout', newSeenProducts);

      _products = products;
      _isLoading = false;
      notifyListeners();

      print('✅ TikTok Inspiration: ${products.length} produits chargés');
    } catch (e) {
      print('❌ Erreur chargement TikTok Inspiration: $e');

      // Parser l'erreur pour extraire des détails utiles
      String errorDetails = e.toString();

      // Analyser le type d'erreur
      if (errorDetails.contains('401')) {
        _errorMessage = '🔑 Clé API invalide';
        _errorDetails = 'La clé OpenAI n\'est plus valide. Les produits ne peuvent pas être générés.';
      } else if (errorDetails.contains('429')) {
        _errorMessage = '⚠️ Quota API dépassé';
        _errorDetails = 'Le quota OpenAI a été atteint. Réessaye plus tard.';
      } else if (errorDetails.contains('500') || errorDetails.contains('502') || errorDetails.contains('503')) {
        _errorMessage = '🔧 Serveur indisponible';
        _errorDetails = 'Le serveur OpenAI a un problème temporaire. Réessaye dans quelques minutes.';
      } else if (errorDetails.contains('SocketException') || errorDetails.contains('Network')) {
        _errorMessage = '📡 Pas de connexion';
        _errorDetails = 'Vérifie ta connexion internet et réessaye.';
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
