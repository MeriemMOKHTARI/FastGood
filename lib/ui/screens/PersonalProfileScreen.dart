import 'package:datalock/config/config.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/user_service.dart';
import 'package:easy_localization/easy_localization.dart';

class PersonalProfileScreen extends StatefulWidget {
  @override
  _PersonalProfileScreenState createState() => _PersonalProfileScreenState();
}

class _PersonalProfileScreenState extends State<PersonalProfileScreen> {
  final UserService _userService = UserService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
   final TextEditingController _familynameController = TextEditingController();

  String _selectedSex = 'Male';
  bool _isLoading = true;
  bool _isUpdating = false;
  String? cachedUserId;  // Stocke l'ID utilisateur récupéré du cache

  @override
  void initState() {
    super.initState();
    _loadCachedUserId();  // Charger l'ID utilisateur avant de récupérer les données du profil
  }


  Future<void> _loadCachedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('cached_user_id');

    print("ID utilisateur récupéré du cache : $userId");

    if (userId == null || userId.isEmpty) {
      print("Attention : L'ID utilisateur en cache est null ou vide");
      return;
    }

    setState(() {
      cachedUserId = userId;
    });

    _loadUserProfile();  
  }

  Future<void> _loadUserProfile() async {
    if (cachedUserId == null) {
      print("Impossible de charger le profil : ID utilisateur non disponible");
      return;
    }

    setState(() => _isLoading = true);

    final profileData = await _userService.getUserProfile();
    if (profileData != null) {
      setState(() {
        _nameController.text = profileData['user_name'] ?? '';
        _familynameController.text = profileData['family_name'] ?? '';
       // _phoneController.text = profileData['phone_user' ] ?? '';
        _emailController.text = profileData['email'] ?? '';
        _selectedSex = profileData['sex'] ?? '';

      });
    } else {
      print(" Erreur : Impossible de récupérer les données de l'utilisateur");
    }

    setState(() => _isLoading = false);
  }

  Future<void> _updateProfile() async {
    setState(() => _isUpdating = true);

    if (cachedUserId == null) {
      print("Impossible de mettre à jour : ID utilisateur non disponible");
      setState(() => _isUpdating = false);
      return;
    }

    final status = await _userService.updateUserProfile(
      name: _nameController.text,
      forename: _familynameController.text,
     // phoneNumber: _phoneController.text,
      email: _emailController.text,
      sex: _selectedSex,
    );

    if (status == '200') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profil mis à jour avec succès !')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(' Erreur lors de la mise à jour du profil.')),
      );
    }

    setState(() => _isUpdating = false);
  }


@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFFFF7F50)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile'.tr(),
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFFFF7F50)))
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Name'.tr()),
                    _buildTextField(_nameController, 'Enter_your_name'.tr()),
                    SizedBox(height: 20),
                    _buildLabel('forename'.tr()),
                    _buildTextField(_familynameController, 'Enter_your_username'.tr()),
                    SizedBox(height: 20),
                    _buildLabel('Gender'.tr()),
                    _buildGenderDropdown(),
                    SizedBox(height: 20),
                    _buildLabel('Email'.tr()),
                    _buildTextField(_emailController, 'Enter your email'.tr()),
                    SizedBox(height: 32),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadUserProfile,
        backgroundColor: Colors.white,
        child: Icon(Icons.refresh, color: Color(0xFFFF7F50)),
        mini: true,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
  return Container(
    decoration: BoxDecoration(
      color: Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(12),
    ),
    padding: EdgeInsets.symmetric(horizontal: 16),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _selectedSex.isNotEmpty ? _selectedSex : null, // Assurez-vous que null est géré
        isExpanded: true,
        icon: Icon(Icons.keyboard_arrow_down),
        hint: Text("Select Gender"), // Afficher une invite par défaut
        items: [
          DropdownMenuItem(
            value: "M",
            child: Text("Male"),
          ),
          DropdownMenuItem(
            value: "F",
            child: Text("Female"),
          ),
        ],
        onChanged: (String? newValue) {
          setState(() {
            _selectedSex = newValue ?? ''; // Permettre la réinitialisation
          });
        },
      ),
    ),
  );
}


  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isUpdating ? null : _updateProfile,
        child: _isUpdating
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Save'.tr(),
                selectionColor: Colors.white,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Config.themeData.scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}