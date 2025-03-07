import 'package:flutter/material.dart';
import '../../config/config.dart';

class IntroPage3 extends StatelessWidget {
  const IntroPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Image de fond
        Image.asset(
          'assets/images/onboard.png', // Remplacez par le nom de votre image
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/intro_page_1.png',
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                ),
                const Text(
                  Config.onboardingTitle1,
                  style: TextStyle(
                    fontSize: 20,
                      color: const Color(0xFF3A3A3A),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  Config.onboardingDesc1,
                  style: TextStyle(
                    fontSize: 16,
                   color: const Color(0xFF3A3A3A),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}