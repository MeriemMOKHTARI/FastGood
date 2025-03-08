import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

// Import your other screen files
import 'CartScreen.dart';
import 'profileScreen.dart';
import 'HomeContent.dart';
import 'FavScreen.dart';
import 'package:easy_localization/easy_localization.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeContent(),
    CartScreen(),
    FavScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
       
        body: _screens[_currentIndex],
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: SalomonBottomBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              selectedItemColor: const Color(0xFFFF7F50),
              unselectedItemColor: Colors.grey,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              items: [
                SalomonBottomBarItem(
                  icon: const Icon(Icons.home_outlined),
                  title:  Text("Accueil".tr()),
                  selectedColor: const Color(0xFFFF7F50),
                ),
                SalomonBottomBarItem(
                  icon: const Icon(Icons.shopping_bag_outlined),
                  title:  Text("Carte".tr()),
                  selectedColor: const Color(0xFFFF7F50),
                ),
                SalomonBottomBarItem(
                  icon: const Icon(Icons.favorite_border_outlined),
                  title:  Text("favoris".tr()),
                  selectedColor: const Color(0xFFFF7F50),
                ),
                SalomonBottomBarItem(
                  icon: const Icon(Icons.person_2_outlined),
                  title:  Text("Profile".tr()),
                  selectedColor: const Color(0xFFFF7F50),
                ),
                
              ],
            ),
          ),
        ),
        extendBody: true,
      ),
    );
  }
}