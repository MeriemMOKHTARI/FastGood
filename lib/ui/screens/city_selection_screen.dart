import 'package:appwrite/appwrite.dart';
import 'package:datalock/ui/screens/HomePage.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import 'HomeContent.dart';
import '../../config/config.dart';
import 'package:easy_localization/easy_localization.dart';

class CitySelectionScreen extends StatefulWidget {
  const CitySelectionScreen({super.key});

  @override
  _CitySelectionScreenState createState() => _CitySelectionScreenState();
}

class _CitySelectionScreenState extends State<CitySelectionScreen> {
  String? _selectedCity;
 final List<String> _algerianCities = [
 'adrar', 'ain_defla', 'ain_temouchent', 'alger', 'annaba', 'batna', 'bechar',
  'bejaia', 'biskra', 'blida', 'bordj_bou_arreridj', 'bouira', 'boumerdes',
  'chlef', 'constantine', 'djelfa', 'el_bayadh', 'el_oued', 'el_tarf', 'ghardaia',
  'guelma', 'illizi', 'jijel', 'khenchela', 'laghouat', 'mascara', 'medea',
  'mila', 'mostaganem', 'msila', 'naama', 'oran', 'ouargla', 'oum_el_bouaghi',
  'relizane', 'saida', 'setif', 'sidi_bel_abbes', 'skikda', 'souk_ahras',
  'tamanghasset', 'tebessa', 'tiaret', 'tindouf', 'tipaza', 'tissemsilt',
  'tizi_ouzou', 'tlemcen'
];
  final account = Config.getAccount();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:  Text('select_your_city'.tr()),
        backgroundColor: Config.themeData.primaryColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Veuillez_sélectionner_votre_ville'.tr(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Config.themeData.scaffoldBackgroundColor,
                ),
              ),
              const SizedBox(height: 20),
              DropdownButton<String>(
                value: _selectedCity,
                hint:  Text('choose_a_city'.tr()),
                isExpanded: true,
                items: _algerianCities.map((String city) {
                  return DropdownMenuItem<String>(
                    value: city,
                    child:  Text('cities.$city'.tr()),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCity = newValue;
                  });
                  if (newValue != null && newValue != 'oran'.tr()) {
                    _showCityAlert();
                  }
                },
              ),
              const SizedBox(height: 20),
              CustomButton(
                onPressed: _selectedCity != null ? _handleCityConfirmation : null,
                text: 'confirm_city'.tr(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCityAlert() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('service_unavailable'.tr()),
        content: Text('service_only_in_oran'.tr()),
        actions: <Widget>[
          TextButton(
            child:  Text('OK'.tr()),
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                // Reset the selected city to Oran after the alert
                _selectedCity = 'oran'.tr(); 
              });
            },
          ),
        ],
      );
    },
  );
}

void _handleCityConfirmation() {
  if (_selectedCity == 'oran'.tr()) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) =>  HomePage()),
    );
  } else {
    _showCityAlert();
  }
}
}