<<<<<<< HEAD
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
=======
import 'package:flutter/foundation.dart';
>>>>>>> part3
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/address_model.dart';
import '../models/user_model.dart' as app_models;

class AuthRepository {
  static const String _loggedUserKey = 'logged_user_ra';
  static const String _isAdminKey = 'logged_user_is_admin';

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
    final ra = await Supabase.instance.client.rpc('generate_next_ra') as String;
    await Supabase.instance.client.from('profiles').insert({
      'ra': ra,
      'nome': nome,
      'email': email,
      'data_nascimento': dataNascimento.toIso8601String(),
      'senha': senha,
      'role': 'aluno',
    });
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
<<<<<<< HEAD
=======
    String? fotoUrl,
>>>>>>> part3
    String? cep,
    String? logradouro,
    String? bairro,
    String? localidade,
    String? uf,
<<<<<<< HEAD
    String? fotoUrl,
=======
>>>>>>> part3
  }) async {
    final Map<String, dynamic> data = {};
    if (nome != null) data['nome'] = nome;
    if (email != null) data['email'] = email;
    if (senha != null) data['senha'] = senha;
<<<<<<< HEAD
=======
    if (fotoUrl != null) data['foto_url'] = fotoUrl;
>>>>>>> part3
    if (cep != null) data['cep'] = cep;
    if (logradouro != null) data['logradouro'] = logradouro;
    if (bairro != null) data['bairro'] = bairro;
    if (localidade != null) data['localidade'] = localidade;
    if (uf != null) data['uf'] = uf;
<<<<<<< HEAD
    if (fotoUrl != null) data['foto_url'] = fotoUrl;
=======
>>>>>>> part3
    if (data.isEmpty) return;
    await Supabase.instance.client.from('profiles').update(data).eq('ra', ra);
  }

  Future<Address?> fetchCep(String cep) async {
    final sanitized = cep.replaceAll(RegExp(r'[^0-9]'), '');
    if (sanitized.length != 8) return null;
    final response = await http.get(
      Uri.parse('https://viacep.com.br/ws/$sanitized/json/'),
    );
    if (response.statusCode != 200) return null;
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return null;
    if (decoded['erro'] == true) return null;
    return Address.fromJson(decoded);
  }

  Future<String> uploadProfileImage(
    String ra,
    Uint8List bytes,
    String fileName,
  ) async {
    final extension = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : 'jpg';
    final path = '$ra/${DateTime.now().millisecondsSinceEpoch}.$extension';
    final storage = Supabase.instance.client.storage.from('avatars');
    await storage.uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(
        upsert: true,
        contentType: 'image/${extension == 'jpg' ? 'jpeg' : extension}',
      ),
    );
    return storage.getPublicUrl(path);
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
<<<<<<< HEAD
=======
      fotoUrl: map['foto_url']?.toString(),
>>>>>>> part3
      cep: map['cep']?.toString(),
      logradouro: map['logradouro']?.toString(),
      bairro: map['bairro']?.toString(),
      localidade: map['localidade']?.toString(),
      uf: map['uf']?.toString(),
<<<<<<< HEAD
      fotoUrl: map['foto_url']?.toString(),
=======
>>>>>>> part3
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
      if (kDebugMode) {
        print('Erro ao fazer upload da foto de perfil: $e');
      }
      return null;
    }
  }
}
