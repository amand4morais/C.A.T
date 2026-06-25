import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/address_model.dart';

class ViaCepRepository {
  static final ViaCepRepository _instance = ViaCepRepository._internal();

  factory ViaCepRepository() => _instance;

  ViaCepRepository._internal();

  Future<AddressModel?> fetchAddress(String cep) async {
    final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanCep.length != 8) return null;
    try {
      final response = await http.get(
        Uri.parse('https://viacep.com.br/ws/$cleanCep/json/'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['erro'] == true) return null;
        return AddressModel.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
