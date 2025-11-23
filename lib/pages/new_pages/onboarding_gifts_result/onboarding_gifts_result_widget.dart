import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/product_matching_service.dart';
import '/services/firebase_data_service.dart';
import '/services/product_url_service.dart';
import 'onboarding_gifts_result_model.dart';
export 'onboarding_gifts_result_model.dart';

class OnboardingGiftsResultWidget extends StatefulWidget {
  const OnboardingGiftsResultWidget({super.key});

  static String routeName = 'OnboardingGiftsResult';
  static String routePath = '/onboarding-gifts-result';

  @override
  State<OnboardingGiftsResultWidget> createState() =>
      _OnboardingGiftsResultWidgetState();
}

class _OnboardingGiftsResultWidgetState
    extends State<OnboardingGiftsResultWidget> {
  late OnboardingGiftsResultModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final Color violetColor = const Color(0xFF8A2BE2);

  @override
  void initState() {
    super.initState();
    _model = OnboardingGiftsResultModel();

    // Parse le personId depuis les query parameters (sera fait dans didChangeDependencies)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _parseQueryParameters();
      }
    });
  }

  String? _returnTo; // Page de retour (ex: /search-page)

  /// Parse les paramètres de query de l'URL et les données extra
  void _parseQueryParameters() {
    final goRouterState = GoRouterState.of(context);
    final personId = goRouterState.uri.queryParameters['personId'];
    _returnTo = goRouterState.uri.queryParameters['returnTo'];

    // 🎤 NOUVEAU: Récupérer les données passées via extra (assistant vocal)
    final extraData = goRouterState.extra;
    print('🎯 Extra data détecté: ${extraData != null ? "OUI" : "NON"}');

    if (extraData != null && extraData is Map<String, dynamic>) {
      print('✅ Profil vocal reçu via extra: ${extraData.keys.join(", ")}');
      _model.setVoiceProfile(extraData);
    }

    if (personId != null) {
      _model.setPersonId(personId);
      print('✅ PersonId détecté: $personId');
    }

    if (_returnTo != null) {
      print('✅ ReturnTo détecté: $_returnTo');
    }

    _loadGifts();
  }

  /// Charge les cadeaux personnalisés basés sur l'onboarding
  Future<void> _loadGifts({bool forceRefresh = false}) async {
    if (mounted) {
      setState(() {
        _model.setLoading(true);
        _model.clearError();
      });
    }

    try {
      Map<String, dynamic>? profileForGeneration;

      // 🎤 PRIORITÉ 1: Si profil vocal existe (assistant vocal), l'utiliser
      if (_model.voiceProfile != null) {
        print('🎤 Utilisation du profil vocal pour génération');
        profileForGeneration = _model.voiceProfile;
        print('✅ Profil vocal: ${profileForGeneration!.keys.join(", ")}');
      }
      // 🎯 PRIORITÉ 2: Si un personId est spécifié, charger les tags de la personne
      else if (_model.personId != null) {
        print('🔍 Chargement des données pour personne: ${_model.personId}');
        final people = await FirebaseDataService.loadPeople();
        final person = people.firstWhere(
          (p) => p['id'] == _model.personId,
          orElse: () => {},
        );

        if (person.isEmpty) {
          // Afficher erreur à l'utilisateur au lieu de crasher
          if (mounted) {
            // IMPORTANT: Montrer SnackBar AVANT de pop pour éviter context invalide
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Personne non trouvée. Veuillez réessayer.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              ),
            );
            // Attendre un petit délai puis naviguer
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) context.pop();
            });
          }
          return;
        }

        final personTags = person['tags'] as Map<String, dynamic>?;
        if (personTags == null) {
          // Afficher erreur à l'utilisateur au lieu de crasher
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profil incomplet. Veuillez compléter l\'onboarding.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              ),
            );
            // Attendre puis naviguer
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) context.pop();
            });
          }
          return;
        }

        _model.setPersonTags(personTags);
        profileForGeneration = personTags;
        print('✅ Tags de personne chargés: ${personTags.keys.join(", ")}');
      }
      // 📝 PRIORITÉ 3: Ancienne méthode (compatibilité): charger depuis Firebase
      else {
        print('🔍 Chargement du profil onboarding (mode compatibilité)');
        final userProfile = await FirebaseDataService.loadOnboardingAnswers();
        _model.setUserProfile(userProfile);
        profileForGeneration = userProfile;
      }

      // ✅ VÉRIFICATION: S'assurer qu'on a un profil valide
      if (profileForGeneration == null || profileForGeneration.isEmpty) {
        print('⚠️ Aucun profil trouvé pour la génération - utilisation du mode découverte');
        // Utiliser un profil vide mais continuer la génération en mode découverte
        profileForGeneration = {};
      }

      // Charger les IDs des produits déjà vus pour refresh intelligent
      final prefs = await SharedPreferences.getInstance();
      final seenProductIds = prefs.getStringList('seen_gift_product_ids')
          ?.map((s) => int.tryParse(s) ?? 0).toList() ?? [];

      // 🎯 Générer les cadeaux via ProductMatchingService (NOUVELLE MÉTHODE)
      // Firebase-first, déduplication, diversité des marques, scoring sexe+âge
      final rawGifts = await ProductMatchingService.getPersonalizedProducts(
        userTags: profileForGeneration ?? {},
        count: 50,
        excludeProductIds: forceRefresh ? seenProductIds : null,
        filteringMode: "person", // Mode PERSON: Modéré pour cadeaux innovants
      );

      // Convertir les produits au format attendu et ajouter les URLs intelligentes
      // FIX Bug 5: Améliorer le mapping d'image et filtrer les produits sans image
      final gifts = rawGifts.map((product) {
        // FIX: Récupérer l'image depuis plusieurs clés possibles
        String imageUrl = '';
        for (final key in ['image', 'imageUrl', 'photo', 'productPhoto', 'product_photo', 'img', 'thumbnail']) {
          if (product[key] != null && product[key].toString().isNotEmpty) {
            imageUrl = product[key].toString();
            break;
          }
        }

        return {
          'id': product['id'],
          'name': product['name'] ?? 'Produit',
          'brand': product['brand'] ?? 'Amazon',
          'price': product['price'] ?? 0,
          'image': imageUrl, // FIX: Utiliser imageUrl trouvé (pas de placeholder qui ne marche pas)
          'url': ProductUrlService.generateProductUrl(product),
          'categories': product['categories'] ?? [],
          'match': ((product['_matchScore'] ?? 0.0) as double).toInt().clamp(0, 100),
        };
      })
      // FIX Bug 5: Filtrer les produits sans image valide
      .where((product) {
        final hasImage = product['image'] != null &&
                         product['image'].toString().isNotEmpty &&
                         product['image'].toString().startsWith('http');
        if (!hasImage) {
          print('⚠️ Produit "${product['name']}" filtré: pas d\'image valide');
        }
        return hasImage;
      })
      .toList();

      // Mettre à jour le cache des produits vus
      if (forceRefresh) {
        final newSeenIds = seenProductIds.map((id) => id.toString()).toList();
        for (var gift in gifts) {
          final id = gift['id'];
          if (id != null) {
            final idStr = id.toString();
            if (!newSeenIds.contains(idStr)) {
              newSeenIds.add(idStr);
            }
          }
        }
        // Limiter à 500 derniers produits vus
        if (newSeenIds.length > 500) {
          newSeenIds.removeRange(0, newSeenIds.length - 500);
        }
        await prefs.setStringList('seen_gift_product_ids', newSeenIds);
      }

      print('✅ ${gifts.length} cadeaux générés localement (Firebase + scoring intelligent)');

      if (mounted) {
        setState(() {
          _model.setGifts(gifts);
          _model.setLoading(false);
          _model.clearError();
        });
      }

      // 🎯 AUTO-SAUVEGARDE: Si c'est la première génération après onboarding (isPendingFirstGen=true),
      // sauvegarder automatiquement la liste SANS attendre que l'utilisateur clique "Enregistrer"
      if (_model.personId != null && gifts.isNotEmpty) {
        try {
          // Vérifier si la personne a le flag isPendingFirstGen
          final people = await FirebaseDataService.loadPeople();
          final person = people.firstWhere(
            (p) => p['id'] == _model.personId,
            orElse: () => {},
          );

          final isPendingFirstGen = person['meta']?['isPendingFirstGen'] == true;

          if (isPendingFirstGen && !forceRefresh) {
            print('💾 Auto-sauvegarde: première génération détectée (isPendingFirstGen=true)');

            // Sauvegarder la liste automatiquement
            final listName = 'Liste ${DateTime.now().day}/${DateTime.now().month}';
            final listId = await FirebaseDataService.saveGiftListForPerson(
              personId: _model.personId!,
              gifts: gifts,
              listName: listName,
            );
            print('✅ ${gifts.length} cadeaux auto-sauvegardés (liste: $listId)');

            // Retirer le flag isPendingFirstGen
            await FirebaseDataService.updatePersonPendingFlag(_model.personId!, false);
            print('✅ Flag isPendingFirstGen retiré (auto-save)');

            // Définir le contexte pour que les futurs favoris soient liés à cette personne
            await FirebaseDataService.setCurrentPersonContext(_model.personId!);
            print('✅ Contexte de personne défini: ${_model.personId} (auto-save)');
          } else if (!isPendingFirstGen) {
            print('ℹ️ isPendingFirstGen=false, pas d\'auto-sauvegarde');
          } else if (forceRefresh) {
            print('ℹ️ forceRefresh=true, pas d\'auto-sauvegarde');
          }
        } catch (e) {
          print('⚠️ Erreur lors de l\'auto-sauvegarde (non-bloquant): $e');
          print('Stack trace: ${StackTrace.current}');
          // Ne pas bloquer l'affichage si l'auto-save échoue
        }
      } else {
        if (_model.personId == null) print('⚠️ personId null, pas d\'auto-sauvegarde');
        if (gifts.isEmpty) print('⚠️ gifts vide, pas d\'auto-sauvegarde');
      }
    } catch (e) {
      print('❌ Erreur chargement cadeaux: $e');

      // Parser l'erreur pour extraire des détails utiles
      String errorMessage = 'Erreur de génération des cadeaux';
      String errorDetails = e.toString();

      // Analyser le type d'erreur
      if (errorDetails.contains('SocketException') || errorDetails.contains('Network')) {
        errorMessage = '📡 Pas de connexion internet';
        errorDetails = 'Vérifie ta connexion internet et réessaye.';
      } else if (errorDetails.contains('firebase')) {
        errorMessage = '🔥 Erreur Firebase';
        errorDetails = 'Impossible de charger les produits depuis la base de données. Réessaye plus tard.';
      } else {
        errorMessage = '⚠️ Erreur de chargement';
        errorDetails = 'Une erreur est survenue lors du chargement des produits. Réessaye.';
      }

      if (mounted) {
        setState(() {
          _model.setLoading(false);
          _model.setError(errorMessage, errorDetails);
        });
      }
    }
  }

  /// Ouvre l'URL d'un produit
  Future<void> _openProductUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('❌ Erreur ouverture URL: $e');
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFFAF5FF),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFAF5FF),
              const Color(0xFFFCE7F3),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Contenu
              Expanded(
                child: _model.isLoading
                    ? _buildLoader()
                    : _model.errorMessage != null
                        ? _buildErrorState()
                        : _model.gifts.isEmpty
                            ? _buildEmptyState()
                            : _buildGiftsList(),
              ),

              // Boutons d'action
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              // Bouton retour/fermer
              IconButton(
                onPressed: () {
                  if (!mounted) return;
                  // Si returnTo existe, retourner vers cette page
                  if (_returnTo != null && _returnTo!.isNotEmpty) {
                    print('🔙 Retour vers: $_returnTo');
                    context.go(_returnTo!);
                  } else {
                    // Sinon, aller à l'accueil
                    context.go('/home-pinterest');
                  }
                },
                icon: Icon(
                  _returnTo != null && _returnTo!.isNotEmpty
                      ? Icons.arrow_back
                      : Icons.close,
                  color: violetColor,
                ),
                tooltip: _returnTo != null && _returnTo!.isNotEmpty ? 'Retour' : 'Fermer',
              ),
              Icon(Icons.auto_awesome, color: violetColor, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tes cadeaux personnalisés',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: violetColor,
                      ),
                    ),
                    Text(
                      'Basés sur tes réponses',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoader() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: violetColor,
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            '✨ Génération de tes cadeaux personnalisés...',
            style: GoogleFonts.poppins(
              color: Colors.grey[700],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Matching intelligent par tags (sexe, âge, centres d\'intérêt)',
            style: GoogleFonts.poppins(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.card_giftcard, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text(
              'Aucun cadeau trouvé',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Essayez de recharger',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône d'erreur
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 24),

            // Titre de l'erreur
            Text(
              _model.errorMessage ?? 'Une erreur est survenue',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Détails de l'erreur
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red[200]!, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: Colors.red[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Détails:',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _model.errorDetails ?? 'Erreur inconnue',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.red[900],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bouton réessayer
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _loadGifts(forceRefresh: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.refresh, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Réessayer',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Bouton continuer quand même
            TextButton(
              onPressed: () async {
                // Marquer l'onboarding comme complété même sans cadeaux
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('onboarding_completed', true);

                if (mounted) {
                  if (FirebaseAuth.instance.currentUser != null) {
                    context.go('/home-pinterest');
                  } else {
                    context.go('/authentification');
                  }
                }
              },
              child: Text(
                'Continuer sans cadeaux',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGiftsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      itemCount: _model.gifts.length,
      itemBuilder: (context, index) {
        final gift = _model.gifts[index];
        return _buildGiftCard(gift);
      },
    );
  }

  Widget _buildGiftCard(Map<String, dynamic> gift) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openProductUrl(gift['url'] ?? ''),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image du produit - FIX Bug 5: Améliorer le loading et l'erreur
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  child: Image.network(
                    gift['image'] ?? '',
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    // FIX: Loader visible pendant le chargement (pas de gris)
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 250,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              violetColor.withOpacity(0.1),
                              const Color(0xFFEC4899).withOpacity(0.1),
                            ],
                          ),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: violetColor,
                            strokeWidth: 3,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    // FIX: Widget d'erreur avec style violet (pas gris)
                    errorBuilder: (context, error, stackTrace) {
                      print('❌ Erreur chargement image cadeau: $error');
                      return Container(
                        height: 250,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              violetColor.withOpacity(0.1),
                              const Color(0xFFEC4899).withOpacity(0.1),
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.card_giftcard,
                              color: violetColor.withOpacity(0.5),
                              size: 60,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Image en cours de chargement',
                              style: GoogleFonts.poppins(
                                color: violetColor.withOpacity(0.7),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Informations du produit
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Marque
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: violetColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          gift['brand'] ?? 'En ligne',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: violetColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Nom du produit
                      Text(
                        gift['name'] ?? 'Produit',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2937),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Description
                      if (gift['description'] != null && gift['description'].toString().isNotEmpty)
                        Text(
                          gift['description'] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF6B7280),
                            height: 1.6,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 16),
                      // Prix et bouton
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Prix
                          Text(
                            '${gift['price']}€',
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: violetColor,
                            ),
                          ),
                          // Bouton voir
                          ElevatedButton(
                            onPressed: () => _openProductUrl(gift['url'] ?? ''),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: violetColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Voir',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bouton Refaire
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _model.isLoading
                ? null
                : () => _loadGifts(forceRefresh: true),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: violetColor, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh, color: violetColor),
                  const SizedBox(width: 8),
                  Text(
                    'Générer de nouveaux cadeaux',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: violetColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Bouton Enregistrer
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _model.isLoading
                  ? null
                  : () async {
                      // Nouvelle architecture: sauvegarder la liste de cadeaux pour une personne
                      if (_model.personId != null) {
                        print('💾 Sauvegarde via nouvelle architecture (personId: ${_model.personId})');

                        // Sauvegarder la liste de cadeaux
                        final listName = 'Liste ${DateTime.now().day}/${DateTime.now().month}';
                        final listId = await FirebaseDataService.saveGiftListForPerson(
                          personId: _model.personId!,
                          gifts: _model.gifts,
                          listName: listName,
                        );
                        print('✅ ${_model.gifts.length} cadeaux sauvegardés (liste: $listId)');

                        // Retirer le flag isPendingFirstGen
                        await FirebaseDataService.updatePersonPendingFlag(_model.personId!, false);
                        print('✅ Flag isPendingFirstGen retiré');

                        // Définir le contexte pour que les futurs favoris soient liés à cette personne
                        await FirebaseDataService.setCurrentPersonContext(_model.personId!);
                        print('✅ Contexte de personne défini: ${_model.personId}');
                      } else {
                        // Ancienne méthode (compatibilité)
                        print('💾 Sauvegarde via ancienne architecture');
                        if (_model.userProfile != null) {
                          final profileWithGifts = {
                            ..._model.userProfile!,
                            'gifts': _model.gifts,
                            'savedAt': DateTime.now().toIso8601String(),
                          };
                          final profileId = await FirebaseDataService.saveGiftProfile(profileWithGifts);
                          print('✅ Profil et ${_model.gifts.length} cadeaux sauvegardés');

                          if (profileId != null) {
                            await FirebaseDataService.setCurrentPersonContext(profileId);
                            print('✅ Contexte de personne défini: $profileId');
                          }
                        }
                      }

                      // Marquer l'onboarding comme complété
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('onboarding_completed', true);
                      await prefs.setString('not_first_time', 'true');
                      print('✅ Onboarding marqué comme complété');

                      // Naviguer vers la page appropriée
                      if (mounted) {
                        // Vérifier si l'utilisateur est déjà authentifié
                        if (FirebaseAuth.instance.currentUser != null) {
                          // Si déjà connecté, aller directement à l'accueil
                          print('✅ Utilisateur déjà connecté, navigation vers home');
                          context.go('/home-pinterest');
                        } else {
                          // Sinon, aller à l'authentification
                          print('🔐 Pas encore connecté, navigation vers auth');
                          context.go('/authentification');
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: violetColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: violetColor.withOpacity(0.4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Enregistrer',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
