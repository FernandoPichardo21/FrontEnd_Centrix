import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/centrix_page_header.dart';
import '../../../core/widgets/centrix_glass.dart';

import '../../auth/viewmodels/auth_view_model.dart';
import '../models/create_user_request.dart';
import '../viewmodels/create_user_view_model.dart';

class CreateUserView extends StatefulWidget {
  const CreateUserView({super.key});

  @override
  State<CreateUserView> createState() => _CreateUserViewState();
}

class _CreateUserViewState extends State<CreateUserView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _secondLastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _lastNameController.dispose();
    _secondLastNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final created = await context.read<CreateUserViewModel>().submit(
      CreateUserRequest(
        email: _emailController.text,
        password: _passwordController.text,
        nombre: _nameController.text,
        apellidoPat: _lastNameController.text,
        apellidoMat: _secondLastNameController.text,
        telefono: _phoneController.text,
      ),
      context.read<AuthViewModel>().session!.token,
    );
    if (created && mounted) {
      _passwordController.clear();
      _confirmPasswordController.clear();
    }
  }

  void _createAnother() {
    _emailController.clear();
    _nameController.clear();
    _lastNameController.clear();
    _secondLastNameController.clear();
    _phoneController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    context.read<CreateUserViewModel>().reset();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthViewModel>();
    final viewModel = context.watch<CreateUserViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Crear usuario')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: viewModel.createdUserId == null
              ? _form(context, viewModel, auth)
              : _SuccessMessage(
                  userId: viewModel.createdUserId!,
                  onCreateAnother: _createAnother,
                ),
        ),
      ),
    );
  }

  Widget _form(
    BuildContext context,
    CreateUserViewModel viewModel,
    AuthViewModel auth,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 48),
      child: CentrixGlass(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CentrixPageHeader(
                  title: 'Nueva cuenta',
                  description: 'Completa los datos de la persona que tendrá acceso a Centrix.',
                  icon: Icons.person_add_alt_1_rounded,
                  eyebrow: 'ADMINISTRACIÓN',
                ),
                const SizedBox(height: 28),
                TextFormField(
                  key: const Key('user-email'),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                        .hasMatch(email)) {
                      return 'Ingresa un correo válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('user-name'),
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Ingresa el nombre'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('user-last-name'),
                  controller: _lastNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Apellido paterno',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Ingresa el apellido paterno'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('user-second-last-name'),
                  controller: _secondLastNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Apellido materno (opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('user-phone'),
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  decoration: const InputDecoration(
                    labelText: 'Teléfono (opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('user-password'),
                  controller: _passwordController,
                  obscureText: !_showPassword,
                  autofillHints: const [AutofillHints.newPassword],
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      tooltip: _showPassword
                          ? 'Ocultar contraseña'
                          : 'Mostrar contraseña',
                      onPressed: () =>
                          setState(() => _showPassword = !_showPassword),
                      icon: Icon(
                        _showPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),
                  validator: (value) => value == null || value.length < 8
                      ? 'La contraseña debe tener al menos 8 caracteres'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('user-confirm-password'),
                  controller: _confirmPasswordController,
                  obscureText: !_showPassword,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar contraseña',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value != _passwordController.text
                      ? 'Las contraseñas no coinciden'
                      : null,
                ),
                if (viewModel.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    viewModel.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  if (viewModel.requiresLogin)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: auth.logout,
                        child: const Text('Volver a iniciar sesión'),
                      ),
                    ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: viewModel.isSubmitting ? null : _submit,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: viewModel.isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Crear usuario'),
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

class _SuccessMessage extends StatelessWidget {
  const _SuccessMessage({required this.userId, required this.onCreateAnother});

  final String userId;
  final VoidCallback onCreateAnother;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Usuario creado',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('La cuenta se registró correctamente.'),
            const SizedBox(height: 12),
            SelectableText(
              'ID del usuario: $userId',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onCreateAnother,
              child: const Text('Crear otro usuario'),
            ),
            TextButton(
              onPressed: () => context.go('/home'),
              child: const Text('Volver al dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
