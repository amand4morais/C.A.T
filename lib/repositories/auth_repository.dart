import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart' as app_models;

class AuthRepository {
  static const String _raCounterKey = 'ra_counter';
  static const String _loggedUserKey = 'logged_user_ra';
  static const String _isAdminKey = 'logged_user_is_admin';
  static const int _initialRaCounter = 1000;

  static final AuthRepository _instance = AuthRepository._internal();

  factory AuthRepository() => _instance;

  AuthRepository._internal();

  Future<void> init() async {}

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
    await Supabase.instance.client.from('profiles').insert({
      'ra': ra,
      'nome': nome,
      'email': email,
      'data_nascimento': dataNascimento.toIso8601String(),
      'senha': senha,
      'role': 'aluno',
    });
    await prefs.setInt(_raCounterKey, counter + 1);
    return ra;
  }

  Future<app_models.User?> login(String ra, String password) async {
    final response = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('ra', ra)
        .eq('senha', password)
        .maybeSingle();
    if (response == null) return null;
    return _mapToUser(response);
  }

  Future<app_models.User?> getUserByRa(String ra) async {
    final response = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('ra', ra)
        .maybeSingle();
    if (response == null) return null;
    return _mapToUser(response);
  }

  Future<void> updateUser(
    String ra, {
    String? nome,
    String? email,
    String? senha,
    String? fotoUrl,
    String? cep,
    String? logradouro,
    String? bairro,
    String? localidade,
    String? uf,
  }) async {
    final Map<String, dynamic> data = {};
    if (nome != null) data['nome'] = nome;
    if (email != null) data['email'] = email;
    if (senha != null) data['senha'] = senha;
    if (fotoUrl != null) data['foto_url'] = fotoUrl;
    if (cep != null) data['cep'] = cep;
    if (logradouro != null) data['logradouro'] = logradouro;
    if (bairro != null) data['bairro'] = bairro;
    if (localidade != null) data['localidade'] = localidade;
    if (uf != null) data['uf'] = uf;
    if (data.isEmpty) return;
    await Supabase.instance.client.from('profiles').update(data).eq('ra', ra);
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

  app_models.User _mapToUser(Map<String, dynamic> map) {
    return app_models.User(
      ra: map['ra']?.toString() ?? '',
      nome: map['nome']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      dataNascimento: map['data_nascimento'] != null
          ? DateTime.parse(map['data_nascimento'].toString())
          : DateTime(1900),
      senha: map['senha']?.toString() ?? '',
      fotoUrl: map['foto_url']?.toString(),
      cep: map['cep']?.toString(),
      logradouro: map['logradouro']?.toString(),
      bairro: map['bairro']?.toString(),
      localidade: map['localidade']?.toString(),
      uf: map['uf']?.toString(),
    );
  }

  Future<String?> uploadProfilePicture(
    String ra,
    Uint8List fileBytes,
    String fileName,
  ) async {
    try {
      final path = '$ra/$fileName';
      await Supabase.instance.client.storage
          .from('avatars')
          .uploadBinary(path, fileBytes, fileOptions: const FileOptions(upsert: true));
      final publicUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      return null;
    }
  }
}
