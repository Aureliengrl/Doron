import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import 'tiktok_inspiration_page_model.dart';
export 'tiktok_inspiration_page_model.dart';

/// Mode Inspiration - TikTok Style SIMPLIFIÉ
/// Swipe vertical entre produits, clic pour voir la fiche
class TikTokInspirationPageWidget extends StatefulWidget {
  const TikTokInspirationPageWidget({super.key});

  static String routeName = 'TikTokInspiration';
  static String routePath = '/inspiration';

  @override
  State<TikTokInspirationPageWidget> createState() => _TikTokInspirationPageWidgetState();
}

class _TikTokInspirationPageWidgetState extends State<TikTokInspirationPageWidget> {
  late TikTokInspirationPageModel _model;
  late PageController _pageController;

  static const Color _violetColor = Color(0xFF8A2BE2);
  static const Color _pinkColor = Color(0xFFEC4899);

  @override
  void initState() {
    super.initState();
    _model = TikTokInspirationPageModel();
    _pageController = PageController();

    // Charger les produits après le premier frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _model.loadProducts();
      }
    });

    // Écouter les changements du model
    _model.addListener(_onModelChanged);
  }

  void _onModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _model.removeListener(_onModelChanged);
    _pageController.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    // État de chargement
    if (_model.isLoading) {
      return _buildLoadingState();
    }

    // État d'erreur
    if (_model.hasError) {
      return _buildErrorState();
    }

    // Liste vide
    if (_model.products.isEmpty) {
      return _buildEmptyState();
    }

    // Affichage des produits
    return _buildProductsView();
  }

  Widget _buildLoadingState() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                color: _violetColor,
                strokeWidth: 4,
              ),
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
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _model.errorMessage,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _model.loadProducts(),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: Text(
                'Réessayer',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _violetColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Retour',
                style: GoogleFonts.poppins(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.card_giftcard,
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune inspiration disponible',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Retour',
                style: GoogleFonts.poppins(color: _violetColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsView() {
    return Stack(
      children: [
        // PageView vertical pour swipe TikTok style
        PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: _model.products.length,
          onPageChanged: (index) {
            _model.setCurrentIndex(index);
            HapticFeedback.selectionClick();
          },
          itemBuilder: (context, index) {
            final product = _model.getProductAt(index);
            if (product == null) {
              return const SizedBox.shrink();
            }
            return _buildProductCard(product, index);
          },
        ),

        // Bouton retour
        Positioned(
          top: 16,
          left: 16,
          child: _buildBackButton(),
        ),

        // Indicateur de progression (pas de ratio pour infinite scroll)
        Positioned(
          right: 12,
          top: 80,
          bottom: 80,
          child: _buildProgressIndicator(),
        ),

        // ✨ INFINITE SCROLL: Indicateur de chargement en bas
        if (_model.isLoadingMore)
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Chargement...',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // ✨ INFINITE SCROLL: Compteur de produits (pour debug/info)
        Positioned(
          top: 16,
          right: 60,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_model.currentIndex + 1} / ${_model.products.length}',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.pop(context);
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white30, width: 1),
        ),
        child: const Icon(
          Icons.arrow_back,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final total = _model.products.length;
    final current = _model.currentIndex + 1;

    // Calculer le ratio de façon sécurisée
    double ratio = 0.0;
    if (total > 0) {
      ratio = current / total;
      // Sécurité: s'assurer que le ratio est valide
      if (ratio.isNaN || ratio.isInfinite) {
        ratio = 0.0;
      }
      ratio = ratio.clamp(0.0, 1.0);
    }

    return Container(
      width: 4,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.topCenter,
        heightFactor: ratio,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_pinkColor, _violetColor],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, int index) {
    // Extraire les données de façon sécurisée
    final String name = product['name']?.toString() ?? 'Produit';
    final String brand = product['brand']?.toString() ?? '';
    final String image = product['image']?.toString() ?? '';
    final String url = product['url']?.toString() ?? '';
    final int price = product['price'] is int ? product['price'] : 0;
    final int match = product['match'] is int ? product['match'] : 85;

    final bool isLiked = _model.likedProductTitles.contains(name);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Image en plein écran
        _buildProductImage(image),

        // Overlay gradient en bas
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
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),

        // Informations produit en bas
        Positioned(
          bottom: 0,
          left: 0,
          right: 70, // Laisser de la place pour le bouton coeur
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Badge marque
                if (brand.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _violetColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      brand,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (brand.isNotEmpty) const SizedBox(height: 8),

                // Nom du produit
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Prix
                Text(
                  '${price}€',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Bouton voir le produit
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: url.isNotEmpty ? () => _openProductUrl(url) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _violetColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Voir le produit',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.open_in_new, color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bouton coeur à droite
        Positioned(
          right: 16,
          bottom: 120,
          child: _buildLikeButton(product, isLiked),
        ),

        // Indicateur de swipe (seulement sur la première carte)
        if (index == 0)
          Positioned(
            bottom: 200,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.keyboard_arrow_up,
                    color: Colors.white.withOpacity(0.7),
                    size: 32,
                  ),
                  Text(
                    'Swipe infini ♾️',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        color: Colors.grey[900],
        child: Center(
          child: Icon(
            Icons.image_not_supported,
            size: 64,
            color: Colors.grey[700],
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => Container(
        color: Colors.grey[900],
        child: const Center(
          child: CircularProgressIndicator(
            color: _violetColor,
            strokeWidth: 3,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[900],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey[700]),
              const SizedBox(height: 8),
              Text(
                'Image non disponible',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLikeButton(Map<String, dynamic> product, bool isLiked) {
    return GestureDetector(
      onTap: () => _toggleFavorite(product),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isLiked ? Colors.red : Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white30, width: 2),
          boxShadow: [
            BoxShadow(
              color: isLiked ? Colors.red.withOpacity(0.4) : Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          isLiked ? Icons.favorite : Icons.favorite_border,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }

  Future<void> _openProductUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      print('❌ Erreur ouverture URL: $e');
    }
  }

  Future<void> _toggleFavorite(Map<String, dynamic> product) async {
    HapticFeedback.mediumImpact();

    final productName = product['name']?.toString() ?? '';
    if (productName.isEmpty) return;

    final isCurrentlyLiked = _model.likedProductTitles.contains(productName);

    // Mise à jour locale immédiate
    setState(() {
      if (isCurrentlyLiked) {
        _model.likedProductTitles.remove(productName);
      } else {
        _model.likedProductTitles.add(productName);
      }
    });

    // Vérifier l'authentification
    if (currentUserReference == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connectez-vous pour sauvegarder vos favoris', style: GoogleFonts.poppins()),
          backgroundColor: Colors.orange[700],
        ),
      );
      return;
    }

    try {
      if (isCurrentlyLiked) {
        // Retirer des favoris
        final favorites = await queryFavouritesRecordOnce(
          queryBuilder: (q) => q
              .where('uid', isEqualTo: currentUserReference)
              .where('product.product_title', isEqualTo: productName),
        );
        for (var fav in favorites) {
          await fav.reference.delete();
        }
      } else {
        // Ajouter aux favoris
        await FavouritesRecord.collection.add(
          createFavouritesRecordData(
            uid: currentUserReference,
            platform: product['source']?.toString().toLowerCase() ?? 'amazon',
            timeStamp: DateTime.now(),
            product: ProductsStruct(
              productTitle: productName,
              productPrice: '${product['price'] ?? 0}€',
              productUrl: product['url']?.toString() ?? '',
              productPhoto: product['image']?.toString() ?? '',
              productStarRating: '',
              productOriginalPrice: '',
              productNumRatings: 0,
              platform: product['source']?.toString().toLowerCase() ?? 'amazon',
            ),
          ),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ajouté aux favoris', style: GoogleFonts.poppins()),
              backgroundColor: Colors.green[700],
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Erreur toggle favori: $e');
      // Revert local state on error
      setState(() {
        if (isCurrentlyLiked) {
          _model.likedProductTitles.add(productName);
        } else {
          _model.likedProductTitles.remove(productName);
        }
      });
    }
  }
}
