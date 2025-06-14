import 'package:datalock/data/models/business_model.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final Business business;

  const RestaurantDetailScreen({
    Key? key,
    required this.business,
  }) : super(key: key);

  @override
  _RestaurantDetailScreenState createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Menu', 'Avis', 'Info'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFF7F50), // Fond orange
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRestaurantInfo(),
                _buildTabBar(),
                _buildTabContent(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: Color(0xFFFF7F50), // Fond orange
      flexibleSpace: FlexibleSpaceBar(
        background: Image.network(
          widget.business.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: Center(
                child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey[400]),
              ),
            );
          },
        ),
      ),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.arrow_back, color: Color(0xFFFF7F50)), // Icône orange
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.favorite_border, color: Color(0xFFFF7F50)), // Icône orange
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.share, color: Color(0xFFFF7F50)), // Icône orange
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildRestaurantInfo() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFFF7F50), // Fond orange via BoxDecoration
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.business.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Texte blanc
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ...widget.business.tags.map((tag) => _buildTag(tag)).toList(),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.star, size: 18, color: Colors.white), // Icône blanche
              const SizedBox(width: 4),
              Text(
                "${widget.business.rating}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Texte blanc
                ),
              ),
              const SizedBox(width: 4),
              Text(
                "(${widget.business.reviewCount} ${"Ratings".tr()})",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8), // Texte blanc légèrement transparent
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time, size: 18, color: Colors.white), // Icône blanche
              const SizedBox(width: 4),
              Text(
                "${widget.business.deliveryTime} ${"Min".tr()}",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8), // Texte blanc légèrement transparent
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.monetization_on_outlined, size: 18, color: Colors.white), // Icône blanche
              const SizedBox(width: 4),
              Text(
                widget.business.isFreeDelivery ? "Free".tr() : "${widget.business.deliveryFee}",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8), // Texte blanc légèrement transparent
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2), // Fond blanc transparent
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        tag.tr(),
        style: TextStyle(
          color: Colors.white, // Texte blanc
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFFF7F50), // Fond orange via BoxDecoration
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.2)), // Bordure blanche transparente
        ),
      ),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? Colors.white : Colors.transparent, // Bordure blanche si sélectionné
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  _tabs[index].tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.7), // Texte blanc
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildMenuTab();
      case 1:
        return _buildReviewsTab();
      case 2:
        return _buildInfoTab();
      default:
        return _buildMenuTab();
    }
  }

  Widget _buildMenuTab() {
    // Simuler des données de menu
    final menuCategories = [
      {
        'name': 'Populaires',
        'items': [
          {'name': 'Plat 1', 'price': '800 DA', 'description': 'Description du plat 1'},
          {'name': 'Plat 2', 'price': '950 DA', 'description': 'Description du plat 2'},
        ]
      },
      {
        'name': 'Entrées',
        'items': [
          {'name': 'Entrée 1', 'price': '400 DA', 'description': 'Description de l\'entrée 1'},
          {'name': 'Entrée 2', 'price': '450 DA', 'description': 'Description de l\'entrée 2'},
        ]
      },
      {
        'name': 'Plats principaux',
        'items': [
          {'name': 'Plat principal 1', 'price': '1200 DA', 'description': 'Description du plat principal 1'},
          {'name': 'Plat principal 2', 'price': '1300 DA', 'description': 'Description du plat principal 2'},
        ]
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFFF7F50), // Fond orange via BoxDecoration
      ),
      child: Column(
        children: menuCategories.map((category) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  (category['name'] as String).tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Texte blanc
                  ),
                ),
              ),
              ...(category['items'] as List).map<Widget>((item) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white, // Fond blanc
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name']!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF7F50), // Texte orange
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['description']!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['price']!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF7F50), // Texte orange
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Icon(Icons.image, color: Colors.grey[400]),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReviewsTab() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFFF7F50), // Fond orange via BoxDecoration
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Avis des clients".tr(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Texte blanc
            ),
          ),
          const SizedBox(height: 16),
          // Simuler quelques avis
          _buildReviewItem(
            name: "Ahmed K.",
            rating: 5,
            date: "15/04/2025",
            comment: "Excellent service et nourriture délicieuse !",
          ),
          _buildReviewItem(
            name: "Sarah M.",
            rating: 4,
            date: "10/04/2025",
            comment: "Très bon, mais la livraison était un peu en retard.",
          ),
          _buildReviewItem(
            name: "Mohamed L.",
            rating: 5,
            date: "05/04/2025",
            comment: "Je recommande vivement, tout était parfait !",
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem({
    required String name,
    required int rating,
    required String date,
    required String comment,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white, // Fond blanc
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF7F50), // Texte orange
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < rating ? Icons.star : Icons.star_border,
                size: 16,
                color: Color(0xFFFF7F50), // Icône orange
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            comment,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFFF7F50), // Fond orange via BoxDecoration
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Informations".tr(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Texte blanc
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            icon: Icons.access_time,
            title: "Horaires d'ouverture".tr(),
            content: "Lun-Dim: 10:00 - 23:00",
          ),
          _buildInfoItem(
            icon: Icons.location_on,
            title: "Adresse".tr(),
            content: "123 Rue des Exemples, Alger",
          ),
          _buildInfoItem(
            icon: Icons.phone,
            title: "Téléphone".tr(),
            content: "+213 123 456 789",
          ),
          _buildInfoItem(
            icon: Icons.payment,
            title: "Modes de paiement".tr(),
            content: "Espèces, Carte bancaire",
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.2)), // Bordure blanche transparente
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 20), // Icône blanche
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Texte blanc
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8), // Texte blanc légèrement transparent
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, // Fond blanc
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // Action pour commander
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // Fond blanc
          foregroundColor: Color(0xFFFF7F50), // Texte orange
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Color(0xFFFF7F50), width: 2), // Bordure orange
          ),
        ),
        child: Text(
          "Commander".tr(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF7F50), // Texte orange
          ),
        ),
      ),
    );
  }
}
