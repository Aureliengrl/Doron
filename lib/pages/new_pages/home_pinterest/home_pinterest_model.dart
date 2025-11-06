class HomePinterestModel {
  String activeCategory = 'Pour toi';
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

  void dispose() {
    // Cleanup if needed
  }
}
