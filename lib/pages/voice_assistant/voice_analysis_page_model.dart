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

      print('🤖 Starting OpenAI analysis for transcript: "$_transcript"');

      // FIX Bug 2: Ajouter un timeout de 30 secondes pour éviter l'écran gris infini
      final result = await OpenAIVoiceAnalysisService.analyzeVoiceTranscript(_transcript)
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('⏱️ OpenAI analysis timeout after 30 seconds');
          return null;
        },
      );

      if (result != null) {
        print('✅ Analysis successful');
        _analysisResult = result;
        _isAnalyzing = false;
        _hasError = false;
      } else {
        print('❌ Analysis returned null');
        _hasError = true;
        _errorMessage =
            'L\'analyse a pris trop de temps ou a échoué. Veuillez réessayer.';
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
