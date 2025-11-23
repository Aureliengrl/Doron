import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Widget optimisé pour afficher des images avec cache automatique
class CachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? placeholderColor;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.placeholderColor,
  });

  @override
  Widget build(BuildContext context) {
    // Fallback image si URL vide
    if (imageUrl.isEmpty) {
      return _buildErrorWidget();
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        // Placeholder pendant le chargement
        placeholder: (context, url) {
          return placeholder ??
              Container(
                width: width,
                height: height,
                color: placeholderColor ?? Colors.grey[200],
                child: Center(
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        placeholderColor?.withOpacity(0.5) ?? Colors.grey[400]!,
                      ),
                    ),
                  ),
                ),
              );
        },
        // Widget d'erreur si l'image ne charge pas
        errorWidget: (context, url, error) {
          print('❌ Erreur chargement image: $url - $error');
          return errorWidget ?? _buildErrorWidget();
        },
        // Options de cache
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 100),
        // Cache l'image pendant 7 jours
        maxWidthDiskCache: 1000, // Optimisation mémoire
        maxHeightDiskCache: 1000,
        memCacheWidth: 800, // Cache en mémoire réduit
        memCacheHeight: 800,
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[100]!,
            Colors.grey[200]!,
          ],
        ),
        borderRadius: borderRadius ?? BorderRadius.zero,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: width != null && width! < 100 ? 40 : 60,
              color: Colors.grey[400],
            ),
            if (width == null || width! >= 100) ...[
              const SizedBox(height: 8),
              Text(
                'Image non disponible',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget optimisé spécifiquement pour les cartes produits (Pinterest)
class ProductImage extends StatelessWidget {
  final String imageUrl;
  final double height;
  final BorderRadius? borderRadius;

  const ProductImage({
    super.key,
    required this.imageUrl,
    this.height = 180,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return CachedImage(
      imageUrl: imageUrl,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover, // ✅ COVER pour remplir les cadres sans bandes blanches ni étirement
      borderRadius: borderRadius,
      placeholderColor: Colors.grey[100],
    );
  }
}

/// Widget optimisé pour le mode Inspirations (plein écran)
/// FIX Bug 4: Amélioration du placeholder et de la gestion d'erreur
class FullscreenProductImage extends StatelessWidget {
  final String imageUrl;
  final double height;
  final BorderRadius? borderRadius;

  const FullscreenProductImage({
    super.key,
    required this.imageUrl,
    this.height = double.infinity,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // FIX Bug 4: Log l'URL pour debug
    print('🖼️ FullscreenProductImage: chargement de "$imageUrl"');

    // FIX Bug 4: Si URL vide ou invalide, afficher message d'erreur clair
    if (imageUrl.isEmpty || !imageUrl.startsWith('http')) {
      print('❌ FullscreenProductImage: URL invalide - "$imageUrl"');
      return Container(
        height: height,
        width: double.infinity,
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported_outlined,
                size: 80,
                color: Colors.white.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Image non disponible',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        // FIX Bug 4: Placeholder avec loader visible (pas juste gris)
        placeholder: (context, url) {
          return Container(
            height: height,
            width: double.infinity,
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFF8A2BE2), // Violet de l'app
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chargement...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        // FIX Bug 4: Widget d'erreur visible avec message explicite
        errorWidget: (context, url, error) {
          print('❌ FullscreenProductImage: Erreur chargement - $url - $error');
          return Container(
            height: height,
            width: double.infinity,
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red.withOpacity(0.7),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur de chargement',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Swipe pour voir le suivant',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 100),
        maxWidthDiskCache: 1200,
        maxHeightDiskCache: 1600,
        memCacheWidth: 1000,
        memCacheHeight: 1400,
      ),
    );
  }
}

/// Preload une liste d'images pour améliorer les performances
Future<void> preloadImages(BuildContext context, List<String> imageUrls) async {
  final validUrls = imageUrls.where((url) => url.isNotEmpty).toList();

  print('🖼️ Preloading ${validUrls.length} images...');

  for (final url in validUrls) {
    try {
      await precacheImage(
        CachedNetworkImageProvider(url),
        context,
      );
    } catch (e) {
      print('⚠️ Failed to preload: $url');
    }
  }

  print('✅ Preloaded ${validUrls.length} images');
}
