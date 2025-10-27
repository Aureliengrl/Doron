import 'package:flutter/material.dart';
import '/services/firebase_data_service.dart';

class SearchPageModel {
  int? selectedProfileId;
  Set<int> likedProducts = {};
  bool isLoading = true;

  List<Map<String, dynamic>> profiles = [];

  final List<Map<String, dynamic>> searchResults = [
    {
      'id': 1,
      'name': 'Coffret Spa Luxe',
      'description': 'Pour se détendre après une longue journée',
      'price': 89,
      'image':
          'https://images.unsplash.com/photo-1596755389378-c31d21fd1273?w=600&q=80',
      'profileId': 1,
      'source': 'Sephora',
      'url': 'https://www.sephora.fr',
    },
    {
      'id': 2,
      'name': 'Livre de Recettes',
      'description': 'Pour des moments en famille',
      'price': 35,
      'image':
          'https://images.unsplash.com/photo-1543362906-acfc16c67564?w=600&q=80',
      'profileId': 1,
      'source': 'Fnac',
      'url': 'https://www.fnac.com',
    },
    {
      'id': 3,
      'name': 'Bougie Parfumée Premium',
      'description': 'Ambiance cosy garantie',
      'price': 42,
      'image':
          'https://images.unsplash.com/photo-1602874801006-e0c97c1c6122?w=600&q=80',
      'profileId': 1,
      'source': 'Zara',
      'url': 'https://www.zara.com/fr/fr/home',
    },
    {
      'id': 4,
      'name': 'Carnet de Voyage',
      'description': 'Immortaliser ses souvenirs',
      'price': 45,
      'image':
          'https://images.unsplash.com/photo-1531346878377-a5be20888e57?w=600&q=80',
      'profileId': 1,
      'source': 'Amazon',
      'url': 'https://www.amazon.fr',
    },
  ];

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

    // Si le profil a des cadeaux sauvegardés, les utiliser
    final currentProf = currentProfile;
    if (currentProf != null && currentProf.containsKey('gifts')) {
      final gifts = currentProf['gifts'] as List?;
      if (gifts != null && gifts.isNotEmpty) {
        return gifts.cast<Map<String, dynamic>>();
      }
    }

    // Sinon, utiliser les résultats de recherche par défaut
    return searchResults
        .where((p) => p['profileId'] == selectedProfileId)
        .toList();
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
