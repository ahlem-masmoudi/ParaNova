import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';

class StatistiquesScreen extends StatefulWidget {
  const StatistiquesScreen({super.key});

  @override
  State<StatistiquesScreen> createState() => _StatistiquesScreenState();
}

class _StatistiquesScreenState extends State<StatistiquesScreen> {
  final _dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📊 Statistiques'), centerTitle: true),
      body: FutureBuilder(
        future: Future.wait([
          _dbService.obtenirProduits(),
          _dbService.obtenirFournisseurs(),
          _dbService.obtenirCommandes(),
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppTheme.roseFonce),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Aucune donnée'));
          }

          final produits = snapshot.data![0] as List;
          final fournisseurs = snapshot.data![1] as List;
          final commandes = snapshot.data![2] as List;

          final totalCommandes = commandes.length;
          final commandesEnAttente = commandes.where((c) {
            final statut = c.statut.toLowerCase();
            return statut == 'en attente';
          }).length;

          final commandesLivrees = commandes.where((c) {
            final statut = c.statut.toLowerCase();
            return statut == 'livrée' ||
                statut == 'livree' ||
                statut == 'livrés' ||
                statut == 'livres';
          }).length;

          final stockTotal = produits.fold<int>(
            0,
            (sum, produit) => sum + (produit.quantiteStock as int),
          );

          final montantTotal = commandes.fold<double>(
            0.0,
            (sum, commande) => sum + (commande.total as num).toDouble(),
          );

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.blanc,
                  AppTheme.lavandePastel.withOpacity(0.1),
                ],
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Section Produits avec graphique
                _buildSectionTitle('📦 Produits'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Produits',
                        produits.length.toString(),
                        Icons.inventory_2_rounded,
                        AppTheme.rosePrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Stock Total',
                        stockTotal.toString(),
                        Icons.warehouse_rounded,
                        AppTheme.bleuPastel,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Section Fournisseurs
                _buildSectionTitle('🏢 Fournisseurs'),
                const SizedBox(height: 12),
                _buildStatCard(
                  'Total Fournisseurs',
                  fournisseurs.length.toString(),
                  Icons.people_rounded,
                  AppTheme.lavandePastel,
                ),
                const SizedBox(height: 24),

                // Section Commandes avec graphique circulaire
                _buildSectionTitle('🛒 Commandes'),
                const SizedBox(height: 12),
                _buildStatCard(
                  'Total Commandes',
                  totalCommandes.toString(),
                  Icons.shopping_cart_rounded,
                  AppTheme.mintPastel,
                ),
                const SizedBox(height: 16),

                // Graphique circulaire des commandes
                _buildCommandesChart(commandesEnAttente, commandesLivrees),
                const SizedBox(height: 24),

                // Section Montant avec barre de progression
                _buildSectionTitle('💰 Montant Total'),
                const SizedBox(height: 12),
                _buildMontantCard(montantTotal),
                const SizedBox(height: 24),

                // Graphique en barres pour les produits par catégorie
                _buildSectionTitle('📊 Répartition des Produits'),
                const SizedBox(height: 12),
                _buildProduitsChart(produits),
              ],
            ),
          );
        },
      ),
    );
  }

  // Graphique circulaire des commandes
  Widget _buildCommandesChart(int enAttente, int livrees) {
    final total = enAttente + livrees;
    if (total == 0) return const SizedBox();

    final percentageEnAttente = (enAttente / total);
    final percentageLivrees = (livrees / total);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'État des Commandes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A4458),
            ),
          ),
          const SizedBox(height: 20),
          // Cercle de progression
          SizedBox(
            height: 200,
            width: 200,
            child: Stack(
              children: [
                // Cercle de fond
                Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[100],
                    ),
                  ),
                ),
                // Portion "En Attente"
                Center(
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: percentageEnAttente,
                      strokeWidth: 20,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFFFFDAB9),
                      ),
                    ),
                  ),
                ),
                // Portion "Livrées"
                Center(
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: Transform.rotate(
                      angle: 2 * 3.14159 * percentageEnAttente,
                      child: CircularProgressIndicator(
                        value: percentageLivrees,
                        strokeWidth: 20,
                        backgroundColor: Colors.transparent,
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFFB5EAD7),
                        ),
                      ),
                    ),
                  ),
                ),
                // Centre avec total
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        total.toString(),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A4458),
                        ),
                      ),
                      const Text(
                        'Total',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Légende
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(
                'En Attente',
                enAttente.toString(),
                const Color(0xFFFFDAB9),
                Icons.schedule_rounded,
              ),
              _buildLegendItem(
                'Livrées',
                livrees.toString(),
                const Color(0xFFB5EAD7),
                Icons.check_circle_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Carte montant avec barre de progression
  Widget _buildMontantCard(double montant) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.roseFonce, AppTheme.rosePrimary],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.roseFonce.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.attach_money_rounded, color: Colors.white, size: 48),
          const SizedBox(height: 12),
          const Text(
            'Revenu Total',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            '${montant.toStringAsFixed(2)} DT',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Graphique en barres pour les produits
  Widget _buildProduitsChart(List produits) {
    // Compter les produits par catégorie
    final Map<String, int> categories = {};
    for (var produit in produits) {
      final cat = produit.categorie;
      categories[cat] = (categories[cat] ?? 0) + 1;
    }

    final maxCount = categories.values.isEmpty
        ? 1
        : categories.values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: categories.entries.map((entry) {
          final percentage = entry.value / maxCount;
          final color = AppTheme.getCategorieColor(entry.key);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4A4458),
                        ),
                      ),
                    ),
                    Text(
                      '${entry.value} produits',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: percentage,
                    minHeight: 12,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4A4458),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A4458),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
