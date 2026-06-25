import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth_viewmodel.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _emailController;
  late final TextEditingController _cepController;
  late final TextEditingController _logradouroController;
  late final TextEditingController _bairroController;
  late final TextEditingController _localidadeController;
  late final TextEditingController _ufController;
  final TextEditingController _senhaAtualController = TextEditingController();
  final TextEditingController _novaSenhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController =
      TextEditingController();

  bool _senhaAtualVisible = false;
  bool _novaSenhaVisible = false;
  bool _confirmarSenhaVisible = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthViewModel>().currentUser;
    _nomeController = TextEditingController(text: user?.nome ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _cepController = TextEditingController(text: user?.cep ?? '');
    _logradouroController = TextEditingController(text: user?.logradouro ?? '');
    _bairroController = TextEditingController(text: user?.bairro ?? '');
    _localidadeController = TextEditingController(text: user?.localidade ?? '');
    _ufController = TextEditingController(text: user?.uf ?? '');
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _cepController.dispose();
    _logradouroController.dispose();
    _bairroController.dispose();
    _localidadeController.dispose();
    _ufController.dispose();
    _senhaAtualController.dispose();
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<AuthViewModel>();
    final novaSenha = _novaSenhaController.text.trim();

    if (novaSenha.isNotEmpty) {
      final sucesso = await viewModel.changePassword(
        _senhaAtualController.text,
        novaSenha,
      );
      if (!sucesso) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Senha atual incorreta'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    await viewModel.updateProfile(
      nome: _nomeController.text.trim(),
      email: _emailController.text.trim(),
      cep: _cepController.text.trim(),
      logradouro: _logradouroController.text.trim(),
      bairro: _bairroController.text.trim(),
      localidade: _localidadeController.text.trim(),
      uf: _ufController.text.trim(),
    );

    if (mounted) {
      _senhaAtualController.clear();
      _novaSenhaController.clear();
      _confirmarSenhaController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil atualizado com sucesso'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _buscarCep() async {
    final cep = _cepController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cep.length != 8) return;
    final address = await context.read<AuthViewModel>().fetchCep(cep);
    if (!mounted) return;
    if (address == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CEP não encontrado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    _logradouroController.text = address.logradouro ?? '';
    _bairroController.text = address.bairro ?? '';
    _localidadeController.text = address.localidade ?? '';
    _ufController.text = address.uf ?? '';
  }

  void _mostrarOpcoesImagem(AuthViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_rounded),
                title: const Text('Câmera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _selecionarImagem(viewModel, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: const Text('Galeria'),
                onTap: () {
                  Navigator.of(context).pop();
                  _selecionarImagem(viewModel, ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selecionarImagem(
    AuthViewModel viewModel,
    ImageSource source,
  ) async {
    final sucesso = await viewModel.updateProfileImage(source);
    if (!mounted || sucesso) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Não foi possível atualizar a foto de perfil'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _logout() async {
    await context.read<AuthViewModel>().logout();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Meu Perfil',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, viewModel, _) {
          final user = viewModel.currentUser;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: () => _mostrarOpcoesImagem(viewModel),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor:
                                user?.fotoUrl != null &&
                                    user!.fotoUrl!.isNotEmpty
                                ? Colors.transparent
                                : const Color(0xFF1976D2),
                            backgroundImage:
                                user?.fotoUrl != null &&
                                    user!.fotoUrl!.isNotEmpty
                                ? NetworkImage(user.fotoUrl!)
                                : null,
                            child:
                                user?.fotoUrl != null &&
                                    user!.fotoUrl!.isNotEmpty
                                ? null
                                : const Icon(
                                    Icons.person_rounded,
                                    size: 48,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (user != null)
                        Center(
                          child: Text(
                            'R.A.: ${user.ra}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      const SizedBox(height: 28),
                      const _SectionTitle(title: 'Dados Pessoais'),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: user?.ra ?? '',
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: 'R.A.',
                          prefixIcon: const Icon(Icons.badge_outlined),
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nomeController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Nome Completo',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: viewModel.validateFullName,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'E-mail',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: viewModel.validateEmail,
                      ),
                      const SizedBox(height: 28),
                      const _SectionTitle(title: 'Endereço'),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _cepController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'CEP',
                          prefixIcon: const Icon(Icons.location_on_outlined),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search_rounded),
                            onPressed: viewModel.isLoading ? null : _buscarCep,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _logradouroController,
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: 'Logradouro',
                          prefixIcon: Icon(Icons.signpost_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _bairroController,
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: 'Bairro',
                          prefixIcon: Icon(Icons.map_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _localidadeController,
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: 'Cidade',
                          prefixIcon: Icon(Icons.location_city_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _ufController,
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: 'Estado (UF)',
                          prefixIcon: Icon(Icons.flag_outlined),
                        ),
                      ),
                      const SizedBox(height: 28),
                      const _SectionTitle(title: 'Alterar Senha'),
                      const SizedBox(height: 4),
                      Text(
                        'Preencha apenas se desejar alterar a senha.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _senhaAtualController,
                        obscureText: !_senhaAtualVisible,
                        decoration: InputDecoration(
                          labelText: 'Senha Atual',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _senhaAtualVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () => setState(
                              () => _senhaAtualVisible = !_senhaAtualVisible,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (_novaSenhaController.text.trim().isNotEmpty &&
                              (value == null || value.isEmpty)) {
                            return 'Senha atual é obrigatória para alterar a senha';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _novaSenhaController,
                        obscureText: !_novaSenhaVisible,
                        decoration: InputDecoration(
                          labelText: 'Nova Senha',
                          prefixIcon: const Icon(Icons.lock_reset_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _novaSenhaVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () => setState(
                              () => _novaSenhaVisible = !_novaSenhaVisible,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            if (value.trim().length < 6) {
                              return 'Nova senha deve ter no mínimo 6 caracteres';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmarSenhaController,
                        obscureText: !_confirmarSenhaVisible,
                        decoration: InputDecoration(
                          labelText: 'Confirmar Nova Senha',
                          prefixIcon: const Icon(Icons.lock_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _confirmarSenhaVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () => setState(
                              () =>
                                  _confirmarSenhaVisible =
                                      !_confirmarSenhaVisible,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (_novaSenhaController.text.trim().isNotEmpty) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Confirme a nova senha';
                            }
                            if (value.trim() !=
                                _novaSenhaController.text.trim()) {
                              return 'As senhas não coincidem';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: viewModel.isLoading ? null : _salvar,
                          icon: viewModel.isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save_rounded),
                          label: const Text('Salvar Alterações'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: viewModel.isLoading ? null : _logout,
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text('Sair'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1976D2),
      ),
    );
  }
}
