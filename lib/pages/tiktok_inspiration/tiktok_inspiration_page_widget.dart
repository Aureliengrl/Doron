import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/components/cached_image.dart';
import '/services/firebase_data_service.dart';
import 'tiktok_inspiration_page_model.dart';
export 'tiktok_inspiration_page_model.dart';

/// Page TikTok Inspiration (BÊTA)
/// Swipe vertical entre produits, swipe horizontal entre photos
class TikTokInspirationPageWidget extends StatefulWidget {
  const TikTokInspirationPageWidget({super.key});

  static String routeName = 'TikTokInspiration';
  static String routePath = '/inspiration';

  @override
  State<TikTokInspirationPageWidget> createState() =>
      _TikTokInspirationPageWidgetState();
}

class _TikTokInspirationPageWidgetState
    extends State<TikTokInspirationPageWidget> {
  late TikTokInspirationPageModel _model;
  late PageController _pageController;

  final Color violetColor = const Color(0xFF8A2BE2);

  @override
  void initState() {
    super.initState();
    _model = TikTokInspirationPageModel();
    _pageController = PageController();

    // Effacer le contexte de personne
    FirebaseDataService.setCurrentPersonContext(null);

    // ✅ IMPORTANT: Ajouter un listener pour forcer le rebuild quand le modèle change
    _model.addListener(_onModelChanged);

    // Charger les favoris existants pour pré-remplir les coeurs
    _loadExistingFavorites();

    // Charger les produits après le premier frame pour garantir que le widget est monté
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _model.loadProducts();
      }
    });
  }

  /// Callback appelé quand le modèle change - force le rebuild
  void _onModelChanged() {
    if (mounted) {
      setState(() {
        // Force rebuild avec les nouvelles données du modèle
        print('🔄 [INSPIRATION] Model changed - forcing rebuild');
      });
    }
  }

  /// Charge les favoris existants pour afficher les coeurs correctement
  Future<void> _loadExistingFavorites() async {
    // ✅ Vérifier si l'utilisateur est connecté avant de charger les favoris Firebase
    if (currentUserReference == null) {
      print('⚠️ Utilisateur non connecté - chargement favoris locaux uniquement');
      // Charger depuis SharedPreferences si non connecté
      try {
        final prefs = await SharedPreferences.getInstance();
        final localFavorites = prefs.getStringList('local_favorite_titles') ?? [];
        if (mounted && localFavorites.isNotEmpty) {
          setState(() {
            _model.likedProductTitles.clear();
            _model.likedProductTitles.addAll(localFavorites);
          });
          print('✅ ${localFavorites.length} favoris locaux chargés');
        }
      } catch (e) {
        print('⚠️ Erreur chargement favoris locaux: $e');
      }
      return;
    }

    try {
      final favorites = await queryFavouritesRecordOnce(
        queryBuilder: (favoritesRecord) => favoritesRecord
            .where('uid', isEqualTo: currentUserReference)
            .where('personId', isNull: true),
      );

      if (mounted) {
        setState(() {
          _model.likedProductTitles.clear();
          for (var fav in favorites) {
            final productTitle = fav.product.productTitle;
            if (productTitle.isNotEmpty) {
              _model.likedProductTitles.add(productTitle);
            }
          }
        });
      }

      print('✅ ${_model.likedProductTitles.length} favoris Firebase chargés');
    } catch (e) {
      print('⚠️ Erreur chargement favoris Firebase: $e');
    }
  }

  @override
  void dispose() {
    _model.removeListener(_onModelChanged);
    _pageController.dispose();
    _model.dispose();
    super.dispose();
  }

  /// Toggle favorite avec sauvegarde Firebase
  Future<void> _toggleFavorite(Map<String, dynamic> product) async {
    // ✅ VÉRIFICATION D'AUTHENTIFICATION
    if (currentUserReference == null) {
      print('⚠️ Utilisateur non connecté, impossible de liker');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '🔐 Veuillez vous connecter pour ajouter aux favoris',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.orange[700],
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Se connecter',
              textColor: Colors.white,
              onPressed: () {
                // ✅ FIX: Utiliser GoRouter au lieu de Navigator pour la cohérence
                context.push('/authentification');
              },
            ),
          ),
        );
      }
      return;
    }

    final productName = product['name'] as String? ?? '';
    final isCurrentlyLiked = _model.likedProductTitles.contains(productName);

    print('💗 Toggle favori (Inspiration) AVANT: isLiked=$isCurrentlyLiked, Produit=$productName');
    print('💗 UID: $currentUserUid');

    setState(() {
      if (isCurrentlyLiked) {
        _model.likedProductTitles.remove(productName);
      } else {
        _model.likedProductTitles.add(productName);
      }
    });

    // Haptic feedback
    HapticFeedback.mediumImpact();

    try {
      if (isCurrentlyLiked) {
        // Retirer des favoris
        final favorites = await queryFavouritesRecordOnce(
          queryBuilder: (favoritesRecord) => favoritesRecord
              .where('uid', isEqualTo: currentUserReference)
              .where('product.product_title', isEqualTo: productName),
        );

        for (var fav in favorites) {
          if (!fav.hasPersonId() || fav.personId == null || fav.personId!.isEmpty) {
            await fav.reference.delete();
            print('✅ Favori supprimé: ${fav.reference.id}');
          }
        }

        print('✅ Retiré des favoris: $productName');
      } else {
        // FIX: Récupérer l'image depuis plusieurs clés possibles
        String productImage = '';
        for (final key in ['image', 'imageUrl', 'photo', 'productPhoto', 'product_photo']) {
          if (product[key] != null && product[key].toString().isNotEmpty) {
            productImage = product[key].toString();
            break;
          }
        }

        // Récupérer la marque/source
        final brandOrSource = product['brand'] ?? product['source'] ?? 'Amazon';

        // Ajouter aux favoris avec toutes les données correctes
        final docRef = await FavouritesRecord.collection.add(
          createFavouritesRecordData(
            uid: currentUserReference,
            platform: brandOrSource.toString().toLowerCase(),
            timeStamp: DateTime.now(),
            personId: null,
            product: ProductsStruct(
              productTitle: productName,
              productPrice: '${product['price'] ?? 0}€',
              productUrl: product['url'] ?? '',
              productPhoto: productImage, // FIX: Utiliser productImage trouvé
              productStarRating: '',
              productOriginalPrice: '',
              productNumRatings: 0,
              platform: brandOrSource.toString().toLowerCase(),
            ),
          ),
        );

        print('✅ Ajouté aux favoris: $productName (ID: ${docRef.id})');
        print('✅ Image sauvegardée: $productImage');

        // Haptic feedback
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '❤️ Ajouté aux favoris !',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: const Color(0xFF10B981),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print('❌ Erreur toggle favori: $e');
      print('Stack trace: $stackTrace');
      // Revenir à l'état précédent
      setState(() {
        if (isCurrentlyLiked) {
          _model.likedProductTitles.add(productName);
        } else {
          _model.likedProductTitles.remove(productName);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _model,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Consumer<TikTokInspirationPageModel>(
            builder: (context, model, child) {
              // 🔍 LOGS DÉTAILLÉS pour diagnostic
              print('🎬 [INSPIRATION BUILD] État du modèle:');
              print('   - isLoading: ${model.isLoading}');
              print('   - hasError: ${model.hasError}');
              print('   - products.length: ${model.products.length}');
              print('   - products.isEmpty: ${model.products.isEmpty}');
              if (model.hasError) {
                print('   - errorMessage: ${model.errorMessage}');
                print('   - errorDetails: ${model.errorDetails}');
              }

              // État de chargement
              if (model.isLoading) {
                print('   → Affichage LOADING STATE');
                return _buildLoadingState();
              }

              // État d'erreur
              if (model.hasError) {
                print('   → Affichage ERROR STATE');
                return _buildErrorState(model);
              }

              // Aucun produit
              if (model.products.isEmpty) {
                print('   → Affichage EMPTY STATE');
                return _buildEmptyState();
              }

              // PageView vertical plein écran
              print('   → Affichage PRODUCTS (${model.products.length} produits)');
              return Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: model.products.length,
                  onPageChanged: (index) {
                    model.setCurrentProductIndex(index);
                  },
                  itemBuilder: (context, index) {
                    final product = model.products[index];
                    return _buildFullscreenProductCard(product);
                  },
                ),

                // Bouton retour en haut à gauche
                SafeArea(
                  child: Positioned(
                    top: 16,
                    left: 16,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Indicateur de progression sur le côté droit
                SafeArea(
                  child: Positioned(
                    right: 12,
                    top: 100,
                    bottom: 100,
                    child: Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.topCenter,
                        // FIX: Éviter division par zéro si products.length == 0
                        heightFactor: model.products.isNotEmpty
                            ? (model.currentProductIndex + 1) / model.products.length
                            : 0.0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFFEC4899),
                                Color(0xFF8A2BE2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: Colors.black, // ✅ Fond noir explicite
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animation de chargement visible
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                color: violetColor,
                strokeWidth: 5,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Chargement des inspirations...',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '🎁 Recherche de cadeaux tendance',
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(TikTokInspirationPageModel model) {
    return Container(
      color: Colors.black, // ✅ Fond noir explicite
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            // Icône d'erreur
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red[900]?.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 50,
                color: Colors.red[300],
              ),
            ),
            const SizedBox(height: 20),

            // Titre de l'erreur
            Text(
              model.errorMessage,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Détails de l'erreur
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[300]!.withOpacity(0.3), width: 1),
              ),
              child: Text(
                model.errorDetails,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            // Bouton réessayer
            ElevatedButton.icon(
              onPressed: () {
                _model.loadProducts();
              },
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: Text(
                'Réessayer',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: violetColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Bouton reset complet
            TextButton.icon(
              onPressed: () async {
                // Reset complet des produits vus
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('seen_inspiration_product_ids');
                print('🔄 RESET MANUEL: Cache produits vus supprimé');
                _model.loadProducts();
              },
              icon: const Icon(Icons.delete_sweep, color: Colors.white70, size: 20),
              label: Text(
                'Reset complet et recharger',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      color: Colors.black, // ✅ Fond noir explicite
      child: Center(
        child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.card_giftcard,
              size: 80,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 20),
            Text(
              'Aucune inspiration pour le moment',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tire vers le bas pour rafraîchir',
              style: GoogleFonts.poppins(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildFullscreenProductCard(Map<String, dynamic> product) {
    final isLiked = _model.likedProductTitles.contains(product['name'] ?? '');

    return Stack(
      fit: StackFit.expand,
      children: [
        // Image en plein écran
        FullscreenProductImage(
          imageUrl: product['image'] as String? ?? '',
          height: double.infinity,
          borderRadius: BorderRadius.zero,
        ),

        // Gradient overlay en bas pour rendre le texte lisible
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),
        ),

        // Info produit en bas
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Marque
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: violetColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      product['brand'] as String? ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Nom du produit
                  Text(
                    product['name'] as String? ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Prix
                  Text(
                    '${product['price']}€',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Bouton Voir le produit
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final url = product['url'] as String? ?? '';
                        if (url.isNotEmpty) {
                          try {
                            final uri = Uri.parse(url);
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          } catch (e) {
                            print('❌ Erreur ouverture URL: $e');
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: violetColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: violetColor.withOpacity(0.6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Voir le produit',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.open_in_new,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Bouton coeur à droite
        SafeArea(
          child: Positioned(
            right: 20,
            bottom: 200,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _toggleFavorite(product);
                },
                borderRadius: BorderRadius.circular(50),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isLiked
                        ? Colors.red
                        : Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isLiked
                            ? Colors.red.withOpacity(0.5)
                            : Colors.black.withOpacity(0.3),
                        blurRadius: isLiked ? 20 : 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: Colors.white,
                    size: 28,
                  ),
                )
                    .animate(
                      key: ValueKey('heart_$isLiked'),
                    )
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.0, 1.0),
                      duration: 200.ms,
                      curve: Curves.elasticOut,
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }

}
