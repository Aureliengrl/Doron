import 'package:flutter/material.dart';
import '/services/firebase_data_service.dart';

class SearchPageModel {
  int? selectedProfileId;
  Set<int> likedProducts = {};
  bool isLoading = true;

  List<Map<String, dynamic>> profiles = [];

  /// Charge les profils depuis Firebase/Local Storage
  Future<void> loadProfiles() async {
    try {
      isLoading = true;
      profiles = await FirebaseDataService.loadGiftProfiles();

      // Sélectionner le premier profil par défaut s'il y en a
      if (profiles.isNotEmpty && selectedProfileId == null) {
        // Utiliser l'ID du premier profil (qui peut être un String ou un int)
        final firstId = profiles[0]['id'];
        if (firstId is int) {
          selectedProfileId = firstId;
        } else if (firstId is String) {
          // Convertir l'ID string en hash int pour la compatibilité
          selectedProfileId = firstId.hashCode;
        }
      }

      isLoading = false;
      print('✅ Loaded ${profiles.length} profiles');
    } catch (e) {
      print('❌ Error loading profiles: $e');
      isLoading = false;
    }
  }

  Map<String, dynamic>? get currentProfile {
    if (selectedProfileId == null) return null;

    try {
      return profiles.firstWhere((p) {
        final pId = p['id'];
        if (pId is int) {
          return pId == selectedProfileId;
        } else if (pId is String) {
          return pId.hashCode == selectedProfileId;
        }
        return false;
      });
    } catch (e) {
      return null;
    }
  }

  List<Map<String, dynamic>> getFilteredProducts() {
    if (selectedProfileId == null) return [];

    // Récupérer les cadeaux sauvegardés pour le profil sélectionné
    final currentProf = currentProfile;
    if (currentProf != null && currentProf.containsKey('gifts')) {
      final gifts = currentProf['gifts'] as List?;
      if (gifts != null && gifts.isNotEmpty) {
        return gifts.cast<Map<String, dynamic>>();
      }
    }

    // Si pas de cadeaux, retourner une liste vide (pas de données de test)
    return [];
  }

  void selectProfile(dynamic profileId) {
    if (profileId is int) {
      selectedProfileId = profileId;
    } else if (profileId is String) {
      selectedProfileId = profileId.hashCode;
    }
  }

  void toggleLike(int productId) {
    if (likedProducts.contains(productId)) {
      likedProducts.remove(productId);
    } else {
      likedProducts.add(productId);
    }
  }

  void handleAddNewPerson(BuildContext context) {
    print('🎯 Redirection vers l\'onboarding "Pour qui veux-tu faire un cadeau ?"');
    // Navigation vers l'onboarding avec skip des questions utilisateur
    // Will be implemented in the widget
  }

  void dispose() {
    // Cleanup if needed
  }
}
