import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/admin_user.dart';
import '../domain/create_user_request.dart';
import '../viewmodel/admin_users_viewmodel.dart';

const _navy = Color(0xFF112D4E);
const _blue = Color(0xFF2563EB);
const _teal = Color(0xFF0F766E);
const _background = Color(0xFFF3F6FA);
const _muted = Color(0xFF64748B);
const _border = Color(0xFFDCE4EE);

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        toolbarHeight: 72,
        backgroundColor: Colors.white,
        foregroundColor: _navy,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Administración de usuarios',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: _border),
        ),
      ),
      body: Consumer<AdminUsersViewModel>(
        builder: (context, viewModel, _) {
          return RefreshIndicator(
            onRefresh: viewModel.loadUsers,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 44),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PageHeading(
                          count: viewModel.users.length,
                          onAdd: () => _openCreateDialog(context),
                        ),
                        const SizedBox(height: 22),
                        _UsersPanel(viewModel: viewModel),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openCreateDialog(BuildContext context) async {
    final viewModel = context.read<AdminUsersViewModel>();
    viewModel.clearMessages();
    final created = await showDialog<bool>(
      context: context,
      barrierDismissible: !viewModel.isSubmitting,
      builder: (_) => ChangeNotifierProvider.value(
        value: viewModel,
        child: const _CreateUserDialog(),
      ),
    );

    if (created == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario creado correctamente'),
          backgroundColor: _teal,
        ),
      );
    }
  }
}

class _PageHeading extends StatelessWidget {
  const _PageHeading({required this.count, required this.onAdd});

  final int count;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 580;
        final information = Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFE7EEFB),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.groups_2_outlined, color: _blue),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Usuarios',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: _navy,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$count ${count == 1 ? 'usuario registrado' : 'usuarios registrados'}',
                    style: const TextStyle(color: _muted, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        );

        final addButton = FilledButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text('Agregar usuario'),
          style: FilledButton.styleFrom(
            backgroundColor: _blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17),
          ),
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              information,
              const SizedBox(height: 18),
              addButton,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: information),
            const SizedBox(width: 20),
            addButton,
          ],
        );
      },
    );
  }
}

class _UsersPanel extends StatelessWidget {
  const _UsersPanel({required this.viewModel});

