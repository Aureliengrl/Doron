/// Définitions officielles et exhaustives des tags produits DORÕN
///
/// Ce fichier centralise TOUTES les valeurs de tags autorisées.
/// Aucun tag en dehors de ces listes ne doit être utilisé.
///
/// Structure : 7 familles de tags avec règles strictes/souples
class TagsDefinitions {
  // ========================================================================
  // TAGS OBLIGATOIRES - 1 SEULE VALEUR POSSIBLE
  // ========================================================================

  /// 1️⃣ SEXE (OBLIGATOIRE - 1 seul tag)
  /// Règle : STRICTE - correspondance exacte requise
  /// ⚠️ PAS DE gender_mixte - uniquement homme OU femme
  static const List<String> genderTags = [
    'gender_femme',
    'gender_homme',
  ];

  /// 2️⃣ CATÉGORIE PRINCIPALE (OBLIGATOIRE - 1 seul tag)
  /// Règle : STRICTE - correspondance exacte requise
  static const List<String> categoryTags = [
    'cat_tendances', // Produits viraux, TikTok, nouveautés tendances
    'cat_tech', // High-tech, gadgets, électronique
    'cat_mode', // Vêtements, accessoires mode
    'cat_maison', // Déco, maison, intérieur
    'cat_beaute', // Beauté, soins, parfums
    'cat_food', // Gastronomie, cuisine, alimentaire
  ];

  /// 3️⃣ TRANCHE DE PRIX (OBLIGATOIRE - 1 seul tag)
  /// Règle : STRICTE - correspondance exacte requise
  static const List<String> budgetTags = [
    'budget_0_50',
    'budget_50_100',
    'budget_100_200',
    'budget_200+',
  ];

  // ========================================================================
  // TAGS MULTIPLES - PLUSIEURS VALEURS POSSIBLES
  // ========================================================================

  /// 4️⃣ TYPE DE CADEAU (MULTIPLE possible)
  /// Règle : SOUPLE - matching partiel autorisé
  static const List<String> giftTypeTags = [
    'type_mode_accessoires',
    'type_bien_etre',
    'type_sport_outdoor',
    'type_gastronomie',
    'type_culture',
    'type_high_tech',
    'type_maison_deco',
    'type_beaute_soins',
    'type_loisirs_creatifs',
    'type_jeux_jouets',
    'type_livres_bd',
    'type_musique_audio',
    'type_voyage_aventure',
    'type_automobile',
    'type_bijoux',
  ];

  /// 5️⃣ STYLE (MULTIPLE possible)
  /// Règle : SOUPLE - matching partiel autorisé
  static const List<String> styleTags = [
    'style_elegant',
    'style_tendance',
    'style_minimaliste',
    'style_classique',
    'style_decontracte',
    'style_sportif',
    'style_vintage',
    'style_moderne',
    'style_luxe',
    'style_boheme',
    'style_streetwear',
    'style_eco_responsable',
  ];

  /// 6️⃣ PERSONNALITÉ (MULTIPLE possible)
  /// Règle : SOUPLE - matching partiel autorisé
  static const List<String> personalityTags = [
    'perso_creatif',
    'perso_actif',
    'perso_cool',
    'perso_bienveillant',
    'perso_ambitieux',
    'perso_romantique',
    'perso_aventurier',
    'perso_intellectuel',
    'perso_sociable',
    'perso_zen',
    'perso_excentrique',
    'perso_pratique',
    'perso_gourmand',
    'perso_techie',
  ];

  /// 7️⃣ PASSIONS (MULTIPLE possible)
  /// Règle : SOUPLE - matching partiel autorisé
  static const List<String> passionTags = [
    'passion_sport',
    'passion_cuisine',
    'passion_voyages',
    'passion_photo',
    'passion_jeuxvideo',
    'passion_lecture',
    'passion_musique',
    'passion_cinema',
    'passion_mode',
    'passion_beaute',
    'passion_tech',
    'passion_art',
    'passion_jardinage',
    'passion_bricolage',
    'passion_yoga',
    'passion_danse',
    'passion_nature',
    'passion_animaux',
    'passion_automobile',
    'passion_vins',
  ];

  // ========================================================================
  // UTILITAIRES DE VALIDATION
  // ========================================================================

  /// Vérifie si un tag de genre est valide
  static bool isValidGenderTag(String tag) => genderTags.contains(tag);

  /// Vérifie si un tag de catégorie est valide
  static bool isValidCategoryTag(String tag) => categoryTags.contains(tag);

  /// Vérifie si un tag de budget est valide
  static bool isValidBudgetTag(String tag) => budgetTags.contains(tag);

  /// Vérifie si un tag de type de cadeau est valide
  static bool isValidGiftTypeTag(String tag) => giftTypeTags.contains(tag);

  /// Vérifie si un tag de style est valide
  static bool isValidStyleTag(String tag) => styleTags.contains(tag);

  /// Vérifie si un tag de personnalité est valide
  static bool isValidPersonalityTag(String tag) => personalityTags.contains(tag);

  /// Vérifie si un tag de passion est valide
  static bool isValidPassionTag(String tag) => passionTags.contains(tag);

  /// Retourne tous les tags valides (toutes catégories confondues)
  static List<String> get allValidTags => [
        ...genderTags,
        ...categoryTags,
        ...budgetTags,
        ...giftTypeTags,
        ...styleTags,
        ...personalityTags,
        ...passionTags,
      ];

  /// Filtre une liste de tags pour ne garder que ceux qui sont valides
  static List<String> filterValidTags(List<String> tags) {
    return tags.where((tag) => allValidTags.contains(tag)).toList();
  }

