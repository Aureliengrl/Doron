class HomePinterestModel {
  String activeCategory = 'Pour toi';
  Set<int> likedProducts = {};
  Map<String, dynamic>? selectedProduct;

  final List<Map<String, String>> categories = [
    {'id': 'all', 'name': 'Pour toi', 'emoji': '✨'},
    {'id': 'trending', 'name': 'Tendances', 'emoji': '🔥'},
    {'id': 'tech', 'name': 'Tech', 'emoji': '📱'},
    {'id': 'fashion', 'name': 'Mode', 'emoji': '👗'},
    {'id': 'home', 'name': 'Maison', 'emoji': '🏠'},
    {'id': 'beauty', 'name': 'Beauté', 'emoji': '💄'},
    {'id': 'food', 'name': 'Food', 'emoji': '🍷'},
  ];

  final List<Map<String, dynamic>> products = [
    {
      'id': 1,
      'name': 'Carnet de Voyage Artisanal',
      'description':
          'Parfait pour immortaliser tes aventures à travers le monde. Couverture en cuir véritable.',
      'price': 45,
      'image':
          'https://images.unsplash.com/photo-1531346878377-a5be20888e57?w=600&q=80',
      'brand': 'Moleskine',
      'source': 'Amazon',
      'match': 95,
    },
    {
      'id': 2,
      'name': 'Enceinte Bluetooth Premium',
      'description':
          'Son cristallin et design moderne pour toutes tes soirées. Autonomie 12h.',
      'price': 89,
      'image':
          'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=600&q=80',
      'brand': 'JBL',
      'source': 'Fnac',
      'match': 88,
    },
    {
      'id': 3,
      'name': 'Coffret Soin Visage Bio',
      'description':
          'Routine beauté complète avec des produits naturels certifiés bio.',
      'price': 65,
      'image':
          'https://images.unsplash.com/photo-1596755389378-c31d21fd1273?w=600&q=80',
      'brand': 'Sephora',
      'source': 'Sephora',
      'match': 82,
    },
    {
      'id': 4,
      'name': 'Poster Carte du Monde',
      'description':
          'Marque toutes tes destinations de voyage. Format XXL 100x70cm.',
      'price': 35,
      'image':
          'https://images.unsplash.com/photo-1526778548025-fa2f459cd5c1?w=600&q=80',
      'brand': 'Luckies',
      'source': 'Amazon',
      'match': 91,
    },
    {
      'id': 5,
      'name': 'Appareil Photo Instantané',
      'description':
          'Capture l\'instant présent avec style. Impression instantanée format crédit.',
      'price': 129,
      'image':
          'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=600&q=80',
      'brand': 'Fujifilm',
      'source': 'Fnac',
      'match': 85,
    },
    {
      'id': 6,
      'name': 'Bougie Parfumée Luxe',
      'description':
          'Ambiance cosy et parfum envoûtant. 3 mèches pour une diffusion optimale.',
      'price': 42,
      'image':
          'https://images.unsplash.com/photo-1602874801006-e0c97c1c6122?w=600&q=80',
      'brand': 'Zara Home',
      'source': 'Zara',
      'match': 78,
    },
    {
      'id': 7,
      'name': 'Casque Audio Sans Fil',
      'description':
          'Immersion totale dans ta musique. Réduction de bruit active.',
      'price': 159,
      'image':
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600&q=80',
      'brand': 'Sony',
      'source': 'Fnac',
      'match': 93,
    },
    {
      'id': 8,
      'name': 'Set de Pinceaux Premium',
      'description':
          'Pour libérer toute ta créativité. 12 pinceaux professionnels.',
      'price': 55,
      'image':
          'https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=600&q=80',
      'brand': 'Windsor & Newton',
      'source': 'Amazon',
      'match': 89,
    },
  ];

  void toggleLike(int productId) {
    if (likedProducts.contains(productId)) {
      likedProducts.remove(productId);
    } else {
      likedProducts.add(productId);
    }
  }

  void dispose() {
    // Cleanup if needed
  }
}
