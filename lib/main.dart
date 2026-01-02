import '/custom_code/actions/index.dart' as actions;
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth/firebase_auth/firebase_user_provider.dart';
import 'auth/firebase_auth/auth_util.dart';

import 'backend/firebase/firebase_config.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/internationalization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/nav/nav.dart';
import '/components/connection_required_dialog.dart';
import 'index.dart';

/// Service de logging d'erreurs global pour capturer les crashs en release
class ErrorLogService {
  static final List<String> _errorLogs = [];
  static const int _maxLogs = 50;

  static void logError(String source, dynamic error, StackTrace? stack) {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = '''
[$timestamp] $source
Error: $error
Stack: ${stack?.toString().split('\n').take(10).join('\n') ?? 'No stack'}
---''';

    _errorLogs.add(logEntry);
    if (_errorLogs.length > _maxLogs) {
      _errorLogs.removeAt(0);
    }

    // Print pour debug console (visible dans Xcode logs)
    print('🔴 ERROR CAPTURED [$source]: $error');
    if (stack != null) {
      print('Stack trace:\n${stack.toString().split('\n').take(15).join('\n')}');
    }
  }

  static List<String> get logs => List.unmodifiable(_errorLogs);
  static String get logsAsString => _errorLogs.join('\n\n');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================
  // FIX CRITIQUE: Capture d'erreurs globale
  // Pour voir les crashs en mode release sur iOS
  // ============================================

  // 1. Capture les erreurs de framework Flutter (widget build errors, etc.)
  FlutterError.onError = (FlutterErrorDetails details) {
    ErrorLogService.logError(
      'FlutterError',
      details.exceptionAsString(),
      details.stack,
    );
    // En debug, afficher normalement
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  };

  // 2. Capture les erreurs async non-gérées (Future/Stream errors)
  PlatformDispatcher.instance.onError = (error, stack) {
    ErrorLogService.logError('PlatformDispatcher', error, stack);
    return true; // Indique qu'on a géré l'erreur
  };

  // 3. Widget d'erreur personnalisé - AU LIEU d'un écran gris
  // Affiche l'erreur réelle pour pouvoir la diagnostiquer
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Container(
      color: Colors.red.shade900,
      padding: const EdgeInsets.all(16),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 48),
              const SizedBox(height: 16),
              const Text(
                'ERREUR WIDGET',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  details.exceptionAsString(),
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontSize: 12,
                    fontFamily: 'monospace',
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Stack: ${details.stack?.toString().split('\n').take(5).join('\n') ?? 'N/A'}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontFamily: 'monospace',
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ),
    );
  };

  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  final environmentValues = FFDevEnvironmentValues();
  await environmentValues.initialize();

  await initFirebase();

  // Start initial custom actions code
  await actions.lockOrientation();
  // End initial custom actions code

  await FlutterFlowTheme.initialize();

  final appState = FFAppState(); // Initialize FFAppState
  await appState.initializePersistedState();

  runApp(ChangeNotifierProvider(
    create: (context) => appState,
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class MyAppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  ThemeMode _themeMode = FlutterFlowTheme.themeMode;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;
  String getRoute([RouteMatch? routeMatch]) {
    final RouteMatch lastMatch =
        routeMatch ?? _router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : _router.routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }

  List<String> getRouteStack() =>
      _router.routerDelegate.currentConfiguration.matches
          .map((e) => getRoute(e))
          .toList();
  late Stream<BaseAuthUser> userStream;

  final authUserSub = authenticatedUserStream.listen((_) {});

  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
    userStream = doronFirebaseUserStream()
      ..listen((user) {
        _appStateNotifier.update(user);
      });
    jwtTokenStream.listen((_) {});
    Future.delayed(
      Duration(milliseconds: 1000),
      () => _appStateNotifier.stopShowingSplashImage(),
    );
  }

  @override
  void dispose() {
    authUserSub.cancel();

    super.dispose();
  }

  void setLocale(String language) {
    safeSetState(() => _locale = createLocale(language));
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
        FlutterFlowTheme.saveThemeMode(mode);
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'DORON',
      scrollBehavior: MyAppScrollBehavior(),
      localizationsDelegates: [
        FFLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FallbackMaterialLocalizationDelegate(),
        FallbackCupertinoLocalizationDelegate(),
      ],
      locale: _locale,
      supportedLocales: const [
        Locale('fr'),
        Locale('en'),
        Locale('es'),
      ],
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: false,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: false,
      ),
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}

