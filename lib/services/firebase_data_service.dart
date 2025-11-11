import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service pour gérer les données Firebase (onboarding, profil utilisateur)
class FirebaseDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sauvegarde les réponses d'onboarding dans Firestore ET SharedPreferences
  static Future<void> saveOnboardingAnswers(
      Map<String, dynamic> answers) async {
    try {
      final user = _auth.currentUser;

      // Sauvegarder localement d'abord (pour accès offline)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('onboarding_answers', json.encode(answers));

      // Si utilisateur connecté, sauvegarder dans Firestore
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set(
          {
            'onboarding': answers,
            'onboardingCompletedAt': FieldValue.serverTimestamp(),
            'lastUpdated': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true), // Merge pour ne pas écraser d'autres données
        );
        print('✅ Onboarding sauvegardé dans Firestore pour ${user.uid}');
      } else {
        print('ℹ️ Onboarding sauvegardé localement (utilisateur non connecté)');
      }
    } catch (e) {
      print('❌ Erreur lors de la sauvegarde de l\'onboarding: $e');
      rethrow;
    }
  }

  /// Charge les réponses d'onboarding depuis Firestore ou SharedPreferences
  static Future<Map<String, dynamic>?> loadOnboardingAnswers() async {
    try {
      final user = _auth.currentUser;

      // Essayer de charger depuis Firestore si connecté
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();

        if (doc.exists && doc.data()?['onboarding'] != null) {
          final onboarding = doc.data()!['onboarding'] as Map<String, dynamic>;
          print('✅ Onboarding chargé depuis Firestore pour ${user.uid}');
          return onboarding;
        }
      }

      // Fallback : charger depuis SharedPreferences (stockage local)
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('onboarding_answers');

      if (stored != null) {
        print('✅ Onboarding chargé depuis SharedPreferences');
        return json.decode(stored) as Map<String, dynamic>;
      }

      print('ℹ️ Aucun onboarding trouvé');
      return null;
    } catch (e) {
      print('❌ Erreur lors du chargement de l\'onboarding: $e');
      return null;
    }
  }

  /// Efface les données d'onboarding (pour réinitialiser)
  static Future<void> clearOnboardingAnswers() async {
    try {
      final user = _auth.currentUser;

      // Effacer localement
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('onboarding_answers');

      // Si connecté, effacer de Firestore
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'onboarding': FieldValue.delete(),
        });
        print('✅ Onboarding effacé pour ${user.uid}');
      }
    } catch (e) {
      print('❌ Erreur lors de l\'effacement de l\'onboarding: $e');
    }
  }

  /// Sauvegarde le profil utilisateur complet
  static Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      await _firestore.collection('users').doc(user.uid).set(
        {
          'profile': profile,
          'lastUpdated': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      print('✅ Profil sauvegardé pour ${user.uid}');
    } catch (e) {
      print('❌ Erreur lors de la sauvegarde du profil: $e');
      rethrow;
    }
  }

  /// Charge le profil utilisateur complet
  static Future<Map<String, dynamic>?> loadUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists && doc.data()?['profile'] != null) {
        return doc.data()!['profile'] as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      print('❌ Erreur lors du chargement du profil: $e');
      return null;
    }
  }

  /// Vérifie si l'utilisateur a complété l'onboarding
  static Future<bool> hasCompletedOnboarding() async {
    final answers = await loadOnboardingAnswers();
    return answers != null && answers.isNotEmpty;
  }
}
