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

  /// Construit le prompt pour l'analyse vocale
  static String _buildAnalysisPrompt(String transcript) {
    return '''Tu es un assistant spécialisé dans l'analyse de descriptions de personnes pour des recommandations de cadeaux.

TRANSCRIPTION VOCALE DE L'UTILISATEUR:
"$transcript"

TÂCHE:
Analyse cette transcription et extrais les informations suivantes au format JSON STRICT. Si une information n'est pas mentionnée, utilise "non spécifié" ou null.

FORMAT DE RÉPONSE REQUIS (JSON uniquement, sans texte supplémentaire):
{
  "recipientType": "Maman | Papa | Amie | Ami | Copine | Copain | Frère | Sœur | Grand-mère | Grand-père | Collègue | Patron | Autre",
  "recipientName": "Prénom si mentionné, sinon null",
  "budget": {
    "min": nombre ou null,
    "max": nombre ou null,
    "currency": "EUR"
  },
  "age": nombre ou null,
  "ageRange": "0-10 | 10-20 | 20-30 | 30-40 | 40-50 | 50-60 | 60+ | non spécifié",
  "personality": "Description courte de la personnalité",
  "hobbies": ["hobby1", "hobby2", "hobby3"],
  "interests": ["intérêt1", "intérêt2"],
  "style": "Moderne | Classique | Sportif | Élégant | Décontracté | Créatif | Tech | Nature | non spécifié",
  "occasion": "Anniversaire | Noël | Fête des mères | Fête des pères | Mariage | Pendaison de crémaillère | Remerciement | Saint-Valentin | Autre | non spécifié",
  "preferredCategories": ["Électronique", "Mode", "Maison", "Sport", "Beauté", "Livres", "Jouets", "Gastronomie"],
  "avoidCategories": ["catégorie à éviter si mentionné"],
  "specialNotes": "Notes additionnelles importantes",
  "gender": "Homme | Femme | Non spécifié"
}

RÈGLES IMPORTANTES:
1. Réponds UNIQUEMENT avec le JSON, sans texte avant ou après
2. Utilise les valeurs exactes des enums ci-dessus
3. Si le budget est "environ 50€", mets min: 40, max: 60
4. Si "pas cher", mets max: 30
5. Si "luxe" ou "cher", mets min: 100
6. Déduis le gender du recipientType si possible (Maman → Femme, Papa → Homme)
7. Pour hobbies et interests, extrais maximum 5 éléments chacun
8. Pour preferredCategories, choisis parmi la liste basée sur les hobbies/interests

Réponds maintenant avec le JSON uniquement:''';
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
  static Map<String, dynamic> convertToGiftProfile(
    Map<String, dynamic> analysis,
  ) {
    return {
      'personType': analysis['recipientType'] ?? 'Autre',
      'personName': analysis['recipientName'] ?? '',
      'budget': analysis['budget']?['max']?.toString() ?? '',
      'age': analysis['age']?.toString() ?? '',
      'hobbies': (analysis['hobbies'] as List?)?.join(', ') ?? '',
      'personality': analysis['personality'] ?? '',
      'style': analysis['style'] ?? 'non spécifié',
      'occasion': analysis['occasion'] ?? 'non spécifié',
      'preferredCategories': analysis['preferredCategories'] ?? [],
      'avoidCategories': analysis['avoidCategories'] ?? [],
      'specialNotes': analysis['specialNotes'] ?? '',
      'gender': analysis['gender'] ?? 'Non spécifié',
      'interests': (analysis['interests'] as List?)?.join(', ') ?? '',
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