class NavBarPage extends StatefulWidget {
  NavBarPage({
    Key? key,
    this.initialPage,
    this.page,
    this.disableResizeToAvoidBottomInset = false,
  }) : super(key: key);

  final String? initialPage;
  final Widget? page;
  final bool disableResizeToAvoidBottomInset;

  @override
  _NavBarPageState createState() => _NavBarPageState();
}

/// This is the private State class that goes with NavBarPage.
class _NavBarPageState extends State<NavBarPage> {
  String _currentPageName = 'HomePinterest';
  late Widget? _currentPage;
  int _currentIndex = 0;

  // Créer les widgets UNE SEULE FOIS pour éviter les rebuilds
  late final List<Widget> _pages;
  late final List<String> _pageNames;

  @override
  void initState() {
    super.initState();

    // Initialiser les pages une seule fois
    _pageNames = ['HomePinterest', 'SearchPage', 'Inspiration', 'UserProfile'];
    _pages = [
      HomePinterestWidget(),
      SearchPageWidget(),
      TikTokInspirationPageWidget(),
      UserProfileWidget(),
    ];

    _currentPageName = widget.initialPage ?? _currentPageName;
    _currentPage = widget.page;
    _currentIndex = _pageNames.indexOf(_currentPageName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: !widget.disableResizeToAvoidBottomInset,
      body: _currentPage ?? IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) async {
          final prefs = await SharedPreferences.getInstance();
          final isAnonymous = prefs.getBool('anonymous_mode') ?? false;

          // Bloquer certaines pages en mode anonyme
          if (isAnonymous) {
            // Index 1 = SearchPage, Index 3 = UserProfile
            if (i == 1) {
              // Afficher le dialog pour SearchPage
              if (context.mounted) {
                await showConnectionRequiredDialog(
                  context,
                  title: 'Connexion requise',
                  message: 'Crée ton compte pour rechercher des cadeaux personnalisés pour tes proches',
                );
              }
              return; // Ne pas changer de page
            } else if (i == 3) {
              // Afficher le dialog pour UserProfile
              if (context.mounted) {
                await showConnectionRequiredDialog(
                  context,
                  title: 'Connexion requise',
                  message: 'Crée ton compte pour accéder à ton profil et tes favoris',
                );
              }
              return; // Ne pas changer de page
            }
            // Les onglets Accueil (index 0) et Inspiration (index 2) sont accessibles en mode anonyme
          }

          // Navigation normale
          safeSetState(() {
            _currentPage = null;
            _currentIndex = i;
            _currentPageName = _pageNames[i];
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF8A2BE2),
        unselectedItemColor: Color(0xFF9E9E9E),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_outlined,
              size: 24.0,
            ),
            activeIcon: Icon(
              Icons.home,
              size: 24.0,
            ),
            label: 'Accueil',
            tooltip: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search_outlined,
              size: 24.0,
            ),
            activeIcon: Icon(
              Icons.search,
              size: 24.0,
            ),
            label: 'Recherche',
            tooltip: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.play_circle_outline,
              size: 28.0,
            ),
            activeIcon: Icon(
              Icons.play_circle,
              size: 28.0,
            ),
            label: 'TikTok',
            tooltip: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_outline,
              size: 24.0,
            ),
            activeIcon: Icon(
              Icons.person,
              size: 24.0,
            ),
            label: 'Profil',
            tooltip: '',
          )
        ],
      ),
    );
  }
}
