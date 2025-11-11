import '/backend/schema/structs/index.dart';
import '/services/openai_service.dart';

/// Utilitaire pour convertir les résultats OpenAI en ProductsStruct
class GiftSearchHelper {
  /// Génère des cadeaux personnalisés via OpenAI
  static Future<List<ProductsStruct>> generatePersonalizedGifts({
    required String recipient,
    required String age,
    required List<String> interests,
    required double minBudget,
    required double maxBudget,
  }) async {
    try {
      print('🎁 Génération de cadeaux personnalisés...');
      print('   Pour: $recipient, $age ans');
      print('   Intérêts: ${interests.join(", ")}');
      print('   Budget: $minBudget€ - $maxBudget€');

      // Créer le profil pour OpenAI
      final onboardingAnswers = {
        'recipient': recipient,
        'recipientAge': age,
        'recipientHobbies': interests,
        'budget': (minBudget + maxBudget) / 2, // Budget moyen
        'recipientPersonality': [], // Vide pour l'instant
        'occasion': 'cadeau',
      };

      // Appeler OpenAI pour générer des suggestions personnalisées
      final gifts = await OpenAIService.generateGiftSuggestions(
        onboardingAnswers: onboardingAnswers,
        count: 12,
      );

      print('✅ ${gifts.length} cadeaux générés par OpenAI');

      // Convertir en ProductsStruct
      final products = gifts.map((gift) {
        return ProductsStruct(
          productTitle: gift['name'] as String? ?? 'Cadeau',
          productPrice: '${gift['price']}€',
          productUrl: gift['url'] as String? ?? '',
          productPhoto: gift['image'] as String? ??
              'https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=600&q=80',
          productStarRating: '${(gift['match'] ?? 80) / 20}', // Match sur 5
          productNumRatings: 100 + (gift['id'] as int? ?? 0) * 10,
          productOriginalPrice: '${((gift['price'] as int? ?? 0) * 1.2).toInt()}€',
        );
      }).toList();

      print('✅ ${products.length} produits convertis');
      return products;
    } catch (e) {
      print('❌ Erreur génération cadeaux: $e');
      // Retourner des produits de secours
      return _getFallbackProducts();
    }
  }

  /// Produits de secours en cas d'erreur
  static List<ProductsStruct> _getFallbackProducts() {
    return [
      ProductsStruct(
        productTitle: 'AirPods Pro 2ème génération - Écouteurs sans fil avec réduction de bruit',
        productPrice: '279€',
        productUrl: 'https://www.apple.com/fr/airpods-pro/',
        productPhoto: 'https://images.unsplash.com/photo-1606841837239-c5a1a4a07af7?w=600&q=80',
        productStarRating: '4.8',
        productNumRatings: 15432,
        productOriginalPrice: '329€',
      ),
      ProductsStruct(
        productTitle: 'Pull en Cachemire Premium - Douceur incomparable',
        productPrice: '89€',
        productUrl: 'https://www.zara.com/fr',
        productPhoto: 'https://images.unsplash.com/photo-1576871337632-b9aef4c17ab9?w=600&q=80',
        productStarRating: '4.5',
        productNumRatings: 892,
        productOriginalPrice: '119€',
      ),
      ProductsStruct(
        productTitle: 'Coffret Skincare Sephora - Routine complète pour une peau éclatante',
        productPrice: '65€',
        productUrl: 'https://www.sephora.fr',
        productPhoto: 'https://images.unsplash.com/photo-1596755389378-c31d21fd1273?w=600&q=80',
        productStarRating: '4.7',
        productNumRatings: 3241,
        productOriginalPrice: '85€',
      ),
      ProductsStruct(
        productTitle: 'Bougie Parfumée Diptyque - Ambiance cosy instantanée',
        productPrice: '68€',
        productUrl: 'https://www.sephora.fr',
        productPhoto: 'https://images.unsplash.com/photo-1602874801006-e0c97c1c6122?w=600&q=80',
        productStarRating: '4.9',
        productNumRatings: 1876,
        productOriginalPrice: '78€',
      ),
      ProductsStruct(
        productTitle: 'Nike Air Max 90 - Sneakers iconiques, confort maximal',
        productPrice: '140€',
        productUrl: 'https://www.nike.com/fr',
        productPhoto: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600&q=80',
        productStarRating: '4.6',
        productNumRatings: 8765,
        productOriginalPrice: '160€',
      ),
      ProductsStruct(
        productTitle: 'PlayStation 5 - Console next-gen, expérience gaming immersive',
        productPrice: '549€',
        productUrl: 'https://www.fnac.com',
        productPhoto: 'https://images.unsplash.com/photo-1606813907291-d86efa9b94db?w=600&q=80',
        productStarRating: '4.9',
        productNumRatings: 23456,
        productOriginalPrice: '599€',
      ),
    ];
  }
}
