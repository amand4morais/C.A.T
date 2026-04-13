import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth_viewmodel.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _raController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _raController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin(AuthViewModel viewModel) async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final success = await viewModel.login(
      ra: _raController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    if (success) {
      context.go('/home');
    }
  }

  OutlineInputBorder _border() {
    return OutlineInputBorder(borderRadius: BorderRadius.circular(12));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Consumer<AuthViewModel>(
                builder: (context, viewModel, _) {
                  return Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _raController,
                          decoration: InputDecoration(
                            labelText: 'Nome Completo',
                            border: _border(),
                            enabledBorder: _border(),
                            focusedBorder: _border(),
                          ),
                          validator: viewModel.validateRa,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            border: _border(),
                            enabledBorder: _border(),
                            focusedBorder: _border(),
                          ),
                          validator: viewModel.validatePassword,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: viewModel.isLoading
                                ? null
                                : () => _onLogin(viewModel),
                            child: viewModel.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Login'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: viewModel.isLoading
                              ? null
                              : () => context.push('/register'),
                          child: const Text('Não tem conta? Cadastre-se'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
