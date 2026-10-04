import 'package:flutter/material.dart';
import '../models/commande.dart';
import '../models/produit.dart';
import '../models/fournisseur.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class CommandesScreen extends StatefulWidget {
  const CommandesScreen({super.key});

  @override
  State<CommandesScreen> createState() => _CommandesScreenState();
}

class _CommandesScreenState extends State<CommandesScreen> {
  final DatabaseService _db = DatabaseService();
  List<Commande> _commandes = [];
  List<Fournisseur> _fournisseurs = [];
  List<Produit> _produits = [];

  @override
  void initState() {
    super.initState();
    _chargerDonnees();
  }

  Future<void> _chargerDonnees() async {
    final commandes = await _db.obtenirCommandes();
    final fournisseurs = await _db.obtenirFournisseurs();
    final produits = await _db.obtenirProduits();
    setState(() {
      _commandes = commandes;
      _fournisseurs = fournisseurs;
      _produits = produits;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commandes'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Total: ${_commandes.length} commandes',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: _commandes.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aucune commande',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _commandes.length,
              itemBuilder: (context, index) {
                final commande = _commandes[index];
                final fournisseur = _fournisseurs.firstWhere(
                  (f) => f.id == commande.fournisseurId,
                  orElse: () =>
                      Fournisseur(nom: 'Inconnu', telephone: '', email: ''),
                );

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatutColor(commande.statut),
                      child: Icon(
                        _getStatutIcon(commande.statut),
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      'Commande #${commande.id} - ${fournisseur.nom}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Date: ${DateFormat('dd/MM/yyyy').format(commande.dateCommande)}\n'
                      'Total: ${commande.total.toStringAsFixed(2)} DT\n'
                      'Statut: ${commande.statut}',
                    ),
                    children: [
                      const Divider(),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          'Détails de la commande :',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      ...commande.lignesCommande.map(
                        (ligne) => ListTile(
                          dense: true,
                          leading: const Icon(Icons.inventory_2, size: 20),
                          title: Text(ligne.nomProduit),
                          subtitle: Text(
                            '${ligne.quantite} × ${ligne.prixUnitaire.toStringAsFixed(2)} DT',
                          ),
                          trailing: Text(
                            '${ligne.sousTotal.toStringAsFixed(2)} DT',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text(
                              'TOTAL: ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${commande.total.toStringAsFixed(2)} DT',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.roseFonce,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (commande.statut != 'Livrée')
                              ElevatedButton.icon(
                                onPressed: () =>
                                    _changerStatut(commande, 'Livrée'),
                                icon: const Icon(Icons.check_circle),
                                label: const Text('Marquer livrée'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            if (commande.statut != 'Annulée')
                              ElevatedButton.icon(
                                onPressed: () =>
                                    _changerStatut(commande, 'Annulée'),
                                icon: const Icon(Icons.cancel),
                                label: const Text('Annuler'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmerSuppression(commande),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _ajouterCommande(context),
        backgroundColor: AppTheme.roseFonce,
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getStatutColor(String statut) {
    switch (statut) {
      case 'En attente':
        return Colors.orange;
      case 'Livrée':
        return Colors.green;
      case 'Annulée':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatutIcon(String statut) {
    switch (statut) {
      case 'En attente':
        return Icons.schedule;
      case 'Livrée':
        return Icons.check_circle;
      case 'Annulée':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  void _ajouterCommande(BuildContext context) {
    int? fournisseurSelectionne;
    List<LigneCommande> lignesCommande = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.rosePrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.add_shopping_cart, color: AppTheme.roseFonce),
              ),
              const SizedBox(width: 12),
              const Text('Nouvelle commande'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Fournisseur',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.roseFonce,
                        width: 2,
                      ),
                    ),
                  ),
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
                const SizedBox(height: 16),
                const Divider(),
                const Text(
                  'Produits',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...lignesCommande.map((ligne) {
                  return Card(
                    color: AppTheme.rosePastel.withOpacity(0.3),
                    child: ListTile(
                      title: Text(ligne.nomProduit),
                      subtitle: Text(
                        'Qté: ${ligne.quantite} × ${ligne.prixUnitaire} DT',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${ligne.sousTotal.toStringAsFixed(2)} DT',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                lignesCommande.remove(ligne);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    _ajouterLigneCommande(context, (ligne) {
                      setState(() {
                        lignesCommande.add(ligne);
                      });
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.rosePrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter un produit'),
                ),
                if (lignesCommande.isNotEmpty) ...[
                  const Divider(),
                  Text(
                    'Total: ${lignesCommande.fold(0.0, (sum, ligne) => sum + ligne.sousTotal).toStringAsFixed(2)} DT',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.roseFonce,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () async {
                if (fournisseurSelectionne != null &&
                    lignesCommande.isNotEmpty) {
                  final commande = Commande(
                    fournisseurId: fournisseurSelectionne!,
                    lignesCommande: lignesCommande,
                    statut: 'En attente',
                    dateCommande: DateTime.now(),
                  );
                  await _db.ajouterCommande(commande);
                  Navigator.pop(context);
                  _chargerDonnees();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.roseFonce,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Créer'),
            ),
          ],
        ),
      ),
    );
  }

  void _ajouterLigneCommande(
    BuildContext context,
    Function(LigneCommande) onAdd,
  ) {
    int? produitSelectionne;
    final quantiteController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.rosePrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.add_shopping_cart_rounded,
                  color: AppTheme.roseFonce,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Ajouter un produit'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label Produit
                const Text(
                  'Produit',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A4458),
                  ),
                ),
                const SizedBox(height: 8),
                // Dropdown Produit
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.rosePastel.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.rosePrimary.withOpacity(0.3),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      hint: const Text('Sélectionner un produit'),
                      value: produitSelectionne,
                      icon: Icon(
                        Icons.arrow_drop_down_rounded,
                        color: AppTheme.roseFonce,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      items: _produits.map((p) {
                        return DropdownMenuItem(
                          value: p.id,
                          child: Text(
                            '${p.nom} (${p.prix} DT)',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          produitSelectionne = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24), // ESPACE AJOUTÉ !
                // Label Quantité
                const Text(
                  'Quantité',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A4458),
                  ),
                ),
                const SizedBox(height: 8),
                // TextField Quantité
                TextField(
                  controller: quantiteController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Entrez la quantité',
                    prefixIcon: Icon(
                      Icons.shopping_bag_rounded,
                      color: AppTheme.roseFonce,
                    ),
                    filled: true,
                    fillColor: AppTheme.rosePastel.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.rosePrimary.withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.rosePrimary.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.roseFonce,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                if (produitSelectionne != null) {
                  final produit = _produits.firstWhere(
                    (p) => p.id == produitSelectionne,
                  );
                  final ligne = LigneCommande(
                    produitId: produit.id!,
                    nomProduit: produit.nom,
                    quantite: int.parse(quantiteController.text),
                    prixUnitaire: produit.prix,
                  );
                  onAdd(ligne);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.roseFonce,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Ajouter'),
                  SizedBox(width: 8),
                  Icon(Icons.add_rounded, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _changerStatut(Commande commande, String nouveauStatut) async {
    await _db.modifierStatutCommande(
      commande.id!,
      nouveauStatut,
      nouveauStatut == 'Livrée' ? DateTime.now() : null,
    );
    _chargerDonnees();
  }

  void _confirmerSuppression(Commande commande) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Voulez-vous vraiment supprimer la commande #${commande.id} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              await _db.supprimerCommande(commande.id!);
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
