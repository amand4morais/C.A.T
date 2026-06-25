class User {
  final String ra;
  final String nome;
  final String email;
  final DateTime dataNascimento;
  final String senha;
<<<<<<< HEAD
=======
  final String? fotoUrl;
>>>>>>> part3
  final String? cep;
  final String? logradouro;
  final String? bairro;
  final String? localidade;
  final String? uf;
<<<<<<< HEAD
  final String? fotoUrl;
=======
>>>>>>> part3

  const User({
    required this.ra,
    required this.nome,
    required this.email,
    required this.dataNascimento,
    required this.senha,
<<<<<<< HEAD
=======
    this.fotoUrl,
>>>>>>> part3
    this.cep,
    this.logradouro,
    this.bairro,
    this.localidade,
    this.uf,
<<<<<<< HEAD
    this.fotoUrl,
=======
>>>>>>> part3
  });
}
