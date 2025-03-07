import 'package:flutter/foundation.dart';

class UserProvider extends ChangeNotifier {
  String? _userId;

  String? get userId => _userId;

  void setUserId(String? id) {
    _userId = id;
    print("ID utilisateur défini dans le provider : $_userId");
    notifyListeners();
  }
}

