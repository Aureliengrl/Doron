import 'dart:convert';
import 'package:doron/services/http_service.dart';
import 'package:flutter/foundation.dart';

/// Service pour analyser les transcriptions vocales avec OpenAI
class OpenAIVoiceAnalysisService {
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  /// Clé API OpenAI hardcodée - MÊME clé que api_calls.dart
  /// Pas besoin de passer par environment.json car la clé est déjà dans le code
  static const String _hardcodedApiKey = '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';

  /// Dernière erreur - VISIBLE À L'UTILISATEUR pour diagnostic
  static String _lastErrorMessage = '';
  static String get lastErrorMessage => _lastErrorMessage;

  /// Analyse une transcription vocale et extrait les informations structurées
  static Future<Map<String, dynamic>?> analyzeVoiceTranscript(
    String transcript,
  ) async {
    // Reset erreur
    _lastErrorMessage = '';

    print('🎤 [VOICE ANALYSIS] ===== DÉBUT ANALYSE =====');
    print('🎤 [VOICE ANALYSIS] Transcript reçu: "$transcript"');
    print('🎤 [VOICE ANALYSIS] Longueur: ${transcript.length} caractères');

    if (transcript.trim().isEmpty) {
      _lastErrorMessage = 'Transcript vide';
      print('❌ [VOICE ANALYSIS] ERREUR: Transcript vide');
      return null;
    }

    try {
      print('🤖 [VOICE ANALYSIS] Préparation appel OpenAI...');

      final prompt = _buildAnalysisPrompt(transcript);
      print('📝 [VOICE ANALYSIS] Prompt construit (${prompt.length} caractères)');

      print('📤 [VOICE ANALYSIS] Envoi requête à OpenAI...');
      final response = await _callOpenAI(prompt);

      if (response == null) {
        // _lastErrorMessage déjà set par _callOpenAI
        print('❌ [VOICE ANALYSIS] ERREUR: Pas de réponse OpenAI');
        return null;
      }

      print('📥 [VOICE ANALYSIS] Réponse reçue (${response.length} caractères)');

      // Parser la réponse JSON
      final parsed = _parseOpenAIResponse(response);

      if (parsed == null) {
        _lastErrorMessage = 'Impossible de parser la réponse OpenAI';
        print('❌ [VOICE ANALYSIS] ERREUR: Impossible de parser la réponse');
        return null;
      }

      print('✅ [VOICE ANALYSIS] ===== ANALYSE RÉUSSIE =====');
      print('✅ [VOICE ANALYSIS] Clés trouvées: ${parsed.keys.join(", ")}');

      return parsed;
    } catch (e, stackTrace) {
      _lastErrorMessage = 'Exception: ${e.toString().length > 100 ? e.toString().substring(0, 100) : e.toString()}';
      print('❌ [VOICE ANALYSIS] ===== EXCEPTION =====');
      print('❌ [VOICE ANALYSIS] Type: ${e.runtimeType}');
      print('❌ [VOICE ANALYSIS] Message: $e');
      print('❌ [VOICE ANALYSIS] Stack: ${stackTrace.toString().split('\n').take(5).join('\n')}');
      return null;
    }
  }

