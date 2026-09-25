import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _hidePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login efetuado com sucesso.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Erro ao iniciar sessão.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
              Align(
              alignment: Alignment.topRight,
              child: DropdownButton<Locale>(
                value: context.watch<LocaleProvider>().locale,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(
                    value: Locale('pt', 'PT'),
                    child: Text('🇵🇹 Português'),
                  ),
                  DropdownMenuItem(
                    value: Locale('en', 'GB'),
                    child: Text('🇬🇧 English'),
                  ),
                  DropdownMenuItem(
                    value: Locale('es', 'ES'),
                    child: Text('🇪🇸 Español'),
                  ),
                ],
                onChanged: (locale) {
                  if (locale != null) {
                    context.read<LocaleProvider>().setLocale(locale);
                  }
                },
              ),
            ),
                const SizedBox(height: 100),

                // Logo
                Image.asset(
                  'assets/images/logo_letras.png',
                  height: 150,
                ),

                const SizedBox(height: 40),



                const SizedBox(height: 30),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !authProvider.isLoading,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email),
                    hintText: l10n.email,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.enterEmail;
                    }

                    if (!value.contains('@')) {
                      return l10n.invalidEmail;
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _hidePassword,
                  enabled: !authProvider.isLoading,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock),
                    hintText: l10n.password,
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _hidePassword = !_hidePassword;
                        });
                      },
                      icon: Icon(
                        _hidePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.enterPassword;
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _login,
                    child: authProvider.isLoading
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                        : Text(l10n.loginButton),
                  ),
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: authProvider.isLoading
                      ? null
                      : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterPage(),
                      ),
                    );
                  },
                  child: Text(
                    l10n.noAccount,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}