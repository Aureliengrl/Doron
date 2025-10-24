import 'package:flutter/material.dart';
import '/services/openai_service.dart';
import '/services/firebase_data_service.dart';

class GiftResultsModel {
  String activeFilter = 'Tous';
  Set<int> likedGifts = {};
  bool isLoading = true;

  late List<AnimationController> animationControllers;
  late List<Animation<double>> fadeAnimations;
  late List<Animation<Offset>> slideAnimations;

  final List<String> filters = [
    'Tous',
    'Meilleur match',
    'Prix croissant',
    'Prix décroissant',
  ];

  List<Map<String, dynamic>> giftResults = [];

  /// Charge les cadeaux générés par l'IA
  Future<void> loadGifts() async {
    try {
      isLoading = true;

      // Charger les réponses d'onboarding depuis Firebase
      final onboardingAnswers =
          await FirebaseDataService.loadOnboardingAnswers();

      if (onboardingAnswers == null || onboardingAnswers.isEmpty) {
        print('❌ Aucune réponse d\'onboarding trouvée');
        _loadFallbackGifts();
        isLoading = false;
        return;
      }

      // Générer des suggestions avec OpenAI
      print('🤖 Génération des cadeaux avec OpenAI...');
      giftResults = await OpenAIService.generateGiftSuggestions(
        onboardingAnswers: onboardingAnswers,
        count: 12,
      );

      print('✅ ${giftResults.length} cadeaux générés');
      isLoading = false;
    } catch (e) {
      print('❌ Erreur lors du chargement des cadeaux: $e');
      _loadFallbackGifts();
      isLoading = false;
    }
  }

  /// Cadeaux de secours si l'IA échoue
  void _loadFallbackGifts() {
    giftResults = [
      {
        'id': 1,
        'name': 'Coffret Spa Luxe Premium',
        'description':
            'Un moment de détente incomparable avec ce coffret spa comprenant huiles essentielles, bougies parfumées et accessoires de massage.',
        'price': 89,
        'image':
            'https://images.unsplash.com/photo-1596755389378-c31d21fd1273?w=600&q=80',
        'source': 'Sephora',
        'brand': 'Sephora',
        'match': 95,
        'reason':
            'Parfait pour se détendre après une longue journée. Correspond aux goûts pour le bien-être.',
      },
      {
        'id': 2,
        'name': 'Livre de Recettes Gourmet',
        'description':
            'Plus de 200 recettes raffinées pour des moments conviviaux en famille. Photos magnifiques et instructions détaillées.',
        'price': 35,
        'image':
            'https://images.unsplash.com/photo-1543362906-acfc16c67564?w=600&q=80',
        'source': 'Fnac',
        'brand': 'Fnac',
        'match': 92,
        'reason':
            'Pour les amateurs de cuisine. Ce livre inspirera de nouvelles créations culinaires.',
      },
      {
        'id': 3,
        'name': 'Bougie Parfumée Artisanale',
        'description':
            'Bougie de luxe faite à la main, parfum envoûtant de vanille et fleur d\'oranger. Durée de combustion: 60h.',
        'price': 45,
        'image':
            'https://images.unsplash.com/photo-1602874801006-e0c97c1c6122?w=600&q=80',
        'source': 'Zara Home',
        'brand': 'Zara',
        'match': 88,
        'reason':
            'Pour créer une ambiance cosy à la maison. Parfait pour les moments de relaxation en soirée.',
      },
    ];
  }

  void initAnimations(TickerProvider vsync) {
    animationControllers = List.generate(
      giftResults.length,
      (index) => AnimationController(
        vsync: vsync,
        duration: Duration(milliseconds: 600 + (index * 100)),
      ),
    );

    fadeAnimations = animationControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      );
    }).toList();

    slideAnimations = animationControllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      );
    }).toList();

    // Start animations
    for (var controller in animationControllers) {
      controller.forward();
    }
  }

  void toggleLike(int giftId) async {
    if (likedGifts.contains(giftId)) {
      likedGifts.remove(giftId);
      // Retirer des favoris Firebase
      await FirebaseDataService.removeFromFavorites(giftId.toString());
    } else {
      likedGifts.add(giftId);
      // Ajouter aux favoris Firebase
      final gift = giftResults.firstWhere((g) => g['id'] == giftId);
      await FirebaseDataService.addToFavorites(gift);
    }
  }

  void dispose() {
    for (var controller in animationControllers) {
      controller.dispose();
    }
  }
}
