import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/centrix_theme.dart';
import '../models/manager_request.dart';
import '../viewmodels/manager_view_model.dart';
import 'widgets/manager_widgets.dart';

const _months = {9: 'Septiembre', 10: 'Octubre', 11: 'Noviembre'};

class ManagerReportsView extends StatelessWidget {
  const ManagerReportsView({super.key});
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ManagerViewModel>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ManagerPageTitle(
          title: 'Del seguimiento a la claridad.',
          description:
              'Los movimientos de tu departamento, en una sola mirada.',
          action: OutlinedButton.icon(
            onPressed: () => _reportPreview(context, vm),
            icon: const Icon(Icons.description_outlined, size: 18),
            label: const Text('Vista previa del reporte'),
          ),
        ),
        const SizedBox(height: 24),
        ManagerCard(
          padding: 18,
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 20,
            runSpacing: 14,
            children: [
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    color: CentrixColors.leaf,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Periodo del reporte',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ],
              ),
              DropdownButton<int>(
                key: const Key('manager-report-month'),
                value: vm.reportMonth,
                underline: const SizedBox.shrink(),
                items: [
                  for (final month in _months.entries)
                    DropdownMenuItem(
                      value: month.key,
                      child: Text('${month.value} 2026'),
                    ),
                ],
                onChanged: (month) {
                  if (month != null) vm.selectReportMonth(month);
                },
              ),
              const Chip(
                avatar: Icon(Icons.apartment_outlined, size: 15),
                label: Text('Operaciones'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        ManagerStats(
          children: [
            ManagerStat(
              label: 'Solicitudes del periodo',
              value: '${vm.reportRequests.length}',
              caption: '${_months[vm.reportMonth]} de 2026',
              icon: Icons.folder_open_rounded,
              highlight: true,
            ),
            ManagerStat(
              label: 'Monto solicitado',
              value: managerMoney(vm.reportTotal),
              caption: 'Todas las solicitudes · MXN',
              icon: Icons.payments_outlined,
            ),
            ManagerStat(
              label: 'Monto aprobado',
              value: managerMoney(
                vm.reportAmount(ManagerRequestStatus.approved),
              ),
              caption: 'Solicitudes autorizadas · MXN',
              icon: Icons.task_alt_rounded,
            ),
          ],
        ),
        const SizedBox(height: 22),
        LayoutBuilder(
          builder: (context, constraints) {
            final status = ManagerCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Estado de las solicitudes',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Distribución del periodo seleccionado',
                    style: TextStyle(fontSize: 11, color: CentrixColors.forest),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: SizedBox.square(
                      dimension: 175,
                      child: CustomPaint(
                        painter: _StatusRing([
                          for (final state in ManagerRequestStatus.values)
                            vm.reportCount(state),
                        ]),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${vm.reportRequests.length}',
                                style: const TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1,
                                ),
                              ),
                              const Text(
                                'SOLICITUDES',
                                style: TextStyle(
                                  fontSize: 9,
                                  letterSpacing: 1.5,
                                  color: CentrixColors.forest,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  for (final state in ManagerRequestStatus.values)
                    Padding(
                      padding: const EdgeInsets.only(top: 9),
                      child: Row(
                        children: [
                          ManagerStatusChip(state),
                          const Spacer(),
                          Text(
                            '${vm.reportCount(state)}',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
            final chart = ManagerCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Recursos por categoría',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Montos solicitados en el periodo · MXN',
                    style: TextStyle(fontSize: 11, color: CentrixColors.forest),
                  ),
                  const SizedBox(height: 32),
                  for (final category in ManagerCategory.values)
                    Builder(
                      builder: (context) {
                        final amount = vm.reportRequests
                            .where((r) => r.category == category)
                            .fold(0, (sum, r) => sum + r.amountCents);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 26),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    managerCategoryIcon(category),
                                    size: 16,
                                    color: CentrixColors.leaf,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      category.label,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  Text(
                                    managerMoney(amount),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: vm.reportTotal == 0
                                      ? 0
                                      : amount / vm.reportTotal,
                                  minHeight: 10,
                                  color: CentrixColors.leaf,
                                  backgroundColor: CentrixColors.raised,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: CentrixColors.raised.withValues(alpha: .75),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Los reportes se actualizan con las decisiones que tomas en esta vista previa.',
                      style: TextStyle(
                        color: CentrixColors.forest,
                        fontSize: 11,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
            if (constraints.maxWidth < 800) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [status, const SizedBox(height: 18), chart],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 4, child: status),
                const SizedBox(width: 20),
                Expanded(flex: 6, child: chart),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        ManagerCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Movimientos del periodo',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 18),
              for (final request in vm.reportRequests)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          request.id,
                          style: const TextStyle(
                            color: CentrixColors.leaf,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 240,
                        child: Text(
                          request.title,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      ManagerStatusChip(request.status),
                      Text(
                        managerMoney(request.amountCents),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _reportPreview(
    BuildContext context,
    ManagerViewModel vm,
  ) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Reporte del departamento'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'CENTRIX · OPERACIONES',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text('${_months[vm.reportMonth]} de 2026'),
              const Divider(height: 30),
              Text('Solicitudes registradas: ${vm.reportRequests.length}'),
              const SizedBox(height: 10),
              Text('Monto solicitado: ${managerMoney(vm.reportTotal)} MXN'),
              const SizedBox(height: 10),
              Text(
                'Monto aprobado: ${managerMoney(vm.reportAmount(ManagerRequestStatus.approved))} MXN',
              ),
              const Divider(height: 30),
              for (final request in vm.reportRequests)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '${request.id} · ${request.title}\n${request.status.label} · ${managerMoney(request.amountCents)}',
                    style: const TextStyle(fontSize: 12, height: 1.6),
                  ),
                ),
              const Text(
                'Documento de ejemplo · Vista previa',
                style: TextStyle(fontSize: 11, color: CentrixColors.forest),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    ),
  );
}

class _StatusRing extends CustomPainter {
  const _StatusRing(this.counts);
  final List<int> counts;
  @override
  void paint(Canvas canvas, Size size) {
    const colors = [
      CentrixColors.amber,
      CentrixColors.leaf,
      CentrixColors.error,
    ];
    final total = counts.fold(0, (sum, value) => sum + value);
    final rect = (Offset.zero & size).deflate(12);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      paint..color = CentrixColors.raised,
    );
    var start = -math.pi / 2;
    if (total == 0) return;
    for (var i = 0; i < counts.length; i++) {
      final sweep = counts[i] / total * math.pi * 2;
      if (sweep > 0) {
        canvas.drawArc(
          rect,
          start + .025,
          math.max(0.0, sweep - .05),
          false,
          paint..color = colors[i],
        );
      }
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_StatusRing old) =>
      old.counts.toString() != counts.toString();
}
