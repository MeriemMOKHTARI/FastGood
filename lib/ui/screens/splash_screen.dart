import 'package:datalock/ui/screens/HomeContent.dart';
import 'package:datalock/ui/screens/HomePage.dart';
import 'package:datalock/ui/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'authentication_screen.dart';
import '../../config/config.dart';
import 'package:appwrite/appwrite.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/widgets.dart' as flutter_widgets;

class SplashScreen extends StatefulWidget {
  final Account account;
  final Databases databases;
  final Functions functions;

  const SplashScreen({
    Key? key,
    required this.account,
    required this.databases,
    required this.functions,
  }) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final storage = FlutterSecureStorage();

  Future<bool> checkUserSession() async {

    final sessionID = await storage.read(key: 'session_id');
    if (sessionID!=null) {
      return true;
    } else {
      print('No session found, navigate to login screen.');
      return false;
    }
  }

  Future<void> setAppLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString('locale');

    final systemLocale = flutter_widgets.WidgetsBinding.instance.window.locale;
    final languageCode = systemLocale.languageCode;

    if (savedLocale == null || savedLocale.isEmpty) {
      if (['en', 'fr', 'ar', 'es'].contains(languageCode)) {
        await context.setLocale(flutter_widgets.Locale(languageCode));
        await prefs.setString('locale', languageCode);
      } else {
        await context.setLocale(flutter_widgets.Locale('en'));
        await prefs.setString('locale', 'en');
      }
    } else {
      await context.setLocale(flutter_widgets.Locale(savedLocale));
    }
  }

  @override
  void initState() {
    super.initState();
    initializeApp();
  }

  void initializeApp() async {
    await setAppLanguage();
    await Future.delayed(Duration(seconds: 2)); 
    navigateBasedOnSession();
  }

  void navigateBasedOnSession() async {
    final isLoggedIn = await checkUserSession();

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OnboardingScreen(),
          //  AuthenticationScreen(
          //   account: widget.account,
          //   databases: widget.databases,
          //   functions: widget.functions,
          // ),
        ),
      );
    }
  }

  final account = Config.getAccount();


   @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/onboard.png',
          fit: BoxFit.cover, // Permet de couvrir tout l'écran
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Container(
        width: 180,
        height: 180,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: ClipOval( 
          child: Image.asset(
            'assets/images/logo.png', 
            fit: BoxFit.cover,        
          ),
        ),
      ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

}


