import 'package:flutter/material.dart';
import '../models/produit.dart';
import '../models/fournisseur.dart';
import '../services/database_service.dart';

class ProduitsScreen extends StatefulWidget {
  const ProduitsScreen({super.key});

  @override
  State<ProduitsScreen> createState() => _ProduitsScreenState();
}

class _ProduitsScreenState extends State<ProduitsScreen> {
  final DatabaseService _db = DatabaseService();
  List<Produit> _produits = [];
  List<Fournisseur> _fournisseurs = [];

  // Liste des catégories
  static const List<String> categories = [
    'Soins Solaires',
    'Crèmes Hydratantes',
    'Soins du Visage',
    'Hygiène & Bien-être',
    'Compléments Alimentaires',
    'Soins Spécifiques',
  ];

  @override
  void initState() {
    super.initState();
    _chargerDonnees();
  }

  Future<void> _chargerDonnees() async {
    final produits = await _db.obtenirProduits();
    final fournisseurs = await _db.obtenirFournisseurs();
    setState(() {
      _produits = produits;
      _fournisseurs = fournisseurs;
    });
  }

  // Grouper les produits par catégorie
  Map<String, List<Produit>> _grouperParCategorie() {
    final Map<String, List<Produit>> groupes = {};
    for (var categorie in categories) {
      groupes[categorie] = [];
    }
    for (var produit in _produits) {
      if (groupes.containsKey(produit.categorie)) {
        groupes[produit.categorie]!.add(produit);
      }
    }
    return groupes;
  }

