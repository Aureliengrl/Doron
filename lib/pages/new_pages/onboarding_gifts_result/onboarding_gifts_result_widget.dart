import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/openai_onboarding_service.dart';
import '/services/firebase_data_service.dart';
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
    _loadGifts();
  }

  /// Charge les cadeaux personnalisés basés sur l'onboarding
  Future<void> _loadGifts({bool forceRefresh = false}) async {
    if (mounted) {
      setState(() {
        _model.setLoading(true);
      });
    }

    try {
      // Charger le profil utilisateur depuis Firebase/SharedPreferences
      final userProfile = await FirebaseDataService.loadOnboardingAnswers();
      _model.setUserProfile(userProfile);

      // Ajouter un seed aléatoire pour forcer ChatGPT à générer de nouveaux produits
      final profileWithVariation = {
        ...?userProfile,
        if (forceRefresh) '_refresh_seed': DateTime.now().millisecondsSinceEpoch,
        '_variation': DateTime.now().second, // Variation basée sur la seconde
      };

      // Générer les cadeaux via ChatGPT
      final gifts = await OpenAIOnboardingService.generateOnboardingGifts(
        userProfile: profileWithVariation,
        count: 50, // 50 produits minimum comme demandé
      );

      if (mounted) {
        setState(() {
          _model.setGifts(gifts);
          _model.setLoading(false);
        });
      }
    } catch (e) {
      print('❌ Erreur chargement cadeaux: $e');
      if (mounted) {
        setState(() {
          _model.setLoading(false);
        });
        // Afficher l'erreur à l'utilisateur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ Impossible de générer tes cadeaux. Vérifie ta connexion.',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red[700],
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Réessayer',
              textColor: Colors.white,
              onPressed: () => _loadGifts(forceRefresh: true),
            ),
          ),
        );
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
              // Bouton fermer
              IconButton(
                onPressed: () {
                  context.go('/home-pinterest');
                },
                icon: Icon(Icons.close, color: violetColor),
                tooltip: 'Fermer',
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
            '✨ ChatGPT génère tes cadeaux personnalisés...',
            style: GoogleFonts.poppins(
              color: Colors.grey[700],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Cela peut prendre quelques secondes',
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
                // Image du produit
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
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 250,
                        color: Colors.grey[100],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.card_giftcard,
                              color: violetColor.withOpacity(0.3),
                              size: 60,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Image non disponible',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[400],
                                fontSize: 14,
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
                          gift['source'] ?? 'En ligne',
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
                      // Sauvegarder le profil avec les cadeaux dans Firebase
                      if (_model.userProfile != null) {
                        // Ajouter les cadeaux au profil
                        final profileWithGifts = {
                          ..._model.userProfile!,
                          'gifts': _model.gifts,
                          'savedAt': DateTime.now().toIso8601String(),
                        };
                        final profileId = await FirebaseDataService.saveGiftProfile(profileWithGifts);
                        print('✅ Profil et ${_model.gifts.length} cadeaux sauvegardés');

                        // Définir le contexte pour que les futurs favoris soient liés à cette personne
                        if (profileId != null) {
                          await FirebaseDataService.setCurrentPersonContext(profileId);
                          print('✅ Contexte de personne défini: $profileId');
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
