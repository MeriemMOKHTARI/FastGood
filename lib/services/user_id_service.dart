class UserIdService {
  static final UserIdService _instance = UserIdService._internal();

  factory UserIdService() {
    return _instance;
  }

  UserIdService._internal();

  String? _userId;

  void setUserId(String userId) {
    _userId = userId;
    print("ID utilisateur défini dans le service : $userId");
  }

  String? getUserId() {
    print("Récupération de l'ID utilisateur depuis le service : $_userId");
    return _userId;
  }
}

