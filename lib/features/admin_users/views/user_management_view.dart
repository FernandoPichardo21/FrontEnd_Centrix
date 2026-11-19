import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/centrix_glass.dart';
import '../../../core/widgets/centrix_page_header.dart';
import '../../auth/viewmodels/auth_view_model.dart';
import '../../dashboard/views/widgets/dashboard_styles.dart';
import '../models/update_user_request.dart';
import '../models/user_list_item.dart';
import '../viewmodels/user_management_view_model.dart';

class UserManagementView extends StatefulWidget {
  const UserManagementView({super.key});

  @override
  State<UserManagementView> createState() => _UserManagementViewState();
}

class _UserManagementViewState extends State<UserManagementView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthViewModel>();
    final vm = context.watch<UserManagementViewModel>();
    final token = auth.session!.token;

    // Escuchar mensajes de error o éxito para mostrar SnackBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (vm.errorMessage != null && vm.users.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.errorMessage!),
            backgroundColor: const Color(0xFFC53030),
            behavior: SnackBarBehavior.floating,
          ),
        );
        vm.clearMessages();
      } else if (vm.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.successMessage!),
            backgroundColor: const Color(0xFF276749),
            behavior: SnackBarBehavior.floating,
          ),
        );
        vm.clearMessages();
      }
    });

    return Theme(
      data: DashboardColors.theme,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: CentrixPageHeader(
                        title: 'Gestión de usuarios',
                        description: 'Administra cuentas, roles y departamentos',
                        icon: Icons.manage_accounts_rounded,
                        eyebrow: 'ADMINISTRACIÓN',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: () => context.go('/admin/users/new'),
                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                    style: FilledButton.styleFrom(
                      backgroundColor: DashboardColors.mint,
                      foregroundColor: DashboardColors.background,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    label: const Text('Nuevo usuario'),
                  ),
                ),
                const SizedBox(height: 20),
                _buildFilterBar(context, vm, token),
                const SizedBox(height: 20),
                _buildContent(context, vm, auth, token),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar(
    BuildContext context,
    UserManagementViewModel vm,
    String token,
  ) {
    return CentrixGlass(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre o correo...',
                      prefixIcon: const Icon(Icons.search_rounded, color: DashboardColors.muted),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                vm.setSearch(token, '');
                              },
                            )
                          : null,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                      ),
                    ),
                    onSubmitted: (value) => vm.setSearch(token, value),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: () => vm.setSearch(token, _searchController.text),
                  style: FilledButton.styleFrom(
                    backgroundColor: DashboardColors.mint.withValues(alpha: 0.2),
                    foregroundColor: DashboardColors.mint,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  ),
                  child: const Text('Buscar'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Filtro de Rol
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 160, maxWidth: 220),
                  child: DropdownButtonFormField<String?>(
                    initialValue: vm.selectedRole,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Rol',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Todos los roles'),
                      ),
                      for (final r in [
                        'administrador',
                        'gerente',
                        'soporte_tecnico',
                        'colaborador',
                      ])
                        DropdownMenuItem<String?>(
                          value: r,
                          child: Text(_labelForRole(r)),
                        ),
                    ],
                    onChanged: (role) => vm.setRoleFilter(token, role),
                  ),
                ),

                // Filtro de Departamento
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 180, maxWidth: 260),
                  child: DropdownButtonFormField<String?>(
                    initialValue: vm.selectedDepartmentId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Departamento',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Todos los departamentos'),
                      ),
                      for (final dept in vm.departments)
                        DropdownMenuItem<String?>(
                          value: dept.departmentId,
                          child: Text(dept.name, overflow: TextOverflow.ellipsis),
                        ),
                    ],
                    onChanged: (deptId) => vm.setDepartmentFilter(token, deptId),
                  ),
                ),

                // Limpiar filtros
                if (vm.searchQuery.isNotEmpty ||
                    vm.selectedRole != null ||
                    vm.selectedDepartmentId != null)
                  TextButton.icon(
                    onPressed: () {
                      _searchController.clear();
                      vm.clearFilters(token);
                    },
                    icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
                    label: const Text('Limpiar filtros'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    UserManagementViewModel vm,
    AuthViewModel auth,
    String token,
  ) {
    if (vm.isLoading && vm.users.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (vm.errorMessage != null && vm.users.isEmpty) {
      return CentrixGlass(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFFF8D7B)),
              const SizedBox(height: 16),
              Text(
                vm.requiresLogin ? 'Sesión expirada' : 'Error al cargar usuarios',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                vm.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: DashboardColors.muted),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: vm.requiresLogin ? auth.logout : () => vm.loadInitial(token),
                child: Text(vm.requiresLogin ? 'Iniciar sesión' : 'Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (vm.users.isEmpty) {
      return CentrixGlass(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              const Icon(Icons.group_off_rounded, size: 54, color: DashboardColors.muted),
              const SizedBox(height: 16),
              const Text(
                'No se encontraron usuarios',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'No hay usuarios que coincidan con los criterios de búsqueda o filtros seleccionados.',
                textAlign: TextAlign.center,
                style: TextStyle(color: DashboardColors.muted),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () {
                  _searchController.clear();
                  vm.clearFilters(token);
                },
                child: const Text('Restablecer filtros'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final user in vm.users)
          _buildUserCard(context, vm, user, token),
        const SizedBox(height: 12),
        if (vm.pagination != null)
          _buildPaginationBar(context, vm, token),
      ],
    );
  }

  Widget _buildUserCard(
    BuildContext context,
    UserManagementViewModel vm,
    UserListItem user,
    String token,
  ) {
    final deptName = vm.departmentNameOf(user.departmentId);
    final roleColor = _colorForRole(user.role);

    return CentrixGlass(
      key: Key('user-card-${user.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: roleColor.withValues(alpha: 0.22),
              foregroundColor: roleColor,
              child: Text(
                user.initials,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    style: const TextStyle(color: DashboardColors.muted, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _buildRoleChip(user.role, roleColor),
                      if (user.departmentId != null && user.departmentId!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            deptName,
                            style: const TextStyle(
                              color: DashboardColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      if (user.tel case final phone? when phone.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.phone_outlined, size: 13, color: DashboardColors.muted),
                            const SizedBox(width: 3),
                            Text(
                              phone,
                              style: const TextStyle(
                                color: DashboardColors.muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  key: Key('edit-user-${user.id}'),
                  tooltip: 'Editar usuario',
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  color: DashboardColors.mint,
                  onPressed: () => _showEditDialog(context, vm, user, token),
                ),
                IconButton(
                  key: Key('delete-user-${user.id}'),
                  tooltip: 'Eliminar usuario',
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  color: const Color(0xFFFF8D7B),
                  onPressed: () => _showDeleteConfirmDialog(context, vm, user, token),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleChip(String role, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        _labelForRole(role),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPaginationBar(
    BuildContext context,
    UserManagementViewModel vm,
    String token,
  ) {
    final pag = vm.pagination!;
    return CentrixGlass(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total: ${pag.total} usuarios · Página ${pag.page} de ${pag.totalPages == 0 ? 1 : pag.totalPages}',
              style: const TextStyle(color: DashboardColors.muted, fontSize: 13),
            ),
            Row(
              children: [
                IconButton(
                  tooltip: 'Página anterior',
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: pag.hasPreviousPage && !vm.isLoading
                      ? () => vm.previousPage(token)
                      : null,
                ),
                Text(
                  '${pag.page}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                IconButton(
                  tooltip: 'Página siguiente',
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: pag.hasNextPage && !vm.isLoading
                      ? () => vm.nextPage(token)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    UserManagementViewModel vm,
    UserListItem user,
    String token,
  ) async {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: user.nombre);
    final lastNameCtrl = TextEditingController(text: user.apellidoPat ?? '');
    final secondLastNameCtrl = TextEditingController(text: user.apellidoMat ?? '');
    final phoneCtrl = TextEditingController(text: user.tel ?? '');
    String selectedRole = user.role;
    String? selectedDeptId = user.departmentId;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF0F1E17),
          title: Row(
            children: [
              const Icon(Icons.edit_note_rounded, color: DashboardColors.mint),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Editar usuario: ${user.displayName}',
                  style: const TextStyle(fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 480,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Nombre *'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa el nombre' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: lastNameCtrl,
                      decoration: const InputDecoration(labelText: 'Primer apellido'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: secondLastNameCtrl,
                      decoration: const InputDecoration(labelText: 'Segundo apellido'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: phoneCtrl,
                      decoration: const InputDecoration(labelText: 'Teléfono'),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      decoration: const InputDecoration(labelText: 'Rol *'),
                      items: [
                        for (final r in [
                          'administrador',
                          'gerente',
                          'soporte_tecnico',
                          'colaborador',
                        ])
                          DropdownMenuItem<String>(
                            value: r,
                            child: Text(_labelForRole(r)),
                          ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedRole = val;
                            if (val == 'administrador') {
                              selectedDeptId = null;
                            }
                          });
                        }
                      },
                    ),
                    if (selectedRole != 'administrador') ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String?>(
                        initialValue: selectedDeptId,
                        decoration: const InputDecoration(labelText: 'Departamento'),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Sin departamento'),
                          ),
                          for (final d in vm.departments)
                            DropdownMenuItem<String?>(
                              value: d.departmentId,
                              child: Text(d.name),
                            ),
                        ],
                        onChanged: (val) => setDialogState(() => selectedDeptId = val),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: vm.isActionLoading ? null : () => Navigator.pop(dialogCtx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: DashboardColors.mint,
                foregroundColor: DashboardColors.background,
              ),
              onPressed: vm.isActionLoading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      final ok = await vm.updateUser(
                        user.id,
                        UpdateUserRequest(
                          nombre: nameCtrl.text,
                          apellidoPat: lastNameCtrl.text.isNotEmpty ? lastNameCtrl.text : null,
                          apellidoMat: secondLastNameCtrl.text.isNotEmpty ? secondLastNameCtrl.text : null,
                          tel: phoneCtrl.text.isNotEmpty ? phoneCtrl.text : null,
                          role: selectedRole,
                          departmentId: selectedDeptId,
                        ),
                        token,
                      );
                      if (ok && context.mounted) {
                        Navigator.pop(dialogCtx);
                      }
                    },
              child: vm.isActionLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar cambios'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmDialog(
    BuildContext context,
    UserManagementViewModel vm,
    UserListItem user,
    String token,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF0F1E17),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFFF8D7B)),
            SizedBox(width: 8),
            Text('Eliminar usuario'),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar la cuenta de ${user.displayName}?\n\nEl usuario será dado de baja de forma segura (eliminación lógica) y ya no podrá iniciar sesión.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC53030),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await vm.deleteUser(user.id, token);
            },
            child: const Text('Eliminar cuenta'),
          ),
        ],
      ),
    );
  }

  static String _labelForRole(String role) => switch (role.toLowerCase().trim()) {
    'administrador' => 'Administrador',
    'gerente' => 'Gerente',
    'soporte_tecnico' => 'Soporte técnico',
    'colaborador' => 'Colaborador',
    _ => role,
  };

  static Color _colorForRole(String role) => switch (role.toLowerCase().trim()) {
    'administrador' => const Color(0xFF9F7AEA),
    'gerente' => const Color(0xFF63B3ED),
    'soporte_tecnico' => DashboardColors.mint,
    'colaborador' => const Color(0xFFCBD5E0),
    _ => Colors.white,
  };
}
