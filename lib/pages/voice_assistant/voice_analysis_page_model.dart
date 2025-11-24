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
      // FIX Bug 2: Vérifier que le transcript n'est pas vide
      if (_transcript.trim().isEmpty) {
        print('❌ Transcript vide - impossible d\'analyser');
        _hasError = true;
        _errorMessage = 'Aucune description détectée. Veuillez réessayer et parler clairement.';
        _isAnalyzing = false;
        notifyListeners();
        return;
      }

      // FIX Bug 2: Vérifier que le transcript est assez long
      if (_transcript.trim().length < 10) {
        print('❌ Transcript trop court: "${_transcript}"');
        _hasError = true;
        _errorMessage = 'Description trop courte. Veuillez donner plus de détails sur la personne.';
        _isAnalyzing = false;
        notifyListeners();
        return;
      }

      print('🤖 [MODEL] Starting OpenAI analysis for transcript: "$_transcript"');

      // Timeout de 60 secondes pour laisser le temps à l'API (45s) + retries
      // L'API fait 3 retries avec backoff donc total possible = 45s + 2s + 4s + 8s = 59s
      final result = await OpenAIVoiceAnalysisService.analyzeVoiceTranscript(_transcript)
          .timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          print('⏱️ [MODEL] OpenAI analysis timeout after 60 seconds');
          return null;
        },
      );

      if (result != null) {
        print('✅ [MODEL] Analysis successful - result received!');
        print('✅ [MODEL] Keys: ${result.keys.join(", ")}');
        _analysisResult = result;
        _isAnalyzing = false;
        _hasError = false;
      } else {
        print('❌ [MODEL] Analysis returned null - check Xcode logs for details');
        _hasError = true;
        _errorMessage =
            'L\'analyse a échoué. Vérifiez votre connexion internet et réessayez.';
        _isAnalyzing = false;
      }

      notifyListeners();
    } catch (e) {
      print('❌ Analysis error: $e');
      _hasError = true;
      _errorMessage = 'Une erreur est survenue lors de l\'analyse: ${e.toString().length > 100 ? e.toString().substring(0, 100) : e.toString()}';
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
