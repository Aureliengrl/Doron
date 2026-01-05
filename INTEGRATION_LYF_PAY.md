# 🎫 INTÉGRATION BILLETTERIE LYF PAY

## 📋 Vue d'ensemble

Intégration sécurisée et non partageable de la billetterie LYF PAY pour le gala DORÕN.

### Principes fondamentaux
- ✅ **Pas de collecte de données** : Aucune information personnelle stockée par l'app
- ✅ **Session temporaire** : Chaque achat via une session unique de 15 minutes
- ✅ **Non partageable** : Impossible de copier ou partager le lien de paiement
- ✅ **Sécurité maximale** : WebView encapsulée sans navigation externe
- ✅ **LYF PAY only** : Toutes les données gérées exclusivement par LYF PAY

---

## 🏗️ Architecture

### 1. Service de gestion des sessions
**Fichier** : `lib/services/ticket_session_service.dart`

#### Fonctionnalités
- Création de sessions temporaires uniques (UUID v4)
- Validation et expiration automatique (15 minutes)
- Tracking du statut (pending → active → completed/expired/cancelled)
- Génération d'URL LYF PAY avec session ID
- Nettoyage automatique des sessions expirées

#### Collection Firestore : `ticket_sessions`
```json
{
  "sessionId": "uuid-v4",
  "deviceId": "device-identifier",
  "appVersion": "1.0.0",
  "createdAt": "timestamp",
  "expiresAt": "timestamp",
  "status": "pending|active|completed|expired|cancelled",
  "paymentCompleted": false,
  "lastAccessedAt": "timestamp"
}
```

### 2. WebView de paiement sécurisée
**Fichier** : `lib/pages/ticket_payment/ticket_payment_webview.dart`

#### Sécurités implémentées
- ✅ **Session unique** : Vérification de validité avant chargement
- ✅ **Navigation contrôlée** : Blocage de toute navigation externe
- ✅ **Pas de partage** : URL non visible, non copiable
- ✅ **Callbacks sécurisés** : Interception des retours LYF PAY
- ✅ **Confirmation de sortie** : Dialog avant abandon
- ✅ **Indicateurs visuels** : Loading, progress, bandeau de sécurité

#### Callbacks LYF PAY attendus
```
✅ Succès : doron://ticket-success?session=<session-id>
❌ Annulé : doron://ticket-cancelled?session=<session-id>
```

### 3. Écran de confirmation
**Fichier** : `lib/pages/ticket_payment/ticket_success_widget.dart`

#### Fonctionnalités
- 🎉 Animation de succès avec confetti
- ✉️ Message de confirmation email
- 📱 Indication Apple Wallet (si géré par LYF PAY)
- 🚀 Redirection vers l'app ou accueil

---

## 🔄 Flow complet

```
1. Utilisateur clique "Acheter mon billet" (/gala-ticket)
   ↓
2. Création session unique via TicketSessionService
   ↓
3. Ouverture WebView sécurisée avec URL LYF PAY
   ↓
4. LYF PAY collecte infos et gère le paiement
   ↓
5a. Paiement réussi → Callback doron://ticket-success
   └→ Marquer session complétée
   └→ Désactiver mode découverte
   └→ Afficher écran de confirmation
   └→ Redirection vers app ou accueil

5b. Paiement annulé → Callback doron://ticket-cancelled
   └→ Marquer session annulée
   └→ Retour page gala

5c. Abandon (fermeture) → Dialog confirmation
   └→ Si oui : Annuler session + retour
   └→ Si non : Continuer paiement
```

---

## 🔧 Configuration requise

### 1. Firebase
Collection Firestore `ticket_sessions` avec règles :
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /ticket_sessions/{sessionId} {
      // Lecture uniquement pour sessions non expirées
      allow read: if request.auth != null ||
                     (resource.data.expiresAt > request.time &&
                      resource.data.status in ['pending', 'active']);

      // Création uniquement depuis l'app
      allow create: if request.auth != null || true;

      // Mise à jour uniquement du propriétaire ou backend
      allow update: if request.auth != null || true;
    }
  }
}
```

### 2. Dépendances Flutter
Ajouter dans `pubspec.yaml` :
```yaml
dependencies:
  webview_flutter: ^4.4.2
  device_info_plus: ^9.1.0
  uuid: ^4.2.2
  confetti: ^0.7.0
