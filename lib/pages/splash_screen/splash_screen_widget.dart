import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/services/first_time_service.dart';
import '/auth/firebase_auth/auth_util.dart';

class SplashScreenWidget extends StatefulWidget {
  const SplashScreenWidget({super.key});

  static String routeName = 'SplashScreen';
  static String routePath = '/splash';

  @override
  State<SplashScreenWidget> createState() => _SplashScreenWidgetState();
}

class _SplashScreenWidgetState extends State<SplashScreenWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
    _navigate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    try {
      print('🚀 Début navigation splash screen');

      // Attendre l'animation
      await Future.delayed(const Duration(milliseconds: 2000));

      if (!mounted) {
        print('⚠️ Widget non monté après animation');
        return;
      }

      print('🔍 Vérification première utilisation...');

      // Timeout de sécurité : 5 secondes max pour les checks
      final futures = await Future.wait([
        FirstTimeService.isFirstTime(),
        FirstTimeService.hasCompletedOnboarding(),
      ]).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('⚠️ Timeout sur FirstTimeService - Défaut: première utilisation');
          return [true, false]; // Par défaut, première utilisation
        },
      );

      final isFirst = futures[0] as bool;
      final hasCompleted = futures[1] as bool;

      // Vérifier si l'utilisateur est connecté
      final isLoggedIn = loggedIn;

      print('📊 Navigation - isFirst: $isFirst, hasCompleted: $hasCompleted, isLoggedIn: $isLoggedIn');

      if (!mounted) {
        print('⚠️ Widget non monté après checks');
        return;
      }

      if (isFirst && !hasCompleted) {
        // Première utilisation → Onboarding
        print('➡️ Navigation vers onboarding');
        Navigator.pushReplacementNamed(context, '/onboarding-advanced');
      } else if (!isLoggedIn) {
        // Pas connecté → Authentification
        print('➡️ Navigation vers authentification');
        Navigator.pushReplacementNamed(context, '/authentification');
      } else {
        // Connecté → Home
        print('➡️ Navigation vers home');
        Navigator.pushReplacementNamed(context, '/homeAlgoace');
      }
    } catch (e) {
      print('❌ Erreur navigation splash: $e');
      // En cas d'erreur, aller vers onboarding par sécurité
      if (mounted) {
        print('➡️ Fallback vers onboarding après erreur');
        Navigator.pushReplacementNamed(context, '/onboarding-advanced');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Image de fond personnalisée
          Image.asset(
            'assets/images/splash_screen.jpeg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback en cas d'erreur de chargement
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF9D4EDD),
                      const Color(0xFFEC4899),
                      const Color(0xFF9D4EDD),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/doron_logo.png',
                        width: 150,
                        height: 150,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'DORÕN',
                        style: GoogleFonts.poppins(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Animation de fade-in
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: child,
              );
            },
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}
