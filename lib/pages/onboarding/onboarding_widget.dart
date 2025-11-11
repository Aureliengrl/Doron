import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '/services/firebase_data_service.dart';
import 'onboarding_model.dart';
export 'onboarding_model.dart';

class OnboardingWidget extends StatefulWidget {
  const OnboardingWidget({super.key});

  static String routeName = 'Onboarding';
  static String routePath = '/onboarding';

  @override
  State<OnboardingWidget> createState() => _OnboardingWidgetState();
}

class _OnboardingWidgetState extends State<OnboardingWidget> {
  late OnboardingModel _model;
  final Color violetColor = const Color(0xFF8A2BE2);
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _model = OnboardingModel();
    _checkIfOnboardingCompleted();
  }

  Future<void> _checkIfOnboardingCompleted() async {
    // Vérifier si l'utilisateur a déjà complété l'onboarding
    final answers = await FirebaseDataService.loadOnboardingAnswers();

    if (answers != null && answers.isNotEmpty && mounted) {
      // Onboarding déjà complété, rediriger vers l'authentification
      context.go('/authentification');
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _saveAndContinue() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Sauvegarder les réponses d'onboarding
      await FirebaseDataService.saveOnboardingAnswers(_model.getAnswers());

      if (mounted) {
        // Rediriger vers l'authentification
        context.go('/authentification');
      }
    } catch (e) {
      print('❌ Erreur sauvegarde onboarding: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // Header avec progression
            _buildHeader(),

            // Contenu de l'étape actuelle
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildStepContent(),
              ),
            ),

            // Boutons de navigation
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final progress = (_model.currentStep + 1) / 5;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Configuration',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: violetColor,
                ),
              ),
              Text(
                '${_model.currentStep + 1}/5',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(violetColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_model.currentStep) {
      case 0:
        return _buildWelcomeStep();
      case 1:
        return _buildPersonalInfoStep();
      case 2:
        return _buildGenderStep();
      case 3:
        return _buildInterestsStep();
      case 4:
        return _buildStyleStep();
      default:
        return Container();
    }
  }

  Widget _buildWelcomeStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [violetColor, const Color(0xFFEC4899)],
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.card_giftcard,
            size: 60,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Bienvenue sur Doron !',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Réponds à quelques questions pour\nrecevoir des recommandations\nde cadeaux personnalisées',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildPersonalInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          '👋 Faisons connaissance',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Comment t\'appelles-tu ?',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _model.firstNameController,
          onChanged: (value) {
            setState(() {
              _model.firstName = value;
            });
          },
          decoration: InputDecoration(
            labelText: 'Prénom',
            hintText: 'Entre ton prénom',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: violetColor, width: 2),
            ),
          ),
          style: GoogleFonts.poppins(fontSize: 16),
        ),
        const SizedBox(height: 24),
        Text(
          'Quel âge as-tu ?',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _model.ageController,
          onChanged: (value) {
            setState(() {
              _model.age = value;
            });
          },
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Âge',
            hintText: 'Entre ton âge',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: violetColor, width: 2),
            ),
          ),
          style: GoogleFonts.poppins(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildGenderStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          '👤 Ton genre',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choisis pour des recommandations adaptées',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),
        ..._model.genderOptions.map((option) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildOptionCard(
                option,
                _model.gender == option,
                () {
                  setState(() {
                    _model.gender = option;
                  });
                },
              ),
            )),
      ],
    );
  }

  Widget _buildInterestsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          '❤️ Tes centres d\'intérêt',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sélectionne au moins un centre d\'intérêt',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _model.interestOptions.map((option) {
            final isSelected = _model.interests.contains(option['id']);
            return _buildInterestChip(
              option['label']!,
              isSelected,
              () {
                setState(() {
                  _model.toggleInterest(option['id']!);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStyleStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          '✨ Ton style',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Quel style te correspond le mieux ?',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),
        ..._model.styleOptions.map((option) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildOptionCard(
                option,
                _model.style == option,
                () {
                  setState(() {
                    _model.style = option;
                  });
                },
              ),
            )),
      ],
    );
  }

  Widget _buildOptionCard(String text, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? violetColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? violetColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? violetColor : Colors.grey[400],
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? violetColor : const Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? violetColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? violetColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : const Color(0xFF111827),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final isLastStep = _model.currentStep == 4;
    final canContinue = _model.isStepValid();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_model.currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _model.previousStep();
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: violetColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Retour',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: violetColor,
                  ),
                ),
              ),
            ),
          if (_model.currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: _model.currentStep == 0 ? 1 : 2,
            child: ElevatedButton(
              onPressed: canContinue
                  ? () {
                      if (isLastStep) {
                        _saveAndContinue();
                      } else {
                        setState(() {
                          _model.nextStep();
                        });
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: violetColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      isLastStep ? 'Terminer' : 'Continuer',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
