# 🔑 Configuration de la Clé API OpenAI

## Pourquoi l'API ne fonctionne pas ?

La clé API OpenAI actuelle dans le code est **expirée ou invalide**. Même si tu as des crédits OpenAI, tu dois mettre à jour la clé dans le code.

## Comment obtenir ta nouvelle clé API ?

1. Va sur https://platform.openai.com/api-keys
2. Connecte-toi avec ton compte OpenAI
3. Clique sur "Create new secret key"
4. Copie la clé (elle commence par `sk-...`)

## Comment mettre à jour la clé dans l'application ?

### Option 1 : Modifier directement le code (Simple)

Ouvre le fichier `lib/services/openai_service.dart` et remplace la ligne 21 :

```dart
const apiKeyPlaceholder = 'YOUR_OPENAI_API_KEY_HERE';
```

Par :

```dart
const apiKeyPlaceholder = 'sk-proj-VOTRE_NOUVELLE_CLE_ICI';
```

### Option 2 : Utiliser un fichier d'environnement (Recommandé)

1. Crée le fichier `assets/environment_values/environment.json`
2. Ajoute :

```json
{
  "openAiApiKey": "sk-proj-VOTRE_NOUVELLE_CLE_ICI"
}
```

3. Redémarre l'application

## Vérification

Une fois la clé mise à jour, les cadeaux devraient se charger correctement ! ✅

## En cas de problème

Si tu continues à avoir des problèmes :
1. Vérifie que tu as des crédits OpenAI sur ton compte
2. Vérifie que la clé est bien copiée sans espaces
3. Redémarre complètement l'application
