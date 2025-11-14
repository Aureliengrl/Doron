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

  // ============= GIFT SEARCHES (renamed from gift_profiles to match spec) =============

  /// Sauvegarde une recherche de cadeau (Maman, Papa, etc.)
  static Future<String?> saveGiftProfile(Map<String, dynamic> profile) async {
    // Sauvegarder localement TOUJOURS
    try {
      final prefs = await SharedPreferences.getInstance();
      final profilesJson = prefs.getString('local_gift_profiles') ?? '[]';
      final profiles = (json.decode(profilesJson) as List).cast<Map<String, dynamic>>();

      // Générer un ID unique pour le profil
      final profileId = DateTime.now().millisecondsSinceEpoch.toString();
      final profileWithId = {
        'id': profileId,
        ...profile,
        'createdAt': DateTime.now().toIso8601String(),
      };

      profiles.add(profileWithId);
      await prefs.setString('local_gift_profiles', json.encode(profiles));
      print('✅ Gift search saved locally: $profileId');
    } catch (e) {
      print('❌ Error saving gift search locally: $e');
    }

    // Sauvegarder sur Firebase si connecté (collection giftSearches selon spec)
    if (!isLoggedIn) return null;

    try {
      final docRef = await _firestore
          .collection('giftSearches')
          .add({
        'userId': currentUserId,
        ...profile,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ Gift search saved to Firebase: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error saving gift search to Firebase: $e');
      return null;
    }
  }

  /// Charge toutes les recherches de cadeaux
  static Future<List<Map<String, dynamic>>> loadGiftProfiles() async {
    // Essayer de charger depuis Firebase si connecté
    if (isLoggedIn) {
      try {
        final snapshot = await _firestore
            .collection('giftSearches')
            .where('userId', isEqualTo: currentUserId)
            .orderBy('createdAt', descending: true)
            .get();

        if (snapshot.docs.isNotEmpty) {
          print('✅ Loaded ${snapshot.docs.length} gift searches from Firebase');
          return snapshot.docs.map((doc) {
            return {
              'id': doc.id,
              ...doc.data(),
            };
          }).toList();
        }
      } catch (e) {
        print('❌ Error loading gift searches from Firebase: $e');
      }
    }

    // Fallback : charger depuis SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final profilesJson = prefs.getString('local_gift_profiles') ?? '[]';
      final profiles = (json.decode(profilesJson) as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();

      print('✅ Loaded ${profiles.length} gift searches from local storage');
      return profiles;
    } catch (e) {
      print('❌ Error loading gift searches from local storage: $e');
      return [];
    }
  }

  /// Met à jour une recherche de cadeau
  static Future<void> updateGiftProfile(
    String profileId,
    Map<String, dynamic> updates,
  ) async {
    if (!isLoggedIn) return;

    try {
      await _firestore
          .collection('giftSearches')
          .doc(profileId)
          .update(updates);

      print('✅ Gift search updated: $profileId');
    } catch (e) {
      print('❌ Error updating gift search: $e');
    }
  }

  // ============= CURRENT PERSON CONTEXT =============

  /// Sauvegarde l'ID de la personne actuellement visualisée (pour lier les favoris)
  static Future<void> setCurrentPersonContext(String? personId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (personId != null) {
        await prefs.setString('current_person_id', personId);
        print('✅ Current person context set: $personId');
      } else {
        await prefs.remove('current_person_id');
        print('✅ Current person context cleared');
      }
    } catch (e) {
      print('❌ Error setting current person context: $e');
    }
  }

  /// Récupère l'ID de la personne actuellement visualisée
  static Future<String?> getCurrentPersonContext() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('current_person_id');
    } catch (e) {
      print('❌ Error getting current person context: $e');
      return null;
    }
  }

  /// Supprime une recherche de cadeau
  static Future<void> deleteGiftProfile(String profileId) async {
    if (!isLoggedIn) return;

    try {
      await _firestore
          .collection('giftSearches')
          .doc(profileId)
          .delete();

      print('✅ Gift search deleted: $profileId');
    } catch (e) {
      print('❌ Error deleting gift search: $e');
    }
  }

  // ============= SUGGESTIONS (AI-generated gifts) =============

  /// Sauvegarde les suggestions générées par l'IA
  static Future<void> saveGiftSuggestions({
    required String searchId,
    required List<Map<String, dynamic>> gifts,
  }) async {
    if (!isLoggedIn) return;

    try {
      await _firestore
          .collection('suggestions')
          .doc(searchId)
          .set({
        'userId': currentUserId,
        'searchId': searchId,
        'gifts': gifts,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('✅ Gift suggestions saved for search: $searchId');
    } catch (e) {
      print('❌ Error saving suggestions: $e');
    }
  }

  /// Charge les suggestions pour une recherche
  static Future<List<Map<String, dynamic>>?> loadGiftSuggestions(
    String searchId,
  ) async {
    if (!isLoggedIn) return null;

    try {
      final doc = await _firestore
          .collection('suggestions')
          .doc(searchId)
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

  // ============= WISHLISTS =============

  /// Crée une nouvelle liste de souhaits
  static Future<String?> createWishlist({
    required String name,
    String? description,
  }) async {
    if (!isLoggedIn) return null;

    try {
      final docRef = await _firestore.collection('wishlists').add({
        'userId': currentUserId,
        'name': name,
        'description': description ?? '',
        'giftIds': [],
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ Wishlist created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error creating wishlist: $e');
      return null;
    }
  }

  /// Charge toutes les listes de souhaits
  static Future<List<Map<String, dynamic>>> loadWishlists() async {
    if (!isLoggedIn) return [];

    try {
      final snapshot = await _firestore
          .collection('wishlists')
          .where('userId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
    } catch (e) {
      print('❌ Error loading wishlists: $e');
      return [];
    }
  }

  /// Ajoute un cadeau à une liste de souhaits
  static Future<void> addToWishlist(String wishlistId, String giftId) async {
    if (!isLoggedIn) return;

    try {
      await _firestore.collection('wishlists').doc(wishlistId).update({
        'giftIds': FieldValue.arrayUnion([giftId]),
      });

      print('✅ Gift added to wishlist');
    } catch (e) {
      print('❌ Error adding to wishlist: $e');
    }
  }

  // ============= GIFTS CATALOG =============

  /// Récupère les produits du catalogue
  static Future<List<Map<String, dynamic>>> getGifts({
    int? limit,
    List<String>? categories,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      var query = _firestore.collection('gifts').where('active', isEqualTo: true);

      if (categories != null && categories.isNotEmpty) {
        query = query.where('category', whereIn: categories);
      }

      if (minPrice != null) {
        query = query.where('price', isGreaterThanOrEqualTo: minPrice);
      }

      if (maxPrice != null) {
        query = query.where('price', isLessThanOrEqualTo: maxPrice);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
    } catch (e) {
      print('❌ Error loading gifts: $e');
      return [];
    }
  }

  /// Récupère un produit spécifique
  static Future<Map<String, dynamic>?> getGift(String giftId) async {
    try {
      final doc = await _firestore.collection('gifts').doc(giftId).get();

      if (doc.exists) {
        return {'id': doc.id, ...doc.data() ?? {}};
      }
    } catch (e) {
      print('❌ Error loading gift: $e');
    }
    return null;
  }

  // ============= TRANSLATIONS =============

  /// Récupère les traductions pour une clé
  static Future<Map<String, String>?> getTranslation(String key) async {
    try {
      final doc = await _firestore.collection('translations').doc(key).get();

      if (doc.exists) {
        final data = doc.data();
        return {
          'fr': data?['fr'] ?? '',
          'en': data?['en'] ?? '',
          'es': data?['es'] ?? '',
        };
      }
    } catch (e) {
      print('❌ Error loading translation: $e');
    }
    return null;
  }

  /// Charge toutes les traductions pour une langue
  static Future<Map<String, String>> loadTranslationsForLanguage(String languageCode) async {
    try {
      final snapshot = await _firestore.collection('translations').get();

      final translations = <String, String>{};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        translations[doc.id] = data[languageCode] ?? '';
      }

      print('✅ Loaded ${translations.length} translations for $languageCode');
      return translations;
    } catch (e) {
      print('❌ Error loading translations: $e');
      return {};
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

  // ============= NEW ARCHITECTURE: USER PROFILE TAGS =============
  //
  // IMPORTANT: Distinction entre 2 types de données :
  // 1. USER PROFILE TAGS (ci-dessous) = Données de L'UTILISATEUR
  //    - Stockées dans: users/{uid}/profile/tags
  //    - Utilisées pour: Personnaliser le feed d'accueil (page Home)
  //    - Contenu: firstName, age, gender, interests, style, giftTypes
  //
  // 2. PEOPLE (voir section suivante) = Données des DESTINATAIRES DE CADEAUX
  //    - Stockées dans: users/{uid}/people/{personId}
  //    - Utilisées pour: Générer des cadeaux pour des personnes spécifiques
  //    - Contenu: name, gender, recipient, budget, recipientAge, hobbies, etc.
  //
  // Ces deux entités sont SÉPARÉES par design et ne doivent PAS être confondues.

  /// Sauvegarde les tags du profil utilisateur (Étape A onboarding)
  /// Ces tags servent uniquement pour le feed d'accueil personnalisé
  static Future<void> saveUserProfileTags(Map<String, dynamic> tags) async {
    // Sauvegarder localement
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('local_user_profile_tags', json.encode(tags));
      print('✅ User profile tags saved locally');
    } catch (e) {
      print('❌ Error saving user profile tags locally: $e');
    }

    // Sauvegarder sur Firebase si connecté
    if (!isLoggedIn) {
      print('⚠️ User not logged in, skipping Firebase save for profile tags');
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .set({
        'profile': {
          'tags': tags,
          'updatedAt': FieldValue.serverTimestamp(),
        }
      }, SetOptions(merge: true));

      print('✅ User profile tags saved to Firebase');
    } catch (e) {
      print('❌ Error saving user profile tags to Firebase: $e');
    }
  }

  /// Charge les tags du profil utilisateur
  static Future<Map<String, dynamic>?> loadUserProfileTags() async {
    // Essayer Firebase d'abord si connecté
    if (isLoggedIn) {
      try {
        final doc = await _firestore.collection('users').doc(currentUserId).get();
        if (doc.exists && doc.data()?['profile']?['tags'] != null) {
          print('✅ Loaded user profile tags from Firebase');
          return doc.data()!['profile']['tags'] as Map<String, dynamic>;
        }
      } catch (e) {
        print('❌ Error loading user profile tags from Firebase: $e');
      }
    }

    // Fallback local
    try {
      final prefs = await SharedPreferences.getInstance();
      final localData = prefs.getString('local_user_profile_tags');
      if (localData != null) {
        print('✅ Loaded user profile tags from local storage');
        return json.decode(localData) as Map<String, dynamic>;
      }
    } catch (e) {
      print('❌ Error loading user profile tags locally: $e');
    }

    return null;
  }

  // ============= NEW ARCHITECTURE: PEOPLE (GIFT RECIPIENTS) =============
  //
  // NOTE: Ces données concernent les DESTINATAIRES pour qui on cherche des cadeaux,
  // PAS l'utilisateur lui-même. Les données de l'utilisateur sont dans profile/tags.
  //
  // Architecture:
  // - Stockage: users/{uid}/people/{personId}
  // - Utilisation: Page Personnes/Search, génération de cadeaux par personne
  // - Persistance: Local (SharedPreferences) + Firebase (si connecté)

  /// Crée une nouvelle personne (Étape B onboarding ou ajout manuel)
  /// Retourne le personId généré
  static Future<String?> createPerson({
    required Map<String, dynamic> tags,
    bool isPendingFirstGen = false,
  }) async {
    final personId = DateTime.now().millisecondsSinceEpoch.toString();

    // Sauvegarder localement
    try {
      final prefs = await SharedPreferences.getInstance();
      final peopleJson = prefs.getString('local_people') ?? '[]';
      final people = (json.decode(peopleJson) as List).cast<Map<String, dynamic>>();

      people.add({
        'id': personId,
        'tags': tags,
        'meta': {
          'isPendingFirstGen': isPendingFirstGen,
          'createdAt': DateTime.now().toIso8601String(),
        },
      });

      await prefs.setString('local_people', json.encode(people));
      print('✅ Person created locally: $personId (pending=$isPendingFirstGen)');
    } catch (e) {
      print('❌ Error creating person locally: $e');
    }

    // Sauvegarder sur Firebase si connecté
    if (!isLoggedIn) return personId;

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('people')
          .doc(personId)
          .set({
        'tags': tags,
        'meta': {
          'isPendingFirstGen': isPendingFirstGen,
          'createdAt': FieldValue.serverTimestamp(),
        },
      });

      print('✅ Person created in Firebase: $personId');
      return personId;
    } catch (e) {
      print('❌ Error creating person in Firebase: $e');
      return personId; // Retourne quand même l'ID local
    }
  }

  /// Charge toutes les personnes
  static Future<List<Map<String, dynamic>>> loadPeople() async {
    // Essayer Firebase si connecté
    if (isLoggedIn) {
      try {
        final snapshot = await _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('people')
            .orderBy('meta.createdAt', descending: true)
            .get();

        if (snapshot.docs.isNotEmpty) {
          print('✅ Loaded ${snapshot.docs.length} people from Firebase');
          return snapshot.docs.map((doc) {
            return {
              'id': doc.id,
              ...doc.data(),
            };
          }).toList();
        }
      } catch (e) {
        print('❌ Error loading people from Firebase: $e');
      }
    }

    // Fallback local
    try {
      final prefs = await SharedPreferences.getInstance();
      final peopleJson = prefs.getString('local_people') ?? '[]';
      final people = (json.decode(peopleJson) as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();

      print('✅ Loaded ${people.length} people from local storage');
      return people;
    } catch (e) {
      print('❌ Error loading people locally: $e');
      return [];
    }
  }

  /// Charge la première personne avec isPendingFirstGen=true
  static Future<Map<String, dynamic>?> getFirstPendingPerson() async {
    final people = await loadPeople();
    try {
      return people.firstWhere(
        (p) => p['meta']?['isPendingFirstGen'] == true,
      );
    } catch (e) {
      return null; // Aucune personne en attente
    }
  }

  /// Met à jour le flag isPendingFirstGen d'une personne
  static Future<void> updatePersonPendingFlag(
    String personId,
    bool isPending,
  ) async {
    // Mise à jour locale
    try {
      final prefs = await SharedPreferences.getInstance();
      final peopleJson = prefs.getString('local_people') ?? '[]';
      final people = (json.decode(peopleJson) as List).cast<Map<String, dynamic>>();

      final index = people.indexWhere((p) => p['id'] == personId);
      if (index != -1) {
        people[index]['meta'] = {
          ...people[index]['meta'] ?? {},
          'isPendingFirstGen': isPending,
        };
        await prefs.setString('local_people', json.encode(people));
        print('✅ Person pending flag updated locally');
      }
    } catch (e) {
      print('❌ Error updating person pending flag locally: $e');
    }

    // Mise à jour Firebase si connecté
    if (!isLoggedIn) return;

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('people')
          .doc(personId)
          .update({
        'meta.isPendingFirstGen': isPending,
      });

      print('✅ Person pending flag updated in Firebase');
    } catch (e) {
      print('❌ Error updating person pending flag in Firebase: $e');
    }
  }

  // ============= GIFT LISTS (PER PERSON) =============

  /// Sauvegarde une liste de cadeaux pour une personne
  static Future<String?> saveGiftListForPerson({
    required String personId,
    required List<Map<String, dynamic>> gifts,
    String? listName,
  }) async {
    final listId = DateTime.now().millisecondsSinceEpoch.toString();

    // Sauvegarder localement
    try {
      final prefs = await SharedPreferences.getInstance();
      final listsJson = prefs.getString('local_gift_lists_$personId') ?? '[]';
      final lists = (json.decode(listsJson) as List).cast<Map<String, dynamic>>();

      lists.add({
        'id': listId,
        'personId': personId,
        'name': listName ?? 'Liste ${DateTime.now().day}/${DateTime.now().month}',
        'gifts': gifts,
        'createdAt': DateTime.now().toIso8601String(),
      });

      await prefs.setString('local_gift_lists_$personId', json.encode(lists));
      print('✅ Gift list saved locally for person $personId');
    } catch (e) {
      print('❌ Error saving gift list locally: $e');
    }

    // Sauvegarder sur Firebase si connecté
    if (!isLoggedIn) return listId;

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('people')
          .doc(personId)
          .collection('gift_lists')
          .doc(listId)
          .set({
        'name': listName ?? 'Liste ${DateTime.now().day}/${DateTime.now().month}',
        'gifts': gifts,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ Gift list saved to Firebase for person $personId');
      return listId;
    } catch (e) {
      print('❌ Error saving gift list to Firebase: $e');
      return listId;
    }
  }

  /// Charge toutes les listes de cadeaux pour une personne
  static Future<List<Map<String, dynamic>>> loadGiftListsForPerson(
    String personId,
  ) async {
    // Essayer Firebase si connecté
    if (isLoggedIn) {
      try {
        final snapshot = await _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('people')
            .doc(personId)
            .collection('gift_lists')
            .orderBy('createdAt', descending: true)
            .get();

        if (snapshot.docs.isNotEmpty) {
          print('✅ Loaded ${snapshot.docs.length} gift lists from Firebase');
          return snapshot.docs.map((doc) {
            return {
              'id': doc.id,
              ...doc.data(),
            };
          }).toList();
        }
      } catch (e) {
        print('❌ Error loading gift lists from Firebase: $e');
      }
    }

    // Fallback local
    try {
      final prefs = await SharedPreferences.getInstance();
      final listsJson = prefs.getString('local_gift_lists_$personId') ?? '[]';
      final lists = (json.decode(listsJson) as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();

      print('✅ Loaded ${lists.length} gift lists from local storage');
      return lists;
    } catch (e) {
      print('❌ Error loading gift lists locally: $e');
      return [];
    }
  }

  /// Charge la dernière liste de cadeaux pour une personne
  static Future<Map<String, dynamic>?> loadLatestGiftListForPerson(
    String personId,
  ) async {
    final lists = await loadGiftListsForPerson(personId);
    return lists.isEmpty ? null : lists.first;
  }

  // ============= HOME FEED =============

  /// Sauvegarde un feed d'accueil généré
  static Future<void> saveHomeFeed(List<Map<String, dynamic>> products) async {
    final feedId = DateTime.now().millisecondsSinceEpoch.toString();

    // Sauvegarder localement
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('local_home_feed_latest', json.encode({
        'id': feedId,
        'products': products,
        'createdAt': DateTime.now().toIso8601String(),
      }));
      print('✅ Home feed saved locally');
    } catch (e) {
      print('❌ Error saving home feed locally: $e');
    }

    // Sauvegarder sur Firebase si connecté
    if (!isLoggedIn) return;

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('home_feed')
          .doc(feedId)
          .set({
        'products': products,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ Home feed saved to Firebase');
    } catch (e) {
      print('❌ Error saving home feed to Firebase: $e');
    }
  }

  /// Charge le dernier feed d'accueil
  static Future<List<Map<String, dynamic>>?> loadLatestHomeFeed() async {
    // Essayer Firebase si connecté
    if (isLoggedIn) {
      try {
        final snapshot = await _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('home_feed')
            .orderBy('createdAt', descending: true)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final products = snapshot.docs.first.data()['products'] as List?;
          if (products != null) {
            print('✅ Loaded home feed from Firebase');
            return products.cast<Map<String, dynamic>>();
          }
        }
      } catch (e) {
        print('❌ Error loading home feed from Firebase: $e');
      }
    }

    // Fallback local
    try {
      final prefs = await SharedPreferences.getInstance();
      final feedJson = prefs.getString('local_home_feed_latest');
      if (feedJson != null) {
        final feedData = json.decode(feedJson) as Map<String, dynamic>;
        final products = feedData['products'] as List?;
        if (products != null) {
          print('✅ Loaded home feed from local storage');
          return products.cast<Map<String, dynamic>>();
        }
      }
    } catch (e) {
      print('❌ Error loading home feed locally: $e');
    }

    return null;
  }
}
