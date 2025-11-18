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
    extends State<TikTokInspirationPageWidget> {
  late TikTokInspirationPageModel _model;

  final Color violetColor = const Color(0xFF8A2BE2);

  @override
  void initState() {
    super.initState();
    _model = TikTokInspirationPageModel();

    // Effacer le contexte de personne
    FirebaseDataService.setCurrentPersonContext(null);

    _model.loadProducts();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  /// Toggle favorite avec sauvegarde Firebase
  Future<void> _toggleFavorite(Map<String, dynamic> product) async {
    final productName = product['name'] as String? ?? '';
    final isCurrentlyLiked = _model.likedProductTitles.contains(productName);

    setState(() {
      if (isCurrentlyLiked) {
        _model.likedProductTitles.remove(productName);
      } else {
        _model.likedProductTitles.add(productName);
      }
    });

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
              productTitle: productName,
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
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Consumer<TikTokInspirationPageModel>(
            builder: (context, model, child) {
              return CustomScrollView(
                slivers: [
                  // Header avec titre et bouton retour
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          // Bouton retour
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Navigator.pop(context),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.arrow_back,
                                  color: const Color(0xFF374151),
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Titre
                          Expanded(
                            child: Text(
                              'Mode Inspiration',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // État de chargement
                  if (model.isLoading) _buildLoadingState(),

                  // État d'erreur
                  if (model.hasError && !model.isLoading)
                    _buildErrorState(model),

                  // Aucun produit
                  if (model.products.isEmpty &&
                      !model.isLoading &&
                      !model.hasError)
                    _buildEmptyState(),

                  // Grille Pinterest
                  if (model.products.isNotEmpty &&
                      !model.isLoading &&
                      !model.hasError)
                    _buildPinterestGrid(model),

                  // Padding en bas
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 40),
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
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      sliver: SliverToBoxAdapter(
        child: Center(
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
                  color: const Color(0xFF6B7280),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(TikTokInspirationPageModel model) {
    return SliverToBoxAdapter(
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
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 50,
                  color: Colors.red[400],
                ),
              ),
              const SizedBox(height: 20),

              // Titre de l'erreur
              Text(
                model.errorMessage,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Détails de l'erreur
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!, width: 1),
                ),
                child: Text(
                  model.errorDetails,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.red[900],
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
                  backgroundColor: Colors.red[600],
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.card_giftcard,
                size: 80,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 20),
              Text(
                'Aucune inspiration pour le moment',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF6B7280),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Tire vers le bas pour rafraîchir',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF9CA3AF),
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

  Widget _buildPinterestGrid(TikTokInspirationPageModel model) {
    // Séparer en 2 colonnes
    final column1 = model.products
        .where((p) => model.products.indexOf(p) % 2 == 0)
        .toList();
    final column2 = model.products
        .where((p) => model.products.indexOf(p) % 2 != 0)
        .toList();

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      sliver: SliverToBoxAdapter(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Colonne 1
            Expanded(
              child: Column(
                children: column1.map((product) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8, bottom: 16),
                    child: _buildProductCard(product),
                  );
                }).toList(),
              ),
            ),
            // Colonne 2 (décalée)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 32),
                child: Column(
                  children: column2.map((product) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 16),
                      child: _buildProductCard(product),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final isLiked = _model.likedProductTitles.contains(product['name'] ?? '');
    final productIndex = _model.products.indexOf(product);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Haptic feedback
          HapticFeedback.lightImpact();
          _showProductDetail(product);
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image avec bouton coeur et badge catégorie
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: ProductImage(
                          imageUrl: product['image'] as String? ?? '',
                          height: double.infinity,
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                    ),
                    // Badge catégorie en haut à gauche
                    if (product['category'] != null && product['category'] != '')
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: violetColor.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            _getCategoryEmoji(product['category'] as String),
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Info produit (brand + name + price)
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand
                    Text(
                      product['brand'] as String? ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Name
                    Text(
                      product['name'] as String? ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Price
                    Text(
                      '${product['price']}€',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: violetColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 50 * productIndex),
          duration: 400.ms,
        )
        .slideY(
          begin: 0.2,
          end: 0,
          delay: Duration(milliseconds: 50 * productIndex),
          duration: 400.ms,
          curve: Curves.easeOut,
        );
  }

  String _getCategoryEmoji(String category) {
    final categoryLower = category.toLowerCase();
    if (categoryLower.contains('tech')) return '📱 Tech';
    if (categoryLower.contains('mode') || categoryLower.contains('vêtement')) {
      return '👗 Mode';
    }
    if (categoryLower.contains('beauté') || categoryLower.contains('cosmétique')) {
      return '💄 Beauté';
    }
    if (categoryLower.contains('maison') || categoryLower.contains('déco')) {
      return '🏠 Maison';
    }
    if (categoryLower.contains('sport')) return '⚽ Sport';
    if (categoryLower.contains('livre')) return '📚 Livres';
    if (categoryLower.contains('jouet') || categoryLower.contains('jeu')) {
      return '🎮 Jeux';
    }
    return category;
  }

  void _showProductDetail(Map<String, dynamic> product) {
    final isLiked = _model.likedProductTitles.contains(product['name'] ?? '');

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 60,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image avec boutons
              Stack(
                children: [
                  ProductImage(
                    imageUrl: product['image'] as String? ?? '',
                    height: 350,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  // Bouton fermer
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Color(0xFF374151),
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Bouton coeur
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _toggleFavorite(product),
                        borderRadius: BorderRadius.circular(50),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isLiked ? Colors.red : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: isLiked
                                    ? Colors.red.withOpacity(0.4)
                                    : Colors.black.withOpacity(0.2),
                                blurRadius: isLiked ? 16 : 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.white : const Color(0xFF374151),
                            size: 20,
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
                ],
              ),

              // Info produit
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand
                    Text(
                      product['brand'] as String? ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Name
                    Text(
                      product['name'] as String? ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Price
                    Text(
                      '${product['price']}€',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: violetColor,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Bouton voir le produit
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
                          elevation: 4,
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
            ],
          ),
        ),
      ),
    );
  }
}
