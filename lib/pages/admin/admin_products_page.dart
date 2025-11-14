import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class AdminProductsPage extends StatefulWidget {
  const AdminProductsPage({Key? key}) : super(key: key);

  @override
  State<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
  bool _isLoading = false;
  String _statusMessage = '';
  int _totalProducts = 0;
  int _uploadedProducts = 0;

  Future<void> _importProductsFromJson() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Chargement du fichier JSON...';
      _uploadedProducts = 0;
    });

    try {
      // 1. Charger le fichier JSON depuis assets
      String jsonString = await rootBundle.loadString('assets/jsons/fallback_products.json');
      List<dynamic> productsJson = json.decode(jsonString);

      setState(() {
        _totalProducts = productsJson.length;
        _statusMessage = 'Trouvé ${productsJson.length} produits. Upload en cours...';
      });

      // 2. Upload vers Firestore par batch (500 produits max par batch)
      final firestore = FirebaseFirestore.instance;
      const batchSize = 500;

      for (int i = 0; i < productsJson.length; i += batchSize) {
        final batch = firestore.batch();
        final end = (i + batchSize < productsJson.length) ? i + batchSize : productsJson.length;

        for (int j = i; j < end; j++) {
          final productData = productsJson[j];

          // Créer la référence du document
          final docRef = firestore.collection('products').doc(productData['id'].toString());

          // Ajouter au batch
          batch.set(docRef, {
            'id': productData['id'],
            'name': productData['name'],
            'brand': productData['brand'],
            'price': productData['price'],
            'url': productData['url'],
            'image': productData['image'],
            'description': productData['description'],
            'categories': List<String>.from(productData['categories']),
            'tags': List<String>.from(productData['tags']),
            'popularity': productData['popularity'],
          });
        }

        // Commit le batch
        await batch.commit();

        setState(() {
          _uploadedProducts = end;
          _statusMessage = 'Uploadé ${end}/${productsJson.length} produits...';
        });
      }

      // 3. Succès
      setState(() {
        _isLoading = false;
        _statusMessage = '✅ ${productsJson.length} produits importés avec succès!';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${productsJson.length} produits importés!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '❌ Erreur: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _clearAllProducts() async {
    // Confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Attention'),
        content: const Text('Êtes-vous sûr de vouloir supprimer TOUS les produits de Firestore?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer tout'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Suppression en cours...';
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final productsSnapshot = await firestore.collection('products').get();

      final batch = firestore.batch();
      for (final doc in productsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      setState(() {
        _isLoading = false;
        _statusMessage = '✅ ${productsSnapshot.docs.length} produits supprimés';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Tous les produits ont été supprimés'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '❌ Erreur: $e';
      });
    }
  }

  Future<int> _getProductCount() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('products').get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Produits'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            const Text(
              'Gestion des Produits',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Import et gestion des produits Firestore',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // Stats
            FutureBuilder<int>(
              future: _getProductCount(),
              builder: (context, snapshot) {
                final count = snapshot.data ?? 0;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text('Produits dans Firestore', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Text(
                          '$count',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Import Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _importProductsFromJson,
              icon: const Icon(Icons.upload_file),
              label: const Text('Importer 447 produits depuis JSON'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            // Clear Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _clearAllProducts,
              icon: const Icon(Icons.delete_forever),
              label: const Text('Supprimer tous les produits'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 24),

            // Status
            if (_isLoading)
              Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_statusMessage),
                  if (_totalProducts > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: LinearProgressIndicator(
                        value: _uploadedProducts / _totalProducts,
                      ),
                    ),
                ],
              )
            else if (_statusMessage.isNotEmpty)
              Card(
                color: _statusMessage.startsWith('✅') ? Colors.green[50] : Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _statusMessage,
                    style: TextStyle(
                      color: _statusMessage.startsWith('✅') ? Colors.green[900] : Colors.red[900],
                    ),
                  ),
                ),
              ),

            const Spacer(),

            // Info
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ℹ️ Information', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('• Fichier source: assets/jsons/fallback_products.json'),
                    Text('• 447 produits de 90 marques premium'),
                    Text('• Images 100% officielles'),
                    Text('• Tags automatiques générés'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
