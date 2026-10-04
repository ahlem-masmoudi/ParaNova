class Commande {
  int? id;
  int fournisseurId;
  List<LigneCommande> lignesCommande; // Liste de produits
  String statut; // 'En attente', 'Livrée', 'Annulée'
  DateTime dateCommande;
  DateTime? dateLivraison;

  Commande({
    this.id,
    required this.fournisseurId,
    required this.lignesCommande,
    required this.statut,
    required this.dateCommande,
    this.dateLivraison,
  });

  double get total {
    return lignesCommande.fold(0, (sum, ligne) => sum + ligne.sousTotal);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fournisseurId': fournisseurId,
      'lignesCommande': lignesCommande.map((l) => l.toMap()).toList(),
      'statut': statut,
      'dateCommande': dateCommande.toIso8601String(),
      'dateLivraison': dateLivraison?.toIso8601String(),
    };
  }

  factory Commande.fromMap(Map<String, dynamic> map) {
    return Commande(
      id: map['id'] as int?,
      fournisseurId: map['fournisseurId'] as int,
      lignesCommande: (map['lignesCommande'] as List)
          .map((l) => LigneCommande.fromMap(l))
          .toList(),
      statut: map['statut'] as String,
      dateCommande: DateTime.parse(map['dateCommande']),
      dateLivraison: map['dateLivraison'] != null
          ? DateTime.parse(map['dateLivraison'])
          : null,
    );
  }
}

class LigneCommande {
  int produitId;
  String nomProduit;
  int quantite;
  double prixUnitaire;

  LigneCommande({
    required this.produitId,
    required this.nomProduit,
    required this.quantite,
    required this.prixUnitaire,
  });

  double get sousTotal => quantite * prixUnitaire;

  Map<String, dynamic> toMap() {
    return {
      'produitId': produitId,
      'nomProduit': nomProduit,
      'quantite': quantite,
      'prixUnitaire': prixUnitaire,
    };
  }

  factory LigneCommande.fromMap(Map<String, dynamic> map) {
    return LigneCommande(
      produitId: map['produitId'] as int,
      nomProduit: map['nomProduit'] as String,
      quantite: map['quantite'] as int,
      prixUnitaire: (map['prixUnitaire'] is int)
          ? (map['prixUnitaire'] as int).toDouble()
          : map['prixUnitaire'] as double,
    );
  }
}
