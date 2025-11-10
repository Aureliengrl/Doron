import 'dart:convert';
import 'package:http/http.dart' as http;
import 'openai_service.dart';
import 'brand_list.dart';
import 'http_service.dart';

/// Service dédié à la génération de produits pour la page d'accueil
class OpenAIHomeService {
  static const String _baseUrl = 'https://api.openai.com/v1';

  /// Génère des produits pour la page d'accueil selon la catégorie sélectionnée
  /// Catégories: 'Pour toi', 'Tendances', 'Tech', 'Mode', 'Maison', 'Beauté', 'Food'
  static Future<List<Map<String, dynamic>>> generateHomeProducts({
    required String category,
    Map<String, dynamic>? userProfile,
    int count = 10,
  }) async {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('🏠 APPEL API CHATGPT - Feed Home ($category) - $count produits');
    print('═══════════════════════════════════════════════════════════');

    try {
      final prompt = _buildHomeCategoryPrompt(category, userProfile, count);

      print('📤 Envoi de la requête à l\'API OpenAI...');
      print('🔑 Clé API: ${OpenAIService.apiKey.substring(0, 20)}...');

      final response = await HttpService.postWithRetry(
        url: Uri.parse('$_baseUrl/chat/completions'),
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
                  'Tu es un expert en curation de produits personnalisés pour un feed d\'inspiration. '
                  'Tu recommandes des produits ADAPTÉS au profil de l\'utilisateur (ses goûts, son âge, son style, ses intérêts). '
                  'CONTEXTE IMPORTANT: Ceci est un feed PERSONNALISÉ pour l\'utilisateur, basé sur SON profil. '
                  'Tu adaptes tes recommandations à SES préférences tout en proposant des produits tendance et populaires. '
                  'Explore la diversité des 400+ marques disponibles. '
                  'Réponds UNIQUEMENT en JSON valide sans texte avant ou après.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 1.2,
          'top_p': 0.95,
          'max_tokens': 6000,
          'frequency_penalty': 0.8,
          'presence_penalty': 0.8,
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

        print('🎁 ${productsList.length} produits générés par ChatGPT !');
        print('═══════════════════════════════════════════════════════════');
        print('');

        return productsList.map((product) {
          // Générer une URL de fallback basée sur la marque
          String getFallbackUrl(String brand, String productName) {
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
            };
            return brandMap[brand] ??
                'https://www.google.com/search?q=${Uri.encodeComponent(productName)}';
          }

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
            'category': product['category'] ?? category,
            'url': product['url'] ??
                getFallbackUrl(product['brand'] ?? 'Amazon', product['name'] ?? 'produit'),
          };
        }).toList();
      } else {
        print('❌ ERREUR API - Status: ${response.statusCode}');
        print('❌ Réponse: ${response.body}');
        print('⚠️ Utilisation des produits de secours (fallback)');
        print('═══════════════════════════════════════════════════════════');
        print('');
        // Lever une exception avec le code d'erreur pour que le widget puisse l'afficher
        throw Exception('API Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ EXCEPTION lors de l\'appel API ChatGPT');
      print('❌ Erreur: $e');
      print('⚠️ Utilisation des produits de secours (fallback)');
      print('═══════════════════════════════════════════════════════════');
      print('');
      // Lever l'exception pour que le widget puisse l'afficher
      rethrow;
    }
  }

  /// Construit le prompt pour générer des produits par catégorie
  static String _buildHomeCategoryPrompt(
    String category,
    Map<String, dynamic>? userProfile,
    int count,
  ) {
    // Utiliser la liste COMPLÈTE des 400+ marques
    final allBrands = BrandList.brands;

    // Récupérer les tags utilisateur si disponibles
    final userAge = userProfile?['age'] ?? '';
    final userGender = userProfile?['gender'] ?? '';
    final userInterests = (userProfile?['interests'] as List?)?.join(', ') ?? '';
    final userStyle = userProfile?['style'] ?? '';

    // Extraire le seed de variation pour forcer la diversité
    final refreshTimestamp = userProfile?['_refresh_timestamp'] ?? 0;
    final variationSeed = userProfile?['_variation_seed'] ?? 0;
    final uniqueId = '$refreshTimestamp-$variationSeed';

    // Extraire la liste des produits déjà vus
    final seenProducts = (userProfile?['_seen_products'] as List?)?.cast<String>() ?? [];
    final seenProductsText = seenProducts.isNotEmpty
        ? '''

🚫 PRODUITS DÉJÀ VUS (${seenProducts.length}) - NE PAS RÉPÉTER
═══════════════════════════════════════════════════════════
⚠️ L'utilisateur a DÉJÀ vu ces produits. Tu DOIS proposer des produits DIFFÉRENTS.

Liste des produits à éviter:
${seenProducts.take(50).join('\n')}${seenProducts.length > 50 ? '\n... et ${seenProducts.length - 50} autres' : ''}

💡 STRATÉGIE: Explore d'autres marques, d'autres catégories de produits dans le même domaine.
'''
        : '';

    // Obtenir les marques prioritaires selon le profil démographique
    final priorityBrands = userAge.isNotEmpty && userGender.isNotEmpty
        ? BrandList.getPriorityBrandsByProfile(age: userAge, gender: userGender)
        : <String>[];

    final priorityBrandsText = priorityBrands.isNotEmpty
        ? '''
🌟 MARQUES PRIORITAIRES pour ce profil (âge: $userAge, genre: $userGender):
${priorityBrands.join(', ')}

⚠️ IMPORTANT: Ces marques correspondent au profil démographique.
Privilégie-les pour au moins 40% de tes recommandations dans la catégorie "Pour toi".
'''
        : '';

    String categoryInstructions = '';

    switch (category) {
      case 'Pour toi':
        categoryInstructions = '''
🎯 CATÉGORIE: POUR TOI (Mix 40% Trending + 60% Personnalisé)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ PERSONNALISATION MAXIMALE - Adapte-toi au profil utilisateur ⚠️

👤 PROFIL UTILISATEUR:
• Âge: $userAge ans
• Genre: $userGender
• Centres d'intérêt: $userInterests
• Style: $userStyle

**Mission ULTRA-IMPORTANTE**: Génère des produits ADAPTÉS à CE profil spécifique:

📊 RÉPARTITION OBLIGATOIRE:
• 60% PERSONNALISÉ (Basé sur le profil utilisateur)
  → Si intérêts "tech" → Apple, Samsung, Dyson, Bose, gadgets innovants
  → Si intérêts "mode" → Zara, H&M, Sandro, Sézane, accessoires tendance
  → Si intérêts "sport" → Nike, Adidas, Lululemon, Decathlon, équipement
  → Si intérêts "bien-être" → Sephora, Rituals, L'Occitane, produits spa
  → Si intérêts "cuisine" → KitchenAid, Le Creuset, ustensiles premium
  → Adapte le style: $userStyle
  → Match score: 90-100

• 40% TRENDING (Best-sellers adaptés au profil)
  → Produits viraux qui correspondent à son âge et ses goûts
  → Nouveautés 2025 dans ses catégories d'intérêt
  → Must-have du moment adaptés à son style
  → Match score: 85-92

🎯 STRATÉGIE:
- PRIORITÉ: Utilise ses intérêts ($userInterests) pour choisir les produits
- STYLE: Respecte son style ($userStyle) dans tous les choix
- ÂGE: Adapte au profil démographique ($userAge ans, $userGender)
- DIVERSITÉ: Varie mais reste dans ses centres d'intérêt
- MARQUES: Utilise les marques prioritaires pour son profil
''';
        break;

      case 'Tendances':
        categoryInstructions = '''
🔥 CATÉGORIE: TENDANCES 2025
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
**Mission**: Suggère les produits les PLUS TENDANCE du moment.
- Produits viraux sur TikTok/Instagram 2025
- Nouveautés des collections printemps/été 2025
- Best-sellers actuels des marques
- Must-have de la saison
- Prix variés: 20€ à 300€
- DIVERSITÉ: Mode, Tech, Beauty, Lifestyle
- Match score: 80-95
''';
        break;

      case 'Tech':
        categoryInstructions = '''
📱 CATÉGORIE: TECH & INNOVATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
**Mission**: Suggère les meilleurs produits TECH.
- Smartphones, écouteurs, montres connectées
- Gadgets innovants 2025
- Gaming (consoles, accessoires)
- Smart home (Dyson, Nest, Philips Hue)
- Photo/Vidéo (GoPro, DJI)
- Marques prioritaires: Apple, Samsung, Sony, Bose, JBL, Nintendo, PlayStation, Logitech
- Prix: 30€ à 500€
- Match score: 75-95
''';
        break;

      case 'Mode':
        categoryInstructions = '''
👗 CATÉGORIE: MODE & STYLE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
**Mission**: Suggère les must-have MODE actuels.
- Vêtements tendance (Zara, H&M, Mango, Sandro, Sézane)
- Accessoires (sacs, bijoux, lunettes)
- Chaussures (sneakers, bottines)
- Pièces iconiques et basiques premium
- Mix streetwear et élégant
- Prix: 25€ à 350€
- Match score: 80-95
''';
        break;

      case 'Maison':
        categoryInstructions = '''
🏠 CATÉGORIE: MAISON & DÉCO
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
**Mission**: Suggère des produits pour embellir l'intérieur.
- Déco design (Ikea, Maisons du Monde, Zara Home)
- Électroménager stylé (Dyson, SMEG, KitchenAid)
- Luminaires (Philips Hue, Flos)
- Textiles cosy (coussins, plaids, bougies)
- Plantes d'intérieur tendance
- Prix: 20€ à 400€
- Match score: 75-92
''';
        break;

      case 'Beauté':
        categoryInstructions = '''
💄 CATÉGORIE: BEAUTÉ & SOIN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
**Mission**: Suggère les meilleurs produits BEAUTÉ.
- Skincare (Sephora, Kiehl's, The Ordinary, Dr. Barbara Sturm)
- Makeup (Fenty, Rare Beauty, Charlotte Tilbury, NARS)
- Parfums luxe (Le Labo, Byredo, Diptyque, Jo Malone)
- Soins cheveux (Dyson, Olaplex)
- Coffrets cadeaux premium
- Prix: 25€ à 350€
- Match score: 80-95
''';
        break;

      case 'Food':
        categoryInstructions = '''
🍷 CATÉGORIE: FOOD & GASTRONOMIE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
**Mission**: Suggère des produits GOURMANDS et raffinés.
- Chocolats d'exception (Pierre Hermé, La Maison du Chocolat, Ladurée)
- Thés et cafés premium (Kusmi Tea, Mariage Frères, Nespresso)
- Vins et champagnes
- Accessoires cuisine design (KitchenAid, Le Creuset)
- Épicerie fine
- Prix: 20€ à 250€
- Match score: 75-90
''';
        break;

      default:
        categoryInstructions = '''
🎁 CATÉGORIE: SÉLECTION VARIÉE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
**Mission**: Mélange harmonieux de toutes les catégories.
- Mix équilibré: Mode, Tech, Beauté, Déco, Food
- Produits populaires et originaux
- Prix variés: 20€ à 300€
- Match score: 75-92
''';
    }

    return '''
🎯 CONTEXTE CRITIQUE - LIS ATTENTIVEMENT 🎯
═══════════════════════════════════════════════════════════
⚠️ CECI EST UN FEED D'INSPIRATION PERSONNALISÉ ⚠️
Tu génères des produits pour le FEED PERSONNEL de l'utilisateur (type Pinterest).
Ce N'EST PAS des cadeaux pour quelqu'un d'autre, c'est pour l'UTILISATEUR lui-même.

Focus: Produits adaptés aux GOÛTS de l'utilisateur (âge: $userAge, genre: $userGender)
Approche: Mix de trending + personnalisé selon ses intérêts ($userInterests) et son style ($userStyle)
Différence clé: Feed POUR L'UTILISATEUR vs. Cadeaux POUR QUELQU'UN D'AUTRE

🔄 VARIATION FORCÉE - ID UNIQUE: $uniqueId
⚠️ IMPORTANT: À chaque nouvelle requête, tu DOIS varier les produits suggérés.
• NE répète PAS les mêmes produits qu'avant
• Explore différentes marques à chaque fois
• Varie les gammes de prix
• Propose des produits originaux et surprenants
• Utilise cet ID unique pour te souvenir de varier: $uniqueId
$seenProductsText
═══════════════════════════════════════════════════════════
📋 MISSION
═══════════════════════════════════════════════════════════
Génère $count produits RÉELS pour un feed d'inspiration type Pinterest.

$categoryInstructions

$priorityBrandsText

═══════════════════════════════════════════════════════════
🏪 LISTE COMPLÈTE DES MARQUES DISPONIBLES (400+)
═══════════════════════════════════════════════════════════
$allBrands

💡 Explore TOUTE cette diversité de marques, pas juste les classiques

═══════════════════════════════════════════════════════════
📋 INSTRUCTIONS STRICTES
═══════════════════════════════════════════════════════════
1. **PRODUITS RÉELS UNIQUEMENT**: Produits qui EXISTENT vraiment dans ces marques

2. **DIVERSITÉ MAXIMALE OBLIGATOIRE** ⚠️ ULTRA-IMPORTANT ⚠️:
   - JAMAIS 2 produits de la MÊME sous-catégorie consécutifs
   - JAMAIS plus de 2 produits d'une MÊME sous-catégorie dans toute la liste
   - Exemple INTERDIT : Chaussures → Chaussures → Chaussures ❌
   - Exemple INTERDIT : Sac → Sac → Pull → Sac → Sac ❌
   - Exemple CORRECT : Chaussures → Tech → Beauté → Vêtement → Déco → Bijoux → Chaussures ✅
   - Alterne OBLIGATOIREMENT entre catégories :
     * Mode (Vêtements, Chaussures, Sacs, Bijoux, Lunettes)
     * Tech (Électronique, Gadgets, Audio, Gaming)
     * Beauté (Maquillage, Parfum, Soin)
     * Maison (Déco, Cuisine, Linge)
     * Sport (Équipement, Vêtements sport)
     * Culture (Livres, Jeux, Loisirs)

3. **IMAGES UNSPLASH**: Fournis des URLs d'images Unsplash pertinentes
   Format: https://images.unsplash.com/photo-[ID]?w=600&q=80

4. **URLS PRODUITS SPÉCIFIQUES - ULTRA CRITIQUE**
   ⚠️⚠️⚠️ ATTENTION MAXIMALE SUR CE POINT ⚠️⚠️⚠️

   Tu DOIS fournir des liens vers les PAGES PRODUITS EXACTES, pas les sites de marques !

   ✅ BON EXEMPLE:
   • "url": "https://www.zara.com/fr/pull-cachemire-col-rond-p01234567.html"
   • "url": "https://www.apple.com/fr/shop/buy-iphone/iphone-15-pro"
   • "url": "https://www.nike.com/fr/t/air-max-90-chaussure-1234567"

   ❌ MAUVAIS EXEMPLE (NE FAIS JAMAIS ÇA):
   • "url": "https://www.zara.com/fr"  ❌ Trop générique !
   • "url": "https://www.nike.com"     ❌ Pas le lien produit !

   📋 STRATÉGIE SI TU NE CONNAIS PAS L'URL EXACTE:
   • Utilise: "https://www.google.com/search?q=[Marque]+[Nom Produit Complet]"
   • Exemple: "https://www.google.com/search?q=Nike+Air+Max+90+White"

   💡 L'utilisateur DOIT pouvoir cliquer et arriver DIRECTEMENT sur le produit

5. **PRIX RÉALISTES**: Entre 20€ et 500€ selon la catégorie

6. **DESCRIPTIONS ENGAGEANTES**: 2-3 phrases inspirantes

7. **FORMAT JSON STRICT**: Réponds UNIQUEMENT en JSON valide

═══════════════════════════════════════════════════════════
📦 FORMAT DE RÉPONSE (JSON UNIQUEMENT)
═══════════════════════════════════════════════════════════
{
  "products": [
    {
      "id": 1,
      "name": "Nom commercial exact du produit",
      "description": "Description engageante et inspirante (2-3 phrases)",
      "price": 89,
      "brand": "Marque exacte",
      "source": "Nom du magasin",
      "url": "https://www.siteofficial.com/product-name-p12345.html",
      "match": 88,
      "image": "https://images.unsplash.com/photo-xxxxx?w=600&q=80",
      "category": "Catégorie"
    }
  ]
}

⚠️ CRUCIAL: Réponds SEULEMENT avec le JSON, pas de texte explicatif avant ou après.
⚠️ RAPPEL URLS: Chaque "url" doit pointer vers la PAGE PRODUIT SPÉCIFIQUE !
''';
  }

  /// Produits de secours par catégorie
  static List<Map<String, dynamic>> _getFallbackHomeProducts(String category) {
    // Products de base avec différentes catégories
    final allProducts = [
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
        'name': 'Bougie Parfumée Diptyque',
        'description':
            'Ambiance cosy instantanée. Parfum envoûtant qui transforme votre intérieur.',
        'price': 68,
        'brand': 'Diptyque',
        'source': 'Sephora',
        'image':
            'https://images.unsplash.com/photo-1602874801006-e0c97c1c6122?w=600&q=80',
        'match': 85,
        'category': 'Maison',
        'url': 'https://www.sephora.fr',
      },
      {
        'id': 5,
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
        'id': 6,
        'name': 'Chocolats Pierre Hermé',
        'description':
            'Sélection gourmande d\'exception. L\'excellence de la haute pâtisserie française.',
        'price': 45,
        'brand': 'Pierre Hermé',
        'source': 'Pierre Hermé',
        'image':
            'https://images.unsplash.com/photo-1481391243133-f96216dcb5d2?w=600&q=80',
        'match': 82,
        'category': 'Food',
        'url': 'https://www.pierreherme.com',
      },
      {
        'id': 7,
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
      {
        'id': 8,
        'name': 'Sac Polène Numéro Un',
        'description':
            'Maroquinerie française d\'excellence. Design minimaliste et élégant.',
        'price': 360,
        'brand': 'Polène',
        'source': 'Polène',
        'image':
            'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=600&q=80',
        'match': 91,
        'category': 'Mode',
        'url': 'https://www.polene-paris.com',
      },
    ];

    // Filtrer selon la catégorie
    if (category == 'Tech') {
      return allProducts
          .where((p) => p['category'] == 'Tech')
          .toList();
    } else if (category == 'Mode') {
      return allProducts
          .where((p) => p['category'] == 'Mode')
          .toList();
    } else if (category == 'Beauté') {
      return allProducts
          .where((p) => p['category'] == 'Beauté')
          .toList();
    } else if (category == 'Maison') {
      return allProducts
          .where((p) => p['category'] == 'Maison')
          .toList();
    } else if (category == 'Food') {
      return allProducts
          .where((p) => p['category'] == 'Food')
          .toList();
    }

    return allProducts;
  }
}
