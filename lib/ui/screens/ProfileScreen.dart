import 'package:datalock/config/config.dart';
import 'package:datalock/main.dart';
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
import '../../services/user_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);


  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = "";
  String userSurname = "";

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final userService = UserService(); // Créer une instance
final user = await userService.getUserProfile();
   if (user != null) {
      setState(() {
        userName = user['user_name'] ?? "";
        userSurname = user['family_name'] ?? ""; // Vérifie le bon nom de clé
      });
    }
  }

   Future<void> _openYassirApp() async {
    const appScheme = 'yassirrider://';
    const playStoreUrl = 'https://play.google.com/store/apps/details?id=com.yatechnologies.yassir_rider&pcampaignid=web_share';
    
    try {
      final bool launched = await launchUrl(Uri.parse(appScheme), mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(Uri.parse(playStoreUrl), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      await launchUrl(Uri.parse(playStoreUrl), mode: LaunchMode.externalApplication);
    }
  }

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
                  'Bonjour'.tr(),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$userName $userSurname',
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
                    title: 'Mon profil'.tr(),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PersonalProfileScreen(), //const PersonalProfileScreen(),
                      ),
                    ),
                  ),
                  ProfileMenuItem(
                    icon: Icons.location_on_outlined,
                    title: 'Mes adresses'.tr(),
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
              title: 'Devenir partenaire'.tr(),
              onTap: _openYassirApp,
            ),
            ProfileMenuItem(
              icon: Icons.delivery_dining_outlined,
              title: 'Devenir livreur'.tr(),
              onTap: _openYassirApp,
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
                    title: 'Mes commandes'.tr(),
                    onTap: () {},
                  ),
                  ProfileMenuItem(
                    icon: Icons.favorite_outline,
                    title: 'Mes favoris'.tr(),
                    onTap: () {},
                  ),
                  ProfileMenuItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications'.tr(),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsScreen(),
                      ),
                    ),
                  ),
                  ProfileMenuItem(
                    icon: Icons.language_outlined,
                    title: 'Langues'.tr(),
                    onTap: () {},
                  ),
                  ProfileMenuItem(
                    icon: Icons.card_giftcard_outlined,
                    title: 'Invitez & Gagnez'.tr(),
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
                'Se déconnecter'.tr(),
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

    if (sessionId != null) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      try {
        final authService = AuthService();
        final client = Client()
            .setEndpoint(Config.appwriteEndpoint)
            .setProject(Config.appwriteProjectId)
            .setSelfSigned(status: true);

        final account = Account(client);
        final databases = Databases(client);

        final result = await authService.logoutUser(
          sessionId,
          account,
          databases,
        );

        // Close loading indicator
        Navigator.of(context).pop();

        if (result['status'] == '200') {
          // Clear all stored data
          await _clearUserData();

          // Navigate to authentication screen
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => AuthenticationScreen(
                account: account,
                databases: databases,
                functions: Functions(client),
              ),
            ),
            (route) => false, // Remove all previous routes
          );
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de la déconnexion. Veuillez réessayer.')),
          );
        }
      } catch (e) {
        // Close loading indicator
        Navigator.of(context).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Une erreur est survenue: $e')),
        );
      }
    } else {
      // No session ID found, just clear data and navigate to login
      await _clearUserData();

      final client = Client()
          .setEndpoint(Config.appwriteEndpoint)
          .setProject(Config.appwriteProjectId)
          .setSelfSigned(status: true);

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
    }
  }

  Future<void> _clearUserData() async {
    // Clear secure storage
    final storage = FlutterSecureStorage();
    await storage.deleteAll();

    // Clear shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_user_id');
    // You can add more keys to remove if needed

    print('User data cleared successfully');
  }
}

