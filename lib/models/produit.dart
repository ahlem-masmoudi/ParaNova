class Produit {
  int? id;
  String nom;
  String description;
  double prix;
  int quantiteStock;
  int fournisseurId;
  String categorie;
  String? imageUrl; 

  Produit({
    this.id,
    required this.nom,
    required this.description,
    required this.prix,
    required this.quantiteStock,
    required this.fournisseurId,
    required this.categorie,
    this.imageUrl, 
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'prix': prix,
      'quantiteStock': quantiteStock,
      'fournisseurId': fournisseurId,
      'categorie': categorie,
      'imageUrl': imageUrl, // ← NOUVEAU
    };
  }

  factory Produit.fromMap(Map<String, dynamic> map) {
    return Produit(
      id: map['id'] as int?,
      nom: map['nom'] as String,
      description: map['description'] as String,
      prix: (map['prix'] is int)
          ? (map['prix'] as int).toDouble()
          : map['prix'] as double,
      quantiteStock: map['quantiteStock'] as int,
      fournisseurId: map['fournisseurId'] as int,
      categorie: map['categorie'] as String? ?? 'Autre',
      imageUrl: map['imageUrl'] as String?, // ← NOUVEAU
    );
  }
}
