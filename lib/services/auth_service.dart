import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  String? ipAddress;
  final FlutterSecureStorage storage = FlutterSecureStorage();

  Future<void> saveUserSession(String phoneNumber, String userId, String sessionId) async {
    try {
      await storage.write(key: 'phone_number', value: phoneNumber);
      await storage.write(key: 'user_id', value: userId);
      await storage.write(key: 'session_id', value: sessionId);
    } catch (e) {
      print('Error saving user session: $e');
    }
  }
  Future<String> sendSMS(
      String phoneNumber,
      String platform,
      String ipAdresseUser,
      String id,
      Account account,
      Databases databases) async {
    Client client = Client()
        .setEndpoint(Config.appwriteEndpoint)
        .setProject(Config.appwriteProjectId)
        .setSelfSigned(status: true);
    Functions functions = Functions(client);
    final storage = FlutterSecureStorage();
    // final id = await storage.read(key: 'user_id');
    await storage.write(key: 'phoneNumber' , value: phoneNumber);
    try {
      Execution result = await functions.createExecution(
        functionId: Config.SEND_SMS_FUNCTION_ID,
        body: json.encode({
          "phoneNumber": phoneNumber,
          "platform": "and",
          "ipAdressUser": "255.255.255.255",
          "entry_id": id
        }),
      );
      if (result.status == 'completed') {
        final responseBody = json.decode(result.responseBody);
        print("ccc,$responseBody");
        // print("entryyy,$id");
        if (responseBody['status'] == 200) {
          print('SMS sent successfully');
          return '200';
        } else if (responseBody['status'] == 333) {
          print('blocked user');
          return '333';
        } else {
          return '401';
        }
      } else {
        print('Function execution failed: ${result.status}');
        return '401';
      }
    } catch (e) {
      print('Error sending SMS: $e');
      return 'Error sending SMS: $e';
    }
  }

 Future<String> VerifyOTP(String phoneNumber, String otp,String id,  Account account, Databases databases) async {
    Client client = Client()
        .setEndpoint(Config.appwriteEndpoint)
        .setProject(Config.appwriteProjectId)
        .setSelfSigned(status: true);
    Functions functions = Functions(client);
    // final storage = FlutterSecureStorage();
    // final id = await storage.read(key: 'new_user_id');
    // if (id == null) {
    //   print('Error: new_user_id is null');
    //   return 'ERR_NULL_ID';
    // }
    // print('new id : ' + id);
    try {
      Execution result = await functions.createExecution(
        functionId: "6744a9f8001f83732f40",
        body: json.encode({
          "phoneNumber": phoneNumber,
          "otpInput": otp,
          "userID": id,
        }),
      );
      print('Function execution status: ${result.status}');
      print('CCCCCCCCCC ${result.responseBody}');
      if (result.status == 'completed') {
        final responseBody = json.decode(result.responseBody);
        print('Decoded response body: $responseBody');

        if (responseBody['status'] == '200') {
          return '200';
        } else if (responseBody['status'] == '400') {
          return '400';
        } else if (responseBody['status'] == '333') {
          return '333';
        } else {
          return 'ERR';
        }
      } else {
        return 'ERR';
      }
    } catch (e) {
      print('Error in VerifyOTP: $e');
      return 'ERR';
    }
  }


  void startCountdown(int seconds, Function(String) updateTime) {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds > 0) {
        seconds--;
        final minutes = seconds ~/ 60;
        final secs = seconds % 60;
        updateTime('$minutes:${secs.toString().padLeft(2, '0')}');
      } else {
        timer.cancel();
        updateTime('');
      }
    });
  }

  Future<String> saveUserInfos(
      String phoneNumber,
      String platform,
      String ipAdresseUser,
      String entry_id,
      String name,
      String familyname,
      String email,
      Account account,
      Databases databases) async {
    Client client = Client()
        .setEndpoint(Config.appwriteEndpoint)
        .setProject(Config.appwriteProjectId)
        .setSelfSigned(status: true);
    Functions functions = Functions(client);
    final storage = FlutterSecureStorage();
    final id = await storage.read(key: 'new_user_id');
    print('new id : '+ id!);
    try {
      Execution result = await functions.createExecution(
        functionId: "saveUserInfo",
        body: json.encode({
          "phoneNumber": phoneNumber,
          "user_id": id,
          "name": name,
          "familyName": familyname,
          "platform_user": platform,
          "ipadress_user": "255.255.255.255",
          "email": email
        }),
        method: ExecutionMethod.pOST,
      );
      if (result.status == 'completed') {
        final responseBody = json.decode(result.responseBody);
        print(responseBody);
        if (responseBody['status'] == '400') {
          print('please provide all informations');
          return '400';
          // Handle successful
        } else if (responseBody['status'] == '200') {
          print('infos saved successfully');

          return '200';
          // Handle SMS send failure
        } else {
          return 'ERR';
        }
      } else {
        print('Function execution failed: ${result.status}');
        return '401';
      }
    } catch (e) {
      // Handle error
      print('Error saving user infos: $e');
      return '401';
    }
  }

  Future<Map<String, String>> uploadUserSession(String phoneNumber, String entry_id,
      Account account, Databases databases) async {
    Client client = Client()
        .setEndpoint(Config.appwriteEndpoint)
        .setProject(Config.appwriteProjectId)
        .setSelfSigned(status: true);
    Functions functions = Functions(client);
    final id = await storage.read(key: 'new_user_id');
    try {
      Execution result = await functions.createExecution(
        functionId: "sessionManagement",
        body: json.encode({
          "phoneNumber": phoneNumber,
          "userID": id,
        }),
        method: ExecutionMethod.pOST,
      );
      if (result.status == 'completed') {
        final responseBody = json.decode(result.responseBody);
        print(responseBody);
        if (responseBody['status'] == '200') {
          await saveUserSession(phoneNumber, entry_id , responseBody['session_ID']);
          return {
            'status': '200',
            'session_id': responseBody['session_ID'] ?? '',
          };
        } else if (responseBody['status'] == '400') {
          return {
            'status': '400',
          };
        } else {
          return {'status':'ERR'};
        }
      } else {
        print('Function execution failed: ${result.status}');
        return {'status':'ERR'};
      }
    } catch (e) {
      // Handle error
      print('Error : $e');
      return {'status':'ERR'};
    }
  }

 
  Future<Map<String, String>> verifyUser(String name, String familyname, String phoneNumber,
      Account account, Databases databases) async {
    Client client = Client()
        .setEndpoint(Config.appwriteEndpoint)
        .setProject(Config.appwriteProjectId)
        .setSelfSigned(status: true);
    Functions functions = Functions(client);
    try {
      Execution result = await functions.createExecution(
        functionId: "verifyUser",
        body: json.encode({
          "phoneNumber": phoneNumber,
          "userName": name,
          "familyName": familyname,
        }),
        method: ExecutionMethod.pOST,
      );
      if (result.status == 'completed') {
        final responseBody = json.decode(result.responseBody);
        print(responseBody); 
        if (responseBody['status'] == '200') {
          print('User exists with matching all details');
          await storage.write(key: 'new_user_id', value: responseBody['userID']);
          return {
            'status': '200',
            'userID': responseBody['userID'] ?? '',
          };
        } else if (responseBody['status'] == '201') {
          print('Phone number matches, but name or family name does not match.');
          return {'status': '201'};
        } else if (responseBody['status'] == '202') {
          print('Name and family name match, but phone number does not');
          return {'status': '202'};
        } else if (responseBody['status'] == '333') {
          print('User does not exist at all');
          return {'status': '333'};
        } else {
          print('Function execution failed: ${result.status}');
          return {'status': '500'};
        }
      } else {
        print('Function execution failed: ${result.status}');
        return {'status': '500'};
      }
    } catch (e) {
      print('Error in verifyUser: $e');
      return {'status': '500'};
    }
  }


