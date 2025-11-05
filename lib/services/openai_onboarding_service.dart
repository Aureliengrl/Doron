import 'dart:convert';
import 'package:http/http.dart' as http;
import 'openai_service.dart';

/// Service dédié à la génération de cadeaux personnalisés après l'onboarding
class OpenAIOnboardingService {
  static const String _baseUrl = 'https://api.openai.com/v1';

  /// Génère des cadeaux personnalisés basés sur le profil utilisateur de l'onboarding
  static Future<List<Map<String, dynamic>>> generateOnboardingGifts({
    required Map<String, dynamic> userProfile,
    int count = 30,
  }) async {
    try {
      final prompt = _buildOnboardingPrompt(userProfile, count);

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
                  'Tu es un expert en curation de cadeaux personnalisés. '
                  'Tu recommandes des produits réels de marques premium et accessibles. '
                  'Tu aimes explorer différentes marques et catégories pour offrir une grande variété. '
                  'Réponds UNIQUEMENT en JSON valide sans texte avant ou après.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 1.3,
          'top_p': 0.95,
          'max_tokens': 3500,
          'frequency_penalty': 0.7,
          'presence_penalty': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'] as String;

        // Parser le JSON retourné par GPT
        final productsData = json.decode(content);
        final productsList = productsData['products'] as List;

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
        print('❌ Erreur OpenAI Onboarding: ${response.statusCode}');
        return _getFallbackGifts();
      }
    } catch (e) {
      print('❌ Exception OpenAI Onboarding: $e');
      return _getFallbackGifts();
    }
  }

  /// Construit le prompt pour générer des cadeaux personnalisés
  static String _buildOnboardingPrompt(
    Map<String, dynamic> userProfile,
    int count,
  ) {
    final brandsString = OpenAIService.priorityBrands.take(60).join(', ');

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

    // Seed de variation pour forcer ChatGPT à générer des produits différents
    final refreshSeed = userProfile['_refresh_seed'] ?? '';
    final variation = userProfile['_variation'] ?? 0;
    final randomSeed = DateTime.now().microsecondsSinceEpoch % 10000;
    final variationInstructions = refreshSeed != ''
        ? '''
🔄 NOUVELLE SÉLECTION #$randomSeed 🔄
IMPORTANT: Cette requête nécessite des produits COMPLÈTEMENT DIFFÉRENTS des précédentes recommandations.
- Explore d'AUTRES marques que d'habitude
- Choisis des catégories VARIÉES et originales
- Propose des styles INNOVANTS et surprenants
- ÉVITE les produits classiques/prévisibles (écouteurs, t-shirts basiques, etc.)
'''
        : '';

    return '''
Génère $count produits cadeaux PERSONNALISÉS ET RÉELS pour un utilisateur.
Timestamp unique: $randomSeed
$variationInstructions

═══════════════════════════════════════════════════════════
🎯 PROFIL UTILISATEUR
═══════════════════════════════════════════════════════════
• Âge: $age
• Genre: $gender
• Centres d'intérêt: $interests
• Style: $style
• Types de cadeaux aimés: $giftTypes

═══════════════════════════════════════════════════════════
🎁 INFORMATIONS SUR LE CADEAU À TROUVER
═══════════════════════════════════════════════════════════
• Destinataire: $recipient
• Budget: ${budget}€
• Âge du destinataire: $recipientAge
• Passions du destinataire: $recipientHobbies
• Personnalité du destinataire: $recipientPersonality
• Style du destinataire: $recipientStyle
• Occasion: $occasion
• Catégories préférées: $preferredCategories

═══════════════════════════════════════════════════════════
🏪 MARQUES À UTILISER PRIORITAIREMENT
═══════════════════════════════════════════════════════════
$brandsString

═══════════════════════════════════════════════════════════
📋 INSTRUCTIONS STRICTES
═══════════════════════════════════════════════════════════
1. **ANALYSE DES TAGS OBLIGATOIRE**:
   - Lis attentivement TOUTES les infos du profil (passions: $recipientHobbies, personnalité: $recipientPersonality, style: $recipientStyle, occasion: $occasion)
   - Choisis les cadeaux EN FONCTION de ces tags spécifiques
   - Par exemple: "créative" → produits artistiques/DIY, "sportif" → équipement sport, "intellectuel" → livres/culture

2. **ULTRA-PERSONNALISÉ**: Chaque produit DOIT correspondre au profil exact du destinataire
   - Si c'est pour Noël: privilégie les cadeaux festifs
   - Si la personne est créative: propose des produits artistiques, DIY, design
   - Si elle aime le sport: équipements sportifs, vêtements techniques

3. **PRODUITS RÉELS UNIQUEMENT**: Produits qui EXISTENT vraiment dans ces marques

4. **BUDGET RESPECTÉ**: Prix entre 20€ et ${budget * 1.2}€ (légèrement au-dessus du budget si pertinent)

5. **IMAGES UNSPLASH**: Fournis des URLs d'images Unsplash de haute qualité et pertinentes
   Format: https://images.unsplash.com/photo-[ID]?w=600&q=80

6. **URLs OFFICIELLES**: Liens vers les sites officiels des marques (Apple, Zara, Sephora, etc.)

7. **DESCRIPTIONS ENGAGEANTES**: 2-3 phrases qui expliquent pourquoi ce cadeau est parfait pour cette personne SELON SES TAGS

8. **DIVERSITÉ MAXIMALE**: Varie les marques, les catégories, les styles - pas toujours les mêmes produits !

9. **MATCH SCORE**: Score de 80 à 100 selon la pertinence pour le destinataire

10. **FORMAT JSON STRICT**: Réponds UNIQUEMENT en JSON valide

═══════════════════════════════════════════════════════════
💡 CATÉGORIES À MÉLANGER INTELLIGEMMENT
═══════════════════════════════════════════════════════════
• Mode & Accessoires (Zara, H&M, Mango, Sandro, Sézane, Nike, Adidas)
• Tech & Innovation (Apple, Samsung, Sony, Bose, JBL, Dyson)
• Beauté & Soin (Sephora, Fenty, Kiehl's, Charlotte Tilbury, Diptyque)
• Maison & Déco (IKEA, Maisons du Monde, Zara Home, Philips Hue)
• Food & Gastronomie (Pierre Hermé, Ladurée, Kusmi Tea, Nespresso)
• Sport & Outdoor (Nike, Adidas, Decathlon, Lululemon)
• Culture & Loisirs (Fnac, Amazon, Moleskine)

═══════════════════════════════════════════════════════════
📦 FORMAT DE RÉPONSE (JSON UNIQUEMENT)
═══════════════════════════════════════════════════════════
{
  "products": [
    {
      "id": 1,
      "name": "Nom commercial exact du produit",
      "description": "Description personnalisée expliquant pourquoi ce cadeau est parfait pour le destinataire (2-3 phrases)",
      "price": 89,
      "brand": "Marque exacte",
      "source": "Nom du magasin",
      "url": "https://www.siteofficial.com/product",
      "match": 95,
      "image": "https://images.unsplash.com/photo-xxxxx?w=600&q=80",
      "category": "Catégorie du produit"
    }
  ]
}

⚠️ CRUCIAL:
- Réponds SEULEMENT avec le JSON, pas de texte explicatif avant ou après
- Privilégie les produits qui correspondent vraiment au profil
- Assure-toi que les liens URL sont vers les vrais sites officiels des marques
- Les images Unsplash doivent être pertinentes et de haute qualité
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
