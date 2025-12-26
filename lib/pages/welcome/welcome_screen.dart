import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const String routeName = 'Welcome';
  static const String routePath = '/welcome';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF8A2BE2), // Violet
              const Color(0xFFEC4899), // Rose
              const Color(0xFFFBBF24).withOpacity(0.3), // Or subtil
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Espace supérieur
                const SizedBox(height: 40),

                // Logo et titre
                Column(
                  children: [
                    // Logo DORON avec animation
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 30,
                            spreadRadius: 5,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '🎁',
                          style: const TextStyle(fontSize: 60),
                        ),
                      ),
                    )
                        .animate()
                        .scale(
                          duration: 600.ms,
                          curve: Curves.easeOutBack,
                        )
                        .fadeIn(duration: 400.ms),

                    const SizedBox(height: 32),

                    // Titre
                    Text(
                      'DORON',
                      style: GoogleFonts.poppins(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 600.ms)
                        .slideY(begin: 0.3, end: 0),

                    const SizedBox(height: 16),

                    // Sous-titre
                    Text(
                      'Trouve le cadeau parfait\npour tes proches',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.95),
                        height: 1.5,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 600.ms)
                        .slideY(begin: 0.2, end: 0),
                  ],
                ),

                // Boutons d'action
                Column(
                  children: [
                    // Bouton primaire : Commencer
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          HapticFeedback.mediumImpact();

                          // Marquer que ce n'est plus la première fois
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('first_time', false);

                          // Aller à l'onboarding express
                          if (context.mounted) {
                            context.go('/onboarding-advanced');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF8A2BE2),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          elevation: 8,
                          shadowColor: Colors.black.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.rocket_launch, size: 24),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Commencer',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Seulement 3 minutes',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: const Color(0xFF8A2BE2).withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 600.ms, duration: 600.ms)
                        .slideY(begin: 0.3, end: 0)
                        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),

                    const SizedBox(height: 16),

                    // Bouton secondaire : Découvrir sans compte
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () async {
                          HapticFeedback.lightImpact();

                          // Activer le mode anonyme
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('anonymous_mode', true);
                          await prefs.setBool('first_time', false);

                          // Aller directement à la home
                          if (context.mounted) {
                            context.go('/home-pinterest');
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          side: const BorderSide(color: Colors.white, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.visibility_outlined, size: 24),
                            const SizedBox(width: 12),
                            Text(
                              'Découvrir sans compte',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 700.ms, duration: 600.ms)
                        .slideY(begin: 0.3, end: 0)
                        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),

                    const SizedBox(height: 24),

                    // Texte rassurant
                    Text(
                      'Pas de carte bancaire,\njuste des idées de cadeaux ✨',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                        height: 1.5,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 800.ms, duration: 600.ms),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
