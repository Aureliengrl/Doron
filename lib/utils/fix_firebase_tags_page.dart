import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

/// PAGE DE DEBUG pour corriger les tags Firebase
///
/// UTILISATION:
/// 1. Ajouter cette route dans nav.dart : '/fix-tags' -> FixFirebaseTagsPage()
/// 2. Naviguer vers /fix-tags dans l'app
/// 3. Cliquer sur "CORRIGER LES TAGS"
/// 4. Attendre que la correction se termine
/// 5. Vérifier les logs et le résumé
class FixFirebaseTagsPage extends StatefulWidget {
  const FixFirebaseTagsPage({super.key});

  static String routeName = 'FixFirebaseTags';
  static String routePath = '/fix-tags';

  @override
  State<FixFirebaseTagsPage> createState() => _FixFirebaseTagsPageState();
}

class _FixFirebaseTagsPageState extends State<FixFirebaseTagsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> _logs = [];
  bool _isRunning = false;
  int _totalProducts = 0;
  int _updatedProducts = 0;
  int _errors = 0;

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)} - $message');
    });
    print(message);
  }

  Future<void> _fixTags() async {
    setState(() {
      _isRunning = true;
      _logs.clear();
      _totalProducts = 0;
      _updatedProducts = 0;
      _errors = 0;
    });

    _addLog('🔧 Début de la correction des tags Firebase');
    _addLog('=========================================');

    try {
      // Charger tous les produits
      _addLog('📦 Chargement des produits...');
      final snapshot = await _firestore.collection('gifts').get();
      _totalProducts = snapshot.docs.length;
      _addLog('✅ ${_totalProducts} produits chargés');

      if (snapshot.docs.isEmpty) {
        _addLog('❌ Aucun produit dans Firebase !');
        setState(() => _isRunning = false);
        return;
      }

      // Afficher un échantillon AVANT
      final sample = snapshot.docs.first.data();
      _addLog('📋 AVANT: "${sample['name']}"');
      _addLog('   Tags: ${sample['tags']}');
      _addLog('   Prix: ${sample['price']}€');
      _addLog('');

      // Traiter chaque produit
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          final productName = (data['name'] ?? '').toString().toLowerCase();
          final productDescription = (data['description'] ?? '').toString().toLowerCase();
          final price = data['price'] is int
              ? data['price']
              : (int.tryParse(data['price']?.toString() ?? '0') ?? 0);
          final currentTags = (data['tags'] as List?)?.cast<String>() ?? [];
          final currentCategories = (data['categories'] as List?)?.cast<String>() ?? [];

          final newTags = <String>{...currentTags};
          final newCategories = <String>{...currentCategories};
          bool modified = false;

          // ============================================
          // 1. TAGS DE GENRE (CRITIQUE)
          // ============================================
          final hasGenderTag = currentTags.any((t) => t.startsWith('gender_'));

          if (!hasGenderTag) {
            // Mots-clés FÉMININS
            final feminineKeywords = [
              'robe',
              'jupe',
              'lingerie',
              'soutien-gorge',
              'culotte femme',
              'collant',
              'maquillage',
              'rouge à lèvres',
              'mascara',
              'vernis',
              'sac à main',
              'femme',
              'pour elle',
              'féminin'
            ];

            // Mots-clés MASCULINS
            final masculineKeywords = [
              'cravate',
              'rasoir électrique',
              'tondeuse barbe',
              'after shave',
              'costume homme',
              'homme',
              'pour lui',
              'masculin'
            ];

            final isFeminine = feminineKeywords
                .any((kw) => productName.contains(kw) || productDescription.contains(kw));
            final isMasculine = masculineKeywords
                .any((kw) => productName.contains(kw) || productDescription.contains(kw));

            if (isFeminine && !isMasculine) {
              newTags.add('gender_femme');
              modified = true;
            } else if (isMasculine && !isFeminine) {
              newTags.add('gender_homme');
              modified = true;
            } else {
              newTags.add('gender_mixte');
              modified = true;
            }
          }

          // ============================================
          // 2. TAGS DE CATÉGORIE
          // ============================================
          final hasCategoryTag = currentTags.any((t) => t.startsWith('cat_'));

          if (!hasCategoryTag) {
            final categoryKeywords = {
              'cat_tech': [
                'tech',
                'électronique',
                'gadget',
                'usb',
                'bluetooth',
                'écouteurs',
                'casque',
                'smartphone',
                'tablette',
                'ordinateur',
                'souris',
                'clavier'
              ],
              'cat_mode': [
                'vêtement',
                't-shirt',
                'pull',
                'sweat',
                'pantalon',
                'jean',
                'chaussure',
                'basket',
                'sneaker',
                'mode',
                'fashion'
              ],
              'cat_beaute': [
                'beauté',
                'maquillage',
                'parfum',
                'crème',
                'soin',
                'cosmétique',
                'huile',
                'sérum',
                'shampoing'
              ],
              'cat_maison': [
                'maison',
                'déco',
                'décoration',
                'coussin',
                'lampe',
                'bougie',
                'vase',
                'cadre',
                'plante'
              ],
              'cat_sport': [
                'sport',
                'fitness',
                'yoga',
                'running',
                'musculation',
                'gym',
                'training',
                'basket',
                'football'
              ],
              'cat_food': [
                'cuisine',
                'gastronomie',
                'chocolat',
                'thé',
                'café',
                'vin',
                'gourmet',
                'food',
                'bouteille'
              ],
            };

            bool foundCategory = false;
            for (var entry in categoryKeywords.entries) {
              final categoryTag = entry.key;
              final keywords = entry.value;

              if (keywords.any(
                  (kw) => productName.contains(kw) || productDescription.contains(kw))) {
                newTags.add(categoryTag);
                newCategories.add(categoryTag.replaceFirst('cat_', '').capitalize());
                modified = true;
                foundCategory = true;
                break;
              }
            }

            if (!foundCategory) {
              newTags.add('cat_tendances');
              newCategories.add('Tendances');
              modified = true;
            }
          }

          // ============================================
          // 3. TAGS DE BUDGET
          // ============================================
          final hasBudgetTag = currentTags.any((t) => t.startsWith('budget_'));

          if (!hasBudgetTag && price > 0) {
            String budgetTag;
            if (price < 50) {
              budgetTag = 'budget_0_50';
            } else if (price < 100) {
              budgetTag = 'budget_50_100';
            } else if (price < 200) {
              budgetTag = 'budget_100_200';
            } else if (price < 500) {
              budgetTag = 'budget_200_500';
            } else {
              budgetTag = 'budget_500_plus';
            }
            newTags.add(budgetTag);
            modified = true;
          }

          // ============================================
          // 4. TAGS D'ÂGE
          // ============================================
          final hasAgeTag = currentTags.any((t) => t.startsWith('age_'));

          if (!hasAgeTag) {
            if (productName.contains('enfant') ||
                productName.contains('bébé') ||
                productName.contains('kid')) {
              newTags.add('age_enfant');
            } else if (productName.contains('ado') || productName.contains('teenager')) {
              newTags.add('age_jeune');
            } else if (productName.contains('senior') || productName.contains('retraite')) {
              newTags.add('age_senior');
            } else {
              newTags.add('age_adulte');
            }
            modified = true;
          }

          // ============================================
          // METTRE À JOUR SI MODIFIÉ
          // ============================================
          if (modified) {
            await doc.reference.update({
              'tags': newTags.toList(),
              'categories': newCategories.toList(),
            });
            _updatedProducts++;

            if (_updatedProducts <= 5) {
              _addLog('✅ "${data['name']}" → ${newTags.length} tags');
            }
          }
        } catch (e) {
          _errors++;
          _addLog('❌ Erreur: $e');
        }
      }

      // Résumé final
      _addLog('');
      _addLog('✅ TERMINÉ !');
      _addLog('═══════════════════════════════════════');
      _addLog('📊 Total produits: $_totalProducts');
      _addLog('✅ Produits mis à jour: $_updatedProducts');
      _addLog('❌ Erreurs: $_errors');

      // Échantillon APRÈS
      final updatedSnapshot = await _firestore.collection('gifts').limit(1).get();
      if (updatedSnapshot.docs.isNotEmpty) {
        final updatedSample = updatedSnapshot.docs.first.data();
        _addLog('');
        _addLog('📋 APRÈS: "${updatedSample['name']}"');
        _addLog('   Tags: ${updatedSample['tags']}');
      }
    } catch (e) {
      _addLog('❌ ERREUR CRITIQUE: $e');
      _errors++;
    } finally {
      setState(() => _isRunning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'Correction Tags Firebase',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF8A2BE2),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Statistiques en haut
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF8A2BE2), const Color(0xFFEC4899)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Total', _totalProducts.toString(), Icons.inventory),
                _buildStat('Mis à jour', _updatedProducts.toString(), Icons.check_circle),
                _buildStat('Erreurs', _errors.toString(), Icons.error),
              ],
            ),
          ),

          // Bouton d'action
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: _isRunning ? null : _fixTags,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8A2BE2),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: _isRunning
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Correction en cours...',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      '🔧 CORRIGER LES TAGS',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),

          // Logs
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _logs.isEmpty
                  ? Center(
                      child: Text(
                        'Cliquez sur le bouton pour commencer',
                        style: GoogleFonts.sourceCodePro(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        final log = _logs[index];
                        Color textColor = Colors.white70;
                        if (log.contains('✅') || log.contains('TERMINÉ')) {
                          textColor = Colors.green;
                        } else if (log.contains('❌')) {
                          textColor = Colors.red;
                        } else if (log.contains('📋') || log.contains('📊')) {
                          textColor = Colors.blue;
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            log,
                            style: GoogleFonts.sourceCodePro(
                              color: textColor,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
