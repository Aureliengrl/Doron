import 'package:flutter/material.dart';

/// Widget skeleton avec effet shimmer pour les états de chargement
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                const Color(0xFF8A2BE2).withOpacity(0.15),
                const Color(0xFFEC4899).withOpacity(0.08),
                const Color(0xFF8A2BE2).withOpacity(0.15),
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton pour une carte produit
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image skeleton
          SkeletonLoader(
            width: double.infinity,
            height: 280,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre
                const SkeletonLoader(width: 150, height: 16),
                const SizedBox(height: 8),
                // Sous-titre
                const SkeletonLoader(width: 100, height: 12),
                const SizedBox(height: 12),
                // Prix
                const SkeletonLoader(width: 80, height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Grid de skeletons pour la page d'accueil (widget normal)
class ProductGridSkeleton extends StatelessWidget {
  final int itemCount;

  const ProductGridSkeleton({
    super.key,
    this.itemCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => const ProductCardSkeleton(),
    );
  }
}

/// VERSION SLIVER du grid de skeletons - À UTILISER dans CustomScrollView/SliverPadding
/// FIX: Cette version retourne un Sliver au lieu d'un widget normal
class SliverProductGridSkeleton extends StatelessWidget {
  final int itemCount;

  const SliverProductGridSkeleton({
    super.key,
    this.itemCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => const ProductCardSkeleton(),
        childCount: itemCount,
      ),
    );
  }
}

/// Skeleton pour liste de profils (page recherche)
class ProfileListSkeleton extends StatelessWidget {
  const ProfileListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(
          4,
          (index) => Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                SkeletonLoader(
                  width: 70,
                  height: 70,
                  borderRadius: BorderRadius.circular(35),
                ),
                const SizedBox(height: 8),
                const SkeletonLoader(width: 60, height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Skeleton pour écran de profil
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        // Avatar
        SkeletonLoader(
          width: 100,
          height: 100,
          borderRadius: BorderRadius.circular(50),
        ),
        const SizedBox(height: 16),
        // Nom
        const SkeletonLoader(width: 150, height: 20),
        const SizedBox(height: 8),
        // Email
        const SkeletonLoader(width: 200, height: 14),
        const SizedBox(height: 32),
        // Stats
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                const SkeletonLoader(width: 60, height: 30),
                const SizedBox(height: 8),
                const SkeletonLoader(width: 80, height: 12),
              ],
            ),
            Column(
              children: [
                const SkeletonLoader(width: 60, height: 30),
                const SizedBox(height: 8),
                const SkeletonLoader(width: 80, height: 12),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
