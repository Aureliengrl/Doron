class HomePinterestModel {
  String activeCategory = 'Pour toi';
  String activePriceFilter = 'all';
  Set<int> likedProducts = {};
  Map<String, dynamic>? selectedProduct;
  bool isLoading = false;
  bool isLoadingMore = false;
  List<Map<String, dynamic>> products = [];
  String firstName = '';
  String searchQuery = '';

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
    {'id': 'trending', 'name': 'Tendances', 'emoji': '🔥'},
    {'id': 'tech', 'name': 'Tech', 'emoji': '📱'},
    {'id': 'fashion', 'name': 'Mode', 'emoji': '👗'},
    {'id': 'home', 'name': 'Maison', 'emoji': '🏠'},
    {'id': 'beauty', 'name': 'Beauté', 'emoji': '💄'},
    {'id': 'food', 'name': 'Food', 'emoji': '🍷'},
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
    products = newProducts;
  }

  void setFirstName(String name) {
    firstName = name;
  }

  void setLoadingMore(bool loading) {
    isLoadingMore = loading;
  }

  void addProducts(List<Map<String, dynamic>> newProducts) {
    products.addAll(newProducts);
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
