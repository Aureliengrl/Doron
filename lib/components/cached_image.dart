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
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.card_giftcard,
          size: width != null && width! < 100 ? 30 : 50,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}

/// Widget optimisé spécifiquement pour les cartes produits
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
      fit: BoxFit.contain, // ✅ CONTAIN pour garder les proportions
      borderRadius: borderRadius,
      placeholderColor: Colors.grey[100],
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
