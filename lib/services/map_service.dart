import 'dart:convert';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/config.dart';

class MapService {
  final storage = FlutterSecureStorage();

  Future<String?> _getCachedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('cached_user_id');
  }

Future<Map<String, dynamic>> addFavoriteAddress({
    required String label,
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    Client client = Client()
        .setEndpoint(Config.appwriteEndpoint)
        .setProject(Config.appwriteProjectId)
        .setSelfSigned(status: true);
    Functions functions = Functions(client);

    try {
      final userId = await storage.read(key: 'user_id');
      print('Retrieved user_id for adding address: $userId');

      if (userId == null) {
        print('No user_id found in storage');
        return {'status': '400', 'message': 'User ID not found'};
      }

      // The label should already be correctly set by the caller
      print('Adding address - Label: $label, UserId: $userId, Address: $address');

      Execution result = await functions.createExecution(
        functionId: "manageFavoriteAddresses",
        body: json.encode({
          "user_id": userId,
          "label": label,
          "address": address,
          "latitude": latitude,
          "longitude": longitude,
        }),
        method: ExecutionMethod.pOST,
      );

      print('Add address response body: ${result.responseBody}');

      if (result.status == 'completed') {
        final responseBody = json.decode(result.responseBody);
        print('Add address parsed response: $responseBody');
        
        // Return the actual status from the backend
        if (responseBody['status'] == '200') {
          return {
            'status': '200',
            'data': responseBody['data']
          };
        } else if (responseBody['status'] == '601') {
          return {
            'status': '601',
            'message': 'Home address already exists'
          };
        } else if (responseBody['status'] == '602') {
          return {
            'status': '602',
            'message': 'Work address already exists'
          };
        } else {
          return {
            'status': responseBody['status'] ?? 'ERR',
            'message': responseBody['message'] ?? 'Unknown error'
          };
        }
      }
      return {'status': 'ERR', 'message': 'Function execution failed'};
    } catch (e) {
      print('Error in addFavoriteAddress: $e');
      return {'status': 'ERR', 'message': e.toString()};
    }
  }





  

 Future<Map<String, dynamic>> updateFavoriteAddress({
  required String documentId,
  required String address,
  required double latitude,
  required double longitude,
}) async {
  Client client = Client()
      .setEndpoint(Config.appwriteEndpoint)
      .setProject(Config.appwriteProjectId)
      .setSelfSigned(status: true);
  Functions functions = Functions(client);

  try {
    print('Updating address with ID: $documentId');

    Execution result = await functions.createExecution(
      functionId: "manageFavoriteAddresses",
      body: json.encode({
        "document_id": documentId,
        "address": address,
        "latitude": latitude,
        "longitude": longitude,
      }),
      method: ExecutionMethod.pUT,
    );
    
    if (result.status == 'completed') {
      final responseBody = json.decode(result.responseBody);
      print('Update address response: $responseBody');
      
      if (responseBody['status'] == '200') {
        return {
          'status': '200',
          'data': responseBody['data']
        };
      } else if (responseBody['status'] == '400') {
        return {
          'status': '400',
          'message': 'Missing required fields'
        };
      } 
      return {'status': 'ERR', 'message': 'Unknown error'};
    } 
    return {'status': 'ERR', 'message': 'Function execution failed'};
  } catch (e) {
    print('Error in updateFavoriteAddress: $e');
    return {'status': 'ERR', 'message': e.toString()};
  }
}



Future<Map<String, dynamic>> getFavoriteAddresses(
    String entry_id,
    Account account,
    Databases databases
  ) async {
    Client client = Client()
        .setEndpoint(Config.appwriteEndpoint)
        .setProject(Config.appwriteProjectId)
        .setSelfSigned(status: true);
    Functions functions = Functions(client);

    try {
      Execution result = await functions.createExecution(
        functionId: "manageFavoriteAddresses",
        body: json.encode({
          "user_id": entry_id,
        }),
        method: ExecutionMethod.gET,
      );
      
      if (result.status == 'completed') {
        final responseBody = json.decode(result.responseBody);
        print('Response from getFavoriteAddresses: $responseBody');
        
        if (responseBody['status'] == '200') {
          return {
            'status': '200',
            'data': responseBody['data']
          };
        } else if (responseBody['status'] == '400') {
          return {
            'status': '400',
            'message': 'Missing required fields'
          };
        } 
        return {'status': 'ERR', 'message': 'Unknown error'};
      } 
      return {'status': 'ERR', 'message': 'Function execution failed'};
    } catch (e) {
      print('Error in getFavoriteAddresses: $e');
      return {'status': 'ERR', 'message': e.toString()};
    }
  }
  Future<Map<String, dynamic>> deleteFavoriteAddress(String documentId) async {
  Client client = Client()
      .setEndpoint(Config.appwriteEndpoint)
      .setProject(Config.appwriteProjectId)
      .setSelfSigned(status: true);
  Functions functions = Functions(client);

  try {
    print('Deleting address with ID: $documentId');

    Execution result = await functions.createExecution(
      functionId: "manageFavoriteAddresses",
      body: json.encode({
        "document_id": documentId,
      }),
      method: ExecutionMethod.dELETE,
    );
    
    if (result.status == 'completed') {
      final responseBody = json.decode(result.responseBody);
      print('Delete address response: $responseBody');
      
      if (responseBody['status'] == '200') {
        return {
          'status': '200',
          'message': 'Address deleted successfully'
        };
      } else if (responseBody['status'] == '400') {
        return {
          'status': '400',
          'message': 'Missing required fields'
        };
      } 
      return {'status': 'ERR', 'message': 'Unknown error'};
    } 
    return {'status': 'ERR', 'message': 'Function execution failed'};
  } catch (e) {
    print('Error in deleteFavoriteAddress: $e');
    return {'status': 'ERR', 'message': e.toString()};
  }
}


}

