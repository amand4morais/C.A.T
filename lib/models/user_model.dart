class User {
  final String ra;
  final String nome;
  final String email;
  final DateTime dataNascimento;
  final String senha;
  final String? cep;
  final String? logradouro;
  final String? bairro;
  final String? localidade;
  final String? uf;
  final String? fotoUrl;

  const User({
    required this.ra,
    required this.nome,
    required this.email,
    required this.dataNascimento,
    required this.senha,
    this.cep,
    this.logradouro,
    this.bairro,
    this.localidade,
    this.uf,
    this.fotoUrl,
  });
}
