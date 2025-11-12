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
    'firstName': '',
    'age': '',
    'gender': '',
    'interests': <String>[],
    'style': '',
    'giftTypes': <String>[],
    // Onboarding "Personne" - Étape de création du profil destinataire
    'personName': '', // Nom de la personne
    'personGender': '', // Sexe de la personne
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

  List<Map<String, dynamic>> getSteps({
    bool skipUserQuestions = false,
    bool onlyUserQuestions = false,
  }) {
    final baseSteps = <Map<String, dynamic>>[];

    // Ajouter l'écran de bienvenue SEULEMENT si c'est la première fois
    if (!skipUserQuestions) {
      baseSteps.add({
        'id': 'welcome',
        'type': 'welcome',
        'title': 'DORÕN',
        'subtitle': 'Find the perfect gift',
        'emoji': '', // Logo remplacera l'emoji
        'useLogo': true, // Indique d'utiliser le logo au lieu de l'emoji
      });
    }

    // Si on ne skip pas, ajouter les questions sur l'utilisateur
    if (!skipUserQuestions || onlyUserQuestions) {
      baseSteps.addAll([
        // PARTIE "TOI"
        {
          'section': 'user',
          'id': 'firstName',
          'type': 'text',
          'question': 'Comment tu t\'appelles ?',
          'subtitle': '✨ Pour personnaliser ton expérience',
          'field': 'firstName',
          'placeholder': 'Ton prénom',
          'icon': '👋',
        },
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
      ]);
    }

    // PARTIE "PERSONNE" - Création du profil destinataire
    if (!onlyUserQuestions) {
      baseSteps.addAll([
        {
          'section': 'person',
          'id': 'personName',
          'type': 'text',
          'question': 'Pour qui cherches-tu un cadeau ?',
          'subtitle': '✨ Entre le prénom de cette personne',
          'field': 'personName',
          'placeholder': 'Son prénom',
          'icon': '👤',
        },
        {
          'section': 'person',
          'id': 'personGender',
          'type': 'single',
          'question': 'Son sexe ?',
          'subtitle': '🎯 Pour mieux personnaliser les suggestions',
          'field': 'personGender',
          'options': [
            '🙋‍♀️ Femme',
            '🙋‍♂️ Homme',
            '🌈 Autre',
          ],
          'icon': '👥',
        },
      ]);
    }

    // PARTIE "CADEAU" - Incluse uniquement si on ne veut pas SEULEMENT les questions utilisateur
    if (!onlyUserQuestions) {
      baseSteps.addAll([
      {
        'section': 'gift',
        'id': 'recipient',
        'type': 'single',
        'question': 'Quelle est votre relation ?',
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
    ]);

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
    } // Fin de if (!onlyUserQuestions)

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

  void handleNext(List<Map<String, dynamic>> steps, BuildContext context, {bool skipUserQuestions = false, String? returnTo}) async {
    final currentStepData = steps[currentStep];

    // ==================== NOUVELLE ARCHITECTURE ====================
    // Détecter la fin de l'Étape A (section user) - juste après la transition
    if (currentStepData['id'] == 'transition') {
      // Sauvegarder les tags utilisateur (Étape A)
      final userTags = {
        'firstName': answers['firstName'],
        'age': answers['age'],
        'gender': answers['gender'],
        'interests': answers['interests'],
        'style': answers['style'],
        'giftTypes': answers['giftTypes'],
      };

      try {
        await FirebaseDataService.saveUserProfileTags(userTags);
        print('✅ Étape A terminée: Tags utilisateur sauvegardés');
      } catch (e) {
        print('❌ Erreur sauvegarde tags utilisateur: $e');
      }
    }
    // =================================================================

    if (currentStep < steps.length - 1) {
      currentStep++;
    } else {
      // Onboarding terminé (fin de l'Étape B)
      print('✅ Onboarding terminé: $answers');

      try {
        // ==================== NOUVELLE ARCHITECTURE ====================
        // 1. Créer la première personne (Étape B) avec isPendingFirstGen=true
        final personTags = {
          'name': answers['personName'], // Nom de la personne
          'gender': answers['personGender'], // Sexe de la personne
          'recipient': answers['recipient'],
          'budget': answers['budget'],
          'recipientAge': answers['recipientAge'],
          'recipientRelationDuration': answers['recipientRelationDuration'],
          'recipientHobbies': answers['recipientHobbies'],
          'recipientPersonality': answers['recipientPersonality'],
          'recipientLifeSituation': answers['recipientLifeSituation'],
          'recipientStyle': answers['recipientStyle'],
          'occasion': answers['occasion'],
          'recipientAlreadyHas': answers['recipientAlreadyHas'],
          'specialMemory': answers['specialMemory'],
          'preferredCategories': answers['preferredCategories'],
        };

        final personId = await FirebaseDataService.createPerson(
          tags: personTags,
          isPendingFirstGen: true, // Flag pour génération post-auth
        );

        print('✅ Première personne créée: $personId (isPendingFirstGen=true)');
        // =================================================================

        // 2. Sauvegarder aussi l'ancien format pour compatibilité
        await FirebaseDataService.saveOnboardingAnswers(answers);

        // Afficher un feedback de succès
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Profil sauvegardé avec succès !'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }

        // 3. Marquer l'onboarding comme complété (seulement si c'est le premier onboarding)
        if (!skipUserQuestions) {
          await FirstTimeService.setOnboardingCompleted();
        }

        // 4. Navigation
        if (context.mounted) {
          // Si returnTo est spécifié, naviguer vers cette page
          if (returnTo != null && returnTo.isNotEmpty) {
            print('🚀 Navigation vers $returnTo');
            context.go(returnTo);
          } else {
            // NOUVELLE LOGIQUE: Rediriger IMMÉDIATEMENT vers la page de génération
            // avec le personId pour générer les cadeaux personnalisés
            if (personId != null) {
              print('🚀 Navigation vers génération avec personId: $personId');
              context.go('/onboarding-gifts-result?personId=$personId');
            } else {
              // Fallback: si pas de personId (erreur), aller à l'authentification
              print('⚠️ Pas de personId, navigation vers authentification');
              context.go('/authentification');
            }
          }
        }
      } catch (e) {
        print('❌ Erreur sauvegarde onboarding: $e');
        // Même en cas d'erreur, on navigue
        if (context.mounted) {
          if (returnTo != null && returnTo.isNotEmpty) {
            context.go(returnTo);
          } else {
            context.go('/authentification');
          }
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
