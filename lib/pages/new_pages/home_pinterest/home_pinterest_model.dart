class HomePinterestModel {
  String activeCategory = 'Pour toi';
  String activePriceFilter = 'all';
  Set<int> likedProducts = {};
  Map<String, dynamic>? selectedProduct;
  bool isLoading = false;
  List<Map<String, dynamic>> products = [];
  String firstName = '';

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

  /// Retourne les produits filtrés selon le prix sélectionné
  List<Map<String, dynamic>> getFilteredProducts() {
    if (activePriceFilter == 'all') {
      return products;
    }

    final filter = priceFilters.firstWhere(
      (f) => f['id'] == activePriceFilter,
      orElse: () => priceFilters.first,
    );

    final minPrice = filter['min'] as int;
    final maxPrice = filter['max'] as int;

    return products.where((product) {
      final price = product['price'];
      final priceValue = price is int ? price : (price is double ? price.toInt() : 0);
      return priceValue >= minPrice && priceValue < maxPrice;
    }).toList();
  }

  void dispose() {
    // Cleanup if needed
  }
}
