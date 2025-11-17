class HomePinterestModel {
  String activeCategory = 'Pour toi';
  String activePriceFilter = 'all';
  Set<int> likedProducts = {};
  Set<String> likedProductTitles = {}; // Pour FlutterFlow system (par titre)
  Map<String, dynamic>? selectedProduct;
  bool isLoading = false;
  bool isLoadingMore = false;
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> sections = []; // Sections thématiques pour l'accueil
  String firstName = '';
  String searchQuery = '';
  String? errorMessage;
  String? errorDetails;

  // Quick filters
  bool showOnlyFavorites = false;
  bool showOnlyNew = false;
  bool showFreeShipping = false;

  // Pagination
  static const int productsPerPage = 12;
  int currentPage = 0;
  bool hasMore = true;

  final List<Map<String, String>> categories = [
    {'id': 'all', 'name': 'Pour toi', 'emoji': '✨'},
    {'id': 'mode', 'name': 'Mode', 'emoji': '👗'},
    {'id': 'beaute', 'name': 'Beauté', 'emoji': '💄'},
    {'id': 'chaussures', 'name': 'Chaussures', 'emoji': '👟'},
    {'id': 'accessoires', 'name': 'Accessoires', 'emoji': '👜'},
    {'id': 'sport', 'name': 'Sport', 'emoji': '⚽'},
    {'id': 'maison', 'name': 'Maison', 'emoji': '🏠'},
  ];

  final List<Map<String, dynamic>> priceFilters = [
    {'id': 'all', 'name': 'Tous les prix', 'min': 0, 'max': 999999},
    {'id': 'low', 'name': '< 50€', 'min': 0, 'max': 50},
    {'id': 'medium', 'name': '50-100€', 'min': 50, 'max': 100},
    {'id': 'high', 'name': '100-200€', 'min': 100, 'max': 200},
    {'id': 'premium', 'name': '> 200€', 'min': 200, 'max': 999999},
  ];

  void toggleLike(int productId) {
    if (likedProducts.contains(productId)) {
      likedProducts.remove(productId);
    } else {
      likedProducts.add(productId);
    }
  }

  void setLoading(bool loading) {
    isLoading = loading;
  }

  void setProducts(List<Map<String, dynamic>> newProducts) {
    // Supprimer les doublons en utilisant un Set basé sur l'ID
    final seenIds = <dynamic>{};
    products = newProducts.where((product) {
      final productId = product['id'];
      if (seenIds.contains(productId)) {
        return false; // Doublon, on l'ignore
      }
      seenIds.add(productId);
      return true; // Premier occurrence, on le garde
    }).toList();
  }

  void setSections(List<Map<String, dynamic>> newSections) {
    sections = newSections;
  }

  void setFirstName(String name) {
    firstName = name;
  }

  void setLoadingMore(bool loading) {
    isLoadingMore = loading;
  }

  void addProducts(List<Map<String, dynamic>> newProducts) {
    // Créer un Set des IDs existants pour éviter les doublons
    final existingIds = products.map((p) => p['id']).toSet();

    // Filtrer les nouveaux produits pour ne garder que ceux qui n'existent pas déjà
    final uniqueNewProducts = newProducts.where((product) {
      final productId = product['id'];
      return !existingIds.contains(productId);
    }).toList();

    // Ajouter uniquement les produits uniques
    products.addAll(uniqueNewProducts);
  }

  void resetPagination() {
    currentPage = 0;
    hasMore = true;
    products.clear();
  }

  void incrementPage() {
    currentPage++;
  }

  void setSearchQuery(String query) {
    searchQuery = query;
  }

  void toggleQuickFilter(String filter) {
    switch (filter) {
      case 'favorites':
        showOnlyFavorites = !showOnlyFavorites;
        break;
      case 'new':
        showOnlyNew = !showOnlyNew;
        break;
      case 'shipping':
        showFreeShipping = !showFreeShipping;
        break;
    }
  }

  void setError(String? message, String? details) {
    errorMessage = message;
    errorDetails = details;
  }

  void clearError() {
    errorMessage = null;
    errorDetails = null;
  }

  /// Retourne les produits filtrés selon le prix, la recherche et les quick filters
  List<Map<String, dynamic>> getFilteredProducts() {
    var filtered = products;

    // Filtre par prix
    if (activePriceFilter != 'all') {
      final filter = priceFilters.firstWhere(
        (f) => f['id'] == activePriceFilter,
        orElse: () => priceFilters.first,
      );

      final minPrice = filter['min'] as int;
      final maxPrice = filter['max'] as int;

      filtered = filtered.where((product) {
        final price = product['price'];
        final priceValue = price is int ? price : (price is double ? price.toInt() : 0);
        return priceValue >= minPrice && priceValue < maxPrice;
      }).toList();
    }

    // Filtre par recherche
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((product) {
        final name = (product['name'] as String? ?? '').toLowerCase();
        final brand = (product['brand'] as String? ?? '').toLowerCase();
        final description = (product['description'] as String? ?? '').toLowerCase();
        return name.contains(query) || brand.contains(query) || description.contains(query);
      }).toList();
    }

    // Quick filter : Favoris uniquement
    if (showOnlyFavorites) {
      filtered = filtered.where((product) {
        return likedProducts.contains(product['id']);
      }).toList();
    }

    return filtered;
  }

  void dispose() {
    // Cleanup - clear products and liked list to free memory
    products.clear();
    likedProducts.clear();
    selectedProduct = null;
  }
}
