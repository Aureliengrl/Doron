import 'dart:convert';
import 'package:http/http.dart' as http;
import 'openai_service.dart';

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
    try {
      final prompt = _buildHomeCategoryPrompt(category, userProfile, count);

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
                  'Tu es un expert en curation de produits et tendances. '
                  'Tu recommandes des produits réels de marques premium et accessibles. '
                  'Réponds UNIQUEMENT en JSON valide sans texte avant ou après.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 0.9,
          'max_tokens': 2500,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'] as String;

        // Parser le JSON retourné par GPT
        final productsData = json.decode(content);
        final productsList = productsData['products'] as List;

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
        print('❌ Erreur OpenAI Home: ${response.statusCode}');
        return _getFallbackHomeProducts(category);
      }
    } catch (e) {
      print('❌ Exception OpenAI Home: $e');
      return _getFallbackHomeProducts(category);
    }
  }

  /// Construit le prompt pour générer des produits par catégorie
  static String _buildHomeCategoryPrompt(
    String category,
    Map<String, dynamic>? userProfile,
    int count,
  ) {
    final brandsString = OpenAIService.priorityBrands.take(60).join(', ');

    // Récupérer les tags utilisateur si disponibles
    final userAge = userProfile?['age'] ?? '';
    final userGender = userProfile?['gender'] ?? '';
    final userInterests = (userProfile?['interests'] as List?)?.join(', ') ?? '';
    final userStyle = userProfile?['style'] ?? '';

    String categoryInstructions = '';

    switch (category) {
      case 'Pour toi':
        categoryInstructions = '''
🎯 CATÉGORIE: POUR TOI (Mix 70% Trending + 30% Personnalisé)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Profil utilisateur:
• Âge: $userAge
• Genre: $userGender
• Centres d'intérêt: $userInterests
• Style: $userStyle

**Mission IMPORTANTE**: Génère un mix intelligent de produits:

📊 RÉPARTITION OBLIGATOIRE:
• 70% TRENDING (Best-sellers, produits populaires)
  → iPhone 15 Pro, AirPods Pro, Apple Watch, Stanley Cup, Lululemon leggings
  → Derniers produits viraux TikTok/Instagram
  → Top produits des marques premium (Apple, Nike, Zara, Sephora)
  → Must-have du moment, nouveautés 2025
  → Match score: 80-92

• 30% PERSONNALISÉ (Basé sur le profil utilisateur)
  → Utilise SES centres d'intérêt: $userInterests
  → Adapte au style: $userStyle
  → Produits qui correspondent à SA personnalité
  → Match score: 90-100

🎯 STRATÉGIE:
- Commence avec les best-sellers universels (iPhone, AirPods, Stanley, etc.)
- Puis insère des produits personnalisés selon ses intérêts
- Alterne intelligemment entre trending et personnalisé
- Diversifie les catégories: Mode, Tech, Beauté, Déco, Sport, Culture
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
Génère $count produits RÉELS pour un feed d'inspiration type Pinterest.

$categoryInstructions

═══════════════════════════════════════════════════════════
🏪 MARQUES À UTILISER PRIORITAIREMENT
═══════════════════════════════════════════════════════════
$brandsString

═══════════════════════════════════════════════════════════
📋 INSTRUCTIONS STRICTES
═══════════════════════════════════════════════════════════
1. **PRODUITS RÉELS UNIQUEMENT**: Produits qui EXISTENT vraiment dans ces marques
2. **IMAGES UNSPLASH**: Fournis des URLs d'images Unsplash pertinentes
   Format: https://images.unsplash.com/photo-[ID]?w=600&q=80
3. **URLs OFFICIELLES**: Liens vers les sites officiels des marques
4. **PRIX RÉALISTES**: Entre 20€ et 500€ selon la catégorie
5. **DESCRIPTIONS ENGAGEANTES**: 2-3 phrases inspirantes
6. **DIVERSITÉ**: Varie les marques et sous-catégories
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
      "url": "https://www.siteofficial.com",
      "match": 88,
      "image": "https://images.unsplash.com/photo-xxxxx?w=600&q=80",
      "category": "Catégorie"
    }
  ]
}

⚠️ CRUCIAL: Réponds SEULEMENT avec le JSON, pas de texte explicatif avant ou après.
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
