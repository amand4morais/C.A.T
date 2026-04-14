import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth_viewmodel.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onRegister(AuthViewModel viewModel) async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final ra = await viewModel.registerUser(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      birthDate: _birthDateController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted || ra == null) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Cadastro Realizado!'),
        content: Text(
          'Seu R.A é:\n\n$ra\n\nAnote-o, pois será necessário para o login.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: ra));
              Navigator.of(ctx).pop();
              context.go('/login');
            },
            child: const Text('Copiar e ir para Login'),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _border() {
    return OutlineInputBorder(borderRadius: BorderRadius.circular(12));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
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
                          'Efetivar Cadastro',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _fullNameController,
                          decoration: InputDecoration(
                            labelText: 'Nome Completo',
                            border: _border(),
                            enabledBorder: _border(),
                            focusedBorder: _border(),
                          ),
                          validator: viewModel.validateFullName,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: _border(),
                            enabledBorder: _border(),
                            focusedBorder: _border(),
                          ),
                          validator: viewModel.validateEmail,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _birthDateController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(8),
                            _DateTextInputFormatter(),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Data de Nascimento',
                            hintText: 'dd/mm/aaaa',
                            border: _border(),
                            enabledBorder: _border(),
                            focusedBorder: _border(),
                          ),
                          validator: viewModel.validateBirthDate,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            border: _border(),
                            enabledBorder: _border(),
                            focusedBorder: _border(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: viewModel.validatePassword,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: viewModel.isLoading
                                ? null
                                : () => _onRegister(viewModel),
                            child: viewModel.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Efetivar Cadastro'),
                          ),
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

class _DateTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 2 || i == 4) {
        buffer.write('/');
      }
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
