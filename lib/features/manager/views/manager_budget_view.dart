import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/centrix_theme.dart';
import '../models/manager_request.dart';
import '../viewmodels/manager_view_model.dart';
import 'widgets/manager_widgets.dart';

class ManagerBudgetView extends StatelessWidget {
  const ManagerBudgetView({super.key});
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ManagerViewModel>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ManagerPageTitle(
          title: 'Un presupuesto. Más posibilidades.',
          description: 'Visualiza los recursos de Operaciones y planea las siguientes decisiones.',
          action: OutlinedButton.icon(
            key: const Key('adjust-manager-budget'),
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => _BudgetDialog(vm),
            ),
            icon: const Icon(Icons.tune_rounded, size: 18),
            label: const Text('Ajustar presupuesto'),
          ),
        ),
        const SizedBox(height: 24),
        ManagerCard(
          dark: true,
          padding: 28,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final summary = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PRESUPUESTO DEL DEPARTAMENTO',
                    style: TextStyle(
                      color: CentrixColors.sage,
                      letterSpacing: 2,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      managerMoney(vm.budget),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Noviembre de 2026  ·  MXN',
                    style: TextStyle(color: CentrixColors.sage, fontSize: 12),
                  ),
                  const SizedBox(height: 28),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: LinearProgressIndicator(
                      value: vm.budget == 0
                          ? 0
                          : (vm.spent / vm.budget).clamp(0, 1),
                      minHeight: 9,
                      color: CentrixColors.sage,
                      backgroundColor: Colors.white.withValues(alpha: .12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${(vm.spent / vm.budget * 100).toStringAsFixed(1)}% ejercido · ${managerMoney(vm.available)} disponible',
                    style: const TextStyle(
                      color: CentrixColors.mint,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              );
              final ring = SizedBox.square(
                dimension: 184,
                child: CustomPaint(
                  painter: _BudgetRing(vm.spent / vm.budget),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(vm.available / vm.budget * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'DISPONIBLE',
                          style: TextStyle(
                            color: CentrixColors.sage,
                            fontSize: 9,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
              if (constraints.maxWidth < 600) return summary;
              return Row(
                children: [
                  Expanded(child: summary),
                  const SizedBox(width: 44),
                  ring,
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 18),
        ManagerStats(
          children: [
            ManagerStat(
              label: 'Ejercido',
              value: managerMoney(vm.spent),
              caption: 'Incluye solicitudes aprobadas',
              icon: Icons.check_circle_outline_rounded,
            ),
            ManagerStat(
              label: 'Disponible',
              value: managerMoney(vm.available),
              caption: 'Recursos sin ejercer',
              icon: Icons.savings_outlined,
            ),
            ManagerStat(
              label: 'Por autorizar',
              value: managerMoney(vm.pendingAmount),
              caption: 'Todavía no descuenta presupuesto',
              icon: Icons.hourglass_top_rounded,
            ),
          ],
        ),
        const SizedBox(height: 28),
        Text(
          'Distribución por categoría',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 7),
        const Text(
          'Una lectura clara de cómo se utilizan los recursos.',
          style: TextStyle(color: CentrixColors.forest, fontSize: 13),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 650 ? 2 : 1;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final category in ManagerCategory.values)
                  SizedBox(
                    width:
                        (constraints.maxWidth - (columns - 1) * 16) / columns,
                    child: ManagerCard(
                      padding: 22,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(11),
                                decoration: BoxDecoration(
                                  color: CentrixColors.raised,
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: Icon(
                                  managerCategoryIcon(category),
                                  size: 21,
                                  color: CentrixColors.leaf,
                                ),
                              ),
                              const SizedBox(width: 13),
                              Expanded(
                                child: Text(
                                  category.label,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Asignado',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: CentrixColors.forest,
                                  ),
                                ),
                              ),
                              Text(
                                managerMoney(vm.allocation(category)),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: LinearProgressIndicator(
                              minHeight: 7,
                              value:
                                  (vm.categorySpent(category) /
                                          vm.allocation(category))
                                      .clamp(0, 1),
                              backgroundColor: CentrixColors.raised,
                              color: CentrixColors.leaf,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 14,
                            runSpacing: 8,
                            children: [
                              Text(
                                'Ejercido ${managerMoney(vm.categorySpent(category))}',
                                style: const TextStyle(
                                  color: CentrixColors.forest,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                'Libre ${managerMoney(vm.allocation(category) - vm.categorySpent(category))}',
                                style: const TextStyle(
                                  color: CentrixColors.leaf,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _BudgetRing extends CustomPainter {
  const _BudgetRing(this.spent);
  final double spent;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(12);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2,
      false,
      paint..color = Colors.white.withValues(alpha: .12),
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * (1 - spent).clamp(0, 1),
      false,
      paint..color = CentrixColors.sage,
    );
  }

  @override
  bool shouldRepaint(_BudgetRing old) => old.spent != spent;
}

class _BudgetDialog extends StatefulWidget {
  const _BudgetDialog(this.viewModel);
  final ManagerViewModel viewModel;
  @override
  State<_BudgetDialog> createState() => _BudgetDialogState();
}

class _BudgetDialogState extends State<_BudgetDialog> {
  late final Map<ManagerCategory, TextEditingController> _controllers;
  String? _error;
  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final category in ManagerCategory.values)
        category: TextEditingController(
          text: (widget.viewModel.allocation(category) / 100).toStringAsFixed(
            2,
          ),
        ),
    };
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Ajustar presupuesto'),
    content: SizedBox(
      width: 460,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Distribuye el presupuesto de noviembre entre las categorías del departamento.',
              style: TextStyle(color: CentrixColors.forest, height: 1.5),
            ),
            const SizedBox(height: 18),
            for (final entry in _controllers.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  key: Key('budget-${entry.key.name}'),
                  controller: entry.value,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: entry.key.label,
                    prefixText: '\$ ',
                    suffixText: 'MXN',
                  ),
                ),
              ),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            const SizedBox(height: 4),
            const Text(
              'Los ajustes son temporales y solo aplican a esta vista previa.',
              style: TextStyle(color: CentrixColors.forest, fontSize: 11),
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        key: const Key('save-manager-budget'),
        onPressed: () {
          final values = <ManagerCategory, int>{};
          for (final entry in _controllers.entries) {
            final text = entry.value.text.trim();
            final parsed = double.tryParse(text);
            if (!RegExp(r'^\d{1,9}(\.\d{1,2})?$').hasMatch(text) ||
                parsed == null ||
                !parsed.isFinite) {
              setState(
                () =>
                    _error = 'Ingresa montos válidos con hasta dos decimales.',
              );
              return;
            }
            values[entry.key] = (parsed * 100).round();
          }
          final error = widget.viewModel.updateBudget(values);
          if (error != null) {
            setState(() => _error = error);
            return;
          }
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Presupuesto actualizado en la vista previa.'),
            ),
          );
        },
        child: const Text('Guardar ajuste'),
      ),
    ],
  );
}
