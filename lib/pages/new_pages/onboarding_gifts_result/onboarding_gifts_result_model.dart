import 'package:flutter/material.dart';

/// Model pour gérer l'état de la page de résultats cadeaux post-onboarding
class OnboardingGiftsResultModel {
  List<Map<String, dynamic>> gifts = [];
  bool isLoading = false;
  Map<String, dynamic>? userProfile;
  String? errorMessage;
  String? errorDetails;

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

  void dispose() {
    // Cleanup si nécessaire
  }
}
