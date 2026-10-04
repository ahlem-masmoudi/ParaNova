class Fournisseur {
  int? id;
  String nom;
  String telephone;
  String email;

  Fournisseur({
    this.id,
    required this.nom,
    required this.telephone,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'nom': nom, 'telephone': telephone, 'email': email};
  }

  factory Fournisseur.fromMap(Map<String, dynamic> map) {
    return Fournisseur(
      id: map['id'],
      nom: map['nom'],
      telephone: map['telephone'],
      email: map['email'],
    );
  }
}
