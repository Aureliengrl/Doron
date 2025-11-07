import 'package:flutter/material.dart';
import 'package:doron/services/openai_voice_analysis_service.dart';
import 'package:doron/services/openai_service.dart';
import 'package:doron/services/firebase_data_service.dart';

/// Model pour la page de résultats vocaux
class VoiceResultsPageModel extends ChangeNotifier {
  Map<String, dynamic>? _analysis;
  String _transcript = '';
  List<Map<String, dynamic>> _products = [];
  bool _isGeneratingProducts = true;
  bool _hasError = false;
  String _errorMessage = '';
  String? _savedProfileId;

  List<Map<String, dynamic>> get products => _products;
  bool get isGeneratingProducts => _isGeneratingProducts;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  Map<String, dynamic>? get analysis => _analysis;
  String get summary => _generateSummary();

  /// Initialise et génère les produits
  Future<void> initialize({
    required Map<String, dynamic> analysis,
    required String transcript,
  }) async {
    _analysis = analysis;
    _transcript = transcript;

    print('🎁 Initializing voice results with analysis: $analysis');

    // Générer les produits
    await generateProducts();
  }

  /// Génère les produits basés sur l'analyse
  Future<void> generateProducts() async {
    _isGeneratingProducts = true;
    _hasError = false;
    notifyListeners();

    try {
      print('🎁 Generating products with OpenAI...');

      // Convertir l'analyse vocale en format onboardingAnswers
      final onboardingAnswers = _convertToOnboardingFormat();

      // Appeler OpenAI pour générer des produits
      final result = await OpenAIService.generateGiftSuggestions(
        onboardingAnswers: onboardingAnswers,
        count: 12, // Générer 12 produits
      );

      if (result.isNotEmpty) {
        print('✅ Generated ${result.length} products');
        _products = result;
        _isGeneratingProducts = false;
        _hasError = false;
      } else {
        print('❌ No products generated');
        _hasError = true;
        _errorMessage = 'Impossible de générer des suggestions. Veuillez réessayer.';
        _isGeneratingProducts = false;
      }

      notifyListeners();
    } catch (e) {
      print('❌ Error generating products: $e');
      _hasError = true;
      _errorMessage = 'Une erreur est survenue lors de la génération des cadeaux.';
      _isGeneratingProducts = false;
      notifyListeners();
    }
  }

  /// Convertit l'analyse vocale en format compatible avec generateGiftSuggestions
  Map<String, dynamic> _convertToOnboardingFormat() {
    if (_analysis == null) return {};

    final budget = (_analysis!['budget']?['max'] ?? 50).toDouble();
    final hobbies = _analysis!['hobbies'] as List? ?? [];
    final interests = _analysis!['interests'] as List? ?? [];
    final personality = _analysis!['personality'] ?? '';

    return {
      // Informations sur le destinataire
      'recipient': _analysis!['recipientType'] ?? 'une personne',
      'budget': budget,
      'recipientAge': _analysis!['age']?.toString() ?? _analysis!['ageRange'] ?? 'adulte',
      'recipientHobbies': hobbies,
      'recipientPersonality': personality.isNotEmpty ? [personality] : [],
      'occasion': _analysis!['occasion'] ?? 'sans occasion',
      'recipientStyle': _analysis!['style'] ?? '',
      'recipientLifeSituation': '',
      'recipientAlreadyHas': _analysis!['avoidCategories'] ?? [],
      'recipientRelationDuration': '',

      // Informations sur l'utilisateur (valeurs par défaut car non capturées par vocal)
      'age': '',
      'gender': _analysis!['gender'] ?? '',
      'interests': interests,
      'style': '',
      'giftTypes': [],

      // Catégories préférées
      'preferredCategories': _analysis!['preferredCategories'] ?? [],
    };
  }

  /// Génère un résumé de l'analyse
  String _generateSummary() {
    if (_analysis == null) return '';
    return OpenAIVoiceAnalysisService.generateSummary(_analysis!);
  }

  /// Sauvegarde le profil dans Firebase
  Future<void> saveProfile() async {
    if (_analysis == null) return;

    try {
      print('💾 Saving voice profile to Firebase...');

      // Convertir l'analyse en profil de cadeau
      final profile = OpenAIVoiceAnalysisService.convertToGiftProfile(_analysis!);
      profile['rawTranscript'] = _transcript;

      // Sauvegarder dans Firebase
      final profileId = await FirebaseDataService.saveGiftProfile(profile);

      if (profileId != null) {
        _savedProfileId = profileId;
        print('✅ Profile saved with ID: $profileId');
      }
    } catch (e) {
      print('❌ Error saving profile: $e');
    }
  }

  /// Réessayer la génération de produits
  Future<void> retry() async {
    await generateProducts();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