  /// Construit le prompt pour l'analyse vocale avec TAGS OFFICIELS DORÕN
  static String _buildAnalysisPrompt(String transcript) {
    return '''Tu es un assistant spécialisé dans l'analyse de descriptions de personnes pour des recommandations de cadeaux.
Tu dois extraire les informations et les convertir en TAGS OFFICIELS du système DORÕN.

TRANSCRIPTION VOCALE DE L'UTILISATEUR:
"$transcript"

TÂCHE:
Analyse cette transcription et génère les TAGS OFFICIELS au format JSON STRICT.

FORMAT DE RÉPONSE REQUIS (JSON uniquement, sans texte supplémentaire):
{
  "recipientType": "Maman | Papa | Amie | Ami | Copine | Copain | Frère | Sœur | Grand-mère | Grand-père | Collègue | Patron | Autre",
  "recipientName": "Prénom si mentionné, sinon null",
  "budget": nombre (le maximum en euros),
  "age": nombre ou null,
  "gender": "Femme | Homme | Non spécifié",
  "genderTag": "gender_femme | gender_homme",
  "categoryTags": ["cat_tendances", "cat_tech", "cat_mode", "cat_maison", "cat_beaute", "cat_food"],
  "budgetTag": "budget_0_50 | budget_50_100 | budget_100_200 | budget_200+",
  "styleTags": ["style_elegant", "style_tendance", "style_minimaliste", "style_classique", "style_decontracte", "style_sportif", "style_vintage", "style_moderne", "style_luxe"],
  "personalityTags": ["perso_creatif", "perso_actif", "perso_cool", "perso_bienveillant", "perso_ambitieux", "perso_romantique", "perso_aventurier", "perso_intellectuel", "perso_sociable", "perso_zen"],
  "passionTags": ["passion_sport", "passion_cuisine", "passion_voyages", "passion_photo", "passion_jeuxvideo", "passion_lecture", "passion_musique", "passion_mode", "passion_tech"],
  "giftTypeTags": ["type_mode_accessoires", "type_bien_etre", "type_sport_outdoor", "type_gastronomie", "type_culture", "type_high_tech"],
  "occasion": "Anniversaire | Noël | Fête des mères | Fête des pères | Mariage | Saint-Valentin | Autre | non spécifié",
  "specialNotes": "Notes additionnelles importantes"
}

RÈGLES STRICTES POUR LES TAGS:
1. **genderTag**: TOUJOURS 1 seul tag parmi gender_femme, gender_homme
   - Maman/Sœur/Copine → gender_femme
   - Papa/Frère/Copain → gender_homme
   - Si neutre/non spécifié → Choisir le plus probable (homme ou femme)

2. **budgetTag**: TOUJOURS 1 seul tag calculé selon le budget
   - < 50€ → budget_0_50
   - 50-100€ → budget_50_100
   - 100-200€ → budget_100_200
   - > 200€ → budget_200+

3. **categoryTags**: LISTE de 1 à 3 catégories principales parmi:
   - cat_tendances (viral, TikTok, nouveauté)
   - cat_tech (high-tech, gadgets)
   - cat_mode (vêtements, accessoires)
   - cat_maison (déco, intérieur)
   - cat_beaute (soins, parfums)
   - cat_food (gastronomie, cuisine)

4. **styleTags**: LISTE de tags de style (plusieurs possibles)
5. **personalityTags**: LISTE de tags de personnalité (plusieurs possibles)
6. **passionTags**: LISTE de tags de passions basés sur hobbies/interests (plusieurs possibles)
7. **giftTypeTags**: LISTE de types de cadeaux (plusieurs possibles)

RÈGLES DE DÉDUCTION:
- Si "sportif" ou "actif" → perso_actif + passion_sport
- Si "créatif" ou "artistique" → perso_creatif + passion_art
- Si "tech" ou "geek" → perso_techie + cat_tech + passion_tech
- Si "mode" ou "fashion" → cat_mode + passion_mode + style_tendance
- Si "cuisine" ou "gastronome" → cat_food + passion_cuisine + perso_gourmand

EXEMPLES:
- "Ma maman de 55 ans qui aime le jardinage, budget 80€"
  → genderTag: "gender_femme", budgetTag: "budget_50_100",
     categoryTags: ["cat_maison"], passionTags: ["passion_jardinage"],
     personalityTags: ["perso_zen", "perso_bienveillant"]

- "Mon pote de 25 ans, fan de gaming, budget 150€"
  → genderTag: "gender_homme", budgetTag: "budget_100_200",
     categoryTags: ["cat_tech", "cat_tendances"], passionTags: ["passion_jeuxvideo"],
     personalityTags: ["perso_techie", "perso_cool"]

Réponds UNIQUEMENT avec le JSON, sans texte avant ou après:''';
  }

