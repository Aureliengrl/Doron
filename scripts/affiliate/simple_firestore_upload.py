#!/usr/bin/env python3
"""
Upload simple vers Firestore sans dépendances complexes
Utilise les REST API de Firestore
"""
import json
import requests
import os

def upload_to_firestore_rest():
    """Upload via REST API Firestore"""

    print("=" * 70)
    print("📤 UPLOAD VERS FIRESTORE (REST API)")
    print("=" * 70)
    print()

    # Charger les produits
    print("📂 Chargement des produits...")
    with open('/home/user/Doron/assets/jsons/fallback_products.json', 'r', encoding='utf-8') as f:
        products = json.load(f)

    print(f"✅ {len(products)} produits chargés\n")

    # Charger google-services.json pour récupérer project_id
    print("🔑 Lecture de la configuration Firebase...")
    try:
        with open('/home/user/Doron/android/app/google-services.json', 'r') as f:
            firebase_config = json.load(f)
            project_id = firebase_config['project_info']['project_id']
            print(f"✅ Project ID: {project_id}\n")
    except Exception as e:
        print(f"❌ Erreur lecture google-services.json: {e}")
        print("\n💡 Tu peux aussi entrer manuellement ton Project ID:")
        project_id = input("Project ID Firebase: ").strip()
        if not project_id:
            return False

    # URL de base Firestore REST API
    base_url = f"https://firestore.googleapis.com/v1/projects/{project_id}/databases/(default)/documents"

    print("⚠️ IMPORTANT:")
    print("Pour utiliser l'API REST Firestore, tu dois:")
    print("1. Aller sur https://console.firebase.google.com")
    print("2. Sélectionner ton projet")
    print("3. Aller dans 'Project Settings' → 'Service Accounts'")
    print("4. Cliquer sur 'Generate new private key'")
    print("5. Télécharger le fichier JSON")
    print("6. Le placer ici: /home/user/Doron/scripts/affiliate/firebase-key.json")
    print()

    # Vérifier si la clé existe
    key_path = '/home/user/Doron/scripts/affiliate/firebase-key.json'
    if not os.path.exists(key_path):
        print(f"❌ Fichier de clé non trouvé: {key_path}")
        print("\nTélécharge la clé et réessaye.")
        return False

    # Alternative: Utiliser gcloud auth
    print("💡 ALTERNATIVE PLUS SIMPLE:")
    print("Utilise plutôt l'Admin Page de ton app Flutter!")
    print()
    print("Code pour l'Admin Page:")
    print("-" * 70)
    print("""
// Dans lib/pages/admin/admin_products_page.dart

Future<void> importProductsFromJson() async {
  try {
    // 1. Charger le fichier JSON
    String jsonString = await rootBundle.loadString('assets/jsons/fallback_products.json');
    List<dynamic> productsJson = json.decode(jsonString);

    // 2. Upload vers Firestore
    final batch = FirebaseFirestore.instance.batch();

    for (var productData in productsJson) {
      final docRef = FirebaseFirestore.instance
          .collection('products')
          .doc(productData['id'].toString());

      batch.set(docRef, productData);
    }

    // 3. Commit
    await batch.commit();

    print('✅ ${productsJson.length} produits importés!');

  } catch (e) {
    print('❌ Erreur import: $e');
  }
}

// Ajouter un bouton dans le UI:
ElevatedButton(
  onPressed: importProductsFromJson,
  child: Text('Import 447 produits depuis JSON'),
)
    """)
    print("-" * 70)
    print()

    return True

if __name__ == "__main__":
    upload_to_firestore_rest()
