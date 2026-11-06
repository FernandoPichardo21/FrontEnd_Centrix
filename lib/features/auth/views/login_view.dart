import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/centrix_theme.dart';
import '../viewmodels/auth_view_model.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<AuthViewModel>().login(
      _emailController.text,
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    return Scaffold(
      backgroundColor: CentrixColors.ink,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [CentrixColors.ink, CentrixColors.deep, CentrixColors.leaf],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 760;
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: wide ? 1040 : 480),
                    child: wide
                        ? Row(
                            children: [
                              const Expanded(child: _BrandIntro(wide: true)),
                              const SizedBox(width: 32),
                              SizedBox(
                                width: 400,
                                child: _LoginCard(
                                  formKey: _formKey,
                                  emailController: _emailController,
                                  passwordController: _passwordController,
                                  obscurePassword: _obscurePassword,
                                  onTogglePassword: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                  onSubmit: _submit,
                                  auth: auth,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              const _BrandIntro(wide: false),
                              const SizedBox(height: 24),
                              _LoginCard(
                                formKey: _formKey,
                                emailController: _emailController,
                                passwordController: _passwordController,
                                obscurePassword: _obscurePassword,
                                onTogglePassword: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                onSubmit: _submit,
                                auth: auth,
                              ),
                            ],
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BrandIntro extends StatelessWidget {
  const _BrandIntro({required this.wide});

  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: wide
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Container(
          width: 66,
          height: 66,
          decoration: BoxDecoration(
            color: CentrixColors.mint,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.layers_rounded,
            size: 34,
            color: CentrixColors.ink,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Centrix',
          style: Theme.of(context).textTheme.headlineLarge
              ?.copyWith(color: CentrixColors.white, fontSize: wide ? 52 : 36),
        ),
        const SizedBox(height: 8),
        Text(
          wide
              ? 'Todo tu trabajo, en un solo lugar.'
              : 'Gestiona tus tickets con claridad.',
          textAlign: wide ? TextAlign.left : TextAlign.center,
          style: const TextStyle(
            color: CentrixColors.mint,
            fontSize: 17,
            height: 1.45,
          ),
        ),
        if (wide) ...[
          const SizedBox(height: 28),
          const Text(
            'Incidencias · Departamentos · Seguimiento',
            style: TextStyle(
              color: CentrixColors.sage,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onSubmit,
    required this.auth,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;
  final AuthViewModel auth;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'ACCESO A TU CUENTA',
                style: TextStyle(
                  color: CentrixColors.leaf,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Bienvenido de nuevo',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Inicia sesión para gestionar tus tickets.',
                style: TextStyle(color: CentrixColors.forest),
              ),
              const SizedBox(height: 28),
              TextFormField(
                key: const Key('email'),
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.mail_outline_rounded),
                ),
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                    return 'Ingresa un correo válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('password'),
                controller: passwordController,
                obscureText: obscurePassword,
                autofillHints: const [AutofillHints.password],
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    tooltip: obscurePassword
                        ? 'Mostrar contraseña'
                        : 'Ocultar contraseña',
                    onPressed: onTogglePassword,
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Ingresa tu contraseña'
                    : null,
                onFieldSubmitted: (_) => onSubmit(),
              ),
              if (auth.errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    auth.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: auth.isLoading ? null : onSubmit,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: auth.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Iniciar sesión'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
