import 'dart:convert';
import 'package:doron/services/http_service.dart';
import 'package:doron/services/openai_service.dart';
import 'package:flutter/foundation.dart';

/// Service pour analyser les transcriptions vocales avec OpenAI
class OpenAIVoiceAnalysisService {
  static String get _apiKey => OpenAIService.apiKey;
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  /// Analyse une transcription vocale et extrait les informations structurées
  static Future<Map<String, dynamic>?> analyzeVoiceTranscript(
    String transcript,
  ) async {
    if (transcript.trim().isEmpty) {
      print('❌ Empty transcript');
      return null;
    }

    try {
      print('🤖 Analyzing voice transcript with OpenAI...');

      final prompt = _buildAnalysisPrompt(transcript);
      final response = await _callOpenAI(prompt);

      if (response == null) {
        print('❌ No response from OpenAI');
        return null;
      }

      // Parser la réponse JSON
      final parsed = _parseOpenAIResponse(response);
      print('✅ Voice analysis completed: $parsed');

      return parsed;
    } catch (e) {
      print('❌ Error analyzing voice transcript: $e');
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
  "genderTag": "gender_femme | gender_homme | gender_mixte",
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
1. **genderTag**: TOUJOURS 1 seul tag parmi gender_femme, gender_homme, gender_mixte
   - Maman/Sœur/Copine → gender_femme
   - Papa/Frère/Copain → gender_homme
   - Si neutre → gender_mixte

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
    try {
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
        'temperature': 0.3, // Basse température pour plus de consistance
        'max_tokens': 1000,
      });

      final response = await HttpService.postWithRetry(
        url: Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: body,
        timeoutSeconds: 45, // Plus long pour l'analyse
        maxRetries: 3,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices']?[0]?['message']?['content'];
        return content?.toString().trim();
      } else {
        print('❌ OpenAI API error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error calling OpenAI: $e');
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

  /// Convertit les données analysées en format compatible avec saveGiftProfile
  /// Extrait les TAGS OFFICIELS DORÕN du nouveau format JSON
  static Map<String, dynamic> convertToGiftProfile(
    Map<String, dynamic> analysis,
  ) {
    // Extraire tous les tags des listes
    final List<String> allTags = [];

    // Tag de genre (STRICT - 1 seul)
    if (analysis['genderTag'] != null) {
      allTags.add(analysis['genderTag'] as String);
    }

    // Tags de catégories (STRICT - peut avoir plusieurs)
    if (analysis['categoryTags'] != null) {
      allTags.addAll((analysis['categoryTags'] as List).cast<String>());
    }

    // Tag de budget (STRICT - 1 seul)
    if (analysis['budgetTag'] != null) {
      allTags.add(analysis['budgetTag'] as String);
    }

    // Tags de styles (SOUPLE - plusieurs possibles)
    if (analysis['styleTags'] != null) {
      allTags.addAll((analysis['styleTags'] as List).cast<String>());
    }

    // Tags de personnalités (SOUPLE - plusieurs possibles)
    if (analysis['personalityTags'] != null) {
      allTags.addAll((analysis['personalityTags'] as List).cast<String>());
    }

    // Tags de passions (SOUPLE - plusieurs possibles)
    if (analysis['passionTags'] != null) {
      allTags.addAll((analysis['passionTags'] as List).cast<String>());
    }

    // Tags de types de cadeaux (SOUPLE - plusieurs possibles)
    if (analysis['giftTypeTags'] != null) {
      allTags.addAll((analysis['giftTypeTags'] as List).cast<String>());
    }

    print('🏷️ Voice Analysis: Extracted ${allTags.length} tags from OpenAI');
    print('   Tags: ${allTags.join(", ")}');

    return {
      // Informations de base
      'personType': analysis['recipientType'] ?? 'Autre',
      'personName': analysis['recipientName'] ?? '',
      'budget': analysis['budget']?.toString() ?? '',
      'age': analysis['age']?.toString() ?? '',
      'gender': analysis['gender'] ?? 'Non spécifié',
      'occasion': analysis['occasion'] ?? 'non spécifié',
      'specialNotes': analysis['specialNotes'] ?? '',

      // NOUVEAU: Tags officiels DORÕN
      'officialTags': allTags,

      // Ancien format pour compatibilité (sera converti par TagsDefinitions)
      'genderTag': analysis['genderTag'],
      'categoryTags': analysis['categoryTags'],
      'budgetTag': analysis['budgetTag'],
      'styleTags': analysis['styleTags'],
      'personalityTags': analysis['personalityTags'],
      'passionTags': analysis['passionTags'],
      'giftTypeTags': analysis['giftTypeTags'],

      // Métadonnées
      'sourceType': 'voice', // Marquer que c'est venu de l'assistant vocal
      'rawTranscript': '', // Sera rempli par l'appelant
    };
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
