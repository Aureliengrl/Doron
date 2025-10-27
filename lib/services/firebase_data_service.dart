import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service pour gérer les données Firebase
class FirebaseDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Retourne l'ID de l'utilisateur connecté
  static String? get currentUserId => _auth.currentUser?.uid;

  /// Vérifie si un utilisateur est connecté
  static bool get isLoggedIn => _auth.currentUser != null;

  // ============= ONBOARDING ANSWERS =============

  /// Sauvegarde les réponses d'onboarding
  static Future<void> saveOnboardingAnswers(
    Map<String, dynamic> answers,
  ) async {
    // Sauvegarder localement TOUJOURS (que l'utilisateur soit connecté ou non)
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('local_onboarding_answers', json.encode(answers));
      print('✅ Onboarding answers saved locally');
    } catch (e) {
      print('❌ Error saving onboarding locally: $e');
    }

    // Sauvegarder sur Firebase si connecté
    if (!isLoggedIn) {
      print('⚠️ User not logged in, skipping Firebase save');
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('onboarding')
          .doc('latest')
          .set({
        'answers': answers,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('✅ Onboarding answers saved to Firebase');
    } catch (e) {
      print('❌ Error saving onboarding to Firebase: $e');
    }
  }

  /// Charge les réponses d'onboarding
  static Future<Map<String, dynamic>?> loadOnboardingAnswers() async {
    // Essayer de charger depuis Firebase d'abord si connecté
    if (isLoggedIn) {
      try {
        final doc = await _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('onboarding')
            .doc('latest')
            .get();

        if (doc.exists) {
          print('✅ Loaded onboarding from Firebase');
          return doc.data()?['answers'] as Map<String, dynamic>?;
        }
      } catch (e) {
        print('❌ Error loading onboarding from Firebase: $e');
      }
    }

    // Fallback : charger depuis SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final localData = prefs.getString('local_onboarding_answers');
      if (localData != null) {
        print('✅ Loaded onboarding from local storage');
        return json.decode(localData) as Map<String, dynamic>;
      }
    } catch (e) {
      print('❌ Error loading onboarding from local storage: $e');
    }

    print('⚠️ No onboarding data found');
    return null;
  }

  // ============= GIFT PROFILES =============

  /// Sauvegarde un profil créé (Maman, Papa, etc.)
  static Future<String?> saveGiftProfile(Map<String, dynamic> profile) async {
    if (!isLoggedIn) return null;

    try {
      final docRef = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('gift_profiles')
          .add({
        ...profile,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ Profile saved: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error saving profile: $e');
      return null;
    }
  }

  /// Charge tous les profils de cadeaux
  static Future<List<Map<String, dynamic>>> loadGiftProfiles() async {
    if (!isLoggedIn) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('gift_profiles')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    } catch (e) {
      print('❌ Error loading profiles: $e');
      return [];
    }
  }

  /// Met à jour un profil
  static Future<void> updateGiftProfile(
    String profileId,
    Map<String, dynamic> updates,
  ) async {
    if (!isLoggedIn) return;

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('gift_profiles')
          .doc(profileId)
          .update(updates);

      print('✅ Profile updated: $profileId');
    } catch (e) {
      print('❌ Error updating profile: $e');
    }
  }

  /// Supprime un profil
  static Future<void> deleteGiftProfile(String profileId) async {
    if (!isLoggedIn) return;

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('gift_profiles')
          .doc(profileId)
          .delete();

      print('✅ Profile deleted: $profileId');
    } catch (e) {
      print('❌ Error deleting profile: $e');
    }
  }

  // ============= GIFT SUGGESTIONS =============

  /// Sauvegarde les suggestions générées par l'IA
  static Future<void> saveGiftSuggestions({
    required String profileId,
    required List<Map<String, dynamic>> gifts,
  }) async {
    if (!isLoggedIn) return;

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('gift_suggestions')
          .doc(profileId)
          .set({
        'gifts': gifts,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('✅ Gift suggestions saved for profile: $profileId');
    } catch (e) {
      print('❌ Error saving suggestions: $e');
    }
  }

  /// Charge les suggestions pour un profil
  static Future<List<Map<String, dynamic>>?> loadGiftSuggestions(
    String profileId,
  ) async {
    if (!isLoggedIn) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('gift_suggestions')
          .doc(profileId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        return (data?['gifts'] as List?)?.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('❌ Error loading suggestions: $e');
    }
    return null;
  }

  // ============= FAVORITES =============

  /// Ajoute un cadeau aux favoris
  static Future<void> addToFavorites(Map<String, dynamic> gift) async {
    if (!isLoggedIn) return;

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('favorites')
          .doc(gift['id'].toString())
          .set({
        ...gift,
        'addedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Added to favorites: ${gift['name']}');
    } catch (e) {
      print('❌ Error adding to favorites: $e');
    }
  }

  /// Retire un cadeau des favoris
  static Future<void> removeFromFavorites(String giftId) async {
    if (!isLoggedIn) return;

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('favorites')
          .doc(giftId)
          .delete();

      print('✅ Removed from favorites: $giftId');
    } catch (e) {
      print('❌ Error removing from favorites: $e');
    }
  }

  /// Charge tous les favoris
  static Future<List<Map<String, dynamic>>> loadFavorites() async {
    if (!isLoggedIn) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('favorites')
          .orderBy('addedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('❌ Error loading favorites: $e');
      return [];
    }
  }

  /// Vérifie si un cadeau est dans les favoris
  static Future<bool> isFavorite(String giftId) async {
    if (!isLoggedIn) return false;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('favorites')
          .doc(giftId)
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // ============= USER PROFILE =============

  /// Met à jour le profil utilisateur
  static Future<void> updateUserProfile(Map<String, dynamic> profile) async {
    if (!isLoggedIn) return;

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .set(profile, SetOptions(merge: true));

      print('✅ User profile updated');
    } catch (e) {
      print('❌ Error updating user profile: $e');
    }
  }

  /// Charge le profil utilisateur
  static Future<Map<String, dynamic>?> loadUserProfile() async {
    if (!isLoggedIn) return null;

    try {
      final doc =
          await _firestore.collection('users').doc(currentUserId).get();

      if (doc.exists) {
        return doc.data();
      }
    } catch (e) {
      print('❌ Error loading user profile: $e');
    }
    return null;
  }
}
