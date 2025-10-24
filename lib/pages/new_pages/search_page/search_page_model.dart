class SearchPageModel {
  int selectedProfileId = 1;
  Set<int> likedProducts = {};

  final List<Map<String, dynamic>> profiles = [
    {
      'id': 1,
      'name': 'Maman',
      'initials': 'M',
      'color': '#ec4899',
      'relation': 'Ma mère',
      'occasion': 'Anniversaire',
    },
  ];

  final List<Map<String, dynamic>> searchResults = [
    {
      'id': 1,
      'name': 'Coffret Spa Luxe',
      'description': 'Pour se détendre après une longue journée',
      'price': 89,
      'image':
          'https://images.unsplash.com/photo-1596755389378-c31d21fd1273?w=600&q=80',
      'profileId': 1,
      'source': 'Sephora',
    },
    {
      'id': 2,
      'name': 'Livre de Recettes',
      'description': 'Pour des moments en famille',
      'price': 35,
      'image':
          'https://images.unsplash.com/photo-1543362906-acfc16c67564?w=600&q=80',
      'profileId': 1,
      'source': 'Fnac',
    },
    {
      'id': 3,
      'name': 'Bougie Parfumée Premium',
      'description': 'Ambiance cosy garantie',
      'price': 42,
      'image':
          'https://images.unsplash.com/photo-1602874801006-e0c97c1c6122?w=600&q=80',
      'profileId': 1,
      'source': 'Zara',
    },
    {
      'id': 4,
      'name': 'Carnet de Voyage',
      'description': 'Immortaliser ses souvenirs',
      'price': 45,
      'image':
          'https://images.unsplash.com/photo-1531346878377-a5be20888e57?w=600&q=80',
      'profileId': 1,
      'source': 'Amazon',
    },
  ];

  Map<String, dynamic>? get currentProfile {
    try {
      return profiles.firstWhere((p) => p['id'] == selectedProfileId);
    } catch (e) {
      return null;
    }
  }

  List<Map<String, dynamic>> getFilteredProducts() {
    return searchResults
        .where((p) => p['profileId'] == selectedProfileId)
        .toList();
  }

  void selectProfile(int profileId) {
    selectedProfileId = profileId;
  }

  void toggleLike(int productId) {
    if (likedProducts.contains(productId)) {
      likedProducts.remove(productId);
    } else {
      likedProducts.add(productId);
    }
  }

  void handleAddNewPerson() {
    print('🎯 Redirection vers l\'onboarding "Pour qui veux-tu faire un cadeau ?"');
    // Navigation vers l'onboarding
  }

  void dispose() {
    // Cleanup if needed
  }
}