Future<Map<String, String>> logoutUser(String sessionsID,
      Account account, Databases databases) async {
    Client client = Client()
        .setEndpoint(Config.appwriteEndpoint)
        .setProject(Config.appwriteProjectId)
        .setSelfSigned(status: true);
    Functions functions = Functions(client);
    try {
      Execution result = await functions.createExecution(
        functionId: "sessionManagement",
        body: json.encode({
          "sessionID": sessionsID,
        }),
        method: ExecutionMethod.dELETE,
      );
      if (result.status == 'completed') {
        final responseBody = json.decode(result.responseBody);
        print(responseBody);
        if (responseBody['status'] == '200') {
          return {
            'status': '200',
          };
        } else if (responseBody['status'] == '400') {
          return {
            'status': '400',
          };
        } else {
          return {'status':'ERR'};
        }
      } else {
        print('Function execution failed: ${result.status}');
        return {'status':'ERR'};
      }
    } catch (e) {
      // Handle error
      print('Error : $e');
      return {'status':'ERR'};
    }
  }

// Update the verifyUserExistence method to ensure consistent caching
Future<Map<String, String>> verifyUserExistence(String phoneNumber) async {
  Client client = Client()
      .setEndpoint(Config.appwriteEndpoint)
      .setProject(Config.appwriteProjectId)
      .setSelfSigned(status: true);
  Functions functions = Functions(client);
  final storage = FlutterSecureStorage();
  final prefs = await SharedPreferences.getInstance(); // Add this line

  try {
    Execution result = await functions.createExecution(
      functionId: "verifyUserExistence",
      body: json.encode({
        "phoneNumber": phoneNumber,
      }),
      method: ExecutionMethod.pOST,
    );
    
    if (result.status == 'completed') {
      final responseBody = json.decode(result.responseBody);
      print('verifyUserExistence response: $responseBody');
      
      if (responseBody['status'] == '200') {
        print('User exists');
        String existingUserID = responseBody['userID'] ?? '';
        await storage.write(key: 'user_id', value: existingUserID);
        await prefs.setString('cached_user_id', existingUserID); // Add this line
        return {
          'status': '200',
          'userID': existingUserID,
        };
      } else if (responseBody['status'] == '333') {
        print('User does not exist');
        String newUserID = ID.unique();
        await storage.write(key: 'user_id', value: newUserID);
        await prefs.setString('cached_user_id', newUserID); // Add this line
        return {
          'status': '333',
          'userID': newUserID,
        };
      } else if (responseBody['status'] == '400') {
        print('Missing required fields');
        return {'status': '400', 'message': 'Missing required fields'};
      } else {
        print('Unknown status: ${responseBody['status']}');
        return {'status': 'ERR', 'message': 'Unknown error'};
      }
    } else {
      print('Function execution failed: ${result.status}');
      return {'status': 'ERR', 'message': 'Function execution failed'};
    }
  } catch (e) {
    print('Error in verifyUserExistence: $e');
    return {'status': 'ERR', 'message': e.toString()};
  }
}

// Add a utility method to help with caching user IDs
Future<void> cacheUserId(String userId) async {
  final storage = FlutterSecureStorage();
  final prefs = await SharedPreferences.getInstance();
  
  // Store in both secure storage and SharedPreferences for redundancy
  await storage.write(key: 'user_id', value: userId);
  await prefs.setString('cached_user_id', userId);
  
  print("User ID cached in multiple locations: $userId");
}
}

