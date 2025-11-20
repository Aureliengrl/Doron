import 'package:flutter/material.dart';

/// Model pour gérer l'état de la page de résultats cadeaux post-onboarding
class OnboardingGiftsResultModel {
  List<Map<String, dynamic>> gifts = [];
  bool isLoading = false;
  Map<String, dynamic>? userProfile;
  String? errorMessage;
  String? errorDetails;
  String? personId; // ID de la personne pour laquelle on génère les cadeaux
  Map<String, dynamic>? personTags; // Tags de la personne (recipient, budget, etc.)
  Map<String, dynamic>? voiceProfile; // 🎤 Profil généré par l'assistant vocal

  void setGifts(List<Map<String, dynamic>> newGifts) {
    gifts = newGifts;
  }

  void setLoading(bool loading) {
    isLoading = loading;
  }

  void setUserProfile(Map<String, dynamic>? profile) {
    userProfile = profile;
  }

  void setError(String? message, String? details) {
    errorMessage = message;
    errorDetails = details;
  }

  void clearError() {
    errorMessage = null;
    errorDetails = null;
  }

  void setPersonId(String? id) {
    personId = id;
  }

  void setPersonTags(Map<String, dynamic>? tags) {
    personTags = tags;
  }

  /// 🎤 Défini le profil vocal (assistant vocal)
  void setVoiceProfile(Map<String, dynamic>? profile) {
    voiceProfile = profile;
    print('🎤 Profil vocal défini dans model: ${profile?.keys.join(", ")}');
  }

  void dispose() {
    // Cleanup si nécessaire
  }
}
