import 'package:appwrite/appwrite.dart';
import 'package:datalock/ui/screens/RestaurantDetailScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/permission_card.dart';
import '../../services/permissions_service.dart';
import '../../services/auth_service.dart';
import '../../config/config.dart';
import '../screens/authentication_screen.dart';
import '../../services/user_service.dart';
import '../../services/business_service.dart';
import '../../data/models/category_model.dart';
import '../../data/models/business_model.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> with SingleTickerProviderStateMixin {
  final PermissionsService _permissionsService = PermissionsService();
  final BusinessService _businessService = BusinessService();
  bool _showNotificationPermission = true;
  final FlutterSecureStorage storage = FlutterSecureStorage();
  final account = Config.getAccount();
  final databases = Config.getDatabases();
  final functions = Config.getFunctions();
  late AuthService _authService;
  int _selectedIndex = 0;
  late AnimationController _animationController;
  String userName = "";
  String userSurname = "";
  
  // Catégories principales
  List<Category> _mainCategories = [];
  
  // Sous-catégories de la catégorie sélectionnée
  List<Category> _subCategories = [];
  
  // Restaurants/businesses à afficher
  List<Business> _businesses = [];
  
  // Catégorie sélectionnée
  Category? _selectedCategory;

  // Sous-catégorie sélectionnée
  Category? _selectedSubCategory;
  
  // État de chargement
  bool _isLoading = true;
  
  // Contrôleur de recherche
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _checkNotificationPermissionStatus();
    _saveSession();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _loadUserInfo();
    _loadCategories();
  }
  
  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Charger les catégories principales
      final categories = await _businessService.getMainCategories();
      
      // Charger les restaurants/businesses recommandés
      final businesses = await _businessService.getBusinesses();
      
      setState(() {
        _mainCategories = categories;
        _businesses = businesses;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des données: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadSubCategories(Category category) async {
    setState(() {
      _isLoading = true;
      _selectedCategory = category;
    });
    
    try {
      // Charger les sous-catégories de la catégorie sélectionnée
      final subCategories = await _businessService.getSubCategories(category.id);
      
      // Charger les restaurants/businesses de cette catégorie
      final businesses = await _businessService.getBusinessesByCategory(category.id);
      
      setState(() {
        _subCategories = subCategories;
        _businesses = businesses;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des sous-catégories: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _resetCategories() {
    setState(() {
      _selectedCategory = null;
      _subCategories = [];
    });
    _loadCategories();
  }

  Future<void> _loadUserInfo() async {
    final userService = UserService();
    final user = await userService.getUserProfile();
    if (user != null) {
      setState(() {
        userName = user['user_name'] ?? "";
        userSurname = user['family_name'] ?? "";
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkNotificationPermissionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool alreadyRequested = prefs.getBool('notification_permission_requested') ?? false;
    if (mounted) {
      setState(() {
        _showNotificationPermission = !alreadyRequested;
      });
    }
  }

  Future<void> _saveSession() async {
    final sessionID = await storage.read(key: 'session_id');
    if (sessionID == null) {
      final id = await storage.read(key: 'new_user_id');
      final phoneNumber = await storage.read(key: 'phoneNumber');
      if (id != null && phoneNumber != null) {
        _authService.uploadUserSession(phoneNumber, id, account, databases);
      }
    }
  }

  Future<void> logout() async {
    try {
      await storage.delete(key: 'session_id');
      await storage.delete(key: 'phone_number');
      await storage.delete(key: 'new_user_id');
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _isLoading 
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF7F50)),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCategoriesSection(),
                            if (_selectedCategory != null) _buildSubCategoriesSection(),
                            _buildBusinessesSection(),
                          ],
                        ),
                      ),
                ),
              ],
            ),
            if (_showNotificationPermission) _buildPermissionCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(CupertinoIcons.sun_max, color: Color(0xFFFF7F50)),
                    const SizedBox(width: 8),
                    Text(
                      "Bonjour".tr(),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Image.asset(
                  'assets/images/logo.png',
                  height: 40,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Meriem Mokhtari",
            // '$userName $userSurname',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Color(0xFF6B7280)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search".tr(),
                      border: InputBorder.none,
                      hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                    ),
                    onSubmitted: (value) {
                      // Implémenter la recherche
                      _searchBusinesses(value);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _searchBusinesses(String query) async {
    if (query.isEmpty) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final results = await _businessService.searchBusinesses(query);
      
      setState(() {
        _businesses = results;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors de la recherche: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 16, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Top categories".tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              if (_selectedCategory != null)
                TextButton(
                  onPressed: _resetCategories,
                  child: Text(
                    "See all".tr(),
                    style: const TextStyle(
                      color: Color(0xFFFF7F50),
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _mainCategories.length,
            itemBuilder: (context, index) {
              final category = _mainCategories[index];
              final isSelected = _selectedCategory?.id == category.id;
              
              return GestureDetector(
                onTap: () => _loadSubCategories(category),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xFFFF7F50) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Color(0xFFFF7F50) : Colors.grey[300]!,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      category.name.tr(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Modifier la méthode _buildSubCategoriesSection pour ajouter la sélection et changer la couleur des icônes
  Widget _buildSubCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _subCategories.length,
            itemBuilder: (context, index) {
              final subCategory = _subCategories[index];
              final isSelected = _selectedSubCategory?.id == subCategory.id;
              
              return GestureDetector(
                onTap: () async {
                  // Charger les businesses de cette sous-catégorie
                  setState(() {
                    _isLoading = true;
                    _selectedSubCategory = subCategory;
                  });
                  
                  try {
                    final businesses = await _businessService.getBusinessesBySubCategory(subCategory.id);
                    
                    setState(() {
                      _businesses = businesses;
                      _isLoading = false;
                    });
                  } catch (e) {
                    print('Erreur lors du chargement des businesses: $e');
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xFFFF7F50) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      // Icône pour chaque sous-catégorie en orange
                      _getSubCategoryIcon(subCategory.name, isSelected),
                      const SizedBox(width: 8),
                      Text(
                        subCategory.name.tr(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Modifier la méthode _getSubCategoryIcon pour utiliser la couleur orange
  Widget _getSubCategoryIcon(String categoryName, bool isSelected) {
    final Color iconColor = isSelected ? Colors.white : Color(0xFFFF7F50);
    
    // Retourne l'icône appropriée pour chaque sous-catégorie
    switch (categoryName.toLowerCase()) {
      case 'pizza':
        return Icon(Icons.local_pizza, size: 20, color: iconColor);
      case 'burger':
        return Icon(Icons.lunch_dining, size: 20, color: iconColor);
      case 'tacos':
        return Icon(Icons.fastfood, size: 20, color: iconColor);
      case 'sushi':
        return Icon(Icons.set_meal, size: 20, color: iconColor);
      case 'grillades':
        return Icon(Icons.outdoor_grill, size: 20, color: iconColor);
      case 'couscous':
      case 'tajines':
        return Icon(Icons.dinner_dining, size: 20, color: iconColor);
      case 'plats algériens':
        return Icon(Icons.restaurant_menu, size: 20, color: iconColor);
      case 'soupes':
        return Icon(Icons.soup_kitchen, size: 20, color: iconColor);
      case 'repas quotidiens':
        return Icon(Icons.rice_bowl, size: 20, color: iconColor);
      case 'salades':
        return Icon(Icons.eco, size: 20, color: iconColor);
      case 'bowl':
        return Icon(Icons.ramen_dining, size: 20, color: iconColor);
      case 'protéiné':
        return Icon(Icons.fitness_center, size: 20, color: iconColor);
      case 'low carb':
        return Icon(Icons.spa, size: 20, color: iconColor);
      case 'végétarien':
        return Icon(Icons.grass, size: 20, color: iconColor);
      case 'gâteaux':
        return Icon(Icons.cake, size: 20, color: iconColor);
      case 'cookies':
        return Icon(Icons.cookie, size: 20, color: iconColor);
      case 'viennoiseries':
        return Icon(Icons.bakery_dining, size: 20, color: iconColor);
      case 'tartes':
        return Icon(Icons.pie_chart, size: 20, color: iconColor);
      case 'crêpes & pancakes':
        return Icon(Icons.breakfast_dining, size: 20, color: iconColor);
      default:
        return Icon(Icons.restaurant, size: 20, color: iconColor);
    }
  }

  Widget _buildBusinessesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _selectedCategory != null 
              ? "${_selectedCategory!.name.tr()} restaurant".tr()
              : "All restaurant".tr(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _businesses.length,
          itemBuilder: (context, index) {
            final business = _businesses[index];
            return BusinessCard(business: business);
          },
        ),
      ],
    );
  }
  
  Widget _buildPermissionCard() {
    return Center(
      child: PermissionCard(
        title: "Autorisation_de_notifications".tr(),
        description: "Recevez_des_notifications_sur_vos_commandes_et_offres_spéciales".tr(),
        icon: Icons.notifications,
        onAccept: _handleNotificationPermission,
        onDeny: _handleNotificationDenied,
      ),
    );
  }

  void _handleNotificationPermission() async {
    bool granted = await _permissionsService.requestNotificationPermission();
    if (mounted) {
      setState(() {
        _showNotificationPermission = false;
      });
    }
    if (!granted) {
      _handleNotificationDenied();
    }
  }

  void _handleNotificationDenied() {
    if (mounted) {
      setState(() {
        _showNotificationPermission = false;
      });
    }
  }
}

// Modifier la classe BusinessCard pour simplifier l'affichage et ajouter la navigation
class BusinessCard extends StatelessWidget {
  final Business business;

  const BusinessCard({
    Key? key,
    required this.business,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigation vers l'écran de détail du restaurant
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestaurantDetailScreen(business: business),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du restaurant
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                business.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey[400]),
                    ),
                  );
                },
              ),
            ),
            
            // Informations du restaurant
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    business.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Prix et tags
                  Row(
                    children: [
                      Text(
                        business.priceRange,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('•', style: TextStyle(color: Colors.grey)),
                      const SizedBox(width: 8),
                      ...business.tags.map((tag) => _buildTag(tag)).toList(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Note seulement (pas de temps de livraison ni de frais)
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: Color(0xFFFF7F50),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${business.rating}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${business.reviewCount} ${"Ratings".tr()}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTag(String tag) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Text(
        tag.tr(),
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
    );
  }
}
