import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class AuthRepository {
  static const String _raCounterKey = 'ra_counter';
  static const String _loggedUserKey = 'logged_user_ra';
  static const String _isAdminKey = 'logged_user_is_admin';
  static const String _usersKey = 'users_data';
  static const int _initialRaCounter = 1000;

  static final AuthRepository _instance = AuthRepository._internal();

  factory AuthRepository() => _instance;

  AuthRepository._internal() {
    _users.add(
      User(
        ra: 'admin',
        nome: 'Administrador',
        email: 'admin@cat.com',
        dataNascimento: DateTime(1990, 1, 1),
        senha: 'admin',
      ),
    );
  }

  final List<User> _users = [];

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList(_usersKey) ?? [];
    _users.clear();
    _users.add(
      User(
        ra: 'admin',
        nome: 'Administrador',
        email: 'admin@cat.com',
        dataNascimento: DateTime(1990, 1, 1),
        senha: 'admin',
      ),
    );
    for (final json in usersJson) {
      final map = jsonDecode(json) as Map<String, dynamic>;
      _users.add(
        User(
          ra: map['ra'] as String,
          nome: map['nome'] as String,
          email: map['email'] as String,
          dataNascimento: DateTime.parse(map['dataNascimento'] as String),
          senha: map['senha'] as String,
        ),
      );
    }
  }

  bool isAdmin(String ra) => ra == 'admin';

  Future<String> register({
    required String nome,
    required String email,
    required DateTime dataNascimento,
    required String senha,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final counter = prefs.getInt(_raCounterKey) ?? _initialRaCounter;
    final ra = counter.toString();
    final user = User(
      ra: ra,
      nome: nome,
      email: email,
      dataNascimento: dataNascimento,
      senha: senha,
    );
    _users.add(user);
    await prefs.setInt(_raCounterKey, counter + 1);
    final usersJson = _users
        .where((u) => u.ra != 'admin')
        .map(
          (u) => jsonEncode({
            'ra': u.ra,
            'nome': u.nome,
            'email': u.email,
            'dataNascimento': u.dataNascimento.toIso8601String(),
            'senha': u.senha,
          }),
        )
        .toList();
    await prefs.setStringList(_usersKey, usersJson);
    return ra;
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

  User? getUserByRa(String ra) {
    try {
      return _users.firstWhere((user) => user.ra == ra);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateUser(
    String ra, {
    String? nome,
    String? email,
    String? senha,
  }) async {
    final index = _users.indexWhere((u) => u.ra == ra);
    if (index == -1) return;
    final old = _users[index];
    _users[index] = User(
      ra: old.ra,
      nome: nome ?? old.nome,
      email: email ?? old.email,
      dataNascimento: old.dataNascimento,
      senha: senha ?? old.senha,
    );
    if (ra != 'admin') {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = _users
          .where((u) => u.ra != 'admin')
          .map(
            (u) => jsonEncode({
              'ra': u.ra,
              'nome': u.nome,
              'email': u.email,
              'dataNascimento': u.dataNascimento.toIso8601String(),
              'senha': u.senha,
            }),
          )
          .toList();
      await prefs.setStringList(_usersKey, usersJson);
    }
  }

  Future<void> saveLoggedUser(String ra) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_loggedUserKey, ra);
    await prefs.setBool(_isAdminKey, isAdmin(ra));
  }

  Future<String?> loadLoggedUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_loggedUserKey);
  }

  Future<bool> loadIsAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isAdminKey) ?? false;
  }

  Future<void> clearLoggedUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedUserKey);
    await prefs.remove(_isAdminKey);
  }
}
