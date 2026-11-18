import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/centrix_theme.dart';
import '../../../core/widgets/centrix_glass.dart';
import '../../auth/viewmodels/auth_view_model.dart';
import '../models/manager_demo_model.dart';
import '../models/manager_request.dart';
import '../viewmodels/manager_view_model.dart';
import 'widgets/manager_widgets.dart';

class ManagerWorkspaceView extends StatelessWidget {
  const ManagerWorkspaceView({
    super.key,
    required this.section,
    required this.child,
    required this.isPreview,
  });
  final ManagerSection section;
  final Widget child;
  final bool isPreview;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1080;
    final auth = context.watch<AuthViewModel>();
    final vm = context.watch<ManagerViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.hub_rounded, color: CentrixColors.leaf),
            const SizedBox(width: 10),
            const Text('Centrix'),
            if (wide) ...[
              const SizedBox(width: 18),
              Container(width: 1, height: 20, color: CentrixColors.sage),
              const SizedBox(width: 18),
              const Text(
                'Espacio de Gerente',
                style: TextStyle(fontSize: 13, color: CentrixColors.forest),
              ),
            ],
          ],
        ),
        actions: [
          if (MediaQuery.sizeOf(context).width > 530)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: CentrixColors.raised,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'VISTA PREVIA',
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          IconButton(
            tooltip: 'Restablecer datos de ejemplo',
            onPressed: vm.reset,
            icon: const Icon(Icons.restart_alt_rounded),
          ),
          IconButton(
            key: const Key('exit-manager-preview'),
            tooltip: isPreview ? 'Salir de vista previa' : 'Volver al inicio',
            onPressed: () =>
                context.go(auth.isAuthenticated ? '/home' : '/login'),
            icon: const Icon(Icons.exit_to_app_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: wide
          ? null
          : Drawer(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _ManagerNavigation(
                    section: section,
                    isPreview: isPreview,
                    inDrawer: true,
                  ),
                ),
              ),
            ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (wide)
            SizedBox(
              width: 260,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 0, 20),
                child: _ManagerNavigation(
                  section: section,
                  isPreview: isPreview,
                ),
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              key: const Key('manager-scroll'),
              padding: EdgeInsets.all(wide ? 30 : 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1320),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: CentrixColors.surface.withValues(alpha: .8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: CentrixColors.outline),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.visibility_outlined,
                              size: 16,
                              color: CentrixColors.leaf,
                            ),
                            SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                'Datos de ejemplo · Los cambios solo se conservan durante esta vista previa.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: CentrixColors.forest,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      child,
                      const SizedBox(height: 32),
                      const Center(
                        child: Text(
                          'CENTRIX  /  TU EQUIPO, EN EQUILIBRIO',
                          style: TextStyle(
                            fontSize: 9,
                            letterSpacing: 2,
                            color: CentrixColors.forest,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManagerNavigation extends StatelessWidget {
  const _ManagerNavigation({
    required this.section,
    required this.isPreview,
    this.inDrawer = false,
  });
  final ManagerSection section;
  final bool isPreview, inDrawer;
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ManagerViewModel>();
    return CentrixGlass(
      dark: true,
      radius: 26,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.space_dashboard_outlined,
                  color: CentrixColors.sage,
                  size: 21,
                ),
                SizedBox(width: 10),
                Text(
                  'GERENTE',
                  style: TextStyle(
                    color: CentrixColors.mint,
                    fontSize: 11,
                    letterSpacing: 1.8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'MI DEPARTAMENTO',
              style: TextStyle(
                color: CentrixColors.sage,
                fontSize: 9,
                letterSpacing: 1.8,
              ),
            ),
            const SizedBox(height: 16),
            for (final item in ManagerSection.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: item == section
                      ? CentrixColors.mint.withValues(alpha: .15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    key: Key('manager-nav-${item.name}'),
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      if (inDrawer) Navigator.pop(context);
                      context.go(
                        '${isPreview ? '/preview' : ''}/gerente/${item.path}',
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            managerSectionIcon(item),
                            size: 19,
                            color: item == section
                                ? CentrixColors.mint
                                : CentrixColors.sage,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item == ManagerSection.requests
                                  ? 'Solicitudes'
                                  : item.label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: item == section
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: item == section
                                    ? Colors.white
                                    : CentrixColors.forest,
                              ),
                            ),
                          ),
                          if (item == ManagerSection.approvals)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: CentrixColors.sage.withValues(
                                  alpha: .25,
                                ),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Text(
                                '${vm.pending.length}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: CentrixColors.mint,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: CentrixColors.mint.withValues(alpha: .12),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.apartment_rounded,
                    color: CentrixColors.sage,
                    size: 24,
                  ),
                  SizedBox(height: 14),
                  Text(
                    ManagerDemoModel.department,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Planeación y seguimiento',
                    style: TextStyle(color: CentrixColors.sage, fontSize: 10),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: CentrixColors.sage,
                  child: Text(
                    'SV',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: CentrixColors.ink,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Gerente de ejemplo',
                    style: TextStyle(color: CentrixColors.mint, fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
