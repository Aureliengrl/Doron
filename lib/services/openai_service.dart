import 'dart:convert';
import 'package:http/http.dart' as http;
import '/environment_values.dart';
import 'http_service.dart';

/// Service pour intégrer OpenAI et générer des suggestions de cadeaux
class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1';

  /// Récupère la clé API depuis les variables d'environnement
  /// ⚠️ SÉCURISÉ : La clé doit être définie dans environment_values.dart
  static String get apiKey {
    final envKey = FFDevEnvironmentValues().openAiApiKey;
    if (envKey.isEmpty) {
      throw Exception(
        'OpenAI API Key not configured. Please add it to environment_values.dart'
      );
    }
    return envKey;
  }

  /// Marques ULTRA-PRIORITAIRES pour FEMMES (à privilégier en premier)
  static const List<String> topPriorityBrandsFemale = [
    'Zara', 'Maje', 'ba&sh', 'Isabel Marant', 'Ganni', 'Miu Miu',
    'Rhude', 'Zara Home', 'SMEG', 'Apple', 'Messika', 'Alo Yoga',
  ];

  /// Marques ULTRA-PRIORITAIRES pour HOMMES (à privilégier en premier)
  static const List<String> topPriorityBrandsMale = [
    'Tom Ford', 'StockX', 'Bell', 'Apple', 'Fnac', 'Zara', 'On Running',
  ];

  /// Toutes les marques disponibles (185 marques)
  static const List<String> allBrands = [
    'Zara', 'Zara Men', 'Zara Women', 'Zara Home', 'H&M', 'Mango',
    'Stradivarius', 'Bershka', 'Pull & Bear', 'Massimo Dutti', 'Uniqlo',
    'COS', 'Arket', 'Weekday', '& Other Stories', 'Sézane', 'Sandro',
    'Maje', 'Claudie Pierlot', 'ba&sh', 'The Kooples', 'A.P.C.', 'AMI Paris',
    'Isabel Marant', 'Jacquemus', 'Reformation', 'Ganni', 'Totême',
    'Anine Bing', 'The Frankie Shop', 'Acne Studios', 'Lemaire',
    'Officine Générale', 'Maison Margiela', 'Saint Laurent', 'Louis Vuitton',
    'Dior', 'Chanel', 'Gucci', 'Prada', 'Miu Miu', 'Fendi', 'Celine',
    'Balenciaga', 'Loewe', 'Valentino', 'Givenchy', 'Burberry',
    'Alexander McQueen', 'Versace', 'Balmain', 'Bottega Veneta', 'Hermès',
    'Alaïa', 'JW Anderson', 'Rick Owens', 'Tom Ford', 'Golden Goose',
    'Off-White', 'Palm Angels', 'Fear of God', 'Rhude', 'Aime Leon Dore',
    'Stone Island', 'C.P. Company', 'Carhartt WIP', 'Stüssy', 'Kith',
    'Supreme', 'Moncler', 'Canada Goose', 'Arc\'teryx', 'The North Face',
    'Patagonia', 'Fusalp', 'Rossignol', 'On Running', 'HOKA', 'Lululemon',
    'Alo Yoga', 'Gymshark', 'Nike', 'Adidas', 'Jordan', 'New Balance',
    'Puma', 'Asics', 'Salomon', 'Veja', 'Autry', 'Common Projects',
    'Axel Arigato', 'Converse', 'Vans', 'Maison Kitsuné', 'Balibaris',
    'Le Slip Français', 'Faguo', 'American Vintage', 'Soeur', 'Sessùn',
    'Maison Labiche', 'De Bonne Facture', 'Le Bon Marché',
    'Galeries Lafayette', 'Printemps', 'La Redoute', 'La Samaritaine',
    'Selfridges', 'Harrods', 'El Corte Inglés', 'IKEA', 'Maisons du Monde',
    'H&M Home', 'Habitat', 'Alinéa', 'Made.com', 'Vitra', 'Hay', 'Muuto',
    'Ferm Living', 'Kartell', 'Tom Dixon', 'Alessi', 'Flos', 'Artemide',
    'Dyson', 'SMEG', 'KitchenAid', 'Nespresso', 'De\'Longhi', 'Moccamaster',
    'Le Creuset', 'Staub', 'Riedel', 'Le Petit Lunetier', 'Ray-Ban',
    'Persol', 'Oliver Peoples', 'Warby Parker', 'Cutler and Gross',
    'Linda Farrow', 'Polène', 'Lancel', 'Longchamp', 'Cuyana', 'Coach',
    'MCM', 'Rimowa', 'Tumi', 'Away', 'Samsonite', 'Delsey',
    'Briggs & Riley', 'Montblanc', 'Bellroy', 'Nomad Goods', 'Peak Design',
    'Native Union', 'Mujjo', 'Apple', 'Samsung', 'Google Pixel', 'Dyson Tech',
    'Bose', 'Sony', 'JBL', 'Marshall', 'Bang & Olufsen', 'Bowers & Wilkins',
    'Sennheiser', 'Devialet', 'Nothing', 'GoPro', 'DJI', 'Withings', 'Garmin',
    'Kindle', 'PlayStation', 'Xbox', 'Nintendo', 'Logitech G', 'Razer',
    'SteelSeries', 'Secretlab', 'Scuf', 'Bell', 'POC', 'Giro', 'Kask', 'HJC',
    'Shark', 'Eram', 'Jonak', 'Minelli', 'Bocage', 'Dr. Martens', 'Paraboot',
    'J.M. Weston', 'Tod\'s', 'Church\'s', 'Santoni', 'Hogan',
    'Gianvito Rossi', 'Amina Muaddi', 'Aquazzura', 'Roger Vivier', 'By Far',
    'Pandora', 'Swarovski', 'Tiffany & Co.', 'Cartier',
    'Van Cleef & Arpels', 'Bulgari', 'Messika', 'Chaumet', 'Fred',
    'Dinh Van', 'Repossi', 'Aristocrazy', 'Maison Cléo', 'Le Labo', 'Byredo',
    'Diptyque', 'Maison Francis Kurkdjian', 'Kilian Paris', 'Creed',
    'Parfums de Marly', 'BDK Parfums', 'DS & Durga', 'Jo Malone London',
    'Aesop', 'Cire Trudon', 'Acqua di Parma', 'Dior Beauty', 'Chanel Beauty',
    'YSL Beauty', 'Lancôme', 'Estée Lauder', 'La Mer', 'La Prairie',
    'Guerlain', 'Shiseido', 'Charlotte Tilbury', 'Armani Beauty', 'Hourglass',
    'NARS', 'Pat McGrath Labs', 'Fenty Beauty', 'Rare Beauty', 'Tatcha',
    'Dr. Barbara Sturm', 'Augustinus Bader', 'SkinCeuticals',
    'Drunk Elephant', 'Summer Fridays', 'Sephora', 'Marionnaud', 'Nocibé',
    'LookFantastic', 'Cult Beauty', 'FeelUnique', 'Kiehl\'s', 'The Ordinary',
    'Paula\'s Choice', 'Glossier', 'Rituals', 'L\'Occitane', 'The Body Shop',
    'Amazon', 'Zalando', 'Asos', 'Farfetch', 'Net-A-Porter', 'MyTheresa',
    'SSENSE', 'MatchesFashion', 'END Clothing', 'Mr Porter', 'Browns Fashion',
    'StockX', 'GOAT', 'Chrono24', 'Back Market', 'Rakuten', 'Cdiscount',
    'Nature & Découvertes', 'Fnac', 'Darty', 'Boulanger', 'Cultura',
    'Decathlon', 'Go Sport', 'Courir', 'Foot Locker', 'JD Sports', 'Lush',
    'Yves Rocher', 'KIKO Milano', 'La Maison du Chocolat', 'Pierre Hermé',
    'Ladurée', 'Fauchon', 'Angelina', 'Pierre Marcolini', 'Godiva', 'Venchi',
    'Patrick Roger', 'Maison Plisson', 'Kusmi Tea', 'Mariage Frères',
    'Dammann Frères', 'Muji', 'Monoprix', 'Promod', 'Rhode',
  ];

  /// Génère des suggestions de cadeaux basées sur les réponses d'onboarding
  static Future<List<Map<String, dynamic>>> generateGiftSuggestions({
    required Map<String, dynamic> onboardingAnswers,
    int count = 12,
  }) async {
    try {
      final prompt = _buildPrompt(onboardingAnswers, count);

      final response = await HttpService.postWithRetry(
        url: Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({
          'model': 'gpt-4o', // ou 'gpt-4-turbo' ou 'gpt-3.5-turbo'
          'messages': [
            {
              'role': 'system',
              'content':
                  'Tu es un expert en suggestions de cadeaux personnalisés. '
                  'Tu recommandes des produits de marques premium et accessibles. '
                  'Réponds UNIQUEMENT en JSON valide sans texte avant ou après.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 0.8,
          'max_tokens': 2000,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'] as String;

        // Parser le JSON retourné par GPT
        final giftsData = json.decode(content);
        final giftsList = giftsData['gifts'] as List;

        return giftsList.map((gift) {
          // Générer une URL de fallback basée sur la source
          String getFallbackUrl(String source) {
            final sourceMap = {
              'Sephora': 'https://www.sephora.fr',
              'Fnac': 'https://www.fnac.com',
              'Zara': 'https://www.zara.com/fr',
              'Apple': 'https://www.apple.com/fr',
              'Amazon': 'https://www.amazon.fr',
              'H&M': 'https://www.hm.com/fr',
              'Mango': 'https://www.mango.com/fr',
              'Ikea': 'https://www.ikea.com/fr',
              'Nature & Découvertes': 'https://www.natureetdecouvertes.com',
              'Kusmi Tea': 'https://www.kusmitea.com/fr',
              'Leroy Merlin': 'https://www.leroymerlin.fr',
              'Decathlon': 'https://www.decathlon.fr',
              'Galeries Lafayette': 'https://www.galerieslafayette.com',
            };
            return sourceMap[source] ?? 'https://www.google.com/search?q=${Uri.encodeComponent(gift['name'] ?? 'cadeau')}';
          }

          return {
            'id': gift['id'] ?? DateTime.now().millisecondsSinceEpoch,
            'name': gift['name'] ?? 'Produit',
            'description': gift['description'] ?? '',
            'price': gift['price'] ?? 0,
            'brand': gift['brand'] ?? '',
            'source': gift['source'] ?? 'En ligne',
            'match': gift['match'] ?? 80,
            'reason': gift['reason'] ?? 'Parfait pour cette personne',
            'image': gift['image'] ??
                'https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=600&q=80',
            'category': gift['category'] ?? 'Général',
            'url': gift['url'] ?? getFallbackUrl(gift['source'] ?? 'Amazon'),
          };
        }).toList();
      } else {
        print('❌ Erreur OpenAI: ${response.statusCode}');
        print('Body: ${response.body}');
        return _getFallbackGifts(onboardingAnswers);
      }
    } catch (e) {
      print('❌ Exception OpenAI: $e');
      return _getFallbackGifts(onboardingAnswers);
    }
  }

  /// Construit le prompt pour OpenAI
  static String _buildPrompt(Map<String, dynamic> answers, int count) {
    // Informations sur le DESTINATAIRE
    final recipient = answers['recipient'] ?? 'une personne';
    final budget = answers['budget'] ?? 50;
    final recipientAge = answers['recipientAge'] ?? 'adulte';
    final recipientHobbies = (answers['recipientHobbies'] as List?)?.join(', ') ?? '';
    final recipientPersonality = (answers['recipientPersonality'] as List?)?.join(', ') ?? '';
    final occasion = answers['occasion'] ?? 'sans occasion';
    final recipientStyle = answers['recipientStyle'] ?? '';
    final recipientLifeSituation = answers['recipientLifeSituation'] ?? '';
    final alreadyHas = (answers['recipientAlreadyHas'] as List?)?.join(', ') ?? '';
    final relationDuration = answers['recipientRelationDuration'] ?? '';

    // Informations sur L'UTILISATEUR (celui qui offre)
    final userAge = answers['age'] ?? '';
    final userGender = answers['gender'] ?? '';
    final userInterests = (answers['interests'] as List?)?.join(', ') ?? '';
    final userStyle = answers['style'] ?? '';
    final userGiftTypes = (answers['giftTypes'] as List?)?.join(', ') ?? '';

    // Catégories préférées
    final categories = (answers['preferredCategories'] as List?)?.join(', ') ?? '';

    // Déterminer le genre pour les marques prioritaires
    final gender = answers['gender'] ?? '';
    final isFemale = gender.toLowerCase().contains('femme') ||
                     gender.toLowerCase().contains('fille') ||
                     recipient.toLowerCase().contains('maman') ||
                     recipient.toLowerCase().contains('sœur') ||
                     recipient.toLowerCase().contains('amie') ||
                     recipient.toLowerCase().contains('copine') ||
                     recipient.toLowerCase().contains('grand-mère');

    // Sélectionner les marques prioritaires selon le genre
    final topBrands = isFemale ? topPriorityBrandsFemale : topPriorityBrandsMale;
    final topBrandsString = topBrands.join(', ');
    final allBrandsString = allBrands.join(', ');

    return '''
Génère $count suggestions de cadeaux ULTRA-PERSONNALISÉS basées sur un profil détaillé.

═══════════════════════════════════════════════════════════
👤 PROFIL DU DESTINATAIRE (personne qui REÇOIT le cadeau)
═══════════════════════════════════════════════════════════
• Relation : $recipient
• Âge : $recipientAge
• Budget disponible : $budget€
• Passions/Hobbies : $recipientHobbies
• Personnalité : $recipientPersonality
• Situation : $recipientLifeSituation
• Style vestimentaire : $recipientStyle
• Occasion : $occasion
${relationDuration.isNotEmpty ? '• Durée de la relation : $relationDuration' : ''}
${alreadyHas.isNotEmpty ? '• ⚠️ POSSÈDE DÉJÀ : $alreadyHas (NE PAS suggérer ces articles)' : ''}

═══════════════════════════════════════════════════════════
🎁 PROFIL DE L'OFFREUR (personne qui OFFRE le cadeau)
═══════════════════════════════════════════════════════════
• Âge : $userAge
• Genre : $userGender
• Centres d'intérêt : $userInterests
• Style personnel : $userStyle
• Types de cadeaux préférés : $userGiftTypes
${categories.isNotEmpty ? '• Catégories favorites : $categories' : ''}

═══════════════════════════════════════════════════════════
⭐ MARQUES À PRIVILÉGIER EN PRIORITÉ (mise en avant)
═══════════════════════════════════════════════════════════
$topBrandsString

═══════════════════════════════════════════════════════════
🏪 TOUTES LES MARQUES DISPONIBLES (185 marques)
═══════════════════════════════════════════════════════════
$allBrandsString

═══════════════════════════════════════════════════════════
📋 INSTRUCTIONS STRICTES
═══════════════════════════════════════════════════════════
1. **MARQUES PRIORITAIRES** : Utilise EN PRIORITÉ les marques de la section "⭐ À PRIVILÉGIER" (au moins 50% des produits)
2. **UTILISE LES DEUX PROFILS** : Le destinataire (ses goûts) ET l'offreur (son style de cadeau)
3. **PRODUITS RÉELS UNIQUEMENT** : Suggère des produits qui EXISTENT vraiment dans ces marques
4. **VARIATION DES PRIX** : Entre ${(budget * 0.5).toInt()}€ et ${(budget * 1.5).toInt()}€ autour du budget
5. **DIVERSITÉ MAXIMALE OBLIGATOIRE** :
   - JAMAIS 2 produits de la même catégorie consécutifs
   - JAMAIS plus de 2 produits d'une même catégorie dans toute la liste
   - Exemple INTERDIT : Chaussures → Chaussures → Chaussures ❌
   - Exemple CORRECT : Chaussures → Tech → Beauté → Vêtement → Déco → Chaussures ✅
   - Alterne : Mode → Tech → Beauté → Déco → Sport → Culture → Bijoux → Maison → etc.
6. **ÉVITE LES DOUBLONS** : Ne suggère PAS ce que la personne possède déjà
7. **SCORING PRÉCIS** : Match entre 75-100 basé sur la correspondance profil
8. **RAISONS PERSONNALISÉES** : Explique POURQUOI ce cadeau correspond (mentionne ses hobbies/personnalité)
9. **URLS RÉELLES** : Fournis des URLs valides vers les sites officiels des marques
10. **FORMAT JSON STRICT** : Réponds UNIQUEMENT en JSON valide, sans texte avant/après

═══════════════════════════════════════════════════════════
📦 FORMAT DE RÉPONSE (JSON UNIQUEMENT)
═══════════════════════════════════════════════════════════
{
  "gifts": [
    {
      "id": 1,
      "name": "Nom exact et commercial du produit",
      "description": "Description détaillée et engageante (2-3 phrases)",
      "price": 45,
      "brand": "Marque exacte",
      "source": "Nom du magasin (Sephora, Fnac, Apple, Zara, etc.)",
      "url": "https://www.siteofficial.com/produit",
      "match": 95,
      "reason": "Raison personnalisée utilisant le profil (hobbies, personnalité, occasion)",
      "category": "Catégorie du produit"
    }
  ]
}

⚠️ CRUCIAL : Réponds SEULEMENT avec le JSON, pas de texte explicatif avant ou après.
''';
  }

  /// Cadeaux de secours si OpenAI échoue
  static List<Map<String, dynamic>> _getFallbackGifts(
      Map<String, dynamic> answers) {
    // FIX: Cast sécurisé - budget peut être int, double ou String
    final budgetRaw = answers['budget'] ?? 50;
    final budget = budgetRaw is double ? budgetRaw : (budgetRaw is int ? budgetRaw.toDouble() : 50.0);

    return [
      {
        'id': 1,
        'name': 'Coffret Spa Luxe Premium',
        'description':
            'Un moment de détente incomparable avec huiles essentielles, bougies parfumées et accessoires de massage.',
        'price': budget.toInt(),
        'brand': 'Sephora',
        'source': 'Sephora',
        'match': 92,
        'reason':
            'Parfait pour se détendre. Correspond aux goûts pour le bien-être.',
        'image':
            'https://images.unsplash.com/photo-1596755389378-c31d21fd1273?w=600&q=80',
        'category': 'Bien-être',
        'url': 'https://www.sephora.fr',
      },
      {
        'id': 2,
        'name': 'Écouteurs Sans Fil Premium',
        'description':
            'Écouteurs Bluetooth avec réduction de bruit active et autonomie 24h.',
        'price': (budget * 1.2).toInt(),
        'brand': 'Apple',
        'source': 'Apple',
        'match': 89,
        'reason': 'Pour écouter de la musique avec une qualité exceptionnelle.',
        'image':
            'https://images.unsplash.com/photo-1606841837239-c5a1a4a07af7?w=600&q=80',
        'category': 'Tech',
        'url': 'https://www.apple.com/fr/airpods/',
      },
      {
        'id': 3,
        'name': 'Carnet de Voyage Artisanal',
        'description':
            'Carnet en cuir véritable pour noter tous les souvenirs de voyage.',
        'price': (budget * 0.6).toInt(),
        'brand': 'Moleskine',
        'source': 'Fnac',
        'match': 88,
        'reason': 'Idéal pour immortaliser les moments précieux.',
        'image':
            'https://images.unsplash.com/photo-1531346878377-a5be20888e57?w=600&q=80',
        'category': 'Papeterie',
        'url': 'https://www.fnac.com',
      },
      {
        'id': 4,
        'name': 'Pull Cachemire Doux',
        'description':
            'Pull en cachemire ultra-doux, coupe moderne, disponible en plusieurs coloris.',
        'price': (budget * 1.4).toInt(),
        'brand': 'Zara',
        'source': 'Zara',
        'match': 87,
        'reason': 'Un basique élégant pour toutes les occasions.',
        'image':
            'https://images.unsplash.com/photo-1576871337632-b9aef4c17ab9?w=600&q=80',
        'category': 'Mode',
        'url': 'https://www.zara.com/fr',
      },
      {
        'id': 5,
        'name': 'Bougie Parfumée Artisanale',
        'description':
            'Bougie de luxe faite à la main, parfum envoûtant. Durée: 60h.',
        'price': (budget * 0.7).toInt(),
        'brand': 'Diptyque',
        'source': 'Sephora',
        'match': 85,
        'reason': 'Crée une ambiance cosy à la maison.',
        'image':
            'https://images.unsplash.com/photo-1602874801006-e0c97c1c6122?w=600&q=80',
        'category': 'Déco',
        'url': 'https://www.sephora.fr',
      },
      {
        'id': 6,
        'name': 'Kit Jardinage Premium',
        'description':
            'Ensemble complet avec outils de qualité professionnelle et gants.',
        'price': (budget * 1.1).toInt(),
        'brand': 'Leroy Merlin',
        'source': 'Leroy Merlin',
        'match': 84,
        'reason': 'Pour jardiner avec des outils de qualité.',
        'image':
            'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=600&q=80',
        'category': 'Jardin',
        'url': 'https://www.leroymerlin.fr',
      },
      {
        'id': 7,
        'name': 'Livre de Recettes Gourmet',
        'description':
            'Plus de 200 recettes raffinées avec photos magnifiques et instructions détaillées.',
        'price': (budget * 0.5).toInt(),
        'brand': 'Fnac',
        'source': 'Fnac',
        'match': 92,
        'reason': 'Pour les amateurs de cuisine qui aiment créer.',
        'image':
            'https://images.unsplash.com/photo-1543362906-acfc16c67564?w=600&q=80',
        'category': 'Culture',
        'url': 'https://www.fnac.com',
      },
      {
        'id': 8,
        'name': 'Sac à Main en Cuir',
        'description':
            'Sac élégant en cuir véritable, pratique et intemporel.',
        'price': (budget * 1.5).toInt(),
        'brand': 'Mango',
        'source': 'Mango',
        'match': 88,
        'reason': 'Un accessoire chic pour toutes les occasions.',
        'image':
            'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=600&q=80',
        'category': 'Accessoires',
        'url': 'https://www.mango.com/fr',
      },
      {
        'id': 9,
        'name': 'Coffret Thé Premium',
        'description':
            'Sélection de 12 thés rares du monde entier dans un magnifique coffret en bois.',
        'price': (budget * 0.8).toInt(),
        'brand': 'Kusmi Tea',
        'source': 'Kusmi Tea',
        'match': 87,
        'reason': 'Pour les amateurs de thé qui apprécient la qualité.',
        'image':
            'https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=600&q=80',
        'category': 'Gastronomie',
        'url': 'https://www.kusmitea.com/fr',
      },
      {
        'id': 10,
        'name': 'Montre Connectée Fitness',
        'description':
            'Montre intelligente avec suivi d\'activité, fréquence cardiaque et GPS intégré.',
        'price': (budget * 2.5).toInt(),
        'brand': 'Apple',
        'source': 'Apple',
        'match': 90,
        'reason': 'Pour suivre ses objectifs fitness au quotidien avec style.',
        'image':
            'https://images.unsplash.com/photo-1579586337278-3befd40fd17a?w=600&q=80',
        'category': 'Tech',
        'url': 'https://www.apple.com/fr/watch/',
      },
      {
        'id': 11,
        'name': 'Plaid Cachemire Doux',
        'description':
            'Plaid ultra-doux en cachemire, parfait pour les soirées cocooning.',
        'price': (budget * 1.3).toInt(),
        'brand': 'Zara Home',
        'source': 'Zara',
        'match': 86,
        'reason': 'Pour des moments cosy au coin du feu.',
        'image':
            'https://images.unsplash.com/photo-1584100936595-c0654b55a2e2?w=600&q=80',
        'category': 'Déco',
        'url': 'https://www.zara.com/fr/fr/home',
      },
      {
        'id': 12,
        'name': 'Coffret Soin Visage Bio',
        'description':
            'Routine complète de soin visage avec produits bio certifiés.',
        'price': (budget * 1.1).toInt(),
        'brand': 'Sephora',
        'source': 'Sephora',
        'match': 92,
        'reason': 'Pour prendre soin de sa peau naturellement.',
        'image':
            'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=600&q=80',
        'category': 'Beauté',
        'url': 'https://www.sephora.fr',
      },
    ];
  }

  /// Calcule un score de match basé sur les réponses (fallback si OpenAI ne donne pas)
  static int calculateMatchScore(
    Map<String, dynamic> gift,
    Map<String, dynamic> answers,
  ) {
    int score = 70; // Score de base

    // Budget match
    final giftPrice = gift['price'] as int? ?? 0;
    final budget = answers['budget'] as double? ?? 50;
    final priceDiff = (giftPrice - budget).abs();

    if (priceDiff <= budget * 0.2) {
      score += 15;
    } else if (priceDiff <= budget * 0.5) {
      score += 10;
    }

    // Catégories match
    final giftCategory = gift['category'] as String? ?? '';
    final preferredCats =
        answers['preferredCategories'] as List<String>? ?? [];

    if (preferredCats.any(
        (cat) => giftCategory.toLowerCase().contains(cat.toLowerCase()))) {
      score += 15;
    }

    return score.clamp(0, 100);
  }
}
