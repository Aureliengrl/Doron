import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/foundation.dart';

/// Service pour gérer la reconnaissance vocale
class VoiceAssistantService {
  static final VoiceAssistantService _instance = VoiceAssistantService._internal();
  factory VoiceAssistantService() => _instance;
  VoiceAssistantService._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;
  String _lastTranscript = '';

  /// Callbacks
  Function(String)? onTranscriptUpdate;
  Function(String)? onFinalTranscript;
  Function(String)? onError;

  bool get isListening => _isListening;
  String get lastTranscript => _lastTranscript;

  /// Initialise le service de reconnaissance vocale
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = await _speech.initialize(
        onStatus: (status) {
          print('🎤 Speech status: $status');
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
          }
        },
        onError: (error) {
          print('❌ Speech error: $error');
          _isListening = false;
          onError?.call(error.errorMsg);
        },
      );

      if (_isInitialized) {
        print('✅ Speech recognition initialized');
      } else {
        print('❌ Speech recognition not available');
      }

      return _isInitialized;
    } catch (e) {
      print('❌ Error initializing speech: $e');
      return false;
    }
  }

  /// Commence l'écoute
  Future<void> startListening() async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        onError?.call('Impossible d\'initialiser le microphone');
        return;
      }
    }

    if (_isListening) {
      print('⚠️ Already listening');
      return;
    }

    try {
      _lastTranscript = '';
      _isListening = true;

      await _speech.listen(
        onResult: (result) {
          _lastTranscript = result.recognizedWords;
          print('📝 Transcript: $_lastTranscript');

          // Callback temps réel
          onTranscriptUpdate?.call(_lastTranscript);

          // Si final
          if (result.finalResult) {
            print('✅ Final transcript: $_lastTranscript');
            onFinalTranscript?.call(_lastTranscript);
            _isListening = false;
          }
        },
        listenFor: const Duration(seconds: 60), // Max 60 secondes
        pauseFor: const Duration(seconds: 3), // Pause de 3s = fin
        partialResults: true,
        localeId: 'fr_FR', // Français
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      );

      print('🎤 Started listening...');
    } catch (e) {
      print('❌ Error starting listening: $e');
      _isListening = false;
      onError?.call('Erreur lors de l\'écoute');
    }
  }

  /// Arrête l'écoute
  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      await _speech.stop();
      _isListening = false;
      print('🛑 Stopped listening');

      // Callback final avec dernier transcript
      if (_lastTranscript.isNotEmpty) {
        onFinalTranscript?.call(_lastTranscript);
      }
    } catch (e) {
      print('❌ Error stopping listening: $e');
    }
  }

  /// Annule l'écoute
  Future<void> cancel() async {
    if (!_isListening) return;

    try {
      await _speech.cancel();
      _isListening = false;
      _lastTranscript = '';
      print('❌ Cancelled listening');
    } catch (e) {
      print('❌ Error cancelling listening: $e');
    }
  }

  /// Reset le service
  void reset() {
    _lastTranscript = '';
    onTranscriptUpdate = null;
    onFinalTranscript = null;
    onError = null;
  }

  /// Dispose le service
  void dispose() {
    if (_isListening) {
      _speech.stop();
    }
    reset();
  }
}
