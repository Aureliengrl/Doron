# 🔄 Modifications de Navigation - DORÕN

## ✅ DÉJÀ FAIT

1. **Routes ajoutées dans `nav.dart`** ✅
   - `/onboarding-advanced` → OnboardingAdvancedWidget
   - `/home-pinterest` → HomePinterestWidget
   - `/search-page` → SearchPageWidget
   - `/gift-results` → GiftResultsWidget

2. **Exports ajoutés dans `index.dart`** ✅

3. **Onboarding → Résultats** ✅
   - À la fin de l'onboarding, navigation automatique vers `/gift-results`

---

## ⏳ À FAIRE MAINTENANT

### 1. **Page Résultats Cadeaux** (`gift_results_widget.dart`)

#### Ajouter 2 Boutons en Bas

**Emplacement**: Juste au-dessus de la bottom nav, dans un Container fixe

```dart
// À ajouter dans le build() après le ListView des résultats
Positioned(
  bottom: 80, // Au-dessus de la bottom nav
  left: 0,
  right: 0,
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: Row(
      children: [
        // Bouton REFAIRE (secondaire)
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/onboarding-advanced');
            },
            icon: const Icon(Icons.refresh),
            label: Text('Refaire',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: const Color(0xFF6B7280),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Bouton ENREGISTRER (primaire)
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: Sauvegarder les données dans Firebase
              Navigator.pushReplacementNamed(context, '/search-page');
            },
            icon: const Icon(Icons.check_circle),
            label: Text('Enregistrer',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: violetColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
              shadowColor: violetColor.withOpacity(0.5),
            ),
          ),
        ),
      ],
    ),
  ),
)
```

#### Modifications nécessaires :

**Fichier**: `lib/pages/new_pages/gift_results/gift_results_widget.dart`

**Ligne ~73**: Dans le `build()`, après le `Expanded(child: _buildResultsList())`

Ajouter le Stack avec le Positioned ci-dessus **AVANT** le `bottomNavigationBar`

---

### 2. **Bottom Navigation - Connecter aux Vraies Pages**

Toutes les 4 nouvelles pages ont une bottom nav avec `onTap: () {}` qui ne fait rien.

#### Modifications nécessaires :

**Fichiers**:
- `gift_results_widget.dart`
- `home_pinterest_widget.dart`
- `search_page_widget.dart`

**Dans chaque fichier**, remplacer la méthode `_buildNavButton`:

```dart
Widget _buildNavButton({
  required IconData icon,
  required String label,
  required bool isActive,
  String? route, // <-- Ajouter ce paramètre
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () {
        if (route != null && !isActive) {
          Navigator.pushReplacementNamed(context, route);
        }
      }, // <-- Navigation réelle
      borderRadius: BorderRadius.circular(16),
      child: Container(
        // ... reste du code identique
      ),
    ),
  );
}
```

**Et dans `_buildBottomNav()`, modifier les appels**:

```dart
_buildNavButton(
  icon: Icons.home,
  label: 'Accueil',
  isActive: false,
  route: '/homeAlgoace', // <-- Route existante
),
_buildNavButton(
  icon: Icons.favorite,
  label: 'Favoris',
  isActive: false,
  route: '/favourites', // <-- Route existante
),
_buildNavButton(
  icon: Icons.search,
  label: 'Recherche',
  isActive: true, // Selon la page actuelle
  route: '/search-page',
),
_buildNavButton(
  icon: Icons.person,
  label: 'Profil',
  isActive: false,
  route: '/profile', // <-- Route existante
),
```

---

### 3. **Page Recherche - Bouton "Ajouter Personne"**

**Fichier**: `lib/pages/new_pages/search_page/search_page_model.dart`

**Ligne ~81**: Méthode `handleAddNewPerson()`

```dart
void handleAddNewPerson() {
  // TODO: Sauvegarder contexte avant de naviguer
  print('🎯 Redirection vers l\'onboarding "Pour qui veux-tu faire un cadeau ?"');
  // Navigation vers l'onboarding
  // PROBLÈME: Pas de BuildContext ici !
}
```

**Solution**: Passer le `BuildContext` en paramètre

```dart
void handleAddNewPerson(BuildContext context) {
  Navigator.pushNamed(context, '/onboarding-advanced');
}
```

**Et dans `search_page_widget.dart`**, modifier les appels:

```dart
// Ligne ~140
onTap: () => _model.handleAddNewPerson(context),

// Ligne ~575 (bouton flottant)
onPressed: () => _model.handleAddNewPerson(context),
```

---

### 4. **Détection Première Utilisation**

Pour afficher l'onboarding au premier lancement, créer un service:

**Nouveau fichier**: `lib/services/first_time_service.dart`

