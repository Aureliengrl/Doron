# 🎁 Doron - Système d'Affiliation

Système automatisé pour récupérer des produits depuis **Amazon Associates**, **Awin** et **CJ Affiliate**, les transformer vers le schéma Doron, et les uploader dans Firestore.

## 🎯 Avantages

✅ **Images 100% officielles** - Les marques fournissent leurs propres images
✅ **Produits réels** - Vrais bestsellers avec prix réels
✅ **URLs d'affiliation** - Tu gagnes des commissions sur chaque vente
✅ **Synchronisation auto** - Mise à jour automatique des produits
✅ **300+ marques** - Apple, Nike, Zara, H&M, Dyson, etc.

## 📋 Ce que tu dois faire

### 1. Inscriptions aux programmes d'affiliation

#### A. Amazon Associates (OBLIGATOIRE)
1. Va sur https://partenaires.amazon.fr/
2. Crée un compte
3. Remplis les informations de ton site/app
4. Note ton **Partner Tag** (ex: `doronapp-21`)
5. Pour accéder à l'API complète (PA-API):
   - Option 1: Faire 3 ventes qualifiées dans les 180 premiers jours
   - Option 2: Attendre 180 jours
   - En attendant: utilise Product Links (limitation mais fonctionne)

#### B. Awin (Pour fashion: Zara, H&M, Mango, etc.)
1. Va sur https://www.awin.com/fr/affilies
2. Crée un compte publisher
3. Candidater aux programmes:
   - Zara, H&M, Mango, ASOS, Zalando
   - Sandro, Maje, Claudie Pierlot, ba&sh
   - Sephora, IKEA, Maisons du Monde
4. Attends l'approbation (peut prendre quelques jours)
5. Une fois approuvé, récupère:
   - **API Token** (dans "Account" → "API Access")
   - **Publisher ID** (ton ID publisher)
   - **Advertiser IDs** de chaque marque

#### C. CJ Affiliate (Pour Nike, Sephora USA, etc.)
1. Va sur https://www.cj.com/
2. Crée un compte publisher
3. Candidater aux programmes Nike, Adidas, Under Armour, Sephora
4. Récupère:
   - **API Token** (dans "Account" → "Web Services")
   - **Website ID**
   - **Advertiser IDs**

### 2. Configuration

#### A. Copie le template .env
```bash
cd scripts/affiliate
cp .env.example .env
```

#### B. Remplis le fichier .env
```bash
# Amazon Associates
AMAZON_ACCESS_KEY=AKIAIOSFODNN7EXAMPLE
AMAZON_SECRET_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
AMAZON_PARTNER_TAG=doronapp-21

# Awin
AWIN_API_TOKEN=ton_token_awin_ici
AWIN_PUBLISHER_ID=123456

# CJ Affiliate
CJ_API_TOKEN=ton_token_cj_ici
CJ_WEBSITE_ID=789012
```

#### C. Remplis les Advertiser IDs

Édite `awin_fetcher.py` ligne 63:
```python
advertiser_ids = {
    "Zara": "12345",      # Remplace par le vrai ID
    "H&M": "67890",       # Remplace par le vrai ID
    "ASOS": "3306",       # Exemple réel
    # etc.
}
```

Édite `cj_fetcher.py` ligne 63:
```python
advertiser_ids = {
    "Nike": "12345",      # Remplace par le vrai ID
    "Adidas": "67890",    # Remplace par le vrai ID
    # etc.
}
```

### 3. Installation des dépendances

```bash
cd scripts/affiliate
pip3 install -r requirements.txt
```

## 🚀 Utilisation

### Test sans upload (recommandé pour la première fois)
```bash
python3 main.py --dry-run --save-json test_products.json
```

### Récupérer seulement Amazon
```bash
python3 main.py --source amazon --max-per-brand 10
```

### Récupérer seulement Awin (fashion)
```bash
python3 main.py --source awin --max-per-brand 10
```

### Récupérer TOUT et uploader dans Firestore
```bash
python3 main.py --source all --max-per-brand 10
```

### Vider la collection avant upload
```bash
python3 main.py --clear --source all
```

### Synchronisation complète (production)
```bash
python3 main.py --source all --max-per-brand 15 --save-json backup.json
```

## 📊 Structure des fichiers

