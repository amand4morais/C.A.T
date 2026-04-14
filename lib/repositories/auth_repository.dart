import '../models/user_model.dart';

class AuthRepository {
  static final AuthRepository _instance = AuthRepository._internal();

  factory AuthRepository() => _instance;

  AuthRepository._internal();

  final List<User> _users = [];

  void register(User user) {
    _users.add(user);
  }

  User? login(String ra, String password) {
    try {
      return _users.firstWhere(
        (user) => user.ra == ra && user.senha == password,
      );
    } catch (_) {
      return null;
    }
  }
}
