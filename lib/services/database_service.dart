import 'dart:convert';
import 'dart:html' as web;
import '../models/fournisseur.dart';
import '../models/produit.dart';
import '../models/commande.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal() {
    _loadFromStorage();
  }

  // Clés localStorage
  static const String _keyFournisseurs = 'app_fournisseurs';
  static const String _keyProduits = 'app_produits';
  static const String _keyCommandes = 'app_commandes';
  static const String _keyNextFournisseurId = 'app_nextFournisseurId';
  static const String _keyNextProduitId = 'app_nextProduitId';
  static const String _keyNextCommandeId = 'app_nextCommandeId';

  // Données en mémoire
  List<Map<String, dynamic>> _fournisseurs = [];
  List<Map<String, dynamic>> _produits = [];
  List<Map<String, dynamic>> _commandes = [];

  int _nextFournisseurId = 1;
  int _nextProduitId = 1;
  int _nextCommandeId = 1;

  // Charger depuis localStorage
  void _loadFromStorage() {
    print('🔄 Chargement depuis localStorage...');

    final storage = web.window.localStorage;

    try {
      final fournisseursJson = storage[_keyFournisseurs];
      if (fournisseursJson != null && fournisseursJson.isNotEmpty) {
        final decoded = jsonDecode(fournisseursJson) as List;
        _fournisseurs = decoded
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (e) {
      print('❌ Erreur fournisseurs: $e');
    }

    try {
      final produitsJson = storage[_keyProduits];
      if (produitsJson != null && produitsJson.isNotEmpty) {
        print('📦 JSON produits length: ${produitsJson.length} chars');
        final decoded = jsonDecode(produitsJson) as List;
        _produits = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        print('✅ Produits chargés: ${_produits.length}');

        if (_produits.isNotEmpty) {
          final maxId = _produits
              .map((p) => p['id'] as int)
              .reduce((a, b) => a > b ? a : b);
          _nextProduitId = maxId + 1;
          print('🔢 Prochain ID produit calculé: $_nextProduitId');
        }
      }
    } catch (e) {
      print('❌ Erreur produits: $e');
    }

    try {
      final commandesJson = storage[_keyCommandes];
      if (commandesJson != null && commandesJson.isNotEmpty) {
        final decoded = jsonDecode(commandesJson) as List;
        _commandes = decoded.map((e) => Map<String, dynamic>.from(e)).toList();

        if (_commandes.isNotEmpty) {
          final maxId = _commandes
              .map((c) => c['id'] as int)
              .reduce((a, b) => a > b ? a : b);
          _nextCommandeId = maxId + 1;
        }
      }
    } catch (e) {
      print('❌ Erreur commandes: $e');
    }

    // Charger les IDs
    final savedNextFournisseurId =
        int.tryParse(storage[_keyNextFournisseurId] ?? '1') ?? 1;
    final savedNextProduitId =
        int.tryParse(storage[_keyNextProduitId] ?? '1') ?? 1;
    final savedNextCommandeId =
        int.tryParse(storage[_keyNextCommandeId] ?? '1') ?? 1;

    if (_fournisseurs.isNotEmpty) {
      final maxId = _fournisseurs
          .map((f) => f['id'] as int)
          .reduce((a, b) => a > b ? a : b);
      _nextFournisseurId = maxId >= savedNextFournisseurId
          ? maxId + 1
          : savedNextFournisseurId;
    } else {
      _nextFournisseurId = savedNextFournisseurId;
    }

    if (savedNextProduitId > _nextProduitId) {
      _nextProduitId = savedNextProduitId;
    }

    if (savedNextCommandeId > _nextCommandeId) {
      _nextCommandeId = savedNextCommandeId;
    }

    print(
      '✅ Chargé: ${_fournisseurs.length} fournisseurs, ${_produits.length} produits, ${_commandes.length} commandes',
    );
    print(
      '🔢 Prochains IDs: Fournisseur=$_nextFournisseurId, Produit=$_nextProduitId, Commande=$_nextCommandeId',
    );
  }

  // Sauvegarder dans localStorage
  void _saveToStorage() {
    try {
      final produitsJson = jsonEncode(_produits);
      final fournisseursJson = jsonEncode(_fournisseurs);
      final commandesJson = jsonEncode(_commandes);

      print(
        '🔧 Sauvegarde - Produits: ${_produits.length}, Fournisseurs: ${_fournisseurs.length}, Commandes: ${_commandes.length}',
      );
      print(
        '📝 IDs des produits à sauvegarder: ${_produits.map((p) => p['id']).toList()}',
      );

      final storage = web.window.localStorage;

      // Sauvegarder
      storage[_keyProduits] = produitsJson;
      storage[_keyFournisseurs] = fournisseursJson;
      storage[_keyCommandes] = commandesJson;
      storage[_keyNextFournisseurId] = _nextFournisseurId.toString();
      storage[_keyNextProduitId] = _nextProduitId.toString();
      storage[_keyNextCommandeId] = _nextCommandeId.toString();

      print('💾 Sauvegardé avec succès !');

      // Vérification immédiate TRÈS DÉTAILLÉE
      final verifJson = storage[_keyProduits];
      if (verifJson != null) {
        final decoded = jsonDecode(verifJson) as List;
        final ids = decoded.map((p) => p['id']).toList();
        print('✅ Vérif: ${decoded.length} produits sauvegardés');
        print('📝 IDs vérifiés dans localStorage: $ids');

        if (decoded.length != _produits.length) {
          print('❌ ERREUR: Mismatch ${decoded.length} vs ${_produits.length}');
        }

        // Vérifier si le dernier produit est là
        final dernierProduit = _produits.last;
        final dernierDansStorage = decoded.firstWhere(
          (p) => p['id'] == dernierProduit['id'],
          orElse: () => null,
        );
        if (dernierDansStorage == null) {
          print(
            '❌ ALERTE: Le produit ID ${dernierProduit['id']} manque dans localStorage !',
          );
        } else {
          print(
            '✅ Le dernier produit (ID ${dernierProduit['id']}) est bien sauvegardé',
          );
        }
      }
    } catch (e) {
      print('❌ Erreur sauvegarde: $e');
    }
  }

  // ==================== FOURNISSEURS ====================

  Future<List<Fournisseur>> obtenirFournisseurs() async {
    return _fournisseurs.map((f) => Fournisseur.fromMap(f)).toList();
  }

  Future<void> ajouterFournisseur(Fournisseur fournisseur) async {
    fournisseur.id = _nextFournisseurId++;
    _fournisseurs.add(fournisseur.toMap());
    _saveToStorage();
    print('✅ Fournisseur ajouté: ${fournisseur.nom} (ID: ${fournisseur.id})');
  }

  Future<void> modifierFournisseur(Fournisseur fournisseur) async {
    final index = _fournisseurs.indexWhere((f) => f['id'] == fournisseur.id);
    if (index != -1) {
      _fournisseurs[index] = fournisseur.toMap();
      _saveToStorage();
      print('✅ Fournisseur modifié: ${fournisseur.nom}');
    }
  }

  Future<void> supprimerFournisseur(int id) async {
    _fournisseurs.removeWhere((f) => f['id'] == id);
    _saveToStorage();
    print('✅ Fournisseur supprimé: #$id');
  }

  // ==================== PRODUITS ====================

  Future<List<Produit>> obtenirProduits() async {
    return _produits.map((p) => Produit.fromMap(p)).toList();
  }

  Future<void> ajouterProduit(Produit produit) async {
    produit.id = _nextProduitId++;
    _produits.add(produit.toMap());
    print('✅ Produit ajouté: ${produit.nom} (ID: ${produit.id})');

    // Forcer la sauvegarde immédiate
    _saveToStorage();

    // Attendre pour garantir l'écriture
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> modifierStock(int produitId, int nouvelleQuantite) async {
    final index = _produits.indexWhere((p) => p['id'] == produitId);
    if (index != -1) {
      _produits[index]['quantiteStock'] = nouvelleQuantite;
      _saveToStorage();
      print('✅ Stock modifié pour produit #$produitId: $nouvelleQuantite');
    }
  }

  Future<void> supprimerProduit(int id) async {
    _produits.removeWhere((p) => p['id'] == id);
    _saveToStorage();
    print('✅ Produit supprimé: #$id');
  }

  // ==================== COMMANDES ====================

  Future<List<Commande>> obtenirCommandes() async {
    return _commandes.map((c) => Commande.fromMap(c)).toList();
  }

  Future<void> ajouterCommande(Commande commande) async {
    commande.id = _nextCommandeId++;
    _commandes.add(commande.toMap());
    _saveToStorage();
    print('✅ Commande ajoutée: #${commande.id}');
  }

  Future<void> modifierStatutCommande(
    int commandeId,
    String nouveauStatut,
    DateTime? dateLivraison,
  ) async {
    final index = _commandes.indexWhere((c) => c['id'] == commandeId);
    if (index != -1) {
      _commandes[index]['statut'] = nouveauStatut;
      if (dateLivraison != null) {
        _commandes[index]['dateLivraison'] = dateLivraison.toIso8601String();
      }
      _saveToStorage();
      print('✅ Statut commande #$commandeId modifié: $nouveauStatut');
    }
  }

  Future<void> supprimerCommande(int id) async {
    _commandes.removeWhere((c) => c['id'] == id);
    _saveToStorage();
    print('✅ Commande supprimée: #$id');
  }

  // ==================== STATISTIQUES ====================

  Future<Map<String, dynamic>> obtenirStatistiques() async {
    final produits = await obtenirProduits();
    final commandes = await obtenirCommandes();

    int totalProduits = produits.length;
    int produitsStockFaible = produits
        .where((p) => p.quantiteStock < 10)
        .length;

    int totalCommandes = commandes.length;
    int commandesEnAttente = commandes
        .where((c) => c.statut == 'En attente')
        .length;
    int commandesLivrees = commandes.where((c) => c.statut == 'Livrée').length;

    double valeurStock = produits.fold(
      0,
      (sum, p) => sum + (p.prix * p.quantiteStock),
    );

    return {
      'totalProduits': totalProduits,
      'produitsStockFaible': produitsStockFaible,
      'totalCommandes': totalCommandes,
      'commandesEnAttente': commandesEnAttente,
      'commandesLivrees': commandesLivrees,
      'valeurStock': valeurStock,
    };
  }

  getFournisseurs() {}

  getProducts() {}

  getCommandes() {}

  Future<void> mettreAJourFournisseur(Fournisseur updated) async {}
}