  @override
  Widget build(BuildContext context) {
    final produitsParCategorie = _grouperParCategorie();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produits'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Total: ${_produits.length} produits',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: _produits.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aucun produit',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final categorie = categories[index];
                final produits = produitsParCategorie[categorie] ?? [];

                if (produits.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: _getCategorieColor(categorie).withOpacity(0.1),
                        border: Border(
                          left: BorderSide(
                            color: _getCategorieColor(categorie),
                            width: 4,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getCategorieIcon(categorie),
                            color: _getCategorieColor(categorie),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            categorie,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _getCategorieColor(categorie),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getCategorieColor(categorie),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${produits.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...produits.map((produit) => _buildProduitCard(produit)),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _ajouterProduit(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProduitCard(Produit produit) {
    // Badge stock avec couleur
    Color stockColor = produit.quantiteStock < 50
        ? Colors.red
        : (produit.quantiteStock < 100 ? Colors.orange : Colors.green);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Détails du produit si besoin
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGE DU PRODUIT
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: produit.imageUrl != null && produit.imageUrl!.isNotEmpty
                    ? Image.network(
                        produit.imageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: Colors.grey[600],
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue[300]!, Colors.blue[600]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.shopping_bag,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
              ),
              const SizedBox(width: 12),

              // INFOS PRODUIT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom + Badge Stock
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            produit.nom,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Badge stock
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: stockColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: stockColor, width: 1.5),
                          ),
                          child: Text(
                            '${produit.quantiteStock}',
                            style: TextStyle(
                              color: stockColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Badge catégorie
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        produit.categorie,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.purple[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Description
                    Text(
                      produit.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Prix + Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${produit.prix.toStringAsFixed(2)} DT',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              color: Colors.orange,
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(8),
                              onPressed: () => _modifierProduit(produit),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20),
                              color: Colors.red,
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(8),
                              onPressed: () => _confirmerSuppression(produit),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategorieColor(String categorie) {
    switch (categorie) {
      case 'Soins Solaires':
        return Colors.orange;
      case 'Crèmes Hydratantes':
        return Colors.blue;
      case 'Soins du Visage':
        return Colors.pink;
      case 'Hygiène & Bien-être':
        return Colors.green;
      case 'Compléments Alimentaires':
        return Colors.purple;
      case 'Soins Spécifiques':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategorieIcon(String categorie) {
    switch (categorie) {
      case 'Soins Solaires':
        return Icons.wb_sunny;
      case 'Crèmes Hydratantes':
        return Icons.water_drop;
      case 'Soins du Visage':
        return Icons.face;
      case 'Hygiène & Bien-être':
        return Icons.spa;
      case 'Compléments Alimentaires':
        return Icons.medication;
      case 'Soins Spécifiques':
        return Icons.healing;
      default:
        return Icons.category;
    }
  }

  void _ajouterProduit(BuildContext context) {
    final nomController = TextEditingController();
    final descController = TextEditingController();
    final prixController = TextEditingController();
    final stockController = TextEditingController();
    int? fournisseurSelectionne;
    String? categorieSelectionnee;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Ajouter un produit'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomController,
                  decoration: const InputDecoration(labelText: 'Nom'),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                TextField(
                  controller: prixController,
                  decoration: const InputDecoration(
                    labelText: 'Prix (DT)',
                    hintText: 'Ex: 180',
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: stockController,
                  decoration: const InputDecoration(labelText: 'Stock initial'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Catégorie'),
                  value: categorieSelectionnee,
                  items: categories.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      categorieSelectionnee = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Fournisseur'),
                  value: fournisseurSelectionne,
                  items: _fournisseurs.map((f) {
                    return DropdownMenuItem(value: f.id, child: Text(f.nom));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      fournisseurSelectionne = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                if (fournisseurSelectionne != null &&
                    categorieSelectionnee != null &&
                    nomController.text.isNotEmpty &&
                    prixController.text.isNotEmpty &&
                    stockController.text.isNotEmpty) {
                  final produit = Produit(
                    nom: nomController.text,
                    description: descController.text,
                    prix: double.parse(prixController.text),
                    quantiteStock: int.parse(stockController.text),
                    fournisseurId: fournisseurSelectionne!,
                    categorie: categorieSelectionnee!,
                    imageUrl:
                        'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=400&h=400&fit=crop', // Image par défaut
                  );
                  await _db.ajouterProduit(produit);
                  Navigator.pop(context);
                  _chargerDonnees();
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }

  void _modifierProduit(Produit produit) {
    final nomController = TextEditingController(text: produit.nom);
    final descController = TextEditingController(text: produit.description);
    final prixController = TextEditingController(text: produit.prix.toString());
    final stockController = TextEditingController(
      text: produit.quantiteStock.toString(),
    );
    String? categorieSelectionnee = produit.categorie;
    int? fournisseurSelectionne = produit.fournisseurId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Modifier - ${produit.nom}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomController,
                  decoration: const InputDecoration(labelText: 'Nom'),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                TextField(
                  controller: prixController,
                  decoration: const InputDecoration(
                    labelText: 'Prix (DT)',
                    hintText: 'Ex: 180',
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: stockController,
                  decoration: const InputDecoration(labelText: 'Stock'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Catégorie'),
                  value: categorieSelectionnee,
                  items: categories.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      categorieSelectionnee = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Fournisseur'),
                  value: fournisseurSelectionne,
                  items: _fournisseurs.map((f) {
                    return DropdownMenuItem(value: f.id, child: Text(f.nom));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      fournisseurSelectionne = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                if (fournisseurSelectionne != null &&
                    categorieSelectionnee != null &&
                    nomController.text.isNotEmpty &&
                    prixController.text.isNotEmpty &&
                    stockController.text.isNotEmpty) {
                  // Supprimer l'ancien produit
                  await _db.supprimerProduit(produit.id!);

                  // Ajouter le produit modifié avec le même ID et la même image
                  final produitModifie = Produit(
                    id: produit.id,
                    nom: nomController.text,
                    description: descController.text,
                    prix: double.parse(prixController.text),
                    quantiteStock: int.parse(stockController.text),
                    fournisseurId: fournisseurSelectionne!,
                    categorie: categorieSelectionnee!,
                    imageUrl: produit.imageUrl, // Conserver l'image
                  );

                  _produits.add(produitModifie);
                  await _db.ajouterProduit(produitModifie);

                  Navigator.pop(context);
                  _chargerDonnees();
                }
              },
              child: const Text('Modifier'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmerSuppression(Produit produit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer "${produit.nom}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              await _db.supprimerProduit(produit.id!);
              Navigator.pop(context);
              _chargerDonnees();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
