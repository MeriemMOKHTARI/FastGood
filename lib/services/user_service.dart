import 'dart:convert';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/config.dart';

class UserService {
  Client client = Client()
      .setEndpoint(Config.appwriteEndpoint)
      .setProject(Config.appwriteProjectId)
      .setSelfSigned(status: true);

  late Functions functions = Functions(client);
  final storage = FlutterSecureStorage();
   UserService() { // create a constructor to initialize functions
    functions = Functions(client);
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cachedUserId = prefs.getString('cached_user_id');

    if (cachedUserId == null || cachedUserId.isEmpty) {
      print(" Erreur : ID utilisateur non trouvé dans le cache !");
      return null;
    } else {
      print("id is  : $cachedUserId");
    }

    try {
      Execution result = await functions.createExecution(
        functionId: "manageUserProfile",
        body: json.encode({"user_id": cachedUserId}),
        method: ExecutionMethod.gET,
      );
      print("📡 Réponse Appwrite : ${result.responseBody}");//pour tester


      if (result.status == 'completed') {
        final responseBody = json.decode(result.responseBody);
        if (responseBody['status'] == '200') {
          print('Profil récupéré : ${responseBody['data']}');
          return responseBody['data'];
        } else {
          print(' Erreur: ${responseBody['status']}');
          return null;
        }
      } else {
        print('Échec de la fonction: ${result.status}');
        return null;
      }
    } catch (e) {
      print(' Erreur lors de la récupération du profil : $e');
      return null;
    }
  }

  //  Mettre à jour les informations du profil utilisateur
  Future<String> updateUserProfile({
    required String name,
    required String forename,
    required String email,
    required String sex,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final String? cachedUserId = prefs.getString('cached_user_id');

    if (cachedUserId == null || cachedUserId.isEmpty) return '401';

    try {
      Execution result = await functions.createExecution(
        functionId: "manageUserProfile",
        body: json.encode({
          "user_id": cachedUserId,
          "family_name": forename,
          "user_name": name,
          "email": email,
          "sex": sex,
        }),
        method: ExecutionMethod.pUT,
      );

      if (result.status == 'completed') {
        final responseBody = json.decode(result.responseBody);
        if (responseBody['status'] == '200') {
          print(' Profil mis à jour avec succès');
          return '200';
        } else {
          print('Erreur: ${responseBody['status']}');
          return responseBody['status'];
        }
      } else {
        print(' Échec de la fonction: ${result.status}');
        return '401';
      }
    } catch (e) {
      print(' Erreur lors de la mise à jour du profil : $e');
      return '401';
    }
  }
}
