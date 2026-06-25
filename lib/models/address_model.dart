<<<<<<< HEAD
class Address {
  final String cep;
  final String logradouro;
  final String bairro;
  final String localidade;
  final String uf;

  const Address({
    required this.cep,
    required this.logradouro,
    required this.bairro,
    required this.localidade,
    required this.uf,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      cep: json['cep']?.toString() ?? '',
      logradouro: json['logradouro']?.toString() ?? '',
      bairro: json['bairro']?.toString() ?? '',
      localidade: json['localidade']?.toString() ?? '',
      uf: json['uf']?.toString() ?? '',
=======
class AddressModel {
  final String? cep;
  final String? logradouro;
  final String? bairro;
  final String? localidade;
  final String? uf;

  const AddressModel({
    this.cep,
    this.logradouro,
    this.bairro,
    this.localidade,
    this.uf,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      cep: json['cep']?.toString(),
      logradouro: json['logradouro']?.toString(),
      bairro: json['bairro']?.toString(),
      localidade: json['localidade']?.toString(),
      uf: json['uf']?.toString(),
>>>>>>> part3
    );
  }
}
