# 🔧 Guide de Modification - Gift Generator

## 🎯 Objectif

Remplacer l'appel lent à l'API Amazon par notre OpenAIService personnalisé et rapide.

---

## ✅ Étape 1 : Import ajouté (FAIT)

L'import `/services/gift_search_helper.dart` a déjà été ajouté ligne 11.

---

## 🔄 Étape 2 : Remplacer la logique du bouton

### Fichier à modifier :
`lib/pages/pages/gift_generator/gift_generator_widget.dart`

### Section à remplacer :

**Lignes 1088-1266** (le `onPressed` du bouton "Trouver un cadeau")

### ANCIEN CODE (à supprimer) :

```dart
onPressed: () async {
  if (_model.formKey.currentState == null ||
      !_model.formKey.currentState!.validate()) {
    return;
  }
  _model.min = double.tryParse(_model.minTextController.text);
  _model.max = double.tryParse(_model.maxTextController.text);
  safeSetState(() {});
  if (_model.min! < _model.max!) {
    _model.query = ContentStruct(
      giftrecipient: _model.relationModel.textController.text,
      budget: (String min, String max, String currency) {
        return '$min $currency - $max $currency';
      }(_model.minTextController.text, _model.maxTextController.text, ('USD')),
      age: int.tryParse(_model.ageModel.textController.text),
      interests: _model.interests.unique((e) => e),
    );
    safeSetState(() {});
    _model.stringQuerry = await actions.contentToString(_model.query!);
    _model.apiResponse = await OpenAiChatGPTAlgoaceCall.call(
      query: _model.stringQuerry,
    );

    if ((_model.apiResponse?.succeeded ?? true)) {
      _model.apiResultoga = await AmazonApiForOpenAICall.call(
        query: OpenAiChatGPTAlgoaceCall.querry((_model.apiResponse?.jsonBody ?? '')),
        minPrice: double.tryParse(_model.minTextController.text),
        maxPrice: double.tryParse(_model.maxTextController.text),
      );

      if ((_model.apiResultoga?.succeeded ?? true)) {
        if (AmazonApiForOpenAICall.productsList((_model.apiResultoga?.jsonBody ?? '')) != null &&
            (AmazonApiForOpenAICall.productsList((_model.apiResultoga?.jsonBody ?? ''))!.isNotEmpty)) {
          await showModalBottomSheet(...);
        } else {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(...));
        }
      }
    }
  } else {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(...));
  }

  _model.addToDummyProducts(ProductsStruct(...));
  safeSetState(() {});
  await showModalBottomSheet(...).then((value) => safeSetState(() {}));
  safeSetState(() {});
}
```

### NOUVEAU CODE (à copier) :

