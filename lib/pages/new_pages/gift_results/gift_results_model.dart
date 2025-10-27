import 'package:flutter/material.dart';
import '/services/openai_service.dart';
import '/services/firebase_data_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
        'url': 'https://www.sephora.fr',
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
        'url': 'https://www.fnac.com',
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
        'url': 'https://www.zara.com/fr/fr/home',
        'reason':
            'Pour créer une ambiance cosy à la maison. Parfait pour les moments de relaxation en soirée.',
      },
      {
        'id': 4,
        'name': 'Montre Connectée Fitness',
        'description':
            'Montre intelligente avec suivi d\'activité, fréquence cardiaque et GPS intégré.',
        'price': 199,
        'image':
            'https://images.unsplash.com/photo-1579586337278-3befd40fd17a?w=600&q=80',
        'source': 'Apple',
        'brand': 'Apple',
        'match': 90,
        'url': 'https://www.apple.com/fr/watch/',
        'reason':
            'Pour suivre ses objectifs fitness au quotidien avec style.',
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
        'brand': 'Kusmi Tea',
        'match': 87,
        'url': 'https://www.kusmitea.com/fr/',
        'reason':
            'Amateur de thé, elle appréciera cette collection raffinée.',
      },
      {
        'id': 6,
        'name': 'Plaid Cachemire Doux',
        'description':
            'Plaid ultra-doux en cachemire, parfait pour les soirées cocooning.',
        'price': 85,
        'image':
            'https://images.unsplash.com/photo-1584100936595-c0654b55a2e2?w=600&q=80',
        'source': 'Zara Home',
        'brand': 'Zara',
        'match': 86,
        'url': 'https://www.zara.com/fr/fr/home',
        'reason':
            'Pour des moments cosy au coin du feu.',
      },
      {
        'id': 7,
        'name': 'Kit Jardinage Premium',
        'description':
            'Ensemble complet avec outils de qualité professionnelle.',
        'price': 75,
        'image':
            'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=600&q=80',
        'source': 'Leroy Merlin',
        'brand': 'Leroy Merlin',
        'match': 84,
        'url': 'https://www.leroymerlin.fr',
        'reason':
            'Pour jardiner avec des outils de qualité.',
      },
      {
        'id': 8,
        'name': 'Diffuseur d\'Huiles Essentielles',
        'description':
            'Diffuseur élégant en céramique avec 6 huiles essentielles bio.',
        'price': 55,
        'image':
            'https://images.unsplash.com/photo-1608571423902-eed4a5ad8108?w=600&q=80',
        'source': 'Nature & Découvertes',
        'brand': 'Nature & Découvertes',
        'match': 91,
        'url': 'https://www.natureetdecouvertes.com',
        'reason':
            'Pour créer une atmosphère apaisante à la maison.',
      },
      {
        'id': 9,
        'name': 'Écouteurs Sans Fil Premium',
        'description':
            'Écouteurs Bluetooth avec réduction de bruit active.',
        'price': 149,
        'image':
            'https://images.unsplash.com/photo-1606841837239-c5a1a4a07af7?w=600&q=80',
        'source': 'Apple',
        'brand': 'Apple',
        'match': 89,
        'url': 'https://www.apple.com/fr/airpods/',
        'reason':
            'Pour écouter de la musique avec une qualité exceptionnelle.',
      },
      {
        'id': 10,
        'name': 'Carafe à Vin Design',
        'description':
            'Carafe en cristal pour aérer et sublimer vos meilleurs vins.',
        'price': 65,
        'image':
            'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?w=600&q=80',
        'source': 'Zara Home',
        'brand': 'Zara',
        'match': 83,
        'url': 'https://www.zara.com/fr/fr/home',
        'reason':
            'Pour les amateurs de vin qui aiment recevoir.',
      },
      {
        'id': 11,
        'name': 'Sac à Main en Cuir',
        'description':
            'Sac élégant en cuir véritable, pratique et intemporel.',
        'price': 120,
        'image':
            'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=600&q=80',
        'source': 'Mango',
        'brand': 'Mango',
        'match': 88,
        'url': 'https://www.mango.com/fr',
        'reason':
            'Un accessoire chic pour toutes les occasions.',
      },
      {
        'id': 12,
        'name': 'Coffret Soin Visage Bio',
        'description':
            'Routine complète de soin visage avec produits bio certifiés.',
        'price': 78,
        'image':
            'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=600&q=80',
        'source': 'Sephora',
        'brand': 'Sephora',
        'match': 92,
        'url': 'https://www.sephora.fr',
        'reason':
            'Pour prendre soin de sa peau naturellement.',
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

  /// Sauvegarde le profil actuel dans les recherches
  Future<void> saveCurrentProfile() async {
    try {
      // Charger les réponses d'onboarding
      final onboardingAnswers = await FirebaseDataService.loadOnboardingAnswers();
      if (onboardingAnswers == null) {
        print('❌ No onboarding answers to save as profile');
        return;
      }

      // Créer un profil à partir des réponses
      final recipient = onboardingAnswers['recipient'] as String? ?? 'Personne';
      final occasion = onboardingAnswers['occasion'] as String? ?? 'Occasion spéciale';

      // Extraire le nom du destinataire (ex: "👩 Ma mère" -> "Maman")
      String profileName = 'Personne';
      String initials = 'P';
      String relation = recipient;

      if (recipient.contains('mère')) {
        profileName = 'Maman';
        initials = 'M';
      } else if (recipient.contains('père')) {
        profileName = 'Papa';
        initials = 'P';
      } else if (recipient.contains('partenaire')) {
        profileName = 'Partenaire';
        initials = 'P';
      } else if (recipient.contains('enfant')) {
        profileName = 'Enfant';
        initials = 'E';
      } else if (recipient.contains('ami')) {
        profileName = 'Ami(e)';
        initials = 'A';
      } else if (recipient.contains('collègue')) {
        profileName = 'Collègue';
        initials = 'C';
      } else if (recipient.contains('Grand-parent')) {
        profileName = 'Grand-parent';
        initials = 'G';
      }

      // Couleurs aléatoires pour les profils
      final colors = ['#ec4899', '#8b5cf6', '#3b82f6', '#10b981', '#f59e0b', '#ef4444'];
      final color = colors[DateTime.now().millisecondsSinceEpoch % colors.length];

      final profile = {
        'name': profileName,
        'initials': initials,
        'color': color,
        'relation': relation,
        'occasion': occasion,
        'onboardingAnswers': onboardingAnswers,
        'gifts': giftResults, // Sauvegarder aussi les cadeaux générés
      };

      // Sauvegarder le profil
      await FirebaseDataService.saveGiftProfile(profile);
      print('✅ Profile "$profileName" saved successfully');
    } catch (e) {
      print('❌ Error saving profile: $e');
    }
  }

  void dispose() {
    for (var controller in animationControllers) {
      controller.dispose();
    }
  }
}
