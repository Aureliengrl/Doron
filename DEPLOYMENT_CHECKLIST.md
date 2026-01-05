# ✅ Checklist de Déploiement - Billetterie LYF PAY

## 📋 État Actuel

### ✅ Déjà Complété

- [x] **Service de session** (`lib/services/ticket_session_service.dart`)
  - Création de sessions temporaires (15 min)
  - Validation et expiration automatique
  - Liaison appareil-session pour sécurité

- [x] **WebView sécurisée** (`lib/pages/ticket_payment/ticket_payment_webview.dart`)
  - Intégration WebView Flutter
  - Blocage navigation externe
  - Interception des callbacks LYF PAY
  - Confirmation avant sortie

- [x] **Écran de succès** (`lib/pages/ticket_payment/ticket_success_widget.dart`)
  - Animation confetti
  - Désactivation mode découverte après achat
  - Redirections appropriées

- [x] **Page Gala** (`lib/pages/gala_ticket/gala_ticket_widget.dart`)
  - Informations complètes sur l'événement
  - Bouton "Acheter mon billet" → WebView sécurisée
  - Bouton "Mode découverte"

- [x] **Configuration Routing**
  - Routes GoRouter configurées pour toutes les pages
  - Deep links `doron://` déjà configurés (iOS + Android)

- [x] **Documentation complète**
  - `INTEGRATION_LYF_PAY.md` avec architecture détaillée
  - Ce checklist de déploiement

---

## 🚀 À Faire Avant Production

### 1. Configuration LYF PAY

- [ ] **Obtenir URL de production LYF PAY**
  - Fichier: `lib/services/ticket_session_service.dart:173`
  - Remplacer: `https://pay.lyf.eu/doron-gala` par l'URL réelle

- [ ] **Configurer les callbacks**
  - Vérifier que LYF PAY redirige vers:
    - Success: `doron://ticket-success?session={sessionId}`
    - Cancelled: `doron://ticket-cancelled?session={sessionId}`

- [ ] **Tester en environnement sandbox**
  - Demander URL sandbox à LYF PAY
  - Tester un paiement complet de bout en bout
  - Vérifier callbacks et redirections

### 2. Firebase Configuration

- [ ] **Règles de sécurité Firestore**
  ```javascript
  match /ticket_sessions/{sessionId} {
    // Seuls les Cloud Functions peuvent écrire
    allow read: if request.auth != null &&
                   resource.data.deviceId == request.resource.data.deviceId;
    allow write: if false; // Seulement via Cloud Functions
  }
  ```

- [ ] **Déployer Cloud Function de nettoyage**
  - Fichier à créer: `functions/cleanupSessions.js`
  - Code fourni dans `INTEGRATION_LYF_PAY.md`
  - Scheduler: toutes les heures
  - Commande: `firebase deploy --only functions:cleanupTicketSessions`

- [ ] **Index Firestore**
  ```
  Collection: ticket_sessions
  Index composé:
    - expiresAt (Ascending)
    - status (Ascending)
  ```

### 3. Configuration iOS

- [x] **Deep Links** (déjà configuré dans `ios/Runner/Info.plist`)
  - URL Scheme: `doron`
  - FlutterDeepLinkingEnabled: `true`

- [ ] **Tester sur appareil iOS réel**
  - Ouvrir WebView LYF PAY
  - Vérifier redirection après paiement
  - Tester callback success et cancelled

### 4. Configuration Android

- [x] **Deep Links** (déjà configuré dans `android/app/src/main/AndroidManifest.xml`)
  - Scheme: `doron`
  - Host: `doron.com`
  - flutter_deeplinking_enabled: `true`

- [ ] **Tester sur appareil Android réel**
  - Ouvrir WebView LYF PAY
  - Vérifier redirection après paiement
  - Tester callback success et cancelled

### 5. Tests Fonctionnels

- [ ] **Scénario 1: Achat réussi**
  1. Ouvrir `/gala-ticket`
  2. Cliquer "Acheter mon billet"
  3. WebView s'ouvre avec session unique
  4. Compléter paiement (sandbox)
  5. Vérifier redirection vers `/ticket-success`
  6. Vérifier confetti + message
  7. Vérifier mode découverte désactivé
  8. Vérifier session marquée "completed" dans Firestore

- [ ] **Scénario 2: Annulation**
  1. Ouvrir `/gala-ticket`
  2. Cliquer "Acheter mon billet"
  3. Cliquer bouton retour dans WebView
  4. Confirmer sortie
  5. Vérifier retour à `/gala-ticket`
  6. Vérifier session marquée "cancelled" dans Firestore

