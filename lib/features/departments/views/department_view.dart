import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/centrix_theme.dart';
import '../../../core/widgets/centrix_page_header.dart';

import '../../auth/viewmodels/auth_view_model.dart';
import '../models/department.dart';
import '../viewmodels/department_view_model.dart';

class DepartmentView extends StatelessWidget {
  const DepartmentView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthViewModel>();
    final viewModel = context.watch<DepartmentViewModel>();
    final token = auth.session!.token;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Departamentos'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: viewModel.isLoading ? null : () => viewModel.load(token),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: _content(context, viewModel, auth, token),
        ),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    DepartmentViewModel viewModel,
    AuthViewModel auth,
    String token,
  ) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.errorMessage != null) {
      return _StatusMessage(
        icon: Icons.cloud_off_outlined,
        title: viewModel.requiresLogin
            ? 'Sesión vencida'
            : 'No pudimos cargar los departamentos',
        message: viewModel.errorMessage!,
        buttonLabel: viewModel.requiresLogin
            ? 'Volver a iniciar sesión'
            : 'Reintentar',
        onPressed: viewModel.requiresLogin
            ? auth.logout
            : () => viewModel.load(token),
      );
    }
    if (viewModel.total == 0) {
      return _StatusMessage(
        icon: Icons.apartment_outlined,
        title: 'Aún no hay departamentos',
        message: 'Cuando se registren departamentos, aparecerán aquí.',
        buttonLabel: 'Actualizar',
        onPressed: () => viewModel.load(token),
      );
    }

    final departments = viewModel.visibleDepartments;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CentrixPageHeader(
            title: 'Catálogo de departamentos',
            description: 'Encuentra el área que necesitas en un solo lugar.',
            icon: Icons.apartment_rounded,
            eyebrow: 'DIRECTORIO',
          ),
          const SizedBox(height: 14),
          Text(
            '${departments.length} de ${viewModel.total} departamentos',
            style: const TextStyle(
              color: CentrixColors.forest,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Buscar departamento',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: viewModel.setSearchQuery,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: departments.isEmpty
                ? const Center(
                    child: Text(
                      'No hay departamentos que coincidan con la búsqueda.',
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => viewModel.load(token),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: departments.length,
                      itemBuilder: (context, index) {
                        return _DepartmentCard(department: departments[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _DepartmentCard extends StatelessWidget {
  const _DepartmentCard({required this.department});

  final Department department;

  @override
  Widget build(BuildContext context) {
    final description = department.description?.trim();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: CentrixColors.mint,
          child: Icon(Icons.apartment_outlined, color: CentrixColors.leaf),
        ),
        title: Text(department.name),
        subtitle: description == null || description.isEmpty
            ? null
            : Text(description),
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton(onPressed: onPressed, child: Text(buttonLabel)),
          ],
        ),
      ),
    );
  }
}
