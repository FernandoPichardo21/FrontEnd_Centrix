import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/centrix_theme.dart';
import '../../../core/widgets/centrix_glass.dart';
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
            Icon(Icons.hub_rounded, size: 24),
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
          constraints: const BoxConstraints(maxWidth: 1180),
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
                  Text(
                    'Tu centro de operaciones',
                    style: theme.textTheme.titleLarge,
                  ),
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
                  maxCrossAxisExtent: 390,
                  mainAxisExtent: 220,
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
  Widget build(BuildContext context) => CentrixGlass(
    dark: true,
    radius: 32,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 780;
        return Stack(
          children: [
            const Positioned(
              right: -100,
              top: -160,
              child: Opacity(opacity: .12, child: CentrixOrbit(size: 480)),
            ),
            Padding(
              padding: EdgeInsets.all(wide ? 36 : 24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: CentrixColors.sage,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 9),
                            const Text(
                              'TU ESPACIO DE TRABAJO',
                              style: TextStyle(
                                color: CentrixColors.sage,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Hola, ${dashboard.displayName}',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: CentrixColors.white,
                                fontSize: wide ? 38 : 28,
                                letterSpacing: -1.3,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Todo conectado. Todo en movimiento.',
                          style: TextStyle(
                            color: CentrixColors.mint.withValues(alpha: .85),
                            height: 1.5,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 26),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .08),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: .14),
                            ),
                          ),
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 10,
                            runSpacing: 8,
                            children: [
                              const Icon(
                                Icons.fingerprint_rounded,
                                color: CentrixColors.sage,
                                size: 22,
                              ),
                              Text(
                                dashboard.user.email,
                                style: const TextStyle(
                                  color: CentrixColors.mint,
                                  fontSize: 13,
                                ),
                              ),
                              for (final role in dashboard.roleLabels)
                                Chip(label: Text(role)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (wide) ...[
                    const SizedBox(width: 28),
                    const CentrixOrbit(size: 220),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    ),
  );
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

    return CentrixGlass(
      interactive: true,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(target),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [CentrixColors.deep, CentrixColors.leaf],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: CentrixColors.leaf.withValues(alpha: .18),
                          blurRadius: 16,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(info.icon, color: CentrixColors.mint),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_outward_rounded,
                    color: CentrixColors.leaf,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                info.title,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontSize: 18, letterSpacing: -.4),
              ),
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
