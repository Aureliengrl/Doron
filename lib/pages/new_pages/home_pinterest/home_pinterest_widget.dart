import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/openai_home_service.dart';
import '/services/firebase_data_service.dart';
import '/services/product_matching_service.dart';
import '/services/product_url_service.dart';
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
    // Vérifier si l'utilisateur est connecté
    if (FirebaseAuth.instance.currentUser == null) {
      print('⚠️ Utilisateur non connecté, favoris non chargés');
      // Charger les favoris locaux depuis SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        final localFavorites = prefs.getStringList('local_favorite_titles') ?? [];
        if (mounted && localFavorites.isNotEmpty) {
          setState(() {
            _model.likedProductTitles.clear();
            _model.likedProductTitles.addAll(localFavorites);
          });
          print('✅ ${localFavorites.length} favoris chargés depuis local storage');
        }
      } catch (e) {
        print('❌ Erreur chargement favoris locaux: $e');
      }
      return;
    }

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
      print('❌ Erreur chargement favoris Firebase: $e');
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
      // Charger les tags utilisateur depuis Firebase (nouvelle architecture)
      final userProfileTags = await FirebaseDataService.loadUserProfileTags();

      print('🏷️ User profile tags: $userProfileTags');

      // Extraire et stocker le prénom
      final firstName = userProfileTags?['firstName'] as String? ?? '';
      _model.setFirstName(firstName);

      // ✅ TOUJOURS utiliser les tags, même vides (ProductMatchingService gère ça)
      final tagsToUse = userProfileTags ?? {};

      print('📋 Tags utilisés pour matching: $tagsToUse');

      // Charger les sections thématiques (seulement pour "Pour toi")
      if (_model.activeCategory == 'Pour toi' && userProfileTags != null) {
        try {
          final sections = await ProductMatchingService.getHomeSections(
            userTags: userProfileTags,
          );
          if (mounted) {
            setState(() {
              _model.setSections(sections);
            });
          }
        } catch (e) {
          print('❌ Erreur chargement sections: $e');
        }
      } else {
        // Clear sections si on n'est pas dans "Pour toi"
        if (mounted) {
          setState(() {
            _model.setSections([]);
          });
        }
      }

      // Charger la liste des IDs de produits déjà vus depuis le cache
      final prefs = await SharedPreferences.getInstance();
      final seenProductIds = prefs.getStringList('seen_home_product_ids_${_model.activeCategory}')?.map((s) => int.tryParse(s) ?? 0).toList() ?? [];
      print('📋 ${seenProductIds.length} produits déjà vus dans la catégorie ${_model.activeCategory}');

      // 🎯 Générer les produits via ProductMatchingService (Firebase-first)
      print('🔄 Appel ProductMatchingService avec ${tagsToUse.length} tags...');

      // Déterminer le mode de filtrage selon la catégorie
      // "Pour toi" = DISCOVERY (souple, personnalisé mais pas restrictif)
      // Autres catégories = HOME (plus strict car filtre actif)
      final filterMode = _model.activeCategory == 'Pour toi' ? 'discovery' : 'home';
      print('🎯 Mode de filtrage: $filterMode pour catégorie "${_model.activeCategory}"');

      final rawProducts = await ProductMatchingService.getPersonalizedProducts(
        userTags: tagsToUse,
        count: HomePinterestModel.productsPerPage,
        category: _model.activeCategory != 'Pour toi' ? _model.activeCategory : null,
        excludeProductIds: seenProductIds,
        filteringMode: filterMode, // DISCOVERY pour "Pour toi", HOME pour les autres
      );

      print('✅ ProductMatchingService a retourné ${rawProducts.length} produits');

      // Convertir au format attendu et ajouter URLs intelligentes
      final products = rawProducts.map((product) {
        return {
          'id': product['id'],
          'name': product['name'] ?? 'Produit',
          'brand': product['brand'] ?? '',
          'price': product['price'] ?? 0,
          'image': product['image'] ?? product['imageUrl'] ?? '',
          'url': ProductUrlService.generateProductUrl(product),
          'source': product['source'] ?? 'Amazon',
          'categories': product['categories'] ?? [],
          // FIX CRASH: matchScore peut être int ou double
          'match': (product['_matchScore'] is int
              ? product['_matchScore'] as int
              : (product['_matchScore'] is double ? (product['_matchScore'] as double).toInt() : 0)).clamp(0, 100),
        };
      }).toList();

      print('📦 ${products.length} produits convertis pour affichage');

      // Sauvegarder les nouveaux IDs dans le cache
      final newSeenIds = <String>[...seenProductIds.map((id) => id.toString())];
      for (var product in products) {
        final productId = product['id']?.toString() ?? '';
        if (productId.isNotEmpty && !newSeenIds.contains(productId)) {
          newSeenIds.add(productId);
        }
      }
      // Limiter à 300 IDs max pour ne pas surcharger
      if (newSeenIds.length > 300) {
        newSeenIds.removeRange(0, newSeenIds.length - 300);
      }
      await prefs.setStringList('seen_home_product_ids_${_model.activeCategory}', newSeenIds);
      print('💾 ${newSeenIds.length} produits dans le cache (${products.length} nouveaux ajoutés)');

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

      // Analyser le type d'erreur
      if (errorDetails.contains('SocketException') || errorDetails.contains('Network')) {
        errorMessage = '📡 Pas de connexion';
        errorDetails = 'Vérifie ta connexion internet et tire pour rafraîchir.';
      } else if (errorDetails.contains('firebase') || errorDetails.contains('Firestore')) {
        errorMessage = '🔥 Erreur Firebase';
        errorDetails = 'Impossible de charger les produits depuis la base de données. Réessaye plus tard.';
      } else {
        errorMessage = '⚠️ Erreur de chargement';
        errorDetails = 'Une erreur est survenue lors du chargement des produits.';
      }

      if (mounted) {
        setState(() {
          _model.setLoading(false);
          _model.setError(errorMessage, errorDetails);
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

      // Charger les tags utilisateur (nouvelle architecture)
      final userProfileTags = await FirebaseDataService.loadUserProfileTags();
      final prefs = await SharedPreferences.getInstance();
      final seenProductIds = prefs.getStringList('seen_home_product_ids_${_model.activeCategory}')?.map((s) => int.tryParse(s) ?? 0).toList() ?? [];

      // 🎯 Générer plus de produits via ProductMatchingService (Firebase-first)
      final rawProducts = await ProductMatchingService.getPersonalizedProducts(
        userTags: userProfileTags ?? {},
        count: HomePinterestModel.productsPerPage,
        category: _model.activeCategory != 'Pour toi' ? _model.activeCategory : null,
        excludeProductIds: seenProductIds,
        filteringMode: "home", // Mode HOME: Strict sur sexe (basé sur soi-même)
      );

      // Convertir au format attendu et ajouter URLs intelligentes
      final products = rawProducts.map((product) {
        return {
          'id': product['id'],
          'name': product['name'] ?? 'Produit',
          'brand': product['brand'] ?? '',
          'price': product['price'] ?? 0,
          'image': product['image'] ?? product['imageUrl'] ?? '',
          'url': ProductUrlService.generateProductUrl(product),
          'source': product['source'] ?? 'Amazon',
          'categories': product['categories'] ?? [],
          // FIX CRASH: matchScore peut être int ou double
          'match': (product['_matchScore'] is int
              ? product['_matchScore'] as int
              : (product['_matchScore'] is double ? (product['_matchScore'] as double).toInt() : 0)).clamp(0, 100),
        };
      }).toList();

      // Mettre à jour le cache
      final newSeenIds = <String>[...seenProductIds.map((id) => id.toString())];
      for (var product in products) {
        final productId = product['id']?.toString() ?? '';
        if (productId.isNotEmpty && !newSeenIds.contains(productId)) {
          newSeenIds.add(productId);
        }
      }
      if (newSeenIds.length > 300) {
        newSeenIds.removeRange(0, newSeenIds.length - 300);
      }
      await prefs.setStringList('seen_home_product_ids_${_model.activeCategory}', newSeenIds);

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

  /// Toggle favorite avec sauvegarde Firebase ou locale
  /// FIX Bug 3: Amélioration de la sauvegarde des favoris avec les bonnes données
  Future<void> _toggleFavorite(Map<String, dynamic> product) async {
    final productId = product['id'];
    final productTitle = product['name'] ?? product['title'] ?? '';
    final isCurrentlyLiked = _model.likedProductTitles.contains(productTitle);
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;

    // FIX Bug 3: Récupérer l'image depuis plusieurs clés possibles
    String productImage = '';
    for (final key in ['image', 'imageUrl', 'photo', 'productPhoto', 'product_photo']) {
      if (product[key] != null && product[key].toString().isNotEmpty) {
        productImage = product[key].toString();
        break;
      }
    }

    print('💗 Toggle favori AVANT: isLiked=$isCurrentlyLiked, ID=$productId, Titre=$productTitle');
    print('💗 Image trouvée: $productImage');
    print('💗 likedProductTitles AVANT: ${_model.likedProductTitles}');
    print('💗 UID: ${FirebaseAuth.instance.currentUser?.uid}');

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // FIX Bug 3: Convertir productId en int si nécessaire
    int productIdInt = 0;
    if (productId is int) {
      productIdInt = productId;
    } else if (productId != null) {
      productIdInt = int.tryParse(productId.toString()) ?? productTitle.hashCode;
    } else {
      productIdInt = productTitle.hashCode; // Fallback sur le hash du titre
    }

    // Toggle l'état local immédiatement pour l'UI
    if (mounted) {
      setState(() {
        _model.toggleLike(productIdInt, productTitle);
        print('💗 likedProductTitles APRÈS toggle: ${_model.likedProductTitles}');
      });
    }

    // Sauvegarder toujours en local (pour persistance même sans connexion)
    try {
      final prefs = await SharedPreferences.getInstance();
      final localFavorites = prefs.getStringList('local_favorite_titles') ?? [];
      if (isCurrentlyLiked) {
        localFavorites.remove(productTitle);
      } else {
        if (!localFavorites.contains(productTitle)) {
          localFavorites.add(productTitle);
        }
      }
      await prefs.setStringList('local_favorite_titles', localFavorites);
      print('💾 Favoris locaux mis à jour: ${localFavorites.length} favoris');
    } catch (e) {
      print('❌ Erreur sauvegarde favoris locaux: $e');
    }

    // Si non connecté, afficher un message suggérant la connexion
    if (!isLoggedIn) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isCurrentlyLiked
                ? '💔 Retiré des favoris (connectez-vous pour synchroniser)'
                : '❤️ Ajouté aux favoris (connectez-vous pour synchroniser)',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: isCurrentlyLiked ? Colors.grey[600] : const Color(0xFF10B981),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'Connexion',
              textColor: Colors.white,
              onPressed: () {
                context.go('/authentification');
              },
            ),
          ),
        );
      }
      return; // Ne pas tenter de sauvegarder sur Firebase
    }

    // Sauvegarder sur Firebase si connecté
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
            print('✅ Favori supprimé de Firebase: ${fav.reference.id}');
          }
        }

        print('✅ Retiré des favoris Firebase: ${product['name']}');
      } else {
        // FIX Bug 3: Ajouter aux favoris Firebase avec les bonnes données
        // S'assurer que l'URL est correcte
        final productUrl = product['url'] ??
            ProductUrlService.generateProductUrl(product);

        // Récupérer la marque/source
        final brandOrSource = product['brand'] ?? product['source'] ?? 'Amazon';

        // Créer le favori avec toutes les données correctes
        final docRef = await FavouritesRecord.collection.add(
          createFavouritesRecordData(
            uid: currentUserReference,
            platform: brandOrSource.toString().toLowerCase(),
            timeStamp: DateTime.now(),
            personId: null, // Favoris "en vrac" sans personne
            product: ProductsStruct(
              productTitle: productTitle,
              productPrice: '${product['price'] ?? 0}€',
              productUrl: productUrl,
              productPhoto: productImage, // FIX: Utiliser productImage trouvé
              productStarRating: '',
              productOriginalPrice: '',
              productNumRatings: 0,
              platform: brandOrSource.toString().toLowerCase(),
            ),
          ),
        );

        print('✅ Ajouté aux favoris Firebase: $productTitle (ID: ${docRef.id})');
        print('✅ Image sauvegardée: $productImage');

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
    } catch (e, stackTrace) {
      print('❌ Erreur toggle favori Firebase: $e');
      print('Stack trace: $stackTrace');
      // Ne PAS rollback l'état local - le favori reste localement
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '⚠️ Favori sauvegardé localement (erreur sync Firebase)',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.orange[700],
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
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

            // Sections thématiques désactivées - Pinterest uniquement
            // if (_model.sections.isNotEmpty) ...[
            //   SliverToBoxAdapter(child: _buildSections()),
            //   const SliverToBoxAdapter(child: SizedBox(height: 16)),
            // ],

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
    // FIX CRASH: Suppression des animations .repeat() qui causent NaN/Infinity
    // Les animations chaînées avec .repeat() + .then() peuvent provoquer
    // des erreurs de calcul dans flutter_animate
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
                // Icône - FIX: Animation simple sans repeat
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
                ),
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
                          // Badge BÊTA - FIX: Animation simple sans repeat
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
                          ),
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
                // Flèche - FIX: Pas d'animation repeat
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          )
              // FIX: Animation d'entrée simple, sans repeat
              .animate()
              .fadeIn(duration: 400.ms, curve: Curves.easeOut)
              .slideY(begin: 0.3, end: 0, duration: 400.ms, curve: Curves.easeOut),
        ),
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

  Widget _buildSections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _model.sections.map((section) {
        final title = section['title'] as String? ?? '';
        final subtitle = section['subtitle'] as String? ?? '';
        final products = section['products'] as List<Map<String, dynamic>>? ?? [];

        if (products.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            // Titre de la section avec flèche
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  // Compteur de produits dans la section
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: violetColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${products.length}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: violetColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Liste horizontale de produits
            SizedBox(
              height: 260,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildSectionProductCard(product),
                  );
                },
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSectionProductCard(Map<String, dynamic> product) {
    final isLiked = _model.likedProductTitles.contains(product['name'] ?? '');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() {
            _model.selectedProduct = product;
          });
          _showProductDetail(product);
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
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
              // Image avec coeur
              Stack(
                children: [
                  ProductImage(
                    imageUrl: product['image'] as String? ?? '',
                    height: 160,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  // Bouton coeur
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _toggleFavorite(product),
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isLiked ? Colors.red : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.white : const Color(0xFF374151),
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Info produit
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'] as String? ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
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
        .fadeIn(duration: 300.ms, curve: Curves.easeOut)
        .slideX(begin: 0.2, end: 0, duration: 300.ms, curve: Curves.easeOut);
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
              // Image seule, sans badge
              AspectRatio(
                aspectRatio: 0.65,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24), // Arrondi complet pour éviter dépassement
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
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isLiked = _model.likedProductTitles.contains(product['name'] ?? '');

          return Dialog(
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
                      // Bouton coeur - Appel simplifié de _toggleFavorite
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              print('💗 Dialog: Clic sur cœur pour "${product['name']}"');

                              // Appeler la fonction centralisée
                              await _toggleFavorite(product);

                              // Rafraîchir l'UI du dialog
                              setDialogState(() {
                                print('🔄 Dialog: Rafraîchissement UI après toggle');
                              });
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
                        product['brand'] as String? ?? product['source'] as String? ?? 'Amazon',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: violetColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      product['name'] as String? ?? 'Produit',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${product['price'] ?? 0}€',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: violetColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (product['description'] != null && (product['description'] as String).isNotEmpty)
                      Text(
                        product['description'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF6B7280),
                          height: 1.6,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      Text(
                        'Cadeau parfait par ${product['brand'] as String? ?? 'une marque de qualité'}',
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
                          // Générer une URL de produit intelligente (≥95% précision)
                          final url = ProductUrlService.generateProductUrl(product);
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
                              'Voir sur ${product['brand'] ?? product['source'] ?? 'Amazon'}',
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
          );
        },
      ),
    );
  }

}
