import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart' as flutter_widgets;
import 'package:shared_preferences/shared_preferences.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  _LanguageSelectionScreenState createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selectedLanguage = '';
  bool _languageChanged = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  Future<void> _loadCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString('locale') ?? 'en';
    setState(() {
      _selectedLanguage = savedLocale;
    });
  }

  Future<void> _changeLanguage(String languageCode) async {
    if (_selectedLanguage == languageCode) return;
    
    await context.setLocale(flutter_widgets.Locale(languageCode));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', languageCode);
    setState(() {
      _selectedLanguage = languageCode;
      _languageChanged = true;
    });

    // Show a confirmation message
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Langue changée avec succès'.tr()),
          backgroundColor: Color(0xFFFF7F50),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _languageChanged);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context, _languageChanged);
            },
          ),
          title: Text(
            'Langues'.tr(),
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choisissez votre langue préférée'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 24),
              _buildLanguageOption('en', 'English', 'English'),
              _buildLanguageOption('fr', 'Français', 'French'),
              _buildLanguageOption('ar', 'العربية', 'Arabic'),
              _buildLanguageOption('es', 'Español', 'Spanish'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String code, String name, String englishName) {
    bool isSelected = _selectedLanguage == code;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? Color(0xFFFF7F50).withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Color(0xFFFF7F50) : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _changeLanguage(code),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                // You can add flag icons here if you have them
                // Image.asset('assets/flags/$code.png', width: 24, height: 24),
                // SizedBox(width: 12),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Color(0xFFFF7F50) : Colors.black,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '($englishName)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Spacer(),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: Color(0xFFFF7F50),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

