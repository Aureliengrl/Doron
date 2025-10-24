import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'onboarding_advanced_model.dart';
export 'onboarding_advanced_model.dart';

class OnboardingAdvancedWidget extends StatefulWidget {
  const OnboardingAdvancedWidget({super.key});

  static String routeName = 'OnboardingAdvanced';
  static String routePath = '/onboarding-advanced';

  @override
  State<OnboardingAdvancedWidget> createState() =>
      _OnboardingAdvancedWidgetState();
}

class _OnboardingAdvancedWidgetState extends State<OnboardingAdvancedWidget>
    with TickerProviderStateMixin {
  late OnboardingAdvancedModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Couleur principale
  final Color violetColor = const Color(0xFF9D4EDD);

  @override
  void initState() {
    super.initState();
    _model = OnboardingAdvancedModel();
    _model.initAnimations(this);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final steps = _model.getSteps();
    final currentStepData = steps[_model.currentStep];
    final progress = (_model.currentStep + 1) / steps.length;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFFAF5FF),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFAF5FF),
              const Color(0xFFFCE7F3),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Particules animées
              ..._buildAnimatedParticles(),

              // Contenu principal
              Column(
                children: [
                  // Header avec progression
                  _buildHeader(progress, steps.length),

                  // Contenu de l'étape
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(
                        left: 24,
                        right: 24,
                        top: 32,
                        bottom: 120,
                      ),
                      child: _buildStepContent(currentStepData),
                    ),
                  ),
                ],
              ),

              // Bouton Continuer
              _buildContinueButton(steps),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAnimatedParticles() {
    return List.generate(20, (index) {
      return AnimatedBuilder(
        animation: _model.particleControllers[index],
        builder: (context, child) {
          return Positioned(
            left: MediaQuery.of(context).size.width *
                _model.particlePositions[index].dx,
            top: MediaQuery.of(context).size.height *
                _model.particlePositions[index].dy,
            child: Opacity(
              opacity: 0.2,
              child: Container(
                width: _model.particleSizes[index],
                height: _model.particleSizes[index],
                decoration: BoxDecoration(
                  color: violetColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildHeader(double progress, int totalSteps) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              if (_model.currentStep > 0)
                InkWell(
                  onTap: _model.handleBack,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: violetColor,
                      size: 24,
                    ),
                  ),
                ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, color: violetColor, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '${_model.currentStep + 1}/$totalSteps',
                      style: GoogleFonts.poppins(
                        color: violetColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Barre de progression
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOut,
                    width: MediaQuery.of(context).size.width * progress,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          violetColor,
                          const Color(0xFFEC4899),
                          violetColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(Map<String, dynamic> stepData) {
    final type = stepData['type'] as String;

    if (type == 'welcome') {
      return _buildWelcomeScreen(stepData);
    } else if (type == 'transition') {
      return _buildTransitionScreen(stepData);
    } else if (type == 'single' || type == 'multiple') {
      return _buildQuestionScreen(stepData);
    } else if (type == 'slider') {
      return _buildSliderScreen(stepData);
    }

    return const SizedBox.shrink();
  }

  Widget _buildWelcomeScreen(Map<String, dynamic> stepData) {
    final useLogo = stepData['useLogo'] as bool? ?? false;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 800),
          builder: (context, double value, child) {
            return Transform.scale(
              scale: value,
              child: useLogo
                  ? Image.asset(
                      'assets/images/doron_logo.png', // Logo DORÕN (vague)
                      width: 150,
                      height: 150,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback si l'image n'existe pas encore
                        return Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: violetColor.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.card_giftcard,
                            size: 80,
                            color: violetColor,
                          ),
                        );
                      },
                    )
                  : Text(
                      stepData['emoji'] as String,
                      style: const TextStyle(fontSize: 100),
                    ),
            );
          },
        ),
        const SizedBox(height: 24),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              violetColor,
              const Color(0xFFEC4899),
              violetColor,
            ],
          ).createShader(bounds),
          child: Text(
            stepData['title'] as String,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          stepData['subtitle'] as String,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 20,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTransitionScreen(Map<String, dynamic> stepData) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 1000),
          builder: (context, double value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: Text(
                  stepData['emoji'] as String,
                  style: const TextStyle(fontSize: 80),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        Text(
          stepData['title'] as String,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: violetColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          stepData['subtitle'] as String,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionScreen(Map<String, dynamic> stepData) {
    final type = stepData['type'] as String;
    final field = stepData['field'] as String;
    final options = stepData['options'] as List<String>;

    return Column(
      children: [
        if (stepData.containsKey('subtitle'))
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              stepData['subtitle'] as String,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: violetColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              stepData['icon'] as String,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                stepData['question'] as String,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        ...options.map((option) {
          final isSelected = _model.isSelected(field, option);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _model.handleSelect(field, option, type == 'multiple');
                    });
                  },
                  borderRadius: BorderRadius.circular(32),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                violetColor,
                                violetColor.withOpacity(0.8),
                              ],
                            )
                          : null,
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : Colors.grey[200]!,
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: violetColor.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            option,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.white : Colors.grey[700],
                            ),
                          ),
                        ),
                        if (isSelected && type == 'multiple')
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
        if (type == 'multiple')
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              '✨ Tu peux sélectionner plusieurs réponses',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: violetColor,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSliderScreen(Map<String, dynamic> stepData) {
    final field = stepData['field'] as String;
    final min = (stepData['min'] as int).toDouble();
    final max = (stepData['max'] as int).toDouble();
    final value = _model.answers[field] as double? ?? min;

    return Column(
      children: [
        Text(
          stepData['icon'] as String,
          style: const TextStyle(fontSize: 40),
        ),
        const SizedBox(height: 16),
        Text(
          stepData['question'] as String,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        if (stepData.containsKey('subtitle'))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              stepData['subtitle'] as String,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: violetColor,
              ),
            ),
          ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        violetColor,
                        const Color(0xFFEC4899),
                      ],
                    ).createShader(bounds),
                    child: Text(
                      '${value.toInt()}€',
                      style: GoogleFonts.poppins(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 0,
                    right: -8,
                    child: Icon(
                      Icons.auto_awesome,
                      color: Color(0xFFFBBF24),
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 16,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 14,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 24,
                  ),
                  activeTrackColor: violetColor,
                  inactiveTrackColor: const Color(0xFFE9D5FF),
                  thumbColor: violetColor,
                  overlayColor: violetColor.withOpacity(0.2),
                ),
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  onChanged: (newValue) {
                    setState(() {
                      _model.answers[field] = newValue;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${min.toInt()}€',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '${max.toInt()}€',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton(List<Map<String, dynamic>> steps) {
    final canProceed = _model.canProceed(steps[_model.currentStep]);
    final isLastStep = _model.currentStep == steps.length - 1;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withOpacity(0),
              Colors.white,
              Colors.white,
            ],
          ),
        ),
        child: ElevatedButton(
          onPressed: canProceed
              ? () {
                  setState(() {
                    _model.handleNext(steps, context);
                  });
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: canProceed ? violetColor : Colors.grey[300],
            disabledBackgroundColor: Colors.grey[300],
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            elevation: canProceed ? 8 : 0,
            shadowColor: violetColor.withOpacity(0.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLastStep) ...[
                const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                isLastStep ? 'Découvrir mes cadeaux' : 'Continuer',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: canProceed ? Colors.white : Colors.grey[500],
                ),
              ),
              if (isLastStep) ...[
                const SizedBox(width: 8),
                const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              ] else ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward,
                  color: canProceed ? Colors.white : Colors.grey[500],
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
