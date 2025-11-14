import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'voice_analysis_page_model.dart';

class VoiceAnalysisPageWidget extends StatefulWidget {
  final String transcript;

  const VoiceAnalysisPageWidget({
    Key? key,
    required this.transcript,
  }) : super(key: key);

  @override
  State<VoiceAnalysisPageWidget> createState() =>
      _VoiceAnalysisPageWidgetState();
}

class _VoiceAnalysisPageWidgetState extends State<VoiceAnalysisPageWidget> {
  late VoiceAnalysisPageModel _model;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _model = VoiceAnalysisPageModel();
    _model.initialize(widget.transcript);

    // Écouter les changements pour naviguer automatiquement
    _model.addListener(_onModelChanged);
  }

  void _onModelChanged() {
    if (!_hasNavigated &&
        !_model.isAnalyzing &&
        !_model.hasError &&
        _model.analysisResult != null) {
      // Marquer comme ayant navigué pour éviter les navigations multiples
      _hasNavigated = true;

      // Navigation automatique vers les résultats
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          context.pushReplacement(
            '/voiceResults',
            extra: {
              'analysis': _model.analysisResult,
              'transcript': widget.transcript,
            },
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _model.removeListener(_onModelChanged);
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _model,
      child: Scaffold(
        backgroundColor: const Color(0xFF062248),
        appBar: AppBar(
          backgroundColor: const Color(0xFF062248),
          automaticallyImplyLeading: false,
          title: const Text(
            'Analyse en cours...',
            style: TextStyle(
              fontFamily: 'Outfit',
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          child: Consumer<VoiceAnalysisPageModel>(
            builder: (context, model, _) {
              if (model.hasError) {
                return _buildErrorState(model);
              }

              return _buildLoadingState();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animation de cercles concentriques
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Cercle extérieur
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFF6B9D).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                )
                    .animate(
                      onPlay: (controller) => controller.repeat(),
                    )
                    .scale(
                      duration: const Duration(milliseconds: 2000),
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.0, 1.0),
                      curve: Curves.easeInOut,
                    )
                    .fadeIn(
                      duration: const Duration(milliseconds: 1000),
                    )
                    .then()
                    .fadeOut(
                      duration: const Duration(milliseconds: 1000),
                    ),

                // Cercle moyen
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFF6B9D).withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                )
                    .animate(
                      onPlay: (controller) => controller.repeat(),
                    )
                    .scale(
                      duration: const Duration(milliseconds: 1500),
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.0, 1.0),
                      curve: Curves.easeInOut,
                    )
                    .fadeIn(
                      duration: const Duration(milliseconds: 750),
                    )
                    .then()
                    .fadeOut(
                      duration: const Duration(milliseconds: 750),
                    ),

                // Cercle intérieur (icône)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF6B9D),
                        Color(0xFFC74375),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B9D).withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 40,
                    color: Colors.white,
                  ),
                )
                    .animate(
                      onPlay: (controller) => controller.repeat(),
                    )
                    .rotate(
                      duration: const Duration(milliseconds: 3000),
                      begin: 0,
                      end: 1,
                    ),
              ],
            ),
          ),

          const SizedBox(height: 48),

          // Texte de chargement
          Text(
            'Analyse de votre description...',
            style: TextStyle(
              fontFamily: 'Outfit',
              color: Colors.white.withOpacity(0.9),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          // Sous-texte
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Notre intelligence artificielle analyse vos critères pour trouver les meilleurs cadeaux',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Outfit',
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Indicateur de progression
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFFFF6B9D),
              ),
              minHeight: 4,
            ),
          )
              .animate(
                onPlay: (controller) => controller.repeat(),
              )
              .shimmer(
                duration: const Duration(milliseconds: 1500),
                color: Colors.white.withOpacity(0.3),
              ),
        ],
      ),
    );
  }

  Widget _buildErrorState(VoiceAnalysisPageModel model) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône d'erreur
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.2),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 50,
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 32),

            // Message d'erreur
            Text(
              'Oups, une erreur est survenue',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Outfit',
                color: Colors.white.withOpacity(0.9),
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              model.errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Outfit',
                color: Colors.white.withOpacity(0.6),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 48),

            // Boutons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Retour',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      model.retry();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B9D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Réessayer',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
