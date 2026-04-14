import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  static final RegExp _emailRegExp = RegExp(
    r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+$",
  );

  final AuthRepository _repository = AuthRepository();

  bool _isLoading = false;
  bool _isLoggedIn = false;
  User? _currentUser;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  User? get currentUser => _currentUser;

  String? validateRa(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'RA é obrigatório';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    if (value.length < 6) {
      return 'Senha deve ter no mínimo 6 caracteres';
    }
    return null;
  }

  String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome completo é obrigatório';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email é obrigatório';
    }
    if (!_emailRegExp.hasMatch(value.trim())) {
      return 'Email inválido';
    }
    return null;
  }

  String? validateBirthDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Data de nascimento é obrigatória';
    }
    final parts = value.split('/');
    if (parts.length != 3) {
      return 'Data inválida';
    }
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) {
      return 'Data inválida';
    }
    if (year < 1900 || year > DateTime.now().year) {
      return 'Data inválida';
    }
    final date = DateTime.tryParse(
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}',
    );
    if (date == null ||
        date.day != day ||
        date.month != month ||
        date.year != year) {
      return 'Data inválida';
    }
    return null;
  }

  Future<void> checkLoginStatus() async {
    final ra = await _repository.loadLoggedUser();
    if (ra != null) {
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  Future<bool> loginUser(String ra, String password) async {
    _setLoading(true);
    final user = _repository.login(ra, password);
    if (user != null) {
      _currentUser = user;
      _isLoggedIn = true;
      await _repository.saveLoggedUser(ra);
    }
    _setLoading(false);
    return user != null;
  }

  Future<String?> registerUser({
    required String fullName,
    required String email,
    required String birthDate,
    required String password,
  }) async {
    _setLoading(true);
    final parts = birthDate.split('/');
    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[2]);
    final ra = await _repository.register(
      nome: fullName,
      email: email,
      dataNascimento: DateTime(year, month, day),
      senha: password,
    );
    _setLoading(false);
    return ra;
  }

  Future<void> logout() async {
    _currentUser = null;
    _isLoggedIn = false;
    await _repository.clearLoggedUser();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
