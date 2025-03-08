import 'package:datalock/config/config.dart';
import 'package:datalock/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'PersonalProfileScreen.dart';
import 'AdressesScreen.dart';
import 'NotificationsScreen.dart';
import '../widgets/ProfileMenuItem.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:appwrite/appwrite.dart';
import 'package:datalock/ui/screens/authentication_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header Section
            Row(
              children: [
                Icon(CupertinoIcons.sun_max, color: Color(0xFFFF7F50)),
                const SizedBox(width: 8),
                Text(
                  'Bonjour',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Okba GHODBANI',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Profile Section
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ProfileMenuItem(
                    icon: Icons.person_outline,
                    title: 'Mon profil',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>  PersonalProfileScreen(),
                      ),
                    ),
                  ),
                  ProfileMenuItem(
                    icon: Icons.location_on_outlined,
                    title: 'Mes adresses',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddressesScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Partner Section
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ProfileMenuItem(
                    icon: Icons.store_outlined,
                    title: 'Devenir partenaire',
                    onTap: () {},
                  ),
                  ProfileMenuItem(
                    icon: Icons.delivery_dining_outlined,
                    title: 'Devenir livreur',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Other Options Section
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ProfileMenuItem(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Mes commandes',
                    onTap: () {},
                  ),
                  ProfileMenuItem(
                    icon: Icons.favorite_outline,
                    title: 'Mes favoris',
                    onTap: () {},
                  ),
                  ProfileMenuItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsScreen(),
                      ),
                    ),
                  ),
                  ProfileMenuItem(
                    icon: Icons.language_outlined,
                    title: 'Langues',
                    onTap: () {},
                  ),
                  ProfileMenuItem(
                    icon: Icons.card_giftcard_outlined,
                    title: 'Invitez & Gagnez',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            TextButton.icon(
              onPressed: () {
                _showLogoutConfirmationDialog(context);
              },
              icon: Icon(
                Icons.logout,
                color: Colors.red[400],
              ),
              label: Text(
                'Se déconnecter',
                style: TextStyle(
                  color: Colors.red[400],
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation de déconnexion'),
          content: Text('Êtes-vous sûr de vouloir vous déconnecter?'),
          actions: <Widget>[
            TextButton(
              child: Text('Non'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Oui'),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await _logout(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    final storage = FlutterSecureStorage();
    final sessionId = await storage.read(key: 'session_id');

    // Store the client configuration outside the try block
    final client = Client()
        .setEndpoint(Config.appwriteEndpoint)
        .setProject(Config.appwriteProjectId)
        .setSelfSigned(status: true);

    // Show loading indicator
    BuildContext? dialogContext;
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          dialogContext = context;
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF7F50)),
            ),
          );
        },
      );
    }

    try {
      if (sessionId == null) {
        print('No session ID found, proceeding with local logout');
        // Clear all local data
        await _clearLocalData();
        
        // Dismiss loading indicator if it's showing
        if (dialogContext != null && Navigator.canPop(dialogContext!)) {
          Navigator.pop(dialogContext!);
        }
        
        // Navigate to login screen
        _navigateToLogin(client, context);
        return;
      }

      final authService = AuthService();
      final result = await authService.logoutUser(sessionId);
      print('Logout result: $result');

      // Clear local data regardless of server response
      await _clearLocalData();
      
      // Dismiss loading indicator if it's showing
      if (dialogContext != null && Navigator.canPop(dialogContext!)) {
        Navigator.pop(dialogContext!);
      }
      
      // Navigate to login screen
      _navigateToLogin(client, context);
    } catch (e) {
      print('Error during logout: $e');
      
      // Clear local data as fallback
      await _clearLocalData();
      
      // Dismiss loading indicator if it's showing
      if (dialogContext != null && Navigator.canPop(dialogContext!)) {
        Navigator.pop(dialogContext!);
      }
      
      // Navigate to login screen
      _navigateToLogin(client, context);
    }
  }

  Future<void> _clearLocalData() async {
    try {
      final storage = FlutterSecureStorage();
      await storage.deleteAll();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_user_id');
      
      print('Local data cleared successfully');
    } catch (e) {
      print('Error clearing local data: $e');
    }
  }

  void _navigateToLogin(Client client, BuildContext context) {
    if (!context.mounted) {
      print('Context is not mounted, cannot navigate');
      return;
    }
    
    try {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => AuthenticationScreen(
            account: Account(client),
            databases: Databases(client),
            functions: Functions(client),
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      print('Error navigating to login screen: $e');
    }
  }
}

