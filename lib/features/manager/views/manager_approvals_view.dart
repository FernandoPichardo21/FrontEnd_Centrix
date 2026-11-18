import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/centrix_theme.dart';
import '../models/manager_request.dart';
import '../viewmodels/manager_view_model.dart';
import 'widgets/manager_widgets.dart';

class ManagerApprovalsView extends StatelessWidget {
  const ManagerApprovalsView({super.key});
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ManagerViewModel>();
    final selected = vm.selected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ManagerPageTitle(
          title: 'Decisiones que hacen avanzar.',
          description:
              'Revisa las solicitudes de tu equipo y da el siguiente paso.',
        ),
        const SizedBox(height: 24),
        ManagerStats(
          children: [
            ManagerStat(
              label: 'Por revisar',
              value: vm.pending.length.toString().padLeft(2, '0'),
              caption: 'Solicitudes de noviembre',
              icon: Icons.pending_actions_rounded,
              highlight: true,
            ),
            ManagerStat(
              label: 'Monto por autorizar',
              value: managerMoney(vm.pendingAmount),
              caption: 'En solicitudes pendientes · MXN',
              icon: Icons.payments_outlined,
            ),
            ManagerStat(
              label: 'Presupuesto disponible',
              value: managerMoney(vm.available),
              caption: 'Antes de nuevas aprobaciones · MXN',
              icon: Icons.account_balance_wallet_outlined,
            ),
          ],
        ),
        const SizedBox(height: 26),
        LayoutBuilder(
          builder: (context, constraints) {
            final list = ManagerCard(
              padding: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Bandeja de revisión',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Text(
                        '${vm.pending.length} pendientes',
                        style: const TextStyle(
                          fontSize: 11,
                          color: CentrixColors.forest,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Selecciona una solicitud para ver el detalle.',
                    style: TextStyle(color: CentrixColors.forest, fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                  if (vm.pending.isEmpty)
                    const ManagerEmpty(
                      title: 'Todo al día',
                      message: 'Tu equipo ya tiene respuesta a todas sus solicitudes de este mes.',
                    ),
                  for (final request in vm.pending)
                    _ApprovalTile(
                      request: request,
                      selected: selected?.id == request.id,
                      onTap: () => vm.selectRequest(request.id),
                    ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: CentrixColors.raised.withValues(alpha: .75),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.tips_and_updates_outlined,
                          color: CentrixColors.leaf,
                          size: 19,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Antes de aprobar, revisa la justificación y el presupuesto de la categoría.',
                            style: TextStyle(
                              fontSize: 11,
                              color: CentrixColors.forest,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
            final detail = selected == null
                ? const ManagerCard(
                    child: ManagerEmpty(
                      title: 'Selecciona una solicitud',
                      message: 'Aquí encontrarás la información necesaria para tomar una decisión.',
                    ),
                  )
                : ManagerRequestDetail(
                    request: selected,
                    viewModel: vm,
                    canDecide: true,
                  );
            if (constraints.maxWidth < 850) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [list, const SizedBox(height: 18), detail],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: list),
                const SizedBox(width: 20),
                Expanded(flex: 6, child: detail),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ApprovalTile extends StatelessWidget {
  const _ApprovalTile({
    required this.request,
    required this.selected,
    required this.onTap,
  });
  final ManagerRequest request;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Material(
      color: selected
          ? CentrixColors.leaf.withValues(alpha: .10)
          : CentrixColors.surface.withValues(alpha: .8),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        key: Key('review-${request.id}'),
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? CentrixColors.sage
                  : CentrixColors.sage.withValues(alpha: .18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    request.id,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: CentrixColors.leaf,
                    ),
                  ),
                  const Spacer(),
                  if (request.priority == 'Alta')
                    const Text(
                      '● Prioridad alta',
                      style: TextStyle(fontSize: 10, color: Color(0xFFFFB97D)),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                request.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                request.applicant,
                style: const TextStyle(
                  fontSize: 11,
                  color: CentrixColors.forest,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      managerMoney(request.amountCents),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.arrow_forward_rounded,
                    size: 19,
                    color: CentrixColors.leaf,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