```dart
import 'package:shared_preferences/shared_preferences.dart';

class FirstTimeService {
  static const String _keyFirstTime = 'isFirstTime';
  static const String _keyCompletedOnboarding = 'completedOnboarding';

  // Vérifie si c'est la première fois
  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFirstTime) ?? true;
  }

  // Marque comme "déjà utilisé"
  static Future<void> setNotFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstTime, false);
  }

  // Vérifie si l'onboarding est complété
  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyCompletedOnboarding) ?? false;
  }

  // Marque l'onboarding comme complété
  static Future<void> setOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyCompletedOnboarding, true);
  }
}
```

**Modifier `nav.dart`** pour rediriger vers l'onboarding si première fois:

```dart
// Ligne ~90-95
FFRoute(
  name: '_initialize',
  path: '/',
  builder: (context, _) async {
    // Vérifier si première utilisation
    final isFirst = await FirstTimeService.isFirstTime();
    final hasCompleted = await FirstTimeService.hasCompletedOnboarding();

    if (isFirst && !hasCompleted) {
      return OnboardingAdvancedWidget();
    }

    return appStateNotifier.loggedIn
        ? NavBarPage()
        : AuthentificationWidget();
  },
),
```

**PROBLÈME**: `builder` ne peut pas être async !

**SOLUTION ALTERNATIVE**: Créer une page de splash qui décide

**Nouveau fichier**: `lib/pages/splash_screen.dart`

```dart
import 'package:flutter/material.dart';
import '/services/first_time_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 1500));

    final isFirst = await FirstTimeService.isFirstTime();
    final hasCompleted = await FirstTimeService.hasCompletedOnboarding();

    if (!mounted) return;

    if (isFirst && !hasCompleted) {
      Navigator.pushReplacementNamed(context, '/onboarding-advanced');
    } else {
      Navigator.pushReplacementNamed(context, '/authentification');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9D4EDD),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🎁',
              style: TextStyle(fontSize: 100),
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
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
```

**Modifier `nav.dart` ligne ~93**:

```dart
builder: (context, _) => SplashScreen(),
```

**Et à la fin de l'onboarding**, appeler:

```dart
await FirstTimeService.setOnboardingCompleted();
await FirstTimeService.setNotFirstTime();
Navigator.pushReplacementNamed(context, '/authentification');
```

---

## 📋 RÉSUMÉ DES FICHIERS À MODIFIER

| Fichier | Modifications |
|---------|--------------|
| `gift_results_widget.dart` | Ajouter boutons Enregistrer/Refaire |
| `home_pinterest_widget.dart` | Connecter bottom nav |
| `search_page_widget.dart` | Connecter bottom nav + handleAddNewPerson |
| `search_page_model.dart` | Ajouter BuildContext à handleAddNewPerson |
| `onboarding_advanced_model.dart` | Appeler FirstTimeService à la fin ✅ (déjà fait navigation) |
| **NOUVEAU** `services/first_time_service.dart` | Créer le service |
| **NOUVEAU** `pages/splash_screen.dart` | Créer splash screen |
| `nav.dart` | Modifier route `_initialize` pour SplashScreen |
| `index.dart` | Exporter SplashScreen |

---

## 🚀 ORDRE D'IMPLÉMENTATION RECOMMANDÉ

1. ✅ **Routes** (FAIT)
2. ✅ **Onboarding → Résultats** (FAIT)
3. ⏳ **Boutons Enregistrer/Refaire** (EN COURS)
4. ⏳ **Bottom Nav** (SIMPLE)
5. ⏳ **Première utilisation** (MOYEN)
6. ⏳ **Sauvegarde Firebase** (AVANCÉ - Phase 2)

---

## ⚠️ CE QUI MANQUE ENCORE (Phase 2)

### Sauvegarde des Données

**Collection Firebase "user_profiles"**:
```json
{
  "userId": "uid_firebase",
  "profiles": [
    {
      "id": "profile_1",
      "name": "Maman",
      "initials": "M",
      "color": "#ec4899",
      "relation": "Ma mère",
      "occasion": "Anniversaire",
      "onboardingAnswers": {
        "age": "50-60",
        "hobbies": ["🍳 Cuisine", "📚 Lecture"],
        ...
      }
    }
  ]
}
```

**Collection Firebase "gift_suggestions"**:
```json
{
  "profileId": "profile_1",
  "userId": "uid_firebase",
  "gifts": [
    {
      "id": "gift_1",
      "name": "Coffret Spa Luxe",
      "price": 89,
      "match": 95,
      ...
    }
  ],
  "createdAt": "2025-01-10T12:00:00Z"
}
```

---

## 💡 VOUS DEVEZ ME DIRE

1. **Je continue avec les modifications de navigation** (Boutons + Bottom Nav) ?
2. **Ou vous voulez d'abord voir l'app fonctionner** avec ce qui est fait ?
3. **Vous avez les clés API** pour générer de vrais cadeaux ?
4. **Quelles marques** prioriser ?

Dites-moi et je continue ! 🚀