  /// Appelle l'API OpenAI avec retry logic
  static Future<String?> _callOpenAI(String prompt) async {
    print('📤 [OPENAI] ===== DÉBUT APPEL API =====');

    try {
      print('📤 [OPENAI] URL: $_apiUrl');
      print('📤 [OPENAI] Modèle: gpt-4o');
      print('📤 [OPENAI] Clé API: ${_hardcodedApiKey.substring(0, 25)}...');

      final body = json.encode({
        'model': 'gpt-4o',
        'messages': [
          {
            'role': 'system',
            'content': 'Tu es un expert en analyse de données pour recommandations de cadeaux. Tu réponds toujours en JSON valide.',
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        'temperature': 0.3,
        'max_tokens': 1000,
      });

      print('📤 [OPENAI] Taille requête: ${body.length} bytes');
      print('📤 [OPENAI] Envoi avec timeout 45s et 3 retries...');

      final response = await HttpService.postWithRetry(
        url: Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_hardcodedApiKey',
        },
        body: body,
        timeoutSeconds: 45,
        maxRetries: 3,
      );

      print('📥 [OPENAI] Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ [OPENAI] Succès! Parsing réponse...');
        final data = json.decode(response.body);
        final content = data['choices']?[0]?['message']?['content'];
        if (content == null) {
          print('⚠️ [OPENAI] Réponse sans contenu!');
          print('⚠️ [OPENAI] Body: ${response.body.substring(0, response.body.length > 300 ? 300 : response.body.length)}');
        } else {
          print('✅ [OPENAI] Contenu extrait (${content.toString().length} chars)');
        }
        return content?.toString().trim();
      } else if (response.statusCode == 401) {
        _lastErrorMessage = 'Erreur 401: Clé API invalide ou expirée';
        print('❌ [OPENAI] ERREUR 401: Clé API invalide ou expirée');
        print('❌ [OPENAI] Body: ${response.body}');
        return null;
      } else if (response.statusCode == 429) {
        _lastErrorMessage = 'Erreur 429: Limite de requêtes dépassée';
        print('❌ [OPENAI] ERREUR 429: Rate limit dépassé');
        print('❌ [OPENAI] Body: ${response.body}');
        return null;
      } else if (response.statusCode >= 500) {
        _lastErrorMessage = 'Erreur ${response.statusCode}: Serveur OpenAI indisponible';
        print('❌ [OPENAI] ERREUR ${response.statusCode}: Serveur OpenAI indisponible');
        print('❌ [OPENAI] Body: ${response.body}');
        return null;
      } else {
        _lastErrorMessage = 'Erreur HTTP ${response.statusCode}';
        print('❌ [OPENAI] ERREUR ${response.statusCode}: Erreur inattendue');
        print('❌ [OPENAI] Body: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      _lastErrorMessage = 'Erreur réseau: ${e.runtimeType}';
      print('❌ [OPENAI] ===== EXCEPTION =====');
      print('❌ [OPENAI] Type: ${e.runtimeType}');
      print('❌ [OPENAI] Message: $e');
      print('❌ [OPENAI] Stack: ${stackTrace.toString().split('\n').take(5).join('\n')}');
      return null;
    }
  }

  /// Parse la réponse OpenAI en Map
  static Map<String, dynamic>? _parseOpenAIResponse(String response) {
    try {
      // Nettoyer la réponse (enlever markdown, etc.)
      String cleaned = response.trim();

      // Enlever les backticks markdown si présents
      if (cleaned.startsWith('```json')) {
        cleaned = cleaned.substring(7);
      } else if (cleaned.startsWith('```')) {
        cleaned = cleaned.substring(3);
      }
      if (cleaned.endsWith('```')) {
        cleaned = cleaned.substring(0, cleaned.length - 3);
      }

      cleaned = cleaned.trim();

      // Parser le JSON
      final parsed = json.decode(cleaned) as Map<String, dynamic>;

      // Validation basique
      if (!parsed.containsKey('recipientType')) {
        print('⚠️ Missing recipientType in response');
      }

      return parsed;
    } catch (e) {
      print('❌ Error parsing OpenAI response: $e');
      print('Response was: $response');
      return null;
    }
  }

  /// Convertit les données analysées en format compatible avec ProductMatchingService
  /// Extrait les TAGS OFFICIELS DORÕN et les convertit au format attendu
  static Map<String, dynamic> convertToGiftProfile(
    Map<String, dynamic> analysis,
  ) {
    print('🏷️ Voice Analysis: Converting to gift profile...');
    print('   Analysis: $analysis');

    // Extraire le genre au format attendu par ProductMatchingService
    String? gender;
    final genderTag = analysis['genderTag'] as String?;
    if (genderTag != null) {
      if (genderTag.contains('femme')) {
        gender = 'Femme';
      } else if (genderTag.contains('homme')) {
        gender = 'Homme';
      } else {
        gender = 'Non spécifié';
      }
    } else {
      gender = analysis['gender'] ?? 'Non spécifié';
    }

    // Extraire les catégories au format attendu
    final categoryTags = (analysis['categoryTags'] as List?)?.cast<String>() ?? [];
    final preferredCategories = categoryTags.map((tag) {
      if (tag.contains('tendances')) return 'Tendances';
      if (tag.contains('tech')) return 'Tech';
      if (tag.contains('mode')) return 'Mode';
      if (tag.contains('maison')) return 'Maison';
      if (tag.contains('beaute')) return 'Beauté';
      if (tag.contains('food')) return 'Food';
      return tag;
    }).toList();

    // Extraire le budget
    final budgetValue = analysis['budget'] ?? 100;

    // Extraire le style
    final styleTags = (analysis['styleTags'] as List?)?.cast<String>() ?? [];
    String? style;
    if (styleTags.isNotEmpty) {
      final firstStyle = styleTags.first;
      if (firstStyle.contains('elegant')) style = 'Élégant';
      else if (firstStyle.contains('tendance')) style = 'Tendance';
      else if (firstStyle.contains('minimaliste')) style = 'Minimaliste';
      else if (firstStyle.contains('classique')) style = 'Classique';
      else if (firstStyle.contains('decontracte')) style = 'Décontracté';
      else if (firstStyle.contains('sportif')) style = 'Sportif';
      else if (firstStyle.contains('moderne')) style = 'Moderne';
      else style = 'Moderne';
    } else {
      style = 'Moderne';
    }

    // Extraire les passions/hobbies au format attendu
    final passionTags = (analysis['passionTags'] as List?)?.cast<String>() ?? [];
    final interests = passionTags.map((tag) {
      if (tag.contains('sport')) return 'sport';
      if (tag.contains('cuisine')) return 'cuisine';
      if (tag.contains('voyages')) return 'voyages';
      if (tag.contains('photo')) return 'photo';
      if (tag.contains('jeuxvideo')) return 'jeux vidéo';
      if (tag.contains('lecture')) return 'lecture';
      if (tag.contains('musique')) return 'musique';
      if (tag.contains('mode')) return 'mode';
      if (tag.contains('tech')) return 'tech';
      if (tag.contains('art')) return 'art';
      return tag;
    }).toList();

    // Extraire la personnalité
    final personalityTags = (analysis['personalityTags'] as List?)?.cast<String>() ?? [];
    String? personality;
    if (personalityTags.isNotEmpty) {
      final firstPersonality = personalityTags.first;
      if (firstPersonality.contains('creatif')) personality = 'créatif';
      else if (firstPersonality.contains('actif')) personality = 'actif';
      else if (firstPersonality.contains('cool')) personality = 'cool';
      else if (firstPersonality.contains('bienveillant')) personality = 'bienveillant';
      else personality = personalityTags.first.replaceFirst('perso_', '');
    }

    // Format compatible avec ProductMatchingService
    final profile = {
      // Format attendu par ProductMatchingService
      'gender': gender,
      'recipientGender': gender,
      'budget': budgetValue.toString(),
      'preferredCategories': preferredCategories,
      'style': style,
      'interests': interests,
      'personality': personality,

      // Informations additionnelles
      'recipient': analysis['recipientType'] ?? 'Autre',
      'recipientAge': analysis['age']?.toString() ?? '',
      'occasion': analysis['occasion'] ?? 'non spécifié',

      // Métadonnées
      'sourceType': 'voice',
      'rawTranscript': '', // Sera rempli par l'appelant
    };

    print('✅ Voice profile converted:');
    print('   - Gender: $gender');
    print('   - Budget: $budgetValue');
    print('   - Categories: $preferredCategories');
    print('   - Style: $style');
    print('   - Interests: $interests');
    print('   - Personality: $personality');

    return profile;
  }

  /// Génère un résumé textuel de l'analyse
  static String generateSummary(Map<String, dynamic> analysis) {
    final recipient = analysis['recipientType'] ?? 'cette personne';
    final name = analysis['recipientName'];
    final age = analysis['age'];
    final budget = analysis['budget'];
    final hobbies = analysis['hobbies'] as List?;
    final occasion = analysis['occasion'];

    String summary = '';

    if (name != null && name.isNotEmpty) {
      summary += 'Pour $name';
    } else {
      summary += 'Pour $recipient';
    }

    if (age != null) {
      summary += ', $age ans';
    }

    if (occasion != null && occasion != 'non spécifié') {
      summary += '\nOccasion: $occasion';
    }

    if (budget != null && budget['max'] != null) {
      summary += '\nBudget: jusqu\'à ${budget['max']}€';
    }

    if (hobbies != null && hobbies.isNotEmpty) {
      summary += '\nCentres d\'intérêt: ${hobbies.take(3).join(', ')}';
    }

    return summary;
  }
}
