# Instructions pour supprimer tous les utilisateurs Firebase

## ⚠️ ATTENTION
Cette opération supprimera **TOUS** les utilisateurs de Firebase Authentication ET de Firestore.
**Cette action est IRRÉVERSIBLE!**

## Étape 1: Déployer la Cloud Function

```bash
# Depuis le répertoire racine du projet
firebase deploy --only functions:deleteAllUsers --project doron-b3011
```

## Étape 2: Appeler la Cloud Function

Une fois déployée, récupère l'URL de la fonction dans la console Firebase Functions, puis:

### Option A: Utiliser curl (Terminal)

```bash
curl -X POST https://us-central1-doron-b3011.cloudfunctions.net/deleteAllUsers \
  -H "Content-Type: application/json" \
  -d '{"confirmationKey": "DELETE_ALL_USERS_CONFIRMED"}'
```

### Option B: Utiliser un outil comme Postman

- **Method**: POST
- **URL**: `https://us-central1-doron-b3011.cloudfunctions.net/deleteAllUsers`
- **Headers**:
  - `Content-Type: application/json`
- **Body** (raw JSON):
```json
{
  "confirmationKey": "DELETE_ALL_USERS_CONFIRMED"
}
```

### Option C: Alternative RAPIDE - Firebase Console

Si tu préfères ne pas déployer de Cloud Function, tu peux supprimer manuellement:

1. **Firebase Authentication**:
   - Ouvre la Console Firebase
   - Va dans Authentication > Users
   - Sélectionne tous les utilisateurs (checkbox en haut)
   - Clique sur "Delete selected users"

2. **Firestore Users Collection**:
   - Va dans Firestore Database
   - Ouvre la collection "Users"
   - Supprime tous les documents (ou supprime la collection entière)

## Résultat attendu

La fonction retournera un JSON avec:
```json
{
  "success": true,
  "message": "Tous les utilisateurs ont été supprimés",
  "details": {
    "authUsersDeleted": 42,
    "firestoreDocsDeleted": 42,
    "errors": null
  }
}
```

## Vérification

Après la suppression:
1. Va dans Firebase Console > Authentication
2. Vérifie qu'il n'y a plus d'utilisateurs
3. Va dans Firestore > Users
4. Vérifie que la collection est vide

---

## Après la suppression

Tous les nouveaux utilisateurs qui installeront l'app devront:
1. Créer un nouveau compte (email/password, Google, ou Apple)
2. Compléter l'onboarding
3. Leurs données seront stockées dans Firebase

Les logs de debug ajoutés dans le code te permettront de voir exactement ce qui se passe pendant l'inscription/connexion dans la console de l'application.
