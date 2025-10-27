import 'package:flutter/material.dart';
import 'dart:math' as math;
import '/services/firebase_data_service.dart';
import '/services/first_time_service.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingAdvancedModel {
  int currentStep = 0;
  Map<String, dynamic> answers = {
    // Onboarding "Toi"
    'age': '',
    'gender': '',
    'interests': <String>[],
    'style': '',
    'giftTypes': <String>[],
    // Onboarding "Cadeau" - AMÉLIORÉ
    'recipient': '',
    'budget': 50.0,
    'recipientAge': '',
    'recipientRelationDuration': '',
    'recipientHobbies': <String>[],
    'recipientPersonality': <String>[],
    'recipientLifeSituation': '',
    'recipientStyle': '',
    'occasion': '',
    'recipientAlreadyHas': <String>[],
    'specialMemory': '',
    'preferredCategories': <String>[],
  };

  // Animations
  late List<AnimationController> particleControllers;
  late List<Offset> particlePositions;
  late List<double> particleSizes;

  void initAnimations(TickerProvider vsync) {
    final random = math.Random();
    particleControllers = List.generate(
      20,
      (index) => AnimationController(
        vsync: vsync,
        duration: Duration(
          milliseconds: 2000 + random.nextInt(1000),
        ),
      )..repeat(reverse: true),
    );

    particlePositions = List.generate(
      20,
      (index) => Offset(
        random.nextDouble(),
        random.nextDouble(),
      ),
    );

    particleSizes = List.generate(
      20,
      (index) => 2.0 + random.nextDouble() * 4,
    );
  }

  void dispose() {
    for (var controller in particleControllers) {
      controller.dispose();
    }
  }

  List<Map<String, dynamic>> getSteps({bool skipUserQuestions = false}) {
    final baseSteps = <Map<String, dynamic>>[
      {
        'id': 'welcome',
        'type': 'welcome',
        'title': 'DORÕN',
        'subtitle': 'Find the perfect gift',
        'emoji': '', // Logo remplacera l'emoji
        'useLogo': true, // Indique d'utiliser le logo au lieu de l'emoji
      },
    ];

    // Si on ne skip pas, ajouter les questions sur l'utilisateur
    if (!skipUserQuestions) {
      baseSteps.addAll([
      // PARTIE "TOI"
      {
        'section': 'user',
        'id': 'age',
        'type': 'single',
        'question': 'Quel âge as-tu ?',
        'subtitle': '✨ Pour personnaliser ton expérience',
        'field': 'age',
        'options': ['18-25', '26-35', '36-45', '46-60', '60+'],
        'icon': '🎂',
      },
      {
        'section': 'user',
        'id': 'gender',
        'type': 'single',
        'question': 'Tu es... ?',
        'field': 'gender',
        'options': [
          '🙋‍♀️ Une femme',
          '🙋‍♂️ Un homme',
          '🌈 Autre',
          '🤐 Préfère ne pas dire'
        ],
        'icon': '👤',
      },
      {
        'section': 'user',
        'id': 'interests',
        'type': 'multiple',
        'question': 'Quels sont tes centres d\'intérêt ?',
        'field': 'interests',
        'options': [
          '🎨 Art & Créativité',
          '⚽ Sport',
          '🎮 Gaming',
          '📚 Lecture',
          '🎵 Musique',
          '✈️ Voyages',
          '🍳 Cuisine',
          '🎬 Cinéma',
          '🧘 Bien-être',
          '🔬 Sciences',
          '🎭 Spectacles',
          '🌱 Nature'
        ],
        'icon': '💫',
      },
      {
        'section': 'user',
        'id': 'style',
        'type': 'single',
        'question': 'Quel est ton style ?',
        'field': 'style',
        'options': [
          '✨ Chic',
          '😎 Décontracté',
          '🎨 Créatif',
          '🏃 Sportif',
          '🌿 Minimaliste',
          '🌟 Tendance'
        ],
        'icon': '👕',
      },
      {
        'section': 'user',
        'id': 'giftTypes',
        'type': 'multiple',
        'question': 'Quels types de cadeaux aimes-tu ?',
        'field': 'giftTypes',
        'options': [
          '🎁 Pratique',
          '💝 Sentimental',
          '🎉 Original',
          '🌟 Luxe',
          '🎯 Tech',
          '🌱 Éco-responsable',
          '🎨 Artisanal',
          '🍽️ Gastronomique'
        ],
        'icon': '🎀',
      },
      // TRANSITION
      {
        'id': 'transition',
        'type': 'transition',
        'title': 'Super ! 🎉',
        'subtitle': 'Maintenant, parlons du cadeau parfait...',
        'emoji': '💝',
      },
      // PARTIE "CADEAU" - AMÉLIORÉE
      {
        'section': 'gift',
        'id': 'recipient',
        'type': 'single',
        'question': 'Pour qui est ce cadeau ?',
        'subtitle': '🎯 Trouve le cadeau parfait',
        'field': 'recipient',
        'options': [
          '👩 Ma mère',
          '👨 Mon père',
          '💑 Mon/Ma partenaire',
          '👶 Mon enfant',
          '👯 Un(e) ami(e)',
          '👔 Un collègue',
          '👴 Grand-parent',
          '🎓 Autre'
        ],
        'icon': '🎁',
      },
      {
        'section': 'gift',
        'id': 'budget',
        'type': 'slider',
        'question': 'Quel est ton budget ?',
        'subtitle': '💰 Sois honnête, on ne juge pas !',
        'field': 'budget',
        'min': 10,
        'max': 500,
        'icon': '💶',
      },
    ];

    // Questions conditionnelles basées sur le destinataire
    final recipient = answers['recipient'] as String;

    if (recipient.contains('partenaire')) {
      baseSteps.add({
        'section': 'gift',
        'id': 'relationDuration',
        'type': 'single',
        'question': 'Depuis combien de temps ensemble ?',
        'field': 'recipientRelationDuration',
        'options': [
          '🌸 Moins de 6 mois',
          '💕 6 mois - 1 an',
          '❤️ 1-3 ans',
          '💍 Plus de 3 ans'
        ],
        'icon': '💑',
      });
    }

    if (recipient.contains('enfant')) {
      baseSteps.add({
        'section': 'gift',
        'id': 'childAge',
        'type': 'single',
        'question': 'Quel âge a cet enfant ?',
        'field': 'recipientAge',
        'options': [
          '👶 0-2 ans',
          '🧒 3-5 ans',
          '👦 6-9 ans',
          '🧑 10-12 ans',
          '👨 13-17 ans'
        ],
        'icon': '🎈',
      });
    } else if (recipient.isNotEmpty) {
      baseSteps.add({
        'section': 'gift',
        'id': 'recipientAge',
        'type': 'single',
        'question': 'Quel âge a cette personne ?',
        'field': 'recipientAge',
        'options': ['18-25', '26-35', '36-45', '46-60', '60+'],
        'icon': '🎂',
      });
    }

    // Questions communes (seulement si un destinataire est choisi)
    if (recipient.isNotEmpty) {
      baseSteps.addAll([
        {
          'section': 'gift',
          'id': 'hobbies',
          'type': 'multiple',
          'question': 'Quelles sont ses passions ?',
          'subtitle': '🎯 Plus tu en sélectionnes, mieux c\'est !',
          'field': 'recipientHobbies',
          'options': [
            '🎨 Art',
            '⚽ Sport',
            '🎮 Jeux vidéo',
            '📚 Lecture',
            '🎵 Musique',
            '✈️ Voyages',
            '🍳 Cuisine',
            '🎬 Cinéma',
            '🧘 Yoga',
            '🎸 Instruments',
            '📸 Photo',
            '🌱 Jardinage'
          ],
          'icon': '💫',
        },
        {
          'section': 'gift',
          'id': 'personality',
          'type': 'multiple',
          'question': 'Comment décrirais-tu sa personnalité ?',
          'field': 'recipientPersonality',
          'options': [
            '😊 Joyeux/se',
            '🧠 Intellectuel(le)',
            '🎨 Créatif/ve',
            '💪 Actif/ve',
            '🤗 Bienveillant(e)',
            '😎 Cool',
            '🎯 Ambitieux/se',
            '🌟 Extraverti(e)'
          ],
          'icon': '✨',
        },
        {
          'section': 'gift',
          'id': 'lifeSituation',
          'type': 'single',
          'question': 'Que fait-il/elle dans la vie ?',
          'field': 'recipientLifeSituation',
          'options': [
            '💼 Travaille',
            '🎓 Étudiant(e)',
            '🏠 Au foyer',
            '🎨 Artiste/Créateur',
            '🚀 Entrepreneur',
            '😴 Retraité(e)'
          ],
          'icon': '🎯',
        },
        {
          'section': 'gift',
          'id': 'style',
          'type': 'single',
          'question': 'Quel est son style ?',
          'field': 'recipientStyle',
          'options': [
            '✨ Élégant',
            '😎 Décontracté',
            '🎨 Créatif',
            '🏃 Sportif',
            '🌿 Minimaliste',
            '🌟 Tendance',
            '👔 Classique'
          ],
          'icon': '👗',
        },
        {
          'section': 'gift',
          'id': 'occasion',
          'type': 'single',
          'question': 'Pour quelle occasion ?',
          'field': 'occasion',
          'options': [
            '🎂 Anniversaire',
            '🎄 Noël',
            '💝 Saint-Valentin',
            '👨‍👩‍👧 Fête des mères/pères',
            '🎓 Réussite',
            '🎉 Sans occasion',
            '💍 Mariage',
            '🎊 Pendaison de crémaillère'
          ],
          'icon': '🎉',
        },
        {
          'section': 'gift',
          'id': 'alreadyHas',
          'type': 'multiple',
          'question': 'Qu\'est-ce qu\'il/elle possède déjà ?',
          'subtitle': '🚫 Pour éviter les doublons',
          'field': 'recipientAlreadyHas',
          'options': [
            '📱 Dernier smartphone',
            '⌚ Montre connectée',
            '🎧 Écouteurs/Casque',
            '💻 Ordinateur',
            '📷 Appareil photo',
            '🎮 Console de jeu',
            '📚 Liseuse',
            '🏠 Déco sympa'
          ],
          'icon': '✅',
        },
        {
          'section': 'gift',
          'id': 'categories',
          'type': 'multiple',
          'question': 'Quels types de cadeaux privilégier ?',
          'field': 'preferredCategories',
          'options': [
            '🎯 High-tech',
            '👕 Mode & Accessoires',
            '🏠 Déco & Maison',
            '🎨 Art & Créatif',
            '🍷 Gastronomie',
            '📚 Culture',
            '💆 Bien-être',
            '⚽ Sport & Outdoor',
            '🎮 Gaming'
          ],
          'icon': '🎁',
        },
      ]);
    }

    return baseSteps;
  }

  void handleSelect(String field, String value, bool isMultiple) {
    if (isMultiple) {
      final currentList = answers[field] as List<String>;
      if (currentList.contains(value)) {
        currentList.remove(value);
      } else {
        currentList.add(value);
      }
    } else {
      answers[field] = value;
    }
  }

  bool isSelected(String field, String value) {
    final fieldValue = answers[field];
    if (fieldValue is List<String>) {
      return fieldValue.contains(value);
    }
    return fieldValue == value;
  }

  bool canProceed(Map<String, dynamic> stepData) {
    final type = stepData['type'] as String;

    if (type == 'welcome' || type == 'transition') {
      return true;
    }

    if (type == 'slider') {
      return true;
    }

    final field = stepData['field'] as String;
    final fieldValue = answers[field];

    if (type == 'multiple') {
      return (fieldValue as List<String>).isNotEmpty;
    }

    return fieldValue != null &&
        fieldValue != '' &&
        (fieldValue is! double || fieldValue > 0);
  }

  void handleNext(List<Map<String, dynamic>> steps, BuildContext context) async {
    if (currentStep < steps.length - 1) {
      currentStep++;
    } else {
      // Onboarding terminé
      print('✅ Onboarding terminé: $answers');

      try {
        // 1. Sauvegarder les réponses LOCALEMENT (pour fonctionner sans auth)
        final prefs = await SharedPreferences.getInstance();
        final answersJson = answers.map((key, value) => MapEntry(key, value.toString()));
        await prefs.setString('onboarding_answers_json', answersJson.toString());
        print('✅ Réponses sauvegardées localement');

        // 2. Sauvegarder dans Firebase si connecté
        await FirebaseDataService.saveOnboardingAnswers(answers);

        // 3. Marquer l'onboarding comme complété
        await FirstTimeService.setOnboardingCompleted();

        // 4. Navigation vers la page de résultats avec GoRouter
        if (context.mounted) {
          print('🚀 Navigation vers gift-results');
          context.go('/gift-results');
        }
      } catch (e) {
        print('❌ Erreur sauvegarde onboarding: $e');
        // Même en cas d'erreur, on navigue vers les résultats
        if (context.mounted) {
          context.go('/gift-results');
        }
      }
    }
  }

  void handleBack() {
    if (currentStep > 0) {
      currentStep--;
    }
  }
}
