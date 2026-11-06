import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/centrix_theme.dart';
import '../../auth/viewmodels/auth_view_model.dart';
import '../models/dashboard_module.dart';
import '../viewmodels/dashboard_view_model.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final dashboard = DashboardViewModel(auth.session!.user);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.layers_rounded, size: 22),
            SizedBox(width: 10),
            Text('Centrix'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: auth.logout,
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
            children: [
              _WelcomePanel(dashboard: dashboard),
              const SizedBox(height: 34),
              Row(
                children: [
                  Container(
                    width: 5,
                    height: 28,
                    decoration: BoxDecoration(
                      color: CentrixColors.leaf,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Áreas de tu cuenta', style: theme.textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 6),
              const Padding(
                padding: EdgeInsets.only(left: 17),
                child: Text(
                  'Selecciona lo que deseas hacer hoy.',
                  style: TextStyle(color: CentrixColors.forest),
                ),
              ),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dashboard.modules.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 360,
                  mainAxisExtent: 190,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  final module = dashboard.modules[index];
                  return _ModuleCard(
                    key: Key('module-${module.name}'),
                    module: module,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel({required this.dashboard});

  final DashboardViewModel dashboard;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [CentrixColors.ink, CentrixColors.deep, CentrixColors.leaf],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TU ESPACIO DE TRABAJO',
            style: TextStyle(
              color: CentrixColors.sage,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Hola, ${dashboard.displayName}',
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(color: CentrixColors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bienvenido a Centrix. Da seguimiento a tu trabajo desde un solo lugar.',
            style: TextStyle(color: CentrixColors.mint, height: 1.45),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CentrixColors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: CentrixColors.mint.withValues(alpha: 0.18),
              ),
            ),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 10,
              children: [
                const Icon(
                  Icons.account_circle_outlined,
                  color: CentrixColors.mint,
                ),
                Text(
                  dashboard.user.email,
                  style: const TextStyle(color: CentrixColors.white),
                ),
                for (final role in dashboard.roleLabels)
                  Chip(label: Text(role)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({super.key, required this.module});

  final DashboardModule module;

  @override
  Widget build(BuildContext context) {
    final info = switch (module) {
      DashboardModule.createTicket => (
        icon: Icons.add_circle_outline,
        title: 'Crear ticket',
        description: 'Reporta una nueva incidencia al departamento indicado.',
      ),
      DashboardModule.myTickets => (
        icon: Icons.confirmation_number_outlined,
        title: 'Mis tickets',
        description: 'Consulta las incidencias que has reportado.',
      ),
      DashboardModule.pendingTickets => (
        icon: Icons.pending_actions_outlined,
        title: 'Tickets pendientes',
        description: 'Revisa las incidencias abiertas o en revisión.',
      ),
      DashboardModule.departmentTickets => (
        icon: Icons.view_list_outlined,
        title: 'Tickets por departamento',
        description: 'Consulta las incidencias de un departamento.',
      ),
      DashboardModule.departments => (
        icon: Icons.apartment_outlined,
        title: 'Departamentos',
        description: 'Conoce los departamentos disponibles.',
      ),
      DashboardModule.createUser => (
        icon: Icons.person_add_alt_1_outlined,
        title: 'Crear usuario',
        description: 'Da de alta una nueva cuenta.',
      ),
    };
    final target = switch (module) {
      DashboardModule.createTicket => '/tickets/new',
      DashboardModule.myTickets => '/tickets/my',
      DashboardModule.pendingTickets => '/tickets/pending',
      DashboardModule.departmentTickets => '/tickets/department',
      DashboardModule.departments => '/departments',
      DashboardModule.createUser => '/admin/users/new',
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(target),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: CentrixColors.mint,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(info.icon, color: CentrixColors.leaf),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_outward_rounded,
                    color: CentrixColors.leaf,
                  ),
                ],
              ),
              const Spacer(),
              Text(info.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(
                info.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: CentrixColors.forest,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