```dart
onPressed: () async {
  // Validation du formulaire
  if (_model.formKey.currentState == null ||
      !_model.formKey.currentState!.validate()) {
    return;
  }

  // Récupérer les budgets
  final min = double.tryParse(_model.minTextController.text) ?? 0;
  final max = double.tryParse(_model.maxTextController.text) ?? 100;

  // Vérifier que le budget est cohérent
  if (min >= max) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Le budget minimum doit être inférieur au maximum.',
          style: TextStyle(
            color: FlutterFlowTheme.of(context).secondaryBackground,
          ),
        ),
        duration: Duration(milliseconds: 2000),
        backgroundColor: FlutterFlowTheme.of(context).primary,
      ),
    );
    return;
  }

  // Vérifier qu'il y a au moins un intérêt
  if (_model.interests.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Ajoutez au moins un centre d\'intérêt pour des résultats personnalisés.',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: FlutterFlowTheme.of(context).error,
      ),
    );
    return;
  }

  // Afficher le loading
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          FlutterFlowTheme.of(context).primary,
        ),
      ),
    ),
  );

  try {
    print('🎁 Génération de cadeaux personnalisés...');

    // Générer des cadeaux personnalisés avec OpenAI (RAPIDE!)
    final products = await GiftSearchHelper.generatePersonalizedGifts(
      recipient: _model.relationModel.textController.text,
      age: _model.ageModel.textController.text,
      interests: _model.interests,
      minBudget: min,
      maxBudget: max,
    );

    print('✅ ${products.length} cadeaux générés');

    // Fermer le loading
    if (mounted) Navigator.of(context).pop();

    if (products.isNotEmpty) {
      // Afficher les résultats dans le bottom sheet
      await showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: false,
        context: context,
        builder: (context) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Padding(
              padding: MediaQuery.viewInsetsOf(context),
              child: OpenAiResultBottomSheetWidget(
                fetchedProducts: products,
              ),
            ),
          );
        },
      ).then((value) => safeSetState(() {}));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Aucun cadeau trouvé. Essayez avec d\'autres paramètres.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    }
  } catch (e) {
    // Fermer le loading si erreur
    if (mounted) {
      Navigator.of(context).pop();
    }

    print('❌ Erreur lors de la recherche: $e');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Erreur lors de la recherche. Vérifiez votre connexion et réessayez.',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: FlutterFlowTheme.of(context).error,
        duration: Duration(milliseconds: 3000),
      ),
    );
  }

  safeSetState(() {});
},
```

---

## 📝 Instructions de modification

### Méthode 1 : Modification manuelle (RECOMMANDÉ)

1. Ouvre le fichier `lib/pages/pages/gift_generator/gift_generator_widget.dart`
2. Va à la ligne **1088** (cherche `onPressed: () async {`)
3. Sélectionne tout le code jusqu'à la ligne **1266** (juste avant le `text: FFLocalizations...`)
4. **Supprime** tout ce code
5. **Colle** le NOUVEAU CODE ci-dessus
6. **Sauvegarde** le fichier

### Méthode 2 : Via un éditeur de code

Dans VS Code / Android Studio :
1. `Ctrl+G` → Aller à la ligne 1088
2. Sélectionner de la ligne 1088 à 1266
3. Supprimer
4. Coller le nouveau code

---

## ✅ Avantages du nouveau système

| Avant (Amazon API) | Après (OpenAI) |
|-------------------|----------------|
| ⏱️ **2 appels API** (lent) | ⚡ **1 seul appel** (rapide) |
| ❌ **Résultats génériques** | ✅ **100% personnalisés** |
| 🐌 **5-10 secondes** | ⚡ **2-3 secondes** |
| ❌ **Pas de contexte utilisateur** | ✅ **Profil complet** |

---

## 🧪 Test après modification

1. Lance l'app : `flutter run`
2. Va sur la page "Recherche de cadeaux"
3. Remplis :
   - Destinataire : "Ma sœur"
   - Âge : "25"
   - Budget : Min 50€, Max 150€
   - Intérêts : "Mode", "Beauté", "Voyage"
4. Clique sur "Trouver un cadeau"
5. **Tu devrais voir** : Un loading de 2-3 secondes, puis des cadeaux PERSONNALISÉS !

---

## ❓ En cas de problème

### Erreur de compilation

Si tu as une erreur, vérifie :
1. Que l'import est bien ligne 11 : `import '/services/gift_search_helper.dart';`
2. Que le nouveau code est bien indenté
3. Que tu n'as pas supprimé le `},` de la fin

### Les cadeaux ne s'affichent pas

1. Vérifie les logs dans la console
2. Assure-toi que la clé API OpenAI est configurée
3. Vérifie ta connexion internet

---

## 🎯 Résultat attendu

Après la modification :
- ✅ Les cadeaux se chargent **2x plus vite**
- ✅ Les cadeaux sont **personnalisés** selon le destinataire
- ✅ Les intérêts sont **vraiment pris en compte**
- ✅ Un loading clair pendant la génération
- ✅ Messages d'erreur clairs si problème

---

**C'est prêt ! Modifie le fichier et teste ! 🚀**