  final AdminUsersViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F112D4E),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(),
          if (viewModel.isLoading)
            const Padding(
              padding: EdgeInsets.all(48),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (viewModel.loadError != null)
            _LoadError(
              message: viewModel.loadError!,
              onRetry: viewModel.loadUsers,
            )
          else if (viewModel.users.isEmpty)
            const _EmptyUsers()
          else
            _UsersList(users: viewModel.users),
        ],
      ),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          Icon(Icons.list_alt_rounded, color: _teal, size: 21),
          SizedBox(width: 10),
          Text(
            'Directorio de usuarios',
            style: TextStyle(
              color: _navy,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _UsersList extends StatelessWidget {
  const _UsersList({required this.users});

  final List<AdminUser> users;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          return Column(
            children: users.map((user) => _MobileUserCard(user: user)).toList(),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              const Color(0xFFF8FAFC),
            ),
            headingTextStyle: const TextStyle(
              color: _muted,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
            dataTextStyle: const TextStyle(color: _navy, fontSize: 13),
            columns: const [
              DataColumn(label: Text('USUARIO')),
              DataColumn(label: Text('TELÉFONO')),
              DataColumn(label: Text('ROL')),
              DataColumn(label: Text('REGISTRO')),
            ],
            rows: users
                .map(
                  (user) => DataRow(
                    cells: [
                      DataCell(_UserIdentity(user: user)),
                      DataCell(Text(
                        user.phone.isEmpty ? 'Sin teléfono' : user.phone,
                      )),
                      DataCell(_RoleBadge(role: user.role)),
                      DataCell(Text(_dateLabel(user.createdAt))),
                    ],
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}

class _MobileUserCard extends StatelessWidget {
  const _MobileUserCard({required this.user});

  final AdminUser user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: const Color(0xFFE7EEFB),
                foregroundColor: _navy,
                child: Text(
                  user.fullName.isEmpty ? '?' : user.fullName[0].toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _navy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 7),
                    _RoleBadge(role: user.role),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 16, color: _muted),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  user.phone.isEmpty ? 'Sin teléfono' : user.phone,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _muted, fontSize: 13),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _dateLabel(user.createdAt),
                style: const TextStyle(color: _muted, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UserIdentity extends StatelessWidget {
  const _UserIdentity({required this.user});

  final AdminUser user;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 19,
          backgroundColor: const Color(0xFFE7EEFB),
          foregroundColor: _navy,
          child: Text(
            user.fullName.isEmpty ? '?' : user.fullName[0].toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(width: 11),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 240),
          child: Text(
            user.fullName,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _navy,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F7F5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        role.replaceAll('_', ' ').toUpperCase(),
        style: const TextStyle(
          color: _teal,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _EmptyUsers extends StatelessWidget {
  const _EmptyUsers();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(52),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.group_off_outlined, size: 48, color: _muted),
            SizedBox(height: 14),
            Text(
              'No hay usuarios registrados',
              style: TextStyle(color: _navy, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(42),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.cloud_off_outlined,
                size: 44, color: Color(0xFFB42318)),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateUserDialog extends StatefulWidget {
  const _CreateUserDialog();

  @override
  State<_CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<_CreateUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _paternalLastName = TextEditingController();
  final _maternalLastName = TextEditingController();
  final _phone = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    _paternalLastName.dispose();
    _maternalLastName.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AdminUsersViewModel>();
    return Dialog(
      insetPadding: const EdgeInsets.all(18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 720),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogHeader(
              onClose: viewModel.isSubmitting
                  ? null
                  : () => Navigator.of(context).pop(false),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(26),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionTitle(
                        number: '01',
                        title: 'Información personal',
                      ),
                      const SizedBox(height: 18),
                      _responsiveFields([
                        _field(
                            _name, 'Nombre', Icons.person_outline, _required),
                        _field(_paternalLastName, 'Apellido paterno',
                            Icons.badge_outlined, _required),
                        _field(_maternalLastName, 'Apellido materno',
                            Icons.badge_outlined, null),
                        _field(_phone, 'Teléfono', Icons.phone_outlined,
                            _required, TextInputType.phone),
                      ]),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Divider(height: 1, color: _border),
                      ),
                      const _SectionTitle(
                        number: '02',
                        title: 'Credenciales de acceso',
                      ),
                      const SizedBox(height: 18),
                      _field(
                          _email,
                          'Correo electrónico',
                          Icons.alternate_email_rounded,
                          _validateEmail,
                          TextInputType.emailAddress),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _password,
                        obscureText: _obscurePassword,
                        validator: _validatePassword,
                        decoration: _decoration(
                          'Contraseña',
                          Icons.lock_outline_rounded,
                        ).copyWith(
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                      ),
                      if (viewModel.errorMessage != null) ...[
                        const SizedBox(height: 16),
                        _ErrorMessage(message: viewModel.errorMessage!),
                      ],
                      const SizedBox(height: 26),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: viewModel.isSubmitting
                                ? null
                                : () => Navigator.of(context).pop(false),
                            child: const Text('Cancelar'),
                          ),
                          const SizedBox(width: 12),
                          FilledButton.icon(
                            onPressed: viewModel.isSubmitting
                                ? null
                                : () => _submit(viewModel),
                            icon: viewModel.isSubmitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.person_add_alt_1_rounded),
                            label: Text(viewModel.isSubmitting
                                ? 'Guardando...'
                                : 'Crear usuario'),
                            style: FilledButton.styleFrom(
                              backgroundColor: _blue,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _responsiveFields(List<Widget> fields) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 560) {
          return Column(
            children: fields
                .map((field) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: field,
                    ))
                .toList(),
          );
        }
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: fields
              .map((field) => SizedBox(
                    width: (constraints.maxWidth - 16) / 2,
                    child: field,
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon,
    String? Function(String?)? validator, [
    TextInputType? keyboardType,
  ]) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _decoration(label, icon),
    );
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20, color: _muted),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _blue, width: 1.5),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Campo obligatorio' : null;

  String? _validateEmail(String? value) {
    if (_required(value) != null) return 'Campo obligatorio';
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value!.trim())
        ? null
        : 'Correo no válido';
  }

  String? _validatePassword(String? value) {
    if (_required(value) != null) return 'Campo obligatorio';
    return value!.length >= 6 ? null : 'Usa al menos 6 caracteres';
  }

  Future<void> _submit(AdminUsersViewModel viewModel) async {
    viewModel.clearMessages();
    if (!_formKey.currentState!.validate()) return;

    final created = await viewModel.createUser(
      CreateUserRequest(
        email: _email.text.trim().toLowerCase(),
        password: _password.text,
        firstName: _name.text.trim(),
        paternalLastName: _paternalLastName.text.trim(),
        maternalLastName: _maternalLastName.text.trim(),
        phone: _phone.text.trim(),
      ),
    );
    if (!mounted || !created) return;
    Navigator.of(context).pop(true);
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.onClose});

  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [_navy, Color(0xFF174A67)]),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0x26FFFFFF),
            foregroundColor: Colors.white,
            child: Icon(Icons.person_add_alt_1_rounded),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Text(
              'Agregar usuario',
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            onPressed: onClose,
            color: Colors.white,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.number, required this.title});

  final String number;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: const Color(0xFFE7EEFB),
          child: Text(
            number,
            style: const TextStyle(
              color: _blue,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 11),
        Text(
          title,
          style: const TextStyle(
            color: _navy,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3F2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFB42318)),
          const SizedBox(width: 9),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

String _dateLabel(DateTime? date) {
  if (date == null) return 'Sin fecha';
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year}';
}
