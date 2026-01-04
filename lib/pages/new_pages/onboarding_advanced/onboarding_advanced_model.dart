import 'package:flutter/material.dart';
import 'dart:math' as math;
import '/services/firebase_data_service.dart';
import '/services/first_time_service.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingAdvancedModel {
  int currentStep = 0;
  // FIX Bug 2: Variable pour empêcher les doubles clics
  bool isNavigating = false;
  Map<String, dynamic> answers = {
    // Onboarding "Toi"
    'firstName': '',
    'department': '', // Département de l'utilisateur
    'age': '',
    'gender': '',
    'interests': <String>[],
    'style': '',
    'giftTypes': <String>[],
    // Onboarding "Personne" - Étape de création du profil destinataire
    'personName': '', // Prénom de la personne (REQUIS)
    'personIdentifier': '', // Username DORON (OPTIONNEL - si la personne utilise l'app)
    'personGender': '', // Sexe de la personne
    // Onboarding "Cadeau" - AMÉLIORÉ
    'recipient': '', // Type de relation (maman, papa, ami, etc.)
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
    bool expressMode = false, // Mode express avec seulement 7 questions essentielles
    String? onboardingMode, // 'valentine' ou 'classic'
  }) {
    final baseSteps = <Map<String, dynamic>>[];

    // Mode Saint-Valentin : questions spécifiques romantiques
    if (onboardingMode == 'valentine') {
      return [
        // Écran de bienvenue Saint-Valentin
        {
          'id': 'welcome',
          'type': 'welcome',
          'title': '💝 DORON Saint-Valentin',
          'subtitle': 'Trouve LE cadeau qui fera chavirer son cœur',
          'emoji': '💝',
        },
        // 1. Durée de la relation (PREMIER - question romantique)
        {
          'section': 'gift',
          'id': 'relationDuration',
          'type': 'single',
          'question': 'Depuis combien de temps êtes-vous ensemble ?',
          'subtitle': '💑 Pour adapter l\'intensité du cadeau',
          'field': 'recipientRelationDuration',
          'options': [
            '🌸 Moins de 6 mois (nouveaux amoureux)',
            '💕 6 mois - 1 an',
            '❤️ 1-3 ans',
            '💍 Plus de 3 ans (couple établi)',
          ],
          'icon': '⏰',
        },
        // 4. Prénom de la personne (REQUIRED - toujours visible)
        {
          'section': 'person',
          'id': 'personName',
          'type': 'text',
          'question': 'Quel est son prénom ?',
          'subtitle': '💝 REQUIS - Le prénom de ton/ta chéri(e)',
          'field': 'personName',
          'placeholder': 'Exemple: Marie',
          'icon': '👤',
          'required': true,
        },
        // 5. Username de la personne (OPTIONAL - clairement marqué)
        {
          'section': 'person',
          'id': 'personUsername',
          'type': 'text',
          'question': 'Son nom d\'utilisateur (optionnel)',
          'subtitle': '🔗 OPTIONNEL - Si la personne utilise DORON (@username)',
          'field': 'personIdentifier',
          'placeholder': '@username (facultatif)',
          'icon': '🔗',
          'required': false,
          'canSkip': true,
        },
        // 6. Sexe
        {
          'section': 'person',
          'id': 'personGender',
          'type': 'single',
          'question': 'Son sexe ?',
          'subtitle': '🎯 Pour des suggestions personnalisées',
          'field': 'personGender',
          'options': [
            '🙋‍♀️ Femme',
            '🙋‍♂️ Homme',
            '🌈 Autre',
          ],
          'icon': '👥',
        },
        // 7. Budget
        {
          'section': 'gift',
          'id': 'budget',
          'type': 'slider',
          'question': 'Quel est ton budget ?',
          'subtitle': '💰 Pas besoin de te ruiner pour faire plaisir !',
          'field': 'budget',
          'min': 10,
          'max': 500,
          'icon': '💶',
        },
        // 8. Style de relation
        {
          'section': 'gift',
          'id': 'relationStyle',
          'type': 'single',
          'question': 'Votre style de couple ?',
          'subtitle': '💑 Pour un cadeau qui vous ressemble',
          'field': 'recipientPersonality',
          'options': [
            '🌹 Romantique & classique',
            '🎉 Fun & aventurier',
            '🏠 Cocooning & intimiste',
            '🎨 Créatif & original',
            '💪 Sportif & actif',
            '🌍 Voyageur & curieux',
          ],
          'icon': '💞',
        },
        // 9. Centres d'intérêt
        {
          'section': 'gift',
          'id': 'hobbies',
          'type': 'multiple',
          'question': 'Quelles sont ses passions ?',
          'subtitle': '🎯 Choisis 2-3 maximum',
          'field': 'recipientHobbies',
          'options': [
            '🎨 Art & Créativité',
            '⚽ Sport & Fitness',
            '🎮 Gaming',
            '📚 Lecture',
            '🎵 Musique',
            '✈️ Voyages',
            '🍳 Cuisine & Gastronomie',
            '🎬 Cinéma & Séries',
            '🧘 Bien-être & Spa',
            '📸 Photo',
            '🌱 Nature & Plein air',
            '💅 Beauté & Mode',
          ],
          'icon': '💫',
          'maxSelections': 3,
        },
        // 10. Type de cadeau souhaité
        {
          'section': 'gift',
          'id': 'categories',
          'type': 'multiple',
          'question': 'Quel type de cadeau préfères-tu ?',
          'subtitle': '💝 Choisis 2-3 catégories',
          'field': 'preferredCategories',
          'options': [
            '💍 Bijoux & Accessoires',
            '🌹 Fleurs & Plantes',
            '🍷 Gastronomie & Vins',
            '💆 Spa & Bien-être',
            '🎨 Expériences créatives',
            '✈️ Week-end romantique',
            '👗 Mode & Lingerie',
            '🏠 Déco & Maison',
            '🎁 Coffrets cadeaux',
            '📚 Livres & Culture',
            '🎵 Concerts & Spectacles',
            '💻 High-tech',
          ],
          'icon': '🎁',
          'maxSelections': 3,
        },
        // 11. Moment de partage
        {
          'section': 'gift',
          'id': 'occasion',
          'type': 'single',
          'question': 'Comment comptez-vous célébrer ?',
          'subtitle': '🎉 Pour un cadeau adapté à l\'occasion',
          'field': 'occasion',
          'options': [
            '🍽️ Dîner en amoureux',
            '🏠 Soirée à la maison',
            '✈️ Week-end surprise',
            '🎭 Sortie culturelle',
            '🌹 Moment romantique simple',
            '🎊 Grande célébration',
          ],
          'icon': '💝',
        },
      ];
    }

    // Mode express : seulement 7 questions essentielles
    if (expressMode) {
      return [
        // Écran de bienvenue
        {
          'id': 'welcome',
          'type': 'welcome',
          'title': 'DORÕN',
          'subtitle': 'Trouve le cadeau parfait en 3 min',
          'emoji': '',
          'useLogo': true,
        },
        // 1. Relation (PREMIER - Pour qui cherches-tu ?)
        {
          'section': 'gift',
          'id': 'recipient',
          'type': 'single',
          'question': 'Pour qui cherches-tu un cadeau ?',
          'subtitle': '🎯 Quelle est votre relation ?',
          'field': 'recipient',
          'options': [
            '👩 Mère',
            '👨 Père',
            '👧 Sœur',
            '👦 Frère',
            '💑 Petit(e) ami(e)',
            '👯 Ami(e)',
            '🎓 Autre'
          ],
          'icon': '🎁',
        },
        // 4. Prénom ET Pseudo (MÊME PAGE - dual fields)
        {
          'section': 'person',
          'id': 'personInfo',
          'type': 'dual_text',
          'question': 'Informations sur cette personne',
          'subtitle': '👤 Prénom requis • 🔗 Pseudo optionnel',
          'icon': '✍️',
          'fields': [
            {
              'field': 'personName',
              'label': 'Prénom',
              'placeholder': 'Ex: Marie',
              'required': true,
              'hint': 'REQUIS',
            },
            {
              'field': 'personIdentifier',
              'label': 'Nom d\'utilisateur DORON',
              'placeholder': '@username (optionnel)',
              'required': false,
              'hint': 'OPTIONNEL - Si la personne utilise l\'app',
            },
          ],
        },
        // 6. Sexe
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
        // 4. Budget
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
        // 5. Lieu de vie (Département)
        {
          'section': 'person',
          'id': 'department',
          'type': 'single',
          'question': 'Où habite cette personne ?',
          'subtitle': '📍 Département',
          'field': 'department',
          'options': [
            '75 - Paris',
            '13 - Bouches-du-Rhône',
            '69 - Rhône',
            '59 - Nord',
            '33 - Gironde',
            '44 - Loire-Atlantique',
            '92 - Hauts-de-Seine',
            '93 - Seine-Saint-Denis',
            '94 - Val-de-Marne',
            '31 - Haute-Garonne',
            '06 - Alpes-Maritimes',
            '34 - Hérault',
            '67 - Bas-Rhin',
            '35 - Ille-et-Vilaine',
            '38 - Isère',
            '01 - Ain',
            '02 - Aisne',
            '03 - Allier',
            '04 - Alpes-de-Haute-Provence',
            '05 - Hautes-Alpes',
            '07 - Ardèche',
            '08 - Ardennes',
            '09 - Ariège',
            '10 - Aube',
            '11 - Aude',
            '12 - Aveyron',
            '14 - Calvados',
            '15 - Cantal',
            '16 - Charente',
            '17 - Charente-Maritime',
            '18 - Cher',
            '19 - Corrèze',
            '21 - Côte-d\'Or',
            '22 - Côtes-d\'Armor',
            '23 - Creuse',
            '24 - Dordogne',
            '25 - Doubs',
            '26 - Drôme',
            '27 - Eure',
            '28 - Eure-et-Loir',
            '29 - Finistère',
            '30 - Gard',
            '32 - Gers',
            '36 - Indre',
            '37 - Indre-et-Loire',
            '39 - Jura',
            '40 - Landes',
            '41 - Loir-et-Cher',
            '42 - Loire',
            '43 - Haute-Loire',
            '45 - Loiret',
            '46 - Lot',
            '47 - Lot-et-Garonne',
            '48 - Lozère',
            '49 - Maine-et-Loire',
            '50 - Manche',
            '51 - Marne',
            '52 - Haute-Marne',
            '53 - Mayenne',
            '54 - Meurthe-et-Moselle',
            '55 - Meuse',
            '56 - Morbihan',
            '57 - Moselle',
            '58 - Nièvre',
            '60 - Oise',
            '61 - Orne',
            '62 - Pas-de-Calais',
            '63 - Puy-de-Dôme',
            '64 - Pyrénées-Atlantiques',
            '65 - Hautes-Pyrénées',
            '66 - Pyrénées-Orientales',
            '68 - Haut-Rhin',
            '70 - Haute-Saône',
            '71 - Saône-et-Loire',
            '72 - Sarthe',
            '73 - Savoie',
            '74 - Haute-Savoie',
            '76 - Seine-Maritime',
            '77 - Seine-et-Marne',
            '78 - Yvelines',
            '79 - Deux-Sèvres',
            '80 - Somme',
            '81 - Tarn',
            '82 - Tarn-et-Garonne',
            '83 - Var',
            '84 - Vaucluse',
            '85 - Vendée',
            '86 - Vienne',
            '87 - Haute-Vienne',
            '88 - Vosges',
            '89 - Yonne',
            '90 - Territoire de Belfort',
            '91 - Essonne',
            '95 - Val-d\'Oise',
            '🌍 Autre / Étranger',
          ],
          'icon': '📍',
        },
        // 6. Occasion
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
            '💍 Mariage',
            '🎓 Diplôme',
            '🏠 Pendaison de crémaillère',
            '❤️ Juste pour faire plaisir'
          ],
          'icon': '🎉',
        },
        // 9. Hobbies (2-3 principaux) - OPTIONS ENRICHIES
        {
          'section': 'gift',
          'id': 'hobbies',
          'type': 'multiple',
          'question': 'Ses hobbies principaux ?',
          'subtitle': '🎯 Choisis 2 ou 3 maximum',
          'field': 'recipientHobbies',
          'options': [
            '🎨 Art & Créativité',
            '🖌️ Dessin & Peinture',
            '⚽ Sport & Fitness',
            '🏃 Running & Cardio',
            '🚴 Cyclisme',
            '🏊 Natation',
            '🎮 Gaming & Jeux vidéo',
            '🎲 Jeux de société',
            '📚 Lecture & Littérature',
            '✍️ Écriture',
            '🎵 Musique',
            '🎸 Instruments de musique',
            '✈️ Voyages & Découvertes',
            '🗺️ Randonnée & Trek',
            '🍳 Cuisine & Gastronomie',
            '🍷 Œnologie',
            '☕ Café & Thé',
            '🎬 Cinéma & Séries',
            '📺 Streaming',
            '🧘 Bien-être & Yoga',
            '💆 Spa & Relaxation',
            '🔬 Sciences & Technologies',
            '💻 Informatique & Code',
            '🎭 Spectacles & Théâtre',
            '🎤 Concerts & Musique live',
            '🌱 Nature & Écologie',
            '🌸 Jardinage',
            '🐕 Animaux',
            '📷 Photographie',
            '🎥 Vidéo & Création',
            '🧶 DIY & Artisanat',
            '👗 Mode & Style',
            '💄 Beauté & Cosmétiques',
            '🏠 Décoration intérieure',
            '📖 BD & Mangas',
            '🧩 Puzzles & Énigmes',
            '🎯 Collection & Figurines',
          ],
          'icon': '💫',
          'maxSelections': 3, // Augmenté à 3 choix
        },
      ];
    }

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
        // Choix du type d'identifiant
        {
          'section': 'person',
          'id': 'personIdentifierType',
          'type': 'single',
          'question': 'Pour qui cherches-tu un cadeau ?',
          'subtitle': '💡 Comment souhaites-tu identifier cette personne ?',
          'field': 'personIdentifierType',
          'options': [
            '👤 Son prénom (si elle n\'a pas encore l\'appli)',
            '🔗 Son nom d\'utilisateur',
          ],
          'icon': '🎯',
        },
        // Champ texte conditionnel
        {
          'section': 'person',
          'id': 'personIdentifier',
          'type': 'text',
          'question': answers['personIdentifierType']?.contains('utilisateur') == true
              ? 'Entre son nom d\'utilisateur'
              : 'Entre son prénom',
          'subtitle': answers['personIdentifierType']?.contains('utilisateur') == true
              ? '🔗 Exemple: @marie_dupont'
              : '✨ Le prénom de cette personne',
          'field': 'personIdentifier',
          'placeholder': answers['personIdentifierType']?.contains('utilisateur') == true
              ? '@username'
              : 'Son prénom',
          'icon': '✏️',
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

  void handleSelect(String field, String value, bool isMultiple, {int? maxSelections}) {
    if (isMultiple) {
      final currentList = answers[field] as List<String>;
      if (currentList.contains(value)) {
        currentList.remove(value);
      } else {
        // Vérifier la limite de sélection si définie
        if (maxSelections != null && currentList.length >= maxSelections) {
          // Ne pas ajouter si la limite est atteinte
          return;
        }
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

  Future<void> handleNext(List<Map<String, dynamic>> steps, BuildContext context, {bool skipUserQuestions = false, String? returnTo, bool onlyUserQuestions = false}) async {
    // FIX Bug 2: Empêcher les doubles clics
    if (isNavigating) {
      print('⚠️ Navigation déjà en cours, ignoré');
      return;
    }
    isNavigating = true;

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

      // 🎯 CAS SPÉCIAL: Si onlyUserQuestions=true, on s'arrête ici
      // L'utilisateur modifie juste son profil depuis les paramètres
      if (onlyUserQuestions) {
        print('✅ Modification profil utilisateur terminée (onlyUserQuestions=true)');

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Profil mis à jour avec succès !'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }

        // Retourner à la page d'origine (ou page Recherche par défaut)
        await Future.delayed(const Duration(milliseconds: 500));
        if (context.mounted) {
          if (returnTo != null && returnTo.isNotEmpty) {
            context.go(returnTo);
          } else {
            context.go('/search-page'); // Redirection vers page Recherche
          }
        }
        isNavigating = false; // Reset le flag avant de return
        return; // Arrêter ici, ne pas créer de personne
      }
    }
    // =================================================================

    if (currentStep < steps.length - 1) {
      currentStep++;
      isNavigating = false; // FIX Bug 2: Reset le flag après l'incrémentation
      print('✅ Step avancé: $currentStep');
    } else {
      // Onboarding terminé (fin de l'Étape B)
      print('✅ Onboarding terminé: $answers');

      try {
        // ==================== NOUVELLE ARCHITECTURE ====================
        // 1. Créer la première personne (Étape B) avec isPendingFirstGen=true

        // Déterminer si c'est un username ou un prénom
        final isUsername = answers['personIdentifierType']?.contains('utilisateur') == true;
        final identifier = answers['personIdentifier'] ?? '';

        final personTags = {
          'name': isUsername ? null : identifier, // Nom de la personne (si prénom)
          'username': isUsername ? identifier.replaceAll('@', '') : null, // Username (si username)
          'isUsername': isUsername, // Flag pour savoir si on doit chercher dans Firestore
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
          // TOUJOURS montrer la page cadeaux d'abord
          if (personId != null) {
            // Si on a un returnTo, le passer en paramètre pour revenir après
            final returnParam = (returnTo != null && returnTo.isNotEmpty)
                ? '&returnTo=${Uri.encodeComponent(returnTo)}'
                : '';

            // Si c'est le PREMIER onboarding (pas de skipUserQuestions)
            if (!skipUserQuestions) {
              // Aller d'abord à l'authentification AVANT de voir les cadeaux
              print('🚀 Premier onboarding: Navigation vers authentification puis cadeaux');
              context.go('/authentification?personId=$personId$returnParam');
            } else {
              // Si c'est un ajout de personne, aller directement aux cadeaux
              print('🚀 Ajout de personne: Navigation directe vers cadeaux');
              context.go('/onboarding-gifts-result?personId=$personId$returnParam');
            }
          } else {
            // Fallback: si pas de personId (erreur)
            print('⚠️ Pas de personId, navigation vers authentification');
            context.go('/authentification');
          }
        }
      } catch (e) {
        print('❌ Erreur sauvegarde onboarding: $e');
        isNavigating = false; // Reset le flag en cas d'erreur
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
