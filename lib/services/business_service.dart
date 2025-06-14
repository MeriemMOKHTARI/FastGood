import 'package:appwrite/appwrite.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/config.dart';
import '../data/models/category_model.dart';
import '../data/models/business_model.dart';

class BusinessService {
  final storage = FlutterSecureStorage();
  
  // Méthode pour récupérer les catégories principales
  Future<List<Category>> getMainCategories() async {
    Client client = Client()
        .setEndpoint(Config.appwriteEndpoint)
        .setProject(Config.appwriteProjectId)
        .setSelfSigned(status: true);
    Databases databases = Databases(client);
    
    try {
      // Simuler des données pour le moment
      // Dans une vraie application, vous feriez une requête à votre base de données
      return [
        Category(id: '1', name: 'Restaurant'),
        Category(id: '2', name: 'Healthy food'),
        Category(id: '3', name: 'Home made'),
        Category(id: '4', name: 'Patisserie'),
        Category(id: '5', name: 'Asian food'),
      ];
    } catch (e) {
      print('Erreur lors de la récupération des catégories: $e');
      return [];
    }
  }
  
  // Méthode pour récupérer les sous-catégories d'une catégorie
  Future<List<Category>> getSubCategories(String categoryId) async {
    // Simuler des données pour le moment
    switch (categoryId) {
      case '1': // Restaurant
        return [
          Category(id: '101', name: 'Pizza', parentId: '1'),
          Category(id: '102', name: 'Burger', parentId: '1'),
          Category(id: '103', name: 'Tacos', parentId: '1'),
          Category(id: '104', name: 'Sushi', parentId: '1'),
          Category(id: '105', name: 'Grillades', parentId: '1'),
        ];
      case '2': // Healthy food / Gym Food
        return [
          Category(id: '201', name: 'Salades', parentId: '2'),
          Category(id: '202', name: 'Bowl', parentId: '2'),
          Category(id: '203', name: 'Protéiné', parentId: '2'),
          Category(id: '204', name: 'Low carb', parentId: '2'),
          Category(id: '205', name: 'Végétarien', parentId: '2'),
        ];
      case '3': // Home made
        return [
          Category(id: '301', name: 'Couscous', parentId: '3'),
          Category(id: '302', name: 'Tajines', parentId: '3'),
          Category(id: '303', name: 'Plats algériens', parentId: '3'),
          Category(id: '304', name: 'Soupes', parentId: '3'),
          Category(id: '305', name: 'Repas quotidiens', parentId: '3'),
        ];
      case '4': // Patisserie
        return [
          Category(id: '401', name: 'Gâteaux', parentId: '4'),
          Category(id: '402', name: 'Cookies', parentId: '4'),
          Category(id: '403', name: 'Viennoiseries', parentId: '4'),
          Category(id: '404', name: 'Tartes', parentId: '4'),
          Category(id: '405', name: 'Crêpes & Pancakes', parentId: '4'),
        ];
      case '5': // Asian food
        return [
          Category(id: '501', name: 'Sushi', parentId: '5'),
          Category(id: '502', name: 'Noodles', parentId: '5'),
          Category(id: '503', name: 'Riz', parentId: '5'),
          Category(id: '504', name: 'Curry', parentId: '5'),
        ];
      default:
        return [];
    }
  }
  
  // Méthode pour récupérer tous les businesses
  Future<List<Business>> getBusinesses() async {
    // Simuler des données pour le moment
    return [
      Business(
        id: '1',
        name: 'Cafe Brichor\'s',
        imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4',
        rating: 4.3,
        reviewCount: 200,
        tags: ['Chinese', 'American', 'Deshi food'],
        priceRange: 'Da',
        deliveryTime: 25,
        deliveryFee: 0,
        isFreeDelivery: true,
        categoryIds: ['1', '101'],
      ),
      Business(
        id: '2',
        name: 'Burger King',
        imageUrl: 'https://images.unsplash.com/photo-1550547660-d9450f859349',
        rating: 4.1,
        reviewCount: 150,
        tags: ['Fast Food', 'Burger'],
        priceRange: 'Da',
        deliveryTime: 20,
        deliveryFee: 2.5,
        isFreeDelivery: false,
        categoryIds: ['1', '102'],
      ),
      Business(
        id: '3',
        name: 'Pizza Hut',
        imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591',
        rating: 4.5,
        reviewCount: 300,
        tags: ['Italian', 'Pizza'],
        priceRange: 'Da',
        deliveryTime: 30,
        deliveryFee: 0,
        isFreeDelivery: true,
        categoryIds: ['1', '101'],
      ),
      // Business(
      //   id: '4',
      //   name: 'Algeria Kouskous',
      //   imageUrl: 'https://africankitchen.com/storage/71/Capture1.PNG',
      //   rating: 4.5,
      //   reviewCount: 300,
      //   tags: ['Kouskous', 'Home made', 'Algerian food'],
      //   priceRange: 'Da',
      //   deliveryTime: 30,
      //   deliveryFee: 0,
      //   isFreeDelivery: true,
      //   categoryIds: ['3', '301'],
      // ),
    ];
  }
  
  // Méthode pour récupérer les businesses par catégorie
  Future<List<Business>> getBusinessesByCategory(String categoryId) async {
    final allBusinesses = await getBusinesses();
    return allBusinesses.where((business) => business.categoryIds.contains(categoryId)).toList();
  }
  
  // Méthode pour récupérer les businesses par sous-catégorie
  Future<List<Business>> getBusinessesBySubCategory(String subCategoryId) async {
    final allBusinesses = await getBusinesses();
    return allBusinesses.where((business) => business.categoryIds.contains(subCategoryId)).toList();
  }
  
  // Méthode pour rechercher des businesses
  Future<List<Business>> searchBusinesses(String query) async {
    final allBusinesses = await getBusinesses();
    return allBusinesses
        .where((business) => business.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