  /// Extrait le tag de budget en fonction d'un prix
  static String getBudgetTagFromPrice(int price) {
    if (price < 50) return 'budget_0_50';
    if (price < 100) return 'budget_50_100';
    if (price < 200) return 'budget_100_200';
    return 'budget_200+';
  }

  // ========================================================================
  // MAPS DE CONVERSION (pour onboarding et voice assistant)
  // ========================================================================

  /// Conversion genre utilisateur → tag produit
  /// ⚠️ "Autre" et "Préfère ne pas dire" ne sont PAS dans cette map
  /// → Ils ne génèrent AUCUN tag genre, ce qui accepte tous les produits
  static const Map<String, String> genderConversion = {
    // Versions sans emoji (voice assistant, ancienne version)
    'Femme': 'gender_femme',
    'Homme': 'gender_homme',
    // Versions avec emoji (onboarding actuel)
    '🙋‍♀️ Femme': 'gender_femme',
    '🙋‍♂️ Homme': 'gender_homme',
    // '🌈 Autre' → volontairement omis, ne génère aucun tag
    // '🤐 Préfère ne pas dire' → volontairement omis, ne génère aucun tag
  };

  /// Conversion catégories onboarding → tags produit
  static const Map<String, String> categoryConversion = {
    'Tendances': 'cat_tendances',
    'Tech': 'cat_tech',
    'Électronique': 'cat_tech',
    'Mode': 'cat_mode',
    'Vêtements': 'cat_mode',
    'Maison': 'cat_maison',
    'Déco': 'cat_maison',
    'Beauté': 'cat_beaute',
    'Soins': 'cat_beaute',
    'Food': 'cat_food',
    'Gastronomie': 'cat_food',
    'Cuisine': 'cat_food',
  };

  /// Conversion styles utilisateur → tags produit
  static const Map<String, String> styleConversion = {
    'Élégant': 'style_elegant',
    'Tendance': 'style_tendance',
    'Minimaliste': 'style_minimaliste',
    'Classique': 'style_classique',
    'Décontracté': 'style_decontracte',
    'Sportif': 'style_sportif',
    'Vintage': 'style_vintage',
    'Moderne': 'style_moderne',
    'Luxe': 'style_luxe',
    'Bohème': 'style_boheme',
    'Street': 'style_streetwear',
    'Eco': 'style_eco_responsable',
  };

  /// Conversion passions/hobbies → tags passion
  static const Map<String, String> passionConversion = {
    'sport': 'passion_sport',
    'cuisine': 'passion_cuisine',
    'voyages': 'passion_voyages',
    'photo': 'passion_photo',
    'photographie': 'passion_photo',
    'jeux vidéo': 'passion_jeuxvideo',
    'gaming': 'passion_jeuxvideo',
    'lecture': 'passion_lecture',
    'livres': 'passion_lecture',
    'musique': 'passion_musique',
    'cinéma': 'passion_cinema',
    'films': 'passion_cinema',
    'mode': 'passion_mode',
    'fashion': 'passion_mode',
    'beauté': 'passion_beaute',
    'maquillage': 'passion_beaute',
    'tech': 'passion_tech',
    'technologie': 'passion_tech',
    'art': 'passion_art',
    'peinture': 'passion_art',
    'jardinage': 'passion_jardinage',
    'bricolage': 'passion_bricolage',
    'yoga': 'passion_yoga',
    'danse': 'passion_danse',
    'nature': 'passion_nature',
    'randonnée': 'passion_nature',
    'animaux': 'passion_animaux',
    'automobile': 'passion_automobile',
    'voitures': 'passion_automobile',
    'vins': 'passion_vins',
    'oenologie': 'passion_vins',
  };

  /// Conversion personnalités → tags personnalité
  static const Map<String, String> personalityConversion = {
    'créatif': 'perso_creatif',
    'créative': 'perso_creatif',
    'actif': 'perso_actif',
    'active': 'perso_actif',
    'sportif': 'perso_actif',
    'cool': 'perso_cool',
    'calme': 'perso_zen',
    'bienveillant': 'perso_bienveillant',
    'bienveillante': 'perso_bienveillant',
    'ambitieux': 'perso_ambitieux',
    'ambitieuse': 'perso_ambitieux',
    'romantique': 'perso_romantique',
    'aventurier': 'perso_aventurier',
    'aventurière': 'perso_aventurier',
    'aventureux': 'perso_aventurier',
    'intellectuel': 'perso_intellectuel',
    'intellectuelle': 'perso_intellectuel',
    'sociable': 'perso_sociable',
    'zen': 'perso_zen',
    'excentrique': 'perso_excentrique',
    'original': 'perso_excentrique',
    'originale': 'perso_excentrique',
    'pratique': 'perso_pratique',
    'pragmatique': 'perso_pratique',
    'gourmand': 'perso_gourmand',
    'gourmande': 'perso_gourmand',
    'techie': 'perso_techie',
    'geek': 'perso_techie',
  };

  // ========================================================================
  // HELPERS DE CONVERSION
  // ========================================================================

  /// Convertit une liste de mots-clés en tags valides
  static List<String> convertKeywordsToTags(List<String> keywords) {
    final Set<String> tags = {};

    for (final keyword in keywords) {
      final lowerKeyword = keyword.toLowerCase().trim();

      // Chercher dans les passions
      passionConversion.forEach((key, value) {
        if (lowerKeyword.contains(key.toLowerCase())) {
          tags.add(value);
        }
      });

      // Chercher dans les personnalités
      personalityConversion.forEach((key, value) {
        if (lowerKeyword.contains(key.toLowerCase())) {
          tags.add(value);
        }
      });

      // Chercher dans les styles
      styleConversion.forEach((key, value) {
        if (lowerKeyword.contains(key.toLowerCase())) {
          tags.add(value);
        }
      });
    }

    return tags.toList();
  }
}