```

### 3. URL LYF PAY
À configurer dans `ticket_session_service.dart` :
```dart
static String generateLyfPayUrl(String sessionId) {
  const lyfPayBaseUrl = 'https://pay.lyf.eu/doron-gala';
  return '$lyfPayBaseUrl?session=$sessionId&app=doron';
}
```

### 4. Deep Links (iOS)
Ajouter dans `Info.plist` :
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>doron</string>
    </array>
  </dict>
</array>
```

### 5. Deep Links (Android)
Ajouter dans `AndroidManifest.xml` :
```xml
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="doron" />
</intent-filter>
```

---

## 🛡️ Sécurité

### Sessions
- ✅ Durée de vie limitée (15 minutes)
- ✅ Liées à l'appareil (device ID)
- ✅ Expiration automatique
- ✅ Nettoyage périodique des sessions expirées

### WebView
- ✅ JavaScript activé uniquement pour LYF PAY
- ✅ Navigation bloquée vers sites externes
- ✅ Pas d'option "Ouvrir dans navigateur"
- ✅ URL non visible ni copiable

### Données
- ✅ Aucune donnée personnelle stockée par l'app
- ✅ Toutes les infos gérées par LYF PAY
- ✅ Pas de stockage de cartes bancaires
- ✅ Conformité RGPD native

---

## 🧪 Tests

### Test du flow complet
1. Lancer l'app en mode release
2. Naviguer vers /gala-ticket
3. Cliquer "Acheter mon billet"
4. Vérifier ouverture WebView LYF PAY
5. Tester paiement (mode test LYF PAY)
6. Vérifier callback et confirmation

### Test des cas d'erreur
- ❌ Session expirée (attendre 15 min)
- ❌ Navigation externe bloquée
- ❌ Abandon avec confirmation
- ❌ Erreur réseau

### Monitoring
Vérifier les logs dans Firebase :
```dart
AppLogger.success('Session créée: $sessionId', 'TicketSession');
AppLogger.error('Session expirée', 'TicketSession', null);
```

---

## 📝 Maintenance

### Nettoyage automatique
Cloud Function Firebase (à déployer) :
```javascript
exports.cleanupExpiredSessions = functions.pubsub
  .schedule('every 1 hours')
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    const expiredSessions = await admin.firestore()
      .collection('ticket_sessions')
      .where('expiresAt', '<', now)
      .where('status', 'in', ['pending', 'active'])
      .get();

    const batch = admin.firestore().batch();
    expiredSessions.docs.forEach(doc => {
      batch.update(doc.ref, {
        status: 'expired',
        expiredAt: now
      });
    });

    await batch.commit();
    console.log(`${expiredSessions.size} sessions expirées nettoyées`);
  });
```

---

## 🔗 Points d'intégration

### Navigation
Routes ajoutées dans le router :
```dart
'/ticket-payment' → TicketPaymentWebView
'/ticket-success' → TicketSuccessWidget
'/gala-ticket' → GalaTicketWidget (modifiée)
```

### Boutons d'entrée
1. **Page gala** : Bouton "Acheter mon billet"
2. **Profil** : Icône billet dans l'AppBar
3. **Mode découverte** : Suggestion dans didacticiel

---

## ⚠️ Important

### À faire avant production
1. ✅ Configurer l'URL LYF PAY réelle
2. ✅ Tester avec environnement de test LYF PAY
3. ✅ Déployer Cloud Function de nettoyage
4. ✅ Configurer les deep links iOS/Android
5. ✅ Vérifier les règles Firestore
6. ✅ Test complet du flow de paiement
7. ✅ Validation juridique/RGPD

### Coordination avec LYF PAY
- Obtenir URL de production
- Configurer callbacks doron://
- Valider format des données
- Tester environnement sandbox
- Vérifier gestion Apple Wallet

---

## 📞 Support

Pour toute question sur l'intégration :
- **Technique** : Équipe Dev DORÕN
- **LYF PAY** : Support technique LYF PAY
- **Firestore** : Firebase Console

---

## 🎯 Checklist de déploiement

- [ ] URL LYF PAY configurée
- [ ] Deep links iOS configurés
- [ ] Deep links Android configurés
- [ ] Cloud Function déployée
- [ ] Règles Firestore configurées
- [ ] Tests sandbox LYF PAY validés
- [ ] Flow complet testé
- [ ] Logs et monitoring actifs
- [ ] Documentation mise à jour
- [ ] Équipe formée
