import 'package:flutter/material.dart';
import '/services/firebase_data_service.dart';
import '/backend/backend.dart';
import '/auth/firebase_auth/auth_util.dart';

class SearchPageModel {
  int? selectedProfileId;
  Set<int> likedProducts = {};
  Set<String> likedProductTitles = {}; // Pour identifier les produits likés par titre
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

        // Charger les favoris de cette personne
        final personId = profiles[0]['id'].toString();
        await loadPersonFavorites(personId);

        // Définir le contexte actuel
        await FirebaseDataService.setCurrentPersonContext(personId);
      }

      isLoading = false;
      print('✅ Loaded ${profiles.length} profiles');
    } catch (e) {
      print('❌ Error loading profiles: $e');
      isLoading = false;
    }
  }

  /// Charge les favoris pour une personne spécifique
  Future<void> loadPersonFavorites(String personId) async {
    try {
      final favorites = await queryFavouritesRecordOnce(
        queryBuilder: (favouritesRecord) => favouritesRecord
            .where('uid', isEqualTo: currentUserReference)
            .where('personId', isEqualTo: personId),
      );

      // Extraire les titres des produits likés pour cette personne
      likedProductTitles = favorites
          .map((fav) => fav.product.productTitle)
          .toSet();

      print('✅ Loaded ${likedProductTitles.length} favorites for person $personId');
    } catch (e) {
      print('❌ Error loading person favorites: $e');
      likedProductTitles = {};
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

  Future<void> selectProfile(dynamic profileId) async {
    if (profileId is int) {
      selectedProfileId = profileId;
    } else if (profileId is String) {
      selectedProfileId = profileId.hashCode;
    }

    // Charger les favoris de la personne sélectionnée
    final profile = currentProfile;
    if (profile != null && profile.containsKey('id')) {
      final personId = profile['id'].toString();
      await loadPersonFavorites(personId);

      // Définir le contexte actuel pour que les nouveaux favoris soient liés à cette personne
      await FirebaseDataService.setCurrentPersonContext(personId);
    }
  }

  void toggleLike(int productId) {
    if (likedProducts.contains(productId)) {
      likedProducts.remove(productId);
    } else {
      likedProducts.add(productId);
    }
  }

  /// Vérifie si un produit est dans les favoris de la personne sélectionnée
  bool isProductLiked(String productTitle) {
    return likedProductTitles.contains(productTitle);
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
