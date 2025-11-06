import 'dart:convert';
import 'package:http/http.dart' as http;
import 'openai_service.dart';
import 'brand_list.dart';

/// Service dédié à la génération de cadeaux personnalisés après l'onboarding
class OpenAIOnboardingService {
  static const String _baseUrl = 'https://api.openai.com/v1';

  /// Génère des cadeaux personnalisés basés sur le profil utilisateur de l'onboarding
  static Future<List<Map<String, dynamic>>> generateOnboardingGifts({
    required Map<String, dynamic> userProfile,
    int count = 50,
  }) async {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('🤖 APPEL API CHATGPT - Génération de $count cadeaux personnalisés');
    print('═══════════════════════════════════════════════════════════');
    print('📋 TAGS DÉTECTÉS:');
    print('   • Destinataire: ${userProfile['recipient'] ?? 'N/A'}');
    print('   • Passions/Hobbies: ${(userProfile['recipientHobbies'] as List?)?.join(', ') ?? 'N/A'}');
    print('   • Personnalité: ${(userProfile['recipientPersonality'] as List?)?.join(', ') ?? 'N/A'}');
    print('   • Style: ${userProfile['recipientStyle'] ?? 'N/A'}');
    print('   • Catégories préférées: ${(userProfile['preferredCategories'] as List?)?.join(', ') ?? 'N/A'}');
    print('   • Âge: ${userProfile['recipientAge'] ?? 'N/A'}');
    print('   • Budget: ${userProfile['budget'] ?? 'N/A'}€');
    print('   • Seed de variation: ${userProfile['_refresh_seed'] ?? 0}');
    print('═══════════════════════════════════════════════════════════');

    try {
      final prompt = _buildOnboardingPrompt(userProfile, count);

      print('📤 Envoi de la requête à l\'API OpenAI...');
      print('🔑 Clé API: ${OpenAIService.apiKey.substring(0, 20)}...');

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${OpenAIService.apiKey}',
        },
        body: json.encode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system',
              'content':
                  'Tu es un expert en curation de cadeaux PERSONNALISÉS pour des personnes SPÉCIFIQUES (pas un feed général). '
                  'Tu recommandes des produits réels de marques premium et accessibles. '
                  'CRITIQUE: Tu crées des sélections ULTRA-SPÉCIFIQUES basées sur les TAGS précis de chaque personne. '
                  'Tu NE recommandes PAS de produits génériques trending (comme pour un feed Pinterest). '
                  'À chaque nouvelle génération, tu explores de NOUVELLES marques et catégories pour offrir une GRANDE VARIÉTÉ. '
                  'Tu ne répètes JAMAIS les mêmes produits. Tu es créatif et surprenant. '
                  'Chaque personne a des goûts UNIQUES - adapte-toi à SES tags spécifiques. '
                  'Réponds UNIQUEMENT en JSON valide sans texte avant ou après.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 1.5,
          'top_p': 0.98,
          'max_tokens': 6000,
          'frequency_penalty': 1.2,
          'presence_penalty': 1.2,
        }),
      );

      print('📥 Réponse reçue - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Succès ! Parsing des données...');
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'] as String;

        // Parser le JSON retourné par GPT
        final productsData = json.decode(content);
        final productsList = productsData['products'] as List;

        print('🎁 ${productsList.length} cadeaux générés par ChatGPT !');
        print('═══════════════════════════════════════════════════════════');
        print('');

        return productsList.map((product) {
          return {
            'id': product['id'] ?? DateTime.now().millisecondsSinceEpoch +
                productsList.indexOf(product),
            'name': product['name'] ?? 'Produit',
            'description': product['description'] ?? '',
            'price': product['price'] ?? 0,
            'brand': product['brand'] ?? '',
            'source': product['source'] ?? 'En ligne',
            'match': product['match'] ?? 80,
            'image': product['image'] ??
                'https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=600&q=80',
            'category': product['category'] ?? 'Divers',
            'url': product['url'] ?? _getFallbackUrl(product['brand'], product['name']),
          };
        }).toList();
      } else {
        print('❌ ERREUR API - Status: ${response.statusCode}');
        print('❌ Réponse: ${response.body}');
        print('⚠️ Utilisation des produits de secours (fallback)');
        print('═══════════════════════════════════════════════════════════');
        print('');
        return _getFallbackGifts();
      }
    } catch (e) {
      print('❌ EXCEPTION lors de l\'appel API ChatGPT');
      print('❌ Erreur: $e');
      print('⚠️ Utilisation des produits de secours (fallback)');
      print('═══════════════════════════════════════════════════════════');
      print('');
      return _getFallbackGifts();
    }
  }

  /// Analyse les tags et retourne les marques recommandées
  static String _getBrandRecommendations(String hobbies, String personality, String style, String categories) {
    final Set<String> recommendedBrands = {};
    final allTags = [
      ...hobbies.toLowerCase().split(',').map((e) => e.trim()),
      ...personality.toLowerCase().split(',').map((e) => e.trim()),
      ...style.toLowerCase().split(',').map((e) => e.trim()),
      ...categories.toLowerCase().split(',').map((e) => e.trim()),
    ].where((tag) => tag.isNotEmpty).toSet();

    // Pour chaque tag, ajouter les marques correspondantes
    for (final tag in allTags) {
      if (BrandList.tagToBrands.containsKey(tag)) {
        recommendedBrands.addAll(BrandList.tagToBrands[tag]!);
      }
    }

    if (recommendedBrands.isEmpty) {
      return 'Utilise une grande variété de marques de la liste complète.';
    }

    return '''
📌 MARQUES PRIORITAIRES basées sur les tags détectés:
${recommendedBrands.take(20).join(', ')}

💡 Ces marques correspondent parfaitement aux tags: ${allTags.join(', ')}
Privilégie CES marques pour au moins 60% de tes recommandations.
Pour les 40% restants, explore d'autres marques de la liste complète pour diversifier.''';
  }

  /// Construit le prompt pour générer des cadeaux personnalisés
  static String _buildOnboardingPrompt(
    Map<String, dynamic> userProfile,
    int count,
  ) {
    // Utiliser la liste COMPLÈTE des marques
    final allBrands = BrandList.brands;

    // Extraire les informations utilisateur
    final age = userProfile['age'] ?? '';
    final gender = userProfile['gender'] ?? '';
    final interests = (userProfile['interests'] as List?)?.join(', ') ?? '';
    final style = userProfile['style'] ?? '';
    final giftTypes = (userProfile['giftTypes'] as List?)?.join(', ') ?? '';

    // Informations sur le destinataire du cadeau
    final recipient = userProfile['recipient'] ?? '';
    final budget = userProfile['budget'] ?? 100.0;
    final recipientAge = userProfile['recipientAge'] ?? '';
    final recipientHobbies = (userProfile['recipientHobbies'] as List?)?.join(', ') ?? '';
    final recipientPersonality = (userProfile['recipientPersonality'] as List?)?.join(', ') ?? '';
    final recipientStyle = userProfile['recipientStyle'] ?? '';
    final occasion = userProfile['occasion'] ?? '';
    final preferredCategories = (userProfile['preferredCategories'] as List?)?.join(', ') ?? '';

    // Seed de variation ULTRA-FORT pour forcer ChatGPT à générer des produits différents
    final previousSeed = userProfile['_refresh_seed'] ?? 0;
    final newSeed = (previousSeed is int ? previousSeed : 0) + 1;
    final randomSeed = DateTime.now().microsecondsSinceEpoch % 100000;
    final uniqueTimestamp = DateTime.now().toIso8601String();
    final personName = recipient.replaceAll('👩 Ma ', '').replaceAll('👨 Mon ', '').replaceAll('💑 Mon/Ma ', '').replaceAll('👶 Mon ', '').replaceAll('👯 Un(e) ', '').replaceAll('👔 Un ', '').replaceAll('👴 ', '').replaceAll('🎓 ', '');

    // Sauvegarder le nouveau seed
    userProfile['_refresh_seed'] = newSeed;

    // Liste de catégories pour forcer la diversité
    final diversityCategories = [
      'Mode & Accessoires', 'Tech & Innovation', 'Beauté & Soins',
      'Maison & Déco', 'Sport & Outdoor', 'Culture & Loisirs',
      'Gastronomie & Gourmandise', 'Bien-être & Relaxation'
    ];

    // Rotation des catégories selon le seed pour forcer la variation
    final primaryCategory = diversityCategories[newSeed % diversityCategories.length];
    final secondaryCategory = diversityCategories[(newSeed + 3) % diversityCategories.length];
    final tertiaryCategory = diversityCategories[(newSeed + 5) % diversityCategories.length];

    // Styles de génération pour varier l'approche à chaque fois
    final generationStyles = [
      'Luxe et Premium', 'Budget et Pratique', 'Original et Créatif',
      'Tendance 2025', 'Classique et Intemporel', 'Expérientiel et Mémorable',
      'Tech et Innovation', 'Artisanal et Local'
    ];
    final currentStyle = generationStyles[newSeed % generationStyles.length];

    // Analyser les tags pour recommander les bonnes marques
    String brandRecommendations = _getBrandRecommendations(recipientHobbies, recipientPersonality, recipientStyle, preferredCategories);

    // Obtenir les marques prioritaires selon le profil démographique du DESTINATAIRE
    final priorityBrands = recipientAge.isNotEmpty && recipient.isNotEmpty
        ? BrandList.getPriorityBrandsByProfile(age: recipientAge, gender: recipient)
        : <String>[];

    final priorityBrandsDemo = priorityBrands.isNotEmpty
        ? '''

🌟 MARQUES PRIORITAIRES DÉMOGRAPHIQUES pour $personName (âge: $recipientAge):
${priorityBrands.join(', ')}

⚠️ ULTRA IMPORTANT: Ces marques correspondent au profil démographique de $personName.
Combine-les avec les marques basées sur les tags ci-dessus.
Au total, privilégie CES marques pour 50-60% de tes recommandations.
'''
        : '';

    final variationInstructions = newSeed > 1
        ? '''
🔄🔄🔄 GÉNÉRATION #$newSeed - NOUVEAUTÉ ABSOLUE EXIGÉE 🔄🔄🔄
⚠️⚠️⚠️ ATTENTION CRITIQUE ⚠️⚠️⚠️

Timestamp unique: $uniqueTimestamp
Random Seed: $randomSeed
STYLE DE GÉNÉRATION: $currentStyle

TU AS DÉJÀ FAIT ${newSeed - 1} RECOMMANDATIONS pour $personName.
Cette fois-ci est la génération #$newSeed.

🚨 IMPÉRATIF ABSOLU 🚨
Tu DOIS générer $count produits COMPLÈTEMENT NOUVEAUX qui n'ont JAMAIS été suggérés avant.

📋 STRATÉGIE DE DIVERSITÉ FORCÉE POUR GÉNÉRATION #$newSeed:
1. STYLE OBLIGATOIRE: $currentStyle
   - Adapte TOUS tes produits à ce style
   - Si "Luxe et Premium" → Privilégie marques haut de gamme (Louis Vuitton, Hermès, Dior)
   - Si "Budget et Pratique" → Privilégie marques accessibles (H&M, Decathlon, IKEA)
   - Si "Original et Créatif" → Privilégie marques créatives (Etsy, Fnac Culture, Urban Outfitters)
   - Si "Tendance 2025" → Privilégie produits viraux et nouveautés
   - Si "Classique et Intemporel" → Privilégie basiques de qualité (COS, A.P.C., Uniqlo)
   - Si "Expérientiel" → Privilégie coffrets, ateliers, expériences
   - Si "Tech et Innovation" → Privilégie gadgets et nouveautés technologiques
   - Si "Artisanal et Local" → Privilégie produits faits main et marques françaises

2. CATÉGORIES PRIORITAIRES pour cette génération #$newSeed:
   - Catégorie principale (40% des produits): $primaryCategory
   - Catégorie secondaire (30% des produits): $secondaryCategory
   - Catégorie tertiaire (20% des produits): $tertiaryCategory
   - Diversité (10% restants): Surprise-moi avec des catégories inattendues!

3. MARQUES: Explore des marques que tu N'AS PAS utilisées dans les ${newSeed - 1} générations précédentes
   ⚠️ RÈGLE D'OR: JAMAIS 2 FOIS LA MÊME MARQUE entre les générations!
   - Génération précédente = Zara, Apple, Nike
   - Cette génération = Mango, Samsung, Adidas (ou TOUTE autre marque différente)

   📊 ROTATION OBLIGATOIRE PAR CATÉGORIE:
   • Mode: Zara → Mango → H&M → Sézane → Sandro → & Other Stories → COS
   • Tech: Apple → Samsung → Sony → Bose → JBL → Dyson → Bang & Olufsen
   • Sport: Nike → Adidas → Lululemon → On Running → Decathlon → Salomon
   • Beauté: Sephora → Kiehl's → Rituals → L'Occitane → Aesop → Lush
   • Maison: Zara Home → Maisons du Monde → IKEA → Am.pm → H&M Home

4. PRIX: Adapte au style "$currentStyle"
   - Si "Luxe" → 60% des produits entre ${budget * 0.8}€ et ${budget * 1.5}€
   - Si "Budget" → 70% des produits entre ${budget * 0.3}€ et ${budget * 0.7}€
   - Sinon → Mix harmonieux de gammes de prix

5. CRÉATIVITÉ MAXIMALE: Pense "out of the box"
   - Produits inattendus mais qui correspondent aux tags
   - Combinaisons originales
   - Idées surprenantes et mémorables
   - Évite les clichés (pas toujours iPhone/Stanley/Dyson Airwrap!)

🎯 OBJECTIF: Que l'utilisateur dise "Wow, je n'y avais pas pensé ! C'est parfait!"

⛔ INTERDICTIONS STRICTES:
- ❌ NE répète PAS les mêmes produits (iPhone → pas iPhone, AirPods → pas AirPods)
- ❌ NE répète PAS les mêmes marques (Zara génération 1 → PAS Zara génération 2)
- ❌ NE reste PAS dans les mêmes catégories dominantes
- ❌ NE propose PAS toujours les "best-sellers évidents"

💡 RAPPEL: Respecte TOUJOURS les tags de $personName, mais explore DIFFÉREMMENT à chaque génération
'''
        : '''
🎉 PREMIÈRE GÉNÉRATION pour $personName 🎉
Timestamp: $uniqueTimestamp
Random Seed: $randomSeed
STYLE DE GÉNÉRATION: $currentStyle

📋 APPROCHE POUR CETTE PREMIÈRE GÉNÉRATION:
• Style à adopter: $currentStyle
• Catégories à explorer en priorité: $primaryCategory, $secondaryCategory, $tertiaryCategory
• Crée des recommandations PARFAITES basées sur les tags fournis
• Varie les marques et les gammes de prix
• Explore toute la richesse des 400+ marques disponibles
''';

    return '''
🎯 CONTEXTE ULTRA-CRITIQUE - LIS EN PREMIER 🎯
═══════════════════════════════════════════════════════════
⚠️⚠️⚠️ CADEAUX POUR UNE PERSONNE SPÉCIFIQUE ⚠️⚠️⚠️

Tu génères des CADEAUX PERSONNALISÉS pour $personName.
Ce N'EST PAS un feed d'inspiration général.
Ce N'EST PAS des produits trending génériques.

🎯 DIFFÉRENCE CLÉS:
• Feed général = produits populaires universels (iPhone, Stanley Cup, etc.)
• TOI (maintenant) = cadeaux HYPER-SPÉCIFIQUES basés sur les TAGS de $personName

📌 APPROCHE OBLIGATOIRE:
• Chaque produit DOIT correspondre à un TAG spécifique
• Utilise les PASSIONS, PERSONNALITÉ, STYLE de $personName
• Privilégie les marques qui matchent avec les tags
• Crée une sélection UNIQUE pour cette personne UNIQUEMENT
• Si $personName aime le bien-être → Sephora, Rituals
• Si $personName aime le sport → Nike, Adidas, Lululemon
• Etc.

═══════════════════════════════════════════════════════════
🎁 MISSION: Génère $count produits cadeaux ULTRA-PERSONNALISÉS pour $personName
🆔 Identifiant unique de cette génération: $randomSeed

$variationInstructions

═══════════════════════════════════════════════════════════
👤 PROFIL DE L'UTILISATEUR (celui qui cherche le cadeau)
═══════════════════════════════════════════════════════════
• Âge: $age ans
• Genre: $gender
• Centres d'intérêt: $interests
• Style: $style
• Types de cadeaux aimés: $giftTypes

═══════════════════════════════════════════════════════════
🎯 PROFIL DU DESTINATAIRE: $personName
═══════════════════════════════════════════════════════════
⚠️ MÉMORISE CES INFORMATIONS - ELLES SONT CRUCIALES ⚠️

• Relation: $recipient
• Budget disponible: ${budget}€
• Âge: $recipientAge ans
• 🏷️ PASSIONS/HOBBIES: $recipientHobbies
• 🏷️ PERSONNALITÉ: $recipientPersonality
• 🏷️ STYLE: $recipientStyle
• 🏷️ CATÉGORIES PRÉFÉRÉES: $preferredCategories
• 🎉 OCCASION: $occasion

═══════════════════════════════════════════════════════════
🏪 MARQUES RECOMMANDÉES (basées sur l'analyse des tags)
═══════════════════════════════════════════════════════════
$brandRecommendations
$priorityBrandsDemo

═══════════════════════════════════════════════════════════
📜 LISTE COMPLÈTE DES MARQUES DISPONIBLES (400+)
═══════════════════════════════════════════════════════════
$allBrands

💡 STRATÉGIE: Utilise prioritairement les marques démographiques et celles basées sur les tags ci-dessus,
puis explore la liste complète pour diversifier.

═══════════════════════════════════════════════════════════
🎯 INSTRUCTIONS CRITIQUES - LIS ATTENTIVEMENT
═══════════════════════════════════════════════════════════

1️⃣ **MÉMORISATION DES TAGS - ULTRA PRIORITAIRE**
   🏷️ Les tags sont LA CLÉ de la personnalisation:
   • PASSIONS: $recipientHobbies
   • PERSONNALITÉ: $recipientPersonality
   • STYLE: $recipientStyle
   • CATÉGORIES: $preferredCategories

   📌 EXEMPLES D'APPLICATION DES TAGS:
   • Tag "bien-être" → Privilégie Sephora, Rituals, L'Occitane, Aesop, Lush
   • Tag "sport" → Privilégie Nike, Adidas, Lululemon, Decathlon, On Running
   • Tag "tech" → Privilégie Apple, Samsung, Dyson, Bose, Sony
   • Tag "créative" → Privilégie produits artistiques, DIY, design, Fnac Culture
   • Tag "mode" → Privilégie Zara, H&M, Mango, Sézane, Sandro
   • Tag "luxe" → Privilégie Louis Vuitton, Dior, Hermès, Gucci
   • Tag "minimaliste" → Privilégie COS, Arket, A.P.C., Muji
   • Tag "gourmand" → Privilégie Pierre Hermé, Ladurée, Kusmi Tea

2️⃣ **DIFFÉRENCIATION PAR PERSONNE - ABSOLUMENT ESSENTIEL**
   ⚠️ Chaque personne EST UNIQUE - Les cadeaux pour MAMAN ≠ PAPA ≠ FRÈRE ≠ AMIE

   🔍 ANALYSE le destinataire:
   • Quel est son âge? ($recipientAge ans)
   • Quelle est sa relation? ($recipient)
   • Quels sont SES tags uniques? (pas ceux de quelqu'un d'autre!)

   💡 EXEMPLE CONCRET:
   - Maman (bien-être, cuisine) → Coffret Sephora, Robot KitchenAid, Thé Kusmi
   - Papa (tech, sport) → AirPods Pro, Nike Air Max, Montre Garmin
   - Sœur (mode, créative) → Sac Polène, Kit DIY Fnac, Pull Sézane

3️⃣ **ADAPTATION PARFAITE AUX TAGS**
   Chaque produit DOIT avoir un lien DIRECT avec les tags:

   ✅ BON EXEMPLE (tag "bien-être"):
   • Coffret Rituals "The Ritual of Sakura" (Rituals) - 35€
   • Description: "Parfait pour quelqu'un qui aime le bien-être et la relaxation.
     Ce coffret transforme la routine quotidienne en moment de détente."

   ❌ MAUVAIS EXEMPLE (tag "bien-être"):
   • PlayStation 5 (Sony) - 549€
   • Description: "Console de jeux moderne" → AUCUN LIEN avec le bien-être!

4️⃣ **PRODUITS RÉELS ET VÉRIFIABLES**
   • Utilise des produits qui EXISTENT VRAIMENT dans ces marques
   • Noms commerciaux exacts (ex: "AirPods Pro 2ème génération", pas juste "écouteurs")
   • Prix réalistes et actuels

5️⃣ **BUDGET INTELLIGENT**
   • Prix entre 15€ et ${budget * 1.2}€
   • Mélange différentes gammes de prix
   • Majorité des produits entre ${budget * 0.5}€ et $budget€

6️⃣ **DESCRIPTIONS ULTRA-PERSONNALISÉES**
   Chaque description DOIT:
   • Mentionner POURQUOI c'est parfait pour $personName
   • Faire référence à au moins UN de ses tags
   • Être engageante et convaincante (2-3 phrases)

   ✅ BON EXEMPLE:
   "Idéal pour votre maman passionnée de bien-être. Ce diffuseur Diptyque
   transforme son intérieur en spa personnel, parfait pour ses moments de détente."

   ❌ MAUVAIS EXEMPLE:
   "Un bon produit de qualité." → Trop générique!

7️⃣ **DIVERSITÉ MAXIMALE**
   • Varie les MARQUES (n'utilise pas 10 fois Zara!)
   • Varie les CATÉGORIES (mode, tech, beauté, maison, food...)
   • Varie les PRIX (du petit cadeau au cadeau premium)
   • Explore TOUTE la liste de 400+ marques

8️⃣ **IMAGES UNSPLASH DE QUALITÉ**
   Format obligatoire: https://images.unsplash.com/photo-[ID]?w=600&q=80
   Choisis des images pertinentes et esthétiques

9️⃣ **URLS OFFICIELLES DES MARQUES**
   Liens vers les vrais sites (Apple.com, Zara.com, Sephora.fr, etc.)

🔟 **MATCH SCORE PRÉCIS**
   • 95-100: Cadeau PARFAIT, correspond exactement aux tags
   • 90-94: Très bon cadeau, correspond bien au profil
   • 85-89: Bon cadeau, correspond à certains tags
   • 80-84: Cadeau correct mais moins personnalisé

═══════════════════════════════════════════════════════════
📦 FORMAT JSON STRICT (réponds UNIQUEMENT en JSON)
═══════════════════════════════════════════════════════════
{
  "products": [
    {
      "id": 1,
      "name": "Nom commercial EXACT du produit",
      "description": "Description personnalisée mentionnant les tags de $personName et pourquoi c'est parfait pour lui/elle (2-3 phrases)",
      "price": 89,
      "brand": "Marque exacte",
      "source": "Nom du magasin/site",
      "url": "https://www.siteofficial.com/product",
      "match": 95,
      "image": "https://images.unsplash.com/photo-xxxxx?w=600&q=80",
      "category": "Catégorie du produit"
    }
  ]
}

⚠️⚠️⚠️ RAPPELS FINAUX CRITIQUES ⚠️⚠️⚠️
✓ MÉMORISE les tags de $personName - ils sont LA CLÉ
✓ Chaque personne est UNIQUE - adapte-toi à SES tags spécifiques
✓ Utilise les MARQUES RECOMMANDÉES basées sur les tags
✓ Varie les marques et catégories - explore les 400+ marques
✓ Descriptions personnalisées mentionnant POURQUOI c'est parfait
✓ JSON UNIQUEMENT - pas de texte avant ou après
✓ Prix réalistes et produits qui existent vraiment
''';
  }

  /// Génère une URL de fallback basée sur la marque
  static String _getFallbackUrl(String? brand, String? productName) {
    final brandMap = {
      'Sephora': 'https://www.sephora.fr',
      'Fnac': 'https://www.fnac.com',
      'Zara': 'https://www.zara.com/fr',
      'Apple': 'https://www.apple.com/fr',
      'Amazon': 'https://www.amazon.fr',
      'H&M': 'https://www.hm.com/fr',
      'Mango': 'https://www.mango.com/fr',
      'IKEA': 'https://www.ikea.com/fr',
      'Nike': 'https://www.nike.com/fr',
      'Adidas': 'https://www.adidas.fr',
      'Sony': 'https://www.sony.fr',
      'Samsung': 'https://www.samsung.com/fr',
      'Dyson': 'https://www.dyson.fr',
      'Decathlon': 'https://www.decathlon.fr',
      'Sandro': 'https://www.sandro-paris.com/fr',
      'Sézane': 'https://www.sezane.com/fr',
      'Galeries Lafayette': 'https://www.galerieslafayette.com',
    };

    if (brand != null && brandMap.containsKey(brand)) {
      return brandMap[brand]!;
    }

    return 'https://www.google.com/search?q=${Uri.encodeComponent(productName ?? 'cadeau')}';
  }

  /// Produits de secours
  static List<Map<String, dynamic>> _getFallbackGifts() {
    return [
      {
        'id': 1,
        'name': 'AirPods Pro 2ème génération',
        'description':
            'Écouteurs sans fil avec réduction de bruit active. Son spatial personnalisé et autonomie exceptionnelle.',
        'price': 279,
        'brand': 'Apple',
        'source': 'Apple',
        'image':
            'https://images.unsplash.com/photo-1606841837239-c5a1a4a07af7?w=600&q=80',
        'match': 92,
        'category': 'Tech',
        'url': 'https://www.apple.com/fr/airpods-pro/',
      },
      {
        'id': 2,
        'name': 'Pull en Cachemire Premium',
        'description':
            'Douceur incomparable, coupe moderne. Le basique luxe parfait pour toutes les occasions.',
        'price': 89,
        'brand': 'Zara',
        'source': 'Zara',
        'image':
            'https://images.unsplash.com/photo-1576871337632-b9aef4c17ab9?w=600&q=80',
        'match': 88,
        'category': 'Mode',
        'url': 'https://www.zara.com/fr',
      },
      {
        'id': 3,
        'name': 'Coffret Skincare Sephora',
        'description':
            'Routine complète pour une peau éclatante. Produits iconiques, résultats visibles.',
        'price': 65,
        'brand': 'Sephora',
        'source': 'Sephora',
        'image':
            'https://images.unsplash.com/photo-1596755389378-c31d21fd1273?w=600&q=80',
        'match': 90,
        'category': 'Beauté',
        'url': 'https://www.sephora.fr',
      },
      {
        'id': 4,
        'name': 'Nike Air Max 90',
        'description':
            'Sneakers iconiques, confort maximal. Le style streetwear intemporel.',
        'price': 140,
        'brand': 'Nike',
        'source': 'Nike',
        'image':
            'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600&q=80',
        'match': 87,
        'category': 'Mode',
        'url': 'https://www.nike.com/fr',
      },
      {
        'id': 5,
        'name': 'PlayStation 5',
        'description':
            'Console next-gen, expérience gaming immersive. Graphismes époustouflants.',
        'price': 549,
        'brand': 'Sony',
        'source': 'Fnac',
        'image':
            'https://images.unsplash.com/photo-1606813907291-d86efa9b94db?w=600&q=80',
        'match': 94,
        'category': 'Tech',
        'url': 'https://www.fnac.com',
      },
    ];
  }
}