- [ ] **Scénario 3: Expiration session**
  1. Créer session
  2. Attendre 16 minutes
  3. Tenter validation
  4. Vérifier erreur "Session expirée"
  5. Vérifier session marquée "expired" dans Firestore

- [ ] **Scénario 4: Navigation externe bloquée**
  1. Dans WebView paiement
  2. Tenter lien externe (ex: google.com)
  3. Vérifier blocage navigation
  4. Vérifier log warning dans console

- [ ] **Scénario 5: Mode découverte**
  1. Cliquer "Explorer l'app en mode invité"
  2. Vérifier accès app sans connexion
  3. Acheter un billet
  4. Vérifier désactivation mode découverte
  5. Vérifier accès complet à l'app

### 6. Sécurité

- [ ] **Vérifier absence de logs sensibles**
  - Pas de session IDs en clair dans logs production
  - Utiliser `AppLogger` qui désactive en production

- [ ] **Test tentative de partage**
  - Copier URL session depuis WebView → doit être impossible
  - Tenter réutilisation session expirée → doit échouer
  - Tenter session d'un autre appareil → doit échouer

- [ ] **Audit sécurité**
  - Aucune donnée personnelle stockée dans l'app ✅
  - Toutes données gérées par LYF PAY ✅
  - Sessions non-partageables ✅
  - Navigation externe bloquée ✅

### 7. Performance

- [ ] **Vérifier temps de chargement WebView**
  - Cible: < 3 secondes
  - Optimiser si nécessaire

- [ ] **Tester sur connexion lente**
  - Vérifier loading indicators
  - Vérifier timeout handling

### 8. RGPD & Légal

- [ ] **Politique de confidentialité**
  - Mentionner intégration LYF PAY
  - Clarifier que l'app ne collecte aucune donnée de paiement
  - Lien vers politique LYF PAY

- [ ] **CGU/CGV**
  - Conditions de vente pour le gala
  - Politique de remboursement
  - Coordonnées support

### 9. Monitoring

- [ ] **Configurer Firebase Analytics**
  - Événement: `ticket_payment_started`
  - Événement: `ticket_payment_completed`
  - Événement: `ticket_payment_cancelled`
  - Événement: `ticket_payment_failed`

- [ ] **Alertes Firestore**
  - Alertes si > 100 sessions actives simultanées
  - Alertes si taux d'échec > 10%

### 10. Support & Documentation

- [ ] **FAQ Utilisateur**
  - Comment acheter un billet ?
  - Que faire si le paiement échoue ?
  - Où trouver mon billet après achat ?
  - Support Apple Wallet (si disponible)

- [ ] **Runbook Technique**
  - Comment vérifier état d'une session ?
  - Comment rembourser un utilisateur ?
  - Comment debugger un problème de callback ?

---

## 📞 Contacts LYF PAY

**À obtenir avant déploiement:**
- [ ] Email support technique LYF PAY
- [ ] Téléphone hotline urgence
- [ ] URL dashboard LYF PAY
- [ ] Credentials API (si nécessaire)

---

## 🎯 Commandes Utiles

### Build & Test
```bash
# iOS
flutter build ios --release
flutter run --release -d iPhone

# Android
flutter build apk --release
flutter run --release -d android
```

### Firebase
```bash
# Déployer Cloud Functions
firebase deploy --only functions

# Vérifier règles Firestore
firebase firestore:rules
```

### Git
```bash
# Créer PR depuis cette branche
gh pr create --title "Intégration billetterie LYF PAY" \
             --body "Intégration complète du système de billetterie sécurisé"
```

---

## 📊 Métriques de Succès

- [ ] **Taux de conversion**: > 60% (sessions → paiements complétés)
- [ ] **Taux d'erreur**: < 5%
- [ ] **Temps moyen paiement**: < 2 minutes
- [ ] **Support tickets**: < 10/semaine

---

## 🎉 Déploiement Final

- [ ] Merge PR vers `main`
- [ ] Tag version: `git tag v1.3.0-gala-tickets`
- [ ] Deploy iOS: `flutter build ios --release`
- [ ] Deploy Android: `flutter build apk --release`
- [ ] Soumettre App Store
- [ ] Soumettre Play Store
- [ ] Communiquer lancement gala sur réseaux sociaux

---

**Date de dernière mise à jour**: 2026-01-05
**Branche**: `claude/app-testing-audit-kKgRw`
**Status**: ✅ Code complet, prêt pour configuration LYF PAY et tests