```
scripts/affiliate/
├── .env.example           # Template configuration
├── .env                   # Ta configuration (à créer)
├── requirements.txt       # Dépendances Python
├── config.py             # Configuration centrale
├── amazon_fetcher.py     # Récupère depuis Amazon PA-API
├── awin_fetcher.py       # Récupère depuis Awin
├── cj_fetcher.py         # Récupère depuis CJ
├── doron_transformer.py  # Transforme vers schéma Doron
├── firestore_uploader.py # Upload vers Firestore
├── main.py              # Script principal
└── README.md            # Ce fichier
```

## 🎁 Schéma Produit Doron

```json
{
  "id": 1,
  "name": "iPhone 15 Pro 128GB",
  "brand": "Apple",
  "price": 1229,
  "url": "https://www.amazon.fr/dp/B0CHX3TW6F?tag=doronapp-21",
  "image": "https://m.media-amazon.com/images/I/81SigpJN1KL._AC_SX679_.jpg",
  "description": "iPhone 15 Pro avec puce A17 Pro",
  "categories": ["tech"],
  "tags": ["homme", "femme", "30-50ans", "budget_200+", "tech"],
  "popularity": 95
}
```

## 🏷️ Tags automatiques

Le système génère automatiquement:

### Genre
- `homme` / `femme` (basé sur le nom et la catégorie)

### Âge
- `20-30ans` (prix < 50€)
- `30-50ans` (prix 50-200€)
- `50+` (prix > 200€)

### Budget
- `budget_0-50`
- `budget_50-100`
- `budget_100-200`
- `budget_200+`

### Catégorie
- `tech`, `fashion`, `sports`, `beauty`, `home`

### Style
- `casual`, `sport`, `elegant`, `tech`

## ⚡ Automatisation (Optionnel)

### Cron job (Linux/Mac)
```bash
# Synchronise tous les jours à 3h du matin
0 3 * * * cd /path/to/Doron/scripts/affiliate && python3 main.py --source all
```

### GitHub Actions (CI/CD)
Crée `.github/workflows/sync-products.yml`:
```yaml
name: Sync Products
on:
  schedule:
    - cron: '0 3 * * *'  # Tous les jours à 3h
  workflow_dispatch:      # Permet déclenchement manuel

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: '3.10'
      - run: pip install -r scripts/affiliate/requirements.txt
      - run: python3 scripts/affiliate/main.py --source all
        env:
          AMAZON_ACCESS_KEY: ${{ secrets.AMAZON_ACCESS_KEY }}
          AMAZON_SECRET_KEY: ${{ secrets.AMAZON_SECRET_KEY }}
          AMAZON_PARTNER_TAG: ${{ secrets.AMAZON_PARTNER_TAG }}
          AWIN_API_TOKEN: ${{ secrets.AWIN_API_TOKEN }}
          AWIN_PUBLISHER_ID: ${{ secrets.AWIN_PUBLISHER_ID }}
          CJ_API_TOKEN: ${{ secrets.CJ_API_TOKEN }}
          CJ_WEBSITE_ID: ${{ secrets.CJ_WEBSITE_ID }}
```

## 🐛 Troubleshooting

### "Configuration incomplète"
→ Vérifie que ton `.env` est bien rempli

### "Amazon API Error 403"
→ Tu n'as pas encore accès à PA-API. Attends 3 ventes ou 180 jours

### "Awin API Error 401"
→ Token invalide. Vérifie dans ton compte Awin

### "Aucun produit récupéré pour X"
→ Tu n'as pas été approuvé pour ce programme. Candidater d'abord

### "Firestore Error"
→ Vérifie que `google-services.json` existe et est valide

## 📞 Support

Questions? Vérifie:
1. La documentation Amazon Associates: https://webservices.amazon.fr/paapi5/documentation/
2. La documentation Awin: https://wiki.awin.com/index.php/Product_Feed_API
3. La documentation CJ: https://developers.cj.com/

## ✅ Checklist avant production

- [ ] Inscrit aux 3 programmes (Amazon, Awin, CJ)
- [ ] Récupéré tous les tokens/clés API
- [ ] Rempli le fichier `.env`
- [ ] Rempli les Advertiser IDs dans les fetchers
- [ ] Testé en mode `--dry-run`
- [ ] Vérifié les produits dans le JSON généré
- [ ] Premier upload réussi vers Firestore
- [ ] Vérifié les produits dans Firebase Console
- [ ] Configuré l'automatisation (optionnel)

Bon courage! 🚀
