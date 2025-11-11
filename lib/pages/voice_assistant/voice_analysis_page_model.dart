import 'package:flutter/material.dart';
import 'package:doron/services/openai_voice_analysis_service.dart';

/// Model pour la page d'analyse vocale
class VoiceAnalysisPageModel extends ChangeNotifier {
  String _transcript = '';
  bool _isAnalyzing = true;
  bool _hasError = false;
  String _errorMessage = '';
  Map<String, dynamic>? _analysisResult;

  bool get isAnalyzing => _isAnalyzing;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  Map<String, dynamic>? get analysisResult => _analysisResult;

  /// Initialise et lance l'analyse
  Future<void> initialize(String transcript) async {
    _transcript = transcript;
    print('🤖 Initializing voice analysis with transcript: $transcript');

    // Lancer l'analyse
    await analyzeTranscript();
  }

  /// Analyse le transcript avec OpenAI
  Future<void> analyzeTranscript() async {
    _isAnalyzing = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      print('🤖 Starting OpenAI analysis...');

      // Appeler OpenAI pour analyser
      final result =
          await OpenAIVoiceAnalysisService.analyzeVoiceTranscript(_transcript);

      if (result != null) {
        print('✅ Analysis successful');
        _analysisResult = result;
        _isAnalyzing = false;
        _hasError = false;
      } else {
        print('❌ Analysis returned null');
        _hasError = true;
        _errorMessage =
            'Impossible d\'analyser votre description. Veuillez réessayer.';
        _isAnalyzing = false;
      }

      notifyListeners();
    } catch (e) {
      print('❌ Analysis error: $e');
      _hasError = true;
      _errorMessage = 'Une erreur est survenue lors de l\'analyse.';
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  /// Réessayer l'analyse
  Future<void> retry() async {
    await analyzeTranscript();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
