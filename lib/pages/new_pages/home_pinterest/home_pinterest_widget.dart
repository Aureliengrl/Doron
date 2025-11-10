import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '/services/openai_home_service.dart';
import '/services/firebase_data_service.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/components/cached_image.dart';
import '/components/skeleton_loader.dart';
import 'home_pinterest_model.dart';
import 'home_pinterest_widgets_extra.dart';
export 'home_pinterest_model.dart';

class HomePinterestWidget extends StatefulWidget {
  const HomePinterestWidget({super.key});

  static String routeName = 'HomePinterest';
  static String routePath = '/home-pinterest';

  @override
  State<HomePinterestWidget> createState() => _HomePinterestWidgetState();
}

class _HomePinterestWidgetState extends State<HomePinterestWidget> {
  late HomePinterestModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final Color violetColor = const Color(0xFF8A2BE2);
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _model = HomePinterestModel();
    // Effacer le contexte de personne (les favoris de cette page seront "en vrac")
    FirebaseDataService.setCurrentPersonContext(null);
    _loadFavorites(); // Charger les favoris depuis Firebase
    _loadProducts();

    // Écouter le scroll pour l'infinite scroll
    _scrollController.addListener(_onScroll);
  }

  /// Charge les favoris depuis Firebase (FlutterFlow system)
  Future<void> _loadFavorites() async {
    try {
      // Charger les favoris FlutterFlow (sans personId = favoris "en vrac")
      final favorites = await queryFavouritesRecordOnce(
        queryBuilder: (favoritesRecord) => favoritesRecord
            .where('uid', isEqualTo: currentUserReference)
            .where('personId', isNull: true),
      );

      if (mounted) {
        setState(() {
          // On ne peut pas utiliser les IDs car FlutterFlow utilise des titres
          // On va créer un Set de titres pour la comparaison
          _model.likedProductTitles.clear();
          for (var fav in favorites) {
            if (fav.product.productTitle.isNotEmpty) {
              _model.likedProductTitles.add(fav.product.productTitle);
            }
          }
        });
        print('✅ ${_model.likedProductTitles.length} favoris chargés depuis Firebase');
      }
    } catch (e) {
      print('❌ Erreur chargement favoris: $e');
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      // L'utilisateur est à 80% du scroll, charger plus de produits
      if (!_model.isLoadingMore && _model.hasMore) {
        _loadMoreProducts();
      }
    }
  }

  /// Charge les produits initiaux (12 premiers)
  Future<void> _loadProducts() async {
    // Réinitialiser la pagination
    _model.resetPagination();

    if (mounted) {
      setState(() {
        _model.setLoading(true);
      });
    }

    try {
      // Charger le profil utilisateur depuis Firebase
      final userProfile = await FirebaseDataService.loadOnboardingAnswers();

      // Extraire et stocker le prénom
      final firstName = userProfile?['firstName'] as String? ?? '';
      _model.setFirstName(firstName);

      // Charger la liste des produits déjà vus depuis le cache
      final prefs = await SharedPreferences.getInstance();
      final seenProductsJson = prefs.getStringList('seen_home_products_${_model.activeCategory}') ?? [];
      print('📋 ${seenProductsJson.length} produits déjà vus dans la catégorie ${_model.activeCategory}');

      // Ajouter un seed de variation pour forcer ChatGPT à générer de nouveaux produits à chaque refresh
      final profileWithVariation = {
        ...?userProfile,
        '_refresh_timestamp': DateTime.now().millisecondsSinceEpoch,
        '_variation_seed': DateTime.now().microsecond,
        '_seen_products': seenProductsJson, // Passer les produits déjà vus
        '_page': 0,
      };

      // Générer les produits via ChatGPT (12 premiers)
      final products = await OpenAIHomeService.generateHomeProducts(
        category: _model.activeCategory,
        userProfile: profileWithVariation,
        count: HomePinterestModel.productsPerPage,
      );

      // Sauvegarder les nouveaux produits dans le cache
      final newSeenProducts = [...seenProductsJson];
      for (var product in products) {
        final productName = '${product['brand']}_${product['name']}';
        if (!newSeenProducts.contains(productName)) {
          newSeenProducts.add(productName);
        }
      }
      // Limiter à 200 produits max pour ne pas surcharger
      if (newSeenProducts.length > 200) {
        newSeenProducts.removeRange(0, newSeenProducts.length - 200);
      }
      await prefs.setStringList('seen_home_products_${_model.activeCategory}', newSeenProducts);
      print('💾 ${newSeenProducts.length} produits dans le cache (${products.length} nouveaux ajoutés)');

      if (mounted) {
        setState(() {
          _model.setProducts(products);
          _model.hasMore = products.length >= HomePinterestModel.productsPerPage;
          _model.setLoading(false);
          _model.clearError(); // Clear any previous errors on success
        });
      }
    } catch (e) {
      print('❌ Erreur chargement produits: $e');

      // Parser l'erreur pour extraire des détails utiles
      String errorMessage = 'Erreur de chargement';
      String errorDetails = e.toString();
      bool showFallbackProducts = false;

      // Analyser le type d'erreur
      if (errorDetails.contains('401')) {
        errorMessage = '🔑 Clé API invalide';
        errorDetails = 'La clé OpenAI n\'est plus valide. Voici une sélection de cadeaux populaires en attendant.';
        showFallbackProducts = true;
      } else if (errorDetails.contains('429')) {
        errorMessage = '⚠️ Quota API dépassé';
        errorDetails = 'Le quota OpenAI a été atteint. Voici une sélection de cadeaux populaires en attendant.';
        showFallbackProducts = true;
      } else if (errorDetails.contains('500') || errorDetails.contains('502') || errorDetails.contains('503')) {
        errorMessage = '🔧 Serveur indisponible';
        errorDetails = 'Le serveur OpenAI a un problème temporaire. Voici une sélection de cadeaux populaires en attendant.';
        showFallbackProducts = true;
      } else if (errorDetails.contains('SocketException') || errorDetails.contains('Network')) {
        errorMessage = '📡 Pas de connexion';
        errorDetails = 'Vérifie ta connexion internet. Voici une sélection de cadeaux populaires en attendant.';
        showFallbackProducts = true;
      } else {
        // Erreur générique - afficher quand même des produits de secours
        errorMessage = '⚠️ Problème de connexion';
        errorDetails = 'Nous avons un problème pour générer des cadeaux personnalisés. Voici une sélection de cadeaux populaires.';
        showFallbackProducts = true;
      }

      if (mounted) {
        setState(() {
          _model.setLoading(false);
          if (showFallbackProducts) {
            // Charger les produits de secours pour que l'utilisateur voie quand même du contenu
            _model.setProducts(_getFallbackProducts(_model.activeCategory));
            _model.hasMore = false;
            _model.clearError(); // Ne pas afficher l'erreur si on a des produits de secours
          } else {
            _model.setError(errorMessage, errorDetails);
          }
        });
      }
    }
  }

  /// Charge plus de produits (infinite scroll)
  Future<void> _loadMoreProducts() async {
    if (_model.isLoadingMore || !_model.hasMore) return;

    if (mounted) {
      setState(() {
        _model.setLoadingMore(true);
      });
    }

    try {
      _model.incrementPage();

      final userProfile = await FirebaseDataService.loadOnboardingAnswers();
      final prefs = await SharedPreferences.getInstance();
      final seenProductsJson = prefs.getStringList('seen_home_products_${_model.activeCategory}') ?? [];

      final profileWithVariation = {
        ...?userProfile,
        '_refresh_timestamp': DateTime.now().millisecondsSinceEpoch,
        '_variation_seed': DateTime.now().microsecond,
        '_seen_products': seenProductsJson,
        '_page': _model.currentPage,
      };

      // Charger 12 produits supplémentaires
      final products = await OpenAIHomeService.generateHomeProducts(
        category: _model.activeCategory,
        userProfile: profileWithVariation,
        count: HomePinterestModel.productsPerPage,
      );

      // Mettre à jour le cache
      final newSeenProducts = [...seenProductsJson];
      for (var product in products) {
        final productName = '${product['brand']}_${product['name']}';
        if (!newSeenProducts.contains(productName)) {
          newSeenProducts.add(productName);
        }
      }
      if (newSeenProducts.length > 200) {
        newSeenProducts.removeRange(0, newSeenProducts.length - 200);
      }
      await prefs.setStringList('seen_home_products_${_model.activeCategory}', newSeenProducts);

      if (mounted) {
        setState(() {
          _model.addProducts(products);
          _model.hasMore = products.length >= HomePinterestModel.productsPerPage;
          _model.setLoadingMore(false);
        });
      }

      print('✅ Chargé ${products.length} produits supplémentaires (page ${_model.currentPage})');
    } catch (e) {
      print('❌ Erreur chargement plus de produits: $e');
      if (mounted) {
        setState(() {
          _model.setLoadingMore(false);
        });
      }
    }
  }

  /// Toggle favorite avec sauvegarde Firebase
  Future<void> _toggleFavorite(Map<String, dynamic> product) async {
    final productId = product['id'] as int;
    final productTitle = product['name'] ?? '';
    final isCurrentlyLiked = _model.likedProductTitles.contains(productTitle);

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Toggle l'état local immédiatement pour l'UI
    if (mounted) {
      setState(() {
        _model.toggleLike(productId);
        if (isCurrentlyLiked) {
          _model.likedProductTitles.remove(productTitle);
        } else {
          _model.likedProductTitles.add(productTitle);
        }
      });
    }

    try {
      if (isCurrentlyLiked) {
        // Retirer des favoris Firebase
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

        print('✅ Retiré des favoris: ${product['name']}');
      } else {
        // Ajouter aux favoris Firebase
        await FavouritesRecord.collection.add(
          createFavouritesRecordData(
            uid: currentUserReference,
            platform: Platforms.amazon,
            timeStamp: DateTime.now(),
            personId: null, // Favoris "en vrac" sans personne
            product: ProductsStruct(
              productTitle: product['name'] ?? '',
              productPrice: '${product['price'] ?? 0}€',
              productUrl: product['url'] ?? '',
              productPhoto: product['image'] ?? '',
              productStarRating: '',
              productOriginalPrice: '',
              productNumRatings: 0,
              platform: Platforms.amazon,
            ),
          ),
        );

        print('✅ Ajouté aux favoris: ${product['name']}');

        // Afficher une confirmation
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
      // Revenir à l'état précédent en cas d'erreur
      if (mounted) {
        setState(() {
          _model.toggleLike(productId);
          // Restaurer aussi likedProductTitles
          if (isCurrentlyLiked) {
            _model.likedProductTitles.add(productTitle);
          } else {
            _model.likedProductTitles.remove(productTitle);
          }
        });
        // Afficher un message d'erreur à l'utilisateur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ Impossible de modifier les favoris. Vérifiez votre connexion.',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red[700],
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Produits de secours quand l'API échoue
  List<Map<String, dynamic>> _getFallbackProducts(String category) {
    final allProducts = [
      {
        'id': 1,
        'name': 'AirPods Pro 2ème génération',
        'description': 'Écouteurs sans fil avec réduction de bruit active. Son spatial personnalisé.',
        'price': 279,
        'brand': 'Apple',
        'source': 'Apple',
        'image': 'https://images.unsplash.com/photo-1606841837239-c5a1a4a07af7?w=600&q=80',
        'category': 'Tech',
        'url': 'https://www.apple.com/fr/airpods-pro/',
      },
      {
        'id': 2,
        'name': 'Pull en Cachemire',
        'description': 'Douceur incomparable, coupe moderne. Le basique luxe parfait.',
        'price': 89,
        'brand': 'Zara',
        'source': 'Zara',
        'image': 'https://images.unsplash.com/photo-1576871337632-b9aef4c17ab9?w=600&q=80',
        'category': 'Mode',
        'url': 'https://www.zara.com/fr',
      },
      {
        'id': 3,
        'name': 'Coffret Skincare',
        'description': 'Routine complète pour une peau éclatante. Produits iconiques.',
        'price': 65,
        'brand': 'Sephora',
        'source': 'Sephora',
        'image': 'https://images.unsplash.com/photo-1596755389378-c31d21fd1273?w=600&q=80',
        'category': 'Beauté',
        'url': 'https://www.sephora.fr',
      },
      {
        'id': 4,
        'name': 'Bougie Diptyque',
        'description': 'Ambiance cosy instantanée. Parfum envoûtant.',
        'price': 68,
        'brand': 'Diptyque',
        'source': 'Sephora',
        'image': 'https://images.unsplash.com/photo-1602874801006-e0c97c1c6122?w=600&q=80',
        'category': 'Maison',
        'url': 'https://www.sephora.fr',
      },
      {
        'id': 5,
        'name': 'Nike Air Max 90',
        'description': 'Sneakers iconiques, confort maximal. Style streetwear.',
        'price': 140,
        'brand': 'Nike',
        'source': 'Nike',
        'image': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600&q=80',
        'category': 'Mode',
        'url': 'https://www.nike.com/fr',
      },
      {
        'id': 6,
        'name': 'Chocolats Pierre Hermé',
        'description': 'Sélection gourmande d\'exception. Haute pâtisserie française.',
        'price': 45,
        'brand': 'Pierre Hermé',
        'source': 'Pierre Hermé',
        'image': 'https://images.unsplash.com/photo-1481391243133-f96216dcb5d2?w=600&q=80',
        'category': 'Food',
        'url': 'https://www.pierreherme.com',
      },
      {
        'id': 7,
        'name': 'PlayStation 5',
        'description': 'Console next-gen, expérience gaming immersive.',
        'price': 549,
        'brand': 'Sony',
        'source': 'Fnac',
        'image': 'https://images.unsplash.com/photo-1606813907291-d86efa9b94db?w=600&q=80',
        'category': 'Tech',
        'url': 'https://www.fnac.com',
      },
      {
        'id': 8,
        'name': 'Sac Polène Numéro Un',
        'description': 'Maroquinerie française d\'excellence. Design minimaliste.',
        'price': 360,
        'brand': 'Polène',
        'source': 'Polène',
        'image': 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=600&q=80',
        'category': 'Mode',
        'url': 'https://www.polene-paris.com',
      },
      {
        'id': 9,
        'name': 'Parfum Le Labo',
        'description': 'Fragrance signature unique et sophistiquée.',
        'price': 195,
        'brand': 'Le Labo',
        'source': 'Sephora',
        'image': 'https://images.unsplash.com/photo-1541643600914-78b084683601?w=600&q=80',
        'category': 'Beauté',
        'url': 'https://www.sephora.fr',
      },
      {
        'id': 10,
        'name': 'Lampe Flos',
        'description': 'Design italien iconique. Éclairage d\'ambiance parfait.',
        'price': 320,
        'brand': 'Flos',
        'source': 'Maisons du Monde',
        'image': 'https://images.unsplash.com/photo-1513506003901-1e6a229e2d15?w=600&q=80',
        'category': 'Maison',
        'url': 'https://www.maisonsdumonde.com',
      },
      {
        'id': 11,
        'name': 'Montre Apple Watch',
        'description': 'Fitness tracker élégant avec toutes les fonctionnalités.',
        'price': 449,
        'brand': 'Apple',
        'source': 'Apple',
        'image': 'https://images.unsplash.com/photo-1579586337278-3befd40fd17a?w=600&q=80',
        'category': 'Tech',
        'url': 'https://www.apple.com/fr/watch/',
      },
      {
        'id': 12,
        'name': 'Veste Zara',
        'description': 'Veste tendance avec coupe moderne et matière premium.',
        'price': 119,
        'brand': 'Zara',
        'source': 'Zara',
        'image': 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=600&q=80',
        'category': 'Mode',
        'url': 'https://www.zara.com/fr',
      },
    ];

    // Filtrer selon la catégorie si spécifique
    if (category == 'Tech') {
      return allProducts.where((p) => p['category'] == 'Tech').toList();
    } else if (category == 'Mode') {
      return allProducts.where((p) => p['category'] == 'Mode').toList();
    } else if (category == 'Beauté') {
      return allProducts.where((p) => p['category'] == 'Beauté').toList();
    } else if (category == 'Maison') {
      return allProducts.where((p) => p['category'] == 'Maison').toList();
    } else if (category == 'Food') {
      return allProducts.where((p) => p['category'] == 'Food').toList();
    }

    // Sinon retourner tous les produits
    return allProducts;
  }

  /// Retourne un emoji + texte court pour la catégorie
  String _getCategoryEmoji(String category) {
    final categoryLower = category.toLowerCase();

    if (categoryLower.contains('tech') || categoryLower.contains('technologie')) {
      return '📱 Tech';
    } else if (categoryLower.contains('mode') || categoryLower.contains('fashion') || categoryLower.contains('vêtement')) {
      return '👗 Mode';
    } else if (categoryLower.contains('maison') || categoryLower.contains('home') || categoryLower.contains('déco')) {
      return '🏠 Maison';
    } else if (categoryLower.contains('beauté') || categoryLower.contains('beauty') || categoryLower.contains('cosmétique')) {
      return '💄 Beauté';
    } else if (categoryLower.contains('sport') || categoryLower.contains('fitness')) {
      return '⚽ Sport';
    } else if (categoryLower.contains('food') || categoryLower.contains('gastronomie') || categoryLower.contains('cuisine')) {
      return '🍷 Food';
    } else if (categoryLower.contains('bien-être') || categoryLower.contains('wellness') || categoryLower.contains('spa')) {
      return '🧘 Bien-être';
    } else if (categoryLower.contains('art') || categoryLower.contains('créatif')) {
      return '🎨 Art';
    } else if (categoryLower.contains('gaming') || categoryLower.contains('jeux')) {
      return '🎮 Gaming';
    } else if (categoryLower.contains('lecture') || categoryLower.contains('livre')) {
      return '📚 Lecture';
    } else if (categoryLower.contains('musique')) {
      return '🎵 Musique';
    } else if (categoryLower.contains('voyage')) {
      return '✈️ Voyage';
    }

    // Par défaut
    return '✨ $category';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF9FAFB),
      body: RefreshIndicator(
        color: violetColor,
        onRefresh: _loadProducts,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Header violet arrondi
            SliverToBoxAdapter(child: _buildHeader()),

            // Barre de recherche
            SliverToBoxAdapter(
              child: SearchBarWidget(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _model.setSearchQuery(value);
                  });
                },
                onClear: () {
                  _searchController.clear();
                  setState(() {
                    _model.setSearchQuery('');
                  });
                },
                violetColor: violetColor,
              ),
            ),

            // Quick filters
            SliverToBoxAdapter(
              child: QuickFiltersWidget(
                showOnlyFavorites: _model.showOnlyFavorites,
                onToggleFilter: (filter) {
                  setState(() {
                    _model.toggleQuickFilter(filter);
                  });
                },
                violetColor: violetColor,
              ),
            ),

            // Message de bienvenue
            SliverToBoxAdapter(child: _buildWelcomeMessage()),

            // Bouton Inspiration (BÊTA)
            SliverToBoxAdapter(child: _buildInspirationButton()),

            // Catégories
            SliverToBoxAdapter(child: _buildCategories()),

            // Filtres par prix
            SliverToBoxAdapter(child: _buildPriceFilters()),

            // Grille Pinterest 2 colonnes
            _buildPinterestGrid(),

            // Loader pour infinite scroll
            if (_model.isLoadingMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: violetColor,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),

            // Espacement pour la bottom nav
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF8A2BE2),
            const Color(0xFFEC4899),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8A2BE2).withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Accueil',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Découvrez votre sélection personnalisée',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          const Icon(
            Icons.auto_awesome,
            color: Color(0xFFFBBF24),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _model.firstName.isNotEmpty
                  ? 'Bienvenue ${_model.firstName} !\nVoici ta sélection personnalisée'
                  : 'Bienvenue !\nVoici ta sélection personnalisée',
              style: GoogleFonts.poppins(
                color: const Color(0xFF4B5563),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspirationButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Haptic feedback
            HapticFeedback.mediumImpact();
            context.push('/inspiration');
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFEC4899),
                  const Color(0xFF8A2BE2),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8A2BE2).withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icône avec animation rotate
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.wb_twilight,
                    color: Colors.white,
                    size: 28,
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(
                      duration: 2000.ms,
                      color: Colors.white.withOpacity(0.3),
                    )
                    .then(delay: 2000.ms),
                const SizedBox(width: 16),
                // Texte
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Mode Inspiration',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'BÊTA',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          )
                              .animate(onPlay: (controller) => controller.repeat())
                              .fadeIn(duration: 1000.ms)
                              .then(delay: 500.ms)
                              .fadeOut(duration: 1000.ms)
                              .then(delay: 500.ms),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Découvre les cadeaux en format TikTok',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                // Flèche avec animation
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 18,
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .moveX(begin: 0, end: 4, duration: 1000.ms, curve: Curves.easeInOut)
                    .then()
                    .moveX(begin: 4, end: 0, duration: 1000.ms, curve: Curves.easeInOut),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, curve: Curves.easeOut)
              .slideY(begin: 0.3, end: 0, duration: 400.ms, curve: Curves.easeOut),
        ),
      )
          .animate(onPlay: (controller) => controller.repeat())
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.02, 1.02),
            duration: 2000.ms,
            curve: Curves.easeInOut,
          )
          .then()
          .scale(
            begin: const Offset(1.02, 1.02),
            end: const Offset(1.0, 1.0),
            duration: 2000.ms,
            curve: Curves.easeInOut,
          ),
    );
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 8),
          child: Text(
            'Filtre par catégorie',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
        SizedBox(
          height: 50,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: _model.categories.length,
            itemBuilder: (context, index) {
              final category = _model.categories[index];
              final isActive = _model.activeCategory == category['name'];

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // Haptic feedback
                  HapticFeedback.lightImpact();
                  setState(() {
                    _model.activeCategory = category['name'] as String;
                  });
                  _loadProducts(); // Recharger les produits pour la nouvelle catégorie
                },
                borderRadius: BorderRadius.circular(50),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? violetColor
                        : violetColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: violetColor.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        category['emoji'] as String,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        category['name'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.white : violetColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: 100 * index),
                duration: 300.ms,
              )
              .slideX(
                begin: -0.2,
                end: 0,
                delay: Duration(milliseconds: 100 * index),
                duration: 300.ms,
                curve: Curves.easeOut,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPriceFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 8),
          child: Text(
            'Filtre par prix',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
        SizedBox(
          height: 50,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: _model.priceFilters.length,
            itemBuilder: (context, index) {
              final filter = _model.priceFilters[index];
              final isActive = _model.activePriceFilter == filter['id'];

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _model.activePriceFilter = filter['id'] as String;
                      });
                    },
                    borderRadius: BorderRadius.circular(50),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFFEC4899) // Rose pour différencier
                            : const Color(0xFFEC4899).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFEC4899).withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : [],
                      ),
                      child: Text(
                        filter['name'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.white : const Color(0xFFEC4899),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPinterestGrid() {
    // Afficher des skeletons pendant le chargement initial
    if (_model.isLoading) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => const ProductCardSkeleton(),
            childCount: 6, // 6 skeletons pendant le chargement
          ),
        ),
      );
    }

    // Séparer en 2 colonnes (avec filtrage par prix)
    final filteredProducts = _model.getFilteredProducts();

    // Afficher l'erreur si présente
    if (_model.errorMessage != null) {
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
                  _model.errorMessage!,
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
                    _model.errorDetails ?? 'Erreur inconnue',
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
                    _model.clearError();
                    _loadProducts();
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

    // Afficher un message si aucun produit (ou aucun après filtrage)
    if (_model.products.isEmpty || filteredProducts.isEmpty) {
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
                  filteredProducts.isEmpty && _model.products.isNotEmpty
                      ? 'Aucun produit dans cette gamme de prix'
                      : 'Aucun cadeau pour l\'instant',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF6B7280),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  filteredProducts.isEmpty && _model.products.isNotEmpty
                      ? 'Essaie un autre filtre de prix'
                      : 'Tire vers le bas pour rafraîchir',
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
    final column1 =
        filteredProducts.where((p) => filteredProducts.indexOf(p) % 2 == 0).toList();
    final column2 =
        filteredProducts.where((p) => filteredProducts.indexOf(p) % 2 != 0).toList();

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
          setState(() {
            _model.selectedProduct = product;
          });
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
              Stack(
                children: [
                  ProductImage(
                    imageUrl: product['image'] as String? ?? '',
                    height: 280,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
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
                  // Bouton coeur avec animation
                  Positioned(
                    top: 12,
                    right: 12,
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
                    height: 280,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  // Bouton fermer
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
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
                            color: Color(0xFF111827),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Bouton coeur
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          await _toggleFavorite(product);
                          Navigator.pop(context);
                          _showProductDetail(product);
                        },
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isLiked
                                ? Colors.red
                                : Colors.white.withOpacity(0.95),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.white : const Color(0xFF111827),
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Détails du produit
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: violetColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        product['source'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: violetColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      product['name'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${product['price']}€',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: violetColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      product['description'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Bouton Voir sur...
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Ouvrir le lien du produit
                          final url = product['url'] as String? ?? '';
                          if (url.isNotEmpty) {
                            try {
                              final uri = Uri.parse(url);
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            } catch (e) {
                              print('❌ Erreur ouverture URL: $e');
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: violetColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          shadowColor: violetColor.withOpacity(0.4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Voir sur ${product['source']}',
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
                              size: 18,
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
