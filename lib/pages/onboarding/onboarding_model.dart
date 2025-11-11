import 'package:flutter/material.dart';

class OnboardingModel {
  // Étape actuelle de l'onboarding (0-4)
  int currentStep = 0;

  // Réponses de l'utilisateur
  String firstName = '';
  String age = '';
  String gender = '';
  List<String> interests = [];
  String style = '';

  // Controllers pour les champs texte
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  // Options prédéfinies
  final List<String> genderOptions = ['Homme', 'Femme', 'Autre'];
  final List<Map<String, String>> interestOptions = [
    {'id': 'tech', 'label': '📱 Tech'},
    {'id': 'mode', 'label': '👗 Mode'},
    {'id': 'beaute', 'label': '💄 Beauté'},
    {'id': 'sport', 'label': '⚽ Sport'},
    {'id': 'maison', 'label': '🏠 Maison'},
    {'id': 'food', 'label': '🍷 Food'},
    {'id': 'gaming', 'label': '🎮 Gaming'},
    {'id': 'lecture', 'label': '📚 Lecture'},
    {'id': 'voyage', 'label': '✈️ Voyage'},
    {'id': 'bien-etre', 'label': '🧘 Bien-être'},
  ];
  final List<String> styleOptions = [
    'Classique',
    'Moderne',
    'Casual',
    'Élégant',
    'Streetwear',
    'Minimaliste',
  ];

  void dispose() {
    firstNameController.dispose();
    ageController.dispose();
  }

  void nextStep() {
    if (currentStep < 4) {
      currentStep++;
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      currentStep--;
    }
  }

  void toggleInterest(String interest) {
    if (interests.contains(interest)) {
      interests.remove(interest);
    } else {
      interests.add(interest);
    }
  }

  bool isStepValid() {
    switch (currentStep) {
      case 0: // Bienvenue
        return true;
      case 1: // Prénom et âge
        return firstName.isNotEmpty && age.isNotEmpty;
      case 2: // Genre
        return gender.isNotEmpty;
      case 3: // Centres d'intérêt
        return interests.isNotEmpty;
      case 4: // Style
        return style.isNotEmpty;
      default:
        return false;
    }
  }

  Map<String, dynamic> getAnswers() {
    return {
      'firstName': firstName,
      'age': age,
      'gender': gender,
      'interests': interests,
      'style': style,
    };
  }
}
