import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../auth/viewmodels/auth_view_model.dart';
import '../../tickets/models/ticket.dart';
import '../models/dashboard_module.dart';
import '../viewmodels/dashboard_view_model.dart';
import 'widgets/dashboard_module_info.dart';
import 'widgets/dashboard_styles.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});
  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _navigationIndex = 0;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final auth = context.read<AuthViewModel>();
    return Theme(
      data: DashboardColors.theme,
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            toolbarHeight: 58,
            automaticallyImplyLeading: false,
            titleSpacing: 20,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 29,
                  height: 29,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF144A34), Color(0xFF0B2219)],
                    ),
                    border: Border.all(
                      color: DashboardColors.neon.withValues(alpha: .22),
                    ),
                  ),
                  child: const Icon(
                    Icons.hub_rounded,
                    color: DashboardColors.neon,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 9),
                const Text(
                  'Centrix',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.7,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Avisos de tickets',
                onPressed: () => _showNotifications(context, vm),
                icon: Badge(
                  isLabelVisible: vm.pending.isNotEmpty,
                  smallSize: 6,
                  backgroundColor: const Color(0xFFFF8D7B),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: DashboardColors.mint,
                    size: 23,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 18, left: 4),
                child: InkWell(
                  key: const Key('dashboard-profile'),
                  customBorder: const CircleBorder(),
                  onTap: () => _showProfile(context, vm, auth),
                  child: CircleAvatar(
                    radius: 17,
                    backgroundColor: DashboardColors.mint,
                    child: Text(
                      vm.initials,
                      style: const TextStyle(
                        color: DashboardColors.background,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.5,
                colors: [
                  Color(0xFF123E2C),
                  Color(0xFF08150F),
                  DashboardColors.background,
                ],
                stops: [0, .45, 1],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 850;
                  final compact = !wide && constraints.maxHeight < 720;
                  final textScale =
                      MediaQuery.textScalerOf(context).scale(14) / 14;
                  final tileHeight =
                      (wide
                          ? 154.0
                          : compact
                          ? 90.0
                          : 108.0) *
                      math.max(1.0, textScale);
                  final columns = wide ? math.max(1, vm.homeModules.length) : 2;
                  final gap = compact ? 10.0 : 14.0;
                  return RefreshIndicator(
                    color: DashboardColors.neon,
                    backgroundColor: DashboardColors.surface,
                    onRefresh: () => vm.load(auth.session!.token),
                    child: SingleChildScrollView(
                      key: const Key('dashboard-body-scroll'),
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        wide ? 30 : 18,
                        8,
                        wide ? 30 : 18,
                        12,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 1100,
                            minHeight: math.min(
                              math.max(0.0, constraints.maxHeight - 20),
                              wide ? 780.0 : double.infinity,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _WelcomeCard(
                                viewModel: vm,
                                compact: compact,
                                wide: wide,
                              ),
                              SizedBox(height: gap + 2),
                              Row(
                                children: [
                                  Container(
                                    width: 3,
                                    height: 19,
                                    decoration: BoxDecoration(
                                      color: DashboardColors.neon,
                                      borderRadius: BorderRadius.circular(4),
                                      boxShadow: [
                                        BoxShadow(
                                          color: DashboardColors.neon
                                              .withValues(alpha: .35),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 9),
                                  const Expanded(
                                    child: Text(
                                      'Centro de operaciones',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: DashboardColors.mint,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -.4,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    key: const Key('dashboard-all-modules'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: DashboardColors.muted,
                                      minimumSize: const Size(0, 24),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 4,
                                      ),
                                    ),
                                    onPressed: () =>
                                        _showModules(context, vm.modules),
                                    child: const Text(
                                      'Ver todos',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: gap),
                              _PrimaryAction(
                                module: vm.primaryModule,
                                compact: compact,
                              ),
                              SizedBox(height: gap),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemCount: vm.homeModules.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: columns,
                                      mainAxisExtent: tileHeight,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                    ),
                                itemBuilder: (context, index) => _BentoTile(
                                  module: vm.homeModules[index],
                                  viewModel: vm,
                                  compact: compact,
                                ),
                              ),
                              SizedBox(height: gap + 2),
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Actividad reciente',
                                      style: TextStyle(
                                        color: DashboardColors.mint,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: vm.requiresLogin
                                        ? 'Iniciar sesión de nuevo'
                                        : 'Actualizar actividad',
                                    visualDensity: VisualDensity.compact,
                                    constraints: const BoxConstraints.tightFor(
                                      width: 27,
                                      height: 26,
                                    ),
                                    padding: EdgeInsets.zero,
                                    onPressed: vm.isLoading
                                        ? null
                                        : vm.requiresLogin
                                        ? auth.logout
                                        : () => vm.load(auth.session!.token),
                                    icon: Icon(
                                      vm.requiresLogin
                                          ? Icons.login_rounded
                                          : Icons.refresh_rounded,
                                      size: 17,
                                      color: DashboardColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: compact ? 6 : 9),
                              _RecentActivity(
                                viewModel: vm,
                                height: compact ? 50 : 60,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
              child: Center(
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: DashboardGlass(
                    radius: 25,
                    colors: const [Color(0xE6273C31), Color(0xE2172520)],
                    child: SizedBox(
                      height: 62,
                      child: Row(
                        children: [
                          _NavItem(
                            icon: Icons.home_rounded,
                            label: 'Inicio',
                            active: _navigationIndex == 0,
                            onTap: () => setState(() => _navigationIndex = 0),
                          ),
                          _NavItem(
                            icon: Icons.confirmation_number_outlined,
                            label: 'Tickets',
                            active: _navigationIndex == 1,
                            onTap: () => _navigateTab(
                              1,
                              () => _showModules(
                                context,
                                vm.modules
                                    .where(
                                      (module) => [
                                        DashboardModule.myTickets,
                                        DashboardModule.pendingTickets,
                                        DashboardModule.departmentTickets,
                                      ].contains(module),
                                    )
                                    .toList(),
                                title: 'Tus tickets',
                              ),
                            ),
                          ),
                          _NavItem(
                            icon: Icons.forum_outlined,
                            label: 'Mensajes',
                            active: _navigationIndex == 2,
                            onTap: () =>
                                _navigateTab(2, () => _showMessages(context)),
                          ),
                          _NavItem(
                            icon: Icons.person_outline_rounded,
                            label: 'Perfil',
                            active: _navigationIndex == 3,
                            onTap: () => _navigateTab(
                              3,
                              () => _showProfile(context, vm, auth),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _navigateTab(int index, Future<void> Function() action) async {
    setState(() => _navigationIndex = index);
    await action();
    if (mounted) setState(() => _navigationIndex = 0);
  }

  Future<void> _showModules(
    BuildContext context,
    List<DashboardModule> modules, {
    String title = 'Todos tus accesos',
  }) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .8,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final module in modules)
                      ListTile(
                        key: Key('all-module-${module.name}'),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                        ),
                        leading: Icon(module.icon, color: DashboardColors.neon),
                        title: Text(
                          module.title,
                          style: const TextStyle(fontSize: 14),
                        ),
                        subtitle: Text(
                          module.description,
                          style: const TextStyle(
                            fontSize: 11,
                            color: DashboardColors.muted,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_outward_rounded,
                          size: 17,
                        ),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          context.push(module.route);
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Future<void> _showProfile(
    BuildContext context,
    DashboardViewModel vm,
    AuthViewModel auth,
  ) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Tu perfil',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: DashboardColors.mint,
                  child: Text(
                    vm.initials,
                    style: const TextStyle(
                      color: DashboardColors.background,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vm.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        vm.user.email,
                        style: const TextStyle(
                          color: DashboardColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final role in vm.roleLabels) Chip(label: Text(role)),
              ],
            ),
            if (vm.user.phone?.isNotEmpty == true) ...[
              const SizedBox(height: 14),
              Text('Teléfono: ${vm.user.phone}'),
            ],
            const Divider(height: 32),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(sheetContext);
                auth.logout();
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    ),
  );

  Future<void> _showMessages(BuildContext context) =>
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (context) => const SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(28, 8, 28, 35),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.forum_outlined,
                  size: 40,
                  color: DashboardColors.neon,
                ),
                SizedBox(height: 18),
                Text(
                  'Mensajes',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 10),
                Text(
                  'Vista previa',
                  style: TextStyle(
                    color: DashboardColors.neon,
                    fontSize: 11,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Aquí encontrarás las conversaciones con tu equipo cuando se habilite la mensajería.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: DashboardColors.muted, height: 1.6),
                ),
              ],
            ),
          ),
        ),
      );

  Future<void> _showNotifications(
    BuildContext context,
    DashboardViewModel vm,
  ) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .65,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Avisos de tickets',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Text(
                vm.pending.isEmpty
                    ? 'No hay avisos pendientes.'
                    : '${vm.pending.length} tickets por revisar.',
                style: const TextStyle(color: DashboardColors.muted),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final ticket in vm.pending.take(8))
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.assignment_outlined,
                          color: DashboardColors.amber,
                        ),
                        title: Text(
                          ticket.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(ticket.status),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          context.push('/tickets/${ticket.ticketId}');
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({
    required this.viewModel,
    required this.compact,
    required this.wide,
  });
  final DashboardViewModel viewModel;
  final bool compact, wide;
  @override
  Widget build(BuildContext context) => DashboardGlass(
    radius: 23,
    borderColor: DashboardColors.neon.withValues(alpha: .4),
    colors: const [Color(0xEC14432D), Color(0xE60C1A12), Color(0xF4111613)],
    child: Padding(
      padding: EdgeInsets.all(
        wide
            ? 26
            : compact
            ? 14
            : 18,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Hola, ${viewModel.firstName}!',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: wide
                            ? 34
                            : compact
                            ? 25
                            : 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      viewModel.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: DashboardColors.mint.withValues(alpha: .72),
                        fontSize: wide ? 14 : 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Tooltip(
                message: 'Porcentaje de tus tickets resueltos o cerrados',
                child: SizedBox(
                  width: wide ? 92 : 70,
                  child: Column(
                    children: [
                      SizedBox.square(
                        dimension: wide
                            ? 64
                            : compact
                            ? 43
                            : 51,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned.fill(
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(
                                  begin: 0,
                                  end: viewModel.resolutionRate,
                                ),
                                duration: const Duration(milliseconds: 450),
                                builder: (context, value, child) =>
                                    CircularProgressIndicator(
                                      value: value,
                                      strokeWidth: 5,
                                      strokeCap: StrokeCap.round,
                                      color: DashboardColors.neon,
                                      backgroundColor: DashboardColors.mint
                                          .withValues(alpha: .13),
                                    ),
                              ),
                            ),
                            Text(
                              viewModel.hasTicketData
                                  ? '${(viewModel.resolutionRate * 100).round()}%'
                                  : '—',
                              style: TextStyle(
                                fontSize: compact ? 11 : 13,
                                color: DashboardColors.mint,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Resolución',
                        style: TextStyle(
                          color: DashboardColors.muted,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 10 : 15),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .28),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: .04),
                    ),
                  ),
                  child: Text(
                    viewModel.user.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: DashboardColors.muted,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: DashboardColors.mint,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    viewModel.primaryRoleLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: DashboardColors.background,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({required this.module, required this.compact});
  final DashboardModule module;
  final bool compact;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      gradient: const LinearGradient(
        colors: [Color(0xFF04D59B), Color(0xFF6BFF7C)],
      ),
      boxShadow: [
        BoxShadow(
          color: DashboardColors.emerald.withValues(alpha: .25),
          blurRadius: 22,
          offset: const Offset(0, 7),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        key: Key('module-${module.name}'),
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.push(module.route),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: compact ? 11 : 15,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFF064A30).withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  module.icon,
                  color: const Color(0xFF063522),
                  size: compact ? 26 : 30,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.title,
                      style: TextStyle(
                        color: const Color(0xFF042919),
                        fontSize: compact ? 17 : 19,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      module.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF075A3A),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_outward_rounded,
                color: Color(0xFF075A3A),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _BentoTile extends StatelessWidget {
  const _BentoTile({
    required this.module,
    required this.viewModel,
    required this.compact,
  });
  final DashboardModule module;
  final DashboardViewModel viewModel;
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final amber = module == DashboardModule.pendingTickets;
    final accent = amber ? DashboardColors.amber : DashboardColors.neon;
    return DashboardGlass(
      radius: 19,
      child: InkWell(
        key: Key('module-${module.name}'),
        borderRadius: BorderRadius.circular(19),
        onTap: () => context.push(module.route),
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(compact ? 5 : 7),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: .09),
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: .09),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: Icon(
                      module.icon,
                      color: accent,
                      size: compact ? 21 : 25,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: amber
                          ? DashboardColors.amber
                          : DashboardColors.mint.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      viewModel.badge(module),
                      style: TextStyle(
                        color: amber
                            ? DashboardColors.background
                            : DashboardColors.mint,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                module.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: compact ? 11 : 13,
                  height: 1.2,
                ),
              ),
              if (!compact) ...[
                const SizedBox(height: 4),
                Text(
                  module.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: DashboardColors.muted,
                    fontSize: 9,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  const _RecentActivity({required this.viewModel, required this.height});
  final DashboardViewModel viewModel;
  final double height;
  @override
  Widget build(BuildContext context) {
    if (viewModel.recentActivity.isEmpty) {
      return SizedBox(
        height: height,
        child: DashboardGlass(
          radius: 13,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Icon(
                  viewModel.isLoading
                      ? Icons.hourglass_top_rounded
                      : Icons.history_rounded,
                  color: DashboardColors.muted,
                  size: 19,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    viewModel.isLoading
                        ? 'Cargando tu actividad…'
                        : viewModel.loadError ??
                              'Aún no tienes tickets registrados.',
                    maxLines: 2,
                    style: const TextStyle(
                      color: DashboardColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: viewModel.recentActivity.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) =>
            _ActivityTile(ticket: viewModel.recentActivity[index]),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.ticket});
  final Ticket ticket;
  @override
  Widget build(BuildContext context) {
    final done = ['resuelto', 'cerrado'].contains(ticket.status.toLowerCase());
    return SizedBox(
      width: 174,
      child: DashboardGlass(
        radius: 13,
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: () => context.push('/tickets/${ticket.ticketId}'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? DashboardColors.neon : DashboardColors.amber,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (done
                                    ? DashboardColors.neon
                                    : DashboardColors.amber)
                                .withValues(alpha: .3),
                        blurRadius: 7,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ticket.status,
                        style: const TextStyle(
                          fontSize: 9,
                          color: DashboardColors.muted,
                        ),
                      ),
                    ],
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

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Expanded(
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: active ? DashboardColors.neon : DashboardColors.muted,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? DashboardColors.neon : DashboardColors.muted,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
