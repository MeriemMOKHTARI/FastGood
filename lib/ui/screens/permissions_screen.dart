import 'package:datalock/ui/screens/HomePage.dart';
import 'package:flutter/material.dart';
import '../widgets/permission_card.dart';
import '../../services/permissions_service.dart';
import './city_selection_screen.dart';
import 'HomeContent.dart';
import '../../config/config.dart';
import 'package:easy_localization/easy_localization.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  _PermissionsScreenState createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  final PermissionsService _permissionsService = PermissionsService();
  final account = Config.getAccount();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLocationPermission(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationPermission() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Config.themeData.primaryColor,
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.location_on,
                 color: Color.fromARGB(255, 255, 174, 123),
                size: 80,
              ),
              Icon(
                Icons.location_on,
                color: Config.themeData.scaffoldBackgroundColor,
                size: 48,
              ),
            ],
          ),
        ),
        SizedBox(height: 32),
        Text(
          'Bienvenue!'.tr(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'L_application_utilisera_votre_localisation_pour_trouver_des_établissements_près_de_vous,_et_vous_livrer_avec_prévision_à_votre_adresse.'.tr(),
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 40),
        ElevatedButton(
          onPressed: _handleLocationPermission,
          style: ElevatedButton.styleFrom(
            backgroundColor: Config.themeData.scaffoldBackgroundColor,
            foregroundColor: Colors.black,
            minimumSize: Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 0,
          ),
          child: Text(
            'Partager_votre_localisation'.tr(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(height: 16),
        TextButton(
          onPressed: _handleLocationDenied,
          child: Text(
            'ne pas partager ma localisation'.tr(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
  void _handleLocationPermission() async {
    bool hasPermission = await _permissionsService.requestLocationPermission();
    if (hasPermission) {
      _navigateToHomePage();
    } else {
      _navigateToCitySelection();
    }
  }

  void _handleLocationDenied() {
    _navigateToCitySelection();
  }

  void _navigateToCitySelection() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const CitySelectionScreen()),
    );
  }
  
  void _navigateToHomePage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) =>  HomePage()),
    );
  }
}

