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
    print('🤖 [MODEL] ===== DÉBUT ANALYSE TRANSCRIPT =====');
    print('🤖 [MODEL] Transcript: "$_transcript"');

    _isAnalyzing = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      // Vérification 1: Transcript vide
      if (_transcript.trim().isEmpty) {
        print('❌ [MODEL] ERREUR: Transcript vide');
        _hasError = true;
        _errorMessage = 'Aucune description détectée. Veuillez réessayer et parler clairement.';
        _isAnalyzing = false;
        notifyListeners();
        return;
      }

      // Vérification 2: Transcript trop court
      if (_transcript.trim().length < 10) {
        print('❌ [MODEL] ERREUR: Transcript trop court (${_transcript.trim().length} chars)');
        _hasError = true;
        _errorMessage = 'Description trop courte. Veuillez donner plus de détails sur la personne.';
        _isAnalyzing = false;
        notifyListeners();
        return;
      }

      print('🤖 [MODEL] Validations OK, lancement analyse OpenAI...');

      // Appel OpenAI avec timeout de 60 secondes
      final result = await OpenAIVoiceAnalysisService.analyzeVoiceTranscript(_transcript)
          .timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          print('⏱️ [MODEL] TIMEOUT après 60 secondes');
          return null;
        },
      );

      print('🤖 [MODEL] Résultat reçu: ${result != null ? "SUCCÈS" : "NULL"}');

      if (result != null) {
        print('✅ [MODEL] ===== ANALYSE RÉUSSIE =====');
        print('✅ [MODEL] Clés: ${result.keys.join(", ")}');
        _analysisResult = result;
        _isAnalyzing = false;
        _hasError = false;
      } else {
        print('❌ [MODEL] ===== ANALYSE ÉCHOUÉE =====');
        _hasError = true;
        // Récupérer la dernière erreur du service pour l'afficher à l'utilisateur
        final lastError = OpenAIVoiceAnalysisService.lastErrorMessage;
        _errorMessage = lastError.isNotEmpty
            ? 'Erreur: $lastError'
            : 'L\'analyse a échoué. Vérifiez votre connexion internet.';
        _isAnalyzing = false;
      }

      notifyListeners();
    } catch (e, stack) {
      print('❌ [MODEL] ===== EXCEPTION =====');
      print('❌ [MODEL] Type: ${e.runtimeType}');
      print('❌ [MODEL] Message: $e');
      print('❌ [MODEL] Stack: ${stack.toString().split('\n').take(3).join('\n')}');
      _hasError = true;
      _errorMessage = 'Erreur: ${e.toString().length > 80 ? e.toString().substring(0, 80) : e.toString()}';
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
