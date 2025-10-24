import 'package:flutter/material.dart';

class GiftResultsModel {
  String activeFilter = 'Tous';
  Set<int> likedGifts = {};

  late List<AnimationController> animationControllers;
  late List<Animation<double>> fadeAnimations;
  late List<Animation<Offset>> slideAnimations;

  final List<String> filters = [
    'Tous',
    'Meilleur match',
    'Prix croissant',
    'Prix décroissant',
  ];

  final List<Map<String, dynamic>> giftResults = [
    {
      'id': 1,
      'name': 'Coffret Spa Luxe Premium',
      'description':
          'Un moment de détente incomparable avec ce coffret spa comprenant huiles essentielles, bougies parfumées et accessoires de massage.',
      'price': 89,
      'image':
          'https://images.unsplash.com/photo-1596755389378-c31d21fd1273?w=600&q=80',
      'source': 'Sephora',
      'match': 95,
      'reason':
          'Parfait pour une maman qui mérite de se détendre après une longue journée. Correspond à ses goûts pour le bien-être.',
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
      'match': 92,
      'reason':
          'Elle adore cuisiner et partager des repas en famille. Ce livre l\'inspirera pour de nouvelles créations culinaires.',
    },
    {
      'id': 3,
      'name': 'Bougie Parfumée Artisanale',
      'description':
          'Bougie de luxe faite à la main, parfum envoûtant de vanille et fleur d\'oranger. Durée de combustion: 60h.',
      'price': 45,
      'image':
          'https://images.unsplash.com/photo-1602874801006-e0c97c1c6122?w=600&q=80',
      'source': 'Zara',
      'match': 88,
      'reason':
          'Pour créer une ambiance cosy à la maison. Parfait pour ses moments de relaxation en soirée.',
    },
    {
      'id': 4,
      'name': 'Carnet de Voyage en Cuir',
      'description':
          'Carnet artisanal avec couverture en cuir véritable. Idéal pour noter ses souvenirs et voyages.',
      'price': 42,
      'image':
          'https://images.unsplash.com/photo-1531346878377-a5be20888e57?w=600&q=80',
      'source': 'Amazon',
      'match': 85,
      'reason':
          'Elle aime voyager et garder des souvenirs. Ce carnet l\'accompagnera dans toutes ses aventures.',
    },
    {
      'id': 5,
      'name': 'Coffret Thé Premium',
      'description':
          'Sélection de 12 thés rares du monde entier dans un magnifique coffret en bois.',
      'price': 48,
      'image':
          'https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=600&q=80',
      'source': 'Kusmi Tea',
      'match': 90,
      'reason':
          'Amateur de thé, elle appréciera cette collection raffinée pour ses pauses détente quotidiennes.',
    },
    {
      'id': 6,
      'name': 'Plaid Cachemire Doux',
      'description':
          'Plaid ultra-doux en cachemire, parfait pour les soirées cocooning. Disponible en plusieurs couleurs.',
      'price': 85,
      'image':
          'https://images.unsplash.com/photo-1584100936595-c0654b55a2e2?w=600&q=80',
      'source': 'Zara Home',
      'match': 87,
      'reason':
          'Pour des moments cosy au coin du feu. La douceur du cachemire apporte un confort exceptionnel.',
    },
    {
      'id': 7,
      'name': 'Kit Jardinage Premium',
      'description':
          'Ensemble complet avec outils de qualité professionnelle et gants en cuir. Pour jardiniers passionnés.',
      'price': 75,
      'image':
          'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=600&q=80',
      'source': 'Leroy Merlin',
      'match': 84,
      'reason':
          'Elle adore jardiner et prendre soin de ses plantes. Ces outils de qualité rendront cette passion encore plus agréable.',
    },
    {
      'id': 8,
      'name': 'Diffuseur d\'Huiles Essentielles',
      'description':
          'Diffuseur élégant en céramique avec 6 huiles essentielles bio incluses. Design minimaliste.',
      'price': 55,
      'image':
          'https://images.unsplash.com/photo-1608571423902-eed4a5ad8108?w=600&q=80',
      'source': 'Nature & Découvertes',
      'match': 91,
      'reason':
          'Pour créer une atmosphère apaisante à la maison. Les huiles essentielles favorisent la détente et le bien-être.',
    },
  ];

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

  void toggleLike(int giftId) {
    if (likedGifts.contains(giftId)) {
      likedGifts.remove(giftId);
    } else {
      likedGifts.add(giftId);
    }
  }

  void dispose() {
    for (var controller in animationControllers) {
      controller.dispose();
    }
  }
}
