import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    extends State<TikTokInspirationPageWidget> with TickerProviderStateMixin {
  late TikTokInspirationPageModel _model;
  late PageController _verticalPageController;
  late PageController _horizontalPageController;
  late AnimationController _likeAnimationController;

  final Color violetColor = const Color(0xFF8A2BE2);
  Set<int> _likedProducts = {};
  bool _showLikeAnimation = false;

  @override
  void initState() {
    super.initState();
    _model = TikTokInspirationPageModel();
    _verticalPageController = PageController();
    _horizontalPageController = PageController();
    _likeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Effacer le contexte de personne
    FirebaseDataService.setCurrentPersonContext(null);

    _model.loadProducts();
  }

  @override
  void dispose() {
    _verticalPageController.dispose();
    _horizontalPageController.dispose();
    _likeAnimationController.dispose();
    _model.dispose();
    super.dispose();
  }

  /// Toggle favorite avec sauvegarde Firebase
  Future<void> _toggleFavorite(Map<String, dynamic> product) async {
    final productId = product['id'] as int;
    final isCurrentlyLiked = _likedProducts.contains(productId);

    setState(() {
      if (isCurrentlyLiked) {
        _likedProducts.remove(productId);
      } else {
        _likedProducts.add(productId);
      }
    });

    try {
      if (isCurrentlyLiked) {
        // Retirer des favoris
        final favorites = await queryFavouritesRecordOnce(
          queryBuilder: (favoritesRecord) => favoritesRecord
              .where('uid', isEqualTo: currentUserReference)
              .where('product.product_title', isEqualTo: product['name'] ?? ''),
        );

        for (var fav in favorites) {
          if (!fav.hasPersonId() || fav.personId == null || fav.personId!.isEmpty) {
            await fav.reference.delete();
          }
        }
      } else {
        // Ajouter aux favoris
        await FavouritesRecord.collection.add(
          createFavouritesRecordData(
            uid: currentUserReference,
            platform: "amazon",
            timeStamp: DateTime.now(),
            personId: null,
            product: ProductsStruct(
              productTitle: product['name'] ?? '',
              productPrice: '${product['price'] ?? 0}€',
              productUrl: product['url'] ?? '',
              productPhoto: product['image'] ?? '',
              productStarRating: '',
              productOriginalPrice: '',
              productNumRatings: 0,
              platform: "amazon",
            ),
          ),
        );

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
    } catch (e) {
      print('❌ Erreur toggle favori: $e');
      // Revenir à l'état précédent
      setState(() {
        if (isCurrentlyLiked) {
          _likedProducts.add(productId);
        } else {
          _likedProducts.remove(productId);
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
          child: Stack(
            children: [
              // Contenu principal
              Consumer<TikTokInspirationPageModel>(
                builder: (context, model, child) {
                  // État de chargement
                  if (model.isLoading) {
                    return _buildLoadingState();
                  }

                  // État d'erreur
                  if (model.hasError) {
                    return _buildErrorState(model);
                  }

                  // Aucun produit
                  if (model.products.isEmpty) {
                    return _buildEmptyState();
                  }

                  // Vue TikTok
                  return _buildTikTokView(model);
                },
              ),

              // Bouton retour toujours visible en haut à gauche
              Positioned(
                top: 16,
                left: 16,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: violetColor,
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'Chargement des inspirations...',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(TikTokInspirationPageModel model) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône d'erreur
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.red[900]?.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red[300],
              ),
            ),
            const SizedBox(height: 24),

            // Titre de l'erreur
            Text(
              model.errorMessage,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Détails de l'erreur
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.red[300]!.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: Colors.red[200]),
                      const SizedBox(width: 8),
                      Text(
                        'Détails:',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[200],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    model.errorDetails,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bouton réessayer
            ElevatedButton.icon(
              onPressed: () {
                _model.loadProducts();
              },
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: Text(
                'Réessayer',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: violetColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
            ),
            const SizedBox(height: 12),

            // Bouton retour
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Retour',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
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
            Icon(
              Icons.card_giftcard,
              size: 80,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 24),
            Text(
              'Aucune inspiration pour le moment',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
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
    );
  }

  Widget _buildTikTokView(TikTokInspirationPageModel model) {
    return Stack(
      children: [
        // PageView vertical pour swiper entre produits
        PageView.builder(
          controller: _verticalPageController,
          scrollDirection: Axis.vertical,
          itemCount: model.products.length,
          onPageChanged: (index) {
            model.setCurrentProductIndex(index);
            // Reset horizontal controller
            if (_horizontalPageController.hasClients) {
              _horizontalPageController.jumpToPage(0);
            }
          },
          itemBuilder: (context, index) {
            final product = model.products[index];
            return _buildProductCard(product);
          },
        ),

        // Bouton fermer en haut à gauche
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
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Badge BÊTA en haut à droite
        SafeArea(
          child: Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: violetColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'INSPIRATION BÊTA',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final productId = product['id'] as int;
    final isLiked = _likedProducts.contains(productId);
    final photos = [product['image'] as String? ?? ''];

    return GestureDetector(
      onDoubleTap: () async {
        // Double tap to like (comme TikTok)
        HapticFeedback.mediumImpact();

        if (!isLiked) {
          setState(() {
            _showLikeAnimation = true;
          });

          _likeAnimationController.forward(from: 0).then((_) {
            setState(() {
              _showLikeAnimation = false;
            });
          });

          await _toggleFavorite(product);
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // PageView horizontal pour swiper entre photos
          PageView.builder(
            controller: _horizontalPageController,
            scrollDirection: Axis.horizontal,
            itemCount: photos.length,
            onPageChanged: (index) {
              _model.setCurrentPhotoIndex(index);
            },
            itemBuilder: (context, photoIndex) {
              return ProductImage(
                imageUrl: photos[photoIndex],
                height: double.infinity,
                borderRadius: BorderRadius.zero,
              );
            },
          ),

        // Gradient overlay pour rendre le texte lisible
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),

        // Indicateurs de photo (dots) en haut
        if (photos.length > 1)
          SafeArea(
            child: Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  photos.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _model.currentPhotoIndex == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                    ),
                  ),
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Badge marque
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
                      product['brand'] as String? ?? product['source'] as String? ?? '',
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
                    '${product['price'] ?? 0}€',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description (si disponible)
                  if (product['description'] != null &&
                      (product['description'] as String).isNotEmpty)
                    Text(
                      product['description'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
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

        // Progress indicator sur le côté droit
        Positioned(
          right: 12,
          top: 0,
          bottom: 0,
          child: Center(
            child: Container(
              width: 4,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.topCenter,
                heightFactor: (_model.currentProductIndex + 1) / _model.products.length,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFEC4899),
                        const Color(0xFF8A2BE2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Bouton coeur à droite
        Positioned(
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
                    key: ValueKey('tiktok_heart_$isLiked'),
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

        // Animation coeur au centre (double tap)
        if (_showLikeAnimation)
          Center(
            child: Icon(
              Icons.favorite,
              size: 120,
              color: Colors.white,
            )
                .animate(controller: _likeAnimationController)
                .scale(
                  begin: const Offset(0.0, 0.0),
                  end: const Offset(1.2, 1.2),
                  duration: 400.ms,
                  curve: Curves.elasticOut,
                )
                .then()
                .fadeOut(duration: 400.ms),
          ),
        ],
      ),
    );
  }
}
