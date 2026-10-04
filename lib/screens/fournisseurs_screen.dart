import 'package:flutter/material.dart';
import '../models/fournisseur.dart';
import '../services/database_service.dart';

class FournisseursScreen extends StatefulWidget {
  const FournisseursScreen({super.key});

  @override
  State<FournisseursScreen> createState() => _FournisseursScreenState();
}

class _FournisseursScreenState extends State<FournisseursScreen> {
  final DatabaseService _db = DatabaseService();
  List<Fournisseur> _fournisseurs = [];

  @override
  void initState() {
    super.initState();
    _chargerFournisseurs();
  }

  Future<void> _chargerFournisseurs() async {
    final fournisseurs = await _db.obtenirFournisseurs();
    setState(() {
      _fournisseurs = fournisseurs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fournisseurs')),
      body: _fournisseurs.isEmpty
          ? const Center(child: Text('Aucun fournisseur'))
          : ListView.builder(
              itemCount: _fournisseurs.length,
              itemBuilder: (context, index) {
                final fournisseur = _fournisseurs[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.business)),
                    title: Text(fournisseur.nom),
                    subtitle: Text(
                      '${fournisseur.telephone}\n${fournisseur.email}',
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await _db.supprimerFournisseur(fournisseur.id!);
                        _chargerFournisseurs();
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _ajouterFournisseur(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _ajouterFournisseur(BuildContext context) {
    final nomController = TextEditingController();
    final telController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ajouter un fournisseur'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: telController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final fournisseur = Fournisseur(
                  nom: nomController.text,
                  telephone: telController.text,
                  email: emailController.text,
                );
                await _db.ajouterFournisseur(fournisseur);
                Navigator.of(dialogContext).pop();
                await _chargerFournisseurs();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fournisseur ajouté !')),
                  );
                }
              } catch (e) {
                print('Erreur: $e');
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}
